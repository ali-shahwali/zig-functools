const std = @import("std");
const testing = std.testing;
const common = @import("../common.zig");
const rangeArrayList = @import("../util.zig").rangeArrayList;
const type_util = @import("type_util.zig");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

/// Create new slice filtered from `slice` using function `pred` as predicate.
/// Additionally supply some arguments to `pred`.
/// Consumer must make sure to free returned slice.
pub fn filterSlice(allocator: Allocator, comptime pred: anytype, slice: []const type_util.funcParamType(pred, 0), args: anytype) ![]type_util.funcParamType(pred, 0) {
    const T = type_util.funcParamType(pred, 0);
    var filtered_list = try std.ArrayList(T).initCapacity(allocator, slice.len);

    for (slice[0..]) |item| {
        if (@call(.auto, pred, .{item} ++ args)) {
            filtered_list.appendAssumeCapacity(item);
        }
    }

    return try filtered_list.toOwnedSlice();
}

/// Create new array list filtered from `arr` using function `pred` as predicate.
/// Additionally supply some arguments to `pred`.
/// Consumer must make sure to free returned array list.
pub fn filterArrayList(allocator: Allocator, comptime pred: anytype, arr: ArrayList(type_util.funcParamType(pred, 0)), args: anytype) !ArrayList(type_util.funcParamType(pred, 0)) {
    const T = type_util.funcParamType(pred, 0);
    var filtered = try ArrayList(T).initCapacity(allocator, arr.capacity);

    for (arr.items) |item| {
        if (@call(.auto, pred, .{item} ++ args)) {
            filtered.appendAssumeCapacity(item);
        }
    }

    return filtered;
}

const CommonPredicates = common.CommonPredicates;

const Point2D = struct {
    x: i32,
    y: i32,
};

test "test filter on i32 slice" {
    const slice = [_]i32{ 1, 2, 3, 4, 5 };
    const allocator = testing.allocator;
    const even = try filterSlice(
        allocator,
        CommonPredicates.even(i32),
        &slice,
        .{},
    );
    defer allocator.free(even);

    try testing.expectEqualSlices(i32, even, &[_]i32{ 2, 4 });
}

test "test filter on Point2D slice" {
    const slice = [_]Point2D{ .{ .x = 2, .y = 2 }, .{ .x = 0, .y = 3 }, .{ .x = 2, .y = 4 } };
    const allocator = testing.allocator;
    const x_coord_eq_2 = try filterSlice(
        allocator,
        CommonPredicates.fieldEq(Point2D, .x),
        &slice,
        .{2},
    );
    defer allocator.free(x_coord_eq_2);

    try testing.expectEqualSlices(Point2D, x_coord_eq_2, &[_]Point2D{
        .{ .x = 2, .y = 2 },
        .{ .x = 2, .y = 4 },
    });
}

test "test filter on i32 array list" {
    const allocator = testing.allocator;
    const arr = try rangeArrayList(allocator, i32, 6);
    defer arr.deinit();

    const even = try filterArrayList(
        allocator,
        CommonPredicates.even(i32),
        arr,
        .{},
    );
    defer even.deinit();

    try testing.expectEqualSlices(i32, even.items, &[_]i32{ 0, 2, 4 });
}
