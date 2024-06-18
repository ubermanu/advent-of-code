const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;

const doc =
    \\...#......
    \\.......#..
    \\#.........
    \\..........
    \\......#...
    \\.#........
    \\.........#
    \\..........
    \\.......#..
    \\#...#.....
;

const Vector2 = struct {
    x: usize,
    y: usize,
};

const Star = struct {
    id: usize,
    index: usize,
    pos: Vector2,

    pub fn distanceTo(self: Star, other: Star) usize {
        const dx = @max(other.pos.x, self.pos.x) - @min(other.pos.x, self.pos.x);
        const dy = @max(other.pos.y, self.pos.y) - @min(other.pos.y, self.pos.y);
        return dx + dy;
    }
};

const Galaxy = struct {
    allocator: Allocator,
    image: std.ArrayList(u8),
    rows: usize,
    cols: usize,

    pub fn init(allocator: Allocator, str: []const u8) Galaxy {
        var image = std.ArrayList(u8).init(allocator);
        image.appendSlice(str) catch unreachable;

        // Add a trailing line break if missing
        if (str[str.len - 1] != '\n') {
            image.append('\n') catch unreachable;
        }

        const rows = std.mem.count(u8, image.items, "\n");
        const cols = (image.items.len - rows) / rows;

        return .{
            .allocator = allocator,
            .image = image,
            .rows = rows,
            .cols = cols,
        };
    }

    pub fn deinit(self: Galaxy) void {
        self.image.deinit();
    }

    // For each rows or cols without stars, it expands 1.
    pub fn expand(self: *Galaxy) !void {
        var rows = self.rows;
        var i: usize = 0;

        while (i < rows) : (i += 1) {
            const row = self.image.items[i * (self.cols + 1) ..][0..self.cols];

            if (std.mem.count(u8, row, ".") == self.cols) {
                var new_row = try self.allocator.alloc(u8, self.cols + 1);
                defer self.allocator.free(new_row);
                @memset(new_row, '.');
                new_row[new_row.len - 1] = '\n';

                try self.image.insertSlice((i + 1) * (self.cols + 1), new_row);
                i += 1;
                rows += 1;
            }
        }

        i = 0;
        var cols = self.cols;

        outer: while (i < cols) : (i += 1) {
            for (0..rows) |j| {
                if (self.image.items[i + j * (cols + 1)] == '#') {
                    continue :outer;
                }
            }

            for (0..rows) |j| {
                try self.image.insert(i + j * (cols + 1) + j, '.');
            }

            i += 1;
            cols += 1;
        }

        self.rows = rows;
        self.cols = cols;
    }

    /// Return all the stars in the galaxy.
    pub fn stars(self: *Galaxy) ![]Star {
        var st = std.ArrayList(Star).init(self.allocator);

        var cur: usize = 0;

        while (cur < self.image.items.len) : (cur += 1) {
            if (std.mem.indexOf(u8, self.image.items[cur..], "#")) |i| {
                try st.append(.{
                    .id = st.items.len + 1,
                    .index = cur + i,
                    .pos = .{
                        .x = (cur + i) % (self.cols + 1),
                        .y = (cur + i) / (self.cols + 1),
                    },
                });
                cur += i;
            } else {
                break;
            }
        }

        return st.toOwnedSlice();
    }

    const Pair = std.meta.Tuple(&[_]type{ *const Star, *const Star });

    /// Return every possible pairs of stars.
    pub fn pairs(self: *Galaxy, items: []Star) ![]Pair {
        var list = std.ArrayList(Pair).init(self.allocator);

        var offset: usize = 1;
        for (0..items.len) |i| {
            for (offset..items.len) |j| {
                const p = Pair{ &items[i], &items[j] };
                try list.append(p);
            }
            offset += 1;
        }

        return list.toOwnedSlice();
    }
};

test {
    const allocator = std.testing.allocator;
    var g = Galaxy.init(allocator, doc);
    defer g.deinit();

    std.debug.print("{s}\n", .{g.image.items});

    try std.testing.expectEqual(10, g.rows);
    try std.testing.expectEqual(10, g.cols);
    try std.testing.expectEqual(g.image.items.len, g.rows * (g.cols + 1));

    try g.expand();

    std.debug.print("\n\nExpanded:\n{s}\n", .{g.image.items});

    try std.testing.expectEqual(12, g.rows);
    try std.testing.expectEqual(13, g.cols);
    try std.testing.expectEqual(g.image.items.len, g.rows * (g.cols + 1));

    const stars = try g.stars();
    defer allocator.free(stars);

    try std.testing.expectEqual(9, stars.len);

    std.debug.print("\n\nStars:\n", .{});
    for (stars) |star| {
        std.debug.print("{any}\n", .{star});
    }

    const pairs = try g.pairs(stars);
    defer allocator.free(pairs);

    std.debug.print("\n\nPairs: {d}\n", .{pairs.len});
    for (pairs) |pair| {
        std.debug.print("\t{d} <-> {d} = {d}\n", .{
            pair[0].id,
            pair[1].id,
            pair[0].distanceTo(pair[1].*),
        });
    }

    var sum: usize = 0;

    for (pairs) |pair| {
        sum += pair[0].distanceTo(pair[1].*);
    }

    try std.testing.expectEqual(374, sum);
}

test {
    const allocator = std.testing.allocator;
    var g = Galaxy.init(allocator, @embedFile("input"));
    defer g.deinit();

    try std.testing.expectEqual(g.image.items.len, g.rows * (g.cols + 1));

    try g.expand();

    try std.testing.expectEqual(g.image.items.len, g.rows * (g.cols + 1));

    const stars = try g.stars();
    defer allocator.free(stars);

    const pairs = try g.pairs(stars);
    defer allocator.free(pairs);

    var sum: usize = 0;

    for (pairs) |pair| {
        sum += pair[0].distanceTo(pair[1].*);
    }

    std.debug.print("\n\ninput sum |> {d}\n", .{sum});
}
