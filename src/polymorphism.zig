const typed = @import("typed");
const std = @import("std");
const testing = std.testing;

pub fn adHocPoly(args: anytype, fns: anytype) typed.ReturnType(fns[0]) {
    const RT = typed.ReturnType(fns[0]);
    comptime for (fns) |func| {
        if (typed.ReturnType(func) != RT) {
            @compileError("all functions must have the same return type");
        }
    };

    const args_ty = @typeInfo(@TypeOf(args));
    const found_idx = blk: switch (args_ty) {
        inline .@"struct" => |s| {
            const fields = s.fields;
            const fns_ty = @typeInfo(@TypeOf(fns));
            switch (fns_ty) {
                inline .@"struct" => |fns_struc| {
                    comptime for (fns_struc.fields, 0..) |func, fn_idx| {
                        const fn_ty = @typeInfo(func.type);
                        switch (fn_ty) {
                            inline .@"fn" => |fn_ty_info| {
                                if (fn_ty_info.params.len != fields.len) {
                                    continue;
                                }

                                var found = true;
                                for (fn_ty_info.params, 0..) |param, i| {
                                    if (param.type) |param_ty| {
                                        if (param_ty != fields[i].type) {
                                            found = false;
                                            break;
                                        }
                                    } else {
                                        @compileError("generic fn parameter of anytype found, can not deduce which fn to call");
                                    }
                                }
                                if (found) {
                                    break :blk fn_idx;
                                }
                            },
                            else => @compileError("functions params was not an array of functions, was " ++ @typeName(@Type(fn_ty))),
                        }
                    };

                    @compileError("no function which fulfills type signature of args was provided");
                },
                else => @compileError("functions was not a struct of fn, was " ++ @typeName(@Type(fns_ty))),
            }
        },
        else => @compileError("expected struct for args, was " ++ @typeName(@Type(args))),
    };

    return @call(.auto, fns[found_idx], args);
}

pub fn adHocPolyT(comptime T: type, args: anytype, fns: anytype) T {
    const args_ty = @typeInfo(@TypeOf(args));
    const found_idx = blk: switch (args_ty) {
        inline .@"struct" => |s| {
            const fields = s.fields;
            const fns_ty = @typeInfo(@TypeOf(fns));
            switch (fns_ty) {
                inline .@"struct" => |fns_struc| {
                    comptime for (fns_struc.fields, 0..) |func, fn_idx| {
                        const fn_ty = @typeInfo(func.type);
                        switch (fn_ty) {
                            inline .@"fn" => |fn_ty_info| {
                                if (fn_ty_info.params.len != fields.len) {
                                    continue;
                                }
                                if (fn_ty_info.return_type) |RT| {
                                    if (RT != T) {
                                        continue;
                                    }
                                } else {
                                    unreachable;
                                }

                                var found = true;
                                for (fn_ty_info.params, 0..) |param, i| {
                                    if (param.type) |param_ty| {
                                        if (param_ty != fields[i].type) {
                                            found = false;
                                            break;
                                        }
                                    } else {
                                        @compileError("generic fn parameter of anytype found, can not deduce which fn to call");
                                    }
                                }
                                if (found) {
                                    break :blk fn_idx;
                                }
                            },
                            else => @compileError("functions params was not an array of functions, was " ++ @typeName(@Type(fn_ty))),
                        }
                    };

                    @compileError("no function which fulfills type signature of args was provided");
                },
                else => @compileError("functions was not a struct of fn, was " ++ @typeName(@Type(fns_ty))),
            }
        },
        else => @compileError("expected struct for args, was " ++ @typeName(@Type(args))),
    };

    return @call(.auto, fns[found_idx], args);
}

const Point2D = struct {
    x: i32,
    y: i32,
};

fn dot2d(p1: Point2D, p2: Point2D) i32 {
    return p1.x * p2.x + p1.y * p2.y;
}

const Point3D = struct {
    x: i32,
    y: i32,
    z: i32,
};

fn dot3d(p1: Point3D, p2: Point3D) i32 {
    return p1.x * p2.x + p1.y * p2.y + p1.z * p2.z;
}

fn dot(args: anytype) i32 {
    return adHocPoly(
        args,
        .{ dot2d, dot3d },
    );
}

test "ad_hoc_polymorphism" {
    try testing.expectEqual(11, dot(.{
        Point2D{ .x = 1, .y = 2 },
        Point2D{ .x = 3, .y = 4 },
    }));

    try testing.expectEqual(32, dot(.{
        Point3D{ .x = 1, .y = 2, .z = 3 },
        Point3D{ .x = 4, .y = 5, .z = 6 },
    }));
}

fn @"*int_i64"(a: i64, b: i64) i64 {
    return a * b;
}

fn @"*int_i32"(a: i64, b: i64) i32 {
    return @intCast(a * b);
}

fn mul(comptime T: type, args: anytype) T {
    return adHocPolyT(
        T,
        args,
        .{ @"*int_i64", @"*int_i32" },
    );
}

test "ad_hoc_polymorphism_with_return_type" {
    try testing.expectEqual(12, mul(i64, .{ @as(i64, 3), @as(i64, 4) }));
    try testing.expectEqual(12, mul(i32, .{ @as(i64, 3), @as(i64, 4) }));
}
