# Reduce
Reduce is also a very common and useful operation. The idea behind reducing is to take a sequence and essentially boil it down (reduce it) to a single value.

**Reduce slice of integers to the sum of all elements**

```zig
test "test reduce slice on i32 slice" {
    const slice = [_]i32{ 1, 2, 3 };
    const result = try functools.reduceSlice(
        i32, // Slice type
        i32, // Return type
        &slice,
        CommonReducers.sum(i32),
        .{},
        0,
    );

    try testing.expectEqual(result, 6);
}
```
Writing a reducer function is slightly different than writing a mapping function. For one, we need to keep track of the accumulator, and as such it needs to be a parameter to the function. We can look at `CommonReducers.sum` to get a better understanding.
```zig{6-8}
    /// Sum all numbers in slice.
    pub fn sum(comptime T: type) fn (prev: T, curr: T) T {
        return (struct {
            // 'prev' is the variable containing the accumulated value so far
            // 'curr' is the current value we are looping over
            fn apply(prev: T, curr: T) T {
                return prev + curr;
            }
        }).apply;
    }

```
Now, if we wanted to write our own reducer for the `Point2D` struct to sum all y-coordinates, we could do the following.
```zig
fn sumPointY(prev: i32, curr: Point2D) i32 {
    return prev + curr.y;
}

test "test reduce struct field" {
    const slice = [_]Point2D{ .{ .x = 1, .y = 2 }, .{ .x = 2, .y = 3 }, .{ .x = 3, .y = 4 } };
    const result = try functools.reduceSlice(
        Point2D,
        i32,
        &slice,
        sumPointY,
        .{},
        0,
    );

    try testing.expectEqual(result, 9);
}
```
### Why reduce?
Similar to map, we are abstracting away a common programming pattern, that of looping and accumulating.