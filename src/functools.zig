const std = @import("std");
const testing = std.testing;

const Allocator = std.mem.Allocator;

pub const FunctoolTypeError = error{
    InvalidParamType,
    InvalidReturnType,
};

/// Set of common mapping functions.
pub const CommonMappers = struct {
    /// Increment each number in slice.
    pub fn inc(comptime T: type) fn (item: T) T {
        return (struct {
            fn apply(item: T) T {
                return item + 1;
            }
        }).apply;
    }

    /// Decrement each number in slice.
    pub fn dec(comptime T: type) fn (item: T) T {
        return (struct {
            fn apply(item: T) T {
                return item - 1;
            }
        }).apply;
    }

    /// Add `n` to each item in slice. Supply `n` with the args.
    pub fn add(comptime T: type) fn (item: T, n: T) T {
        return (struct {
            fn apply(item: T, n: T) T {
                return item + n;
            }
        }).apply;
    }

    /// Subtract `n` to each item in slice. Supply `n` with the args.
    pub fn sub(comptime T: type) fn (item: T, n: T) T {
        return (struct {
            fn apply(item: T, n: T) T {
                return item - n;
            }
        }).apply;
    }

    /// Multiply `n` to each item in slice. Supply `n` with the args.
    pub fn mul(comptime T: type) fn (item: T, n: T) T {
        return (struct {
            fn apply(item: T, n: T) T {
                return item * n;
            }
        }).apply;
    }

    /// Divide `n` to each item in slice. Supply `n` with the args.
    pub fn div(comptime T: type) fn (item: T, n: T) T {
        return (struct {
            fn apply(item: T, n: T) T {
                return @divExact(item, n);
            }
        }).apply;
    }

    /// Strip item of all but one field supplied by args. The field type must also be provided.
    pub fn takeField(comptime T: type, comptime FT: type) fn (item: T, comptime field: []const u8) FT {
        return (struct {
            fn apply(item: T, comptime field: []const u8) FT {
                return @field(item, field);
            }
        }).apply;
    }
};

/// Set of common reducers.
pub const CommonReducers = struct {
    /// Sum all numbers in slice.
    pub fn sum(comptime T: type) fn (prev: T, curr: T) T {
        return (struct {
            fn apply(prev: T, curr: T) T {
                return prev + curr;
            }
        }).apply;
    }

    /// Compute the product of all numbers in slice.
    pub fn prod(comptime T: type) fn (prev: T, curr: T) T {
        return (struct {
            fn apply(prev: T, curr: T) T {
                return prev * curr;
            }
        }).apply;
    }
};

/// Set of common predicate functions.
pub const CommonPredicates = struct {
    /// Evalatues `true` if item is even.
    pub fn even(comptime T: type) fn (item: T) bool {
        return (struct {
            fn apply(item: T) bool {
                return @mod(item, 2) == 0;
            }
        }).apply;
    }

    /// Evalatues `true` if item is odd.
    pub fn odd(comptime T: type) fn (item: T) bool {
        return (struct {
            fn apply(item: T) bool {
                return @mod(item, 2) != 0;
            }
        }).apply;
    }

    /// Evalatues `true` if `item == 0`.
    pub fn zero(comptime T: type) fn (item: T) bool {
        return (struct {
            fn apply(item: T) bool {
                return item == 0;
            }
        }).apply;
    }

    /// Evalatues `true` if `item != 0`.
    pub fn notZero(comptime T: type) fn (item: T) bool {
        return (struct {
            fn apply(item: T) bool {
                return item != 0;
            }
        }).apply;
    }

    /// Evalatues `true` if `item` equals that of supplied in args. Only works on primitive types.
    pub fn eq(comptime T: type) fn (item: T, n: T) bool {
        return (struct {
            fn apply(item: T, n: T) bool {
                return item == n;
            }
        }).apply;
    }

    /// Evalatues `true` if `item` does not equal that of supplied in args. Only works on primitive types.
    pub fn neq(comptime T: type) fn (item: T, n: T) bool {
        return (struct {
            fn apply(item: T, n: T) bool {
                return item != n;
            }
        }).apply;
    }

    /// Evalatues `true` if `item` is `true`.
    pub fn truthy() fn (item: bool) bool {
        return (struct {
            fn apply(item: bool) bool {
                return item;
            }
        }).apply;
    }

    /// Evalatues `true` if `item` is `false`.
    pub fn falsy() fn (item: bool) bool {
        return (struct {
            fn apply(item: bool) bool {
                return !item;
            }
        }).apply;
    }
};

/// Map over slice of type `T` to slice new slice of type `RT` using function `func` on each element of `slice`.
/// Usually `T == RT`.
/// Additionally supply some arguments to `func`,
pub fn mapSlice(allocator: Allocator, comptime T: type, slice: []const T, comptime func: anytype, args: anytype) ![]@typeInfo(@TypeOf(func)).Fn.return_type.? {
    if (@typeInfo(@TypeOf(func)).Fn.params[0].type.? != T) {
        return FunctoolTypeError.InvalidParamType;
    }

    const ReturnType = @typeInfo(@TypeOf(func)).Fn.return_type orelse {
        return FunctoolTypeError.InvalidReturnType;
    };
    var mapped_list = try std.ArrayList(ReturnType).initCapacity(allocator, slice.len);

    for (0..slice.len) |idx| {
        const mapped: ReturnType = @call(.auto, func, .{slice[idx]} ++ args);
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

/// Take every nth element in `slice` of type `T`.
pub fn takeNth(allocator: Allocator, comptime T: type, slice: []const T, n: usize) ![]T {
    if (n <= 0) {
        return slice;
    }

    var nth = std.ArrayList(T).init(allocator);
    for (0..slice.len) |idx| {
        if (@mod(idx, n) == 0) {
            try nth.append(slice[idx]);
        }
    }

    const nth_slice = try nth.toOwnedSlice();
    return nth_slice;
}
