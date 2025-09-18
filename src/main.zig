const std = @import("std");
const random = @import("random.zig");
const common = @import("common.zig");
const Turret = @import("turret.zig");
const Ship = @import("ship.zig");
const Fleet = @import("fleet.zig");
const Battle = @import("battle.zig");

pub fn main() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    defer stdout.flush() catch {};
    var fleet1 = Fleet.randomly_populate();
    var fleet2 = Fleet.randomly_populate();
    try stdout.writeAll("Player Fleet\n");
    try fleet1.display_list_ships(stdout);
    try stdout.writeAll("Enenmy Fleet\n");
    try fleet2.display_list_ships(stdout);
    var battle = Battle.init(&fleet1, &fleet2);
    try battle.battle(stdout);
}
