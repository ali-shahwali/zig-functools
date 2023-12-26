# Core API

## mapSlice
- **Type**

    ```zig
    fn mapSlice(allocator: Allocator, comptime T: type, slice: []const T, comptime func: anytype, args: anytype) ![]@typeInfo(@TypeOf(func)).Fn.return_type.?
    ```
- **Documentation**

    Map over slice of type `T` to new allocated slice using function `func` on each element of `slice`. Additionally supply some arguments to `func`. Consumer of function must make sure to free returned slice.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/functions/map.zig#L13){target="_self"}**

    


## mapMutSlice
- **Type**

    ```zig
    fn mapMutSlice(comptime T: type, slice: []T, comptime func: anytype, args: anytype) !void
    ```
- **Documentation**

    Map over mutable slice of type `T` using function `func` on each element of `slice`. Additionally supply some arguments to `func`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/functions/map.zig#L32){target="_self"}**


## reduceSlice
- **Type**

    ```zig
    pub fn reduceSlice(comptime T: type, slice: []const T, comptime func: anytype, args: anytype, initial_value: @typeInfo(@TypeOf(func)).Fn.return_type.?) !@typeInfo(@TypeOf(func)).Fn.return_type.?
    ```
- **Documentation**

    Reduce slice of type `T` using function `func` with initial value to reduce from. Additionally supply some arguments to `func`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/functions/reduce.zig#L10){target="_self"}**


## filterSlice
- **Type**

    ```zig
    fn filterSlice(allocator: std.mem.Allocator, comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) ![]T
    ```
- **Documentation**

    Create new slice filtered from `slice` of type `T` using function `pred` as predicate. Additionally supply some arguments to `pred`. Consumer must make sure to free returned slice.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/functions/filter.zig#L14){target="_self"}**

## someSlice
- **Type**

    ```zig
    fn someSlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) !bool
    ```
- **Documentation**

    Returns true if `slice` contains an item of type `T` that passes the predicate specified by `pred` Additionally supply some arguments to `pred`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/functions/some.zig#L12){target="_self"}**


## everySlice
- **Type**

    ```zig
    fn everySlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) !bool
    ```
- **Documentation**

    Returns true if predicate defined by `pred` is true for every element in `slice` of type `T`. Additionally supply some arguments to `pred`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/functions/every.zig#L10){target="_self"}**

## findSlice
- **Type**

    ```zig
    fn findSlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) !?T
    ```
- **Documentation**

    Find and retrieve first item that predicate `pred` evaluates to `true` in slice of type `T`. Additionally supply some arguments to `pred`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/functions/find.zig#L14){target="_self"}**