const std = @import("std");
const testing = std.testing;
const common = @import("../common.zig");
const rangeArrayList = @import("../util.zig").rangeArrayList;

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

/// Find and retrieve first item that predicate `pred` evaluates to true in slice of type `T`.
/// Additionally supply some arguments to `pred`.
pub fn findSlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) ?T {
    for (slice[0..]) |item| {
        if (@call(.auto, pred, .{item} ++ args)) {
            return item;
        }
    }

    return null;
}

/// Find and retrieve first item that predicate `pred` evaluates to true in array list of type `T`.
/// Additionally supply some arguments to `pred`.
pub fn findArrayList(comptime T: type, arr: ArrayList(T), comptime pred: anytype, args: anytype) ?T {
    for (arr.items) |item| {
        if (@call(.auto, pred, .{item} ++ args)) {
            return item;
        }
    }

    return null;
}

const CommonPredicates = common.CommonPredicates;

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

    const found = findSlice(
        Point2D,
        &slice,
        CommonPredicates.fieldEq(Point2D, i32),
        .{ "x", 2 },
    );

    try testing.expect(found != null);
    try testing.expectEqual(found.?, slice[2]);

    const not_found = findSlice(
        Point2D,
        &slice,
        CommonPredicates.fieldEq(Point2D, i32),
        .{ "y", 5 },
    );

    try testing.expect(not_found == null);
}

test "test find array list" {
    const allocator = testing.allocator;

    const arr = try rangeArrayList(allocator, i32, 4);
    defer arr.deinit();

    const found = findArrayList(
        i32,
        arr,
        CommonPredicates.eq(i32),
        .{2},
    );

    try testing.expect(found != null);
    try testing.expectEqual(found.?, arr.items[2]);

    const not_found = findArrayList(
        i32,
        arr,
        CommonPredicates.eq(i32),
        .{5},
    );

    try testing.expect(not_found == null);
}
