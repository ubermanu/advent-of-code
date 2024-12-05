const std = @import("std");

const doc =
    \\7 6 4 2 1
    \\1 2 7 8 9
    \\9 7 6 2 1
    \\1 3 2 4 5
    \\8 6 4 4 1
    \\1 3 6 7 9
;

const Level = usize;
const Report = []const Level;

fn parse(allocator: std.mem.Allocator, input: []const u8) ![]Report {
    var reports = std.ArrayList(Report).init(allocator);
    errdefer reports.deinit();

    var lines = std.mem.splitSequence(u8, input, "\n");

    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var levels = std.ArrayList(Level).init(allocator);
        defer levels.deinit();

        var it = std.mem.splitSequence(u8, line, " ");

        while (it.next()) |n| {
            if (n.len == 0) {
                continue;
            }

            try levels.append(try std.fmt.parseInt(Level, n, 10));
        }

        try reports.append(try levels.toOwnedSlice());
    }

    return try reports.toOwnedSlice();
}

test "parse doc" {
    const reports = try parse(std.testing.allocator, doc);

    defer {
        for (reports) |report| {
            std.testing.allocator.free(report);
        }
        std.testing.allocator.free(reports);
    }

    try std.testing.expectEqual(6, reports.len);
    try std.testing.expectEqualSlices(Level, &.{ 7, 6, 4, 2, 1 }, reports[0]);
}

// The levels are either all increasing or all decreasing.
// Any two adjacent levels differ by at least one and at most three.
fn isSafe(report: Report) bool {
    var i: usize = 1;

    if (report[0] == report[1]) {
        return false;
    }

    const asc = report[0] < report[1];

    while (i < report.len) : (i += 1) {
        if (@max(report[i], report[i - 1]) - @min(report[i], report[i - 1]) > 3) {
            return false;
        } else if (asc and report[i - 1] < report[i]) {
            continue;
        } else if (!asc and report[i - 1] > report[i]) {
            continue;
        } else {
            return false;
        }
    }

    return true;
}

test "is safe" {
    const reports = try parse(std.testing.allocator, doc);

    defer {
        for (reports) |report| {
            std.testing.allocator.free(report);
        }
        std.testing.allocator.free(reports);
    }

    try std.testing.expectEqual(true, isSafe(reports[0]));
    try std.testing.expectEqual(false, isSafe(reports[1]));
    try std.testing.expectEqual(false, isSafe(reports[2]));
    try std.testing.expectEqual(false, isSafe(reports[3]));
    try std.testing.expectEqual(false, isSafe(reports[4]));
    try std.testing.expectEqual(true, isSafe(reports[5]));
}

test "puzzle input" {
    const reports = try parse(std.testing.allocator, @embedFile("input"));
    defer std.testing.allocator.free(reports);

    var total: usize = 0;

    for (reports) |report| {
        defer std.testing.allocator.free(report);
        total += if (isSafe(report)) 1 else 0;
    }

    std.debug.print("There are {} safe reports.\n", .{total});
}
