const std = @import("std");
const common = @import("../common.zig");
const typed = @import("typed");
const rangeArrayList = @import("../util/util.zig").rangeArrayList;
const adHocPolyT = @import("../polymorphism.zig").adHocPolyT;

const testing = std.testing;
const ArrayList = std.ArrayList;

fn someImpl(comptime T: type) fn (fn (T) bool, []T) bool {
    return (struct {
        fn e(pred: fn (T) bool, slice: []T) bool {
            for (slice[0..]) |item| {
                if (@call(.auto, pred, .{item})) {
                    return true;
                }
            }

            return false;
        }
    }).e;
}

fn someIdxImpl(comptime T: type) fn (fn (T, usize) bool, []T) bool {
    return (struct {
        fn e(pred: fn (T, usize) bool, slice: []T) bool {
            for (slice[0..], 0..) |item, idx| {
                if (@call(.auto, pred, .{ item, idx })) {
                    return true;
                }
            }

            return false;
        }
    }).e;
}

/// Returns true if `slice` contains an item that passes the predicate specified by `pred`.
/// Additionally supply some arguments to `pred`.
pub fn some(comptime predicate: anytype, slice: []typed.ParamType(predicate, 0)) bool {
    return adHocPolyT(
        bool,
        .{ predicate, slice },
        .{
            someImpl(typed.ParamType(predicate, 0)),
            someIdxImpl(typed.ParamType(predicate, 0)),
        },
    );
}

const predicates = common.predicates;

const Point2D = struct {
    x: i32,
    y: i32,
};

test "test some on i32 slice" {
    const allocator = testing.allocator;
    const slice = try allocator.alloc(i32, 3);
    @memcpy(slice, &[_]i32{ 1, 3, 5 });
    defer allocator.free(slice);
    const some_even = some(predicates.even(i32), slice);

    try testing.expect(!some_even);
}

test "test some on Point2D slice" {
    const allocator = testing.allocator;
    const slice = try allocator.alloc(Point2D, 3);
    @memcpy(slice, &[_]Point2D{
        .{ .x = 5, .y = 2 },
        .{ .x = 1, .y = 3 },
        .{ .x = 0, .y = 4 }, // This one is orthogonal to (1, 0)
    });
    defer allocator.free(slice);

    const e_x = Point2D{ .x = 1, .y = 0 };
    const some_orthogonal = some(orthogonal(e_x), slice);

    try testing.expect(some_orthogonal);
}

fn orthogonal(p2: Point2D) fn (Point2D) bool {
    return (struct {
        fn e(p1: Point2D) bool {
            return (p1.x * p2.x + p1.y * p2.y) == 0;
        }
    }).e;
}

test "test some array list" {
    const allocator = testing.allocator;

    const arr = try rangeArrayList(allocator, i32, 4);
    defer arr.deinit();

    const found = some(predicates.even(i32), arr.items);

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
    const some_orthogonal = some(orthogonal(e_x), arr.items);

    try testing.expect(some_orthogonal);
}
