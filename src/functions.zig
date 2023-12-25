const std = @import("std");
const common = @import("common.zig");
const testing = std.testing;

const Allocator = std.mem.Allocator;

pub const FunctoolTypeError = error{
    InvalidParamType,
    InvalidReturnType,
};

pub const CommonMappers = common.CommonMappers;
pub const CommonReducers = common.CommonReducers;
pub const CommonPredicates = common.CommonPredicates;

/// Map over slice of type `T` to new allocated slice using function `func` on each element of `slice`.
/// Additionally supply some arguments to `func`.
/// Consumer of function must make sure to free returned slice.
pub fn mapSlice(allocator: Allocator, comptime T: type, slice: []const T, comptime func: anytype, args: anytype) ![]@typeInfo(@TypeOf(func)).Fn.return_type.? {
    if (@typeInfo(@TypeOf(func)).Fn.params[0].type.? != T) {
        return FunctoolTypeError.InvalidParamType;
    }

    const ReturnType = @typeInfo(@TypeOf(func)).Fn.return_type orelse {
        return FunctoolTypeError.InvalidReturnType;
    };

    var mapped_slice = try allocator.alloc(ReturnType, slice.len);
    for (0..slice.len) |idx| {
        mapped_slice[idx] = @call(.auto, func, .{slice[idx]} ++ args);
    }

    return mapped_slice;
}

/// Map over mutable slice of type `T` using function `func` on each element of `slice`.
/// Additionally supply some arguments to `func`,
pub fn mapMutSlice(comptime T: type, slice: []T, comptime func: anytype, args: anytype) !void {
    comptime {
        if (@typeInfo(@TypeOf(func)).Fn.params[0].type.? != T) {
            return FunctoolTypeError.InvalidParamType;
        }
    }

    for (0..slice.len) |idx| {
        slice[idx] = @call(.auto, func, .{slice[idx]} ++ args);
    }
}

/// Reduce slice of type `T` to value of type `RT` using function `func`.
/// Additionally supply some arguments to `func` and an initial value to reduce from.
pub fn reduceSlice(comptime T: type, comptime RT: type, slice: []const T, comptime func: anytype, args: anytype, initial_value: RT) !RT {
    comptime {
        if (@typeInfo(@TypeOf(func)).Fn.params[0].type.? != RT) {
            return FunctoolTypeError.InvalidParamType;
        }
        if (@typeInfo(@TypeOf(func)).Fn.params[1].type.? != T) {
            return FunctoolTypeError.InvalidParamType;
        }
        if (@typeInfo(@TypeOf(func)).Fn.return_type.? != RT) {
            return FunctoolTypeError.InvalidReturnType;
        }
    }

    var accumulator: RT = initial_value;

    for (slice[0..]) |item| {
        accumulator = @call(.auto, func, .{ accumulator, item } ++ args);
    }

    return accumulator;
}

/// Create new slice filtered from `slice` of type `T` using function `pred` as predicate.
/// Additionally supply some arguments to `pred`.
/// Consumer must make sure to free returned slice.
pub fn filterSlice(allocator: std.mem.Allocator, comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) ![]T {
    comptime {
        if (@typeInfo(@TypeOf(pred)).Fn.params[0].type.? != T) {
            return FunctoolTypeError.InvalidParamType;
        }
        if (@typeInfo(@TypeOf(pred)).Fn.return_type.? != bool) {
            return FunctoolTypeError.InvalidReturnType;
        }
    }

    var filtered = try allocator.alloc(T, slice.len);
    var filtered_len: usize = 0;
    for (slice[0..]) |item| {
        if (@call(.auto, pred, .{item} ++ args)) {
            filtered[filtered_len] = item;
            filtered_len += 1;
        }
    }

    _ = allocator.resize(filtered, filtered_len);
    return filtered[0..filtered_len];
}

/// Returns true if `slice` contains an item of type `T` that passes the predicate specified by `pred`.
/// Additionally supply some arguments to `pred`.
pub fn someSlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) !bool {
    comptime {
        if (@typeInfo(@TypeOf(pred)).Fn.params[0].type.? != T) {
            return FunctoolTypeError.InvalidParamType;
        }
        if (@typeInfo(@TypeOf(pred)).Fn.return_type.? != bool) {
            return FunctoolTypeError.InvalidReturnType;
        }
    }

    for (slice[0..]) |item| {
        if (@call(.auto, pred, .{item} ++ args)) {
            return true;
        }
    }

    return false;
}

/// Returns true if predicate defined by `pred` is true for every element in `slice` of type `T`.
/// Additionally supply some arguments to `pred`.
pub fn everySlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) !bool {
    comptime {
        if (@typeInfo(@TypeOf(pred)).Fn.params[0].type.? != T) {
            return FunctoolTypeError.InvalidParamType;
        }
        if (@typeInfo(@TypeOf(pred)).Fn.return_type.? != bool) {
            return FunctoolTypeError.InvalidReturnType;
        }
    }

    for (slice[0..]) |item| {
        if (!@call(.auto, pred, .{item} ++ args)) {
            return false;
        }
    }

    return true;
}

/// Take every nth element in `slice` of type `T`.
/// Consumer of function must make sure to free returned slice.
/// A special case is n <= 0, in which case the same slice will be returned.
pub fn takeNth(allocator: Allocator, comptime T: type, slice: []const T, n: usize) ![]T {
    if (n <= 0) {
        var copy = try allocator.alloc(T, slice.len);
        @memcpy(copy, slice);
        return copy;
    }

    var nth = try allocator.alloc(T, @divFloor(slice.len, n));
    var j: usize = 0;
    var i: usize = 0;
    while (i < slice.len) : (i += n) {
        nth[j] = slice[i];
        j += 1;
    }

    return nth;
}

/// Returns a slice of length `n` and type `T` where the elements start from 0 and go to n - 1.
/// ```zig
/// // Example
/// const slice = functools.rangeSlice(i32, 4);
/// try testing.expectEqualSlices(i32, slice, &[_]i32{ 0, 1, 2, 3 });
/// ```
pub fn rangeSlice(comptime T: type, comptime n: usize) *[n]T {
    var slice: [n]T = undefined;
    var idx: T = 0;
    for (0..n) |i| {
        slice[i] = idx;
        idx += 1;
    }

    return &slice;
}

/// Find and retrieve first item that predicate `pred` evaluates to true in slice of type `T`.
/// Additionally supply some arguments to `pred`.
pub fn findSlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) !?T {
    comptime {
        if (@typeInfo(@TypeOf(pred)).Fn.params[0].type.? != T) {
            return FunctoolTypeError.InvalidParamType;
        }
        if (@typeInfo(@TypeOf(pred)).Fn.return_type.? != bool) {
            return FunctoolTypeError.InvalidReturnType;
        }
    }

    for (slice[0..]) |item| {
        if (@call(.auto, pred, .{item} ++ args)) {
            return item;
        }
    }

    return null;
}
