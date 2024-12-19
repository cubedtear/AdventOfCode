const std = @import("std");
const input = @embedFile("inputs/day16.txt");

const width: usize = get_width();
const height: usize = get_height();

const start_pos = find_start_position();
const end_pos = find_end_position();

inline fn get_width() usize {
    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");
    return line_it.next().?.len;
}

inline fn get_height() usize {
    @setEvalBranchQuota(50000);

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

fn find_start_position() Point {
    @setEvalBranchQuota(50000);
    inline for (0..height) |y| {
        inline for (0..width) |x| {
            const c = input[x + y * (width + 2)];
            if (c == 'S') {
                @setEvalBranchQuota(1000);
                return Point{ .x = x, .y = y };
            }
        }
    }
    unreachable;
}

fn find_end_position() Point {
    @setEvalBranchQuota(50000);
    inline for (0..height) |y| {
        inline for (0..width) |x| {
            const c = input[x + y * (width + 2)];
            if (c == 'E') {
                @setEvalBranchQuota(1000);
                return Point{ .x = x, .y = y };
            }
        }
    }
    unreachable;
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

const PointToExplore = struct {
    pos: Point,
    dir: Direction,
    cost: usize,
    path: std.ArrayList(Point),
};

fn compare_points(_: void, a: PointToExplore, b: PointToExplore) std.math.Order {
    return std.math.order(a.cost, b.cost);
}

pub fn main() !void {
    try part1();
    try part2();
}

fn part1() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var visited = [_]VisitedInfo{VisitedInfo.init()} ** ((width + 2) * height);

    var queue = std.PriorityQueue(PointToExplore, void, compare_points).init(alloc, {});

    try queue.add(PointToExplore{ .pos = start_pos, .dir = .right, .cost = 0, .path = std.ArrayList(Point).init(alloc) });

    var found_min_cost: ?usize = null;
    var best_found = false;

    while (queue.items.len > 0) {
        const current = queue.remove();
        defer current.path.deinit();

        const current_visited = visited[get_index_from_coords(current.pos.x, current.pos.y)];

        if (current_visited.visited_per_dir[get_dir_idx(current.dir)] and current_visited.best_score_per_dir[get_dir_idx(current.dir)] < current.cost) {
            continue;
        }
        visited[get_index_from_coords(current.pos.x, current.pos.y)].visited = true;
        visited[get_index_from_coords(current.pos.x, current.pos.y)].visited_per_dir[get_dir_idx(current.dir)] = true;
        visited[get_index_from_coords(current.pos.x, current.pos.y)].best_score_per_dir[get_dir_idx(current.dir)] = current.cost;

        if (current.pos.x == end_pos.x and current.pos.y == end_pos.y) {
            found_min_cost = current.cost;
            best_found = true;

            for (current.path.items) |point| {
                visited[get_index_from_coords(point.x, point.y)].part_of_best_path = true;
            }
            visited[get_index_from_coords(current.pos.x, current.pos.y)].part_of_best_path = true;
            break;
        }

        if (current.dir != .right and current.pos.x > 0 and input[get_index_from_coords(current.pos.x - 1, current.pos.y)] != '#') {
            const extra_cost: usize = if (current.dir == .left) 1 else 1001;

            if (found_min_cost == null or current.cost + extra_cost <= found_min_cost.?) {
                var new_path = try current.path.clone();
                try new_path.append(current.pos);
                const new_point = PointToExplore{ .pos = Point{.x = current.pos.x - 1, .y = current.pos.y}, .dir = .left, .cost = current.cost + extra_cost, .path = new_path };
                try queue.add(new_point);
            }
        }
        if (current.dir != .left and current.pos.x < width - 1 and input[get_index_from_coords(current.pos.x + 1, current.pos.y)] != '#') {
            const extra_cost: usize = if (current.dir == .right) 1 else 1001;

            if (found_min_cost == null or current.cost + extra_cost <= found_min_cost.?) {
                var new_path = try current.path.clone();
                try new_path.append(current.pos);
                const new_point = PointToExplore{ .pos = Point{.x = current.pos.x + 1, .y = current.pos.y}, .dir = .right, .cost = current.cost + extra_cost, .path = new_path };
                try queue.add(new_point);
            }
        }
        if (current.dir != .down and current.pos.y > 0 and input[get_index_from_coords(current.pos.x, current.pos.y - 1)] != '#') {
            const extra_cost: usize = if (current.dir == .up) 1 else 1001;

            if (found_min_cost == null or current.cost + extra_cost <= found_min_cost.?) {
                var new_path = try current.path.clone();
                try new_path.append(current.pos);
                const new_point = PointToExplore{ .pos = Point{.x = current.pos.x, .y = current.pos.y - 1}, .dir = .up, .cost = current.cost + extra_cost, .path = new_path };
                try queue.add(new_point);
            }
        }
        if (current.dir != .up and current.pos.y < height - 1 and input[get_index_from_coords(current.pos.x, current.pos.y + 1)] != '#') {
            const extra_cost: usize = if (current.dir == .down) 1 else 1001;

            if (found_min_cost == null or current.cost + extra_cost <= found_min_cost.?) {
                var new_path = try current.path.clone();
                try new_path.append(current.pos);
                const new_point = PointToExplore{ .pos = Point{.x = current.pos.x, .y = current.pos.y + 1}, .dir = .down, .cost = current.cost + extra_cost, .path = new_path };
                try queue.add(new_point);
            }
        }
    }

    if (found_min_cost) |result| {
        std.debug.print("Part 1 result: {}\n", .{result});
    } else {
        std.debug.print("Part 1 result: Path not found!\n", .{});
    }
}

fn check_if_already_in_queue(queue: std.PriorityQueue(PointToExplore, void, compare_points), pos: Point, dir: Direction) ?*PointToExplore {
    for (0..queue.items.len) |item_index| {
        var item = queue.items[item_index];
        if (item.pos.x == pos.x and item.pos.y == pos.y and item.dir == dir) {
            return &item;
        }
    }
    return null;
}

const VisitedInfo = struct {
    visited: bool,
    visited_per_dir: [4]bool,
    best_score_per_dir: [4]usize,
    part_of_best_path: bool,

    fn init() VisitedInfo {
        return VisitedInfo{
            .visited = false,
            .visited_per_dir = [_]bool{false, false, false, false},
            .best_score_per_dir = [_]usize{0, 0, 0, 0},
            .part_of_best_path = false,
        };
    }
};

fn get_dir_idx(dir: Direction) usize {
    switch (dir) {
        Direction.left => return 0,
        Direction.right => return 1,
        Direction.up => return 2,
        Direction.down => return 3,
    }
    unreachable;
}

fn part2() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var visited = [_]VisitedInfo{VisitedInfo.init()} ** ((width + 2) * height);

    var queue = std.PriorityQueue(PointToExplore, void, compare_points).init(alloc, {});

    try queue.add(PointToExplore{ .pos = start_pos, .dir = .right, .cost = 0, .path = std.ArrayList(Point).init(alloc) });

    var found_min_cost: ?usize = null;
    var best_found = false;

    while (queue.items.len > 0) {
        const current = queue.remove();
        defer current.path.deinit();

        if (best_found and current.cost > found_min_cost.?) {
            break;
        }

        const current_visited = visited[get_index_from_coords(current.pos.x, current.pos.y)];

        if (!best_found and current_visited.visited_per_dir[get_dir_idx(current.dir)] and current_visited.best_score_per_dir[get_dir_idx(current.dir)] < current.cost) {
            continue;
        }
        visited[get_index_from_coords(current.pos.x, current.pos.y)].visited = true;
        visited[get_index_from_coords(current.pos.x, current.pos.y)].visited_per_dir[get_dir_idx(current.dir)] = true;
        visited[get_index_from_coords(current.pos.x, current.pos.y)].best_score_per_dir[get_dir_idx(current.dir)] = current.cost;

        if (current.pos.x == end_pos.x and current.pos.y == end_pos.y) {
            found_min_cost = current.cost;
            best_found = true;

            for (current.path.items) |point| {
                visited[get_index_from_coords(point.x, point.y)].part_of_best_path = true;
            }
            visited[get_index_from_coords(current.pos.x, current.pos.y)].part_of_best_path = true;
        }

        if (current.dir != .right and current.pos.x > 0 and input[get_index_from_coords(current.pos.x - 1, current.pos.y)] != '#') {
            const extra_cost: usize = if (current.dir == .left) 1 else 1001;

            if (found_min_cost == null or current.cost + extra_cost <= found_min_cost.?) {
                var new_path = try current.path.clone();
                try new_path.append(current.pos);
                const new_point = PointToExplore{ .pos = Point{.x = current.pos.x - 1, .y = current.pos.y}, .dir = .left, .cost = current.cost + extra_cost, .path = new_path };
                try queue.add(new_point);
            }
        }
        if (current.dir != .left and current.pos.x < width - 1 and input[get_index_from_coords(current.pos.x + 1, current.pos.y)] != '#') {
            const extra_cost: usize = if (current.dir == .right) 1 else 1001;

            if (found_min_cost == null or current.cost + extra_cost <= found_min_cost.?) {
                var new_path = try current.path.clone();
                try new_path.append(current.pos);
                const new_point = PointToExplore{ .pos = Point{.x = current.pos.x + 1, .y = current.pos.y}, .dir = .right, .cost = current.cost + extra_cost, .path = new_path };
                try queue.add(new_point);
            }
        }
        if (current.dir != .down and current.pos.y > 0 and input[get_index_from_coords(current.pos.x, current.pos.y - 1)] != '#') {
            const extra_cost: usize = if (current.dir == .up) 1 else 1001;

            if (found_min_cost == null or current.cost + extra_cost <= found_min_cost.?) {
                var new_path = try current.path.clone();
                try new_path.append(current.pos);
                const new_point = PointToExplore{ .pos = Point{.x = current.pos.x, .y = current.pos.y - 1}, .dir = .up, .cost = current.cost + extra_cost, .path = new_path };
                try queue.add(new_point);
            }
        }
        if (current.dir != .up and current.pos.y < height - 1 and input[get_index_from_coords(current.pos.x, current.pos.y + 1)] != '#') {
            const extra_cost: usize = if (current.dir == .down) 1 else 1001;

            if (found_min_cost == null or current.cost + extra_cost <= found_min_cost.?) {
                var new_path = try current.path.clone();
                try new_path.append(current.pos);
                const new_point = PointToExplore{ .pos = Point{.x = current.pos.x, .y = current.pos.y + 1}, .dir = .down, .cost = current.cost + extra_cost, .path = new_path };
                try queue.add(new_point);
            }
        }
    }

    if (found_min_cost) |_| {
        var best_path_count: usize = 0;
        for (0..height) |y| {
            for (0..width) |x| {
                if (visited[get_index_from_coords(x, y)].part_of_best_path) {
                    best_path_count += 1;
                }
            }
        }

        std.debug.print("Part 2 result: {}\n", .{best_path_count});
    } else {
        std.debug.print("Part 2 result: Path not found!\n", .{});
    }
}
