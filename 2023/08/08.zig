const std = @import("std");
const print = std.debug.print;

const doc =
    \\RL
    \\
    \\AAA = (BBB, CCC)
    \\BBB = (DDD, EEE)
    \\CCC = (ZZZ, GGG)
    \\DDD = (DDD, DDD)
    \\EEE = (EEE, EEE)
    \\GGG = (GGG, GGG)
    \\ZZZ = (ZZZ, ZZZ)
;

const doc2 =
    \\LLR
    \\
    \\AAA = (BBB, BBB)
    \\BBB = (AAA, ZZZ)
    \\ZZZ = (ZZZ, ZZZ)
;

const Node = struct {
    id: [3]u8,
    left: ?*Node,
    right: ?*Node,
};

const file = @embedFile("input");

pub fn main() !void {
    var it = std.mem.split(u8, file, "\n");

    var instructions = it.next().?;
    print("Instructions: {s}\n", .{instructions});

    var nodes = std.AutoArrayHashMap([3]u8, Node).init(std.heap.page_allocator);
    defer nodes.deinit();

    while (it.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var id = line[0..3].*;
        var node = Node{
            .id = id,
            .left = null,
            .right = null,
        };

        try nodes.put(id, node);
    }

    // Connect the nodes
    it.reset();
    _ = it.next().?;

    while (it.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var node = nodes.getPtr(line[0..3].*).?;
        var left = nodes.getPtr(line[7..10].*);
        var right = nodes.getPtr(line[12..15].*);

        node.left = left;
        node.right = right;
    }

    print("Nodes: {s}\n", .{nodes.keys()});

    var cur: *Node = nodes.getPtr("AAA".*).?;
    var inst_id: usize = 0;
    var steps: usize = 0;

    while (std.mem.eql(u8, @constCast(&cur.id), "ZZZ") == false) {
        var inst = instructions[inst_id .. inst_id + 1];

        print("Instruction: {s}\n", .{inst});

        if (std.mem.eql(u8, inst, "L")) {
            cur = cur.left.?;
        }

        if (std.mem.eql(u8, inst, "R")) {
            cur = cur.right.?;
        }

        inst_id += 1;
        if (inst_id > instructions.len - 1) {
            inst_id = 0;
        }

        steps += 1;
    }

    print("Reached ZZZ in {} steps\n", .{steps});
}
