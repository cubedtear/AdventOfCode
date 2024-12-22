const std = @import("std");
const builtin = @import("builtin");
const input = @embedFile("inputs/day18.txt");

const width: usize = 71; // Actual value is 71
const height: usize = 71; // Actual value is 71
const only_use_first_n_obstacles: usize = 1024; // Actual value is 1024

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
    var obstacles = [_]bool{false} ** ((width + 2) * height);

    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");
    var inserted_obstacle_count: usize = 0;
    while (line_it.next()) |line| {
        if (inserted_obstacle_count >= only_use_first_n_obstacles) {
            break;
        }
        const line_trimmed = std.mem.trimRight(u8, line, "\r\n");
        var coords_iter = std.mem.tokenizeAny(u8, line_trimmed, ",");
        const x = try std.fmt.parseInt(usize, coords_iter.next().?, 10);
        const y = try std.fmt.parseInt(usize, coords_iter.next().?, 10);
        obstacles[get_index_from_coords(x, y)] = true;
        inserted_obstacle_count += 1;
    }

    var queue = std.PriorityQueue(PointToExplore, void, compare_points).init(alloc, {});

    try queue.add(PointToExplore{ .pos = Point{.x = 0, .y = 0}, .cost = 0, .path = std.ArrayList(Point).init(alloc) });

    var found_min_cost: ?usize = null;
    var best_found = false;

    while (queue.items.len > 0) {
        const current = queue.remove();
        defer current.path.deinit();


        if (visited[get_index_from_coords(current.pos.x, current.pos.y)].visited) {
            continue;
        }
        visited[get_index_from_coords(current.pos.x, current.pos.y)].visited = true;

        if (current.pos.x == width-1 and current.pos.y == height-1) {
            found_min_cost = current.cost;
            best_found = true;

            for (current.path.items) |point| {
                visited[get_index_from_coords(point.x, point.y)].part_of_best_path = true;
            }
            visited[get_index_from_coords(current.pos.x, current.pos.y)].part_of_best_path = true;
            break;
        }

        if (current.pos.x > 0 and !obstacles[get_index_from_coords(current.pos.x - 1, current.pos.y)] and !visited[get_index_from_coords(current.pos.x-1, current.pos.y)].visited) {
            var new_path = try current.path.clone();
            try new_path.append(current.pos);
            const new_point = PointToExplore{ .pos = Point{.x = current.pos.x - 1, .y = current.pos.y}, .cost = current.cost + 1, .path = new_path };
            try queue.add(new_point);
        }
        if (current.pos.x < width - 1 and !obstacles[get_index_from_coords(current.pos.x + 1, current.pos.y)] and !visited[get_index_from_coords(current.pos.x+1, current.pos.y)].visited) {
            var new_path = try current.path.clone();
            try new_path.append(current.pos);
            const new_point = PointToExplore{ .pos = Point{.x = current.pos.x + 1, .y = current.pos.y}, .cost = current.cost + 1, .path = new_path };
            try queue.add(new_point);
        }
        if (current.pos.y > 0 and !obstacles[get_index_from_coords(current.pos.x, current.pos.y - 1)] and !visited[get_index_from_coords(current.pos.x, current.pos.y-1)].visited) {
            var new_path = try current.path.clone();
            try new_path.append(current.pos);
            const new_point = PointToExplore{ .pos = Point{.x = current.pos.x, .y = current.pos.y - 1}, .cost = current.cost + 1, .path = new_path };
            try queue.add(new_point);
        }
        if (current.pos.y < height - 1 and !obstacles[get_index_from_coords(current.pos.x, current.pos.y + 1)] and !visited[get_index_from_coords(current.pos.x, current.pos.y+1)].visited) {
            var new_path = try current.path.clone();
            try new_path.append(current.pos);
            const new_point = PointToExplore{ .pos = Point{.x = current.pos.x, .y = current.pos.y + 1}, .cost = current.cost + 1, .path = new_path };
            try queue.add(new_point);
        }
    }

    if (found_min_cost) |result| {
        std.debug.print("Part 1 result: {}\n", .{result});
    } else {
        std.debug.print("Part 1 result: Path not found!\n", .{});
    }
}

const VisitedInfo = struct {
    visited: bool,
    part_of_best_path: bool,

    fn init() VisitedInfo {
        return VisitedInfo{
            .visited = false,
            .part_of_best_path = false,
        };
    }
};

const DichotomicIterator = struct {
    start: usize,
    end: usize,
    updated_since_last_next: bool,

    pub fn init(T: anytype, slice: []const T) DichotomicIterator {
        return DichotomicIterator{
            .start = 0,
            .end = slice.len,
            .updated_since_last_next = true,
        };
    }

    pub fn next(self: *DichotomicIterator) ?usize {
        if (!self.updated_since_last_next) {
            std.debug.panic("DichotomicIterator: Forgot to call one of the target_* functions in between update calls.", .{});
        }
        self.updated_since_last_next = false;
        if (self.start >= self.end) {
            return null;
        }
        return self.start + (self.end - self.start) / 2;
    }

    pub fn target_strict_after_current(self: *DichotomicIterator) void {
        self.start = self.start + (self.end - self.start) / 2 + 1;
        self.updated_since_last_next = true;
    }

    pub fn target_after_or_eq_current(self: *DichotomicIterator) void {
        self.start = self.start + (self.end - self.start) / 2;
        self.updated_since_last_next = true;
    }

    pub fn target_strict_before_current(self: *DichotomicIterator) void {
        self.end = self.start + (self.end - self.start) / 2 - 1;
        self.updated_since_last_next = true;
    }

    pub fn target_before_or_eq_current(self: *DichotomicIterator) void {
        self.end = self.start + (self.end - self.start) / 2;
        self.updated_since_last_next = true;
    }
};

