const std = @import("std");
const input = @embedFile("inputs/day15.txt");

const width: usize = get_width();
const height: usize = get_height();

var input_copy: [(width + 2) * height]u8 = undefined;

inline fn get_width() usize {
    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");
    return line_it.next().?.len;
}

inline fn get_height() usize {
    @setEvalBranchQuota(5000);

    var last_char_was_newline = false;
    var lines = 1;
    for (input) |char| {
        if (char == '#' and last_char_was_newline) {
            lines += 1;
        }
        if (char == '\r' and last_char_was_newline) {
            break;
        }
        last_char_was_newline = char == '\n';
    }

    @setEvalBranchQuota(1000);
    return lines;
}

const part2_width: usize = width * 2;
const part2_height: usize = height;

var part2_input_copy = get_part2_input();

inline fn get_part2_input() [(part2_width + 2) * height]u8 {
    @setEvalBranchQuota(5000);

    var part2_input: [(part2_width + 2) * part2_height]u8 = undefined;

    var index = 0;
    inline for (0..(width + 2) * height) |idx| {
        const c = input[idx];
        if (c == '#') {
            part2_input[index] = '#';
            part2_input[index+1] = '#';
            index += 2;
        } else if (c == 'O') {
            part2_input[index] = '[';
            part2_input[index+1] = ']';
            index += 2;
        } else if (c == '.') {
            part2_input[index] = '.';
            part2_input[index+1] = '.';
            index += 2;
        } else if (c == '@') {
            part2_input[index] = '@';
            part2_input[index+1] = '.';
            index += 2;
        } else {
            part2_input[index] = c;
            index += 1;
        }
    }
    return part2_input;
}

pub fn main() !void {
    std.mem.copyForwards(u8, &input_copy, input[0..input_copy.len]);
    try part1();
    try part2();
}

fn part1() !void {
    const commands = input[(width + 2) * height + 2..];

    var robot_pos = blk: {
        for (0..height) |y| {
            for (0..width) |x| {
                const c = input_copy[get_index_from_coords(x, y)];
                if (c == '@') {
                    break :blk Point{ .x = x, .y = y };
                }
            }
        }
        unreachable;
    };

    // print_grid(&input_copy, width, height);

    for (commands) |move_char| {
        if (move_char == '\r' or move_char == '\n') {
            continue;
        }
        const move = switch (move_char) {
            '<' => Direction.left,
            '>' => Direction.right,
            '^' => Direction.up,
            'v' => Direction.down,
            else => unreachable,
        };
        robot_pos = push_in_direction(robot_pos, move);
        // std.debug.print("Move {c}:\n", .{move_char});
        // print_grid(&input_copy, width, height);
    }


    var result: usize = 0;
    for (0..height) |y| {
        for (0..width) |x| {
            const c = input_copy[get_index_from_coords(x, y)];
            if (c == 'O') {
                result += 100 * y + x;
            }
        }
    }

    std.debug.print("Part 1 result: {}\n", .{result});
}

const Point = struct {
    x: usize,
    y: usize,
};

const Direction = enum {
    left,
    right,
    up,
    down,
};

fn direction_to_str(dir: Direction) []const u8 {
    switch (dir) {
        Direction.left => return "left",
        Direction.right => return "right",
        Direction.up => return "up",
        Direction.down => return "down",
    }
    unreachable;
}

fn get_index_from_coords(x: usize, y: usize) usize {
    return y * (width + 2) + x; // The 2 is there in order to account for the \r\n
}

fn get_index_from_coords2(x: usize, y: usize) usize {
    return y * (part2_width + 2) + x; // The 2 is there in order to account for the \r\n
}

fn print_grid(grid: []const u8, w: usize, h: usize) void {
    std.debug.print("{s}\n", .{grid[0..(w + 2) * h]});
}

