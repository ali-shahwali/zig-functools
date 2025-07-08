const std = @import("std");
const common = @import("../common.zig");
const typed = @import("typed");
const rangeArrayList = @import("../util/util.zig").rangeArrayList;
const rangeSlice = @import("../util/util.zig").rangeSlice;
const adHocPolyT = @import("../polymorphism.zig").adHocPolyT;

const testing = std.testing;
const Allocator = std.mem.Allocator;

fn filterImpl(comptime T: type) fn (Allocator, fn (T) bool, []T) Allocator.Error![]T {
    return (struct {
        fn e(allocator: Allocator, pred: fn (T) bool, slice: []T) Allocator.Error![]T {
            var filtered_list = try std.ArrayList(T).initCapacity(allocator, slice.len);

            for (slice[0..]) |item| {
                if (@call(.auto, pred, .{item})) {
                    filtered_list.appendAssumeCapacity(item);
                }
            }

            return try filtered_list.toOwnedSlice();
        }
    }).e;
}

fn filterIdxImpl(comptime T: type) fn (Allocator, fn (T, usize) bool, []T) Allocator.Error![]T {
    return (struct {
        fn e(allocator: Allocator, pred: fn (T, usize) bool, slice: []T) Allocator.Error![]T {
            var filtered_list = try std.ArrayList(T).initCapacity(allocator, slice.len);

            for (slice[0..], 0..) |item, idx| {
                if (@call(.auto, pred, .{ item, idx })) {
                    filtered_list.appendAssumeCapacity(item);
                }
            }

            return try filtered_list.toOwnedSlice();
        }
    }).e;
}

/// Create new slice filtered from `slice` using function `pred` as predicate.
/// Consumer must make sure to free returned slice.
pub fn filter(allocator: Allocator, comptime predicate: anytype, slice: []typed.ParamType(predicate, 0)) ![]typed.ParamType(predicate, 0) {
    return adHocPolyT(
        Allocator.Error![]typed.ParamType(predicate, 0),
        .{ allocator, predicate, slice },
        .{
            filterImpl(typed.ParamType(predicate, 0)),
            filterIdxImpl(typed.ParamType(predicate, 0)),
        },
    );
}

const predicates = common.predicates;

const Point2D = struct {
    x: i32,
    y: i32,
};

test "test filter on i32 slice" {
    const allocator = testing.allocator;
    const slice = try rangeSlice(allocator, i32, 6);
    defer allocator.free(slice);
    const even = try filter(
        allocator,
        predicates.even(i32),
        slice,
    );
    defer allocator.free(even);

    try testing.expectEqualSlices(i32, even, &[_]i32{ 0, 2, 4 });
}

test "test filter on Point2D slice" {
    const allocator = testing.allocator;
    const slice = try allocator.alloc(Point2D, 3);
    @memcpy(slice, &[_]Point2D{ .{ .x = 2, .y = 2 }, .{ .x = 0, .y = 3 }, .{ .x = 2, .y = 4 } });
    defer allocator.free(slice);
    const x_coord_eq_2 = try filter(
        allocator,
        predicates.fieldEq(Point2D, .x, 2),
        slice,
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

    const even = try filter(
        allocator,
        predicates.even(i32),
        arr.items,
    );
    defer allocator.free(even);

    try testing.expectEqualSlices(i32, even, &[_]i32{ 0, 2, 4 });
}
