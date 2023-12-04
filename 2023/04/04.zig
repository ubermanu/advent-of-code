const std = @import("std");
const print = std.debug.print;

fn parseInt(str: []const u8) !i32 {
    return std.fmt.parseInt(i32, std.mem.trim(u8, str, " "), 10);
}

fn extract_numbers(text: []const u8, numbers: []i32) !void {
    for (0..text.len) |i| {
        if (i % 3 == 0) {
            var number = try parseInt(text[i..(i + 2)]);
            numbers[i / 3] = number;
        }
    }
}

const Card = struct {
    id: i32,
    winning_numbers: [10]i32,
    numbers: [25]i32,

    pub fn get_matching_numbers(self: *Card) []i32 {
        var list = std.ArrayList(i32).init(std.heap.page_allocator);

        for (self.numbers) |n| {
            for (self.winning_numbers) |w| {
                if (n == w) {
                    list.append(n) catch |err| {
                        print("{}\n", .{err});
                    };
                }
            }
        }

        return list.items;
    }

    pub fn get_points(self: *Card) i32 {
        const matches = self.get_matching_numbers();

        if (matches.len == 0) {
            return 0;
        }

        var len: i32 = @intCast(matches.len);
        return std.math.pow(i32, 2, len - 1);
    }
};

fn decode_card(text: []const u8) !Card {
    var card = Card{ .id = 0, .winning_numbers = .{}, .numbers = .{} };

    card.id = try parseInt(text[5..8]);

    try extract_numbers(text[10..40], &card.winning_numbers);
    try extract_numbers(text[42..], &card.numbers);

    return card;
}

const file = @embedFile("input");

pub fn main() !void {
    var it = std.mem.split(u8, file, "\n");
    var total: i32 = 0;

    while (it.next()) |line| {
        if (line.len > 0) {
            var card = try decode_card(line);
            total += card.get_points();
            print("{d}\t{any}\n", .{ card.get_points(), card.get_matching_numbers() });
        }
    }

    print("Total points: {d}\n", .{total});
}
