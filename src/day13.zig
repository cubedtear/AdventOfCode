const std = @import("std");
const input = @embedFile("inputs/day13.txt");

pub fn main() !void {
    try part1();
    try part2();
}

fn part1() !void {
    var result: i64 = 0;

    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");
    while (line_it.next()) |first_line| {
        const a_dx = try std.fmt.parseInt(i64, first_line[12..14], 10);
        const a_dy = try std.fmt.parseInt(i64, first_line[18..20], 10);

        const second_line = line_it.next() orelse unreachable;
        const b_dx = try std.fmt.parseInt(i64, second_line[12..14], 10);
        const b_dy = try std.fmt.parseInt(i64, second_line[18..20], 10);

        const third_line = line_it.next() orelse unreachable;
        const r_trimmed_third_line = std.mem.trimRight(u8, third_line, "\r\n");
        const rl_trimmed_third_line = r_trimmed_third_line[9..];

        var p_value_it = std.mem.tokenizeSequence(u8, rl_trimmed_third_line, ", Y=");
        const px = try std.fmt.parseInt(i64, p_value_it.next() orelse unreachable, 10);
        const py = try std.fmt.parseInt(i64, p_value_it.next() orelse unreachable, 10);

        if ((b_dy * a_dx - b_dx * a_dy) == 0) {
            // Denominator is zero, skip
            continue;
        }
        const b_presses = std.math.divExact(i64, a_dx * py - a_dy * px, b_dy * a_dx - b_dx * a_dy) catch |e| switch (e) {
            error.UnexpectedRemainder => {
                // Non-integer solution, skip
                continue;
            },
            else => {
                return e;
            },
        };

        if (a_dx == 0) {
            // Denominator is zero, skip
            continue;
        }
        const a_presses = std.math.divExact(i64, px - b_dx * b_presses, a_dx) catch |e| switch (e) {
            error.UnexpectedRemainder => {
                // Non-integer solution, skip
                continue;
            },
            else => {
                return e;
            },
        };

        if (a_presses > 100 or b_presses > 100) {
            // Too far, skip
            continue;
        }

        // std.debug.print("A: {} - B: {}\n", .{a_presses, b_presses});

        result += 3 * a_presses + b_presses;
    }

    std.debug.print("Part 1 result: {}\n", .{result});
}


fn part2() !void {
    var result: i64 = 0;

    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");
    while (line_it.next()) |first_line| {
        const a_dx = try std.fmt.parseInt(i64, first_line[12..14], 10);
        const a_dy = try std.fmt.parseInt(i64, first_line[18..20], 10);

        const second_line = line_it.next() orelse unreachable;
        const b_dx = try std.fmt.parseInt(i64, second_line[12..14], 10);
        const b_dy = try std.fmt.parseInt(i64, second_line[18..20], 10);

        const third_line = line_it.next() orelse unreachable;
        const r_trimmed_third_line = std.mem.trimRight(u8, third_line, "\r\n");
        const rl_trimmed_third_line = r_trimmed_third_line[9..];

        var p_value_it = std.mem.tokenizeSequence(u8, rl_trimmed_third_line, ", Y=");
        const file_px = try std.fmt.parseInt(i64, p_value_it.next() orelse unreachable, 10);
        const file_py = try std.fmt.parseInt(i64, p_value_it.next() orelse unreachable, 10);

        const px = file_px + 10000000000000;
        const py = file_py + 10000000000000;

        if ((b_dy * a_dx - b_dx * a_dy) == 0) {
            // Denominator is zero, skip
            continue;
        }
        const b_presses = std.math.divExact(i64, a_dx * py - a_dy * px, b_dy * a_dx - b_dx * a_dy) catch |e| switch (e) {
            error.UnexpectedRemainder => {
                // Non-integer solution, skip
                continue;
            },
            else => {
                return e;
            },
        };

        if (a_dx == 0) {
            // Denominator is zero, skip
            continue;
        }
        const a_presses = std.math.divExact(i64, px - b_dx * b_presses, a_dx) catch |e| switch (e) {
            error.UnexpectedRemainder => {
                // Non-integer solution, skip
                continue;
            },
            else => {
                return e;
            },
        };

        // std.debug.print("A: {} - B: {}\n", .{a_presses, b_presses});

        result += 3 * a_presses + b_presses;
    }

    std.debug.print("Part 2 result: {}\n", .{result});
}