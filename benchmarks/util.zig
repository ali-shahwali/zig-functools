//! Some utilities for benchmarking.
const std = @import("std");
const Chameleon = @import("chameleon").Chameleon;
const print = std.debug.print;

pub fn callFn(comptime func: anytype, args: anytype) void {
    if (@typeInfo(@TypeOf(func)).Fn.return_type.? == void) {
        @call(.always_inline, func, args);
    } else {
        _ = @call(.always_inline, func, args);
    }
}

pub fn benchMilli(desc: []const u8, comptime func: anytype, args: anytype) i64 {
    const start_time = std.time.milliTimestamp();

    callFn(func, args);

    const end_time = std.time.milliTimestamp();

    const total = end_time - start_time;
    printResult(i64, desc, total, "ms");
    return total;
}

pub fn benchMicro(desc: []const u8, comptime func: anytype, args: anytype) i64 {
    const start_time = std.time.microTimestamp();

    callFn(func, args);

    const end_time = std.time.microTimestamp();

    const total = end_time - start_time;
    printResult(i64, desc, total, "microseconds");
    return total;
}

pub fn benchNano(desc: []const u8, comptime func: anytype, args: anytype) i128 {
    const start_time = std.time.nanoTimestamp();

    callFn(func, args);

    const end_time = std.time.nanoTimestamp();

    const total = end_time - start_time;
    printResult(i128, desc, total, "ns");
    return total;
}

pub fn printComparison(comptime UnitType: type, method: []const u8, bench1: UnitType, bench2: UnitType) void {
    const diff: f64 = @as(f64, @floatFromInt(bench1)) / @as(f64, @floatFromInt(bench2));
    comptime var cham = Chameleon.init(.Auto);
    if (diff < 1) {
        print(cham.green().fmt("{s} incurs a {d:.2}% speedup.\n\n"), .{ method, (1 - diff) * 100 });
    } else {
        print(cham.red().fmt("{s} incurs a {d:.2}% overhead.\n\n"), .{ method, (diff - 1) * 100 });
    }
}

fn printResult(comptime UnitType: type, desc: []const u8, time: UnitType, unit: []const u8) void {
    print("{s}: {d}{s} \n", .{ desc, time, unit });
}
