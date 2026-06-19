const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const tools = [_][]const u8{
        "finance",       "accounting",         "support",      "sales",            "security", "infra",
        "data-analysis", "personal-assistant", "digital-twin", "personal-shopper", "scraper",  "premium-layout",
    };

    for (tools) |name| {
        const exe = b.addExecutable(.{
            .name = b.fmt("ztat-{s}", .{name}),
            .root_source_file = b.path(b.fmt("src/{s}.zig", .{name})),
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(exe);
    }
}
