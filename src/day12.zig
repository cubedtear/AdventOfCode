const std = @import("std");
const input = @embedFile("inputs/day12.txt");

const width = 140; // Not including the \r\n
const height = 140;

var visited = [_]bool{false} ** ((width + 2) * height);

pub fn main() !void {
    try part1();
    @memset(&visited, false);
    try part2();
}

fn get_index_from_coords(x: usize, y: usize) usize {
    return y * (width + 2) + x; // The 2 is there in order to account for the \r\n
}

fn get_char(x: usize, y: usize) u8 {
    const index = get_index_from_coords(x, y);
    return input[index];
}

fn is_visited(x: usize, y: usize) bool {
    const index = get_index_from_coords(x, y);
    return visited[index];
}

fn mark_visited(x: usize, y: usize) void {
    const index = get_index_from_coords(x, y);
    visited[index] = true;
}

const Point = struct {
    x: usize,
    y: usize,
};

fn part1() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();


    var result: usize = 0;
    for (0..height) |y| {
        for (0..width) |x| {
            if (is_visited(x, y)) {
                continue;
            }

            const current_char = get_char(x, y);

            const LinkedListType = std.DoublyLinkedList(Point);

            var current_area_point_list = std.ArrayList(Point).init(alloc);
            var pending_points_to_add = LinkedListType{};

            const first_node = try alloc.create(LinkedListType.Node);
            first_node.data = Point{.x = x, .y = y};

            try current_area_point_list.append(first_node.data);

            mark_visited(x, y);

            pending_points_to_add.append(first_node);

            var perimeter: usize = 0;

            while (pending_points_to_add.len > 0) {
                const node = pending_points_to_add.popFirst() orelse unreachable;
                const point = node.data;

                if (point.x > 0) {
                    const left_char = get_char(point.x - 1, point.y);
                    if (left_char == current_char) {
                        if (!is_visited(point.x - 1, point.y)) {
                            const new_node = try alloc.create(LinkedListType.Node);
                            new_node.data = Point{.x = point.x - 1, .y = point.y};
                            mark_visited(new_node.data.x, new_node.data.y);
                            try current_area_point_list.append(new_node.data);
                            pending_points_to_add.append(new_node);
                        }
                    } else {
                        perimeter += 1;
                    }
                } else {
                    perimeter += 1;
                }

                if (point.x < width - 1) {
                    const right_char = get_char(point.x + 1, point.y);
                    if (right_char == current_char) {
                        if (!is_visited(point.x + 1, point.y)) {
                            const new_node = try alloc.create(LinkedListType.Node);
                            new_node.data = Point{.x = point.x + 1, .y = point.y};
                            mark_visited(new_node.data.x, new_node.data.y);
                            try current_area_point_list.append(new_node.data);
                            pending_points_to_add.append(new_node);
                        }
                    } else {
                        perimeter += 1;
                    }
                } else {
                    perimeter += 1;
                }

                if (point.y > 0) {
                    const up_char = get_char(point.x, point.y - 1);
                    if (up_char == current_char) {
                        if (!is_visited(point.x, point.y - 1)) {
                            const new_node = try alloc.create(LinkedListType.Node);
                            new_node.data = Point{.x = point.x, .y = point.y - 1};
                            mark_visited(new_node.data.x, new_node.data.y);
                            try current_area_point_list.append(new_node.data);
                            pending_points_to_add.append(new_node);
                        }
                    } else {
                        perimeter += 1;
                    }
                } else {
                    perimeter += 1;
                }

                if (point.y < height - 1) {
                    const down_char = get_char(point.x, point.y + 1);
                    if (down_char == current_char) {
                        if (!is_visited(point.x, point.y + 1)) {
                            const new_node = try alloc.create(LinkedListType.Node);
                            new_node.data = Point{.x = point.x, .y = point.y + 1};
                            mark_visited(new_node.data.x, new_node.data.y);
                            try current_area_point_list.append(new_node.data);
                            pending_points_to_add.append(new_node);
                        }
                    } else {
                        perimeter += 1;
                    }
                } else {
                    perimeter += 1;
                }
            }

            result += perimeter * current_area_point_list.items.len;
        }
    }

    std.debug.print("Part 1: {}\n", .{result});
}

