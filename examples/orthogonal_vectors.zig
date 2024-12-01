//! The orthogonal vectors problem is the following,
//! you are given two sets of vectors, A and B of dimension d.
//! Decide whether or not there exists a vector in A
//! that is orthogonal to a vector in B.
//!
//! This problem can famously not be solved in strong sub-quadratic time
//! unless SETH is false.
//!
//! In this example we will solve the problem using functools for vectors of dimension 3.

const std = @import("std");
const functools = @import("functools");
const print = std.debug.print;

const TEST_SIZE = 100;
const SEED = 1827319;
var prng = std.rand.DefaultPrng.init(SEED);

const Vec3 = struct {
    x: i64,
    y: i64,
    z: i64,
    pub fn orthogonal(v1: Vec3, v2: Vec3) bool {
        return (v1.x * v2.x + v1.y * v2.y + v1.z * v2.z) == 0;
    }
};

fn randVec3(v: Vec3) Vec3 {
    _ = v;
    return Vec3{
        .x = prng.random().intRangeAtMost(i64, 0, 1),
        .y = prng.random().intRangeAtMost(i64, 0, 1),
        .z = prng.random().intRangeAtMost(i64, 0, 1),
    };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var set_A = try allocator.alloc(Vec3, TEST_SIZE);
    const set_B = try allocator.alloc(Vec3, TEST_SIZE);
    defer allocator.free(set_A);
    defer allocator.free(set_B);

    functools.mapSlice(randVec3, set_A, .{});
    functools.mapSlice(randVec3, set_B, .{});
    for (set_A[0..]) |v| {
        const found = functools.findSlice(Vec3.orthogonal, set_B, .{v});

        if (found) |ov| {
            print("Found 2 orthogonal vectors\n", .{});
            print("From A: x={d}\ty={d}\tz={d}\n", .{ v.x, v.y, v.z });
            print("From B: x={d}\ty={d}\tz={d}", .{ ov.x, ov.y, ov.z });
            std.process.exit(0);
        }
    }

    print("Found no orthogonal vectors.", .{});
}
