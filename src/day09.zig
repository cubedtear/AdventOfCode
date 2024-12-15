const std = @import("std");
const input = @embedFile("inputs/day09.txt");


pub fn main() !void {
    try part1();
    try part2();
}


fn part1() !void {
    // Analyzing the input, all the expanded data should fit in 189232 u16s, since the input is 20k chars long (so 10k file IDs), and the sum of all digits is 189232
    var data: [189232]u16 = undefined;

    const last_pos = blk: {
        var current_pos: usize = 0;
        var next_file = true;
        var next_file_id: u16 = 0;
        for (input) |c| {
            for (0..c - '0') |_|{
                data[current_pos] = if (next_file) next_file_id else std.math.maxInt(u16);
                current_pos += 1;
            }

            if (next_file) {
                next_file_id += 1;
            }
            next_file = !next_file;
        }
        break :blk current_pos;
    };

    var last_free_pos: usize = input[0] - '0';

    // print_state(&data, last_pos);

    var idx = last_pos;
    while(idx > 0) {
        idx -= 1;

        if (data[idx] == std.math.maxInt(u16)) {
            continue;
        }

        if (last_free_pos >= idx) {
            break;
        }

        data[last_free_pos] = data[idx];
        data[idx] = std.math.maxInt(u16);
        last_free_pos += 1;
        while (data[last_free_pos] != std.math.maxInt(u16)) {
            last_free_pos += 1;
        }
        // print_state(&data, last_pos);
    }

    const result = calculate_checksum(&data, idx + 1);


    std.debug.print("Part 1: {}\n", .{result});
}

fn part2() !void {
    // Analyzing the input, all the expanded data should fit in 189232 u16s, since the input is 20k chars long (so 10k file IDs), and the sum of all digits is 189232
    var data: [189232]u16 = undefined;

    const last_pos = blk: {
        var current_pos: usize = 0;
        var next_file = true;
        var next_file_id: u16 = 0;
        for (input) |c| {
            for (0..c - '0') |_|{
                data[current_pos] = if (next_file) next_file_id else std.math.maxInt(u16);
                current_pos += 1;
            }

            if (next_file) {
                next_file_id += 1;
            }
            next_file = !next_file;
        }
        break :blk current_pos;
    };

    // print_state(&data, last_pos);

    var last_moved_id: u16 = std.math.maxInt(u16);

    var idx = last_pos;
    while(idx > 0) {
        idx -= 1;

        // Skip empty spaces
        if (data[idx] == std.math.maxInt(u16) or data[idx] >= last_moved_id) {
            continue;
        }

        const file_end_idx = idx;
        const file_id = data[file_end_idx];
        // Find the start of the file
        while (idx > 0 and data[idx - 1] == file_id) {
            idx -= 1;
        }
        const file_start_idx = idx;
        const file_length = file_end_idx - file_start_idx + 1;

        // std.debug.print("  File {} in [{}, {}] (length {})\n", .{file_id, file_start_idx, file_end_idx, file_length});

        if (file_start_idx < file_length) {
            continue;
        }

        // Find the first contiguous sequence of free space that fits the file
        var free_space_start_idx: ?usize = null;
        var free_space_found = false;
        for (0..file_start_idx + 1) |index| {
            if (data[index] != std.math.maxInt(u16)) {
                // std.debug.print("   Resetting free space starting at {}\n", .{index});
                free_space_start_idx = null;
                continue;
            } else if (free_space_start_idx == null) {
                if (index + file_length > file_start_idx) {
                    // std.debug.print("   Candidate starting pos ({}) of free space is too close to the file\n", .{index});
                    break;
                }
                // std.debug.print("   Found free space starting at {}\n", .{index});
                free_space_start_idx = index;
            }

            // std.debug.print("   Checking free space [{}, {}] - Length: {}\n", .{free_space_start_idx.?, index, file_length});

            if (index + 1 - free_space_start_idx.? == file_length and data[index] == std.math.maxInt(u16)) {
                free_space_found = true;
                break;
            }
        }

        last_moved_id = file_id;

        if (!free_space_found or free_space_start_idx == null) {
            // std.debug.print("   No free space found for file {} - Free Found: {} - FreeSpaceStart: {?}\n", .{file_id, free_space_found, free_space_start_idx});
            continue;
        }

        // Move the file to the beginning of the free space
        // std.debug.print("   Moving file {} from [{}, {}] to [{}, {}]\n", .{file_id, file_start_idx, file_end_idx, free_space_start_idx.?, free_space_start_idx.? + file_length - 1});
        for (file_start_idx..file_end_idx + 1) |file_idx| {
            data[free_space_start_idx.?] = data[file_idx];
            data[file_idx] = std.math.maxInt(u16);
            free_space_start_idx.? += 1;
        }

        // print_state(&data, last_pos);
    }

    // print_state(&data, last_pos);
    const result = calculate_checksum(&data, last_pos);


    std.debug.print("Part 2: {}\n", .{result});
}

fn print_state(data: []u16, last_pos: usize) void {
    for (data, 0..) |c, index| {
        if (index == last_pos) {
            break;
        }
        if (c == std.math.maxInt(u16)) {
            std.debug.print(".", .{});
        } else {
            std.debug.print("{}", .{c});
        }
    }
    std.debug.print("\n", .{});
}

fn calculate_checksum(data: []u16, last_pos: usize) usize {
    var checksum: usize = 0;
    for (data[0..last_pos], 0..) |c, idx| {
        if (c == std.math.maxInt(u16)) {
            continue;
        }
        checksum += c * idx;
        // std.debug.print("{} * {} => {}\n", .{c, idx, checksum});
    }
    return checksum;
}

