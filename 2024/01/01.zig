const std = @import("std");

const doc =
    \\3   4
    \\4   3
    \\2   5
    \\1   3
    \\3   9
    \\3   3
;

fn parse(allocator: std.mem.Allocator, input: []const u8) ![2][]usize {
    var left = std.ArrayList(usize).init(allocator);
    var right = std.ArrayList(usize).init(allocator);

    errdefer left.deinit();
    errdefer right.deinit();

    var lines = std.mem.splitSequence(u8, input, "\n");

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var it = std.mem.splitAny(u8, line, " ");
        try left.append(try std.fmt.parseInt(usize, it.first(), 10));

        while (it.next()) |n| {
            if (n.len == 0) {
                continue;
            }

            try right.append(try std.fmt.parseInt(usize, n, 10));
            break;
        }

        if (left.items.len != right.items.len) {
            unreachable;
        }
    }

    return .{
        try left.toOwnedSlice(),
        try right.toOwnedSlice(),
    };
}

test "parse lists" {
    const lists = try parse(std.testing.allocator, doc);

    defer std.testing.allocator.free(lists[0]);
    defer std.testing.allocator.free(lists[1]);

    try std.testing.expectEqualSlices(usize, &.{ 3, 4, 2, 1, 3, 3 }, lists[0]);
    try std.testing.expectEqualSlices(usize, &.{ 4, 3, 5, 3, 9, 3 }, lists[1]);
}

const Pair = std.meta.Tuple(&[_]type{ usize, usize });

test "calc total distance" {
    const lists = try parse(std.testing.allocator, doc);

    defer std.testing.allocator.free(lists[0]);
    defer std.testing.allocator.free(lists[1]);

    std.mem.sort(
        usize,
        lists[0],
        {},
        std.sort.asc(usize),
    );

    std.mem.sort(
        usize,
        lists[1],
        {},
        std.sort.asc(usize),
    );

    var pairs = std.ArrayList(Pair).init(std.testing.allocator);
    defer pairs.deinit();

    for (0..lists[0].len) |i| {
        try pairs.append(.{ lists[0][i], lists[1][i] });
    }

    var total: usize = 0;

    for (pairs.items) |p| {
        total += @max(p[0], p[1]) - @min(p[0], p[1]);
    }

    try std.testing.expectEqual(11, total);
}

test "calc total distance input" {
    const lists = try parse(std.testing.allocator, @embedFile("input"));

    defer std.testing.allocator.free(lists[0]);
    defer std.testing.allocator.free(lists[1]);

    std.mem.sort(
        usize,
        lists[0],
        {},
        std.sort.asc(usize),
    );

    std.mem.sort(
        usize,
        lists[1],
        {},
        std.sort.asc(usize),
    );

    var pairs = std.ArrayList(Pair).init(std.testing.allocator);
    defer pairs.deinit();

    for (0..lists[0].len) |i| {
        try pairs.append(.{ lists[0][i], lists[1][i] });
    }

    var total: usize = 0;

    for (pairs.items) |p| {
        total += @max(p[0], p[1]) - @min(p[0], p[1]);
    }

    std.debug.print("Total distance: {}\n", .{total});
}
