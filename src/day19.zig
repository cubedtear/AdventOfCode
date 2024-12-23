const std = @import("std");
const builtin = @import("builtin");
const input = @embedFile("inputs/day19.txt");


pub fn main() !void {
    try part1();
    try part2();
}

fn part1() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var parts_it = std.mem.tokenizeSequence(u8, input, "\n\r"); // \n\r should only appear in consecutive \r\n\r\n pairs
    const towel_input = parts_it.next().?;
    const designs_input = parts_it.next().?;

    var towel_it = std.mem.tokenizeSequence(u8, towel_input, ", ");
    var design_it = std.mem.tokenizeAny(u8, designs_input, "\r\n");

    var all_towels = std.ArrayList([]const u8).init(alloc);
    while (towel_it.next()) |towel| {
        const towel_trimmed = std.mem.trimRight(u8, towel, "\r\n");
        try all_towels.append(towel_trimmed);
    }

    var result: usize = 0;
    while (design_it.next()) |design| {
        const design_trimmed = std.mem.trimRight(u8, design, "\r\n");

        if (solve_design_part_1(design_trimmed, all_towels.items)) {
            result += 1;
        }
    }

    std.debug.print("Part 1 result: {}\n", .{result});
}

fn solve_design_part_1(remaining_design: []const u8, all_towels: [][]const u8) bool {
    if (remaining_design.len == 0) {
        return true;
    }

    for (0..all_towels.len) |towel_idx| {
        const towel = all_towels[towel_idx];

        if (remaining_design.len < towel.len) {
            continue;
        }

        if (std.mem.eql(u8, remaining_design[0..towel.len], towel)) {
            if (solve_design_part_1(remaining_design[towel.len..], all_towels)) {
                return true;
            }
        } else {
        }
    }
    return false;
}

fn lexicographic_less_than(_: void, lhs: []const u8, rhs: []const u8) bool {
    return lhs[0] < rhs[0] or (lhs[0] == rhs[0] and lhs.len < rhs.len) or (lhs[0] == rhs[0] and lhs.len == rhs.len and lhs.len > 1 and rhs.len > 1 and lhs[1] < rhs[1]);
}

const StringHashSet = std.StringHashMap(usize);

fn part2() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var parts_it = std.mem.tokenizeSequence(u8, input, "\n\r"); // \n\r should only appear in consecutive \r\n\r\n pairs
    const towel_input = parts_it.next().?;
    const designs_input = parts_it.next().?;

    var towel_it = std.mem.tokenizeSequence(u8, towel_input, ", ");
    var design_it = std.mem.tokenizeAny(u8, designs_input, "\r\n");

    var all_towels = std.ArrayList([]const u8).init(alloc);
    while (towel_it.next()) |towel| {
        const towel_trimmed = std.mem.trimRight(u8, towel, "\r\n");
        try all_towels.append(towel_trimmed);
    }

    var cache = StringHashSet.init(alloc);

    var towel_trie = try PrefixTree.init(alloc);
    defer towel_trie.deinit();

    for (all_towels.items) |towel| {
        try towel_trie.insert(towel);
    }

    var result: usize = 0;
    while (design_it.next()) |design| {
        const design_trimmed = std.mem.trimRight(u8, design, "\r\n");
        result += solve_design_part_2(design_trimmed, towel_trie, &cache);
    }

    std.debug.print("Part 2 result: {}\n", .{result});

}

fn get_letter_idx(letter: u8) usize {
    switch (letter) {
        'w' => return 0,
        'u' => return 1,
        'b' => return 2,
        'r' => return 3,
        'g' => return 4,
        else => unreachable
    }
}

const PrefixTree = struct {
    char: ?u8,
    children: []?PrefixTree,
    is_leaf: bool,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !PrefixTree {
        const children = try allocator.alloc(?PrefixTree, 5);
        @memset(children, null);
        return PrefixTree{
            .char = null,
            .children = children,
            .is_leaf = false,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *PrefixTree) void {
        for (0..self.children.len) |child_idx| {
            if (self.children[child_idx] != null) {
                self.children[child_idx].?.deinit();
            }
        }
        self.allocator.free(self.children);
    }

    pub fn insert(self: *PrefixTree, design: []const u8) !void {
        if (design.len == 0) {
            self.is_leaf = true;
            return;
        }

        const letter_idx = get_letter_idx(design[0]);
        if (self.children[letter_idx] == null) {
            const children = try self.allocator.alloc(?PrefixTree, 5);
            @memset(children, null);
            self.children[letter_idx] = PrefixTree{
                .char = design[0],
                .children = children,
                .is_leaf = false,
                .allocator = self.allocator,
            };
        }

        try self.children[letter_idx].?.insert(design[1..]);
    }

    pub fn contains(self: *const PrefixTree, design: []const u8) bool {
        if (design.len == 0) {
            return self.is_leaf;
        }

        const letter_idx = get_letter_idx(design[0]);
        if (self.children[letter_idx] == null) {
            return false;
        }

        return self.children[letter_idx].?.contains(design[1..]);
    }
};

fn solve_design_part_2(remaining_design: []const u8, towel_hash_set: PrefixTree, cache: *StringHashSet) usize {
    if (remaining_design.len == 0) {
        return 1;
    }

    if (cache.contains(remaining_design)) {
        return cache.get(remaining_design).?;
    }

    var result: usize = 0;

    var prefix_length: usize = 0;
    var current_trie = towel_hash_set;
    var next_letter_idx = get_letter_idx(remaining_design[prefix_length]);
    while (current_trie.children[next_letter_idx] != null) {
        current_trie = current_trie.children[next_letter_idx].?;
        prefix_length += 1;
        if (current_trie.is_leaf) {
            result += solve_design_part_2(remaining_design[prefix_length..], towel_hash_set, cache);
        }

        if (prefix_length == remaining_design.len) {
            break;
        } else {
            next_letter_idx = get_letter_idx(remaining_design[prefix_length]);
        }
    }

    // Try to cache the result, but if it fails (OOM), just ignore it
    cache.put(remaining_design, result) catch {};

    return result;
}