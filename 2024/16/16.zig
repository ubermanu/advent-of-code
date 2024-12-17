const std = @import("std");

const Map = struct {
    data: []const u8,
    cols: usize,
    rows: usize,

    pub fn init(input: []const u8) Map {
        var it = std.mem.splitSequence(u8, input, "\n");
        return .{
            .data = input,
            .rows = std.mem.count(u8, input, "\n"),
            .cols = it.first().len,
        };
    }

    pub fn at(self: Map, v: Vector2) u8 {
        return self.data[self.toIndex(v)];
    }

    pub fn toVector2(self: Map, i: usize) Vector2 {
        return .{
            .x = @floatFromInt(@mod(i, self.cols + 1)),
            .y = @floor(@as(f64, @floatFromInt(i)) / (@as(f64, @floatFromInt(self.cols)) + 1)),
        };
    }

    pub fn toIndex(self: Map, v: Vector2) usize {
        const x: usize = @intFromFloat(v.x);
        const y: usize = @intFromFloat(v.y);
        std.debug.assert(x <= self.cols or y <= self.rows);
        return x + (self.cols + 1) * y;
    }
};

const Wall = '#';
const End = 'E';

const Vector2 = struct {
    x: f64,
    y: f64,

    pub fn add(self: Vector2, v: Vector2) Vector2 {
        return .{ .x = self.x + v.x, .y = self.y + v.y };
    }

    pub fn rotateLeft(self: Vector2) Vector2 {
        return .{ .x = self.y, .y = self.x * -1 };
    }

    pub fn rotateRight(self: Vector2) Vector2 {
        return .{ .x = self.y * -1, .y = self.x };
    }
};

const NORTH = Vector2{ .x = 0, .y = -1 };
const EAST = Vector2{ .x = 1, .y = 0 };
const SOUTH = Vector2{ .x = 0, .y = 1 };
const WEST = Vector2{ .x = -1, .y = 0 };

const Reindeer = struct {
    pos: Vector2,
    dir: Vector2 = EAST,
    score: usize = 0,
};

fn search(allocator: std.mem.Allocator, map: Map, deer: Reindeer, already_visited: ?std.ArrayList(Vector2)) ![]Reindeer {
    var visited = already_visited orelse std.ArrayList(Vector2).init(allocator);
    defer visited.deinit();

    try visited.append(deer.pos);

    var res = std.ArrayList(Reindeer).init(allocator);
    defer res.deinit();

    for (neighbours(deer)) |n| {
        if (map.at(n.pos) == Wall) {
            continue;
        }

        if (map.at(n.pos) == End) {
            try res.append(n);
            continue;
        }

        if (containsVector2(visited.items, n.pos) == false) {
            try visited.append(n.pos);
            const deers = try search(allocator, map, n, try visited.clone());
            defer allocator.free(deers);
            try res.appendSlice(deers);
        }
    }

    return res.toOwnedSlice();
}

fn neighbours(cur: Reindeer) [3]Reindeer {
    return .{
        .{
            .pos = cur.pos.add(cur.dir),
            .score = cur.score + 1,
            .dir = cur.dir,
        },
        .{
            .pos = cur.pos.add(cur.dir.rotateRight()),
            .score = cur.score + 1001,
            .dir = cur.dir.rotateRight(),
        },
        .{
            .pos = cur.pos.add(cur.dir.rotateLeft()),
            .score = cur.score + 1001,
            .dir = cur.dir.rotateLeft(),
        },
    };
}

fn containsVector2(slice: []const Vector2, v: Vector2) bool {
    for (slice) |i| {
        if (i.x == v.x and i.y == v.y) {
            return true;
        }
    }
    return false;
}

fn lowestScore(slice: []const Reindeer) usize {
    var lowest: usize = 0;
    for (slice) |r| {
        if (lowest == 0 or r.score < lowest) {
            lowest = r.score;
        }
    }
    return lowest;
}

const doc =
    \\###############
    \\#.......#....E#
    \\#.#.###.#.###.#
    \\#.....#.#...#.#
    \\#.###.#####.#.#
    \\#.#.#.......#.#
    \\#.#.#####.###.#
    \\#...........#.#
    \\###.#.#####.#.#
    \\#...#.....#.#.#
    \\#.#.#.###.#.#.#
    \\#.....#...#.#.#
    \\#.###.#.#.#.#.#
    \\#S..#.....#...#
    \\###############
;

test {
    const map = Map.init(doc);
    const start = std.mem.indexOf(u8, map.data, "S") orelse unreachable;

    const deers = try search(std.testing.allocator, map, .{ .pos = map.toVector2(start) }, null);
    defer std.testing.allocator.free(deers);

    try std.testing.expectEqual(7036, lowestScore(deers));
}

const doc2 =
    \\#################
    \\#...#...#...#..E#
    \\#.#.#.#.#.#.#.#.#
    \\#.#.#.#...#...#.#
    \\#.#.#.#.###.#.#.#
    \\#...#.#.#.....#.#
    \\#.#.#.#.#.#####.#
    \\#.#...#.#.#.....#
    \\#.#.#####.#.###.#
    \\#.#.#.......#...#
    \\#.#.###.#####.###
    \\#.#.#...#.....#.#
    \\#.#.#.#####.###.#
    \\#.#.#.........#.#
    \\#.#.#.#########.#
    \\#S#.............#
    \\#################
;

test {
    const map = Map.init(doc2);
    const start = std.mem.indexOf(u8, map.data, "S") orelse unreachable;

    const deers = try search(std.testing.allocator, map, .{ .pos = map.toVector2(start) }, null);
    defer std.testing.allocator.free(deers);

    try std.testing.expectEqual(11048, lowestScore(deers));
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const map = Map.init(@embedFile("input"));
    const start = std.mem.indexOf(u8, map.data, "S") orelse unreachable;

    const deers = try search(allocator, map, .{ .pos = map.toVector2(start) }, null);
    defer allocator.free(deers);

    std.debug.print("Calculating lowest score...\n", .{});
    std.debug.print("Lowest score is: {}\n", .{lowestScore(deers)});
}
