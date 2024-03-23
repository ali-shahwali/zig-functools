const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

/// Take every nth element in `slice` of type `T`.
/// Consumer of function must make sure to free returned slice.
/// A special case is n <= 0, in which case the same slice will be returned.
pub fn takeNth(allocator: Allocator, comptime T: type, slice: []const T, n: usize) ![]T {
    if (n <= 0) {
        const copy = try allocator.alloc(T, slice.len);
        @memcpy(copy, slice);
        return copy;
    }
    const len = try std.math.divCeil(usize, slice.len, n);
    var nth = try allocator.alloc(T, len);
    var j: usize = 0;
    var i: usize = 0;
    while (i < slice.len) : (i += n) {
        nth[j] = slice[i];
        j += 1;
    }

    return nth;
}

test "test takeNth" {
    const allocator = testing.allocator;

    const slice = [_]i32{ 0, 1, 2, 3, 4, 5 };
    const nth = try takeNth(allocator, i32, &slice, 2);
    defer allocator.free(nth);

    try testing.expectEqualSlices(i32, nth, &[_]i32{ 0, 2, 4 });
}