fn push_in_direction(p: Point, dir: Direction) Point {
    switch (dir) {
        Direction.left => return blk: {
            for (1..p.x) |dx| {
                const nx = p.x - dx;
                if (input_copy[get_index_from_coords(nx, p.y)] == '#') break :blk p;
                if (input_copy[get_index_from_coords(nx, p.y)] == '.') {
                    for (nx..p.x) |nnx| {
                        input_copy[get_index_from_coords(nnx, p.y)] = input_copy[get_index_from_coords(nnx + 1, p.y)];
                    }
                    input_copy[get_index_from_coords(p.x, p.y)] = '.';
                    break :blk Point{ .x = p.x-1, .y = p.y };
                }
            }
            break :blk p;
        },
        Direction.right => return blk: {
            for (p.x+1..width) |nx| {
                if (input_copy[get_index_from_coords(nx, p.y)] == '#') break :blk p;
                if (input_copy[get_index_from_coords(nx, p.y)] == '.') {
                    for (0..(nx - p.x)) |dnx| {
                        const nnx = nx - dnx;
                        input_copy[get_index_from_coords(nnx, p.y)] = input_copy[get_index_from_coords(nnx - 1, p.y)];
                    }
                    input_copy[get_index_from_coords(p.x, p.y)] = '.';
                    break :blk Point{ .x = p.x+1, .y = p.y };
                }
            }
            break :blk p;
        },
        Direction.up => return blk: {
            for (1..p.y) |dy| {
                const ny = p.y - dy;
                if (input_copy[get_index_from_coords(p.x, ny)] == '#') break :blk p;
                if (input_copy[get_index_from_coords(p.x, ny)] == '.') {
                    for (ny..p.y) |nny| {
                        input_copy[get_index_from_coords(p.x, nny)] = input_copy[get_index_from_coords(p.x, nny + 1)];
                    }
                    input_copy[get_index_from_coords(p.x, p.y)] = '.';
                    break :blk Point{ .x = p.x, .y = p.y-1 };
                }
            }
            break :blk p;
        },
        Direction.down => return blk: {
            for (p.y+1..height) |ny| {
                if (input_copy[get_index_from_coords(p.x, ny)] == '#') break :blk p;
                if (input_copy[get_index_from_coords(p.x, ny)] == '.') {
                    for (0..(ny - p.y)) |dny| {
                        const nny = ny - dny;
                        input_copy[get_index_from_coords(p.x, nny)] = input_copy[get_index_from_coords(p.x, nny - 1)];
                    }
                    input_copy[get_index_from_coords(p.x, p.y)] = '.';
                    break :blk Point{ .x = p.x, .y = p.y+1 };
                }
            }
            break :blk p;
        },
    }
    unreachable;
}

fn part2() !void {
    const commands = input[(width + 2) * height + 2..];

    var robot_pos = blk: {
        for (0..part2_height) |y| {
            for (0..part2_width) |x| {
                const c = part2_input_copy[get_index_from_coords2(x, y)];
                if (c == '@') {
                    break :blk Point{ .x = x, .y = y };
                }
            }
        }
        unreachable;
    };

    // std.debug.print("Robot pos: ({}, {})\n", .{robot_pos.x, robot_pos.y});
    // print_grid(&part2_input_copy, part2_width, part2_height);

    for (commands, 0..) |move_char, move_count| {
        if (move_char == '\r' or move_char == '\n') {
            continue;
        }

        const move = switch (move_char) {
            '<' => Direction.left,
            '>' => Direction.right,
            '^' => Direction.up,
            'v' => Direction.down,
            else => unreachable,
        };

        if (can_push_in_direction2(robot_pos, move)) {
            robot_pos = push_in_direction2(robot_pos, move);
        }
        _ = move_count;
        // std.debug.print("Move {c} (#{}):\n", .{move_char, move_count});
        // std.debug.print("Robot pos: ({}, {})\n", .{robot_pos.x, robot_pos.y});
        // print_grid(&part2_input_copy, part2_width, part2_height);
    }

    var result: usize = 0;
    for (0..part2_height) |y| {
        for (0..part2_width) |x| {
            const c = part2_input_copy[get_index_from_coords2(x, y)];
            if (c == '[') {
                result += 100 * y + x;
            }
        }
    }

    std.debug.print("Part 2 result: {}\n", .{result});
}

