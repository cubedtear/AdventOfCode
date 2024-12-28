const std = @import("std");
const input = @embedFile("inputs/day21.txt");

const Allocator = std.mem.Allocator;

pub fn main() !void {
    try part1();
    try part2(); // Lower than 1076502057600325
}

// Usage: num_transitions[get_num_idx(origin_char)][get_num_idx(destination_char)]
const num_transitions = [_][11][]const u8 {
    //            0       1       2       3       4       5       6       7       8       9       A
    [_][]const u8{"",     "^<",   "^",    "^>",   "^^<",  "^^",   "^^>",  "^^^<", "^^^",  "^^^>", ">"    }, // 0
    [_][]const u8{">v",   "",     ">",    ">>",   "^",    "^>",   "^>>",  "^^",   "^^>",  "^^>>", ">>v"  }, // 1
    [_][]const u8{"v",    "<",    "",     ">",    "^<",   "^",    "^>",   "^^<",  "^^",   "^^>",  "v>"   }, // 2
    [_][]const u8{"<v",   "<<",   "<",    "",     "<<^",  "<^",   "^",    "<<^^", "<^^",  "^^",   "v"    }, // 3
    [_][]const u8{">vv",  "<v",   "v",    "v>",   "",     ">",    ">>",   "^",    "^>",   "^>>",  ">>vv" }, // 4
    [_][]const u8{"vv",   "v<",   "v",    "v>",   "<",    "",     ">",    "^<",   "^",    "^>",   ">vv"  }, // 5
    [_][]const u8{"<vv",  "<<v",  "<v",   "v",    "<<",   "<",    "",     "<<^",  "<^",   "^",    "vv"   }, // 6
    [_][]const u8{">vvv", "vv",   "vv>",  "vv>>", "v",    "v>",   "v>>",  "",     ">",    ">>",   ">>vvv"}, // 7
    [_][]const u8{"vvv",  "vv<",  "vv",   "vv>",  "v<",   "v",    "v>",   "<",    "",     ">",    ">vvv" }, // 8
    [_][]const u8{"vvv<", "<<vv", "<vv",  "vv",   "<<v",  "<v",   "v",    "<<",   "<",    "",     "vvv"  }, // 9
    [_][]const u8{"<",    "^<<",  "^<",   "^",    "^^<<", "<^^",  "^^",   "^^^<<","<^^^", "^^^",  ""     }, // A
};

// Usage: dir_transitions[get_dir_idx(origin_char)][get_dir_idx(destination_char)]
const dir_transitions = [_][5][]const u8 {
    //            ^     v     <     >     A
    [_][]const u8{"",   "v",  "v<", "v>", ">"  }, // ^
    [_][]const u8{"^",  "",   "<",  ">",  "^>" }, // v
    [_][]const u8{">^", ">",  "",   ">>", ">>^"}, // <
    [_][]const u8{"<^", "<",  "<",  "",   "^"  }, // >
    [_][]const u8{"<",  "<v", "v<<","v",  ""   }, // A
};

fn get_num_idx(num: u8) u8 {
    switch (num) {
        '0' => return 0,
        '1' => return 1,
        '2' => return 2,
        '3' => return 3,
        '4' => return 4,
        '5' => return 5,
        '6' => return 6,
        '7' => return 7,
        '8' => return 8,
        '9' => return 9,
        'A' => return 10,
        else => std.debug.panic("Invalid char: {c}", .{num}),
    }
}

fn get_dir_idx(dir: u8) u8 {
    switch (dir) {
        '^' => return 0,
        'v' => return 1,
        '<' => return 2,
        '>' => return 3,
        'A' => return 4,
        else => std.debug.panic("Invalid char: {c}", .{dir}),
    }
}

fn iterateOnce(alloc: Allocator, desired: []const u8, is_dir: bool) !std.ArrayList(u8) {
    var result = std.ArrayList(u8).init(alloc);

    var last_char: u8 = 'A';
    for (desired) |desired_char| {
        if (desired_char != last_char) {
            const origin_idx = if (is_dir) get_dir_idx(last_char) else get_num_idx(last_char);
            const dest_idx = if (is_dir) get_dir_idx(desired_char) else get_num_idx(desired_char);

            const transition = if (is_dir) dir_transitions[origin_idx][dest_idx] else num_transitions[origin_idx][dest_idx];

            try result.appendSlice(transition);
        }
        try result.append('A');
        last_char = desired_char;
    }
    return result;
}

