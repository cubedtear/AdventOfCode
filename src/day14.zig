const std = @import("std");
const input = @embedFile("inputs/day14.txt");

const width: i64 = 101;
const height: i64 = 103;
const iterations: i64 = 100;

pub fn main() !void {
    try part1();
    try part2();
}

const Point = struct {
    x: i64,
    y: i64,
};

fn calculate_pos_after(px: i64, py: i64, vx: i64, vy: i64, iters: i64) !Point {
    return Point {
        .x = try std.math.mod(i64, px + vx * iters, width),
        .y = try std.math.mod(i64, py + vy * iters, height),
    };
}

fn part1() !void {
    var q1: i64 = 0;
    var q2: i64 = 0;
    var q3: i64 = 0;
    var q4: i64 = 0;

    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");
    while (line_it.next()) |line| {
        var line_parts_it = std.mem.tokenizeAny(u8, line, "p=, v");
        const pos_x = try std.fmt.parseInt(i64, line_parts_it.next() orelse unreachable, 10);
        const pos_y = try std.fmt.parseInt(i64, line_parts_it.next() orelse unreachable, 10);
        const vel_x = try std.fmt.parseInt(i64, line_parts_it.next() orelse unreachable, 10);
        const vel_y = try std.fmt.parseInt(i64, line_parts_it.next() orelse unreachable, 10);

        const pos = try calculate_pos_after(pos_x, pos_y, vel_x, vel_y, iterations);
        // std.debug.print("p={},{} v={},{} -> p={},{}\n", .{pos_x, pos_y, vel_x, vel_y, pos.x, pos.y});

        if (pos.x < try std.math.divFloor(i64, width, 2) and pos.y < try std.math.divFloor(i64, height, 2)) {
            q1 += 1;
        } else if (pos.x >= try std.math.divCeil(i64, width, 2) and pos.y < try std.math.divFloor(i64, height, 2)) {
            q2 += 1;
        } else if (pos.x < try std.math.divFloor(i64, width, 2) and pos.y >= try std.math.divCeil(i64, height, 2)) {
            q3 += 1;
        } else if (pos.x >= try std.math.divCeil(i64, width, 2) and pos.y >= try std.math.divCeil(i64, height, 2)) {
            q4 += 1;
        }

        // std.debug.print("p={},{} v={},{}\n", .{pos_x, pos_y, vel_x, vel_y});
    }

    // std.debug.print("Q1: {}\n", .{q1});
    // std.debug.print("Q2: {}\n", .{q2});
    // std.debug.print("Q3: {}\n", .{q3});
    // std.debug.print("Q4: {}\n", .{q4});

    std.debug.print("Part 1 result: {}\n", .{q1 * q2 * q3 * q4});
}

const Robot = struct {
    pos: Point,
    vel: Point,

    pub fn next_pos(self: *Robot, iter_count: i64) !void {
        const pos = try calculate_pos_after(self.pos.x, self.pos.y, self.vel.x, self.vel.y, iter_count);

        self.pos.x = pos.x;
        self.pos.y = pos.y;
    }
};

fn part2() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var robot_list = std.ArrayList(Robot).init(alloc);

    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");
    while (line_it.next()) |line| {
        var line_parts_it = std.mem.tokenizeAny(u8, line, "p=, v");
        const pos_x = try std.fmt.parseInt(i64, line_parts_it.next() orelse unreachable, 10);
        const pos_y = try std.fmt.parseInt(i64, line_parts_it.next() orelse unreachable, 10);
        const vel_x = try std.fmt.parseInt(i64, line_parts_it.next() orelse unreachable, 10);
        const vel_y = try std.fmt.parseInt(i64, line_parts_it.next() orelse unreachable, 10);

        try robot_list.append(Robot {
            .pos = Point { .x = pos_x, .y = pos_y },
            .vel = Point { .x = vel_x, .y = vel_y },
        });
    }

    const iter_count = 10000;

    for (0..iter_count) |iter| {
        var max_length: i32 = 0;
        for (0..height) |y| {
            var last_found = false;
            var found_length: i32 = 0;
            for (0..width) |x| {
                var found = false;
                for (robot_list.items) |robot| {
                    if (robot.pos.x == x and robot.pos.y == y) {
                        found = true;
                        break;
                    }
                }

                if (found) {
                    last_found = true;
                    found_length += 1;
                    if (found_length > max_length) {
                        max_length = found_length;
                    }
                } else {
                    last_found = false;
                    found_length = 0;
                }
                
            }
        }

        if (max_length > 8) {
            // var buffer = [_]u8{0} ** ((width + 2) * height * 2);
            // var stream = std.io.fixedBufferStream(&buffer);
            // var writer = stream.writer();
            // for (0..height) |y| {
            //     for (0..width) |x| {
            //         var found = false;
            //         for (robot_list.items) |robot| {
            //             if (robot.pos.x == x and robot.pos.y == y) {
            //                 found = true;
            //                 break;
            //             }
            //         }

            //         if (found) {
            //             try writer.print("##", .{});
            //         } else {
            //             try writer.print("  ", .{});
            //         }

            //     }
            //     try writer.print("\n", .{});
            // }

            // std.debug.print("Iter: {}\n{s}\n\n", .{iter, buffer[0..writer.context.pos]});
            std.debug.print("Part 2 result: {}\n", .{iter});
        }

        for (0..robot_list.items.len) |robot_idx| {
            try robot_list.items[robot_idx].next_pos(1);
        }
    }
}