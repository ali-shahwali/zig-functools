const std = @import("std");
const testing = std.testing;

const Allocator = std.mem.Allocator;

pub const FunctoolTypeError = error{
    InvalidParamType,
    InvalidReturnType,
};

/// Map over slice of type `T` using function `func`.
/// Additionally supply some arguments to `func`,
pub fn mapSlice(allocator: Allocator, comptime T: type, slice: []const T, comptime func: anytype, args: anytype) ![]T {
    if (@typeInfo(@TypeOf(func)).Fn.params[0].type.? != T) {
        return FunctoolTypeError.InvalidParamType;
    }
    if (@typeInfo(@TypeOf(func)).Fn.return_type.? != T) {
        return FunctoolTypeError.InvalidReturnType;
    }

    var mapped_list = try std.ArrayList(T).initCapacity(allocator, slice.len);

    for (0..slice.len) |idx| {
        const mapped: T = @call(.auto, func, .{slice[idx]} ++ args);
        try mapped_list.append(mapped);
    }

    const mapped_slice = try mapped_list.toOwnedSlice();
    return mapped_slice;
}

/// Reduce slice of type `T` to value of type `RT` using function `func`.
/// Additionally supply some arguments to `func` and an initial value to reduce from.
pub fn reduceSlice(comptime T: type, comptime RT: type, slice: []const T, comptime func: anytype, args: anytype, initial_value: RT) !RT {
    if (@typeInfo(@TypeOf(func)).Fn.params[0].type.? != RT) {
        return FunctoolTypeError.InvalidParamType;
    }
    if (@typeInfo(@TypeOf(func)).Fn.params[1].type.? != T) {
        return FunctoolTypeError.InvalidParamType;
    }
    if (@typeInfo(@TypeOf(func)).Fn.return_type.? != RT) {
        return FunctoolTypeError.InvalidReturnType;
    }

    var accumulator: RT = initial_value;

    for (0..slice.len) |idx| {
        accumulator = @call(.auto, func, .{ accumulator, slice[idx] } ++ args);
    }

    return accumulator;
}

/// Create new slice filtered from `slice` of type `T` using function `pred` as predicate.
/// Additionally supply some arguments to `pred`.
pub fn filterSlice(allocator: std.mem.Allocator, comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) ![]T {
    if (@typeInfo(@TypeOf(pred)).Fn.params[0].type.? != T) {
        return FunctoolTypeError.InvalidParamType;
    }
    if (@typeInfo(@TypeOf(pred)).Fn.return_type.? != bool) {
        return FunctoolTypeError.InvalidReturnType;
    }

    var filtered_list = try std.ArrayList(T).initCapacity(allocator, slice.len);

    for (0..slice.len) |idx| {
        const filtered: bool = @call(.auto, pred, .{slice[idx]} ++ args);
        if (filtered) {
            try filtered_list.append(slice[idx]);
        }
    }

    const filtered_slice = try filtered_list.toOwnedSlice();
    return filtered_slice;
}

/// Returns true if `slice` contains an item of type `T` that passes the predicate specified by `pred`.
/// Additionally supply some arguments to `pred`.
pub fn someSlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) !bool {
    if (@typeInfo(@TypeOf(pred)).Fn.params[0].type.? != T) {
        return FunctoolTypeError.InvalidParamType;
    }
    if (@typeInfo(@TypeOf(pred)).Fn.return_type.? != bool) {
        return FunctoolTypeError.InvalidReturnType;
    }

    for (0..slice.len) |idx| {
        const pred_result: bool = @call(.auto, pred, .{slice[idx]} ++ args);
        if (pred_result) {
            return true;
        }
    }

    return false;
}

/// Returns true if predicate defined by `pred` is true for every element in `slice` of type `T`.
/// Additionally supply some arguments to `pred`.
pub fn everySlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) !bool {
    if (@typeInfo(@TypeOf(pred)).Fn.params[0].type.? != T) {
        return FunctoolTypeError.InvalidParamType;
    }
    if (@typeInfo(@TypeOf(pred)).Fn.return_type.? != bool) {
        return FunctoolTypeError.InvalidReturnType;
    }

    for (0..slice.len) |idx| {
        const pred_result: bool = @call(.auto, pred, .{slice[idx]} ++ args);
        if (!pred_result) {
            return false;
        }
    }

    return true;
}
