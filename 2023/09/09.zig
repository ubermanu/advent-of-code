const std = @import("std");
const print = std.debug.print;

const doc =
    \\0 3 6 9 12 15
    \\1 3 6 10 15 21
    \\10 13 16 21 30 45
;

const Sequence = []isize;

fn get_next_sequence(seq: Sequence) !Sequence {
    var list = std.ArrayList(isize).init(std.heap.page_allocator);

    for (0..seq.len - 1) |i| {
        try list.append(seq[i + 1] - seq[i]);
    }

    return list.toOwnedSlice();
}

fn is_empty_seq(seq: Sequence) bool {
    for (seq) |n| {
        if (n != 0) {
            return false;
        }
    }
    return true;
}

fn parse_sequence(text: []const u8) !Sequence {
    var list = std.ArrayList(isize).init(std.heap.page_allocator);
    var it = std.mem.split(u8, text, " ");

    while (it.next()) |n| {
        try list.append(try std.fmt.parseInt(isize, n, 10));
    }

    return list.toOwnedSlice();
}

fn get_prediction(seq: Sequence) !isize {
    var sequences = std.ArrayList(Sequence).init(std.heap.page_allocator);
    defer sequences.deinit();

    try sequences.append(seq);

    var cur = seq;

    while (is_empty_seq(cur) == false) {
        var next = try get_next_sequence(cur);
        try sequences.append(next);
        cur = next;
    }

    var next: isize = 0;

    for (sequences.items) |item| {
        next += item[item.len - 1];
    }

    return next;
}

const file = @embedFile("input");

pub fn main() !void {
    var it = std.mem.split(u8, file, "\n");

    var total: isize = 0;

    while (it.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var seq = try parse_sequence(line);
        var prediction = try get_prediction(seq);
        total += prediction;
    }

    print("Sum of extrapolated values: {}\n", .{total});
}
