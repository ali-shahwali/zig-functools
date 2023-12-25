# Some and Every
We can use the function `someSlice` to check that there exists _some_ element in a slice that satisfies a condition. Similarly we can use the function `everySlice` to check that _every_ element in a slice satisfies a condition.

**Check that some Point2D is orthogonal to the x basis vector**
```zig
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
```

**Check that every Point2D is orthogonal to the x basis vector**

```zig
test "test every on Point2D slice" {
    const slice = [_]Point2D{
        .{ .x = 0, .y = 1 },
        .{ .x = 0, .y = 3 },
        .{ .x = 1, .y = 4 }, // This one is not orthogonal to (1, 0)
    };
    const e_x = Point2D{ .x = 1, .y = 0 };
    const every_orthogonal = try functools.everySlice(Point2D, &slice, orthogonal, .{e_x});

    try testing.expect(!every_orthogonal);
}
```