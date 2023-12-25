const std = @import("std");
const common = @import("common.zig");
const functions = @import("functions.zig");
const thread = @import("thread.zig");

pub const FunctoolTypeError = functions.FunctoolTypeError;

pub const CommonMappers = common.CommonMappers;
pub const CommonReducers = common.CommonReducers;
pub const CommonPredicates = common.CommonPredicates;

pub const mapSlice = functions.mapSlice;
pub const mapMutSlice = functions.mapMutSlice;
pub const reduceSlice = functions.reduceSlice;
pub const filterSlice = functions.filterSlice;
pub const someSlice = functions.someSlice;
pub const everySlice = functions.everySlice;
pub const takeNth = functions.takeNth;
pub const rangeSlice = functions.rangeSlice;
pub const findSlice = functions.findSlice;

pub const Thread = thread.Thread;