fn part2() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();

    var all_obstacles = std.ArrayList(Point).init(alloc);

    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");
    while (line_it.next()) |line| {
        const line_trimmed = std.mem.trimRight(u8, line, "\r\n");
        var coords_iter = std.mem.tokenizeAny(u8, line_trimmed, ",");
        const x = try std.fmt.parseInt(usize, coords_iter.next().?, 10);
        const y = try std.fmt.parseInt(usize, coords_iter.next().?, 10);
        try all_obstacles.append(Point{.x = x, .y = y});
    }


    var dich_iter = DichotomicIterator.init(Point, all_obstacles.items);
    while (dich_iter.next()) |last_obst_idx| {
        var visited = [_]VisitedInfo{VisitedInfo.init()} ** ((width + 2) * height);
        var obstacles = [_]bool{false} ** ((width + 2) * height);

        for (0..last_obst_idx + 1) |i| {
            const obst_coords = all_obstacles.items[i];
            obstacles[get_index_from_coords(obst_coords.x, obst_coords.y)] = true;
        }

        var queue = std.PriorityQueue(PointToExplore, void, compare_points).init(alloc, {});

        try queue.add(PointToExplore{ .pos = Point{.x = 0, .y = 0}, .cost = 0, .path = std.ArrayList(Point).init(alloc) });

        var found_min_cost: ?usize = null;
        var best_found = false;

        while (queue.items.len > 0) {
            const current = queue.remove();
            defer current.path.deinit();


            if (visited[get_index_from_coords(current.pos.x, current.pos.y)].visited) {
                continue;
            }
            visited[get_index_from_coords(current.pos.x, current.pos.y)].visited = true;

            if (current.pos.x == width-1 and current.pos.y == height-1) {
                found_min_cost = current.cost;
                best_found = true;

                for (current.path.items) |point| {
                    visited[get_index_from_coords(point.x, point.y)].part_of_best_path = true;
                }
                visited[get_index_from_coords(current.pos.x, current.pos.y)].part_of_best_path = true;
                break;
            }

            if (current.pos.x > 0 and !obstacles[get_index_from_coords(current.pos.x - 1, current.pos.y)] and !visited[get_index_from_coords(current.pos.x-1, current.pos.y)].visited) {
                var new_path = try current.path.clone();
                try new_path.append(current.pos);
                const new_point = PointToExplore{ .pos = Point{.x = current.pos.x - 1, .y = current.pos.y}, .cost = current.cost + 1, .path = new_path };
                try queue.add(new_point);
            }
            if (current.pos.x < width - 1 and !obstacles[get_index_from_coords(current.pos.x + 1, current.pos.y)] and !visited[get_index_from_coords(current.pos.x+1, current.pos.y)].visited) {
                var new_path = try current.path.clone();
                try new_path.append(current.pos);
                const new_point = PointToExplore{ .pos = Point{.x = current.pos.x + 1, .y = current.pos.y}, .cost = current.cost + 1, .path = new_path };
                try queue.add(new_point);
            }
            if (current.pos.y > 0 and !obstacles[get_index_from_coords(current.pos.x, current.pos.y - 1)] and !visited[get_index_from_coords(current.pos.x, current.pos.y-1)].visited) {
                var new_path = try current.path.clone();
                try new_path.append(current.pos);
                const new_point = PointToExplore{ .pos = Point{.x = current.pos.x, .y = current.pos.y - 1}, .cost = current.cost + 1, .path = new_path };
                try queue.add(new_point);
            }
            if (current.pos.y < height - 1 and !obstacles[get_index_from_coords(current.pos.x, current.pos.y + 1)] and !visited[get_index_from_coords(current.pos.x, current.pos.y+1)].visited) {
                var new_path = try current.path.clone();
                try new_path.append(current.pos);
                const new_point = PointToExplore{ .pos = Point{.x = current.pos.x, .y = current.pos.y + 1}, .cost = current.cost + 1, .path = new_path };
                try queue.add(new_point);
            }
        }

        if (best_found) {
            // std.debug.print("  Idx: {} - Result: GOOD (Start: {} - End: {})\n", .{last_obst_idx, dich_iter.start, dich_iter.end});
            dich_iter.target_strict_after_current();
        } else {
            // std.debug.print("  Idx: {} - Result: BAD  (Start: {} - End: {})\n", .{last_obst_idx, dich_iter.start, dich_iter.end});
            dich_iter.target_before_or_eq_current();
        }
    }

    std.debug.print("Part 2 result: {},{}\n", .{all_obstacles.items[dich_iter.start].x, all_obstacles.items[dich_iter.start].y});
}