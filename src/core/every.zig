const std = @import("std");
const typed = @import("typed");
const adHocPolyT = @import("../polymorphism.zig").adHocPolyT;

const testing = std.testing;
const ArrayList = std.ArrayList;

fn everyImpl(comptime T: type) fn (fn (T) bool, []T) bool {
    return (struct {
        fn e(pred: fn (T) bool, slice: []T) bool {
            for (slice[0..]) |item| {
                if (!@call(.auto, pred, .{item})) {
                    return false;
                }
            }

            return true;
        }
    }).e;
}

fn everyIdxImpl(comptime T: type) fn (fn (T, usize) bool, []T) bool {
    return (struct {
        fn e(pred: fn (T, usize) bool, slice: []T) bool {
            for (slice[0..], 0..) |item, idx| {
                if (!@call(.auto, pred, .{ item, idx })) {
                    return false;
                }
            }

            return true;
        }
    }).e;
}

/// Returns true if predicate defined by `pred` is true for every element in `slice`.
/// Additionally supply some arguments to `pred`.
pub fn every(comptime predicate: anytype, slice: []typed.ParamType(predicate, 0)) bool {
    return adHocPolyT(
        bool,
        .{ predicate, slice },
        .{
            everyImpl(typed.ParamType(predicate, 0)),
            everyIdxImpl(typed.ParamType(predicate, 0)),
        },
    );
}

const Point2D = struct {
    x: i32,
    y: i32,
};

fn orthogonal(p2: Point2D) fn (Point2D) bool {
    return (struct {
        fn e(p1: Point2D) bool {
            return (p1.x * p2.x + p1.y * p2.y) == 0;
        }
    }).e;
}

test "test every on Point2D slice" {
    const allocator = testing.allocator;
    const slice = try allocator.alloc(Point2D, 3);
    @memcpy(slice, &[_]Point2D{
        .{ .x = 0, .y = 1 },
        .{ .x = 0, .y = 3 },
        // This one is not orthogonal to (1, 0)
        .{ .x = 1, .y = 4 },
    });
    defer allocator.free(slice);

    const e_x = Point2D{ .x = 1, .y = 0 };
    const every_orthogonal = every(orthogonal(e_x), slice);

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
    const every_orthogonal = every(orthogonal(e_x), arr.items);

    try testing.expect(!every_orthogonal);
}
