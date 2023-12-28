//! This example shows how to use functools when creating your data structures.
//! In this instance we are implementing a mathematical set.

const std = @import("std");
const functools = @import("functools");
const Allocator = std.mem.Allocator;

const CommonPredicates = functools.CommonPredicates;

pub fn Set(comptime T: type) type {
    return struct {
        allocator: Allocator,
        set: std.ArrayList(T),

        const Self = @This();

        pub fn init(allocator: Allocator) Self {
            return .{
                .allocator = allocator,
                .set = std.ArrayList(T).init(allocator),
            };
        }

        pub fn deinit(self: *const Self) void {
            self.set.deinit();
        }

        pub fn fromArrayList(allocator: Allocator, arr: std.ArrayList(T)) !Self {
            var set = std.ArrayList(T).init(allocator);
            for (arr.items) |item| {
                const some = try functools.someArrayList(
                    T,
                    set,
                    CommonPredicates.eq(T),
                    .{item},
                );
                if (!some) {
                    try set.append(item);
                }
            }
            return .{ .allocator = allocator, .set = set };
        }

        pub fn asArrayList(self: *const Self) !std.ArrayList(T) {
            return try self.set.clone();
        }

        pub fn insert(self: *Self, item: T) !void {
            const some = try functools.someArrayList(
                T,
                self.set,
                CommonPredicates.eq(T),
                .{item},
            );
            if (!some) {
                try self.set.append(item);
            }
        }

        pub fn remove(self: *Self, item: T) !void {
            self.set = try functools.filterArrayList(
                self.allocator,
                T,
                self.set,
                functools.CommonPredicates.neq(T),
                .{item},
            );
        }

        pub fn contains(self: *const Self, item: T) !bool {
            return try functools.someArrayList(
                T,
                self.set,
                CommonPredicates.eq(T),
                .{item},
            );
        }

        pub fn size(self: *const Self) usize {
            return self.set.items.len;
        }

        pub fn setIntersect(allocator: Allocator, s1: Set(T), s2: Set(T)) !Set(T) {
            var intersected = Set(T).init(allocator);

            for (s1.set.items) |item| {
                const c = try s2.contains(item);
                if (c) {
                    try intersected.insert(item);
                }
            }

            return intersected;
        }

        pub fn setUnion(allocator: Allocator, s1: Set(T), s2: Set(T)) !Set(T) {
            var result = try Set(T).fromArrayList(allocator, s1.set);

            for (s2.set.items) |item| {
                try result.insert(item);
            }

            return result;
        }

        pub fn setDifference(allocator: Allocator, s1: Set(T), s2: Set(T)) !Set(T) {
            var result = try Set(T).fromArrayList(allocator, s1.set);

            for (s2.set.items) |item| {
                try result.remove(item);
            }

            return result;
        }

        pub fn pprint(self: *const Self) void {
            std.debug.print("{any}\n", .{self.set.items});
        }
    };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var s1 = Set(i32).init(allocator);
    defer s1.deinit();

    try s1.insert(1);
    try s1.insert(2);
    try s1.insert(3);

    std.debug.print("S1: ", .{});
    s1.pprint();

    var s2 = Set(i32).init(allocator);
    defer s2.deinit();

    try s2.insert(4);
    try s2.insert(5);
    try s2.insert(6);

    std.debug.print("S2: ", .{});
    s2.pprint();

    const s3 = try Set(i32).setUnion(allocator, s1, s2);
    defer s3.deinit();

    std.debug.print("S3 = S1 U S2: ", .{});
    s3.pprint();

    try s1.remove(1);
    std.debug.print("S1 = S1 \\ {{ 1 }}: ", .{});
    s1.pprint();

    const s4 = try Set(i32).setDifference(allocator, s3, s1);
    defer s4.deinit();

    std.debug.print("S4 = S3 \\ S1: ", .{});
    s4.pprint();
}