fn part1() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var result: usize = 0;

    var codes_it = std.mem.tokenizeAny(u8, input, "\n\r");
    while (codes_it.next()) |code| {
        var arena_allocator = std.heap.ArenaAllocator.init(alloc);
        const arena_alloc = arena_allocator.allocator();
        defer arena_allocator.deinit();

        const after_number = try iterateOnce(arena_alloc, code, false);
        // std.debug.print(" After number: {s}\n", .{after_number.items});

        var tmp = after_number;
        for (0..2) |_| {
            const new_tmp = try iterateOnce(arena_alloc, tmp.items, true);
            // std.debug.print(" Next: {s}\n", .{new_tmp.items});
            tmp.deinit();
            tmp = new_tmp;
        }
        // std.debug.print("  {s}: {s} ({})\n", .{code, tmp.items, tmp.items.len});

        const numeric_part = try std.fmt.parseInt(i32, code[0..code.len - 1], 10);
        result += @as(usize, @intCast(numeric_part)) * tmp.items.len;
    }

    std.debug.print("Part 1 result: {}\n", .{result});
}

const CacheKey = struct {
    pair: [2]u8,
    iterations_remaining: u8,
};

const CacheContext = struct {
    pub fn hash(self: @This(), key: CacheKey) u64 {
        _ = self;
        const p1: u64 = @intCast(key.pair[0]);
        const p2: u64 = @intCast(key.pair[0]);
        const it: u64 = @intCast(key.iterations_remaining);

        return p1 | (p2 << 8) | (it << 16);
    }

    pub fn eql(self: @This(), k1: CacheKey, k2: CacheKey) bool {
        _ = self;
        return k1.pair[0] == k2.pair[0] and k1.pair[1] == k2.pair[1] and k1.iterations_remaining == k2.iterations_remaining;
    }
};

const CacheType = std.HashMap(CacheKey, usize, CacheContext, std.hash_map.default_max_load_percentage);

fn iterateN(desired: []const u8, n: u8, cache: *CacheType) !usize {
    if (n == 0) {
        // std.debug.print("{s}D:0 - Result: {s}\n", .{spaces, desired});
        return desired.len;
    }

    var total_chars: usize = 0;

    var last_char: u8 = 'A';
    for (desired) |next_char| {
        // std.debug.print("{s}D:{} - Handling {c}{c} - ", .{spaces, n, last_char, next_char});
        const key = CacheKey{ .pair = [_]u8{last_char, next_char}, .iterations_remaining = n };
        if (cache.get(key)) |cache_value| {
            total_chars += cache_value;
            last_char = next_char;
        } else {
            // Convert manually, and recurse
            const str_after_iter = dir_transitions[get_dir_idx(last_char)][get_dir_idx(next_char)];

            var buf = [_]u8{0} ** 1024;
            @memcpy(buf[0..str_after_iter.len], str_after_iter);
            buf[str_after_iter.len] = 'A';

            // std.debug.print("Recursing with: {s}\n", .{buf[0..str_after_iter.len+1]});
            const after_iter_len = try iterateN(buf[0..str_after_iter.len+1], n - 1, cache);
            // std.debug.print("{s}D:{} - Backtracking\n", .{spaces, n});
            total_chars += after_iter_len;
            last_char = next_char;

            try cache.put(key, after_iter_len);
        }
    }

    // std.debug.print("{s}D:{} - Result: {s}\n", .{spaces, n, str_buffer[0..writer.pos]});
    return total_chars;
}

fn part2() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var result: usize = 0;

    var codes_it = std.mem.tokenizeAny(u8, input, "\n\r");
    while (codes_it.next()) |code| {
        var arena_allocator = std.heap.ArenaAllocator.init(alloc);
        const arena_alloc = arena_allocator.allocator();
        defer arena_allocator.deinit();

        const after_number = try iterateOnce(arena_alloc, code, false);

        // std.debug.print(" After number: {s}\n", .{after_number.items});

        var cache = CacheType.init(alloc);
        const iteration_result = try iterateN(after_number.items, 25, &cache);
        // std.debug.print("  {s}: {}\n", .{code, iteration_result});

        const numeric_part = try std.fmt.parseInt(i32, code[0..code.len - 1], 10);
        result += @as(usize, @intCast(numeric_part)) * iteration_result;
    }

    std.debug.print("Part 2 result: {}\n", .{result});
}
