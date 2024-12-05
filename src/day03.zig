const std = @import("std");
const input = @embedFile("inputs/day03.txt");

pub fn main() !void {
    try part1();
    try part2();
}

// Expected output (calculated by hand using regex + python): 183380722
fn part1() !void {
    var result: u32 = 0;

    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");
    while (line_it.next()) |line| {
        const trimmed_line = std.mem.trimRight(u8, line, "\r\n");
        var potential_instruction_it = std.mem.tokenizeSequence(u8, trimmed_line, "mul(");

        while (potential_instruction_it.next()) |potential_instruction| {
            if (potential_instruction.len < 4) {
                continue;
            }

            const paren_index = std.mem.indexOf(u8, potential_instruction, ")") orelse continue;

            const instruction = potential_instruction[0..paren_index];
            var instruction_it = std.mem.tokenizeSequence(u8, instruction, ",");
            const op1_str = instruction_it.next() orelse continue;
            const op2_str = instruction_it.next() orelse continue;

            const op1 = std.fmt.parseInt(u32, op1_str, 10) catch continue;
            const op2 = std.fmt.parseInt(u32, op2_str, 10) catch continue;

            result += op1 * op2;
        }
    }

    std.debug.print("Part 1 result: {}\n", .{result});
}

fn part2() !void {
    var result: u32 = 0;

    var ignore = false;

    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");
    while (line_it.next()) |line| {
        const trimmed_line = std.mem.trimRight(u8, line, "\r\n");

        var potential_do_dont_it = std.mem.tokenizeSequence(u8, trimmed_line, "do");
        while (potential_do_dont_it.next()) |potential_do_dont| {
            if (potential_do_dont.len >= 2 and std.mem.eql(u8, potential_do_dont[0..2], "()")) {
                ignore = false;
            } else if (potential_do_dont.len >= 5 and std.mem.eql(u8, potential_do_dont[0..5], "n't()")) {
                ignore = true;
            }

            if (ignore) {
                continue;
            }

            var potential_instruction_it = std.mem.tokenizeSequence(u8, potential_do_dont, "mul(");
            while (potential_instruction_it.next()) |potential_instruction| {
                if (potential_instruction.len < 4) {
                    continue;
                }

                const paren_index = std.mem.indexOf(u8, potential_instruction, ")") orelse continue;

                const instruction = potential_instruction[0..paren_index];
                var instruction_it = std.mem.tokenizeSequence(u8, instruction, ",");
                const op1_str = instruction_it.next() orelse continue;
                const op2_str = instruction_it.next() orelse continue;

                const op1 = std.fmt.parseInt(u32, op1_str, 10) catch continue;
                const op2 = std.fmt.parseInt(u32, op2_str, 10) catch continue;

                result += op1 * op2;
            }
        }
    }

    std.debug.print("Part 2 result: {}\n", .{result});
}


