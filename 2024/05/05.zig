const std = @import("std");

const doc =
    \\47|53
    \\97|13
    \\97|61
    \\97|47
    \\75|29
    \\61|13
    \\75|53
    \\29|13
    \\97|29
    \\53|29
    \\61|53
    \\97|53
    \\61|29
    \\47|13
    \\75|47
    \\97|75
    \\47|61
    \\75|61
    \\47|29
    \\75|13
    \\53|13
    \\
    \\75,47,61,53,29
    \\97,61,53,29,13
    \\75,29,13
    \\75,97,47,61,53
    \\61,13,29
    \\97,13,75,29,47
;

const Page = usize;
const Update = []const Page;

const Rule = struct { before: Page, after: Page };

fn parse(allocator: std.mem.Allocator, input: []const u8) !struct { []Rule, []Update } {
    var rules = std.ArrayList(Rule).init(allocator);
    errdefer rules.deinit();

    var updates = std.ArrayList(Update).init(allocator);
    errdefer updates.deinit();

    var lines = std.mem.splitSequence(u8, input, "\n");

    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var it = std.mem.splitSequence(u8, line, "|");

        try rules.append(.{
            .before = try std.fmt.parseInt(Page, it.first(), 10),
            .after = try std.fmt.parseInt(Page, it.rest(), 10),
        });
    }

    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var update = std.ArrayList(Page).init(allocator);
        errdefer update.deinit();

        var it = std.mem.splitSequence(u8, line, ",");

        while (it.next()) |n| {
            try update.append(try std.fmt.parseInt(Page, n, 10));
        }

        try updates.append(try update.toOwnedSlice());
    }

    return .{
        try rules.toOwnedSlice(),
        try updates.toOwnedSlice(),
    };
}

fn isBefore(rules: []Rule, a: Page, b: Page) bool {
    for (rules) |rule| {
        if (rule.before == b and rule.after == a) {
            return false;
        }
    }
    return true;
}

fn isCorrect(rules: []Rule, update: Update) bool {
    for (update, 0..) |page, i| {
        const prev = update[0..i];

        for (prev) |sibling| {
            if (!isBefore(rules, sibling, page)) {
                return false;
            }
        }

        const next = update[i .. update.len - 1];

        for (next) |sibling| {
            if (!isBefore(rules, page, sibling)) {
                return false;
            }
        }
    }

    return true;
}

test "parse doc" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const rules, const updates = try parse(arena.allocator(), doc);

    try std.testing.expectEqual(true, isCorrect(rules, updates[0]));
    try std.testing.expectEqual(true, isCorrect(rules, updates[1]));
    try std.testing.expectEqual(true, isCorrect(rules, updates[2]));
    try std.testing.expectEqual(false, isCorrect(rules, updates[3]));
    try std.testing.expectEqual(false, isCorrect(rules, updates[4]));
    try std.testing.expectEqual(false, isCorrect(rules, updates[5]));

    var total: usize = 0;

    for (updates) |update| {
        if (isCorrect(rules, update)) {
            total += update[update.len / 2];
        }
    }

    try std.testing.expectEqual(143, total);
}

test "puzzle input" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const rules, const updates = try parse(arena.allocator(), @embedFile("input"));

    var total: usize = 0;

    for (updates) |update| {
        if (isCorrect(rules, update)) {
            total += update[update.len / 2];
        }
    }

    std.debug.print("result: {}\n", .{total});
}
