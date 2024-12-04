const std = @import("std");
const input = @embedFile("inputs/day01.txt");

pub fn main() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var list1 = std.ArrayList(u32).init(alloc);
    var list2 = std.ArrayList(u32).init(alloc);

    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");
    while (line_it.next()) |line| {
        const trimmed_line = std.mem.trimRight(u8, line, "\r\n");
        var value_it = std.mem.tokenizeSequence(u8, trimmed_line, "   ");

        const s1 = value_it.next().?;
        const s2 = value_it.next().?;

        const v1 = try std.fmt.parseInt(u32, s1, 10);
        const v2 = try std.fmt.parseInt(u32, s2, 10);

        try list1.append(v1);
        try list2.append(v2);
    }

    // Part 1

    std.mem.sort(u32, list1.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, list2.items, {}, comptime std.sort.asc(u32));

    var result1: u64 = 0;
    for (list1.items, list2.items) |v1, v2| {
        result1 += @abs(@as(i64, @intCast(v1)) - @as(i64, @intCast(v2)));
    }

    std.debug.print("Part 1 result: {}\n", .{result1});

    // Part 2

    var result2: usize = 0;

    for (list1.items) |v1| {
        const array = [1]u32{v1};
        const occurrences = std.mem.count(u32, list2.items, &array);
        result2 += v1 * occurrences;
    }
    std.debug.print("Part 2 result: {}\n", .{result2});
}