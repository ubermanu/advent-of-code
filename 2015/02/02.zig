const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

fn get_box_surface(box: []const u8) !i32 {
    var it = std.mem.split(u8, box, "x");

    var w: i32 = try parseInt(i32, it.next().?, 10);
    var l: i32 = try parseInt(i32, it.next().?, 10);
    var h: i32 = try parseInt(i32, it.next().?, 10);

    var leftover = @min(l * w, @min(w * h, h * l));

    return (2 * l * w) + (2 * w * h) + (2 * h * l) + leftover;
}

fn get_ribbon_length(box: []const u8) !i32 {
    var it = std.mem.split(u8, box, "x");

    var w: i32 = try parseInt(i32, it.next().?, 10);
    var l: i32 = try parseInt(i32, it.next().?, 10);
    var h: i32 = try parseInt(i32, it.next().?, 10);

    var sizes: [3]i32 = .{ w, l, h };

    std.sort.heap(i32, sizes[0..], {}, std.sort.asc(i32));

    var wrap_length = sizes[0] * 2 + sizes[1] * 2;
    var bow_length = w * l * h;

    return wrap_length + bow_length;
}

const file = @embedFile("input");

pub fn main() !void {
    print("{d}\n", .{try get_box_surface("2x3x4")});
    print("{d}\n", .{try get_box_surface("1x1x10")});

    var it = std.mem.split(u8, file, "\n");
    var total: i32 = 0;

    while (it.next()) |line| {
        if (line.len > 0) {
            total += try get_box_surface(line);
        }
    }

    print("Total surface of paper needed: {d}\n", .{total});

    print("---\n", .{});

    print("{d}\n", .{try get_ribbon_length("2x3x4")});
    print("{d}\n", .{try get_ribbon_length("1x1x10")});

    it.reset();
    total = 0;

    while (it.next()) |line| {
        if (line.len > 0) {
            total += try get_ribbon_length(line);
        }
    }

    print("Total length of ribban needed: {d}\n", .{total});
}
