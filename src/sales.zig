const common = @import("common.zig");

pub fn main() !void {
    try common.run(.{
        .name = "ztat-sales",
        .domain = "sales operations",
        .purpose = "lead scoring, proposal drafting, CRM update plans, pipeline hygiene",
        .capabilities = &.{ "lead scoring, proposal drafting, CRM update plans, pipeline hygiene", "validates all input as untrusted", "returns plan-only JSON by default", "requires scoped capability tokens for side effects" },
        .denied_actions = &.{ "no autonomous money movement, purchasing, deletion, messaging, or network access", "no secret echoing or credential persistence", "no execution of user-provided commands" },
        .required_evidence = &.{ "authenticated actor and tenant", "explicit task policy", "source provenance", "approval for regulated or irreversible actions", "audit correlation id" },
    });
}
