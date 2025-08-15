const std = @import("std");
const random = @import("random.zig");
const common = @import("common.zig");
const turret = @import("turret.zig");
const ship = @import("ship.zig");


pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const new_turret = turret.gacha();
    try new_turret.display(stdout);
    try stdout.print("\tDamage: {d}\n", .{new_turret.damage()});
    var new_ship = ship.gacha();
    new_ship.add_equipment(.{.turret = new_turret}) catch {
        try stdout.print("Ship doesn't have the carrying capacity to equip this\n", .{});
        try stdout.print("Capacity: {d} => Turret Weight {d}\n", .{new_ship.carry_limit(),new_turret.weight()});
    };
    try new_ship.display(stdout);
}
