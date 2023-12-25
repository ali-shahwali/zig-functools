# Map
Map is one of the more common and useful operations one frequently does. The basic idea is to perform some mapping of one value to another for each element in a sequence. We specify the mapping with a function.

**Increment all integers in a slice**

```zig{3-8}
test "test map mutable slice on i32 slice without args" {
    var slice = [3]i32{ 1, 2, 3 };
    functools.mapMutSlice(
        i32,                                // Specify type
        &slice,                             // The slice we want to map over
        functools.CommonMappers.inc(i32),   // Maps i32 n -> i32 n + 1
        .{},                                // Some additional args if needed
    );

    try testing.expectEqualSlices(i32, &slice, &[_]i32{ 2, 3, 4 });
}
```
::: details
`functools.CommonMappers`, `functools.CommonReducers`, `functools.CommonPredicates` are collections of functions that come with the library, it contains many common functions that one uses when programming functionally.
:::

In most cases we preserve the type when we map, however there are cases when we want to map from one type to another. However, to do this we need to allocate new memory and thus can not use `mapMutSlice`.

**Create 2D points from integers**
```zig
const Point2D = struct {
    x: i32,
    y: i32,
};

test "test map i32 slice to Point2D slice" {
    const allocator = testing.allocator;
    const slice = [_]i32{ 1, 2, 3 };
    const points: []Point2D = try functools.mapSlice(
        allocator,
        i32,
        &slice,
        // We can use an anonymous struct to quickly define a mapper
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
```


### Why map?
A lot of code we write can simply be boiled down to looping over some sequence and manipulating the data at the current index. This essentially is the same thing as mapping, map is useful because it abstracts a common programming pattern that can be overly verbose.