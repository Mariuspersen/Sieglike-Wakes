const Self = @This();
const random = @import("random.zig");
const common = @import("common.zig");
const Turret = @import("turret.zig");
const std = @import("std");

const Equipment = union(enum) {
    none,
    turret: Turret,

    pub fn empty() @This() {
        return .{ .none = {} };
    }
};

const NAME_MAX_LEN = std.math.maxInt(u6);
const EQUIP_MAX_LEN = std.math.maxInt(u3);
const DMG_T = common.DMG_T;
const HP_T = DMG_T;
const WEIGHT_T = common.WEIGHT_T;
const SIZE_T = u32;

const CLASS_T = enum {
    TB,
    DD,
    CL,
    CA,
    BC,
    BB,
};

name: []const u8,
HP: HP_T,
armour: HP_T,
equipment: [EQUIP_MAX_LEN]Equipment,
class: CLASS_T,
length: SIZE_T,

pub fn weight(length: u32, beam: u32, draft: u32) WEIGHT_T {
    const submergedVolume = length * beam * draft;
    return @divTrunc((submergedVolume * 1025), 1000);
}

pub fn gacha() Self {
    const class = random.random(CLASS_T);
    const armor = random.random(HP_T);
    return .{
        .name = "baslls",
        .class = class,
        .armour = armor,
        .equipment = [1]Equipment{ Equipment.empty() } ** EQUIP_MAX_LEN,
        .HP = random.random(HP_T),
        .length = random.random(SIZE_T),
    };
}

