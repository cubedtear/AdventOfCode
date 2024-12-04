const std = @import("std");

const run_day = @import("step_list.zig").run_day;

pub fn main() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();
    var argIter = try std.process.argsWithAllocator(alloc);


    _ = argIter.next(); // Skip the first argument, which is the executable name.

    if (argIter.next()) |arg| {
        const day = std.fmt.parseInt(u32, arg, 10) catch {
            std.log.err("Failed to parse day number: {s}\n", .{arg});
            return;
        };

        try run_day(day);
    } else {
        std.log.warn("No day number provided", .{});
        std.log.warn("Usage: zig build run -- 1", .{});
    }
}