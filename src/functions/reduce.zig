const std = @import("std");
const FunctoolTypeError = @import("errors.zig").FunctoolTypeError;
const testing = std.testing;
const common = @import("../common.zig");

const CommonReducers = common.CommonReducers;

/// Reduce slice of type `T` to value of type `RT` using function `func`.
/// Additionally supply some arguments to `func` and an initial value to reduce from.
pub fn reduceSlice(comptime T: type, slice: []const T, comptime func: anytype, args: anytype, initial_value: @typeInfo(@TypeOf(func)).Fn.return_type.?) !@typeInfo(@TypeOf(func)).Fn.return_type.? {
    const ReturnType = @typeInfo(@TypeOf(func)).Fn.return_type orelse {
        return FunctoolTypeError.InvalidReturnType;
    };
    comptime {
        if (@typeInfo(@TypeOf(func)).Fn.params[0].type.? != ReturnType) {
            return FunctoolTypeError.InvalidParamType;
        }
        if (@typeInfo(@TypeOf(func)).Fn.params[1].type.? != T) {
            return FunctoolTypeError.InvalidParamType;
        }
    }

    var accumulator: ReturnType = initial_value;

    for (slice[0..]) |item| {
        accumulator = @call(.auto, func, .{ accumulator, item } ++ args);
    }

    return accumulator;
}

test "test reduce slice on i32 slice" {
    const slice = [_]i32{ 1, 2, 3 };
    const result = try reduceSlice(
        i32,
        &slice,
        CommonReducers.sum(i32),
        .{},
        0,
    );

    try testing.expectEqual(result, 6);
}

const Point2D = struct {
    x: i32,
    y: i32,
};

fn sumPointY(prev: i32, curr: Point2D) i32 {
    return prev + curr.y;
}

test "test reduce struct field" {
    const slice = [_]Point2D{ .{ .x = 1, .y = 2 }, .{ .x = 2, .y = 3 }, .{ .x = 3, .y = 4 } };
    const result = try reduceSlice(
        Point2D,
        &slice,
        sumPointY,
        .{},
        0,
    );

    try testing.expectEqual(result, 9);
}
