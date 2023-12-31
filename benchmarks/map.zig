const std = @import("std");
const functools = @import("functools");
const time = std.time;
const print = std.debug.print;
const util = @import("util.zig");
const Chameleon = @import("chameleon").Chameleon;

const TEST_SIZE = 90000000;

fn inc(n: i32) i32 {
    return n + 1;
}

fn withMapMutSlice(data: []i32) void {
    functools.mapMutSlice(
        i32,
        data,
        functools.CommonMappers.inc(i32),
        .{},
    );
}

fn withoutMap(data: []i32) void {
    for (0..TEST_SIZE) |i| {
        data[i] = inc(data[i]);
    }
}

pub fn benchmark(allocator: std.mem.Allocator) !void {
    comptime var cham = Chameleon.init(.Auto);

    print(cham.blue().bold().fmt("Benchmarking mapMutSlice with {d} elements.\n"), .{TEST_SIZE});

    const data = try allocator.alloc(i32, TEST_SIZE);
    defer allocator.free(data);

    @memset(data, 0);

    const map_mut_slice_time = util.benchMilli(
        "With mapSlice",
        withMapMutSlice,
        .{data},
    );

    @memset(data, 0);

    const manual_time = util.benchMilli(
        "Without functools",
        withoutMap,
        .{data},
    );

    util.printComparison(i64, "mapMutSlice", map_mut_slice_time, manual_time);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    try benchmark(allocator);
}
