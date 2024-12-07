const std = @import("std");
const input = @embedFile("inputs/day04.txt");

pub fn main() !void {
    try part1();
    try part2();
}

const width = 140; // Not including the \r\n
const height = 140;

fn get_index_from_coords(x: usize, y: usize) usize {
    return y * (width + 2) + x; // The 2 is there in order to account for the \r\n
}

fn get_char(x: usize, y: usize) u8 {
    const index = get_index_from_coords(x, y);
    return input[index];
}

fn part1() !void {
    var result: usize = 0;

    for (0..height) |y| {
        for (0..width) |x| {
            if (get_char(x, y) == 'X') {
                // Left
                if (x >= 3 and get_char(x-1, y) == 'M' and get_char(x-2, y) == 'A' and get_char(x-3, y) == 'S') {
                    result += 1;
                }

                // Right
                if (x + 3 < width and get_char(x+1, y) == 'M' and get_char(x+2, y) == 'A' and get_char(x+3, y) == 'S') {
                    result += 1;
                }

                // Up
                if (y >= 3 and get_char(x, y-1) == 'M' and get_char(x, y-2) == 'A' and get_char(x, y-3) == 'S') {
                    result += 1;
                }

                // Down
                if (y + 3 < height and get_char(x, y+1) == 'M' and get_char(x, y+2) == 'A' and get_char(x, y+3) == 'S') {
                    result += 1;
                }

                // Diagonal up-left
                if (x >= 3 and y >= 3 and get_char(x-1, y-1) == 'M' and get_char(x-2, y-2) == 'A' and get_char(x-3, y-3) == 'S') {
                    result += 1;
                }

                // Diagonal up-right
                if (x + 3 < width and y >= 3 and get_char(x+1, y-1) == 'M' and get_char(x+2, y-2) == 'A' and get_char(x+3, y-3) == 'S') {
                    result += 1;
                }

                // Diagonal down-left
                if (x >= 3 and y + 3 < height and get_char(x-1, y+1) == 'M' and get_char(x-2, y+2) == 'A' and get_char(x-3, y+3) == 'S') {
                    result += 1;
                }

                // Diagonal down-right
                if (x + 2 < width and y + 3 < height and get_char(x+1, y+1) == 'M' and get_char(x+2, y+2) == 'A' and get_char(x+3, y+3) == 'S') {
                    result += 1;
                }
            }
        }
    }

    std.debug.print("Part 1 result: {}\n", .{result});
}

fn part2() !void {
    var result: usize = 0;

    for (1..height-1) |y| {
        for (1..width-1) |x| {
            if (get_char(x, y) == 'A') {
                var found: usize = 0;
                if (get_char(x-1, y-1) == 'M' and get_char(x+1, y+1) == 'S') {
                    found += 1;
                }
                if (get_char(x+1, y-1) == 'M' and get_char(x-1, y+1) == 'S') {
                    found += 1;
                }
                if (get_char(x-1, y+1) == 'M' and get_char(x+1, y-1) == 'S') {
                    found += 1;
                }
                if (get_char(x+1, y+1) == 'M' and get_char(x-1, y-1) == 'S') {
                    found += 1;
                }
                if (found >= 2) {
                    result += 1;
                }
            }
        }
    }

    std.debug.print("Part 2 result: {}\n", .{result});
}


