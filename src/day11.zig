const std = @import("std");
const input = @embedFile("inputs/day11.txt");

const Allocator = std.mem.Allocator;

pub fn main() !void {
    // Part 1: 203228
    try part(1, 25);
    // Part 2: Bigger than 240882107907647, and smaller than 365890051570186
    try part(2, 75);
}

const cache_iteration_count = 80;
const cache_entry_count = 50;

const Cache = struct {
    entries: [cache_iteration_count * cache_entry_count]?u64 = [_]?u64{null} ** (cache_iteration_count * cache_entry_count),
    len: u64 = 0,

    pub fn get(self: *Cache, entry: u64, iteration: u64) ?u64 {
        if (entry >= cache_entry_count or iteration >= cache_iteration_count) {
            return null;
        }
        return self.entries[entry + iteration * cache_entry_count];
    }

    pub fn set(self: *Cache, entry: u64, iteration: u64, value: u64) void {
        if (entry >= cache_entry_count or iteration >= cache_iteration_count) {
            // std.debug.print("Invalid cache entry: {} {}\n", .{entry, iteration});
            return;
        }
        self.entries[entry + iteration * cache_entry_count] = value;
    }
};

var cache = Cache{};

// Expected output (calculated by hand using regex + python): 183380722
fn part(part_id: u8, iter_count: u64) !void {
    var result: u64 = 0;

    var value_str_it = std.mem.tokenizeScalar(u8, input, ' ');
    while (value_str_it.next()) |value_str| {
        const value_str_trimmed = std.mem.trimRight(u8, value_str, " \r\n");

        const value = try std.fmt.parseInt(u64, value_str_trimmed, 10);

        result += handle_node(value, iter_count);
    }

    // print_linked_list(&stones);
    std.debug.print("Part {} result: {}\n", .{part_id, result});
}

fn get_number_of_digits(value: u64) u64 {
    if (value < 10) {
        return 1;
    } else if (value < 100) {
        return 2;
    } else if (value < 1000) {
        return 3;
    } else if (value < 10000) {
        return 4;
    } else if (value < 100000) {
        return 5;
    } else if (value < 1000000) {
        return 6;
    } else if (value < 10000000) {
        return 7;
    } else if (value < 100000000) {
        return 8;
    } else if (value < 1000000000) {
        return 9;
    } else if (value < 10000000000) {
        return 10;
    } else if (value < 100000000000) {
        return 11;
    } else if (value < 1000000000000) {
        return 12;
    } else if (value < 10000000000000) {
        return 13;
    } else if (value < 100000000000000) {
        return 14;
    } else if (value < 1000000000000000) {
        return 15;
    } else if (value < 10000000000000000) {
        return 16;
    } else if (value < 100000000000000000) {
        return 17;
    } else if (value < 1000000000000000000) {
        return 18;
    } else {
        return 19;
    }
}

fn handle_node(value: u64, remaining_iters: u64) u64 {
    if (remaining_iters == 0) {
        return 1;
    }
    if (cache.get(value, remaining_iters)) |cached_value| {
        return cached_value;
    }

    if (value == 0) {
        return handle_node(1, remaining_iters - 1);
    } else if (value == 1) {
        return handle_node(2024, remaining_iters - 1);
    } else {
        const number_of_digits: u64 = get_number_of_digits(value);

        if (number_of_digits % 2 == 0) {
            // Even number of digits, so split the digits in the top and bottom half, and split the node in two
            const half = number_of_digits / 2;
            const first_half = value / std.math.pow(u64, 10, half);
            const second_half = value % std.math.pow(u64, 10, half);

            const result = handle_node(first_half, remaining_iters - 1) + handle_node(second_half, remaining_iters - 1);
            cache.set(value, remaining_iters, result);
            return result;
        } else {
            const result = handle_node(value * 2024, remaining_iters - 1);
            cache.set(value, remaining_iters, result);
            return result;
        }
    }
}
