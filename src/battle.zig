const Fleet = @import("fleet.zig");
const Ship = @import("ship.zig");

const common = @import("common.zig");
const random = @import("random.zig");

const std = @import("std");
const Writer = std.io.Writer;


const Self = @This();
const DMG_T = common.DMG_T;

player: *Fleet,
enemy: *Fleet,
result: packed struct {
    player_damage_dealt: DMG_T = 0,
    enemy_damage_dealt: DMG_T = 0,
},

pub fn init(player: *const Fleet, enemy: *const Fleet) Self {
    return .{
        .player = @constCast(player),
        .enemy = @constCast(enemy),
        .result = .{},
    };
}

pub fn attack(_: *Self,_: *const Ship, _: *Ship) !void {

}

pub fn battle(self: *Self, writer: *Writer) !void {
    for (self.player.positions,self.enemy.positions) |ppos, epos| {
        switch (ppos) {
            .ship => |*player_ship| {
                try player_ship.display_name_short(writer);
                const ship_index = random.range(usize, 0, self.enemy.positions.len - 1);
                switch (self.enemy.positions[ship_index]) {
                    .ship => |*enemy_ship| {
                        const equipment_index = random.range(usize, 0, enemy_ship.equipment.len - 1);
                        switch (player_ship.equipment[equipment_index]) {
                            .turret => |t| {
                                const damage: common.ARMOR_T = @as(common.ARMOR_T, @truncate(t.damage()));
                                enemy_ship.*.HP = if (damage > enemy_ship.HP) 0 else enemy_ship.HP - damage;
                                try writer.print(" dealt {d} damage to {s}",.{damage,if (enemy_ship.HP == 0) "and sunk " else ""});
                                try enemy_ship.display_name_short(writer);
                                if (enemy_ship.HP == 0) {
                                    self.enemy.positions[ship_index] = .empty();
                                }
                            },
                            else => {
                                try writer.writeAll("'s crew were not at battle stations!");
                            }
                        }
                    },
                    else => {
                        try writer.writeAll(" missed the enemy!");
                    }
                }
            },
            else => {
                try writer.writeAll("Admiral failed to give the correct orders!");
            }
        }
        try writer.writeByte('\n');
        switch (epos) {
            .ship => |*enemy_ship| {
                try enemy_ship.display_name_short(writer);
                const ship_index = random.range(usize, 0, self.player.positions.len - 1);
                switch (self.player.positions[ship_index]) {
                    .ship => |*player_ship| {
                        const equipment_index = random.range(usize, 0, enemy_ship.equipment.len - 1);
                        switch (enemy_ship.equipment[equipment_index]) {
                            .turret => |t| {
                                const damage: common.ARMOR_T = @as(common.ARMOR_T, @truncate(t.damage()));
                                player_ship.*.HP = if (damage > player_ship.HP) 0 else player_ship.HP - damage;
                                try writer.print(" dealt {d} damage to {s}",.{damage,if (player_ship.HP == 0) "causing a retreat of " else ""});
                                try player_ship.display_name_short(writer);
                                if (player_ship.HP == 0) {
                                    self.enemy.positions[ship_index] = .empty();
                                }
                            },
                            else => {
                                try writer.writeAll("Enemy did nothing.");
                            }
                        }
                    },
                    else => {
                        try writer.writeAll(" missed the player!");
                    }
                }
            },
            else => {
                try writer.writeAll("Enemy did nothing.");
            }
        }
        try writer.writeByte('\n');
    }
}
