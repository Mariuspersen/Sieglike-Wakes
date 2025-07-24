const random = @import("random.zig");

pub const DMG_T = u32;
pub const WEIGHT_T = u32;


pub const TUPLET_NAMING = [_][]const u8{
    "Single",
    "Double",
    "Triple",
    "Quadruple",
    "Quintuple",
    "Sextuple",
    "Septuple",
    "Octuple",
};

const MAX_RANGE = 1.0;
const MIN_RANGE = 0.0;
const ULTRA_RARE_RATE = 0.05;
const SUPER_RARE_RATE = 0.15;
const RARE_RATE = 0.35;
const COMMON_RATE = 0.9;

pub const RARITY = enum(u3) {
    ULTRA_RARE = 4,
    SUPER_RARE = 3,
    RARE = 2,
    COMMON = 1,
    RUST = 0,

    pub fn gacha() @This() {
        const number = random.random(f32);
        if (ULTRA_RARE_RATE > number) return .ULTRA_RARE;
        if (SUPER_RARE_RATE > number) return .SUPER_RARE;
        if (RARE_RATE > number) return .RARE;
        if (COMMON_RATE > number) return .COMMON;
        return .RUST;
    }

    pub fn float(self: *const @This()) f32 {
        const int: u3 = @intFromEnum(self.*);
        return @floatFromInt(int);
    }

    pub fn display(self: *const @This()) []const u8 {
        return switch (self.*) {
            .ULTRA_RARE =>  "Ultra Rare",
            .SUPER_RARE =>  "Super Rare",
            .RARE       =>  "Rare",
            .COMMON     =>  "Common",
            .RUST       =>  "Rusty"
        };
    }
};

pub fn oneMoreThan(T: type) type {
    const builtin = @import("std").builtin;
    const info = @typeInfo(T);
    const newT = builtin.Type{ .int = .{
        .bits = info.int.bits + 1,
        .signedness = info.int.signedness,
    } };
    return @Type(newT);
}

pub fn doubleType(T: type) type {
    const builtin = @import("std").builtin;
    const info = @typeInfo(T);
    const newT = builtin.Type{ .int = .{
        .bits = info.int.bits * 2,
        .signedness = info.int.signedness,
    } };
    return @Type(newT);
}
