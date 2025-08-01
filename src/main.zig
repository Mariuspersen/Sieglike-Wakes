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
    const new_ship = ship.gacha();
    try new_ship.display(stdout);
}
