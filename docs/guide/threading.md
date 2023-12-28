# Threading
::: warning
This is an unstable feature and the API is very likely to change over time.
:::

When talking about threading in a functional programming context we are referring to the idea of chaining together multiple functional calls and piping in the result from the previous function in to the next. The functool library provides a way of doing this.

## Examples

**Increment all numbers in a slice, then filter even ones**

```zig
test "test threading map->filter" {
    const allocator = testing.allocator;
    // slice = {0, 1, 2, ..., 9}
    const slice = try util.rangeSlice(allocator, i32, 10);
    defer allocator.free(slice);

    const result = try Thread(i32)
        .init(allocator, slice)
        .map(CommonMappers.inc(i32), .{})
        .filter(CommonPredicates.even(i32), .{})
        .result();

    defer allocator.free(result);

    try testing.expectEqualSlices(i32, &[_]i32{ 2, 4, 6, 8, 10 }, result);
}
```

**Increment all numbers in a slice, then filter even ones, then reduce down the sum of all elements**
```zig
test "test threading map->filter->reduce" {
    const allocator = testing.allocator;
    const slice = try util.rangeSlice(allocator, i32, 10);
    defer allocator.free(slice);

    const result = try Thread(i32)
        .init(allocator, slice)
        .map(CommonMappers.inc(i32), .{})
        .filter(CommonPredicates.even(i32), .{})
        .reduce(CommonReducers.sum(i32), .{}, 0);

    try testing.expectEqual(result, 30);
}
```

**Increment all numbers in a slice, then filter odd ones, then check if there is some even number**
```zig
test "test threading map->filter->some" {
    const allocator = testing.allocator;
    const slice = try util.rangeSlice(allocator, i32, 10);
    defer allocator.free(slice);

    const some_even = try Thread(i32)
        .init(allocator, slice)
        .map(CommonMappers.inc(i32), .{})
        .filter(CommonPredicates.odd(i32), .{})
        .some(CommonPredicates.even(i32), .{});

    try testing.expect(!some_even);
}
```
