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
        defer list.deinit();

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

    pub fn get_scratchcards(self: *Card, cards: *[206]Card) []Card {
        const matches = self.get_matching_numbers();

        if (matches.len == 0) {
            return &.{};
        }

        var id: usize = @intCast(self.id);
        const end = @min(id + matches.len, cards.len);

        return cards[id..end];
    }
};

fn decode_card(text: []const u8) !Card {
    var card = Card{ .id = 0, .winning_numbers = .{}, .numbers = .{} };

    card.id = try parseInt(text[5..8]);

    try extract_numbers(text[10..40], &card.winning_numbers);
    try extract_numbers(text[42..], &card.numbers);

    return card;
}

fn get_scratchcards_count(cards: *[206]Card, card: *Card) i32 {
    var count: i32 = 1;

    const scratches = card.get_scratchcards(cards);
    for (scratches, 0..) |_, i| {
        count += get_scratchcards_count(cards, &scratches[i]);
    }

    return count;
}

fn get_all_scratchcards_count(cards: *[206]Card) i32 {
    var count: i32 = 0;

    for (cards, 0..) |_, i| {
        const c = get_scratchcards_count(cards, &cards[i]);
        print("Card {} = {}\n", .{ (i + 1), c });
        count += c;
    }

    return count;
}

const file = @embedFile("input");

pub fn main() !void {
    var it = std.mem.split(u8, file, "\n");
    var total: i32 = 0;

    while (it.next()) |line| {
        if (line.len > 0) {
            var card = try decode_card(line);
            total += card.get_points();
        }
    }

    print("Total points: {d}\n", .{total});

    it.reset();
    total = 0;

    var cards: [206]Card = .{};

    while (it.next()) |line| {
        if (line.len > 0) {
            var card = try decode_card(line);
            var id: usize = @intCast(card.id);
            cards[id - 1] = card;
        }
    }

    print("Total number of scratchcards: {d}\n", .{get_all_scratchcards_count(&cards)});
}
