# Thread API

## Thread

- **Type**

  ```zig
  fn Thread(comptime T: type) type
  ```

- **Documentation**

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/thread.zig){target="_self"}**

## init

- **Type**

  ```zig
  fn init(allocator: Allocator, data: []T) Self
  ```

- **Documentation**

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/thread.zig){target="_self"}**

## map

- **Type**

  ```zig
  fn map(self: *const Self, comptime func: anytype, args: anytype) Self
  ```

- **Documentation**

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/thread.zig){target="_self"}**

## filter

- **Type**

  ```zig
  fn filter(self: *const Self, comptime pred: anytype, args: anytype) Self
  ```

- **Documentation**

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/thread.zig){target="_self"}**

## reduce

- **Type**

  ```zig
  fn reduce(self: *const Self, comptime func: anytype, args: anytype, initial_value: T) !T
  ```

- **Documentation**

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/thread.zig){target="_self"}**

## some

- **Type**

  ```zig
  fn some(self: *const Self, comptime pred: anytype, args: anytype) !bool
  ```

- **Documentation**

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/thread.zig){target="_self"}**

## every

- **Type**

  ```zig
  fn every(self: *const Self, comptime pred: anytype, args: anytype) !bool
  ```

- **Documentation**

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/thread.zig){target="_self"}**

## find

- **Type**

  ```zig
  fn find(self: *const Self, comptime pred: anytype, args: anytype) !?T
  ```

- **Documentation**

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/thread.zig){target="_self"}**

## result

- **Type**

  ```zig
  fn result(self: *const Self) ![]T
  ```

- **Documentation**

- **[Source](https://github.com/ali-shahwali/zig-functools/blob/main/src/thread.zig){target="_self"}**
