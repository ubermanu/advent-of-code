const std = @import("std");
const print = std.debug.print;

const doc =
    \\.....
    \\.S-7.
    \\.|.|.
    \\.L-J.
    \\.....
;

const doc2 =
    \\..F7.
    \\.FJ|.
    \\SJ.L7
    \\|F--J
    \\LJ...
;

const PipeType = enum {
    Vertical,
    Horizontal,
    BendTopRight,
    BendTopLeft,
    BendBottomRight,
    BendBottomLeft,
    Unknown,
};

const PipeError = error{
    UnknownPipeEntry,
};

const Pipe = struct {
    position: Position,
    type: PipeType,
    connections: [2]?*Pipe,

    pub fn get_opposite_end(self: *Pipe, input: *Pipe) !*Pipe {
        if (self.connections[0].? == input) {
            return self.connections[1].?;
        }
        if (self.connections[1].? == input) {
            return self.connections[0].?;
        }
        return PipeError.UnknownPipeEntry;
    }
};

const Position = [2]usize;

fn get_pipe_type_from_char(char: u8) PipeType {
    return switch (char) {
        "|"[0] => PipeType.Vertical,
        "-"[0] => PipeType.Horizontal,
        "L"[0] => PipeType.BendTopRight,
        "J"[0] => PipeType.BendTopLeft,
        "F"[0] => PipeType.BendBottomRight,
        "7"[0] => PipeType.BendBottomLeft,
        "S"[0] => PipeType.Unknown,
        else => unreachable,
    };
}

const file = @embedFile("input");

pub fn main() !void {
    var pipes = std.AutoArrayHashMap(Position, Pipe).init(std.heap.page_allocator);
    defer pipes.deinit();

    var it = std.mem.split(u8, file, "\n");
    var y: usize = 1; // Added an offset to avoid -1 checks

    while (it.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        for (line, 0..line.len) |char, x| {
            if (char == "."[0]) {
                continue;
            }

            // Added an offest on X to avoid -1 checks
            var pipe = Pipe{
                .position = .{ x + 1, y },
                .type = get_pipe_type_from_char(char),
                .connections = .{ null, null },
            };

            try pipes.put(.{ x + 1, y }, pipe);
        }

        y += 1;
    }

    var start: Position = undefined;

    // Connect the pipes
    for (pipes.keys()) |pos| {
        var pipe = pipes.getPtr(pos).?;

        switch (pipe.type) {
            .Vertical => {
                pipe.connections[0] = pipes.getPtr(.{ pos[0], pos[1] - 1 });
                pipe.connections[1] = pipes.getPtr(.{ pos[0], pos[1] + 1 });
            },
            .Horizontal => {
                pipe.connections[0] = pipes.getPtr(.{ pos[0] - 1, pos[1] });
                pipe.connections[1] = pipes.getPtr(.{ pos[0] + 1, pos[1] });
            },
            .BendTopRight => {
                pipe.connections[0] = pipes.getPtr(.{ pos[0], pos[1] - 1 });
                pipe.connections[1] = pipes.getPtr(.{ pos[0] + 1, pos[1] });
            },
            .BendTopLeft => {
                pipe.connections[0] = pipes.getPtr(.{ pos[0], pos[1] - 1 });
                pipe.connections[1] = pipes.getPtr(.{ pos[0] - 1, pos[1] });
            },
            .BendBottomRight => {
                pipe.connections[0] = pipes.getPtr(.{ pos[0], pos[1] + 1 });
                pipe.connections[1] = pipes.getPtr(.{ pos[0] + 1, pos[1] });
            },
            .BendBottomLeft => {
                pipe.connections[0] = pipes.getPtr(.{ pos[0], pos[1] + 1 });
                pipe.connections[1] = pipes.getPtr(.{ pos[0] - 1, pos[1] });
            },
            .Unknown => {
                start = pos;
            },
        }
    }

    // print("{any}\n", .{pipes.values()});

    // Count the distance from the starting point
    // Test every direction and take the lowest distance values
    // The farthest is the one with the highest distance

    var distances = std.AutoArrayHashMap(Position, usize).init(std.heap.page_allocator);
    defer distances.deinit();

    var directions = [_]?*Pipe{
        pipes.getPtr(.{ start[0] - 1, start[1] }),
        pipes.getPtr(.{ start[0] + 1, start[1] }),
        pipes.getPtr(.{ start[0], start[1] - 1 }),
        pipes.getPtr(.{ start[0], start[1] + 1 }),
    };

    var start_pipe = pipes.getPtr(start).?;

    for (directions) |maybe_dir| {
        var prev: *Pipe = pipes.getPtr(start).?;

        // If there is no pipe at cursor, forget about it
        if (maybe_dir) |dir| {
            var cur: *Pipe = dir;

            var counter: usize = 0;

            while (cur != start_pipe) {
                counter += 1;

                var entry = try distances.getOrPut(cur.position);
                if (entry.found_existing) {
                    entry.value_ptr.* = @min(entry.value_ptr.*, counter);
                } else {
                    entry.value_ptr.* = counter;
                }

                var next = cur.get_opposite_end(prev) catch {
                    print("Could not get the other end of the pipe\n", .{});
                    break;
                };

                prev = cur;
                cur = next;
            }
        }
    }

    // print("{any}\n", .{distances.values()});

    var farthest: usize = 0;
    for (distances.values()) |dist| {
        if (dist > farthest) {
            farthest = dist;
        }
    }

    print("The farthest pipe is at the distance: {}\n", .{farthest});
}
