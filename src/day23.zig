const std = @import("std");
const input = @embedFile("inputs/day23.txt");

const Allocator = std.mem.Allocator;

pub fn main() !void {
    try part1();
    try part2();
}

fn part1() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    // var result: usize = 0;

    var name_to_idx_hashmap = std.StringHashMap(usize).init(alloc);
    var idx_to_name_hashmap = std.AutoHashMap(usize, []const u8).init(alloc);

    // There are at most 1000 nodes
    var adj_matrix = [_][1000]bool{[_]bool{false} ** 1000} ** 1000;

    var conection_it = std.mem.tokenizeAny(u8, input, "\n\r");
    while (conection_it.next()) |connection| {
        const left = connection[0..2];
        const right = connection[3..5];

        const left_idx = blk: {
            if (name_to_idx_hashmap.contains(left)) {
                break :blk name_to_idx_hashmap.get(left).?;
            } else {
                const idx = name_to_idx_hashmap.count();
                try name_to_idx_hashmap.put(left, idx);
                try idx_to_name_hashmap.put(idx, left);
                break :blk idx;
            }
        };
        const right_idx = blk: {
            if (name_to_idx_hashmap.contains(right)) {
                break :blk name_to_idx_hashmap.get(right).?;
            } else {
                const idx = name_to_idx_hashmap.count();
                try name_to_idx_hashmap.put(right, idx);
                try idx_to_name_hashmap.put(idx, right);
                break :blk idx;
            }
        };

        adj_matrix[left_idx][right_idx] = true;
        adj_matrix[right_idx][left_idx] = true;
    }

    var result: usize = 0;

    for (0..name_to_idx_hashmap.count()) |first_idx| {
        const first_name = idx_to_name_hashmap.get(first_idx).?;
        for (first_idx+1..name_to_idx_hashmap.count()) |second_idx| {
            if (adj_matrix[first_idx][second_idx]) {
                const second_name = idx_to_name_hashmap.get(second_idx).?;
                for (second_idx+1..name_to_idx_hashmap.count()) |third_idx| {
                    if (adj_matrix[second_idx][third_idx] and adj_matrix[first_idx][third_idx]) {
                        const third_name = idx_to_name_hashmap.get(third_idx).?;

                        if (first_name[0] != 't' and second_name[0] != 't' and third_name[0] != 't') {
                            continue;
                        }

                        result += 1;

                        // std.debug.print("Found a triangle: {s} -> {s} -> {s}\n", .{first_name, second_name, third_name});
                    }
                }
            }

        }
    }

    std.debug.print("Part 1 result: {}\n", .{result});
}

fn part2() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    // var result: usize = 0;

    var name_to_idx_hashmap = std.StringHashMap(usize).init(alloc);
    var idx_to_name_hashmap = std.AutoHashMap(usize, []const u8).init(alloc);

    // There are at most 1000 nodes
    var adj_matrix = [_][1000]bool{[_]bool{false} ** 1000} ** 1000;

    var conection_it = std.mem.tokenizeAny(u8, input, "\n\r");
    while (conection_it.next()) |connection| {
        const left = connection[0..2];
        const right = connection[3..5];

        const left_idx = blk: {
            if (name_to_idx_hashmap.contains(left)) {
                break :blk name_to_idx_hashmap.get(left).?;
            } else {
                const idx = name_to_idx_hashmap.count();
                try name_to_idx_hashmap.put(left, idx);
                try idx_to_name_hashmap.put(idx, left);
                break :blk idx;
            }
        };
        const right_idx = blk: {
            if (name_to_idx_hashmap.contains(right)) {
                break :blk name_to_idx_hashmap.get(right).?;
            } else {
                const idx = name_to_idx_hashmap.count();
                try name_to_idx_hashmap.put(right, idx);
                try idx_to_name_hashmap.put(idx, right);
                break :blk idx;
            }
        };

        adj_matrix[left_idx][right_idx] = true;
        adj_matrix[right_idx][left_idx] = true;
    }

    // var result: usize = 0;

    const result = try bron_kerbosch_initial(alloc, &adj_matrix);

    var clique_names = std.ArrayList([]const u8).init(alloc);

    for (result.clique.?, 0..) |v, idx| {
        if (v) {
            const name = idx_to_name_hashmap.get(idx).?;
            try clique_names.append(name);
        }
    }
    alloc.free(result.clique.?);

    std.mem.sort([]const u8, clique_names.items, {}, comptime lexicograpic_str_less_than);

    std.debug.print("Part 2 result: ", .{});
    for (clique_names.items, 0..) |name, idx| {
        std.debug.print("{s}", .{name});
        if (idx + 1 != clique_names.items.len) {
            std.debug.print(",", .{});
        }
    }

    std.debug.print("\n", .{});
}

