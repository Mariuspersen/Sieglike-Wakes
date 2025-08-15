const Self = @This();
const random = @import("random.zig");
const common = @import("common.zig");
const std = @import("std");

const BARREL_T = u2;
const ONEMORE_T = common.oneMoreThan(BARREL_T);
const CALIBER_T = u6;
const BORE_T = u8;
const ACC_T = f32;
const DMG_T = common.DMG_T;
const WEIGHT_T = common.WEIGHT_T;

barrels: BARREL_T,
caliber: CALIBER_T,
bore: BORE_T,
accuracy: ACC_T,
rarity: common.RARITY,

pub fn gacha() Self {
    return .{
        .barrels = random.random(BARREL_T),
        .bore = random.random(BORE_T),
        .caliber = random.random(CALIBER_T),
        .accuracy = random.range(ACC_T, 0.0, 100.0),
        .rarity = common.RARITY.gacha(),
    };
}

pub fn max() Self {
    return .{
        .barrels = std.math.maxInt(BARREL_T),
        .bore = std.math.maxInt(BORE_T),
        .caliber = std.math.maxInt(CALIBER_T),
        .accuracy = 100.0,
        .rarity = common.RARITY.ULTRA_RARE,
    };
}

test "maxTest" {
    const max_possible = Self.max();
    const dmg = max_possible.damage();
    std.debug.print("MAX DMG => {d}, Bits required: {d}\n", .{dmg, std.math.log2(dmg) + 1});
}

pub fn damage(self: *const Self) DMG_T {
    var total: DMG_T = 0;
    var rolls: ONEMORE_T = self.barrels;
    rolls += 1;
    for (0..rolls) |_| {
        const hit_roll = if (@inComptime()) 100.0 else random.range(ACC_T, 0.0, 100.0);
        if (self.accuracy * self.rarity.float() < hit_roll) continue;
        total += self.bore;
        total += self.caliber;
    }
    total *= @intFromEnum(self.rarity);
    return total;
}

pub fn weight(self: *const Self) WEIGHT_T {
    const barrel_weight: f32 = 0.8 * @as(f32, @floatFromInt(self.caliber)) * @as(f32, @floatFromInt(self.bore));
    const all_barrels: f32 = barrel_weight * @as(f32, @floatFromInt(self.barrels));
    const rarity_bonus = self.rarity.float() + 1;
    const total: f32 = (all_barrels / rarity_bonus) + self.accuracy;
    return @intFromFloat(total);
}

test "Turret Weight Test" {
    var max_possible = Self.max();
    const dmg = max_possible.weight();
    std.debug.print("MAX WEIGHT => {d}\n", .{dmg});
}

pub fn display(self: *const Self, writer: anytype) !void {
    try writer.print("{s} {d}mm/{d} Caliber {s} Turret", .{ self.rarity.display(), self.bore, self.caliber, common.TUPLET_NAMING[self.barrels] });
}
