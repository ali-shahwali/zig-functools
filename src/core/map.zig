const std = @import("std");
const common = @import("../common.zig");
const range = @import("../util/range.zig");
const typed = @import("typed");
const adHocPolyT = @import("../polymorphism.zig").adHocPolyT;

const testing = std.testing;
const Allocator = std.mem.Allocator;

fn mapImpl(comptime T: type) fn (fn (T) T, []T) void {
    return (struct {
        fn e(mapper: fn (T) T, slice: []T) void {
            for (0..slice.len) |idx| {
                slice[idx] = @call(.auto, mapper, .{slice[idx]});
            }
        }
    }).e;
}

fn mapIdxImpl(comptime T: type) fn (fn (T, usize) T, []T) void {
    return (struct {
        fn e(mapper: fn (T, usize) T, slice: []T) void {
            for (0..slice.len) |idx| {
                slice[idx] = @call(.auto, mapper, .{ slice[idx], idx });
            }
        }
    }).e;
}

/// Map over mutable slice using function `func` on each element of `slice`.
/// Does not allocate new memory and instead assigns mapped values in place.
pub fn map(comptime mapper: anytype, slice: []typed.ParamType(mapper, 0)) void {
    adHocPolyT(void, .{
        mapper,
        slice,
    }, .{
        mapImpl(typed.ParamType(mapper, 0)),
        mapIdxImpl(typed.ParamType(mapper, 0)),
    });
}

fn mapAllocImpl(comptime T: type, comptime G: type) fn (Allocator, fn (T) G, []T) Allocator.Error![]G {
    return (struct {
        fn e(allocator: Allocator, mapper: fn (T) G, slice: []T) Allocator.Error![]G {
            var mapped_slice = try allocator.alloc(G, slice.len);
            for (0..slice.len) |idx| {
                mapped_slice[idx] = @call(.auto, mapper, .{slice[idx]});
            }

            return mapped_slice;
        }
    }).e;
}

fn mapIdxAllocImpl(comptime T: type, comptime G: type) fn (Allocator, fn (T, usize) G, []T) Allocator.Error![]G {
    return (struct {
        fn e(allocator: Allocator, mapper: fn (T, usize) G, slice: []T) Allocator.Error![]G {
            var mapped_slice = try allocator.alloc(G, slice.len);
            for (0..slice.len) |idx| {
                mapped_slice[idx] = @call(.auto, mapper, .{ slice[idx], idx });
            }

            return mapped_slice;
        }
    }).e;
}

/// Map over slice to new allocated slice using function `func` on each element of `slice`.
/// Consumer of function must make sure to free returned slice.
pub fn mapAlloc(allocator: Allocator, comptime mapper: anytype, slice: []typed.ParamType(mapper, 0)) ![]typed.ReturnType(mapper) {
    return adHocPolyT(
        Allocator.Error![]typed.ReturnType(mapper),
        .{ allocator, mapper, slice },
        .{
            mapAllocImpl(typed.ParamType(mapper, 0), typed.ReturnType(mapper)),
            mapIdxAllocImpl(typed.ParamType(mapper, 0), typed.ReturnType(mapper)),
        },
    );
}

const mappers = common.mappers;

const Point2D = struct {
    x: i32,
    y: i32,
};

test "test map on slice of type i32 to slice of type i64" {
    const allocator = testing.allocator;

    const slice = try range.rangeSlice(allocator, i32, 3);
    defer allocator.free(slice);
    const incremented = try mapAlloc(allocator, (struct {
        fn inci64(n: i32) i64 {
            return @as(i64, n + 1);
        }
    }).inci64, slice);
    defer allocator.free(incremented);

    try testing.expectEqualSlices(i64, incremented, &[_]i64{ 1, 2, 3 });
}

test "test map mutable slice on i32 slice without args" {
    const allocator = testing.allocator;

    const slice = try range.rangeSlice(allocator, i32, 3);
    defer allocator.free(slice);

    map(mappers.inc(i32), slice);

    try testing.expectEqualSlices(i32, slice, &[_]i32{ 1, 2, 3 });
}

test "test map slice on i32 slice with args" {
    const allocator = testing.allocator;
    const slice = try range.rangeSlice(allocator, i32, 3);
    defer allocator.free(slice);
    const added: []i32 = try mapAlloc(
        allocator,
        mappers.add(i32, 1),
        slice,
    );
    defer allocator.free(added);

    try testing.expectEqualSlices(i32, added, &[_]i32{ 1, 2, 3 });
}

test "test map slice on f32 slice with trunc" {
    const allocator = testing.allocator;
    const slice = try allocator.alloc(f32, 4);
    @memcpy(slice, &[_]f32{ 1.9, 2.01, 3.999, 4.5 });
    defer allocator.free(slice);
    const trunced: []f32 = try mapAlloc(
        allocator,
        mappers.trunc(f32),
        slice,
    );
    defer allocator.free(trunced);

    try testing.expectEqualSlices(f32, trunced, &[_]f32{ 1, 2, 3, 4 });
}

test "test map slice on Point2D slice with takeField mapper" {
    const allocator = testing.allocator;
    const slice = try allocator.alloc(Point2D, 3);
    @memcpy(slice, &[_]Point2D{ .{ .x = 1, .y = 2 }, .{ .x = 2, .y = 3 }, .{ .x = 3, .y = 4 } });
    defer allocator.free(slice);
    const x_coords: []i32 = try mapAlloc(
        allocator,
        mappers.takeField(Point2D, .x),
        slice,
    );
    defer allocator.free(x_coords);

    try testing.expectEqualSlices(i32, x_coords, &[_]i32{ 1, 2, 3 });
}

test "test map i32 slice to Point2D slice" {
    const allocator = testing.allocator;
    const slice = try range.rangeSlice(allocator, i32, 3);
    defer allocator.free(slice);

    const points: []Point2D = try mapAlloc(
        allocator,
        (struct {
            fn toPoint2D(n: i32) Point2D {
                return Point2D{
                    .x = n,
                    .y = 0,
                };
            }
        }).toPoint2D,
        slice,
    );
    defer allocator.free(points);

    try testing.expectEqualSlices(Point2D, points, &[_]Point2D{
        .{ .x = 0, .y = 0 },
        .{ .x = 1, .y = 0 },
        .{ .x = 2, .y = 0 },
    });
}

test "test map i32 array list" {
    const allocator = testing.allocator;

    var arr = try range.rangeArrayList(allocator, i32, 4);
    defer arr.deinit();

    map(mappers.inc(i32), arr.items);
    try testing.expectEqualSlices(i32, arr.items, &[_]i32{ 1, 2, 3, 4 });
}

test "test map slice on f32 slice with sin" {
    const allocator = testing.allocator;
    const slice = try allocator.alloc(f32, 3);
    @memcpy(slice, &[_]f32{ std.math.pi, 2 * std.math.pi, 1.5 * std.math.pi });
    defer allocator.free(slice);

    const sined = try mapAlloc(
        allocator,
        mappers.sin(f32),
        slice,
    );
    defer allocator.free(sined);

    // For precision errors
    map(mappers.trunc(f32), sined);

    try testing.expectEqualSlices(f32, sined, &[_]f32{ 0, 0, -1 });
}
