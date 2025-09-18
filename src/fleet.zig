const std = @import("std");
const random = @import("random.zig");

const Ship = @import("ship.zig");
const Turret = @import("turret.zig");

const Writer = std.io.Writer;

const Position = union(enum) {
    none: void,
    ship: Ship,

    pub fn empty() @This() {
        return .{ .none = {} };
    }
};

const Self = @This();
pub const MAX_POS = 5;

positions: [MAX_POS]Position = [1]Position{Position.empty()} ** MAX_POS,

pub fn init() Self {
    return .{};
}

pub fn randomly_populate() Self {
    var fleet = Self{};
    for (&fleet.positions) |*pos| {
        pos.* = .{ .ship = Ship.gacha() };
        for (0..pos.ship.equipment.len) |_| {
            var filled = false;
            while (!filled) {
                pos.ship.add_equipment(.{ .turret = Turret.gacha() }) catch {
                    filled = false;
                    continue;
                };
                filled = true;
            }
        }
    }
    return fleet;
}

pub fn select_random_ship(self: *Self) *Position {
    const index = random.range(usize, 0, self.positions.len - 1);
    return &self.positions[index];
}

pub fn add_ship(self: *Self, ship: Ship) !void {
    for (&self.positions) |*pos| {
        switch (pos.*) {
            .none => {
                pos.* = .{ .ship = ship };
                return;
            },
            .ship => {},
        }
    }
    return error.fleet_full;
}

pub fn display_list_ships(self: *const Self, writer: *Writer) !void {
    for (self.positions, 1..) |pos, i| {
        switch (pos) {
            .none => try writer.print("Slot {d}: None", .{i}),
            .ship => {
                try writer.print("Slot {d}: ", .{i});
                try pos.ship.display_name_short(writer);
            },
        }
        try writer.writeByte('\n');
    }
}

pub fn serialize(self: *const Self, writer: *Writer) !void {
    try writer.writeAll(std.mem.asBytes(self));
}
