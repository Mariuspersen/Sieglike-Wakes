const Self = @This();
const random = @import("random.zig");
const common = @import("common.zig");

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

pub fn damage(self: *const Self) DMG_T {
    var total: DMG_T = 0;
    var rolls: ONEMORE_T = self.barrels;
    rolls += 1;
    for (0..rolls) |_| {
        const hit_roll = random.range(ACC_T, 0.0, 100.0);
        if (self.accuracy * self.rarity.float() < hit_roll) continue;
        total += self.bore;
        total += self.caliber;
    }
    total *= @intFromEnum(self.rarity);
    return total;
}



pub fn display(self: *const Self, writer: anytype) !void {
    try writer.print("{s} {d}mm/{d} Caliber {s} Turret", .{ self.rarity.display(), self.bore, self.caliber, common.TUPLET_NAMING[self.barrels] });
}
