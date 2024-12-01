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

## Documentation
The documentation can be found [here](https://ali-shahwali.github.io/zig-functools/).

## Examples
The documentation contains some examples. The tests are also good examples of how to use the library, below are some simple examples from the tests. <br> <br>
**Map over slice and increment each element.**

```zig
test "test map mutable slice on i32 slice without args" {
    const allocator = testing.allocator;

    var slice = try range.rangeSlice(allocator, i32, 3);
    defer allocator.free(slice);

    mapSlice(CommonMappers.inc(i32), slice, .{});

    try testing.expectEqualSlices(i32, slice, &[_]i32{ 1, 2, 3 });
}
```

**Filter even integers.**

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

**Check that every vector is orthogonal to the x basis vector.**

```zig
const Point2D = struct {
    x: i32,
    y: i32,
};

fn orthogonal(p1: Point2D, p2: Point2D) bool {
    return (p1.x * p2.x + p1.y * p2.y) == 0;
}

test "test every on Point2D slice" {
    const slice = &[_]Point2D{
        .{ .x = 0, .y = 1 },
        .{ .x = 0, .y = 3 },
        .{ .x = 1, .y = 4 }, // Not orthogonal to (1, 0)
    };
    const e_x = Point2D{ .x = 1, .y = 0 };
    const every_orthogonal = everySlice(orthogonal, slice, .{e_x});

    try testing.expect(!every_orthogonal);
}
```
**Thread functions**
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
