const std = @import("std");
const print = std.debug.print;

const doc =
    \\seeds: 79 14 55 13
    \\
    \\seed-to-soil map:
    \\50 98 2
    \\52 50 48
    \\
    \\soil-to-fertilizer map:
    \\0 15 37
    \\37 52 2
    \\39 0 15
    \\
    \\fertilizer-to-water map:
    \\49 53 8
    \\0 11 42
    \\42 0 7
    \\57 7 4
    \\
    \\water-to-light map:
    \\88 18 7
    \\18 25 70
    \\
    \\light-to-temperature map:
    \\45 77 23
    \\81 45 19
    \\68 64 13
    \\
    \\temperature-to-humidity map:
    \\0 69 1
    \\1 0 69
    \\
    \\humidity-to-location map:
    \\60 56 37
    \\56 93 4
;

fn parseInt(text: []const u8) isize {
    return std.fmt.parseInt(isize, text, 10) catch |err| {
        print("{s} -> {}\n", .{ text, err });
        return 0;
    };
}

fn eql(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

const Almanac = struct {
    seeds: []isize,
    seeds_to_soil: [][3]isize,
    soil_to_fertilizer: [][3]isize,
    fertilizer_to_water: [][3]isize,
    water_to_light: [][3]isize,
    light_to_temperature: [][3]isize,
    temperature_to_humidity: [][3]isize,
    humidity_to_location: [][3]isize,

    pub fn maps(self: *Almanac) [7][][3]isize {
        return .{
            self.seeds_to_soil,
            self.soil_to_fertilizer,
            self.fertilizer_to_water,
            self.water_to_light,
            self.light_to_temperature,
            self.temperature_to_humidity,
            self.humidity_to_location,
        };
    }

    pub fn get_seed_location(self: *Almanac, seed: isize) isize {
        var cursor: isize = seed;

        for (self.maps()) |map| {
            cursor = find_destination(cursor, map);
            // print("seed {} -> cursor {}\n", .{ seed, cursor });
        }

        return cursor;
    }

    pub fn get_lowest_location_number(self: *Almanac) !isize {
        var lowest: isize = 0;

        for (self.seeds) |seed| {
            var location = self.get_seed_location(seed);
            if (lowest == 0 or location < lowest) {
                lowest = location;
            }
        }

        return lowest;
    }

    pub fn get_seed_pairs(self: *Almanac) ![][2]isize {
        var list = std.ArrayList([2]isize).init(std.heap.page_allocator);
        defer list.deinit();

        for (0..self.seeds.len / 2) |i| {
            var pair: [2]isize = self.seeds[i * 2 .. i * 2 + 2][0..2].*;
            try list.append(pair);
        }

        return try list.toOwnedSlice();
    }

    // Get the location ranges that match for a given seed pair
    pub fn get_seed_pair_location_ranges(self: *Almanac, seed_pair: [2]isize) ![][2]isize {
        var set = std.AutoArrayHashMap([2]isize, [2]isize).init(std.heap.page_allocator);
        defer set.deinit();

        try set.put(seed_pair, seed_pair);

        for (self.maps()) |map| {
            var buf = std.ArrayList([2]isize).init(std.heap.page_allocator);
            defer buf.deinit();

            for (set.values()) |pair| {
                var ranges = try find_destination_ranges(pair, map);
                for (ranges) |range| {
                    try buf.append(range);
                }
            }

            // Try list.items = buf owned slice?
            set.clearAndFree();
            for (try buf.toOwnedSlice()) |item| {
                try set.put(item, item);
            }
        }

        var list = std.ArrayList([2]isize).init(std.heap.page_allocator);
        defer list.deinit();

        for (set.values()) |value| {
            try list.append(value);
        }

        var results: [][2]isize = try list.toOwnedSlice();
        std.mem.sort([2]isize, results, {}, lessThanRange);

        return results;
    }

    // Revert the process, find the lowest location range
    pub fn get_lowest_location_number2(self: *Almanac) !isize {
        var lowest: isize = 0;

        for ((try self.get_seed_pairs())) |pair| {
            var location_ranges = try self.get_seed_pair_location_ranges(pair);
            // print("\tSeed pair {any} -> location ranges {any}\n", .{ pair, location_ranges });

            for (location_ranges) |range| {
                if (range[0] < lowest or lowest == 0) {
                    lowest = range[0];
                }
            }
        }

        return lowest;
    }
};

fn lessThanRange(_: void, lhs: [2]isize, rhs: [2]isize) bool {
    return lhs[0] < rhs[0];
}

fn find_destination_ranges(range: [2]isize, map: [][3]isize) ![][2]isize {
    var sections = std.AutoArrayHashMap([2]isize, [3]isize).init(std.heap.page_allocator);
    defer sections.deinit();

    var min = range[0];
    var max = range[0] + range[1];

    for (map) |row| {
        // Check intersection
        var intersection: [2]isize = .{
            @max(range[0], row[1]),
            @min(range[0] + range[1], row[1] + row[2]),
        };

        if (intersection[0] > intersection[1]) {
            continue;
        }

        var section: [3]isize = .{
            row[0] + intersection[0] - row[1], // dest (modified to match offset)
            intersection[0], // source
            intersection[1] - intersection[0], // length
        };

        try sections.put(intersection, section);
    }

    var list = std.ArrayList([2]isize).init(std.heap.page_allocator);
    defer list.deinit();

    if (sections.values().len == 0) {
        // There is no sections, return the whole seed
        try list.append(range);
        return try list.toOwnedSlice();
    }

    var tmp = try sections.clone();
    var keys = tmp.keys()[0..];
    std.mem.sort([2]isize, keys, {}, lessThanRange);

    // Fill the gaps
    var cur = min;

    for (0..keys.len) |k| {
        var intersection = keys[k];

        // Insert a section from cursor to the next intersection
        // that correspond to the normal range (no match)
        if (cur < intersection[0]) {
            try list.append(.{ cur, intersection[0] - cur });
        }

        // Add the intersection entry and convert to destination
        var section = sections.get(intersection).?;
        try list.append(.{ section[0], section[2] });

        // Jump to the end of the intersection
        cur = intersection[1];
    }

    if (cur < max) {
        try list.append(.{ cur, max - cur });
    }

    return try list.toOwnedSlice();
}

fn find_destination(seed: isize, map: [][3]isize) isize {
    for (map) |row| {
        var dest = row[0];
        var source = row[1];
        var range = row[2];

        if (seed >= source and seed <= source + range) {
            return seed - source + dest;
        }
    }

    return seed;
}

fn extract_numbers(text: []const u8) ![]isize {
    var list = std.ArrayList(isize).init(std.heap.page_allocator);
    defer list.deinit();

    var it = std.mem.split(u8, text, " ");
    while (it.next()) |n| {
        try list.append(parseInt(n));
    }

    return try list.toOwnedSlice();
}

fn parse_almanac(text: []const u8) !Almanac {
    var alm = Almanac{
        .seeds = undefined,
        .seeds_to_soil = undefined,
        .soil_to_fertilizer = undefined,
        .fertilizer_to_water = undefined,
        .water_to_light = undefined,
        .light_to_temperature = undefined,
        .temperature_to_humidity = undefined,
        .humidity_to_location = undefined,
    };

    var it = std.mem.split(u8, text, "\n");

    var line1 = it.next().?;
    alm.seeds = try extract_numbers(line1[7..]);

    var list = std.ArrayList([3]isize).init(std.heap.page_allocator);
    defer list.deinit();

    var section: []const u8 = undefined;

    while (it.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        if (eql(line[(line.len - 1)..], ":")) {
            if (eql(section, "seed-to-soil")) {
                alm.seeds_to_soil = try list.toOwnedSlice();
            }

            if (eql(section, "soil-to-fertilizer")) {
                alm.soil_to_fertilizer = try list.toOwnedSlice();
            }

            if (eql(section, "fertilizer-to-water")) {
                alm.fertilizer_to_water = try list.toOwnedSlice();
            }

            if (eql(section, "water-to-light")) {
                alm.water_to_light = try list.toOwnedSlice();
            }

            if (eql(section, "light-to-temperature")) {
                alm.light_to_temperature = try list.toOwnedSlice();
            }

            if (eql(section, "temperature-to-humidity")) {
                alm.temperature_to_humidity = try list.toOwnedSlice();
            }

            section = line[0 .. line.len - 5];
            // print("{s}\n", .{section});
            continue;
        }

        if (section.len > 0) {
            try list.append((try extract_numbers(line))[0..3].*);
        }
    }

    if (eql(section, "humidity-to-location")) {
        alm.humidity_to_location = try list.toOwnedSlice();
    }

    return alm;
}

const file = @embedFile("input");

pub fn main() !void {
    var alm = try parse_almanac(doc);
    print("The lowest location number is: {}\n", .{try alm.get_lowest_location_number()});

    var alm2 = try parse_almanac(file);
    print("The lowest location number is: {}\n", .{try alm2.get_lowest_location_number()});

    print("The lowest location number (pair) is: {}\n", .{try alm.get_lowest_location_number2()});
    print("The lowest location number (pair) is: {}\n", .{try alm2.get_lowest_location_number2()});
}
