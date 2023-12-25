const std = @import("std");
const functools = @import("functools");
const time = std.time;
const print = std.debug.print;
const util = @import("util.zig");
const Chameleon = @import("chameleon").Chameleon;

const TEST_SIZE = 90000000;

fn printResult(method: []const u8, t1: i64, t2: i64) void {
    const overhead: f64 = @as(f64, @floatFromInt(t1)) / @as(f64, @floatFromInt(t2));
    if (overhead < 1) {
        print("{s} incurs a {d:.2}% speedup.\n", .{ method, (1 - overhead) * 100 });
    } else {
        print("{s} incurs a {d:.2}% overhead.\n", .{ method, (overhead - 1) * 100 });
    }
}

fn withReduce(data: []const i64) i64 {
    return functools.reduceSlice(
        i64,
        data,
        functools.CommonReducers.sum(i64),
        .{},
        0,
    ) catch unreachable;
}

fn withoutReduce(data: []const i64) i64 {
    var reduced: i64 = 0;
    for (data[0..]) |item| {
        reduced += item;
    }

    return reduced;
}

pub fn benchmark(allocator: std.mem.Allocator) !void {
    comptime var cham = Chameleon.init(.Auto);

    print(cham.blue().bold().fmt("Benchmarking reduceSlice with {d} elements.\n"), .{TEST_SIZE});

    const data = try allocator.alloc(i64, TEST_SIZE);

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
