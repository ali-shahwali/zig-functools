const std = @import("std");
const testing = std.testing;
const common = @import("../common.zig");
const rangeArrayList = @import("../util.zig").rangeArrayList;

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

/// Returns true if predicate defined by `pred` is true for every element in `slice` of type `T`.
/// Additionally supply some arguments to `pred`.
pub fn everySlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) bool {
    for (slice[0..]) |item| {
        if (!@call(.auto, pred, .{item} ++ args)) {
            return false;
        }
    }

    return true;
}

/// Returns true if predicate defined by `pred` is true for every item in array list of type `T`.
/// Additionally supply some arguments to `pred`.
pub fn everyArrayList(comptime T: type, arr: ArrayList(T), comptime pred: anytype, args: anytype) bool {
    for (arr.items) |item| {
        if (!@call(.auto, pred, .{item} ++ args)) {
            return false;
        }
    }

    return true;
}

const Point2D = struct {
    x: i32,
    y: i32,
};

fn orthogonal(p1: Point2D, p2: Point2D) bool {
    return (p1.x * p2.x + p1.y * p2.y) == 0;
}

test "test every on Point2D slice" {
    const slice = [_]Point2D{
        .{ .x = 0, .y = 1 },
        .{ .x = 0, .y = 3 },
        // This one is not orthogonal to (1, 0)
        .{ .x = 1, .y = 4 },
    };
    const e_x = Point2D{ .x = 1, .y = 0 };
    const every_orthogonal = everySlice(Point2D, &slice, orthogonal, .{e_x});

    try testing.expect(!every_orthogonal);
}

test "test every on Point2D array list" {
    const allocator = testing.allocator;
    var arr = ArrayList(Point2D).init(allocator);
    defer arr.deinit();

    try arr.append(.{ .x = 0, .y = 1 });
    try arr.append(.{ .x = 0, .y = 3 });
    try arr.append(.{ .x = 1, .y = 4 });

    const e_x = Point2D{ .x = 1, .y = 0 };
    const every_orthogonal = everyArrayList(Point2D, arr, orthogonal, .{e_x});

    try testing.expect(!every_orthogonal);
}
