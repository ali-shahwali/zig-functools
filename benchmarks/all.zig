const std = @import("std");
const map = @import("map.zig");
const reduce = @import("reduce.zig");
const filter_impl = @import("filter_impl.zig");
const every = @import("every.zig");
const functools = @import("functools");

const BenchError = error{
    Error,
    OutOfMemory,
};

const BenchFn = fn (allocator: std.mem.Allocator) BenchError!void;

const BENCHMARK_FNS = [_]BenchFn{
    map.benchmark,
    reduce.benchmark,
    filter_impl.benchmark,
    every.benchmark,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    inline for (BENCHMARK_FNS[0..]) |bench_fn| {
        try bench_fn(allocator);
    }
}
