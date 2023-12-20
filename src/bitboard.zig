const std = @import("std");
const testing = std.testing;
const chess = @import("chess.zig");
// MSB      ...     LSB
// North    ...     South
// Black    ...     White
// Bitboards
pub const Bitboard = u64;
// Place bits are u64s with a single bit population.
// They are meant to mark a single piece's position like a bitboard.
pub const Placebit = u64;

pub const all = 0xffffffffffffffff;
pub const rank1 = 0x00000000000000ff;
pub const rank2 = 0x000000000000ff00;
pub const rank3 = 0x0000000000ff0000;
pub const rank4 = 0x00000000ff000000;
pub const rank5 = 0x000000ff00000000;
pub const rank6 = 0x0000ff0000000000;
pub const rank7 = 0x00ff000000000000;
pub const rank8 = 0xff00000000000000;

pub const fileA = 0x0101010101010101;
pub const fileB = 0x0202020202020202;
pub const fileC = 0x0404040404040404;
pub const fileD = 0x0808080808080808;
pub const fileE = 0x1010101010101010;
pub const fileF = 0x2020202020202020;
pub const fileG = 0x4040404040404040;
pub const fileH = 0x8080808080808080;

pub fn placebitFromInd(pos_ind: chess.PosInd) Placebit {
    return @as(u64, 1) << pos_ind.ind;
}

pub fn indFromPlacebit(pos: Placebit) chess.PosInd {
    return chess.PosInd{ .ind = @ctz(pos) };
}

pub fn shiftNorth(board: Bitboard, comptime n: u8) Bitboard {
    return board << (8 * n);
}

pub fn shiftSouth(board: Bitboard, comptime n: u8) Bitboard {
    return board >> (8 * n);
}

pub fn shiftEast(board: Bitboard, comptime n: u8) Bitboard {
    // Mask of positions a starting position could move to
    const mask = switch (n) {
        1 => 0xfefefefefefefefe,
        2 => 0xfcfcfcfcfcfcfcfc,
        3 => 0xf8f8f8f8f8f8f8f8,
        4 => 0xf0f0f0f0f0f0f0f0,
        5 => 0xe0e0e0e0e0e0e0e0,
        6 => 0xc0c0c0c0c0c0c0c0,
        7 => 0x8080808080808080,
        else => all,
    };
    return (board << n) & mask;
}

pub fn shiftWest(board: Bitboard, comptime n: u8) Bitboard {
    // Mask of starting positions that can make this move (same as shiftEast mask)
    const mask = switch (n) {
        1 => 0xfefefefefefefefe,
        2 => 0xfcfcfcfcfcfcfcfc,
        3 => 0xf8f8f8f8f8f8f8f8,
        4 => 0xf0f0f0f0f0f0f0f0,
        5 => 0xe0e0e0e0e0e0e0e0,
        6 => 0xc0c0c0c0c0c0c0c0,
        7 => 0x8080808080808080,
        else => all,
    };
    return (board & mask) >> n;
}

pub fn shiftNE(board: Bitboard, comptime n: u8) Bitboard {
    // Mask of positions a starting position could move to
    const mask = switch (n) {
        1 => 0xfefefefefefefe00,
        2 => 0xfcfcfcfcfcfc0000,
        3 => 0xf8f8f8f8f8000000,
        4 => 0xf0f0f0f000000000,
        5 => 0xe0e0e00000000000,
        6 => 0xc0c0000000000000,
        7 => 0x8000000000000000,
        else => all,
    };
    return (board << (9 * n) & mask);
}

pub fn shiftSE(board: Bitboard, comptime n: u8) Bitboard {
    // Mask of positions a starting position could move to
    const mask = switch (n) {
        1 => 0x00fefefefefefefe,
        2 => 0x0000fcfcfcfcfcfc,
        3 => 0x000000f8f8f8f8f8,
        4 => 0x00000000f0f0f0f0,
        5 => 0x0000000000e0e0e0,
        6 => 0x000000000000c0c0,
        7 => 0x0000000000000080,
        else => all,
    };
    return (board >> (7 * n) & mask);
}

