const std = @import("std");
const functions = @import("functions.zig");
const Allocator = std.mem.Allocator;

pub fn Thread(comptime T: type) type {
    return struct {
        err: ?error{ FunctoolTypeError, OutOfMemory } = null,
        allocator: Allocator,

        const Self = @This();

        var slice: []T = undefined;

        pub fn init(allocator: Allocator, data: []T) Self {
            slice = allocator.alloc(T, data.len) catch |err| {
                return .{ .allocator = allocator, .err = err };
            };
            @memcpy(slice, data);
            return .{
                .allocator = allocator,
            };
        }

        pub fn map(self: *const Self, comptime func: anytype, args: anytype) Self {
            if (self.err) |err| {
                return .{
                    .err = err,
                    .allocator = self.allocator,
                };
            }
            functions.mapMutSlice(T, slice, func, args) catch |err| {
                return .{
                    .err = err,
                    .allocator = self.allocator,
                };
            };

            return .{
                .allocator = self.allocator,
            };
        }

        pub fn filter(self: *const Self, comptime pred: anytype, args: anytype) Self {
            if (self.err) |err| {
                return .{
                    .err = err,
                    .allocator = self.allocator,
                };
            }
            const filtered = functions.filterSlice(self.allocator, T, slice, pred, args) catch |err| {
                return .{
                    .err = err,
                    .allocator = self.allocator,
                };
            };
            defer self.allocator.free(filtered);
            _ = self.allocator.resize(slice, filtered.len);
            @memcpy(slice[0..filtered.len], filtered);
            slice = slice[0..filtered.len];
            return .{
                .allocator = self.allocator,
            };
        }

        pub fn reduce(self: *const Self, comptime func: anytype, args: anytype, initial_value: T) !T {
            defer self.allocator.free(slice);
            if (self.err) |err| {
                return err;
            }
            return functions.reduceSlice(T, slice, func, args, initial_value) catch |err| {
                return err;
            };
        }

        pub fn some(self: *const Self, comptime pred: anytype, args: anytype) !bool {
            defer self.allocator.free(slice);
            if (self.err) |err| {
                return err;
            }
            return functions.someSlice(T, slice, pred, args) catch |err| {
                return err;
            };
        }

        pub fn every(self: *const Self, comptime pred: anytype, args: anytype) !bool {
            defer self.allocator.free(slice);
            if (self.err) |err| {
                return err;
            }
            return functions.everySlice(T, slice, pred, args) catch |err| {
                return err;
            };
        }

        pub fn find(self: *const Self, comptime pred: anytype, args: anytype) !?T {
            defer self.allocator.free(slice);
            if (self.err) |err| {
                return err;
            }
            return functions.findSlice(T, slice, pred, args) catch |err| {
                return err;
            };
        }

        pub fn result(self: *const Self) ![]T {
            if (self.err) |err| {
                return err;
            } else {
                return slice;
            }
        }
    };
}
