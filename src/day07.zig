const std = @import("std");
const input = @embedFile("inputs/day07.txt");

pub fn main() !void {
    try part1();
    try part2();
}

fn part1() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var result: u64 = 0;

    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");
    while (line_it.next()) |line| {
        const trimmed_line = std.mem.trimRight(u8, line, "\r\n");

        if (trimmed_line.len == 0) {
            break;
        }

        var equation_it = std.mem.tokenizeSequence(u8, trimmed_line, ": ");
        const expected_result_str = equation_it.next() orelse @panic("Line doesn't match expected format");
        const operands_str = equation_it.next() orelse @panic("Line doesn't match expected format");

        const expected_result = try std.fmt.parseInt(u64, expected_result_str, 10);

        var operands_it = std.mem.tokenizeScalar(u8, operands_str, ' ');
        var operands_list = std.ArrayList(u64).init(alloc);

        while (operands_it.next()) |operand_str| {
            const operand = try std.fmt.parseInt(u64, operand_str, 10);
            try operands_list.append(operand);
        }

        // std.log.debug("Expected: {} - Values: {any}", .{expected_result, operands_list.items});
        if (is_expected_value_possible_part_1(operands_list.items[0], operands_list.items[1..], expected_result)) {
            result += expected_result;
        }
    }

    std.debug.print("Part 1: {}\n", .{result});
}

fn is_expected_value_possible_part_1(previous_value: u64, operands: []u64, expected_value: u64) bool {
    // std.log.debug("  - Current: {} - Remaining: {any}", .{previous_value, operands});
    if (operands.len == 0) {
        return previous_value == expected_value;
    }

    const operand = operands[0];
    const remaining_operands = operands[1..];

    return is_expected_value_possible_part_1(previous_value + operand, remaining_operands, expected_value) or
           is_expected_value_possible_part_1(previous_value * operand, remaining_operands, expected_value);
}

fn part2() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var result: u64 = 0;

    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");
    while (line_it.next()) |line| {
        const trimmed_line = std.mem.trimRight(u8, line, "\r\n");

        if (trimmed_line.len == 0) {
            break;
        }

        var equation_it = std.mem.tokenizeSequence(u8, trimmed_line, ": ");
        const expected_result_str = equation_it.next() orelse @panic("Line doesn't match expected format");
        const operands_str = equation_it.next() orelse @panic("Line doesn't match expected format");

        const expected_result = try std.fmt.parseInt(u64, expected_result_str, 10);

        var operands_it = std.mem.tokenizeScalar(u8, operands_str, ' ');
        var operands_list = std.ArrayList(u64).init(alloc);

        while (operands_it.next()) |operand_str| {
            const operand = try std.fmt.parseInt(u64, operand_str, 10);
            try operands_list.append(operand);
        }

        // std.log.debug("Expected: {} - Values: {any}", .{expected_result, operands_list.items});
        if (is_expected_value_possible_part_2(operands_list.items[0], operands_list.items[1..], expected_result)) {
            result += expected_result;
        }
    }

    std.debug.print("Part 2: {}\n", .{result});
}

fn is_expected_value_possible_part_2(previous_value: u64, operands: []u64, expected_value: u64) bool {
    // std.log.debug("  - Current: {} - Remaining: {any}", .{previous_value, operands});
    if (operands.len == 0) {
        return previous_value == expected_value;
    }

    const operand = operands[0];
    const remaining_operands = operands[1..];

    const concatenated = if (operand < 10) blk: {
        break :blk previous_value * 10 + operand;
    } else if (operand < 100) blk: {
        break :blk previous_value * 100 + operand;
    } else blk: {
        break :blk previous_value * 1000 + operand;
    };

    return is_expected_value_possible_part_2(previous_value + operand, remaining_operands, expected_value) or
           is_expected_value_possible_part_2(previous_value * operand, remaining_operands, expected_value) or
           is_expected_value_possible_part_2(concatenated, remaining_operands, expected_value);
}
