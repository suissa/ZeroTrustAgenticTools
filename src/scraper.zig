const common = @import("common.zig");

pub fn main() !void {
    try common.run(.{
        .name = "ztat-scraper",
        .domain = "web scraping",
        .purpose = "robots-aware scrape plans, extraction schemas, rate-limit plans, provenance capture",
        .capabilities = &.{ "robots-aware scrape plans, extraction schemas, rate-limit plans, provenance capture", "validates all input as untrusted", "returns plan-only JSON by default", "requires scoped capability tokens for side effects" },
        .denied_actions = &.{ "no autonomous money movement, purchasing, deletion, messaging, or network access", "no secret echoing or credential persistence", "no execution of user-provided commands" },
        .required_evidence = &.{ "authenticated actor and tenant", "explicit task policy", "source provenance", "approval for regulated or irreversible actions", "audit correlation id" },
    });
}
