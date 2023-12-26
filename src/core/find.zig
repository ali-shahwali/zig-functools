const std = @import("std");
const FunctoolTypeError = @import("errors.zig").FunctoolTypeError;
const testing = std.testing;
const common = @import("../common.zig");

const CommonMappers = common.CommonMappers;
const CommonReducers = common.CommonReducers;
const CommonPredicates = common.CommonPredicates;

const Allocator = std.mem.Allocator;

/// Find and retrieve first item that predicate `pred` evaluates to true in slice of type `T`.
/// Additionally supply some arguments to `pred`.
pub fn findSlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) !?T {
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
            return item;
        }
    }

    return null;
}

const Point2D = struct {
    x: i32,
    y: i32,
};

test "test find slice" {
    const slice = [_]Point2D{
        .{ .x = 8, .y = 1 },
        .{ .x = 4, .y = 3 },
        .{ .x = 2, .y = 4 },
    };

    const found = try findSlice(
        Point2D,
        &slice,
        CommonPredicates.fieldEq(Point2D, i32),
        .{ "x", 2 },
    );

    try testing.expect(found != null);
    try testing.expectEqual(found.?, slice[2]);

    const not_found = try findSlice(
        Point2D,
        &slice,
        CommonPredicates.fieldEq(Point2D, i32),
        .{ "y", 5 },
    );

    try testing.expect(not_found == null);
}
