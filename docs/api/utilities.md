# Utilities API

## rangeArray

- **Type**

  ```zig
  fn rangeArray(comptime T: type, comptime n: usize) [n]T
  ```

- **Documentation**

  Returns an array of length `n` and type `T` where the elements start from 0 and go to n - 1.

  ```zig
  // Example
  const slice = functools.rangeSlice(i32, 4);
  try testing.expectEqualSlices(i32, slice, &[_]i32{ 0, 1, 2, 3 });
  ```

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/util/range.zig){target="_self"}**

## rangeSlice

- **Type**

  ```zig
  fn rangeSlice(allocator: Allocator, comptime T: type, n: usize) ![]T
  ```

- **Documentation**

  Returns an allocated slice of length `n` and type `T` where the elements start from 0 and go to n - 1.

  ```zig
  // Example
  const allocator = testing.allocator;
  const slice = try functools.rangeSlice(allocator, i32, 4);
  defer allocator.free(slice);
  try testing.expectEqualSlices(i32, slice, &[_]i32{ 0, 1, 2, 3 });
  ```

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/util/range.zig){target="_self"}**

## rangeArrayList

- **Type**

  ```zig
  fn rangeArrayList(allocator: Allocator, comptime T: type, n: usize) !ArrayList(T)
  ```

- **Documentation**

  Returns an `ArrayList(T)` of length `n` where the elements start from 0 and go to n - 1.

  ```zig
  // Example
  const allocator = testing.allocator;
  const arr = functools.rangeArrayList(allocator, i32, 4);
  try testing.expectEqualSlices(i32, arr.items, &[_]i32{ 0, 1, 2, 3 });
  ```

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/util/range.zig){target="_self"}**

## takeNth

- **Type**

  ```zig
  fn takeNth(allocator: Allocator, comptime T: type, slice: []const T, n: usize) ![]T
  ```

- **Documentation**

  Take every nth element in `slice` of type `T`. Consumer of function must make sure to free returned slice. A special case is n <= 0, in which case the same slice will be returned.

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/util/take.zig){target="_self"}**
