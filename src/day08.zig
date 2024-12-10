const std = @import("std");
const input = @embedFile("inputs/day08.txt");

const width = 50; // Not including the \r\n
const height = 50;

var antinodes = init_antinodes();

inline fn init_antinodes() [(width+2) * height]u8 {
    var local_antinodes = [_]u8{'.'} ** ((width + 2) * height);
    for (0..height) |y| {
        const idx = get_index_from_coords(width, y);
        local_antinodes[idx] = '\r';
        local_antinodes[idx + 1] = '\n';
    }
    return local_antinodes;
}

pub fn main() !void {
    try part1();
    try part2();
}

fn get_index_from_coords(x: usize, y: usize) usize {
    return y * (width + 2) + x; // The 2 is there in order to account for the \r\n
}

fn get_char(x: usize, y: usize) u8 {
    const index = get_index_from_coords(x, y);
    return input[index];
}

fn is_tile_antenna(x: usize, y: usize) bool {
    return get_char(x, y) != '.';
}

fn set_antinode_between(x1: usize, y1: usize, x2: usize, y2: usize) void {
    // std.debug.print("({:0>2}, {:0>2}) -> ({:0>2}, {:0>2}) - {c}", .{x1, y1, x2, y2, get_char(x1, y1)});
    if (2 * x1 >= x2 and 2 * y1 >= y2) {
        const antinode_towards_1_x = 2 * x1 - x2;
        const antinode_towards_1_y = 2 * y1 - y2;
        if (antinode_towards_1_x < width and antinode_towards_1_y < height) {
            antinodes[get_index_from_coords(antinode_towards_1_x, antinode_towards_1_y)] = get_char(x1, y1);
            // std.debug.print(" - Towards 1 => YES ", .{});
        } else {
            // std.debug.print(" - Towards 1 => NO 2", .{});
        }
    } else {
        // std.debug.print(" - Towards 1 => NO 1", .{});
    }

    if (2 * x2 >= x1 and 2 * y2 >= y1) {
        const antinode_towards_2_x = 2 * x2 - x1;
        const antinode_towards_2_y = 2 * y2 - y1;
        if (antinode_towards_2_x < width and antinode_towards_2_y < height) {
            antinodes[get_index_from_coords(antinode_towards_2_x, antinode_towards_2_y)] = get_char(x1, y1);
            // std.debug.print(" - Towards 2 => YES \n", .{});
        } else {
            // std.debug.print(" - Towards 2 => NO 2\n", .{});
        }
    } else {
        // std.debug.print(" - Towards 2 => NO 1\n", .{});
    }
}

fn part1() !void {
    for (0..height) |y1| {
        for (0..width) |x1| {
            if (!is_tile_antenna(x1, y1)) {
                continue;
            }
            for (y1..height) |y2| {
                for (0..width) |x2| {
                    if (y1 == y2 and x1 >= x2) {
                        continue;
                    }
                    if (!is_tile_antenna(x2, y2)) {
                        continue;
                    }
                    if (get_char(x1, y1) != get_char(x2, y2)) {
                        continue;
                    }
                    set_antinode_between(x1, y1, x2, y2);
                }
            }
        }
    }

    // std.debug.print("{s}\n\n", .{input});
    // std.debug.print("{s}\n", .{antinodes});

    var result: usize = 0;
    for  (0..height) |y| {
        for (0..width) |x| {
            if (antinodes[get_index_from_coords(x, y)] != '.') {
                result += 1;
            }
        }
    }

    std.debug.print("Part 1: {}\n", .{result});
}



fn add_all_antinodes_for_antennas(x1: usize, y1: usize, x2: usize, y2: usize) void {
    const ix1: isize = @intCast(x1);
    const iy1: isize = @intCast(y1);
    const ix2: isize = @intCast(x2);
    const iy2: isize = @intCast(y2);

    {
        const delta_x = ix1 - ix2;
        const delta_y = iy1 - iy2;

        for (0..@max(width, height)) |k| {
            const antinode_towards_1_x = ix1 - delta_x * @as(isize, @intCast(k));
            const antinode_towards_1_y = iy1 - delta_y * @as(isize, @intCast(k));
            if (antinode_towards_1_x >= 0 and antinode_towards_1_y >= 0 and antinode_towards_1_x < width and antinode_towards_1_y < height) {
                const ax = @as(usize, @intCast(antinode_towards_1_x));
                const ay = @as(usize, @intCast(antinode_towards_1_y));
                antinodes[get_index_from_coords(ax, ay)] = get_char(x1, y1);
            }
        }
    }

    {
        const delta_x = ix2 - ix1;
        const delta_y = iy2 - iy1;

        for (0..@max(width, height)) |k| {
            const antinode_towards_2_x = ix2 - delta_x * @as(isize, @intCast(k));
            const antinode_towards_2_y = iy2 - delta_y * @as(isize, @intCast(k));
            if (antinode_towards_2_x >= 0 and antinode_towards_2_y >= 0 and antinode_towards_2_x < width and antinode_towards_2_y < height) {
                const ax = @as(usize, @intCast(antinode_towards_2_x));
                const ay = @as(usize, @intCast(antinode_towards_2_y));
                antinodes[get_index_from_coords(ax, ay)] = get_char(x1, y1);
            }
        }
    }
}

fn part2() !void {
    for (0..height) |y1| {
        for (0..width) |x1| {
            if (!is_tile_antenna(x1, y1)) {
                continue;
            }
            for (y1..height) |y2| {
                for (0..width) |x2| {
                    if (y1 == y2 and x1 >= x2) {
                        continue;
                    }
                    if (!is_tile_antenna(x2, y2)) {
                        continue;
                    }
                    if (get_char(x1, y1) != get_char(x2, y2)) {
                        continue;
                    }
                    add_all_antinodes_for_antennas(x1, y1, x2, y2);
                }
            }
        }
    }

    // std.debug.print("{s}\n\n", .{input});
    // std.debug.print("{s}\n", .{antinodes});

    var result: usize = 0;
    for  (0..height) |y| {
        for (0..width) |x| {
            if (antinodes[get_index_from_coords(x, y)] != '.') {
                result += 1;
            }
        }
    }

    std.debug.print("Part 1: {}\n", .{result});
}
