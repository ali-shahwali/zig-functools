const std = @import("std");
const testing = std.testing;
const common = @import("../common.zig");
const rangeArrayList = @import("../util.zig").rangeArrayList;

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

/// Returns true if `slice` contains an item of type `T` that passes the predicate specified by `pred`.
/// Additionally supply some arguments to `pred`.
pub fn someSlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) bool {
    for (slice[0..]) |item| {
        if (@call(.auto, pred, .{item} ++ args)) {
            return true;
        }
    }

    return false;
}

/// Returns true if array list contains an item of type `T` that passes the predicate specified by `pred`.
/// Additionally supply some arguments to `pred`.
pub fn someArrayList(comptime T: type, arr: ArrayList(T), comptime pred: anytype, args: anytype) bool {
    for (arr.items) |item| {
        if (@call(.auto, pred, .{item} ++ args)) {
            return true;
        }
    }

    return false;
}

const CommonPredicates = common.CommonPredicates;

const Point2D = struct {
    x: i32,
    y: i32,
};

test "test some on i32 slice" {
    const slice = [_]i32{ 1, 3, 5 };
    const some_even = someSlice(
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
    const some_orthogonal = someSlice(Point2D, &slice, orthogonal, .{e_x});

    try testing.expect(some_orthogonal);
}

test "test some array list" {
    const allocator = testing.allocator;

    const arr = try rangeArrayList(allocator, i32, 4);
    defer arr.deinit();

    const found = someArrayList(
        i32,
        arr,
        CommonPredicates.even(i32),
        .{},
    );

    try testing.expect(found);
}

test "test every on Point2D array list" {
    const allocator = testing.allocator;
    var arr = ArrayList(Point2D).init(allocator);
    defer arr.deinit();

    try arr.append(.{ .x = 5, .y = 2 });
    try arr.append(.{ .x = 1, .y = 3 });
    try arr.append(.{ .x = 0, .y = 4 });

    const e_x = Point2D{ .x = 1, .y = 0 };
    const some_orthogonal = someArrayList(Point2D, arr, orthogonal, .{e_x});

    try testing.expect(some_orthogonal);
}