fn part2() !void {
    var allocator = std.heap.HeapAllocator.init();
    const alloc = allocator.allocator();


    var result: usize = 0;
    for (0..height) |y| {
        for (0..width) |x| {
            if (is_visited(x, y)) {
                continue;
            }

            const current_char = get_char(x, y);

            // std.debug.print("Processing area at ({}, {}), char: {c}\n", .{x, y, current_char});

            const LinkedListType = std.DoublyLinkedList(Point);

            var current_area_point_list = std.ArrayList(Point).init(alloc);
            var pending_points_to_add = LinkedListType{};

            const first_node = try alloc.create(LinkedListType.Node);
            first_node.data = Point{.x = x, .y = y};

            try current_area_point_list.append(first_node.data);

            mark_visited(x, y);

            pending_points_to_add.append(first_node);

            var perimeter: usize = 0;

            while (pending_points_to_add.len > 0) {
                const node = pending_points_to_add.popFirst() orelse unreachable;
                const point = node.data;

                // std.debug.print("  Processing point ({}, {})\n", .{point.x, point.y});

                if (point.x > 0) {
                    const left_char = get_char(point.x - 1, point.y);
                    if (left_char == current_char) {
                        if (!is_visited(point.x - 1, point.y)) {
                            // std.debug.print("    Adding point ({}, {}) to the list\n", .{point.x - 1, point.y});
                            const new_node = try alloc.create(LinkedListType.Node);
                            new_node.data = Point{.x = point.x - 1, .y = point.y};
                            mark_visited(new_node.data.x, new_node.data.y);
                            try current_area_point_list.append(new_node.data);
                            pending_points_to_add.append(new_node);
                        }
                    } else {
                        // We checking if there is a perimeter to the left of X:
                        // AB
                        // CX
                        // We know C != X. So there is one more perimeter if B != X or A == X
                        if (point.y > 0) {
                            const point_a = get_char(point.x - 1, point.y - 1);
                            const point_b = get_char(point.x, point.y - 1);
                            if (point_b != current_char or point_a == current_char) {
                                perimeter += 1;
                            }
                        } else {
                            perimeter += 1;
                        }
                    }
                } else {
                    // Left edge
                    if (point.y > 0) {
                        if (get_char(point.x, point.y - 1) != current_char) {
                            perimeter += 1;
                        }
                    } else {
                        // Top-left corner
                        perimeter += 1;
                    }
                }

                if (point.x < width - 1) {
                    const right_char = get_char(point.x + 1, point.y);
                    if (right_char == current_char) {
                        if (!is_visited(point.x + 1, point.y)) {
                            // std.debug.print("    Adding point ({}, {}) to the list\n", .{point.x + 1, point.y});
                            const new_node = try alloc.create(LinkedListType.Node);
                            new_node.data = Point{.x = point.x + 1, .y = point.y};
                            mark_visited(new_node.data.x, new_node.data.y);
                            try current_area_point_list.append(new_node.data);
                            pending_points_to_add.append(new_node);
                        }
                    } else {
                        // We checking if there is a perimeter to the right of X:
                        // AB
                        // XC
                        // We know C != X. So there is one more perimeter if A != X or B == X
                        if (point.y > 0) {
                            const point_a = get_char(point.x, point.y - 1);
                            const point_b = get_char(point.x + 1, point.y - 1);
                            if (point_a != current_char or point_b == current_char) {
                                perimeter += 1;
                            }
                        } else {
                            perimeter += 1;
                        }
                    }
                } else {
                    // Right edge
                    if (point.y > 0) {
                        if (get_char(point.x, point.y - 1) != current_char) {
                            perimeter += 1;
                        }
                    } else {
                        // Top-right corner
                        perimeter += 1;
                    }
                }

                if (point.y > 0) {
                    const up_char = get_char(point.x, point.y - 1);
                    if (up_char == current_char) {
                        if (!is_visited(point.x, point.y - 1)) {
                            // std.debug.print("    Adding point ({}, {}) to the list\n", .{point.x, point.y - 1});
                            const new_node = try alloc.create(LinkedListType.Node);
                            new_node.data = Point{.x = point.x, .y = point.y - 1};
                            mark_visited(new_node.data.x, new_node.data.y);
                            try current_area_point_list.append(new_node.data);
                            pending_points_to_add.append(new_node);
                        }
                    } else {
                        // We checking if there is a perimeter above X:
                        // AC
                        // BX
                        // We know C != X. So there is one more perimeter if B != X or A == X
                        if (point.x > 0) {
                            const point_a = get_char(point.x - 1, point.y - 1);
                            const point_b = get_char(point.x - 1, point.y);
                            if (point_b != current_char or point_a == current_char) {
                                perimeter += 1;
                            }
                        } else {
                            perimeter += 1;
                        }
                    }
                } else {
                    // Top edge
                    if (point.x > 0) {
                        if (get_char(point.x - 1, point.y) != current_char) {
                            perimeter += 1;
                        }
                    } else {
                        // Top-left corner
                        perimeter += 1;
                    }
                }

                if (point.y < height - 1) {
                    const down_char = get_char(point.x, point.y + 1);
                    if (down_char == current_char) {
                        if (!is_visited(point.x, point.y + 1)) {
                            // std.debug.print("    Adding point ({}, {}) to the list\n", .{point.x, point.y + 1});
                            const new_node = try alloc.create(LinkedListType.Node);
                            new_node.data = Point{.x = point.x, .y = point.y + 1};
                            mark_visited(new_node.data.x, new_node.data.y);
                            try current_area_point_list.append(new_node.data);
                            pending_points_to_add.append(new_node);
                        }
                    } else {
                        // We checking if there is a perimeter below X
                        // AX
                        // BC
                        // We know C != X. So there is one more perimeter if A != X or B == X
                        if (point.x > 0) {
                            const point_a = get_char(point.x - 1, point.y);
                            const point_b = get_char(point.x - 1, point.y + 1);
                            if (point_a != current_char or point_b == current_char) {
                                perimeter += 1;
                            }
                        } else {
                            perimeter += 1;
                        }
                    }
                } else {
                    // Bottom edge
                    if (point.x > 0) {
                        if (get_char(point.x - 1, point.y) != current_char) {
                            perimeter += 1;
                        }
                    } else {
                        // Bottom-left corner
                        perimeter += 1;
                    }
                }
            }

            result += perimeter * current_area_point_list.items.len;
        }
    }

    std.debug.print("Part 2: {}\n", .{result});
}