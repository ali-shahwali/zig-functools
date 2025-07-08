const std = @import("std");
const functools = @import("functools");
const print = std.debug.print;
const util = @import("util.zig");

const TEST_SIZE = 900000000;

fn withReduce(data: []const i64) i64 {
    return functools.reduce(
        functools.reducers.sum(i64),
        @constCast(data),
        0,
    );
}

fn withoutReduce(data: []const i64) i64 {
    var reduced: i64 = 0;
    for (data[0..]) |item| {
        reduced += item;
    }

    return reduced;
}

pub fn benchmark(allocator: std.mem.Allocator) !void {
    print("Benchmarking reduceSlice with {d} elements.\n", .{TEST_SIZE});

    const data = try allocator.alloc(i64, TEST_SIZE);
    defer allocator.free(data);

    @memset(data, 1);

    const reduce_slice_time: i64 = util.benchMilli("With functools", withReduce, .{data});

    const manual_time: i64 = util.benchMilli("Without functools", withoutReduce, .{data});

    util.printComparison(i64, "reduceSlice", reduce_slice_time, manual_time);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    try benchmark(allocator);
}
