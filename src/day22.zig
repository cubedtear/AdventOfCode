const std = @import("std");
const input = @embedFile("inputs/day22.txt");

const Allocator = std.mem.Allocator;

pub fn main() !void {
    try part1();
    try part2(); // Bigger than 1353
}

const NextSecretIterator = struct {
    current_secret: u64,

    pub fn init(initial_secret: u64) NextSecretIterator {
        return NextSecretIterator{
            .current_secret = initial_secret
        };
    }

    pub fn next(self: *NextSecretIterator) u64 {
        const next_secret_1 = ((self.current_secret << 6) ^ self.current_secret) & 0x0FF_FFFF;
        const next_secret_2 = ((next_secret_1 >> 5) ^ next_secret_1) & 0x0FF_FFFF;
        const next_secret_3 = ((next_secret_2 << 11) ^ next_secret_2) & 0x0FF_FFFF;
        self.current_secret = next_secret_3;
        return next_secret_3;
    }
};

fn part1() !void {
    var result: usize = 0;

    var initial_secret_it = std.mem.tokenizeAny(u8, input, "\n\r");
    while (initial_secret_it.next()) |initial_secret| {
        const initial_secret_int = try std.fmt.parseInt(u64, initial_secret, 10);
        var secret_iter = NextSecretIterator.init(initial_secret_int);
        for (0..2000-1) |_| {
            _ = secret_iter.next();
        }

        const last_secret = secret_iter.next();
        // std.debug.print("{}: {}\n", .{initial_secret_int, last_secret});
        result += last_secret;
    }

    std.debug.print("Part 1 result: {}\n", .{result});
}

const I8Pair = struct {
    price: i8,
    delta_with_previous: i8,
};

const HashMapKey = struct {
    secret_idx: usize,
    first: i8,
    second: i8,
    third: i8,
    fourth: i8,
};

const HashMapContext = struct {
    pub fn hash(self: @This(), key: HashMapKey) u64 {
        _ = self;
        return key.secret_idx + 2000 * (
            @as(u64, @intCast(key.first + 9)) + 19 * (
                @as(u64, @intCast(key.second + 9)) + 9 + 19 * (
                    @as(u64, @intCast(key.third + 9)) + 9 + 19 * (
                        @as(u64, @intCast(key.fourth + 9)) + 9
                    )
                )
            )
        );
    }
    pub fn eql(self: @This(), a: HashMapKey, b: HashMapKey) bool {
        _ = self;
        return a.secret_idx == b.secret_idx and
            a.first == b.first and
            a.second == b.second and
            a.third == b.third and
            a.fourth == b.fourth;
    }
};

const HashMapType = std.HashMap(HashMapKey, usize, HashMapContext, std.hash_map.default_max_load_percentage);

fn part2() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var all_differences = std.ArrayList([2000]I8Pair).init(alloc);

    var hash_map = HashMapType.init(alloc);

    // const result: usize = 0;
    var initial_secret_it = std.mem.tokenizeAny(u8, input, "\n\r");
    while (initial_secret_it.next()) |initial_secret| {
        const initial_secret_int = try std.fmt.parseInt(u64, initial_secret, 10);
        var secret_iter = NextSecretIterator.init(initial_secret_int);

        try all_differences.append([_]I8Pair{I8Pair{.delta_with_previous = undefined, .price = undefined}} ** 2000);

        var last_value: i8 = @intCast(initial_secret_int % 10);

        for (0..2000) |idx| {
            const new_value: i8 = @intCast(secret_iter.next() % 10);

            all_differences.items[all_differences.items.len - 1][idx].price = new_value;
            all_differences.items[all_differences.items.len - 1][idx].delta_with_previous = new_value - last_value;

            if (idx >= 3) {
                const key = HashMapKey{
                    .secret_idx = all_differences.items.len - 1,
                    .first = all_differences.items[all_differences.items.len - 1][idx-3].delta_with_previous,
                    .second = all_differences.items[all_differences.items.len - 1][idx-2].delta_with_previous,
                    .third = all_differences.items[all_differences.items.len - 1][idx-1].delta_with_previous,
                    .fourth = all_differences.items[all_differences.items.len - 1][idx].delta_with_previous,
                };

                if (!hash_map.contains(key)) {
                    try hash_map.put(key, idx);
                }
            }

            last_value = new_value;
        }
    }

    var best_idx: ?usize = null;
    var best_sum: i32 = 0;

    for (0..19) |unsigned_first_idx| {
        const first_idx = @as(i8, @intCast(unsigned_first_idx)) - 9;
        for (0..19) |unsigned_second_idx| {
            const second_idx = @as(i8, @intCast(unsigned_second_idx)) - 9;
            for (0..19) |unsigned_third_idx| {
                const third_idx = @as(i8, @intCast(unsigned_third_idx)) - 9;
                for (0..19) |unsigned_fourth_idx| {
                    const fourth_idx = @as(i8, @intCast(unsigned_fourth_idx)) - 9;

                    var total_sum: i32 = 0;

                    for (0..all_differences.items.len) |list_idx| {
                        const key = HashMapKey{
                            .secret_idx = list_idx,
                            .first = first_idx,
                            .second = second_idx,
                            .third = third_idx,
                            .fourth = fourth_idx,
                        };

                        if (!hash_map.contains(key)) {
                            continue;
                        }

                        const idx = hash_map.get(key).?;

                        total_sum += all_differences.items[list_idx][idx].price;
                    }

                    if (best_idx == null or total_sum > best_sum) {
                        best_sum = total_sum;
                        best_idx = 0;
                    }
                }
            }
        }
    }

    // std.debug.print("Part 2 result: Best pattern (at {}): {}, {}, {}, {} - Total price: {}\n", .{
    //     best_idx.?,
    //     all_differences.items[0][best_idx.?].delta_with_previous,
    //     all_differences.items[0][best_idx.?+1].delta_with_previous,
    //     all_differences.items[0][best_idx.?+2].delta_with_previous,
    //     all_differences.items[0][best_idx.?+3].delta_with_previous,
    //     best_sum,
    // });

    std.debug.print("Part 2 result: {}\n", .{best_sum});
}
