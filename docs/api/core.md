# Core API

## mapSlice

- **Type**

  ```zig
  fn mapSlice(allocator: Allocator, comptime T: type, slice: []const T, comptime func: anytype, args: anytype) ![]@typeInfo(@TypeOf(func)).Fn.return_type.?
  ```

- **Documentation**

  Map over slice of type `T` to new allocated slice using function `func` on each element of `slice`. Additionally supply some arguments to `func`. Consumer of function must make sure to free returned slice.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/map.zig){target="_self"}**

## mapMutSlice

- **Type**

  ```zig
  fn mapMutSlice(comptime T: type, slice: []T, comptime func: anytype, args: anytype) void
  ```

- **Documentation**

  Map over mutable slice of type `T` using function `func` on each element of `slice`. Additionally supply some arguments to `func`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/map.zig){target="_self"}**

## mapArrayList

- **Type**

  ```zig
  fn mapArrayList(comptime T: type, arr: ArrayList(T), comptime func: anytype, args: anytype) void
  ```

- **Documentation**

  Map over array list of type `T` using function `func` on each element of `slice`. Additionally supply some arguments to `func`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/map.zig){target="_self"}**

## mapAllocArrayList

- **Type**

  ```zig
  fn mapAllocArrayList(allocator: Allocator, comptime T: type, arr: ArrayList(T), comptime func: anytype, args: anytype) !ArrayList(@typeInfo(@TypeOf(func)).Fn.return_type.?)
  ```

- **Documentation**

  Map over array list of type `T` using function `func` on each element of `arr`, returns a new allocated array list with mapped elements. Additionally supply some arguments to `func`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/map.zig){target="_self"}**

## reduceSlice

- **Type**

  ```zig
  fn reduceSlice(comptime T: type, slice: []const T, comptime func: anytype, args: anytype, initial_value: @typeInfo(@TypeOf(func)).Fn.return_type.?) @typeInfo(@TypeOf(func)).Fn.return_type.?
  ```

- **Documentation**

  Reduce slice of type `T` using function `func` with initial value to reduce from. Additionally supply some arguments to `func`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/reduce.zig){target="_self"}**

## reduceArrayList

- **Type**

  ```zig
  fn reduceArrayList(comptime T: type, arr: ArrayList(T), comptime func: anytype, args: anytype, initial_value: @typeInfo(@TypeOf(func)).Fn.return_type.?) @typeInfo(@TypeOf(func)).Fn.return_type.?
  ```

- **Documentation**

  Reduce array list of type `T` using function `func`. Additionally supply some arguments to `func` and an initial value to reduce from.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/reduce.zig){target="_self"}**

## filterSlice

- **Type**

  ```zig
  fn filterSlice(allocator: std.mem.Allocator, comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) ![]T
  ```

- **Documentation**

  Create new slice filtered from `slice` of type `T` using function `pred` as predicate. Additionally supply some arguments to `pred`. Consumer must make sure to free returned slice.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/filter.zig){target="_self"}**

## filterArrayList

- **Type**

  ```zig
  fn filterArrayList(allocator: Allocator, comptime T: type, arr: ArrayList(T), comptime pred: anytype, args: anytype) !ArrayList(T)
  ```

- **Documentation**

  Create new array list filtered from `arr` of type `T` using function `pred` as predicate. Additionally supply some arguments to `pred`. Consumer must make sure to free returned array list.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/filter.zig){target="_self"}**

## someSlice

- **Type**

  ```zig
  fn someSlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) bool
  ```

- **Documentation**

  Returns true if `slice` contains an item of type `T` that passes the predicate specified by `pred` Additionally supply some arguments to `pred`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/some.zig){target="_self"}**

## someArrayList

- **Type**

  ```zig
  fn someArrayList(comptime T: type, arr: ArrayList(T), comptime pred: anytype, args: anytype) bool
  ```

- **Documentation**

  Returns true if array list contains an item of type `T` that passes the predicate specified by `pred` Additionally supply some arguments to `pred`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/some.zig){target="_self"}**

## everySlice

- **Type**

  ```zig
  fn everySlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) bool
  ```

- **Documentation**

  Returns true if predicate defined by `pred` is true for every element in `slice` of type `T`. Additionally supply some arguments to `pred`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/every.zig){target="_self"}**

## everyArrayList

- **Type**

  ```zig
  fn everyArrayList(comptime T: type, arr: ArrayList(T), comptime pred: anytype, args: anytype) bool
  ```

- **Documentation**

  Returns true if predicate defined by `pred` is true for every item in array list of type `T`. Additionally supply some arguments to `pred`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/every.zig){target="_self"}**

## findSlice

- **Type**

  ```zig
  fn findSlice(comptime T: type, slice: []const T, comptime pred: anytype, args: anytype) ?T
  ```

- **Documentation**

  Find and retrieve first item that predicate `pred` evaluates to `true` in slice of type `T`. Additionally supply some arguments to `pred`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/find.zig){target="_self"}**

## findArrayList

- **Type**

  ```zig
  fn findArrayList(comptime T: type, arr: ArrayList(T), comptime pred: anytype, args: anytype) ?T
  ```

- **Documentation**

  Find and retrieve first item that predicate `pred` evaluates to true in array list of type `T`. Additionally supply some arguments to `pred`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/find.zig){target="_self"}**
