# Getting Started

This section provides an installation guide to quickly get started with using Zig Functools.

## Installation

Add the `.functools` dependency to your `build.zig.zon`.

```zig{5-8}
.{
    .name = "Your project name",
    .version = "x.y.z",
    .paths = .{""},
    .dependencies = .{
        .functools = .{
            .url = "https://github.com/ali-shahwali/zig-functools/archive/refs/tags/v0.0.6.tar.gz",
            .hash = "1220755a56367c5eee41fea101569c15ce250a3e60133108d8d4ec6402f999bdeaf6",
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
exe.root_module.addImport("functools", functools.module("functools"));
// Or, if you are building a library
// lib.root_module.addImport("functools", functools.module("functools"));
```

The library can now be imported as a module.

```zig
const functools = @import("functools");
```