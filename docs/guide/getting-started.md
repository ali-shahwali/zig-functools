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
            .hash = "122045e23553019c2e608d47c23ab4cb30de9abb5b35cfedd1975c8569af5555eb84",
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