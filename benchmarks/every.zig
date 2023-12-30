const std = @import("std");
const functools = @import("functools");
const time = std.time;
const util = @import("util.zig");
const print = std.debug.print;
const Chameleon = @import("chameleon").Chameleon;

const TEST_SIZE = 90000000;

fn withEvery(data: []i64) bool {
    return functools.everySlice(
        i64,
        data,
        functools.CommonPredicates.eq(i64),
        .{@as(i64, 1)},
    );
}

fn withoutEvery(data: []i64) bool {
    var result = true;
    for (data[0..]) |item| {
        if (item != 1) {
            result = false;
            break;
        }
    }

    return result;
}

pub fn benchmark(allocator: std.mem.Allocator) !void {
    comptime var cham = Chameleon.init(.Auto);

    print(cham.blue().bold().fmt("Benchmarking everySlice with {d} elements.\n"), .{TEST_SIZE});

    const data = try allocator.alloc(i64, TEST_SIZE);

    @memset(data, 1);

    const every_slice_time = util.benchNano("With functools", withEvery, .{data});

    const manual_time = util.benchNano("Without functools", withoutEvery, .{data});

    util.printComparison(i128, "everySlice", every_slice_time, manual_time);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    try benchmark(allocator);
}