fn can_push_in_direction2(p: Point, dir: Direction) bool {
    switch (dir) {
        Direction.left => return blk: {
            const left_char = part2_input_copy[get_index_from_coords2(p.x-1, p.y)];
            if (left_char == '#') break :blk false;
            if (left_char == '.') return true;
            if (left_char == '[' or left_char == ']') {
                return can_push_in_direction2(Point{ .x = p.x-1, .y = p.y }, dir);
            }
            unreachable;
        },
        Direction.right => return blk: {
            const right_char = part2_input_copy[get_index_from_coords2(p.x+1, p.y)];
            if (right_char == '#') break :blk false;
            if (right_char == '.') return true;
            if (right_char == '[' or right_char == ']') {
                return can_push_in_direction2(Point{ .x = p.x+1, .y = p.y }, dir);
            }
            unreachable;
        },
        Direction.up => return blk: {
            const up_char = part2_input_copy[get_index_from_coords2(p.x, p.y - 1)];
            if (up_char == '#') break :blk false;
            if (up_char == '.') return true;
            if (up_char == ']') {
                return
                    can_push_in_direction2(Point{ .x = p.x - 1, .y = p.y-1 }, dir) and
                    can_push_in_direction2(Point{ .x = p.x, .y = p.y-1 }, dir);
            }
            if (up_char == '[') {
                return
                    can_push_in_direction2(Point{ .x = p.x, .y = p.y-1 }, dir) and
                    can_push_in_direction2(Point{ .x = p.x + 1, .y = p.y-1 }, dir);
            }
            unreachable;
        },
        Direction.down => return blk: {
            const down_char = part2_input_copy[get_index_from_coords2(p.x, p.y+1)];
            if (down_char == '#') break :blk false;
            if (down_char == '.') return true;
            if (down_char == ']') {
                return
                    can_push_in_direction2(Point{ .x = p.x - 1, .y = p.y+1 }, dir) and
                    can_push_in_direction2(Point{ .x = p.x, .y = p.y+1 }, dir);
            }
            if (down_char == '[') {
                return
                    can_push_in_direction2(Point{ .x = p.x, .y = p.y+1 }, dir) and
                    can_push_in_direction2(Point{ .x = p.x + 1, .y = p.y+1 }, dir);
            }
            unreachable;
        },
    }
    unreachable;
}

fn push_in_direction2(p: Point, dir: Direction) Point {
    if (part2_input_copy[get_index_from_coords2(p.x, p.y)] == '.') {
        return p;
    }
    switch (dir) {
        Direction.left => {
            const left_char = part2_input_copy[get_index_from_coords2(p.x-1, p.y)];
            if (left_char == '#') unreachable;
            if (left_char != '.') {
                _ = push_in_direction2(Point{ .x = p.x-1, .y = p.y }, dir);
            }
            part2_input_copy[get_index_from_coords2(p.x-1, p.y)] = part2_input_copy[get_index_from_coords2(p.x, p.y)];
            part2_input_copy[get_index_from_coords2(p.x, p.y)] = '.';
            return Point{ .x = p.x-1, .y = p.y };
        },
        Direction.right => {
            const right_char = part2_input_copy[get_index_from_coords2(p.x+1, p.y)];
            if (right_char == '#') unreachable;
            if (right_char != '.') {
                _ = push_in_direction2(Point{ .x = p.x+1, .y = p.y }, dir);
            }
            part2_input_copy[get_index_from_coords2(p.x+1, p.y)] = part2_input_copy[get_index_from_coords2(p.x, p.y)];
            part2_input_copy[get_index_from_coords2(p.x, p.y)] = '.';
            return Point{ .x = p.x+1, .y = p.y };
        },
        Direction.up => {
            const up_char = part2_input_copy[get_index_from_coords2(p.x, p.y-1)];
            if (up_char == '#') unreachable;
            if (up_char == ']') {
                _ = push_in_direction2(Point{ .x = p.x - 1, .y = p.y-1 }, dir);
                _ = push_in_direction2(Point{ .x = p.x, .y = p.y-1 }, dir);
            }
            if (up_char == '[') {
                _ = push_in_direction2(Point{ .x = p.x, .y = p.y-1 }, dir);
                _ = push_in_direction2(Point{ .x = p.x + 1, .y = p.y-1 }, dir);
            }
            part2_input_copy[get_index_from_coords2(p.x, p.y-1)] = part2_input_copy[get_index_from_coords2(p.x, p.y)];
            part2_input_copy[get_index_from_coords2(p.x, p.y)] = '.';
            return Point{ .x = p.x, .y = p.y-1 };
        },
        Direction.down => {
            const down_char = part2_input_copy[get_index_from_coords2(p.x, p.y+1)];
            if (down_char == '#') unreachable;
            if (down_char == ']') {
                _ = push_in_direction2(Point{ .x = p.x - 1, .y = p.y+1 }, dir);
                _ = push_in_direction2(Point{ .x = p.x, .y = p.y+1 }, dir);
            }
            if (down_char == '[') {
                _ = push_in_direction2(Point{ .x = p.x, .y = p.y+1 }, dir);
                _ = push_in_direction2(Point{ .x = p.x+1, .y = p.y+1 }, dir);
            }
            part2_input_copy[get_index_from_coords2(p.x, p.y+1)] = part2_input_copy[get_index_from_coords2(p.x, p.y)];
            part2_input_copy[get_index_from_coords2(p.x, p.y)] = '.';
            return Point{ .x = p.x, .y = p.y+1 };
        },
    }
    unreachable;
}
