const Self = @This();
const std = @import("std");

const WORD_LEN = 12;
const MAX_WORDS = 10;

const Entry = struct {
    word: [WORD_LEN]u8,
    frequency: u8,
};

const ChainEntry = union {
    none: void,
    entry: Entry,
};

pub fn init(filename: []const u8) !Self {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const alloc = std.heap.c_allocator;

    const stat = try file.stat();
    const text = try file.readToEndAlloc(alloc, stat.size);
    defer alloc.free(text);

    const hash = std.StringHashMap([MAX_WORDS]ChainEntry).init(alloc);

    var split = std.mem.splitAny(u8, text, "\n\r ");
    while (split.next()) |word| {
        if (split.next()) |next| {
            const result = try hash.getOrPut(word);
            if (result.found_existing) {
                for (result.value_ptr) |*value| {
                    switch (value.*) {
                        .none => {},
                        .entry => {},
                    }
                }
            } else {
                result.value_ptr.* = ChainEntry{ .none = {} } ** MAX_WORDS;
                result.value_ptr[0] = .{ .entry = .{ .word = next, .frequency = 1 } };
            }
        }
        
    }
}