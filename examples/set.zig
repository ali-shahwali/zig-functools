//! This example shows how to use functools when creating your data structures.
//! In this instance we are implementing a mathematical set.

const std = @import("std");
const functools = @import("functools");
const Allocator = std.mem.Allocator;

const CommonPredicates = functools.CommonPredicates;

pub fn Set(comptime T: type) type {
    return struct {
        allocator: Allocator,
        set: functools.Sequence(T),

        const Self = @This();

        pub fn init(allocator: Allocator) Self {
            return .{
                .allocator = allocator,
                .set = functools.Sequence(T).init(allocator),
            };
        }

        pub fn deinit(self: *const Self) void {
            self.set.deinit();
        }

        pub fn fromSlice(allocator: Allocator, slice: []T) !Self {
            var seq = functools.Sequence(i32).init(allocator);
            for (slice[0..]) |item| {
                const some = seq.some(CommonPredicates.eq(T), .{item});

                if (!some) {
                    try seq.append(item);
                }
            }
            return .{ .allocator = allocator, .set = seq };
        }

        pub fn insert(self: *Self, item: T) !void {
            const some = self.set.some(CommonPredicates.eq(T), .{item});
            if (!some) {
                try self.set.append(item);
            }
        }

        pub fn remove(self: *Self, item: T) !void {
            try self.set.filter(functools.CommonPredicates.neq(T), .{item});
        }

        pub fn contains(self: *const Self, item: T) bool {
            return self.set.some(CommonPredicates.eq(T), .{item});
        }

        pub fn size(self: *const Self) usize {
            return self.set.items.len;
        }

        pub fn setIntersect(allocator: Allocator, s1: Set(T), s2: Set(T)) !Set(T) {
            var intersected = Set(T).init(allocator);

            for (s1.set.seq.items) |item| {
                const c = try s2.contains(item);
                if (c) {
                    try intersected.insert(item);
                }
            }

            return intersected;
        }

        pub fn setUnion(allocator: Allocator, s1: Set(T), s2: Set(T)) !Set(T) {
            var result = try Set(T).fromSlice(allocator, s1.set.seq.items);

            for (s2.set.seq.items) |item| {
                try result.insert(item);
            }

            return result;
        }

        pub fn setDifference(allocator: Allocator, s1: Set(T), s2: Set(T)) !Set(T) {
            var result = try Set(T).fromSlice(allocator, s1.set.seq.items);

            for (s2.set.seq.items) |item| {
                try result.remove(item);
            }

            return result;
        }

        pub fn pprint(self: *const Self) void {
            std.debug.print("{any}\n", .{self.set.seq.items});
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
