/// Returns return type of `func`.
/// If it has no return type, assumes its the same as the first param type.
pub inline fn funcReturnType(comptime func: anytype) type {
    comptime {
        return @typeInfo(@TypeOf(func)).Fn.return_type orelse {
            @compileLog("Function type info = ", @typeInfo(@TypeOf(func)).Fn);
            @compileError("Function has no return type.");
        };
    }
}

/// Returns the type of the first parameter of `func`.
pub inline fn funcParamType(comptime func: anytype, comptime param_idx: usize) type {
    comptime {
        return @typeInfo(@TypeOf(func)).Fn.params[param_idx].type orelse {
            @compileLog("Function type info = ", @typeInfo(@TypeOf(func)).Fn);
            @compileError("Function without params has no param type.");
        };
    }
}
