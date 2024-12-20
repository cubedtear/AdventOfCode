const std = @import("std");
const input = @embedFile("inputs/day17.txt");

pub fn main() !void {
    try part1();
    try part2();
}

fn instr(program: []const u8, index: u64) u3 {
    return @intCast(program[2 * index] - '0');
}

fn get_opcode_str(opcode: u3) []const u8 {
    switch (opcode) {
        0 => return "adv(0)",
        1 => return "bxl(1)",
        2 => return "bst(2)",
        3 => return "jnz(3)",
        4 => return "bxc(4)",
        5 => return "out(5)",
        6 => return "bdv(6)",
        7 => return "cdv(7)",
    }
    unreachable;
}

const State = struct {
    program: []const u8,
    reg_a: u64,
    reg_b: u64,
    reg_c: u64,
    pc: u64,
};

fn part1() !void {
    var output_buffer = [_]u8{0} ** 2048;
    var output_stream = std.io.fixedBufferStream(&output_buffer);
    const writer = output_stream.writer();

    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");

    var state = blk: {
        const reg_a = try std.fmt.parseInt(u64, line_it.next().?[12..], 10);
        const reg_b = try std.fmt.parseInt(u64, line_it.next().?[12..], 10);
        const reg_c = try std.fmt.parseInt(u64, line_it.next().?[12..], 10);

        // Note: The numbers are separated by a comma, so for intruction n, the number is at index 2n
        const program = line_it.next().?[9..];

        break :blk State{
            .program = program,
            .reg_a = reg_a,
            .reg_b = reg_b,
            .reg_c = reg_c,
            .pc = 0,
        };
    };

    while (state.pc < (state.program.len + 1) / 2) {
        // print_state(&state);
        const opt_out = run_single_iteration(&state);
        if (opt_out) |out| {
            try writer.print(",{}", .{out});
        }
    }
    // print_state(&state);

    std.debug.print("Part 1 result: {s}\n", .{output_buffer[1..output_stream.pos]});
}

// std.debug.print("pc: {d}, reg_a: {o}, reg_b: {o}, reg_c: {o}\n", .{pc, reg_a, reg_b, reg_c});
fn print_state(state: *State) void {
    const opcode = instr(state.program, state.pc);
    const literal_operand = instr(state.program, state.pc + 1);
    const combo_operand: u64 = blk: {
        if (literal_operand <= 3) break :blk literal_operand;
        if (literal_operand == 4) break :blk state.reg_a;
        if (literal_operand == 5) break :blk state.reg_b;
        if (literal_operand == 6) break :blk state.reg_c;
        unreachable;
    };
    std.debug.print("pc: {d} - opcode: {s} - literal_operand: {d} - combo_operand: {d} - reg_a: {o} - reg_b: {o} - reg_c: {o}\n", .{state.pc, get_opcode_str(opcode), literal_operand, combo_operand, state.reg_a, state.reg_b, state.reg_c});
}

fn part2() !void {
    var line_it = std.mem.tokenizeAny(u8, input, "\r\n");

    _ = line_it.next();
    _ = line_it.next();
    _ = line_it.next();

    // Note: The numbers are separated by a comma, so for intruction n, the number is at index 2n
    const program = line_it.next().?[9..];

    const result = solve(program, program.len - 1, 0) orelse unreachable;

    std.debug.print("Part 2 result: {}\n", .{result});
}

fn solve(program: []const u8, out_idx: usize, previous_reg_a: u64) ?u64 {
    const expected_output = program[out_idx] - '0';

    for (0..8) |octal_digit| {
        const reg_a = (previous_reg_a << 3) | octal_digit;

        var state = State{
            .program = program,
            .reg_a = reg_a,
            .reg_b = 0,
            .reg_c = 0,
            .pc = 0,
        };
        var output: ?u3 = null;
        while (instr(state.program, state.pc) != 3) {
            // print_state(&state);
            output = run_single_iteration(&state);
        }
        if (output == null or output.? != expected_output) {
            continue;
        } else {
            if (out_idx < 2) {
                return reg_a;
            }
            if (solve(program, out_idx - 2, reg_a)) |result| {
                return result;
            }
        }
    }

    return null;
}

fn run_single_iteration(state: *State) ?u3 {
    var output: ?u3 = null;

    const opcode = instr(state.program, state.pc);
    const literal_operand = instr(state.program, state.pc + 1);
    const combo_operand: u64 = blk: {
        if (literal_operand <= 3) break :blk literal_operand;
        if (literal_operand == 4) break :blk state.reg_a;
        if (literal_operand == 5) break :blk state.reg_b;
        if (literal_operand == 6) break :blk state.reg_c;
        unreachable;
    };

    switch (opcode) {
        0 => {
            // adv => A = trunc(A / (2**combo_operand))
            state.reg_a = @divTrunc(state.reg_a, std.math.pow(u64, 2, combo_operand));
            state.pc += 2;
        },
        1 => {
            // bxl => B = B XOR literal_operand
            state.reg_b = state.reg_b ^ @as(u64, @intCast(literal_operand));
            state.pc += 2;
        },
        2 => {
            // bst => B = combo_operand % 8
            state.reg_b = combo_operand % 8;
            state.pc += 2;
        },
        3 => {
            // jnz => if A != 0 { pc = literal_operand; }
            // Do not increment pc if we jump
            if (state.reg_a != 0) {
                state.pc = literal_operand;
            } else {
                state.pc += 2;
            }
        },
        4 => {
            // bxc => B = B XOR C
            state.reg_b = state.reg_b ^ state.reg_c;
            state.pc += 2;
        },
        5 => {
            // out => print(combo_operand % 8)
            output = @intCast(combo_operand % 8);
            state.pc += 2;
        },
        6 => {
            // bdv => B = trunc(A / (2**combo_operand))
            state.reg_b = @divTrunc(state.reg_a, std.math.pow(u64, 2, combo_operand));
            state.pc += 2;
        },
        7 => {
            // cdv => C = trunc(A / (2**combo_operand))
            state.reg_c = @divTrunc(state.reg_a, std.math.pow(u64, 2, combo_operand));
            state.pc += 2;
        },
    }
    return output;
}

