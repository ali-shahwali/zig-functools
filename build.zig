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
        .name = "map-impl",
        .run_step_name = "bench-map-impl",
        .description = "Benchmark the 2 different map implementations",
        .path = "benchmarks/map_impl.zig",
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

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const cham_dep = b.dependency("chameleon", .{});
    const cham = cham_dep.module("chameleon");

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

    b.installArtifact(lib);

    inline for (benchmarks) |config| {
        const bench_run_step = b.step(config.run_step_name, config.description);

        var bench = b.addExecutable(.{
            .name = config.name,
            .root_source_file = .{ .path = config.path },
            .target = target,
            .optimize = .ReleaseSafe,
        });
        bench.addModule("functools", functools);
        bench.addModule("chameleon", cham);

        const bench_run = b.addRunArtifact(bench);
        bench_run_step.dependOn(&bench_run.step);
    }

    inline for (examples) |config| {
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

    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/functools.zig" },
        .target = target,
        .optimize = optimize,
    });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_tests.step);
}
