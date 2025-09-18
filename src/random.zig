const std = @import("std");
const deltaFloat = std.math.floatMax(f32) - std.math.floatMin(f32);
const FLOAT_MIN = std.math.floatMin(f32);

pub fn seededRNG() std.Random.Xoroshiro128 {
    const timestamp: u64 = @truncate(@as(u128, @bitCast(std.time.nanoTimestamp())));
    return std.Random.Xoroshiro128.init(timestamp);
}

pub fn random(T: type) T {
    var rng = seededRNG();
    const info = @typeInfo(T);
    return switch (info) {
        .float => std.Random.float(rng.random(), T),
        .int => std.Random.int(rng.random(), T),
        .@"enum" => std.Random.enumValue(rng.random(), T),
        else => @compileError("Must be float or int")
    };
}

pub fn range(T: type, low: T, high: T) T {
    const info = @typeInfo(T);
    var rng = seededRNG();
    switch (info) {
        .float => {
            const number = std.Random.float(rng.random(), f32);
            return std.math.lerp(low, high, number);
        },
        .int => {
            return std.Random.intRangeAtMost(
                rng.random(),
                T,
                low,
                high,
            );
        },
        else => @compileError("Must be float or int")
    }
}
