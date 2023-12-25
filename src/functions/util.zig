const std = @import("std");
const FunctoolTypeError = @import("errors.zig").FunctoolTypeError;
const testing = std.testing;
const common = @import("../common.zig");

const CommonMappers = common.CommonMappers;
const CommonReducers = common.CommonReducers;
const CommonPredicates = common.CommonPredicates;

const Allocator = std.mem.Allocator;

/// Take every nth element in `slice` of type `T`.
/// Consumer of function must make sure to free returned slice.
/// A special case is n <= 0, in which case the same slice will be returned.
pub fn takeNth(allocator: Allocator, comptime T: type, slice: []const T, n: usize) ![]T {
    if (n <= 0) {
        var copy = try allocator.alloc(T, slice.len);
        @memcpy(copy, slice);
        return copy;
    }

    var nth = try allocator.alloc(T, @divFloor(slice.len, n));
    var j: usize = 0;
    var i: usize = 0;
    while (i < slice.len) : (i += n) {
        nth[j] = slice[i];
        j += 1;
    }

    return nth;
}

/// Returns a slice of length `n` and type `T` where the elements start from 0 and go to n - 1.
/// ```zig
/// // Example
/// const slice = functools.rangeSlice(i32, 4);
/// try testing.expectEqualSlices(i32, slice, &[_]i32{ 0, 1, 2, 3 });
/// ```
pub fn rangeSlice(comptime T: type, comptime n: usize) []T {
    var slice: [n]T = undefined;
    var idx: T = 0;
    for (0..n) |i| {
        slice[i] = idx;
        idx += 1;
    }

    return &slice;
}

/// Returns an allocated slice of length `n` and type `T` where the elements start from 0 and go to n - 1.
/// ```zig
/// // Example
/// const allocator = testing.allocator;
/// const slice = try functools.rangeSlice(allocator, i32, 4);
/// defer allocator.free(slice);
/// try testing.expectEqualSlices(i32, slice, &[_]i32{ 0, 1, 2, 3 });
/// ```
pub fn rangeAllocSlice(allocator: Allocator, comptime T: type, comptime n: usize) ![]T {
    var slice = try allocator.alloc(T, n);
    var idx: T = 0;
    for (0..n) |i| {
        slice[i] = idx;
        idx += 1;
    }

    return slice;
}

const Point2D = struct {
    x: i32,
    y: i32,
};

fn orthogonal(p1: Point2D, p2: Point2D) bool {
    return (p1.x * p2.x + p1.y * p2.y) == 0;
}

test "test takeNth" {
    const allocator = testing.allocator;

    const slice = [_]i32{ 0, 1, 2, 3, 4, 5 };
    const nth = try takeNth(allocator, i32, &slice, 2);
    defer allocator.free(nth);

    try testing.expectEqualSlices(i32, nth, &[_]i32{ 0, 2, 4 });
}

test "test range slice" {
    const slice = rangeSlice(i32, 4);
    try testing.expectEqualSlices(i32, slice, &[_]i32{ 0, 1, 2, 3 });
}
