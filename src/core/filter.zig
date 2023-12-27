const std = @import("std");
const FunctoolTypeError = @import("errors.zig").FunctoolTypeError;
const testing = std.testing;
const common = @import("../common.zig");
const rangeArrayList = @import("../util.zig").rangeArrayList;

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

/// Create new slice filtered from `slice` of type `T` using function `pred` as predicate.
/// Additionally supply some arguments to `pred`.
/// Consumer must make sure to free returned slice.
pub fn filterSlice(allocator: Allocator, comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) ![]T {
    comptime {
        if (@typeInfo(@TypeOf(pred)).Fn.params[0].type.? != T) {
            return FunctoolTypeError.InvalidParamType;
        }
        if (@typeInfo(@TypeOf(pred)).Fn.return_type.? != bool) {
            return FunctoolTypeError.InvalidReturnType;
        }
    }

    var filtered = try allocator.alloc(T, slice.len);
    var filtered_len: usize = 0;
    for (slice[0..]) |item| {
        if (@call(.auto, pred, .{item} ++ args)) {
            filtered[filtered_len] = item;
            filtered_len += 1;
        }
    }

    _ = allocator.resize(filtered, filtered_len);
    return filtered[0..filtered_len];
}

/// Create new array list filtered from `arr` of type `T` using function `pred` as predicate.
/// Additionally supply some arguments to `pred`.
/// Consumer must make sure to free returned array list.
pub fn filterArrayList(allocator: Allocator, comptime T: type, arr: ArrayList(T), comptime pred: anytype, args: anytype) !ArrayList(T) {
    comptime {
        if (@typeInfo(@TypeOf(pred)).Fn.params[0].type.? != T) {
            return FunctoolTypeError.InvalidParamType;
        }
        if (@typeInfo(@TypeOf(pred)).Fn.return_type.? != bool) {
            return FunctoolTypeError.InvalidReturnType;
        }
    }

    var filtered = try ArrayList(T).initCapacity(allocator, arr.capacity);
    for (arr.items) |item| {
        if (@call(.auto, pred, .{item} ++ args)) {
            try filtered.append(item);
        }
    }

    try filtered.resize(filtered.items.len);
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
        i32,
        &slice,
        CommonPredicates.even(i32),
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
        Point2D,
        &slice,
        CommonPredicates.fieldEq(Point2D, i32),
        .{ "x", 2 },
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
        i32,
        arr,
        CommonPredicates.even(i32),
        .{},
    );
    defer even.deinit();

    try testing.expectEqualSlices(i32, even.items, &[_]i32{ 0, 2, 4 });
}
