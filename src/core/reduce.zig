const std = @import("std");
const common = @import("../common.zig");
const range = @import("../util/range.zig");
const typed = @import("typed");

const testing = std.testing;
const ArrayList = std.ArrayList;

/// Reduce slice using function `reducer`.
/// Additionally supply some arguments to `reducer`.
/// Supply an initial value to reduce from.
pub fn reduceSlice(comptime reducer: anytype, slice: []const typed.ParamType(reducer, 1), args: anytype, initial_value: typed.ReturnType(reducer)) typed.ReturnType(reducer) {
    const ReturnType = typed.ReturnType(reducer);

    var accumulator: ReturnType = initial_value;

    for (slice[0..]) |item| {
        accumulator = @call(.auto, reducer, .{ accumulator, item } ++ args);
    }

    return accumulator;
}

/// Reduce array list using function `reducer`.
/// Additionally supply some arguments to `reducer`.
/// Supply an initial value to reduce from.
pub fn reduceArrayList(comptime reducer: anytype, arr: ArrayList(typed.ParamType(reducer, 1)), args: anytype, initial_value: typed.ReturnType(reducer)) typed.ReturnType(reducer) {
    const ReturnType = typed.ReturnType(reducer);

    var accumulator: ReturnType = initial_value;

    for (arr.items[0..]) |item| {
        accumulator = @call(.auto, reducer, .{ accumulator, item } ++ args);
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
        CommonReducers.sum(i32),
        &slice,
        .{},
        0,
    );

    try testing.expectEqual(result, 6);
}

test "test reduce struct field" {
    const slice = [_]Point2D{ .{ .x = 1, .y = 2 }, .{ .x = 2, .y = 3 }, .{ .x = 3, .y = 4 } };
    const result = reduceSlice(
        sumPointY,
        &slice,
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
        CommonReducers.sum(i32),
        arr,
        .{},
        0,
    );

    try testing.expectEqual(result, 6);
}
