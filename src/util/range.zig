const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

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

test "test range slice" {
    const slice = rangeSlice(i32, 4);
    try testing.expectEqualSlices(i32, slice, &[_]i32{ 0, 1, 2, 3 });
}

test "test iterate range slice" {
    for (rangeSlice(usize, 5), 0..) |item, idx| {
        try testing.expectEqual(idx, item);
    }
}