pub fn shiftSW(board: Bitboard, comptime n: u8) Bitboard {
    // Mask of starting positions that can make this move (same as shiftNE mask)
    const mask = switch (n) {
        1 => 0xfefefefefefefe00,
        2 => 0xfcfcfcfcfcfc0000,
        3 => 0xf8f8f8f8f8000000,
        4 => 0xf0f0f0f000000000,
        5 => 0xe0e0e00000000000,
        6 => 0xc0c0000000000000,
        7 => 0x8000000000000000,
        else => all,
    };
    return (board & mask) >> (9 * n);
}

pub fn shiftNW(board: Bitboard, comptime n: u8) Bitboard {
    // Mask of starting positions that can make this move (same as shiftSE mask)
    const mask = switch (n) {
        1 => 0x00fefefefefefefe,
        2 => 0x0000fcfcfcfcfcfc,
        3 => 0x000000f8f8f8f8f8,
        4 => 0x00000000f0f0f0f0,
        5 => 0x0000000000e0e0e0,
        6 => 0x000000000000c0c0,
        7 => 0x0000000000000080,
        else => all,
    };
    return (board & mask) << (7 * n);
}

pub fn print(board: Bitboard) void {
    std.debug.print("\n", .{});
    var board_it = board;
    for (0..8) |rank| {
        std.debug.print("{d} {b:0>8}\n", .{ 8 - rank, @bitReverse(@as(u8, @truncate(board_it >> 56))) });
        board_it <<= 8;
    }
    std.debug.print("  abcdefgh\n", .{});
}

////////////////////////////////
// Testing
////////////////////////////////
test "print" {
    // All work as expected
    const a1 = rank1 & fileA;
    std.debug.print("\nA1 square", .{});
    print(a1);
    const checkerboard = 0x55aa55aa55aa55aa;
    std.debug.print("\ncheckerboard", .{});
    print(checkerboard);
    std.debug.print("\nRank 1", .{});
    print(rank1);
    // std.debug.print("\nRank 8", .{});
    // print(rank8);
    std.debug.print("\nFile A", .{});
    print(fileA);
    // std.debug.print("\nFile H", .{});
    // print(fileH);
}

test "shift north-south" {
    try testing.expect(rank2 == shiftNorth(rank1, 1));
    try testing.expect(rank3 == shiftNorth(rank1, 2));
    try testing.expect(rank8 == shiftNorth(rank1, 7));

    try testing.expect(rank1 == shiftSouth(rank2, 1));
    try testing.expect(rank1 == shiftSouth(rank3, 2));
    try testing.expect(rank1 == shiftSouth(rank8, 7));
}

test "shift east-west" {
    try testing.expect(fileB == shiftEast(fileA, 1));
    try testing.expect(fileH == shiftEast(fileA, 7));
    try testing.expect(shiftEast(fileH, 1) == 0);

    // Shifting overflow
    try testing.expect(shiftEast(rank1, 4) == shiftEast(0x000000000000000f, 4));

    try testing.expect(fileA == shiftWest(fileB, 1));
    try testing.expect(fileA == shiftWest(fileH, 7));
    try testing.expect(shiftWest(fileA, 1) == 0);

    // Shifting overflow
    try testing.expect(shiftWest(rank1, 4) == shiftWest(0x00000000000000f0, 4));
}

test "shift diagonal" {
    try testing.expectEqual(shiftNE(rank1 & fileA, 7), rank8 & fileH);
    try testing.expectEqual(shiftNE(rank1 & fileA, 1), rank2 & fileB);

    try testing.expectEqual(shiftSE(rank8 & fileA, 7), rank1 & fileH);
    try testing.expectEqual(shiftSE(rank8 & fileA, 1), rank7 & fileB);

    try testing.expectEqual(shiftNW(rank1 & fileH, 7), rank8 & fileA);
    try testing.expectEqual(shiftNW(rank1 & fileH, 1), rank2 & fileG);

    try testing.expectEqual(shiftSW(rank8 & fileH, 7), rank1 & fileA);
    try testing.expectEqual(shiftSW(rank8 & fileH, 1), rank7 & fileG);
}
