const std = @import("std");
const FunctoolTypeError = @import("errors.zig").FunctoolTypeError;
const testing = std.testing;
const common = @import("../common.zig");

const CommonMappers = common.CommonMappers;

const Allocator = std.mem.Allocator;

/// Map over slice of type `T` to new allocated slice using function `func` on each element of `slice`.
/// Additionally supply some arguments to `func`.
/// Consumer of function must make sure to free returned slice.
pub fn mapSlice(allocator: Allocator, comptime T: type, slice: []const T, comptime func: anytype, args: anytype) ![]@typeInfo(@TypeOf(func)).Fn.return_type.? {
    if (@typeInfo(@TypeOf(func)).Fn.params[0].type.? != T) {
        return FunctoolTypeError.InvalidParamType;
    }

    const ReturnType = @typeInfo(@TypeOf(func)).Fn.return_type orelse {
        return FunctoolTypeError.InvalidReturnType;
    };

    var mapped_slice = try allocator.alloc(ReturnType, slice.len);
    for (0..slice.len) |idx| {
        mapped_slice[idx] = @call(.auto, func, .{slice[idx]} ++ args);
    }

    return mapped_slice;
}

/// Map over mutable slice of type `T` using function `func` on each element of `slice`.
/// Additionally supply some arguments to `func`,
pub fn mapMutSlice(comptime T: type, slice: []T, comptime func: anytype, args: anytype) !void {
    comptime {
        if (@typeInfo(@TypeOf(func)).Fn.params[0].type.? != T) {
            return FunctoolTypeError.InvalidParamType;
        }
    }

    for (0..slice.len) |idx| {
        slice[idx] = @call(.auto, func, .{slice[idx]} ++ args);
    }
}

const Point2D = struct {
    x: i32,
    y: i32,
};

test "test map on slice of type i32 to slice of type i64" {
    const allocator = testing.allocator;

    const slice = [3]i32{ 1, 2, 3 };
    const incremented = try mapSlice(allocator, i32, &slice, (struct {
        fn inci64(n: i32) i64 {
            return @as(i64, n + 1);
        }
    }).inci64, .{});
    defer allocator.free(incremented);

    try testing.expectEqualSlices(i64, incremented, &[_]i64{ 2, 3, 4 });
}

test "test map mutable slice on i32 slice without args" {
    var slice = [_]i32{ 1, 2, 3 };
    try mapMutSlice(
        i32,
        &slice,
        CommonMappers.inc(i32),
        .{},
    );

    try testing.expectEqualSlices(i32, &slice, &[_]i32{ 2, 3, 4 });
}

test "test map slice on i32 slice with args" {
    const allocator = testing.allocator;
    const slice = [_]i32{ 1, 2, 3 };
    const added: []i32 = try mapSlice(
        allocator,
        i32,
        &slice,
        CommonMappers.add(i32),
        .{@as(i32, 1)},
    );
    defer allocator.free(added);

    try testing.expectEqualSlices(i32, added, &[_]i32{ 2, 3, 4 });
}

test "test map slice on f32 slice with trunc" {
    const allocator = testing.allocator;
    const slice = [_]f32{ 1.9, 2.01, 3.999, 4.5 };
    const trunced: []f32 = try mapSlice(
        allocator,
        f32,
        &slice,
        CommonMappers.trunc(f32),
        .{},
    );
    defer allocator.free(trunced);

    try testing.expectEqualSlices(f32, trunced, &[_]f32{ 1, 2, 3, 4 });
}

test "test map slice on Point2D slice with takeField mapper" {
    const allocator = testing.allocator;
    const slice = [_]Point2D{ .{
        .x = 1,
        .y = 2,
    }, .{
        .x = 2,
        .y = 3,
    }, .{
        .x = 3,
        .y = 4,
    } };
    const x_coords: []i32 = try mapSlice(
        allocator,
        Point2D,
        &slice,
        CommonMappers.takeField(Point2D, i32),
        .{"x"},
    );
    defer allocator.free(x_coords);

    try testing.expectEqualSlices(i32, x_coords, &[_]i32{ 1, 2, 3 });
}

test "test map i32 slice to Point2D slice" {
    const allocator = testing.allocator;
    const slice = [_]i32{ 1, 2, 3 };
    const points: []Point2D = try mapSlice(
        allocator,
        i32,
        &slice,
        (struct {
            fn toPoint2D(n: i32) Point2D {
                return Point2D{
                    .x = n,
                    .y = 0,
                };
            }
        }).toPoint2D,
        .{},
    );
    defer allocator.free(points);

    try testing.expectEqualSlices(Point2D, points, &[_]Point2D{
        .{ .x = 1, .y = 0 },
        .{ .x = 2, .y = 0 },
        .{ .x = 3, .y = 0 },
    });
}
