const std = @import("std");

const Runnable = struct {
    name: []const u8,
    run_step_name: []const u8,
    description: []const u8,
    path: []const u8,
};

const benchmarks = [_]Runnable{
    .{
        .name = "map",
        .run_step_name = "bench-map",
        .description = "Benchmark the map function",
        .path = "benchmarks/map.zig",
    },
    .{
        .name = "reduce",
        .run_step_name = "bench-reduce",
        .description = "Benchmark the reduce function",
        .path = "benchmarks/reduce.zig",
    },
    .{
        .name = "filter-impl",
        .run_step_name = "bench-filter-impl",
        .description = "Benchmark the 2 different filter implementations",
        .path = "benchmarks/filter_impl.zig",
    },
    .{
        .name = "all",
        .run_step_name = "bench-all",
        .description = "Run all benchmarks",
        .path = "benchmarks/all.zig",
    },
};

const examples = [_]Runnable{
    .{
        .name = "OV",
        .run_step_name = "example-OV",
        .description = "Run the Orthogonal Vectors example",
        .path = "examples/orthogonal_vectors.zig",
    },
    .{
        .name = "set",
        .run_step_name = "example-set",
        .description = "Run the set example",
        .path = "examples/set.zig",
    },
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const typed = b.dependency("typed", .{}).module("typed");

    const functools = b.addModule("functools", .{
        .root_source_file = b.path("src/root.zig"),
        .imports = &.{.{
            .name = "typed",
            .module = typed,
        }},
    });

    const lib = b.addSharedLibrary(.{
        .name = "functools",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib.root_module.addImport("typed", typed);

    b.installArtifact(lib);

    inline for (benchmarks) |config| {
        const bench_run_step = b.step(config.run_step_name, config.description);

        var bench = b.addExecutable(.{
            .name = config.name,
            .root_source_file = b.path(config.path),
            .target = target,
            .optimize = .ReleaseSafe,
        });
        bench.root_module.addImport("functools", functools);
        bench.root_module.addImport("typed", typed);

        const bench_run = b.addRunArtifact(bench);
        bench_run_step.dependOn(&bench_run.step);
    }

    inline for (examples) |config| {
        const example_run_step = b.step(config.run_step_name, config.description);

        var example = b.addExecutable(.{
            .name = config.name,
            .root_source_file = b.path(config.path),
            .target = target,
            .optimize = optimize,
        });
        example.root_module.addImport("functools", functools);

        const example_run = b.addRunArtifact(example);
        example_run_step.dependOn(&example_run.step);
    }

    const tests = b.addTest(.{
        .name = "tests",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    tests.root_module.addImport("typed", typed);

    const run_tests = b.addRunArtifact(tests);

    // Uncomment to create executable for debugging.
    // b.installArtifact(tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_tests.step);
}
