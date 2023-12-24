const std = @import("std");

pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    var functools = b.createModule(.{
        .source_file = .{ .path = "src/functools.zig" },
    });

    try b.modules.put(b.dupe("functools"), functools);

    const lib = b.addSharedLibrary(.{
        .name = "functools",
        .root_source_file = .{ .path = "src/functools.zig" },
        .target = target,
        .optimize = optimize,
    });

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);

    inline for ([_]struct {
        name: []const u8,
        run_step_name: []const u8,
        description: []const u8,
        path: []const u8,
    }{
        .{
            .name = "map",
            .run_step_name = "bench-map",
            .description = "benchmark the map function",
            .path = "benchmarks/map.zig",
        },
        .{
            .name = "reduce",
            .run_step_name = "bench-reduce",
            .description = "benchmark the reduce function",
            .path = "benchmarks/reduce.zig",
        },
        .{
            .name = "every",
            .run_step_name = "bench-every",
            .description = "benchmark the every function",
            .path = "benchmarks/every.zig",
        },
    }) |config| {
        const bench_run_step = b.step(config.run_step_name, config.description);

        var bench = b.addExecutable(.{
            .name = config.name,
            .root_source_file = .{ .path = config.path },
            .target = target,
            .optimize = optimize,
        });

        bench.addModule("functools", functools);

        const bench_run = b.addRunArtifact(bench);
        bench_run_step.dependOn(&bench_run.step);
    }

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    tests.addModule("functools", functools);
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_tests.step);
}
