# Getting Started

This section provides an installation guide to quickly get started with using Zig Functools.

## Installation

Add the `.functools` dependency to your `build.zig.zon`.

```zig{5-8}
.{
    .name = "Your project name",
    .version = "x.y.z",
    .dependencies = .{
        .functools = .{
            .url = "https://github.com/ali-shahwali/zig-functools/archive/refs/tags/v0.0.5.tar.gz",
            .hash = "12204b0e5dc32609df9d25b302fe0dcd3a7077b6f71c6444561839143a8c4c335b90",
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