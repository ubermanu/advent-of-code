const std = @import("std");
const parseInt = std.fmt.parseInt;

fn get_box_surface(box: []const u8) !i32 {
    var it = std.mem.split(u8, box, "x");

    var w: i32 = try parseInt(i32, it.next().?, 10);
    var l: i32 = try parseInt(i32, it.next().?, 10);
    var h: i32 = try parseInt(i32, it.next().?, 10);

    var leftover = @min(l * w, @min(w * h, h * l));

    return (2 * l * w) + (2 * w * h) + (2 * h * l) + leftover;
}

const file = @embedFile("input");

pub fn main() !void {
    std.debug.print("{d}\n", .{try get_box_surface("2x3x4")});
    std.debug.print("{d}\n", .{try get_box_surface("1x1x10")});

    var it = std.mem.split(u8, file, "\n");
    var total: i32 = 0;

    while (it.next()) |line| {
        if (line.len > 0) {
            total += try get_box_surface(line);
        }
    }

    std.debug.print("Total surface need of paper: {d}\n", .{total});
}
