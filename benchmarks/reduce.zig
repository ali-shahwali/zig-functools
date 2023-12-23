const std = @import("std");
const functools = @import("functools");
const time = std.time;

const TEST_SIZE = 90000000;

pub fn main() !void {
    std.debug.print("Testing reduceSlice with {d} elements.\n\n", .{TEST_SIZE});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const data = try allocator.alloc(i64, TEST_SIZE);
    var reduced: i64 = undefined;

    @memset(data, 1);

    var end_time: i64 = undefined;
    var start_time = time.milliTimestamp();

    reduced = try functools.reduceSlice(
        i64,
        i64,
        data,
        functools.CommonReducers.sum(i64),
        .{},
        0,
    );

    end_time = time.milliTimestamp();
    const functools_time: i64 = end_time - start_time;
    std.debug.print("With functools: {d}ms.\n", .{functools_time});

    start_time = time.milliTimestamp();

    for (0..TEST_SIZE) |i| {
        reduced += data[i];
    }

    end_time = time.milliTimestamp();
    const manual_time: i64 = end_time - start_time;
    std.debug.print("Without functools: {d}ms.\n\n", .{manual_time});

    const overhead: f64 = @as(f64, @floatFromInt(functools_time)) / @as(f64, @floatFromInt(manual_time));
    std.debug.print("Functool incurs a {d:.2}x overhead.", .{overhead});
}
