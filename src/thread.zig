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
            core.mapSlice(func, self.slice, args);

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
            const filtered = core.filterSlice(self.allocator, pred, self.slice, args) catch |err| {
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
        pub fn reduce(self: *const Self, comptime reducer: anytype, args: anytype, initial_value: T) !T {
            defer self.deinit();
            if (self.err) |err| {
                return err;
            }
            return core.reduceSlice(reducer, self.slice, args, initial_value);
        }

        /// Perform some, returns result from some and deinits thread making it unusable.
        pub fn some(self: *const Self, comptime pred: anytype, args: anytype) !bool {
            defer self.deinit();
            if (self.err) |err| {
                return err;
            }
            return core.someSlice(pred, self.slice, args);
        }

        /// Perform every, returns result from every and deinits thread making it unusable.
        pub fn every(self: *const Self, comptime pred: anytype, args: anytype) !bool {
            defer self.deinit();
            if (self.err) |err| {
                return err;
            }
            return core.everySlice(pred, self.slice, args);
        }

        /// Perform find, returns result from find and deinits thread making it unusable.
        pub fn find(self: *const Self, comptime pred: anytype, args: anytype) !?T {
            defer self.deinit();
            if (self.err) |err| {
                return err;
            }
            return core.findSlice(pred, self.slice, args);
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

/// VTable specifying the interface for Threadable types.
/// Threadable types must implement a `thread` fn.
pub fn Threadable(comptime T: type) type {
    return struct {
        ptr: *anyopaque,
        vtab: *const VTab,

        const Self = @This();

        const VTab = struct {
            thread: *const fn (ptr: *anyopaque) Thread(T),
        };

        pub fn thread(self: Self) Thread(T) {
            return self.vtab.thread(self.ptr);
        }

        fn validPtr(comptime PtrInfo: std.builtin.Type) bool {
            return PtrInfo == .Pointer and PtrInfo.Pointer.size == .One and @typeInfo(PtrInfo.Pointer.child) == .Struct;
        }

        pub fn init(obj_ptr: anytype) Self {
            const Ptr = @TypeOf(obj_ptr);
            const PtrInfo = @typeInfo(Ptr);

            std.debug.assert(validPtr(PtrInfo));

            const Impl = struct {
                fn thread(ptr: *anyopaque) Thread(T) {
                    const self = @as(Ptr, @ptrCast(@alignCast(ptr)));
                    return self.thread();
                }
            };

            return .{
                .ptr = obj_ptr,
                .vtab = &.{
                    .thread = Impl.thread,
                },
            };
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
        .find(CommonPredicates.eq(i32), .{9});

    try testing.expect(nine != null);
    try testing.expect(nine.? == 9);
}
