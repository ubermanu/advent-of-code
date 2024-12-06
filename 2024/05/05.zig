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

const ParseResult = struct {
    allocator: std.mem.Allocator,
    rules: []Rule,
    updates: []Update,

    pub fn deinit(self: ParseResult) void {
        for (self.updates) |update| {
            self.allocator.free(update);
        }
        self.allocator.free(self.updates);
        self.allocator.free(self.rules);
    }
};

fn parse(allocator: std.mem.Allocator, input: []const u8) !ParseResult {
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
        .allocator = allocator,
        .rules = try rules.toOwnedSlice(),
        .updates = try updates.toOwnedSlice(),
    };
}

fn is_before(ctx: ParseResult, a: Page, b: Page) bool {
    for (ctx.rules) |rule| {
        if (rule.before == b and rule.after == a) {
            return false;
        }
    }
    return true;
}

fn is_correct(ctx: ParseResult, update: Update) bool {
    for (update, 0..) |page, i| {
        const prev = update[0..i];

        for (prev) |sibling| {
            if (!is_before(ctx, sibling, page)) {
                return false;
            }
        }

        const next = update[i .. update.len - 1];

        for (next) |sibling| {
            if (!is_before(ctx, page, sibling)) {
                return false;
            }
        }
    }

    return true;
}

test "parse doc" {
    const res = try parse(std.testing.allocator, doc);
    defer res.deinit();

    try std.testing.expectEqual(true, is_correct(res, res.updates[0]));
    try std.testing.expectEqual(true, is_correct(res, res.updates[1]));
    try std.testing.expectEqual(true, is_correct(res, res.updates[2]));
    try std.testing.expectEqual(false, is_correct(res, res.updates[3]));
    try std.testing.expectEqual(false, is_correct(res, res.updates[4]));
    try std.testing.expectEqual(false, is_correct(res, res.updates[5]));

    var total: usize = 0;

    for (res.updates) |update| {
        if (is_correct(res, update)) {
            total += update[update.len / 2];
        }
    }

    try std.testing.expectEqual(143, total);
}

test "puzzle input" {
    const res = try parse(std.testing.allocator, @embedFile("input"));
    defer res.deinit();

    var total: usize = 0;

    for (res.updates) |update| {
        if (is_correct(res, update)) {
            total += update[update.len / 2];
        }
    }

    std.debug.print("result: {}\n", .{total});
}
