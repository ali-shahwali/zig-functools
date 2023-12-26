const std = @import("std");
const FunctoolTypeError = @import("errors.zig").FunctoolTypeError;
const testing = std.testing;
const common = @import("../common.zig");

const CommonMappers = common.CommonMappers;
const CommonReducers = common.CommonReducers;
const CommonPredicates = common.CommonPredicates;

/// Returns true if `slice` contains an item of type `T` that passes the predicate specified by `pred`.
/// Additionally supply some arguments to `pred`.
pub fn someSlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) !bool {
    comptime {
        if (@typeInfo(@TypeOf(pred)).Fn.params[0].type.? != T) {
            return FunctoolTypeError.InvalidParamType;
        }
        if (@typeInfo(@TypeOf(pred)).Fn.return_type.? != bool) {
            return FunctoolTypeError.InvalidReturnType;
        }
    }

    for (slice[0..]) |item| {
        if (@call(.auto, pred, .{item} ++ args)) {
            return true;
        }
    }

    return false;
}

const Point2D = struct {
    x: i32,
    y: i32,
};

test "test some on i32 slice" {
    const slice = [_]i32{ 1, 3, 5 };
    const some_even = try someSlice(
        i32,
        &slice,
        CommonPredicates.even(i32),
        .{},
    );

    try testing.expect(!some_even);
}

fn orthogonal(p1: Point2D, p2: Point2D) bool {
    return (p1.x * p2.x + p1.y * p2.y) == 0;
}

test "test some on Point2D slice" {
    const slice = [_]Point2D{
        .{ .x = 5, .y = 2 },
        .{ .x = 1, .y = 3 },
        .{ .x = 0, .y = 4 }, // This one is orthogonal to (1, 0)
    };

    const e_x = Point2D{ .x = 1, .y = 0 };
    const some_orthogonal = try someSlice(Point2D, &slice, orthogonal, .{e_x});

    try testing.expect(some_orthogonal);
}
