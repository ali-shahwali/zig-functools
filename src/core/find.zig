const std = @import("std");
const testing = std.testing;
const common = @import("../common.zig");
const rangeArrayList = @import("../util.zig").rangeArrayList;
const type_util = @import("type_util.zig");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

/// Find and retrieve first item that predicate `pred` evaluates to true.
/// Additionally supply some arguments to `pred`.
pub fn findSlice(comptime pred: anytype, slice: []const type_util.funcParamType(pred, 0), args: anytype) ?type_util.funcParamType(pred, 0) {
    for (slice[0..]) |item| {
        if (@call(.auto, pred, .{item} ++ args)) {
            return item;
        }
    }

    return null;
}

/// Find and retrieve first item that predicate `pred` evaluates to true in array list.
/// Additionally supply some arguments to `pred`.
pub fn findArrayList(comptime pred: anytype, arr: ArrayList(type_util.funcParamType(pred, 0)), args: anytype) ?type_util.funcParamType(pred, 0) {
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
        CommonPredicates.fieldEq(Point2D, .x),
        &slice,
        .{2},
    );

    try testing.expect(found != null);
    try testing.expectEqual(found.?, slice[2]);

    const not_found = findSlice(
        CommonPredicates.fieldEq(Point2D, .y),
        &slice,
        .{5},
    );

    try testing.expect(not_found == null);
}

test "test find array list" {
    const allocator = testing.allocator;

    const arr = try rangeArrayList(allocator, i32, 4);
    defer arr.deinit();

    const found = findArrayList(
        CommonPredicates.eq(i32),
        arr,
        .{2},
    );

    try testing.expect(found != null);
    try testing.expectEqual(found.?, arr.items[2]);

    const not_found = findArrayList(
        CommonPredicates.eq(i32),
        arr,
        .{5},
    );

    try testing.expect(not_found == null);
}
