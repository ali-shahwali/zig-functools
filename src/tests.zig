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

    try testing.expectEqualSlices(i64, incremented, &[_]i64{ 2, 3, 4 });
}

test "test map mutable slice on i32 slice without args" {
    var slice = [_]i32{ 1, 2, 3 };
    try functools.mapMutSlice(
        i32,
        &slice,
        CommonMappers.inc(i32),
        .{},
    );

    try testing.expectEqualSlices(i32, &slice, &[_]i32{ 2, 3, 4 });
}

test "test map slice on i32 slice with args" {
    const allocator = testing.allocator;
    const slice = [_]i32{ 1, 2, 3 };
    const added: []i32 = try functools.mapSlice(
        allocator,
        i32,
        &slice,
        CommonMappers.add(i32),
        .{@as(i32, 1)},
    );
    defer allocator.free(added);

    try testing.expectEqualSlices(i32, added, &[_]i32{ 2, 3, 4 });
}

test "test map slice on f32 slice with trunc" {
    const allocator = testing.allocator;
    const slice = [_]f32{ 1.9, 2.01, 3.999, 4.5 };
    const trunced: []f32 = try functools.mapSlice(
        allocator,
        f32,
        &slice,
        CommonMappers.trunc(f32),
        .{},
    );
    defer allocator.free(trunced);

    try testing.expectEqualSlices(f32, trunced, &[_]f32{ 1, 2, 3, 4 });
}

