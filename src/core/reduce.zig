const std = @import("std");
const common = @import("../common.zig");
const range = @import("../util/range.zig");
const testing = std.testing;

const ArrayList = std.ArrayList;

/// Reduce slice of type `T` using function `func`.
/// Additionally supply some arguments to `func` and an initial value to reduce from.
pub fn reduceSlice(comptime T: type, slice: []const T, comptime func: anytype, args: anytype, initial_value: @typeInfo(@TypeOf(func)).Fn.return_type.?) @typeInfo(@TypeOf(func)).Fn.return_type.? {
    const ReturnType = @typeInfo(@TypeOf(func)).Fn.return_type.?;

    var accumulator: ReturnType = initial_value;

    for (slice[0..]) |item| {
        accumulator = @call(.auto, func, .{ accumulator, item } ++ args);
    }

    return accumulator;
}

/// Reduce array list of type `T` using function `func`.
/// Additionally supply some arguments to `func` and an initial value to reduce from.
pub fn reduceArrayList(comptime T: type, arr: ArrayList(T), comptime func: anytype, args: anytype, initial_value: @typeInfo(@TypeOf(func)).Fn.return_type.?) @typeInfo(@TypeOf(func)).Fn.return_type.? {
    const ReturnType = @typeInfo(@TypeOf(func)).Fn.return_type.?;

    var accumulator: ReturnType = initial_value;

    for (arr.items[0..]) |item| {
        accumulator = @call(.auto, func, .{ accumulator, item } ++ args);
    }

    return accumulator;
}

const CommonReducers = common.CommonReducers;

const Point2D = struct {
    x: i32,
    y: i32,
};

fn sumPointY(prev: i32, curr: Point2D) i32 {
    return prev + curr.y;
}

test "test reduce slice on i32 slice" {
    const slice = [_]i32{ 1, 2, 3 };
    const result = reduceSlice(
        i32,
        &slice,
        CommonReducers.sum(i32),
        .{},
        0,
    );

    try testing.expectEqual(result, 6);
}

test "test reduce struct field" {
    const slice = [_]Point2D{ .{ .x = 1, .y = 2 }, .{ .x = 2, .y = 3 }, .{ .x = 3, .y = 4 } };
    const result = reduceSlice(
        Point2D,
        &slice,
        sumPointY,
        .{},
        0,
    );

    try testing.expectEqual(result, 9);
}

test "test reduce i32 array list" {
    const allocator = testing.allocator;
    const arr = try range.rangeArrayList(allocator, i32, 4);
    defer arr.deinit();

    const result = reduceArrayList(
        i32,
        arr,
        CommonReducers.sum(i32),
        .{},
        0,
    );

    try testing.expectEqual(result, 6);
}