fn lexicograpic_str_less_than(_: void, a: []const u8, b: []const u8) bool {
    for (a, b) |a_char, b_char| {
        if (a_char < b_char) {
            return true;
        } else if (a_char > b_char) {
            return false;
        }
    }
    return false;
}

const BronKerboschResult = struct {
    clique_size: ?usize,
    clique: ?[]bool,
};

// Returns the indices of the nodes in the maximal clique. Memory of result must be freed by the caller.
fn bron_kerbosch_initial(
    alloc: Allocator,
    adjacency_matrix: anytype,
) !BronKerboschResult {
    const r = try alloc.alloc(bool, adjacency_matrix.len);
    const p = try alloc.alloc(bool, adjacency_matrix.len);
    const x = try alloc.alloc(bool, adjacency_matrix.len);

    @memset(r, false);
    @memset(p, true);
    @memset(x, false);

    const sliced_adj_matrix = try alloc.alloc([]const bool, adjacency_matrix.len);
    for (0..adjacency_matrix.len) |idx| {
        sliced_adj_matrix[idx] = &adjacency_matrix[idx];
    }

    return bron_kerbosch(alloc, sliced_adj_matrix, r, p, x);
}

// Returns the indices of the nodes in the maximal clique. Memory of result must be freed by the caller.
fn bron_kerbosch(
    alloc: Allocator,
    adjacency_matrix: []const []const bool,
    r: []bool,
    p: []bool,
    x: []bool,
) !BronKerboschResult {
    var p_len: usize = 0;
    for (p) |v| {
        if (v) {
            p_len += 1;
        }
    }

    var x_len: usize = 0;
    for (x) |v| {
        if (v) {
            x_len += 1;
        }
    }

    if (p_len == 0 and x_len == 0) {
        var r_len: usize = 0;
        for (r) |v| {
            if (v) {
                r_len += 1;
            }
        }
        const r_copy = try alloc.alloc(bool, r.len);
        @memcpy(r_copy, r);
        return BronKerboschResult{ .clique_size = r_len, .clique = r_copy };
    }

    var max_clique_size: ?usize = null;
    var max_clique: ?[]bool = null;

    for (p, 0..) |v_pending, v_idx| {
        if (!v_pending) continue;

        var new_p = try alloc.alloc(bool, p.len);
        var new_x = try alloc.alloc(bool, x.len);

        for (0..p.len) |idx| {
            new_p[idx] = p[idx] and adjacency_matrix[v_idx][idx];
        }

        for (0..x.len) |idx| {
            new_x[idx] = x[idx] and adjacency_matrix[v_idx][idx];
        }

        r[v_idx] = true;
        const rec_result = try bron_kerbosch(alloc, adjacency_matrix, r, new_p, new_x);
        r[v_idx] = false;

        alloc.free(new_p);
        alloc.free(new_x);

        if (max_clique_size == null or (rec_result.clique_size != null and rec_result.clique_size.? > max_clique_size.?)) {
            max_clique_size = rec_result.clique_size;
            max_clique = rec_result.clique;
        }

        p[v_idx] = false;
        x[v_idx] = true;
    }

    return BronKerboschResult{ .clique_size = max_clique_size, .clique = max_clique };
}