test "test map slice on Point2D slice with takeField mapper" {
    const allocator = testing.allocator;
    const slice = [_]Point2D{ .{
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

    try testing.expectEqualSlices(i32, x_coords, &[_]i32{ 1, 2, 3 });
}

test "test map i32 slice to Point2D slice" {
    const allocator = testing.allocator;
    const slice = [_]i32{ 1, 2, 3 };
    const points: []Point2D = try functools.mapSlice(
        allocator,
        i32,
        &slice,
        (struct {
            fn toPoint2D(n: i32) Point2D {
                return Point2D{
                    .x = n,
                    .y = 0,
                };
            }
        }).toPoint2D,
        .{},
    );
    defer allocator.free(points);

    try testing.expectEqualSlices(Point2D, points, &[_]Point2D{
        .{ .x = 1, .y = 0 },
        .{ .x = 2, .y = 0 },
        .{ .x = 3, .y = 0 },
    });
}

test "test reduce slice on i32 slice" {
    const slice = [_]i32{ 1, 2, 3 };
    const result = try functools.reduceSlice(
        i32,
        &slice,
        CommonReducers.sum(i32),
        .{},
        0,
    );

    try testing.expectEqual(result, 6);
}

test "test reduce struct field" {
    const slice = [_]Point2D{ .{ .x = 1, .y = 2 }, .{ .x = 2, .y = 3 }, .{ .x = 3, .y = 4 } };
    const result = try functools.reduceSlice(
        Point2D,
        &slice,
        sumPointY,
        .{},
        0,
    );

    try testing.expectEqual(result, 9);
}

test "test filter on i32 slice" {
    const slice = [_]i32{ 1, 2, 3, 4, 5 };
    const allocator = testing.allocator;
    const even = try functools.filterSlice(
        allocator,
        i32,
        &slice,
        CommonPredicates.even(i32),
        .{},
    );
    defer allocator.free(even);

    try testing.expectEqualSlices(i32, even, &[_]i32{ 2, 4 });
}

test "test filter on Point2D slice" {
    const slice = [_]Point2D{ .{ .x = 2, .y = 2 }, .{ .x = 0, .y = 3 }, .{ .x = 2, .y = 4 } };
    const allocator = testing.allocator;
    const x_coord_eq_2 = try functools.filterSlice(
        allocator,
        Point2D,
        &slice,
        CommonPredicates.fieldEq(Point2D, i32),
        .{ "x", 2 },
    );
    defer allocator.free(x_coord_eq_2);

    try testing.expectEqualSlices(Point2D, x_coord_eq_2, &[_]Point2D{
        .{ .x = 2, .y = 2 },
        .{ .x = 2, .y = 4 },
    });
}

test "test some on i32 slice" {
    const slice = [_]i32{ 1, 3, 5 };
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
    const slice = [_]Point2D{
        .{ .x = 5, .y = 2 },
        .{ .x = 1, .y = 3 },
        .{ .x = 0, .y = 4 }, // This one is orthogonal to (1, 0)
    };

    const e_x = Point2D{ .x = 1, .y = 0 };
    const some_orthogonal = try functools.someSlice(Point2D, &slice, orthogonal, .{e_x});

    try testing.expect(some_orthogonal);
}

test "test every on Point2D slice" {
    const slice = [_]Point2D{
        .{ .x = 0, .y = 1 },
        .{ .x = 0, .y = 3 },
        // This one is not orthogonal to (1, 0)
        .{ .x = 1, .y = 4 },
    };
    const e_x = Point2D{ .x = 1, .y = 0 };
    const every_orthogonal = try functools.everySlice(Point2D, &slice, orthogonal, .{e_x});

    try testing.expect(!every_orthogonal);
}

test "test takeNth" {
    const allocator = testing.allocator;

    const slice = [_]i32{ 0, 1, 2, 3, 4, 5 };
    const nth = try functools.takeNth(allocator, i32, &slice, 2);
    defer allocator.free(nth);

    try testing.expectEqualSlices(i32, nth, &[_]i32{ 0, 2, 4 });
}

test "test wrong param type error" {
    const allocator = testing.allocator;

    const slice = [_]i64{ 1, 2, 3 };
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

test "test range slice" {
    const slice = functools.rangeSlice(i32, 4);
    try testing.expectEqualSlices(i32, slice, &[_]i32{ 0, 1, 2, 3 });
}

test "test find slice" {
    const slice = [_]Point2D{
        .{
            .x = 8,
            .y = 1,
        },
        .{
            .x = 4,
            .y = 3,
        },
        .{
            .x = 2,
            .y = 4,
        },
    };

    const found = try functools.findSlice(
        Point2D,
        &slice,
        CommonPredicates.fieldEq(Point2D, i32),
        .{ "x", 2 },
    );

    try testing.expect(found != null);
    try testing.expectEqual(found.?, slice[2]);

    const not_found = try functools.findSlice(
        Point2D,
        &slice,
        CommonPredicates.fieldEq(Point2D, i32),
        .{ "y", 5 },
    );

    try testing.expect(not_found == null);
}

test "test threading map->filter->reduce" {
    const allocator = testing.allocator;
    const slice = functools.rangeSlice(i32, 10);

    const result = try functools.Thread(i32)
        .init(allocator, slice)
        .map(CommonMappers.inc(i32), .{})
        .filter(CommonPredicates.even(i32), .{})
        .reduce(CommonReducers.sum(i32), .{}, 0);

    try testing.expectEqual(result, 30);
}

test "test threading map->filter" {
    const allocator = testing.allocator;
    const slice = functools.rangeSlice(i32, 10);

    const result = try functools.Thread(i32)
        .init(allocator, slice)
        .map(CommonMappers.inc(i32), .{})
        .filter(CommonPredicates.even(i32), .{})
        .result();

    defer allocator.free(result);

    try testing.expectEqualSlices(i32, &[_]i32{ 2, 4, 6, 8, 10 }, result);
}

test "test threading map->filter->some" {
    const allocator = testing.allocator;
    const slice = functools.rangeSlice(i32, 10);

    const some_even = try functools.Thread(i32)
        .init(allocator, slice)
        .map(CommonMappers.inc(i32), .{})
        .filter(CommonPredicates.odd(i32), .{})
        .some(CommonPredicates.even(i32), .{});

    try testing.expect(!some_even);
}

test "test threading map->filter->every" {
    const allocator = testing.allocator;
    const slice = functools.rangeSlice(i32, 10);

    const every_odd = try functools.Thread(i32)
        .init(allocator, slice)
        .map(CommonMappers.inc(i32), .{})
        .filter(CommonPredicates.odd(i32), .{})
        .every(CommonPredicates.odd(i32), .{});

    try testing.expect(every_odd);
}

test "test threading map->filter->find" {
    const allocator = testing.allocator;
    const slice = functools.rangeSlice(i32, 10);

    const nine = try functools.Thread(i32)
        .init(allocator, slice)
        .map(CommonMappers.inc(i32), .{})
        .filter(CommonPredicates.odd(i32), .{})
        .find(CommonPredicates.eq(i32), .{@as(i32, 9)});

    try testing.expect(nine != null);
    try testing.expect(nine.? == 9);
}
