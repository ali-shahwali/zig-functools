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
            .url = "https://github.com/ali-shahwali/zig-functools/archive/refs/tags/v0.0.3.tar.gz",
            .hash = "1220b0d1e247e30f32cffeabbfef4e0ce5b21e72e0a628062e7ade917288af912a7c",
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