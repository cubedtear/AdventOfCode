const std = @import("std");


fn generate_step_list(b: *std.Build) !void {
    var step_list_file_buffer: []u8 = try b.allocator.alloc(u8, 4096);
    var fbs = std.io.fixedBufferStream(step_list_file_buffer);
    const stream = fbs.writer();
    _ = try stream.write(
        \\const std = @import("std");
        \\
        \\pub fn run_day(day: u32) !void {
        \\    switch (day) {
        \\
    );
    for (0..25) |day| {
        // Check if file at src/dayXX.zig exists, and if so, add it to the build.
        const day_file_path = b.pathFromRoot(b.fmt("src/day{:0>2}.zig", .{day}));
        const day_file = std.fs.openFileAbsolute(day_file_path, .{.mode = .read_only}) catch continue;
        _ = day_file.stat() catch continue;

        _ = try stream.print("        {0} => return @import(\"{1s}\").main(),\n", .{day, b.fmt("day{0:0>2}.zig",.{day})});
    }

    _ = try stream.write(
        \\        else => {
        \\            std.log.err("Day {} not implemented\n", .{day});
        \\            return;
        \\        }
        \\    }
        \\}
        \\
    );

    const write_files_step = b.addWriteFiles();

    write_files_step.addBytesToSource(step_list_file_buffer[0..stream.context.pos], "src/step_list.zig");

    b.default_step.dependOn(&write_files_step.step);
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "AdventOfCode",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    try generate_step_list(b);

    // exe.root_module.addImport("step_list", step_list_module);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
