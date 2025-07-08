const std = @import("std");
const common = @import("../common.zig");
const range = @import("../util/range.zig");
const typed = @import("typed");
const adHocPolyT = @import("../polymorphism.zig").adHocPolyT;

const testing = std.testing;

fn reduceImpl(comptime T: type, comptime G: type) fn (fn (G, T) G, []T, G) G {
    return (struct {
        fn e(reducer: fn (G, T) G, slice: []T, initial_value: G) G {
            var accumulator: G = initial_value;

            for (slice[0..]) |item| {
                accumulator = @call(.auto, reducer, .{ accumulator, item });
            }

            return accumulator;
        }
    }).e;
}

fn reduceIdxImpl(comptime T: type, comptime G: type) fn (fn (G, T, usize) G, []T, G) G {
    return (struct {
        fn e(reducer: fn (G, T, usize) G, slice: []T, initial_value: G) G {
            var accumulator: G = initial_value;

            for (slice[0..], 0..) |item, idx| {
                accumulator = @call(.auto, reducer, .{ accumulator, item, idx });
            }

            return accumulator;
        }
    }).e;
}

/// Reduce slice using function `reducer`.
/// Supply an initial value to reduce from.
pub fn reduce(comptime reducer: anytype, slice: []typed.ParamType(reducer, 1), initial_value: typed.ReturnType(reducer)) typed.ReturnType(reducer) {
    return adHocPolyT(
        typed.ReturnType(reducer),
        .{ reducer, slice, initial_value },
        .{
            reduceImpl(typed.ParamType(reducer, 1), typed.ReturnType(reducer)),
            reduceIdxImpl(typed.ParamType(reducer, 1), typed.ReturnType(reducer)),
        },
    );
}

const reducers = common.reducers;

const Point2D = struct {
    x: i32,
    y: i32,
};

fn sumPointY(prev: i32, curr: Point2D) i32 {
    return prev + curr.y;
}

test "test reduce slice on i32 slice" {
    const allocator = testing.allocator;
    const slice = try allocator.alloc(i32, 3);
    @memcpy(slice, &[_]i32{ 1, 2, 3 });
    defer allocator.free(slice);
    const result = reduce(
        reducers.sum(i32),
        slice,
        0,
    );

    try testing.expectEqual(result, 6);
}

test "test reduce struct field" {
    const allocator = testing.allocator;
    const slice = try allocator.alloc(Point2D, 3);
    @memcpy(slice, &[_]Point2D{ .{ .x = 1, .y = 2 }, .{ .x = 2, .y = 3 }, .{ .x = 3, .y = 4 } });
    defer allocator.free(slice);
    const result = reduce(
        sumPointY,
        slice,
        0,
    );

    try testing.expectEqual(result, 9);
}

test "test reduce i32 array list" {
    const allocator = testing.allocator;
    const arr = try range.rangeArrayList(allocator, i32, 4);
    defer arr.deinit();

    const result = reduce(
        reducers.sum(i32),
        arr.items,
        0,
    );

    try testing.expectEqual(result, 6);
}
