# Core API

## mapAllocSlice

- **Type**

  ```zig
  fn mapAllocSlice(allocator: Allocator, comptime func: anytype, slice: []const typed.ParamType(func, 0), args: anytype) ![]typed.ReturnType(func)
  ```

- **Documentation**

  Map over slice to new allocated slice using function `func` on each element of `slice`. Additionally supply some arguments to `func`. Consumer of function must make sure to free returned slice.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/map.zig){target="_self"}**

## mapSlice

- **Type**

  ```zig
  fn mapSlice(comptime func: anytype, slice: []typed.ParamType(func, 0), args: anytype) void
  ```

- **Documentation**

  Map over mutable slice using function `func` on each element of `slice`. Additionally supply some arguments to `func`. Does not allocate new memory and instead assigns mapped values in place.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/map.zig){target="_self"}**

## mapArrayList

- **Type**

  ```zig
  fn mapArrayList(comptime func: anytype, arr: ArrayList(typed.ParamType(func, 0)), args: anytype) void
  ```

- **Documentation**

  Map over array list using function `func` on each element of `slice`. Additionally supply some arguments to `func`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/map.zig){target="_self"}**

## mapAllocArrayList

- **Type**

  ```zig
  fn mapAllocArrayList(allocator: Allocator, comptime func: anytype, arr: ArrayList(typed.ParamType(func, 0)), args: anytype) !ArrayList(typed.ReturnType(func))
  ```

- **Documentation**

  Map over array list using function `func` on each element of `arr`, returns a new allocated array list with mapped elements. Additionally supply some arguments to `func`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/map.zig){target="_self"}**

## reduceSlice

- **Type**

  ```zig
  fn reduceSlice(comptime reducer: anytype, slice: []const typed.ParamType(reducer, 1), args: anytype, initial_value: typed.ReturnType(reducer)) typed.ReturnType(reducer)
  ```

- **Documentation**

  Reduce slice using function `reducer` with initial value to reduce from. Additionally supply some arguments to `func`. Supply an initial value to reduce from.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/reduce.zig){target="_self"}**

## reduceArrayList

- **Type**

  ```zig
  fn reduceArrayList(comptime reducer: anytype, arr: ArrayList(typed.ParamType(reducer, 1)), args: anytype, initial_value: typed.ReturnType(reducer)) typed.ReturnType(reducer)
  ```

- **Documentation**

  Reduce array list using function `func`. Additionally supply some arguments to `func` and an initial value to reduce from. Supply an initial value to reduce from.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/reduce.zig){target="_self"}**

## filterSlice

- **Type**

  ```zig
  fn filterSlice(allocator: Allocator, comptime pred: anytype, slice: []const typed.ParamType(pred, 0), args: anytype) ![]typed.ParamType(pred, 0)
  ```

- **Documentation**

  Create new slice filtered from `slice` using function `pred` as predicate. Additionally supply some arguments to `pred`. Consumer must make sure to free returned slice.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/filter.zig){target="_self"}**

## filterArrayList

- **Type**

  ```zig
  fn filterArrayList(allocator: Allocator, comptime pred: anytype, arr: ArrayList(typed.ParamType(pred, 0)), args: anytype) !ArrayList(typed.ParamType(pred, 0))
  ```

- **Documentation**

  Create new array list filtered from `arr` using function `pred` as predicate. Additionally supply some arguments to `pred`. Consumer must make sure to free returned array list.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/filter.zig){target="_self"}**

## someSlice

- **Type**

  ```zig
  fn someSlice(comptime pred: anytype, slice: []const typed.ParamType(pred, 0), args: anytype) bool
  ```

- **Documentation**

  Returns true if `slice` contains an item that passes the predicate specified by `pred` Additionally supply some arguments to `pred`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/some.zig){target="_self"}**

## someArrayList

- **Type**

  ```zig
  fn someArrayList(comptime pred: anytype, arr: ArrayList(typed.ParamType(pred, 0)), args: anytype) bool
  ```

- **Documentation**

  Returns true if array list contains an item that passes the predicate specified by `pred` Additionally supply some arguments to `pred`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/some.zig){target="_self"}**

## everySlice

- **Type**

  ```zig
  fn everySlice(comptime pred: anytype, slice: []const typed.ParamType(pred, 0), args: anytype) bool
  ```

- **Documentation**

  Returns true if predicate defined by `pred` is true for every element in `slice`. Additionally supply some arguments to `pred`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/every.zig){target="_self"}**

## everyArrayList

- **Type**

  ```zig
  fn everyArrayList(comptime pred: anytype, arr: ArrayList(typed.ParamType(pred, 0)), args: anytype) bool
  ```

- **Documentation**

  Returns true if predicate defined by `pred` is true for every item in array list. Additionally supply some arguments to `pred`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/every.zig){target="_self"}**

## findSlice

- **Type**

  ```zig
  fn findSlice(comptime pred: anytype, slice: []const typed.ParamType(pred, 0), args: anytype) ?typed.ParamType(pred, 0)
  ```

- **Documentation**

  Find and retrieve first item that predicate `pred` evaluates to `true` in slice. Additionally supply some arguments to `pred`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/find.zig){target="_self"}**

## findArrayList

- **Type**

  ```zig
  fn findArrayList(comptime pred: anytype, arr: ArrayList(typed.ParamType(pred, 0)), args: anytype) ?typed.ParamType(pred, 0)
  ```

- **Documentation**

  Find and retrieve first item that predicate `pred` evaluates to true in array list. Additionally supply some arguments to `pred`.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/core/find.zig){target="_self"}**
