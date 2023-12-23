const std = @import("std");
const functools = @import("functools");
const time = std.time;

const TEST_SIZE = 90000000;

fn inc(n: i32) i32 {
    return n + 1;
}

pub fn main() !void {
    std.debug.print("Testing mapSlice with {d} elements.\n\n", .{TEST_SIZE});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const data = try allocator.alloc(i32, TEST_SIZE);
    var mapped_data = try allocator.alloc(i32, TEST_SIZE);

    @memset(data, 0);
    @memset(mapped_data, 0);

    var end_time: i64 = undefined;
    var start_time = time.milliTimestamp();

    mapped_data = try functools.mapSlice(
        allocator,
        i32,
        data,
        functools.CommonMappers.inc(i32),
        .{},
    );

    end_time = time.milliTimestamp();

    const functools_time: i64 = end_time - start_time;
    std.debug.print("With functools: {d}ms.\n", .{functools_time});

    start_time = time.milliTimestamp();

    for (0..TEST_SIZE) |i| {
        mapped_data[i] = inc(data[i]);
    }
    end_time = time.milliTimestamp();

    const manual_time: i64 = end_time - start_time;
    std.debug.print("Without functools: {d}ms.\n\n", .{manual_time});

    const overhead: f64 = @as(f64, @floatFromInt(functools_time)) / @as(f64, @floatFromInt(manual_time));
    std.debug.print("Functool incurs a {d:.2}x overhead.", .{overhead});
}
