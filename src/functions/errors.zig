const testing = @import("std").testing;
const mapSlice = @import("map.zig").mapSlice;
const CommonMappers = @import("../common.zig").CommonMappers;

pub const FunctoolTypeError = error{
    InvalidParamType,
    InvalidReturnType,
};

test "test wrong param type error" {
    const allocator = testing.allocator;

    const slice = [_]i64{ 1, 2, 3 };
    _ = mapSlice(
        allocator,
        i64,
        &slice,
        CommonMappers.inc(i32),
        .{},
    ) catch |err| {
        try testing.expect(err == FunctoolTypeError.InvalidParamType);
    };
}
