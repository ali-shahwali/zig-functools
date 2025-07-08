# Zig Functools

A Zig library that provides functional programming tools such as map, reduce and filter.

## Add it to your project

Add the `.functools` dependency to your `build.zig.zon`.

```sh
$ zig fetch --save git+https://github.com/ali-shahwali/zig-functools
```

Add this to your `build.zig` inside the `build` function.

```zig
const functools = b.dependency("functools", .{
        .target = target,
        .optimize = optimize,
    });
exe.root_module.addImport("functools", functools.module("functools"));
// Or, if you are building a library
// lib.root_module.addImport("functools", functools.module("functools"));
```

The library can now be imported as a module.

```zig
const functools = @import("functools");
```

## Examples
The documentation contains some examples. The tests are also good examples of how to use the library, below are some simple examples from the tests. <br> <br>
**Map over slice and increment each element.**

```zig
test "test map mutable slice on i32 slice without args" {
    const allocator = testing.allocator;

    var slice = try range.rangeSlice(allocator, i32, 3);
    defer allocator.free(slice);

    map(mappers.inc(i32), slice);

    try testing.expectEqualSlices(i32, slice, &[_]i32{ 1, 2, 3 });
}
```

**Filter even integers.**

```zig
test "test filter on i32 slice" {
    const allocator = testing.allocator;
    const slice = try rangeSlice(allocator, i32, 6);
    defer allocator.free(slice);
    const even = try filter(
        allocator,
        predicates.even(i32),
        slice,
    );
    defer allocator.free(even);

    try testing.expectEqualSlices(i32, even, &[_]i32{ 0, 2, 4 });
}
```

**Check that every vector is orthogonal to the x basis vector.**

```zig
const Point2D = struct {
    x: i32,
    y: i32,
};

fn orthogonal(p2: Point2D) fn (Point2D) bool {
    return (struct {
        fn e(p1: Point2D) bool {
            return (p1.x * p2.x + p1.y * p2.y) == 0;
        }
    }).e;
}

test "test every on Point2D slice" {
    const allocator = testing.allocator;
    const slice = try allocator.alloc(Point2D, 3);
    @memcpy(slice, &[_]Point2D{
        .{ .x = 0, .y = 1 },
        .{ .x = 0, .y = 3 },
        // This one is not orthogonal to (1, 0)
        .{ .x = 1, .y = 4 },
    });
    defer allocator.free(slice);

    const e_x = Point2D{ .x = 1, .y = 0 };
    const every_orthogonal = every(orthogonal(e_x), slice);

    try testing.expect(!every_orthogonal);
}
```
