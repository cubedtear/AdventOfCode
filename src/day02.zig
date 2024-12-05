const std = @import("std");
const input = @embedFile("inputs/day02.txt");

pub fn main() !void {
    try part1();
    try part2();
}

fn part1() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var valid_count: u32 = 0;

    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");
    while (line_it.next()) |line| {
        const trimmed_line = std.mem.trimRight(u8, line, "\r\n");
        var value_it = std.mem.tokenizeSequence(u8, trimmed_line, " ");

        var report = std.ArrayList(u32).init(alloc);

        while (value_it.next()) |value_str| {
            const current_value = try std.fmt.parseInt(u32, value_str, 10);
            try report.append(current_value);
        }
        if (try test_report(report.items, null)) {
            valid_count += 1;
        }
    }

    std.debug.print("Part 1 result: {}\n", .{valid_count});
}

fn part2() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var valid_count: u32 = 0;

    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");
    while (line_it.next()) |line| {
        const trimmed_line = std.mem.trimRight(u8, line, "\r\n");
        var value_it = std.mem.tokenizeSequence(u8, trimmed_line, " ");

        var report = std.ArrayList(u32).init(alloc);

        while (value_it.next()) |value_str| {
            const current_value = try std.fmt.parseInt(u32, value_str, 10);
            try report.append(current_value);
        }

        if (try test_report(report.items, null)) {
            valid_count += 1;
        } else {
            for (0..report.items.len) |index| {
                if (try test_report(report.items, index)) {
                    valid_count += 1;
                    break;
                }
            }
        }
    }

    std.debug.print("Part 2 result: {}\n", .{valid_count});
}

fn test_report(report: []const u32, index_to_ignore: ?usize) !bool {
    var last_value = if (index_to_ignore == 0) report[1] else report[0];
    const start_index: u32 = if (index_to_ignore == 0) 2 else 1;
    var increasing: ?bool = null;
    var valid = true;

    for (report[start_index..], start_index..) |value, index| {
        if (index_to_ignore != null and index == index_to_ignore) {
            continue;
        }

        if (increasing == null) {
            increasing = value > last_value;
        }

        if (value == last_value or increasing != (value > last_value)) {
            valid = false;
            break;
        } else if (@max(value, last_value) - @min(value, last_value) > 3) {
            valid = false;
            break;
        } else {
            last_value = value;
            continue;
        }
    }

    // std.log.debug("Case: {any} - Ignoring: {?} - Result: {}", .{report, index_to_ignore, valid});

    return valid;
}
