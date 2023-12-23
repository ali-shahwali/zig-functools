const std = @import("std");
const functools = @import("functools");
const testing = std.testing;
const CommonMappers = functools.CommonMappers;
const CommonReducers = functools.CommonReducers;
const CommonPredicates = functools.CommonPredicates;

const Point2D = struct {
    x: i32,
    y: i32,
};

fn sumPointY(prev: i32, curr: Point2D) i32 {
    return prev + curr.y;
}

test "test map on slice of type i32 to slice of type i64" {
    const allocator = testing.allocator;

    const slice = [3]i32{ 1, 2, 3 };
    const incremented = try functools.mapSlice(allocator, i32, &slice, (struct {
        fn inci64(n: i32) i64 {
            return @as(i64, n + 1);
        }
    }).inci64, .{});
    defer allocator.free(incremented);

    try testing.expectEqual(incremented[0], 2);
    try testing.expectEqual(incremented[1], 3);
    try testing.expectEqual(incremented[2], 4);
}

test "test map slice on i32 slice without args " {
    const allocator = testing.allocator;

    const slice = [3]i32{ 1, 2, 3 };
    const incremented = try functools.mapSlice(
        allocator,
        i32,
        &slice,
        CommonMappers.inc(i32),
        .{},
    );
    defer allocator.free(incremented);

    try testing.expectEqual(incremented[0], 2);
    try testing.expectEqual(incremented[1], 3);
    try testing.expectEqual(incremented[2], 4);
}

test "test map slice on i32 slice with args" {
    const allocator = testing.allocator;
    const slice = [3]i32{ 1, 2, 3 };
    const added: []i32 = try functools.mapSlice(
        allocator,
        i32,
        &slice,
        CommonMappers.add(i32),
        .{@as(i32, 1)},
    );
    defer allocator.free(added);

    try testing.expectEqual(added[0], 2);
    try testing.expectEqual(added[1], 3);
    try testing.expectEqual(added[2], 4);
}

test "test map slice on f32 slice with trunc" {
    const allocator = testing.allocator;
    const slice = [4]f32{ 1.9, 2.01, 3.999, 4.5 };
    const trunced: []f32 = try functools.mapSlice(
        allocator,
        f32,
        &slice,
        CommonMappers.trunc(f32),
        .{},
    );
    defer allocator.free(trunced);

    try testing.expectEqual(trunced[0], 1);
    try testing.expectEqual(trunced[1], 2);
    try testing.expectEqual(trunced[2], 3);
    try testing.expectEqual(trunced[3], 4);
}

test "test map slice on Point2D slice with takeField mapper" {
    const allocator = testing.allocator;
    const slice = [3]Point2D{ .{
        .x = 1,
        .y = 2,
    }, .{
        .x = 2,
        .y = 3,
    }, .{
        .x = 3,
        .y = 4,
    } };
    const x_coords: []i32 = try functools.mapSlice(
        allocator,
        Point2D,
        &slice,
        CommonMappers.takeField(Point2D, i32),
        .{"x"},
    );
    defer allocator.free(x_coords);

    try testing.expectEqual(x_coords[0], 1);
    try testing.expectEqual(x_coords[1], 2);
    try testing.expectEqual(x_coords[2], 3);
}

test "test reduce slice on i32 slice" {
    const slice = [3]i32{ 1, 2, 3 };
    const result = try functools.reduceSlice(
        i32,
        i32,
        &slice,
        CommonReducers.sum(i32),
        .{},
        0,
    );

    try testing.expectEqual(result, 6);
}

test "test reduce struct field" {
    const slice = [3]Point2D{ .{
        .x = 1,
        .y = 2,
    }, .{
        .x = 2,
        .y = 3,
    }, .{
        .x = 3,
        .y = 4,
    } };
    const result = try functools.reduceSlice(Point2D, i32, &slice, sumPointY, .{}, 0);

    try testing.expectEqual(result, 9);
}

test "test filter on i32 slice" {
    const slice = [5]i32{ 1, 2, 3, 4, 5 };
    const allocator = testing.allocator;
    const even = try functools.filterSlice(
        allocator,
        i32,
        &slice,
        CommonPredicates.even(i32),
        .{},
    );
    defer allocator.free(even);

    try testing.expectEqual(even[0], 2);
    try testing.expectEqual(even[1], 4);
    try testing.expectEqual(even.len, 2);
}

test "test some on i32 slice" {
    const slice = [3]i32{ 1, 3, 5 };
    const some_even = try functools.someSlice(
        i32,
        &slice,
        CommonPredicates.even(i32),
        .{},
    );

    try testing.expect(!some_even);
}

fn orthogonal(p1: Point2D, p2: Point2D) bool {
    return (p1.x * p2.x + p1.y * p2.y) == 0;
}

test "test some on Point2D slice" {
    const slice = [3]Point2D{
        .{
            .x = 5,
            .y = 2,
        },
        .{
            .x = 1,
            .y = 3,
        },
        // This one is orthogonal to (1, 0)
        .{
            .x = 0,
            .y = 4,
        },
    };
    const e_x = Point2D{
        .x = 1,
        .y = 0,
    };
    const some_orthogonal = try functools.someSlice(Point2D, &slice, orthogonal, .{e_x});

    try testing.expect(some_orthogonal);
}

test "test every on Point2D slice" {
    const slice = [3]Point2D{
        .{
            .x = 0,
            .y = 1,
        },
        .{
            .x = 0,
            .y = 3,
        },
        // This one is not orthogonal to (1, 0)
        .{
            .x = 1,
            .y = 4,
        },
    };
    const e_x = Point2D{
        .x = 1,
        .y = 0,
    };
    const every_orthogonal = try functools.everySlice(Point2D, &slice, orthogonal, .{e_x});

    try testing.expect(!every_orthogonal);
}

test "test wrong param type error" {
    const allocator = testing.allocator;

    const slice = [3]i64{ 1, 2, 3 };
    _ = functools.mapSlice(
        allocator,
        i64,
        &slice,
        CommonMappers.inc(i32),
        .{},
    ) catch |err| {
        try testing.expect(err == functools.FunctoolTypeError.InvalidParamType);
    };
}
