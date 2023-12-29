# Sequences
A sequence is a an additional layer of abstraction on top of the well known `ArrayList` data structure implemented in `std`. Sequences make it easier for us to map, reduce, filter e.t.c. Below are some examples of how to use Sequences.

**Filter Sequence**
```zig
test "test filter sequence" {
    const allocator = testing.allocator;
    const slice = try util.rangeSlice(allocator, i32, 10);
    defer allocator.free(slice);

    var seq = try Sequence(i32).fromSlice(allocator, slice);
    try seq.filter(CommonPredicates.even(i32), .{});

    const res = try seq.toOwnedSlice();
    defer allocator.free(res);

    try testing.expectEqualSlices(i32, &[_]i32{ 0, 2, 4, 6, 8 }, res);
}
```

**Conjoin and map Sequences**
```zig
test "test map and conjoin sequence" {
    const allocator = testing.allocator;
    const s1 = try util.rangeSlice(allocator, i32, 5);
    defer allocator.free(s1);

    const s2 = try util.rangeSlice(allocator, i32, 5);
    defer allocator.free(s2);

    var seq1 = try Sequence(i32).fromSlice(allocator, s1);
    var seq2 = try Sequence(i32).fromSlice(allocator, s2);
    defer seq2.deinit();

    try seq2.map(CommonMappers.add(i32), .{5});

    try seq1.conj(seq2);
    try seq1.filter(common.CommonPredicates.even(i32), .{});

    const res = try seq1.toOwnedSlice();
    defer allocator.free(res);

    try testing.expectEqualSlices(i32, &[_]i32{ 0, 2, 4, 6, 8 }, res);
}
```

**Thread functions on Sequence**
```zig
test "test thread sequence" {
    const allocator = testing.allocator;
    const slice = try util.rangeSlice(allocator, i32, 10);
    defer allocator.free(slice);

    var seq = try Sequence(i32).fromSlice(allocator, slice);
    defer seq.deinit();

    const res = try seq
        .thread()
        .map(CommonMappers.inc(i32), .{})
        .filter(CommonPredicates.even(i32), .{})
        .reduce(CommonReducers.sum(i32), .{}, 0);

    try testing.expectEqual(res, 30);
}
```

Because `Sequence` sits on top of the `ArrayList` implementation, you can easily access the `ArrayList` API with the `.seq` field. The `Sequence` implementation is also a good example of how to use the Thread API when designing your own data structures. See below

```zig
...
/// Perform threading on sequence. Returns a new thread, user must make sure to
/// free the result from threading if it is a slice. Threading does not deinit `self`.
/// Note that any operations performed when threading do not modify the sequence. 
pub fn thread(self: *const Self) Thread(T) {
    return Thread(T).init(self.allocator, self.seq.items);
}
...
```