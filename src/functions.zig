//! This module contains all functional programming functions.

const map = @import("functions/map.zig");
const reduce = @import("functions/reduce.zig");
const filter = @import("functions/filter.zig");
const some = @import("functions/some.zig");
const every = @import("functions/every.zig");
const util = @import("functions/util.zig");
const find = @import("functions/find.zig");
const errors = @import("functions/errors.zig");

pub const mapSlice = map.mapSlice;
pub const mapMutSlice = map.mapMutSlice;

pub const reduceSlice = reduce.reduceSlice;

pub const filterSlice = filter.filterSlice;

pub const someSlice = some.someSlice;

pub const everySlice = every.everySlice;

pub const takeNth = util.takeNth;
pub const rangeSlice = util.rangeSlice;
pub const rangeAllocSlice = util.rangeAllocSlice;

pub const findSlice = find.findSlice;

pub const FunctoolTypeError = errors.FunctoolTypeError;
