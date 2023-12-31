# Filter
The idea behind filter is to remove some elements from a sequence based on some condition (predicate), a condition can for example be, _"is a number even?"_ or _"does the struct field contain this value?"_. 

## Examples

**Filter even numbers**
```zig
test "test filter on i32 slice" {
    const slice = &[_]i32{ 1, 2, 3, 4, 5 };
    const allocator = testing.allocator;
    const even = try filterSlice(
        allocator,
        CommonPredicates.even(i32),
        slice,
        .{},
    );
    defer allocator.free(even);

    try testing.expectEqualSlices(i32, even, &[_]i32{ 2, 4 });
}
```
One particularly useful use case for filter is the previously mentioned scenario of filtering based on struct field values.

**Filter Point2D based on x coordinate value**
```zig
test "test filter on Point2D slice" {
    const slice = [_]Point2D{ .{ .x = 2, .y = 2 }, .{ .x = 0, .y = 3 }, .{ .x = 2, .y = 4 } };
    const allocator = testing.allocator;
    const x_coord_eq_2 = try filterSlice(
        allocator,
        CommonPredicates.fieldEq(Point2D, .x, 2),
        &slice,
        .{},
    );
    defer allocator.free(x_coord_eq_2);

    try testing.expectEqualSlices(Point2D, x_coord_eq_2, &[_]Point2D{
        .{ .x = 2, .y = 2 },
        .{ .x = 2, .y = 4 },
    });
}
```
## Why filter?
The use case for filter is much more obvious than that of map and reduce, being able to easily remove items from a sequence based on some condition is a powerful tool.
