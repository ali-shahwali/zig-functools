const std = @import("std");
const common = @import("../common.zig");
const typed = @import("typed");
const rangeArrayList = @import("../util/util.zig").rangeArrayList;
const adHocPolyT = @import("../polymorphism.zig").adHocPolyT;

const testing = std.testing;

fn findImpl(comptime T: type) fn (fn (T) bool, []T) ?T {
    return (struct {
        fn e(pred: fn (T) bool, slice: []T) ?T {
            for (slice[0..]) |item| {
                if (@call(.auto, pred, .{item})) {
                    return item;
                }
            }

            return null;
        }
    }).e;
}

fn findIdxImpl(comptime T: type) fn (fn (T, usize) bool, []T) ?T {
    return (struct {
        fn e(pred: fn (T, usize) bool, slice: []T) ?T {
            for (slice[0..], 0..) |item, idx| {
                if (@call(.auto, pred, .{ item, idx })) {
                    return item;
                }
            }

            return null;
        }
    }).e;
}

/// Find and retrieve first item that predicate `pred` evaluates to true.
/// Additionally supply some arguments to `pred`.
pub fn find(comptime predicate: anytype, slice: []typed.ParamType(predicate, 0)) ?typed.ParamType(predicate, 0) {
    return adHocPolyT(
        ?typed.ParamType(predicate, 0),
        .{ predicate, slice },
        .{
            findImpl(typed.ParamType(predicate, 0)),
            findIdxImpl(typed.ParamType(predicate, 0)),
        },
    );
}

const predicates = common.predicates;

const Point2D = struct {
    x: i32,
    y: i32,
};

test "test find slice" {
    const allocator = testing.allocator;
    const slice = try allocator.alloc(Point2D, 3);
    @memcpy(slice, &[_]Point2D{
        .{ .x = 8, .y = 1 },
        .{ .x = 4, .y = 3 },
        .{ .x = 2, .y = 4 },
    });
    defer allocator.free(slice);

    const found = find(predicates.fieldEq(Point2D, .x, 2), slice);

    try testing.expect(found != null);
    try testing.expectEqual(found.?, slice[2]);

    const not_found = find(predicates.fieldEq(Point2D, .y, 5), slice);

    try testing.expect(not_found == null);
}

test "test find array list" {
    const allocator = testing.allocator;

    const arr = try rangeArrayList(allocator, i32, 4);
    defer arr.deinit();

    const found = find(predicates.eq(i32, 2), arr.items);

    try testing.expect(found != null);
    try testing.expectEqual(found.?, arr.items[2]);

    const not_found = find(predicates.eq(i32, 5), arr.items);

    try testing.expect(not_found == null);
}
