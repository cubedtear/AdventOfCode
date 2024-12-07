const std = @import("std");
const input = @embedFile("inputs/day06.txt");


const width = 130; // Not including the \r\n
const height = 130;
var input_copy: [(width + 2) * height]u8 = undefined;

pub fn main() !void {
    std.mem.copyForwards(u8, &input_copy, input);
    try part1();

    // The input is reset inside part2 for each iteration, so no need to do it here
    try part2();
}

fn get_index_from_coords(x: usize, y: usize) usize {
    return y * (width + 2) + x; // The 2 is there in order to account for the \r\n
}

fn get_char(x: usize, y: usize) u8 {
    const index = get_index_from_coords(x, y);
    return input_copy[index];
}

const Direction = enum {
    left,
    right,
    up,
    down,
};

fn is_next_tile_obstacle(x: usize, y: usize, dir: Direction) bool {
    switch (dir) {
        .left => return x == 0 or get_char(x - 1, y) == '#',
        .right => return x == width - 1 or get_char(x + 1, y) == '#',
        .up => return y == 0 or get_char(x, y - 1) == '#',
        .down => return y == height - 1 or get_char(x, y + 1) == '#',
    }
}

fn is_next_tile_outside(x: usize, y: usize, dir: Direction) bool {
    switch (dir) {
        .left => return x == 0,
        .right => return x == width - 1,
        .up => return y == 0,
        .down => return y == height - 1,
    }
}

fn mark_visited_tile(x: usize, y: usize, dir: Direction) bool {
    const index = get_index_from_coords(x, y);
    var result = false;
    if (input_copy[index] < 'A' or (input_copy[index] > 'A' + 15)) {
        // This condition is purely aesthetic, to show the ^ icon in the starting position
        if (input_copy[index] != '^') {
            input_copy[index] = 'A';
        }
        result = true;
    }

    const dir_bit: u8 = switch (dir) {
        .left => 1,
        .right => 2,
        .up => 4,
        .down => 8,
    };

    // This condition is purely aesthetic, to show the ^ icon in the starting position
    if (input_copy[index] != '^') {
        input_copy[index] = 'A' + ((input_copy[index] - 'A') | dir_bit);
    }
    return result;
}

fn is_visited_tile(x: usize, y: usize, dir: Direction) bool {
    const index = get_index_from_coords(x, y);

    const dir_bit: u8 = switch (dir) {
        .left => 1,
        .right => 2,
        .up => 4,
        .down => 8,
    };

    return input_copy[index] > 'A' and (input_copy[index] < 'A' + 15) and ((input_copy[index] - 'A') & dir_bit) != 0;
}

fn get_next_direction(dir: Direction) Direction {
    return switch (dir) {
        .left => Direction.up,
        .up => Direction.right,
        .right => Direction.down,
        .down => Direction.left,
    };
}


fn part1() !void {
    var result: usize = 0;

    var dir = Direction.up;
    var x: usize = 89;
    var y: usize = 84;

    while (!is_visited_tile(x, y, dir)) {
        if (mark_visited_tile(x, y, dir)) {
            result += 1;
        }

        if (is_next_tile_outside(x, y, dir)) {
            break;
        }

        if (is_next_tile_obstacle(x, y, dir)) {
            dir = get_next_direction(dir);
        } else {
            switch (dir) {
                .left => x -= 1,
                .right => x += 1,
                .up => y -= 1,
                .down => y += 1,
            }
        }
    }

    // Print the result
    // std.log.debug("\n{s}", .{input_copy});

    std.debug.print("Part 1 result: {}\n", .{result});
}

fn part2() !void {
    var result: usize = 0;

    for (0..height) |obstacle_y| {
        for (0..width) |obstacle_x| {
            // Reset the input for each iteration
            std.mem.copyForwards(u8, &input_copy, input);

            // Skip if there is anything already there
            if (get_char(obstacle_x, obstacle_y) != '.') {
                continue;
            }

            // Add the obstacle
            input_copy[get_index_from_coords(obstacle_x, obstacle_y)] = '#';

            // Check for loops after adding the obstacle
            var dir = Direction.up;
            var x: usize = 89;
            var y: usize = 84;
            var broke_because_outside = false;
            while (!is_visited_tile(x, y, dir)) {
                _ = mark_visited_tile(x, y, dir);

                if (is_next_tile_outside(x, y, dir)) {
                    broke_because_outside = true;
                    break;
                }

                if (is_next_tile_obstacle(x, y, dir)) {
                    dir = get_next_direction(dir);
                } else {
                    switch (dir) {
                        .left => x -= 1,
                        .right => x += 1,
                        .up => y -= 1,
                        .down => y += 1,
                    }
                }
            }
            if (is_visited_tile(x, y, dir) and !broke_because_outside) {
                result += 1;
            }
        }
    }

    std.debug.print("Part 2 result: {}\n", .{result});
}
