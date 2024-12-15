const std = @import("std");

const doc =
    \\##########
    \\#..O..O.O#
    \\#......O.#
    \\#.OO..O.O#
    \\#..O@..O.#
    \\#O#..O...#
    \\#O..O..O.#
    \\#.OO.O.OO#
    \\#....O...#
    \\##########
    \\
    \\<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
    \\vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
    \\><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
    \\<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
    \\^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
    \\^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
    \\>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
    \\<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
    \\^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
    \\v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
;

const doc2 =
    \\########
    \\#..O.O.#
    \\##@.O..#
    \\#...O..#
    \\#.#.O..#
    \\#...O..#
    \\#......#
    \\########
    \\
    \\<^^>>>vv<v>>v<<
;

const Wall = '#';
const Box = 'O';

const Map = struct {
    data: []u8,
    cols: usize,
    rows: usize,

    pub fn init(allocator: std.mem.Allocator, input: []const u8) Map {
        var it = std.mem.splitSequence(u8, input, "\n");
        return .{
            .data = allocator.dupe(u8, input) catch unreachable,
            .rows = std.mem.count(u8, input, "\n"),
            .cols = it.first().len,
        };
    }

    pub fn at(self: Map, x: usize, y: usize) u8 {
        if (x > self.cols or y > self.rows) {
            unreachable;
        }

        return self.data[x + (self.cols + 1) * y];
    }

    pub fn toX(self: Map, i: usize) usize {
        return @mod(i, self.cols + 1);
    }

    pub fn toY(self: Map, i: usize) usize {
        return @intFromFloat(@floor(@as(f64, @floatFromInt(i)) / (@as(f64, @floatFromInt(self.cols)) + 1)));
    }

    pub fn toIndex(self: Map, v: Vector2) usize {
        if (v.x > self.cols or v.y > self.rows) {
            unreachable;
        }
        return v.x + (self.cols + 1) * v.y;
    }
};

const Vector2 = struct {
    x: usize,
    y: usize,

    fn add(self: Vector2, v: Vector2) Vector2 {
        return .{ .x = self.x + v.x, .y = self.y + v.y };
    }

    fn sub(self: Vector2, v: Vector2) Vector2 {
        return .{ .x = self.x - v.x, .y = self.y - v.y };
    }

    fn apply(self: Vector2, dir: u8) ?Vector2 {
        return switch (dir) {
            '<' => self.sub(.{ .x = 1, .y = 0 }),
            '>' => self.add(.{ .x = 1, .y = 0 }),
            '^' => self.sub(.{ .x = 0, .y = 1 }),
            'v' => self.add(.{ .x = 0, .y = 1 }),
            else => null,
        };
    }
};

const Robot = struct {
    pos: Vector2,

    pub fn move(self: *Robot, dir: u8, map: *Map) void {
        const next = self.pos.apply(dir) orelse return;
        map.data[map.toIndex(self.pos)] = '.';

        switch (map.at(next.x, next.y)) {
            Wall => {
                // Boop'd into an immovable object
            },
            Box => {
                if (pushBox(map, self.pos, dir)) {
                    self.pos = next;
                }
            },
            else => {
                self.pos = next;
            },
        }

        map.data[map.toIndex(self.pos)] = '@';
    }
};

fn findRobot(map: Map) Robot {
    if (std.mem.indexOf(u8, map.data, "@")) |i| {
        return .{
            .pos = .{
                .x = map.toX(i),
                .y = map.toY(i),
            },
        };
    } else {
        unreachable;
    }
}

/// Returns `true` if a box has been successfully pushed of its
/// initial position.
fn pushBox(map: *Map, pos: Vector2, dir: u8) bool {
    const next = pos.apply(dir) orelse unreachable;

    switch (map.at(next.x, next.y)) {
        Box => {
            // Check if next pos is a box, and push it real good
            const ret = pushBox(map, next, dir);
            if (ret) {
                map.data[map.toIndex(next)] = Box;
            }
            return ret;
        },
        Wall => {
            return false;
        },
        else => {
            map.data[map.toIndex(next)] = Box;
            return true;
        },
    }
}

fn parse(allocator: std.mem.Allocator, input: []const u8) struct { Map, []const u8, Robot } {
    var it = std.mem.splitSequence(u8, input, "\n\n");
    const map = Map.init(allocator, it.first());
    return .{
        map,
        it.next() orelse unreachable,
        findRobot(map),
    };
}

test {
    var map, const directions, var rob = parse(
        std.testing.allocator,
        doc,
    );
    defer std.testing.allocator.free(map.data);

    std.debug.print("{s}\n\n", .{map.data});

    for (directions) |dir| {
        rob.move(dir, &map);
        std.debug.print("{s}\n\n", .{map.data});
    }

    try std.testing.expectEqualStrings(
        \\##########
        \\#.O.O.OOO#
        \\#........#
        \\#OO......#
        \\#OO@.....#
        \\#O#.....O#
        \\#O.....OO#
        \\#O.....OO#
        \\#OO....OO#
        \\##########
    , map.data);

    var total: usize = 0;

    for (map.data, 0..) |c, i| {
        if (c == Box) {
            total += map.toX(i) + 100 * map.toY(i);
        }
    }

    try std.testing.expectEqual(10092, total);
}

test "puzzle input" {
    var map, const directions, var rob = parse(
        std.testing.allocator,
        @embedFile("input"),
    );
    defer std.testing.allocator.free(map.data);

    for (directions) |dir| {
        rob.move(dir, &map);
    }

    var total: usize = 0;

    for (map.data, 0..) |c, i| {
        if (c == Box) {
            total += map.toX(i) + 100 * map.toY(i);
        }
    }

    std.debug.print("Sum of GPS coords: {}\n", .{total});
}
