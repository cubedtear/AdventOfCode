const std = @import("std");
const input = @embedFile("inputs/day10.txt");

const width = 40; // Not including the \r\n
const height = 40;

var visited = [_]bool{false} ** ((width + 2) * height);


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

fn part1() !void {
    var result: usize = 0;
    for (0..height) |y1| {
        for (0..width) |x1| {
            if (get_char(x1, y1) != '0') {
                // Not a trailhead
                continue;
            }
            @memset(&visited, false);
            const score = find_reachable_9s(x1, y1);
            result += score;
        }
    }

    std.debug.print("Part 1: {}\n", .{result});
}

fn find_reachable_9s(x: usize, y: usize) usize {
    const current_value = get_char(x, y);

    if (current_value == '9') {
        if (visited[get_index_from_coords(x, y)]) {
            return 0;
        } else {
            visited[get_index_from_coords(x, y)] = true;
            return 1;
        }
    }

    var result: usize = 0;
    if (x + 1 < width and get_char(x+1, y) == current_value + 1) {
        result += find_reachable_9s(x+1, y);
    }

    if (x > 0 and get_char(x-1, y) == current_value + 1) {
        result += find_reachable_9s(x-1, y);
    }

    if (y + 1 < height and get_char(x, y+1) == current_value + 1) {
        result += find_reachable_9s(x, y+1);
    }

    if (y > 0 and get_char(x, y-1) == current_value + 1) {
        result += find_reachable_9s(x, y-1);
    }

    return result;
}

fn part2() !void {
    var result: usize = 0;
    for (0..height) |y1| {
        for (0..width) |x1| {
            if (get_char(x1, y1) != '0') {
                // Not a trailhead
                continue;
            }
            const score = find_paths_to_9s(x1, y1);
            result += score;
        }
    }

    std.debug.print("Part 2: {}\n", .{result});
}

fn find_paths_to_9s(x: usize, y: usize) usize {
    const current_value = get_char(x, y);

    if (current_value == '9') {
        return 1;
    }

    var result: usize = 0;
    if (x + 1 < width and get_char(x+1, y) == current_value + 1) {
        result += find_paths_to_9s(x+1, y);
    }

    if (x > 0 and get_char(x-1, y) == current_value + 1) {
        result += find_paths_to_9s(x-1, y);
    }

    if (y + 1 < height and get_char(x, y+1) == current_value + 1) {
        result += find_paths_to_9s(x, y+1);
    }

    if (y > 0 and get_char(x, y-1) == current_value + 1) {
        result += find_paths_to_9s(x, y-1);
    }

    return result;
}