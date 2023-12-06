const std = @import("std");
const print = std.debug.print;

fn parseInt(text: []const u8) isize {
    return std.fmt.parseInt(isize, std.mem.trim(u8, text, " "), 10) catch |err| {
        print("{}\n", .{err});
        return 0;
    };
}

const doc =
    \\Time:         7     15     30
    \\Distance:     9     40    200
;

fn get_travelled_distance(press_duration: isize, time: isize) isize {
    var speed = press_duration;
    return (time - press_duration) * speed;
}

const Race = struct {
    time: isize,
    record_distance: isize,

    // Returns the minimum press duration to break the record
    pub fn get_min_press_duration(self: *const Race) isize {
        var len: usize = @intCast(self.time);
        for (0..len) |dt| {
            var press_duration: isize = @intCast(dt);
            var travel = get_travelled_distance(press_duration, self.time);
            if (travel > self.record_distance) {
                return press_duration;
            }
        }
        return 0;
    }

    // Returns the maximum press duration to break the record
    pub fn get_max_press_duration(self: *const Race) isize {
        var dt: isize = self.time;
        while (dt > 0) {
            var travel = get_travelled_distance(dt, self.time);
            if (travel > self.record_distance) {
                return dt;
            }
            dt -= 1;
        }
        return self.time;
    }

    pub fn get_winning_press_count(self: *const Race) isize {
        return self.get_max_press_duration() - self.get_min_press_duration() + 1;
    }
};

fn extract_numbers(text: []const u8, cols: usize) ![]isize {
    var numbers = std.ArrayList(isize).init(std.heap.page_allocator);
    defer numbers.deinit();

    for (0..cols) |i| {
        try numbers.append(parseInt(text[i * 7 .. (i * 7) + 6]));
    }

    return numbers.toOwnedSlice();
}

fn parse_races(text: []const u8, cols: usize) ![]Race {
    var list = std.ArrayList(Race).init(std.heap.page_allocator);
    defer list.deinit();

    var lines = std.mem.split(u8, text, "\n");

    var times = try extract_numbers(lines.next().?[9..], cols);
    // print("{any}\n", .{times});

    var distances = try extract_numbers(lines.next().?[9..], cols);
    // print("{any}\n", .{distances});

    for (0..cols) |i| {
        var race = Race{
            .time = times[i],
            .record_distance = distances[i],
        };
        try list.append(race);
    }

    return try list.toOwnedSlice();
}

const file = @embedFile("input");

pub fn main() !void {
    var races: []Race = try parse_races(doc, 3);
    var total: isize = 1;

    for (races) |race| {
        print("{any} -> min {}, max {}\n", .{ race, race.get_min_press_duration(), race.get_max_press_duration() });
        total *= race.get_winning_press_count();
    }

    print("Possible ways to beat the record (multiplied): {}\n", .{total});
    print("\n", .{});

    var races2: []Race = try parse_races(file, 4);
    total = 1;

    for (races2) |race| {
        print("{any} -> min {}, max {}\n", .{ race, race.get_min_press_duration(), race.get_max_press_duration() });
        total *= race.get_winning_press_count();
    }

    print("Possible ways to beat the record (multiplied): {}\n", .{total});
}
