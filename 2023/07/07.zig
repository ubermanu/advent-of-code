const std = @import("std");
const print = std.debug.print;

const Card = u8;
const Hand = [5]Card;

const Combination = enum {
    FiveOfAKind,
    FourOfAKind,
    FullHouse,
    ThreeOfAKind,
    TwoPair,
    OnePair,
    HighCard,
    None,
};

fn get_combination(hand: Hand) !Combination {
    var map = std.AutoArrayHashMap(Card, usize).init(std.heap.page_allocator);
    defer map.deinit();

    for (hand) |card| {
        var item = try map.getOrPutValue(card, 1);
        if (item.found_existing) {
            item.value_ptr.* += 1;
        }
    }

    var keys = map.keys();
    var values = map.values();

    return switch (keys.len) {
        1 => Combination.FiveOfAKind,
        2 => {
            if (values[0] == 1 or values[0] == 4) {
                return Combination.FourOfAKind;
            } else {
                return Combination.FullHouse;
            }
        },
        3 => if (values[0] == 3 or values[1] == 3 or values[2] == 3) {
            return Combination.ThreeOfAKind;
        } else {
            return Combination.TwoPair;
        },
        4 => Combination.OnePair,
        5 => Combination.HighCard,
        else => Combination.None,
    };
}

fn get_combination_strength(combination: Combination) usize {
    return switch (combination) {
        .FiveOfAKind => 7,
        .FourOfAKind => 6,
        .FullHouse => 5,
        .ThreeOfAKind => 4,
        .TwoPair => 3,
        .OnePair => 2,
        .HighCard => 1,
        .None => 0,
    };
}

const card_order = "AKQJT98765432";

fn get_card_strength(card: Card) usize {
    for (0..card_order.len) |i| {
        if (card == card_order[i]) {
            return card_order.len - i + 1;
        }
    }
    return 0;
}

inline fn get_combination_step() usize {
    var total: usize = 0;
    for (card_order) |card| {
        total += get_card_strength(card);
    }
    return total;
}

fn lessThanCard(_: void, lhs: Card, rhs: Card) bool {
    return get_card_strength(lhs) > get_card_strength(rhs);
}

fn sort_cards(hand: *Hand) void {
    std.mem.sort(Card, hand, {}, lessThanCard);
}

fn parseInt(text: []const u8) usize {
    return std.fmt.parseInt(usize, text, 10) catch |err| {
        print("{}\n", .{err});
        return 0;
    };
}

const Turn = struct {
    hand: Hand,
    bid: usize,
};

fn parse_turns(text: []const u8) ![]Turn {
    var list = std.ArrayList(Turn).init(std.heap.page_allocator);
    defer list.deinit();

    var it = std.mem.split(u8, text, "\n");

    while (it.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var turn = Turn{
            .hand = line[0..5].*,
            .bid = parseInt(line[6..]),
        };

        try list.append(turn);
    }

    return try list.toOwnedSlice();
}

const doc =
    \\32T3K 765
    \\T55J5 684
    \\KK677 28
    \\KTJJT 220
    \\QQQJA 483
;

fn moreThanTurn(_: void, lhs: Turn, rhs: Turn) bool {
    var crs = get_combination_strength(get_combination(rhs.hand) catch Combination.None);
    var cls = get_combination_strength(get_combination(lhs.hand) catch Combination.None);

    if (crs != cls) {
        return cls < crs;
    }

    for (lhs.hand, rhs.hand) |l, r| {
        var l_card_str = get_card_strength(l);
        var r_card_str = get_card_strength(r);

        if (l_card_str != r_card_str) {
            return l_card_str < r_card_str;
        }
    }

    return false;
}

fn sort_turns(turns: *[]Turn) void {
    std.mem.sort(Turn, turns.*, {}, moreThanTurn);
}

const file = @embedFile("input");

pub fn main() !void {
    // print("{}\n", .{try get_combination("AAAAA".*)});
    // print("{}\n", .{try get_combination("AA8AA".*)});
    // print("{}\n", .{try get_combination("23332".*)});
    // print("{}\n", .{try get_combination("TTT98".*)});
    // print("{}\n", .{try get_combination("23432".*)});
    // print("{}\n", .{try get_combination("A23A4".*)});
    // print("{}\n", .{try get_combination("23456".*)});

    var turns: []Turn = try parse_turns(doc);
    sort_turns(&turns);

    var total: usize = 0;

    for (0..turns.len) |i| {
        total += (i + 1) * turns[i].bid;
    }

    print("Total winnings: {}\n", .{total});

    turns = try parse_turns(file);
    sort_turns(&turns);
    total = 0;

    for (0..turns.len) |i| {
        total += (i + 1) * turns[i].bid;
    }

    print("Total winnings: {}\n", .{total});
}
