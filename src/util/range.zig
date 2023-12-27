const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

/// Returns an array of length `n` and type `T` where the elements start from 0 and go to n - 1.
/// ```zig
/// // Example
/// const slice = functools.rangeSlice(i32, 4);
/// try testing.expectEqualSlices(i32, slice, &[_]i32{ 0, 1, 2, 3 });
/// ```
pub fn rangeArray(comptime T: type, comptime n: usize) [n]T {
    var slice: [n]T = undefined;
    var idx: T = 0;
    for (0..n) |i| {
        slice[i] = idx;
        idx += 1;
    }

    return slice;
}

/// Returns an allocated slice of length `n` and type `T` where the elements start from 0 and go to n - 1.
/// ```zig
/// // Example
/// const allocator = testing.allocator;
/// const slice = try functools.rangeSlice(allocator, i32, 4);
/// defer allocator.free(slice);
/// try testing.expectEqualSlices(i32, slice, &[_]i32{ 0, 1, 2, 3 });
/// ```
pub fn rangeSlice(allocator: Allocator, comptime T: type, n: usize) ![]T {
    var slice = try allocator.alloc(T, n);
    var idx: T = 0;
    for (0..n) |i| {
        slice[i] = idx;
        idx += 1;
    }

    return slice;
}

/// Returns an `ArrayList(T)` of length `n` where the elements start from 0 and go to n - 1.
/// ```zig
/// // Example
/// const allocator = testing.allocator;
/// const arr = functools.rangeArrayList(allocator, i32, 4);
/// try testing.expectEqualSlices(i32, arr.items, &[_]i32{ 0, 1, 2, 3 });
/// ```
pub fn rangeArrayList(allocator: Allocator, comptime T: type, n: usize) !ArrayList(T) {
    var list = try ArrayList(T).initCapacity(allocator, n);
    var idx: T = 0;
    for (0..n) |_| {
        try list.append(idx);
        idx += 1;
    }

    return list;
}

const Point2D = struct {
    x: i32,
    y: i32,
};

fn orthogonal(p1: Point2D, p2: Point2D) bool {
    return (p1.x * p2.x + p1.y * p2.y) == 0;
}

test "test range array" {
    const arr = rangeArray(i32, 4);
    try testing.expectEqualSlices(i32, &arr, &[_]i32{ 0, 1, 2, 3 });
}

test "test iterate range slice" {
    for (rangeArray(usize, 5), 0..) |item, idx| {
        try testing.expectEqual(idx, item);
    }
}

test "test range array list" {
    const allocator = testing.allocator;
    const arr = try rangeArrayList(allocator, i32, 4);
    defer arr.deinit();

    try testing.expectEqualSlices(i32, arr.items, &[_]i32{ 0, 1, 2, 3 });
}
