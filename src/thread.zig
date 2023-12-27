const std = @import("std");
const core = @import("core.zig");
const util = @import("util.zig");
const Allocator = std.mem.Allocator;
const testing = std.testing;
const common = @import("common.zig");

pub fn Thread(comptime T: type) type {
    return struct {
        err: ?error{ FunctoolTypeError, OutOfMemory } = null,
        allocator: Allocator,

        const Self = @This();

        var slice: []T = undefined;

        pub fn init(allocator: Allocator, data: []T) Self {
            slice = allocator.alloc(T, data.len) catch |err| {
                return .{ .allocator = allocator, .err = err };
            };
            @memcpy(slice, data);
            return .{
                .allocator = allocator,
            };
        }

        pub fn map(self: *const Self, comptime func: anytype, args: anytype) Self {
            if (self.err) |err| {
                return .{
                    .err = err,
                    .allocator = self.allocator,
                };
            }
            core.mapMutSlice(T, slice, func, args) catch |err| {
                return .{
                    .err = err,
                    .allocator = self.allocator,
                };
            };

            return .{
                .allocator = self.allocator,
            };
        }

        pub fn filter(self: *const Self, comptime pred: anytype, args: anytype) Self {
            if (self.err) |err| {
                return .{
                    .err = err,
                    .allocator = self.allocator,
                };
            }
            const filtered = core.filterSlice(self.allocator, T, slice, pred, args) catch |err| {
                return .{
                    .err = err,
                    .allocator = self.allocator,
                };
            };
            defer self.allocator.free(filtered);
            _ = self.allocator.resize(slice, filtered.len);
            @memcpy(slice[0..filtered.len], filtered);
            slice = slice[0..filtered.len];
            return .{
                .allocator = self.allocator,
            };
        }

        pub fn reduce(self: *const Self, comptime func: anytype, args: anytype, initial_value: T) !T {
            defer self.allocator.free(slice);
            if (self.err) |err| {
                return err;
            }
            return core.reduceSlice(T, slice, func, args, initial_value) catch |err| {
                return err;
            };
        }

        pub fn some(self: *const Self, comptime pred: anytype, args: anytype) !bool {
            defer self.allocator.free(slice);
            if (self.err) |err| {
                return err;
            }
            return core.someSlice(T, slice, pred, args) catch |err| {
                return err;
            };
        }

        pub fn every(self: *const Self, comptime pred: anytype, args: anytype) !bool {
            defer self.allocator.free(slice);
            if (self.err) |err| {
                return err;
            }
            return core.everySlice(T, slice, pred, args) catch |err| {
                return err;
            };
        }

        pub fn find(self: *const Self, comptime pred: anytype, args: anytype) !?T {
            defer self.allocator.free(slice);
            if (self.err) |err| {
                return err;
            }
            return core.findSlice(T, slice, pred, args) catch |err| {
                return err;
            };
        }

        pub fn result(self: *const Self) ![]T {
            if (self.err) |err| {
                return err;
            } else {
                return slice;
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
