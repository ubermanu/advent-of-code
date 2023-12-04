const std = @import("std");
const print = std.debug.print;

fn parseInt(str: []const u8) i32 {
    return std.fmt.parseInt(i32, std.mem.trim(u8, str, " "), 10) catch |err| {
        print("{}\n", .{err});
        return 0;
    };
}

const InstructionType = enum {
    TURN_ON,
    TURN_OFF,
    TOGGLE,
};

const Instruction = struct {
    type: InstructionType,
    from: [2]i32,
    through: [2]i32,
};

fn extract_position(text: []const u8) [2]i32 {
    var it = std.mem.split(u8, text, ",");

    var pos: [2]i32 = .{ 0, 0 };
    pos[0] = parseInt(it.next().?);
    pos[1] = parseInt(it.next().?);

    return pos;
}

fn extract_instruction_values(text: []const u8, inst: *Instruction) void {
    var it = std.mem.split(u8, text, "through");

    inst.from = extract_position(it.next().?);
    inst.through = extract_position(it.next().?);
}

fn parse_instruction(text: []const u8) Instruction {
    var inst = Instruction{ .type = undefined, .from = undefined, .through = undefined };

    if (std.mem.eql(u8, text[0..6], "toggle")) {
        inst.type = InstructionType.TOGGLE;
        extract_instruction_values(text[7..], &inst);
    } else if (std.mem.eql(u8, text[0..7], "turn on")) {
        inst.type = InstructionType.TURN_ON;
        extract_instruction_values(text[8..], &inst);
    } else if (std.mem.eql(u8, text[0..8], "turn off")) {
        inst.type = InstructionType.TURN_OFF;
        extract_instruction_values(text[9..], &inst);
    } else {
        @panic("Could not determine the instruction");
    }

    return inst;
}

fn apply_instruction(grid: *[1000][1000]i32, inst: *Instruction) void {
    var x1: usize = @intCast(inst.from[0]);
    var x2: usize = @intCast(inst.through[0]);
    var y1: usize = @intCast(inst.from[1]);
    var y2: usize = @intCast(inst.through[1]);

    for (x1..x2 + 1) |x| {
        for (y1..y2 + 1) |y| {
            switch (inst.type) {
                InstructionType.TOGGLE => {
                    grid[x][y] = grid[x][y] ^ 1;
                },
                InstructionType.TURN_ON => {
                    grid[x][y] = 1;
                },
                InstructionType.TURN_OFF => {
                    grid[x][y] = 0;
                },
            }
            // print("{} {}\n", .{ x, y });
        }
    }
}

fn apply_instruction2(grid: *[1000][1000]i32, inst: *Instruction) void {
    var x1: usize = @intCast(inst.from[0]);
    var x2: usize = @intCast(inst.through[0]);
    var y1: usize = @intCast(inst.from[1]);
    var y2: usize = @intCast(inst.through[1]);

    for (x1..x2 + 1) |x| {
        for (y1..y2 + 1) |y| {
            switch (inst.type) {
                InstructionType.TOGGLE => {
                    grid[x][y] += 2;
                },
                InstructionType.TURN_ON => {
                    grid[x][y] += 1;
                },
                InstructionType.TURN_OFF => {
                    grid[x][y] = @max(grid[x][y] - 1, 0);
                },
            }
            // print("{} {}\n", .{ x, y });
        }
    }
}

fn init_lights(grid: *[1000][1000]i32) void {
    for (0..1000) |x| {
        for (0..1000) |y| {
            grid[x][y] = 0;
        }
    }
}

fn count_lit(grid: *[1000][1000]i32) i32 {
    var total: i32 = 0;

    for (0..1000) |x| {
        for (0..1000) |y| {
            if (grid[x][y] == 1) {
                total += 1;
            }
        }
    }

    return total;
}

fn calc_brightness(grid: *[1000][1000]i32) i32 {
    var total: i32 = 0;

    for (0..1000) |x| {
        for (0..1000) |y| {
            total += grid[x][y];
        }
    }

    return total;
}

const file = @embedFile("input");

pub fn main() !void {
    var grid: [1000][1000]i32 = undefined;

    init_lights(&grid);

    var inst1 = parse_instruction("turn on 0,0 through 999,999");
    var inst2 = parse_instruction("toggle 0,0 through 999,0");
    var inst3 = parse_instruction("turn off 499,499 through 500,500");

    apply_instruction(&grid, &inst1);
    apply_instruction(&grid, &inst2);
    apply_instruction(&grid, &inst3);

    print("In the example, {} lights are lit\n", .{count_lit(&grid)});

    init_lights(&grid);

    var it = std.mem.split(u8, file, "\n");

    while (it.next()) |line| {
        if (line.len > 0) {
            var inst = parse_instruction(line);
            apply_instruction(&grid, &inst);
        }
    }

    print("In the input, {} lights are lit\n", .{count_lit(&grid)});

    init_lights(&grid);
    it.reset();

    while (it.next()) |line| {
        if (line.len > 0) {
            var inst = parse_instruction(line);
            apply_instruction2(&grid, &inst);
        }
    }

    print("The total brightness of the lights is: {}\n", .{calc_brightness(&grid)});
}
