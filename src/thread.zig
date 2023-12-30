//! This module contains the Thread API

const std = @import("std");
const core = @import("core.zig");
const util = @import("util.zig");
const common = @import("common.zig");

const Allocator = std.mem.Allocator;
const testing = std.testing;

/// A data structure used for chaining multiple functional calls.
pub fn Thread(comptime T: type) type {
    return struct {
        slice: []T,
        err: ?error{ FunctoolTypeError, OutOfMemory } = null,
        allocator: Allocator,

        const Self = @This();

        /// Initialize thread
        pub fn init(allocator: Allocator, data: []T) Self {
            const slice = allocator.alloc(T, data.len) catch |err| {
                return .{
                    .err = err,
                    .slice = undefined,
                    .allocator = allocator,
                };
            };
            @memcpy(slice, data);
            return .{
                .allocator = allocator,
                .slice = slice,
            };
        }

        pub fn deinit(self: *const Self) void {
            self.allocator.free(self.slice);
        }

        /// Perform mapping, returns Thread with mapping peformed.
        pub fn map(self: *const Self, comptime func: anytype, args: anytype) Self {
            if (self.err) |err| {
                return .{
                    .err = err,
                    .allocator = self.allocator,
                    .slice = self.slice,
                };
            }
            core.mapMutSlice(T, self.slice, func, args);

            return .{
                .allocator = self.allocator,
                .slice = self.slice,
            };
        }

        /// Perform filtering, returns Thread with filtering peformed.
        pub fn filter(self: *const Self, comptime pred: anytype, args: anytype) Self {
            if (self.err) |err| {
                return .{
                    .slice = self.slice,
                    .err = err,
                    .allocator = self.allocator,
                };
            }
            const filtered = core.filterSlice(self.allocator, T, self.slice, pred, args) catch |err| {
                return .{
                    .slice = self.slice,
                    .err = err,
                    .allocator = self.allocator,
                };
            };

            defer self.allocator.free(filtered);
            _ = self.allocator.resize(self.slice, filtered.len);
            @memcpy(self.slice[0..filtered.len], filtered);

            return .{
                .slice = self.slice[0..filtered.len],
                .allocator = self.allocator,
            };
        }

        /// Perform reduce, returns result from reducing and deinits thread making it unusable.
        pub fn reduce(self: *const Self, comptime func: anytype, args: anytype, initial_value: T) !T {
            defer self.deinit();
            if (self.err) |err| {
                return err;
            }
            return core.reduceSlice(T, self.slice, func, args, initial_value);
        }

        /// Perform some, returns result from some and deinits thread making it unusable.
        pub fn some(self: *const Self, comptime pred: anytype, args: anytype) !bool {
            defer self.deinit();
            if (self.err) |err| {
                return err;
            }
            return core.someSlice(T, self.slice, pred, args);
        }

        /// Perform every, returns result from every and deinits thread making it unusable.
        pub fn every(self: *const Self, comptime pred: anytype, args: anytype) !bool {
            defer self.deinit();
            if (self.err) |err| {
                return err;
            }
            return core.everySlice(T, self.slice, pred, args);
        }

        /// Perform find, returns result from find and deinits thread making it unusable.
        pub fn find(self: *const Self, comptime pred: anytype, args: anytype) !?T {
            defer self.deinit();
            if (self.err) |err| {
                return err;
            }
            return core.findSlice(T, self.slice, pred, args);
        }

        /// Returns current result, user of function must make sure to free returned slice.
        pub fn result(self: *const Self) ![]T {
            if (self.err) |err| {
                return err;
            } else {
                return self.slice;
            }
        }
    };
}

const CommonMappers = common.CommonMappers;
const CommonPredicates = common.CommonPredicates;
const CommonReducers = common.CommonReducers;

test "test threading map->filter->reduce" {
    const allocator = testing.allocator;
    const slice = try util.rangeSlice(allocator, i32, 10);
    defer allocator.free(slice);

    const result = try Thread(i32)
        .init(allocator, slice)
        .map(CommonMappers.inc(i32), .{})
        .filter(CommonPredicates.even(i32), .{})
        .reduce(CommonReducers.sum(i32), .{}, 0);

    try testing.expectEqual(result, 30);
}

test "test threading map->filter" {
    const allocator = testing.allocator;
    const slice = try util.rangeSlice(allocator, i32, 10);
    defer allocator.free(slice);

    const result = try Thread(i32)
        .init(allocator, slice)
        .map(CommonMappers.inc(i32), .{})
        .filter(CommonPredicates.even(i32), .{})
        .result();

    defer allocator.free(result);

    try testing.expectEqualSlices(i32, &[_]i32{ 2, 4, 6, 8, 10 }, result);
}

test "test threading map->filter->some" {
    const allocator = testing.allocator;
    const slice = try util.rangeSlice(allocator, i32, 10);
    defer allocator.free(slice);

    const some_even = try Thread(i32)
        .init(allocator, slice)
        .map(CommonMappers.inc(i32), .{})
        .filter(CommonPredicates.odd(i32), .{})
        .some(CommonPredicates.even(i32), .{});

    try testing.expect(!some_even);
}

test "test threading map->filter->every" {
    const allocator = testing.allocator;
    const slice = try util.rangeSlice(allocator, i32, 10);
    defer allocator.free(slice);

    const every_odd = try Thread(i32)
        .init(allocator, slice)
        .map(CommonMappers.inc(i32), .{})
        .filter(CommonPredicates.odd(i32), .{})
        .every(CommonPredicates.odd(i32), .{});

    try testing.expect(every_odd);
}

test "test threading map->filter->find" {
    const allocator = testing.allocator;
    const slice = try util.rangeSlice(allocator, i32, 10);
    defer allocator.free(slice);

    const nine = try Thread(i32)
        .init(allocator, slice)
        .map(CommonMappers.inc(i32), .{})
        .filter(CommonPredicates.odd(i32), .{})
        .find(CommonPredicates.eq(i32), .{@as(i32, 9)});

    try testing.expect(nine != null);
    try testing.expect(nine.? == 9);
}
