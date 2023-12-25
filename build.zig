const std = @import("std");

const Benchmark = struct {
    name: []const u8,
    run_step_name: []const u8,
    description: []const u8,
    path: []const u8,
};

const benchmarks = [_]Benchmark{
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
        .name = "every",
        .run_step_name = "bench-every",
        .description = "Benchmark the every function",
        .path = "benchmarks/every.zig",
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
