const std = @import("std");

const doc =
    \\MMMSXXMASM
    \\MSAMXMSMSA
    \\AMXSXMAAMM
    \\MSAMASMSMX
    \\XMASAMXAMM
    \\XXAMMXXAMA
    \\SMSMSASXSS
    \\SAXAMASAAA
    \\MAMMMXMMMM
    \\MXMXAXMASX
;

const Table = struct {
    data: []const u8,
    rows: usize,
    cols: usize,

    pub fn init(input: []const u8) Table {
        var it = std.mem.splitSequence(u8, input, "\n");
        return .{
            .data = input,
            .rows = std.mem.count(u8, input, "\n"),
            .cols = it.first().len,
        };
    }

    /// Returns `.` if out of bound.
    pub fn at(self: Table, x: usize, y: usize) u8 {
        if (x > self.cols or y > self.rows) {
            return '.';
        }
        const pos = x + (self.cols + 1) * y;
        if (pos >= self.data.len) {
            return '.';
        }
        return self.data[pos];
    }

    pub fn toX(self: Table, pos: usize) usize {
        return @mod(pos, self.cols + 1);
    }

    pub fn toY(self: Table, pos: usize) usize {
        return @intFromFloat(@floor(@as(f64, @floatFromInt(pos)) / (@as(f64, @floatFromInt(self.cols)) + 1)));
    }
};

test "table" {
    const t = Table.init(doc);
    try std.testing.expectEqual('M', t.at(0, 0));
    try std.testing.expectEqual('M', t.at(3, 1));
    try std.testing.expectEqual('X', t.at(0, 5));
}

const Dir = enum { N, NE, E, SE, S, SW, W, NW };

const SearchResult = struct {
    pos: usize,
    dir: Dir,
};

fn search(allocator: std.mem.Allocator, t: Table) ![]SearchResult {
    var res = std.ArrayList(SearchResult).init(allocator);
    errdefer res.deinit();

    for (t.data, 0..) |c, pos| {
        if (c == '\n') {
            continue;
        }

        const x = t.toX(pos);
        const y = t.toY(pos);

        if (c != 'X') {
            continue;
        }

        if (y >= 3 and t.at(x, y - 1) == 'M' and t.at(x, y - 2) == 'A' and t.at(x, y - 3) == 'S') {
            try res.append(.{ .pos = pos, .dir = .N });
        }

        if (y >= 3 and t.at(x + 1, y - 1) == 'M' and t.at(x + 2, y - 2) == 'A' and t.at(x + 3, y - 3) == 'S') {
            try res.append(.{ .pos = pos, .dir = .NE });
        }

        if (t.at(x + 1, y) == 'M' and t.at(x + 2, y) == 'A' and t.at(x + 3, y) == 'S') {
            try res.append(.{ .pos = pos, .dir = .E });
        }

        if (t.at(x + 1, y + 1) == 'M' and t.at(x + 2, y + 2) == 'A' and t.at(x + 3, y + 3) == 'S') {
            try res.append(.{ .pos = pos, .dir = .SE });
        }

        if (t.at(x, y + 1) == 'M' and t.at(x, y + 2) == 'A' and t.at(x, y + 3) == 'S') {
            try res.append(.{ .pos = pos, .dir = .S });
        }

        if (x >= 3 and t.at(x - 1, y + 1) == 'M' and t.at(x - 2, y + 2) == 'A' and t.at(x - 3, y + 3) == 'S') {
            try res.append(.{ .pos = pos, .dir = .SW });
        }

        if (x >= 3 and t.at(x - 1, y) == 'M' and t.at(x - 2, y) == 'A' and t.at(x - 3, y) == 'S') {
            try res.append(.{ .pos = pos, .dir = .W });
        }

        if (x >= 3 and y >= 3 and t.at(x - 1, y - 1) == 'M' and t.at(x - 2, y - 2) == 'A' and t.at(x - 3, y - 3) == 'S') {
            try res.append(.{ .pos = pos, .dir = .NW });
        }
    }

    return try res.toOwnedSlice();
}

test "search" {
    const res = try search(std.testing.allocator, Table.init(doc));
    defer std.testing.allocator.free(res);

    try std.testing.expectEqual(18, res.len);
}

test "puzzle input" {
    const res = try search(std.testing.allocator, Table.init(@embedFile("input")));
    defer std.testing.allocator.free(res);

    std.debug.print("{} results found in the input.\n", .{res.len});
}
