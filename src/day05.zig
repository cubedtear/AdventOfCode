const std = @import("std");
const input = @embedFile("inputs/day05.txt");

pub fn main() !void {
    try part1();
    try part2();
}

fn part1() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var rule_list = std.ArrayList(struct{usize, usize}).init(alloc);

    var line_it = std.mem.splitAny(u8, input, "\r\n");
    while (line_it.next()) |line| {
        _ = line_it.next(); // Skip the empty pieces between \r and \n
        const trimmed_line = std.mem.trimRight(u8, line, "\r\n");

        if (trimmed_line.len == 0) {
            // Start reading rules
            break;
        }

        const op1 = @as(usize, (trimmed_line[0] - '0')) * 10 + @as(usize, (trimmed_line[1] - '0'));
        const op2 = @as(usize, (trimmed_line[3] - '0')) * 10 + @as(usize, (trimmed_line[4] - '0'));

        try rule_list.append(.{op1, op2});
    }


    var result: usize = 0;
    while (line_it.next()) |line| {
        _ = line_it.next(); // Skip the empty pieces between \r and \n
        const trimmed_line = std.mem.trimRight(u8, line, "\r\n");
        if (trimmed_line.len == 0) {
            break;
        }

        var updates = std.ArrayList(usize).init(alloc);

        var number_it = std.mem.tokenizeScalar(u8, trimmed_line, ',');
        while (number_it.next()) |number| {
            const num = try std.fmt.parseInt(usize, number, 10);
            try updates.append(num);
        }


        var follows_all_rules = true;

        for (rule_list.items) |rule| {
            if (!check_rule(rule, updates.items)) {
                follows_all_rules = false;
            }
        }

        if (follows_all_rules) {
            result += updates.items[(updates.items.len - 1) / 2];
        }
    }

    std.debug.print("Part 1: {}\n", .{result});
}

fn part2() !void {
    // Options for part 2:
    // 1. After reading the rules, get a list of numbers in the rules, and sort them topologically.
    //    This creates a bijection between the numbers and indices.
    //    Then, for each update, convert numbers to their indices, sort the list, and convert back to numbers.
    // 2. For each update, check which rules it violates, and move the first number to just before the second number. (or viceversa)
    //    Then, check all rules again. If it violates any, repeat. If it doesn't, add the middle number to the result.

    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var rule_list = std.ArrayList(struct{usize, usize}).init(alloc);

    var line_it = std.mem.splitAny(u8, input, "\r\n");
    while (line_it.next()) |line| {
        _ = line_it.next(); // Skip the empty pieces between \r and \n
        const trimmed_line = std.mem.trimRight(u8, line, "\r\n");

        if (trimmed_line.len == 0) {
            // Start reading rules
            break;
        }

        const op1 = @as(usize, (trimmed_line[0] - '0')) * 10 + @as(usize, (trimmed_line[1] - '0'));
        const op2 = @as(usize, (trimmed_line[3] - '0')) * 10 + @as(usize, (trimmed_line[4] - '0'));

        try rule_list.append(.{op1, op2});
    }


    var result: usize = 0;
    while (line_it.next()) |line| {
        _ = line_it.next(); // Skip the empty pieces between \r and \n
        const trimmed_line = std.mem.trimRight(u8, line, "\r\n");
        if (trimmed_line.len == 0) {
            break;
        }

        var updates = std.ArrayList(usize).init(alloc);

        var number_it = std.mem.tokenizeScalar(u8, trimmed_line, ',');
        while (number_it.next()) |number| {
            const num = try std.fmt.parseInt(usize, number, 10);
            try updates.append(num);
        }


        var violates_rule_index: ?usize = null;

        for (rule_list.items, 0..) |rule, index| {
            if (!check_rule(rule, updates.items)) {
                violates_rule_index = index;
                break;
            }
        }

        if (violates_rule_index == null) {
            continue;
        }

        while (violates_rule_index) |first_violated_rule_index| {
            const violated_rule = rule_list.items[first_violated_rule_index];

            const op1 = violated_rule.@"0";
            const op2 = violated_rule.@"1";

            const index_of_op1 = std.mem.indexOfScalar(usize, updates.items, op1) orelse @panic("Op1 not found");
            const index_of_op2 = std.mem.indexOfScalar(usize, updates.items, op2) orelse @panic("Op2 not found");

            // Take op1 (which must be after op2 because the rule is violated). Move everything between op2 and op1 to the right.
            // Then, move op1 to the left of op2.
            const dest = updates.items[index_of_op2+1..index_of_op1+1];
            const src = updates.items[index_of_op2..index_of_op1];

            std.mem.copyBackwards(usize, dest, src);
            updates.items[index_of_op2] = op1;

            violates_rule_index = null;
            for (rule_list.items, 0..) |rule, index| {
                if (!check_rule(rule, updates.items)) {
                    violates_rule_index = index;
                    break;
                }
            }
        }
        result += updates.items[(updates.items.len - 1) / 2];
    }

    std.debug.print("Part 2: {}\n", .{result});
}

fn check_rule(rule: struct{usize, usize}, updates: []usize) bool {
    const op1 = rule.@"0";
    const op2 = rule.@"1";

    var found_op1 = false;
    var found_op2_before_op1 = false;

    for (updates) |update| {
        if (update == op1) {
            found_op1 = true;
        } else if (update == op2) {
            if (!found_op1) {
                found_op2_before_op1 = true;
            }
        }
    }

    return !found_op2_before_op1 or !found_op1;
}

