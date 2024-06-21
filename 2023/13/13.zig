const std = @import("std");
const ArenaAllocator = std.heap.ArenaAllocator;
const Allocator = std.mem.Allocator;

const doc =
    \\#.##..##.
    \\..#.##.#.
    \\##......#
    \\##......#
    \\..#.##.#.
    \\..##..##.
    \\#.#.##.#.
;

const doc2 =
    \\#...##..#
    \\#....#..#
    \\..##..###
    \\#####.##.
    \\#####.##.
    \\..##..###
    \\#....#..#
;

const Mirror = struct {
    lhs: usize,
    rhs: usize,
    orientation: enum { horizontal, vertical },
};

const Valley = struct {
    arena: ArenaAllocator,
    input: []const u8,
    rows: usize,
    cols: usize,

    pub fn init(allocator: Allocator, str: []const u8) Valley {
        var arena = ArenaAllocator.init(allocator);

        var input = std.ArrayList(u8).init(arena.allocator());
        input.appendSlice(str) catch unreachable;

        // Ensure we get a trailing
        if (input.getLast() != '\n') {
            input.append('\n') catch unreachable;
        }

        const rows = std.mem.count(u8, input.items, "\n");
        const cols = (input.items.len - rows) / rows;

        return .{
            .arena = arena,
            .input = input.items,
            .rows = rows,
            .cols = cols,
        };
    }

    pub fn deinit(self: Valley) void {
        self.arena.deinit();
    }

    /// Returns a slice of the row at index `i`.
    /// Returns null if out of bounds.
    pub fn rowSlice(self: Valley, i: usize) ?[]const u8 {
        if (i >= self.rows) {
            return null;
        }

        return self.input[i * (self.cols + 1) ..][0..self.cols];
    }

    /// Returns a slice of the col at index `i`.
    /// Returns null if out of bounds.
    pub fn colSlice(self: *Valley, i: usize) ?[]u8 {
        if (i >= self.cols) {
            return null;
        }

        var col = std.ArrayList(u8).init(self.arena.allocator());

        for (0..self.rows) |j| {
            col.append(self.input[i + j * (self.cols + 1)]) catch unreachable;
        }

        return col.items;
    }

    pub fn findMirror(self: *Valley) Mirror {
        // Check vertically, 0 means between 0 and 1
        for (0..self.cols - 1) |lhs| {
            var i: usize = 0;

            while (true) : (i += 1) {

                // We reached out of bounds, wich means the current index is correct
                if (i > lhs) {
                    return .{
                        .lhs = lhs,
                        .rhs = lhs + 1,
                        .orientation = .vertical,
                    };
                }

                const before = self.colSlice(lhs - i);
                const after = self.colSlice(lhs + i + 1);

                // We reached out of bounds, wich means the current index is correct
                if (before == null or after == null) {
                    return .{
                        .lhs = lhs,
                        .rhs = lhs + 1,
                        .orientation = .vertical,
                    };
                }

                // The columns are different, check for another one
                if (std.mem.eql(u8, before.?, after.?) == false) {
                    break;
                }
            }
        }

        // Check horizontally, 0 means between 0 and 1
        for (0..self.rows - 1) |lhs| {
            var i: usize = 0;

            while (true) : (i += 1) {
                if (i > lhs) {
                    return .{
                        .lhs = lhs,
                        .rhs = lhs + 1,
                        .orientation = .horizontal,
                    };
                }

                const before = self.rowSlice(lhs - i);
                const after = self.rowSlice(lhs + i + 1);

                if (before == null or after == null) {
                    return .{
                        .lhs = lhs,
                        .rhs = lhs + 1,
                        .orientation = .horizontal,
                    };
                }

                if (std.mem.eql(u8, before.?, after.?) == false) {
                    break;
                }
            }
        }

        std.debug.print("\nSHAPE:\n{s}\n", .{self.input});

        @panic("Could not find a mirror");
    }
};

test {
    const allocator = std.testing.allocator;

    var v1 = Valley.init(allocator, doc ++ "\n");
    defer v1.deinit();

    try std.testing.expectEqual(9, v1.cols);

    try std.testing.expectEqualDeep(
        Mirror{
            .lhs = 4,
            .rhs = 5,
            .orientation = .vertical,
        },
        v1.findMirror(),
    );

    var v2 = Valley.init(allocator, doc2 ++ "\n");
    defer v2.deinit();

    try std.testing.expectEqualDeep(
        Mirror{
            .lhs = 3,
            .rhs = 4,
            .orientation = .horizontal,
        },
        v2.findMirror(),
    );

    var mirrors = std.ArrayList(Mirror).init(allocator);
    defer mirrors.deinit();

    try mirrors.append(v1.findMirror());
    try mirrors.append(v2.findMirror());

    var sum: usize = 0;

    for (mirrors.items) |mirror| {
        switch (mirror.orientation) {
            .vertical => sum += mirror.lhs + 1,
            .horizontal => sum += (mirror.lhs + 1) * 100,
        }
    }

    try std.testing.expectEqual(405, sum);
}

test {
    const allocator = std.testing.allocator;
    const doc3 =
        \\.#..#......
        \\..#.#......
        \\..#...#....
        \\#.##...####
        \\.#..#..####
        \\#.#.##.####
        \\###..#.#..#
    ;
    var v = Valley.init(allocator, doc3);
    defer v.deinit();

    try std.testing.expectEqual(11, v.cols);
    try std.testing.expectEqual(7, v.rows);

    try std.testing.expectEqualStrings("...#.##", v.colSlice(0).?);

    const m = v.findMirror();

    try std.testing.expectEqualDeep(Mirror{
        .lhs = 8,
        .rhs = 9,
        .orientation = .vertical,
    }, m);
}

test {
    const allocator = std.testing.allocator;
    const doc4 =
        \\###...#...#.#..
        \\.#.##.#.....#..
        \\..###..#..#....
        \\..###..#..#....
        \\.#.##.#........
        \\###...#...#.#..
        \\###..#..##.#.##
    ;
    var v = Valley.init(allocator, doc4);
    defer v.deinit();

    const m = v.findMirror();

    try std.testing.expectEqualDeep(Mirror{
        .lhs = 13,
        .rhs = 14,
        .orientation = .vertical,
    }, m);
}

test {
    const allocator = std.testing.allocator;

    var mirrors = std.ArrayList(Mirror).init(allocator);
    defer mirrors.deinit();

    const input = @embedFile("input");

    var it = std.mem.splitSequence(u8, input, "\n\n");

    while (it.next()) |str| {
        var v = Valley.init(allocator, str);
        defer v.deinit();
        try mirrors.append(v.findMirror());
    }

    var sum: usize = 0;

    for (mirrors.items) |mirror| {
        switch (mirror.orientation) {
            .vertical => sum += mirror.lhs + 1,
            .horizontal => sum += (mirror.lhs + 1) * 100,
        }
    }

    std.debug.print("Result: {d}\n", .{sum});
}
