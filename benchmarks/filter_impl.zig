//! This benchmark compares two different implementations of filter.
//! One using alloc and resize, and one using ArrayList with toOwnedSlice.
//! It seems like alloc and resize is slightly faster, current implementation is using this for now.
const std = @import("std");
const util = @import("util.zig");
const functools = @import("functools");
const print = std.debug.print;

const TEST_SIZE = 90000000;

fn filterSliceWithAlloc(allocator: std.mem.Allocator, comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) ![]T {
    var filtered = try allocator.alloc(T, slice.len);
    var filtered_len: usize = 0;
    for (slice[0..]) |item| {
        if (@call(.auto, pred, .{item} ++ args)) {
            filtered[filtered_len] = item;
            filtered_len += 1;
        }
    }

    _ = allocator.resize(filtered, filtered_len);
    filtered.len = filtered_len;
    return filtered;
}

fn filterSliceWithList(allocator: std.mem.Allocator, comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) ![]T {
    var filtered_list = try std.ArrayList(T).initCapacity(allocator, slice.len);

    for (slice) |item| {
        if (@call(.auto, pred, .{item} ++ args)) {
            filtered_list.appendAssumeCapacity(item);
        }
    }

    return try filtered_list.toOwnedSlice();
}

fn withAllocFilter(allocator: std.mem.Allocator, data: []i32) void {
    _ = filterSliceWithAlloc(
        allocator,
        i32,
        data,
        functools.predicates.even(i32),
        .{},
    ) catch unreachable;
}

fn withListFilter(allocator: std.mem.Allocator, data: []i32) void {
    _ = functools.filter(
        allocator,
        functools.predicates.even(i32),
        data,
    ) catch unreachable;
}

pub fn benchmark(allocator: std.mem.Allocator) !void {
    print("Benchmarking filter implementations with {d} elements.\n", .{TEST_SIZE});

    const data = try functools.rangeSlice(allocator, i32, TEST_SIZE);
    defer allocator.free(data);

    const filter_alloc_time = util.benchMilli(
        "With alloc filter",
        withAllocFilter,
        .{ allocator, data },
    );

    const filter_list_time = util.benchMilli(
        "With array list filter",
        withListFilter,
        .{ allocator, data },
    );

    util.printComparison(i64, "withAllocFilter", filter_alloc_time, filter_list_time);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    try benchmark(allocator);
}
