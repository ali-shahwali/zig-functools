# Zig Functools
A Zig library that provides functional programming tools such as map, reduce and filter.
### Add it to your project
Add this to `build.zig.zon`
```zig
.{
    .name = "Your project name",
    .version = "x.y.z",
    .dependencies = .{
        .functools = .{
            .url = "https://github.com/ali-shahwali/zig-functools/archive/refs/tags/v0.0.1.tar.gz",
            .hash = "12207e0d856ef9cd7f84926ddcd6e1603d75ed2c6f0ed24444ebe2856679629e9055",
        },
    },
}
```
Add this to your `build.zig` inside the `build` function.
```zig
const functools = b.dependency("functools", .{
        .target = target,
        .optimize = optimize,
    });
exe.addModule("functools", functools.module("functools"));
```
The library can now be imported as a module with
```zig
const functools = @import("functools");
```
### Examples
The [tests](./src/tests.zig) are some examples of how to use the library, below are some quick examples from the tests to give an idea. <br>
**Map over slice and increment each element.**
```zig
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
```
**Filter even integers.**
```zig
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
```
**Check that every vector is orthogonal to the x basis vector.**
```zig
fn orthogonal(p1: Point2D, p2: Point2D) bool {
    return (p1.x * p2.x + p1.y * p2.y) == 0;
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
```