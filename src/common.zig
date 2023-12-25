const std = @import("std");

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

    /// Compute `ln(n)` on each item in slice.
    pub fn log(comptime T: type) fn (item: T) T {
        return (struct {
            fn apply(item: T) T {
                return @log(item);
            }
        }).apply;
    }

    /// Compute log base 2 on each item in slice.
    pub fn log2(comptime T: type) fn (item: T) T {
        return (struct {
            fn apply(item: T) T {
                return @log2(item);
            }
        }).apply;
    }

    /// Compute log base 10 on each item in slice.
    pub fn log10(comptime T: type) fn (item: T) T {
        return (struct {
            fn apply(item: T) T {
                return @log10(item);
            }
        }).apply;
    }

    /// Compute the sinus value of each item in slice.
    pub fn sin(comptime T: type) fn (item: T) T {
        return (struct {
            fn apply(item: T) T {
                return @sin(item);
            }
        }).apply;
    }

    /// Compute the cosinus value of each item in slice.
    pub fn cos(comptime T: type) fn (item: T) T {
        return (struct {
            fn apply(item: T) T {
                return @cos(item);
            }
        }).apply;
    }

    /// Compute the cosinus value of each item in slice.
    pub fn tan(comptime T: type) fn (item: T) T {
        return (struct {
            fn apply(item: T) T {
                return @tan(item);
            }
        }).apply;
    }

    /// Compute the square root of each item in slice.
    pub fn sqrt(comptime T: type) fn (item: T) T {
        return (struct {
            fn apply(item: T) T {
                return @sqrt(item);
            }
        }).apply;
    }

    /// Compute largest integral value not greater than given floating point number on each item in slice.
    pub fn floor(comptime T: type) fn (item: T) T {
        return (struct {
            fn apply(item: T) T {
                return @floor(item);
            }
        }).apply;
    }

    /// Compute smallest integral value not less than given floating point number on each item in slice.
    pub fn ceil(comptime T: type) fn (item: T) T {
        return (struct {
            fn apply(item: T) T {
                return @ceil(item);
            }
        }).apply;
    }

    /// Round each floating point item in slice to an integer, towards zero.
    pub fn trunc(comptime T: type) fn (item: T) T {
        return (struct {
            fn apply(item: T) T {
                return @trunc(item);
            }
        }).apply;
    }

    /// Strip item of all but one field supplied by args. The field type must also be provided.
    pub fn takeField(comptime T: type, comptime FieldType: type) fn (item: T, comptime field: []const u8) FieldType {
        return (struct {
            fn apply(item: T, comptime field: []const u8) FieldType {
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

    /// Evalatues `true` if `item` is greater than 0.
    pub fn pos(comptime T: type) fn (item: T) bool {
        return (struct {
            fn apply(item: T) bool {
                return item > 0;
            }
        }).apply;
    }

    /// Evalatues `true` if `item` is less than 0.
    pub fn neg(comptime T: type) fn (item: T) bool {
        return (struct {
            fn apply(item: T) bool {
                return item < 0;
            }
        }).apply;
    }

    /// Evalatues `true` if field supplied in args of `item` equals that of value supplied in args.
    pub fn fieldEq(comptime T: type, comptime FieldType: type) fn (item: T, comptime field: []const u8, value: FieldType) bool {
        return (struct {
            fn apply(item: T, comptime field: []const u8, value: FieldType) bool {
                return @field(item, field) == value;
            }
        }).apply;
    }
};
