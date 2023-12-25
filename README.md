# Zig Functools

A Zig library that provides functional programming tools such as map, reduce and filter.

## Add it to your project

Add the `.functools` dependency to your `build.zig.zon`.

```zig
.{
    .name = "Your project name",
    .version = "x.y.z",
    .dependencies = .{
        .functools = .{
            .url = "https://github.com/ali-shahwali/zig-functools/archive/refs/tags/v0.0.2.tar.gz",
            .hash = "1220301a11b35299c1dd7c6806e1a1f7d2a485eecfa3aa3999ecaba990b06d13f534",
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
// Or, if you are building a library
// lib.addModule("functools", functools.module("functools"));
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
    var slice = [3]i32{ 1, 2, 3 };
    functools.mapMutSlice(
        i32,
        &slice,
        functools.CommonMappers.inc(i32),
        .{},
    );

    try testing.expectEqualSlices(i32, &slice, &[_]i32{ 2, 3, 4 });
}
```

**Filter even integers.**

```zig
test "test filter on i32 slice" {
    const slice = [_]i32{ 1, 2, 3, 4, 5 };
    const allocator = testing.allocator;
    const even = try functools.filterSlice(
        allocator,
        i32,
        &slice,
        functools.CommonPredicates.even(i32),
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
**Thread functions**
```zig
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
```