const Self = @This();
const random = @import("random.zig");
const common = @import("common.zig");
const Turret = @import("turret.zig");
const std = @import("std");

const names = @embedFile("ships.txt");

const Equipment = union(enum) {
    none,
    turret: Turret,

    pub fn empty() @This() {
        return .{ .none = {} };
    }
};

const NAME_MAX_LEN = std.math.maxInt(u6);
const EQUIP_MAX_LEN = 4;
const DMG_T = common.DMG_T;
const HP_T = common.ARMOR_T;
const WEIGHT_T = common.WEIGHT_T;
const SIZE_T = u6;
const DOUBLESIZE_T = common.doubleType(SIZE_T);
const BEAM_RATIO = 0.12;
const DRAFT_RATIO = 0.045;

const Class = struct {
    short: []const u8,
    long: []const u8,
    multiplier: f32,

    pub fn init(short: []const u8, long: []const u8, multiplier: f32) @This() {
        return .{
            .short = short,
            .long = long,
            .multiplier = multiplier,
        };
    }
};

pub const CLASS_LIST = [_]Class{
    Class.init("TB", "Torpedo Boat", 1.0),
    Class.init("DD", "Destroyer", 2.0),
    Class.init("CL", "Light Cruiser", 3.0),
    Class.init("CA", "Heavy Cruiser", 3.5),
    Class.init("CB", "Large Cruiser", 4.5),
    Class.init("BC", "Battlecruiser", 5.5),
    Class.init("BB", "Battleship", 6.0),
};

name: []const u8,
HP: HP_T,
armour: HP_T,
equipment: [EQUIP_MAX_LEN]Equipment,
class: Class,
length: DOUBLESIZE_T,
rarity: common.RARITY,

fn weight(length: u32) WEIGHT_T {
    const submergedVolume = length * beam(length) * draft(length);
    return @divTrunc((submergedVolume * 1025), 1000);
}

fn beam(length: u32) u32 {
    const fLength: f32 = @floatFromInt(length);
    const result: f32 = fLength * BEAM_RATIO;
    return @intFromFloat(result);
}

fn draft(length: u32) u32 {
    const fLength: f32 = @floatFromInt(length);
    const result: f32 = fLength * DRAFT_RATIO;
    return @intFromFloat(result);
}

pub fn carry_limit(self: *const Self) WEIGHT_T {
    const scaler = 100.0;
    const volume = self.length * beam(self.length) * draft(self.length);
    const scaled: f32 = @as(f32, @floatFromInt(volume)) / scaler;
    const class_bonus = self.class.multiplier;
    const total = scaled * class_bonus * self.rarity.float();
    return @intFromFloat(total);
}

pub fn gacha() Self {
    const class_index = random.range(usize, 0, CLASS_LIST.len - 1);
    const class = CLASS_LIST[class_index];
    const armor = random.random(HP_T);
    const length = random.range(f32, 40.0, 50.0) * class.multiplier;
    var split = std.mem.splitAny(u8, names, "\n");
    const limit = random.random(u10);
    for (0..limit) |_| _ = split.next();
    return .{
        .name = split.next() orelse "NULL",
        .class = class,
        .armour = armor,
        .equipment = [1]Equipment{Equipment.empty()} ** EQUIP_MAX_LEN,
        .HP = random.random(HP_T),
        .length = @intFromFloat(length),
        .rarity = common.RARITY.gacha(),
    };
}

pub fn add_equipment(self: *Self, equipment: Equipment) !void {
    var current_capacity: WEIGHT_T = 0;
    for (self.equipment) |e| {
        switch (e) {
            .none => {},
            .turret => |t| current_capacity += t.weight(),
        }
    }
    if (current_capacity > self.carry_limit()) return error.overweight;

    switch (equipment) {
        .none => {},
        .turret => |t| current_capacity += t.weight(),
    }

    if (current_capacity > self.carry_limit()) return error.overweight;

    for (&self.equipment) |*e| {
        switch (e.*) {
            .none => {
                e.* = equipment;
                break;
            },
            else => {},
        }
    }
}

pub fn display(self: *const Self, writer: anytype) !void {
    const lbeam = beam(self.length);
    const ldraft = draft(self.length);
    try writer.print("{s} {s} {s}\n", .{ self.rarity.display(), self.class.long, self.name });
    try writer.print("HP: {d}\nArmor: {d}\n", .{ self.HP, self.armour });
    try writer.print("Length: {d}\nBeam: {d}\nDraft: {d}\n", .{ self.length, lbeam, ldraft });
    try writer.print("Equipment:\n", .{});
    for (self.equipment, 1..) |slot, i| {
        try writer.print("Slot {d}: ", .{i});
        switch (slot) {
            .none => try writer.print("None", .{}),
            .turret => |t| try t.display(writer),
        }
        try writer.print("\n", .{});
    }
    try writer.print("Carrying Capacity: {d}\n", .{self.carry_limit()});
}
