const std = @import("std");
const Allocator = std.mem.Allocator;
const time = std.time;
const print = std.debug.print;
const util = @import("util.zig");
const functools = @import("functools");
const typed = @import("typed");

const TEST_SIZE = 90000000;

pub fn mapSliceWithAlloc(allocator: Allocator, comptime T: type, slice: []const T, comptime func: anytype, args: anytype) ![]typed.ReturnType(func) {
    const ReturnType = typed.ReturnType(func);
    var mapped_slice = try allocator.alloc(ReturnType, slice.len);
    for (0..slice.len) |idx| {
        mapped_slice[idx] = @call(.auto, func, .{slice[idx]} ++ args);
    }

    return mapped_slice;
}

pub fn mapSliceWithArrayList(allocator: Allocator, comptime T: type, slice: []const T, comptime func: anytype, args: anytype) ![]typed.ReturnType(func) {
    const ReturnType = typed.ReturnType(func);
    var mapped_list = try std.ArrayList(ReturnType).initCapacity(allocator, slice.len);
    for (0..slice.len) |idx| {
        mapped_list.appendAssumeCapacity(@call(.auto, func, .{slice[idx]} ++ args));
    }

    return try mapped_list.toOwnedSlice();
}

fn withAllocMap(allocator: std.mem.Allocator, data: []i32) void {
    _ = mapSliceWithAlloc(
        allocator,
        i32,
        data,
        functools.CommonMappers.inc(i32),
        .{},
    ) catch unreachable;
}

fn withListMap(allocator: std.mem.Allocator, data: []i32) void {
    _ = mapSliceWithArrayList(
        allocator,
        i32,
        data,
        functools.CommonMappers.inc(i32),
        .{},
    ) catch unreachable;
}

pub fn benchmark(allocator: std.mem.Allocator) !void {
    print("Benchmarking map implementations with {d} elements.\n", .{TEST_SIZE});

    const data = try allocator.alloc(i32, TEST_SIZE);
    defer allocator.free(data);

    @memset(data, 0);

    const map_alloc_time = util.benchMilli(
        "With alloc",
        withAllocMap,
        .{ allocator, data },
    );

    const map_list_time = util.benchMilli(
        "With array list",
        withListMap,
        .{ allocator, data },
    );

    util.printComparison(i64, "mapSliceWithAlloc", map_alloc_time, map_list_time);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    try benchmark(allocator);
}
