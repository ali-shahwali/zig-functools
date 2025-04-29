//! This module contains the Sequence data structure.

const std = @import("std");
const core = @import("core.zig");
const util = @import("util.zig");
const common = @import("common.zig");

const testing = std.testing;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

/// A generic data structure that represents a sequence of elements.
/// Wrapper around the ArrayList type in std.
pub fn Sequence(comptime T: type) type {
    return struct {
        seq: ArrayList(T),
        allocator: Allocator,

        const Self = @This();

        /// Initialize empty sequence
        pub fn init(allocator: Allocator) Self {
            return .{
                .seq = ArrayList(T).init(allocator),
                .allocator = allocator,
            };
        }

        /// Initialize sequence from slice
        pub fn fromSlice(allocator: Allocator, slice: []T) !Self {
            var seq = try ArrayList(T).initCapacity(allocator, slice.len);
            seq.appendSliceAssumeCapacity(slice);

            return .{
                .allocator = allocator,
                .seq = seq,
            };
        }

        /// Initialize sequence from array list
        pub fn fromArrayList(allocator: Allocator, arr: ArrayList(T)) !Self {
            const seq = try ArrayList(T).initCapacity(allocator, arr.capacity);
            seq.appendSliceAssumeCapacity(arr.items);

            return .{
                .allocator = allocator,
                .items = seq,
            };
        }

        /// Deinitializes sequence and returns owned slice.
        /// Consumer of function must make sure to free returned slice with the same allocator.
        pub fn toOwnedSlice(self: *Self) ![]T {
            defer self.deinit();

            return try self.seq.toOwnedSlice();
        }

        /// Returns new cloned sequence
        pub fn clone(self: *const Self) !Sequence(T) {
            const cl = try Sequence(T).fromArrayList(self.allocator, self.seq);
            return cl;
        }

        /// Deinitialize sequence
        pub fn deinit(self: *const Self) void {
            self.seq.deinit();
        }

        /// Map over sequence
        pub fn map(self: *const Self, comptime func: anytype, args: anytype) void {
            core.mapArrayList(func, self.seq, args);
        }

        /// Filter sequence
        pub fn filter(self: *Self, comptime pred: anytype, args: anytype) !void {
            var filtered = try core.filterArrayList(
                self.allocator,
                pred,
                self.seq,
                args,
            );

            const slice = try filtered.toOwnedSlice();
            self.seq.clearAndFree();
            self.seq = ArrayList(T).fromOwnedSlice(self.allocator, slice);
        }

        /// Reduce sequence
        pub fn reduce(self: *Self, comptime reducer: anytype, args: anytype, initial_value: T) T {
            return core.reduceArrayList(
                reducer,
                self.seq,
                args,
                initial_value,
            );
        }

        /// Returns true if some item in sequence satisfies predicate
        pub fn some(self: *Self, comptime pred: anytype, args: anytype) bool {
            return core.someArrayList(pred, self.seq, args);
        }

        /// Returns true if every item in sequence satisfies predicate
        pub fn every(self: *Self, comptime pred: anytype, args: anytype) bool {
            return core.everyArrayList(pred, self.seq, args);
        }

        /// Find first item in sequence that satisfies predicate.
        pub fn find(self: *Self, comptime pred: anytype, args: anytype) ?T {
            return core.findArrayList(pred, self.seq, args);
        }

        /// Conjoin sequence with another sequence
        pub fn conj(self: *Self, s: Sequence(T)) !void {
            try self.seq.ensureTotalCapacity(self.seq.capacity + s.seq.capacity);
            self.seq.appendSliceAssumeCapacity(s.seq.items);
        }

        /// Append item to end of sequence
        pub fn append(self: *Self, value: T) !void {
            try self.seq.append(value);
        }
    };
}

const CommonMappers = common.CommonMappers;
const CommonPredicates = common.CommonPredicates;
const CommonReducers = common.CommonReducers;

test "test filter sequence" {
    const allocator = testing.allocator;
    const slice = try util.rangeSlice(allocator, i32, 10);
    defer allocator.free(slice);

    var seq = try Sequence(i32).fromSlice(allocator, slice);
    try seq.filter(CommonPredicates.even(i32), .{});

    const res = try seq.toOwnedSlice();
    defer allocator.free(res);

    try testing.expectEqualSlices(i32, &[_]i32{ 0, 2, 4, 6, 8 }, res);
}

test "test map and conjoin sequence" {
    const allocator = testing.allocator;
    const s1 = try util.rangeSlice(allocator, i32, 5);
    defer allocator.free(s1);

    const s2 = try util.rangeSlice(allocator, i32, 5);
    defer allocator.free(s2);

    var seq1 = try Sequence(i32).fromSlice(allocator, s1);
    var seq2 = try Sequence(i32).fromSlice(allocator, s2);
    defer seq2.deinit();

    seq2.map(CommonMappers.add(i32), .{5});

    try seq1.conj(seq2);
    try seq1.filter(common.CommonPredicates.even(i32), .{});

    const res = try seq1.toOwnedSlice();
    defer allocator.free(res);

    try testing.expectEqualSlices(i32, &[_]i32{ 0, 2, 4, 6, 8 }, res);
}

test "test append sequence" {
    const allocator = testing.allocator;

    var seq = Sequence(i32).init(allocator);
    defer seq.deinit();

    try seq.append(5);

    const some = seq.some(CommonPredicates.eq(i32), .{5});

    try testing.expect(some);
}
