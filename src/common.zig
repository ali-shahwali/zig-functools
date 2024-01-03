//! This module contains a set of common mapping, reducing and predicate functions.
const meta = @import("std").meta;

/// Set of common mapping functions.
pub const CommonMappers = struct {
    /// Increment each number.
    pub fn inc(comptime T: type) fn (item: T) T {
        return (struct {
            fn incFn(item: T) T {
                return item + 1;
            }
        }).incFn;
    }

    /// Decrement each number.
    pub fn dec(comptime T: type) fn (item: T) T {
        return (struct {
            fn decFn(item: T) T {
                return item - 1;
            }
        }).decFn;
    }

    /// Add `n` to each item.
    /// `n` must be supplied in `args`.
    pub fn add(comptime T: type) fn (item: T, n: T) T {
        return (struct {
            fn addFn(item: T, n: T) T {
                return item + n;
            }
        }).addFn;
    }

    /// Subtract `n` to each item.
    /// `n` must be supplied in `args`.
    pub fn sub(comptime T: type) fn (item: T, n: T) T {
        return (struct {
            fn subFn(item: T, n: T) T {
                return item - n;
            }
        }).subFn;
    }

    /// Multiply `n` to each item.
    /// `n` must be supplied in `args`.
    pub fn mul(comptime T: type) fn (item: T, n: T) T {
        return (struct {
            fn mulFn(item: T, n: T) T {
                return item * n;
            }
        }).mulFn;
    }

    /// Divide `n` to each item.
    /// `n` must be supplied in `args`.
    pub fn div(comptime T: type) fn (item: T, n: T) T {
        return (struct {
            fn divFn(item: T, n: T) T {
                return @divExact(item, n);
            }
        }).divFn;
    }

    /// Compute the natural logarithm `ln(n)` on each item.
    pub fn log(comptime T: type) fn (item: T) T {
        return (struct {
            fn logFn(item: T) T {
                return @log(item);
            }
        }).logFn;
    }

    /// Compute log base 2 on each item.
    pub fn log2(comptime T: type) fn (item: T) T {
        return (struct {
            fn log2Fn(item: T) T {
                return @log2(item);
            }
        }).log2Fn;
    }

    /// Compute log base 10 on each item .
    pub fn log10(comptime T: type) fn (item: T) T {
        return (struct {
            fn log10Fn(item: T) T {
                return @log10(item);
            }
        }).log10Fn;
    }

    /// Compute the sinus value of each item.
    pub fn sin(comptime T: type) fn (item: T) T {
        return (struct {
            fn sinFn(item: T) T {
                return @sin(item);
            }
        }).sinFn;
    }

    /// Compute the cosinus value of each item.
    pub fn cos(comptime T: type) fn (item: T) T {
        return (struct {
            fn cosFn(item: T) T {
                return @cos(item);
            }
        }).cosFn;
    }

    /// Compute the tangent value of each item.
    pub fn tan(comptime T: type) fn (item: T) T {
        return (struct {
            fn tanFn(item: T) T {
                return @tan(item);
            }
        }).tanFn;
    }

    /// Compute the square root of each item.
    pub fn sqrt(comptime T: type) fn (item: T) T {
        return (struct {
            fn sqrtFn(item: T) T {
                return @sqrt(item);
            }
        }).sqrtFn;
    }

    /// Compute largest integral value not greater than given floating point number on each item.
    pub fn floor(comptime T: type) fn (item: T) T {
        return (struct {
            fn floorFn(item: T) T {
                return @floor(item);
            }
        }).floorFn;
    }

    /// Compute smallest integral value not less than given floating point number on each item.
    pub fn ceil(comptime T: type) fn (item: T) T {
        return (struct {
            fn ceilFn(item: T) T {
                return @ceil(item);
            }
        }).ceilFn;
    }

    /// Round each floating point item  to an integer, towards zero.
    pub fn trunc(comptime T: type) fn (item: T) T {
        return (struct {
            fn truncFn(item: T) T {
                return @trunc(item);
            }
        }).truncFn;
    }

    /// Strip item of all but one field supplied by args. The field type must also be provided.
    pub fn takeField(comptime T: type, comptime field: meta.FieldEnum(T)) fn (item: T) meta.FieldType(T, field) {
        return (struct {
            fn takeField(item: T) meta.FieldType(T, field) {
                return @field(item, @tagName(field));
            }
        }).takeField;
    }
};

/// Set of common reducers.
pub const CommonReducers = struct {
    /// Sum all numbers.
    pub fn sum(comptime T: type) fn (prev: T, curr: T) T {
        return (struct {
            fn apply(prev: T, curr: T) T {
                return prev + curr;
            }
        }).apply;
    }

    /// Compute the product of all numbers.
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
            fn evenFn(item: T) bool {
                return @mod(item, 2) == 0;
            }
        }).evenFn;
    }

    /// Evalatues `true` if item is odd.
    pub fn odd(comptime T: type) fn (item: T) bool {
        return (struct {
            fn oddFn(item: T) bool {
                return @mod(item, 2) != 0;
            }
        }).oddFn;
    }

    /// Evalatues `true` if `item == 0`.
    pub fn zero(comptime T: type) fn (item: T) bool {
        return (struct {
            fn zeroFn(item: T) bool {
                return item == 0;
            }
        }).zeroFn;
    }

    /// Evalatues `true` if `item != 0`.
    pub fn notZero(comptime T: type) fn (item: T) bool {
        return (struct {
            fn notZeroFn(item: T) bool {
                return item != 0;
            }
        }).notZeroFn;
    }

    /// Evalatues `true` if `item` equals that of `n`.
    /// `n` must be supplied in `args`.
    pub fn eq(comptime T: type) fn (item: T, n: T) bool {
        return (struct {
            fn eqFn(item: T, n: T) bool {
                return meta.eql(item, n);
            }
        }).eqFn;
    }

    /// Evalatues `true` if `item` does not equal that of `n`.
    /// `n` must be supplied in `args`.
    pub fn neq(comptime T: type) fn (item: T, n: T) bool {
        return (struct {
            fn neqFn(item: T, n: T) bool {
                return !meta.eql(item, n);
            }
        }).neqFn;
    }

    /// Evalatues `true` if `item` is `true`.
    pub fn truthy(comptime T: type) fn (item: T) bool {
        return (struct {
            fn truthyFn(item: T) bool {
                if (item) {
                    return true;
                }

                return false;
            }
        }).truthyFn;
    }

    /// Evalatues `true` if `item` is `false`.
    pub fn falsy(comptime T: type) fn (item: T) bool {
        return (struct {
            fn falsyFn(item: T) bool {
                if (item) {
                    return false;
                }

                return true;
            }
        }).falsyFn;
    }

    /// Evalatues `true` if `item` is greater than 0.
    pub fn pos(comptime T: type) fn (item: T) bool {
        return (struct {
            fn posFn(item: T) bool {
                return item > 0;
            }
        }).posFn;
    }

    /// Evalatues `true` if `item` is less than 0.
    pub fn neg(comptime T: type) fn (item: T) bool {
        return (struct {
            fn negFn(item: T) bool {
                return item < 0;
            }
        }).negFn;
    }

    /// Evalatues `true` if field supplied in args of `item` equals that of `value`.
    pub fn fieldEq(comptime T: type, comptime field: meta.FieldEnum(T)) fn (item: T, value: meta.FieldType(T, field)) bool {
        return (struct {
            fn fieldEqFn(item: T, value: meta.FieldType(T, field)) bool {
                return meta.eql(@field(item, @tagName(field)), value);
            }
        }).fieldEqFn;
    }
};
