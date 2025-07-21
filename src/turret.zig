const Self = @This();
const random = @import("random.zig");
const common = @import("common.zig");

const display_name_for_number_of_guns = [_][]const u8{ "Single", "Double", "Triple", "Quadruple", "Quintuple", "Sextuple", "Septuple", "Octuple" };

const BARREL_T = u2;
const CALIBER_T = u6;
const BORE_T = u8;
const ACC_T = f32;

pub fn oneMoreThan(T: type) type {
    const builtin = @import("std").builtin;
    const info = @typeInfo(T);
    const newT = builtin.Type{ .int = .{
        .bits = info.int.bits + 1,
        .signedness = info.int.signedness,
    } };
    return @Type(newT);
}

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

pub fn damage(self: *const Self) u32 {
    var total: u32 = 0;
    var rolls: oneMoreThan(BARREL_T) = self.barrels;
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
    try writer.print("{s} {d}mm/{d} Caliber {s} Turret", .{ self.rarity.display(), self.bore, self.caliber, display_name_for_number_of_guns[self.barrels] });
}
