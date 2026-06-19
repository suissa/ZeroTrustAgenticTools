#[path = "../common.rs"]
mod common;
fn main() {
    common::run(common::ToolSpec {
        name: "ztat-rs-security",
        domain: "security operations",
        purpose: "alert triage, threat modeling, policy review, incident runbooks",
        capabilities: &[
            "alert triage, threat modeling, policy review, incident runbooks",
            "validates all input as untrusted",
            "returns plan-only JSON by default",
            "requires scoped capability tokens for side effects",
        ],
        denied_actions: &[
            "no autonomous money movement, purchasing, deletion, messaging, or network access",
            "no secret echoing or credential persistence",
            "no execution of user-provided commands",
        ],
        required_evidence: &[
            "authenticated actor and tenant",
            "explicit task policy",
            "source provenance",
            "approval for regulated or irreversible actions",
            "audit correlation id",
        ],
    });
}
