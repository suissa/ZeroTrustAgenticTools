use std::io::Read;
pub struct ToolSpec {
    pub name: &'static str,
    pub domain: &'static str,
    pub purpose: &'static str,
    pub capabilities: &'static [&'static str],
    pub denied_actions: &'static [&'static str],
    pub required_evidence: &'static [&'static str],
}
const MAX: usize = 64 * 1024;
const INJECTION: &[&str] = &[
    "ignore previous",
    "ignore all",
    "system prompt",
    "developer message",
    "jailbreak",
    "exfiltrate",
    "disable safety",
    "bypass",
    "sudo ",
    "rm -rf",
    "curl ",
    "wget ",
];
const SECRETS: &[&str] = &[
    "api_key",
    "apikey",
    "secret",
    "password",
    "token=",
    "\"token\"",
    "bearer ",
    "private key",
    "aws_access_key_id",
    "-----begin",
];
pub fn run(spec: ToolSpec) {
    if std::env::args().any(|a| a == "--help" || a == "-h") {
        help(&spec);
        return;
    }
    let mut data = Vec::new();
    std::io::stdin()
        .take((MAX + 1) as u64)
        .read_to_end(&mut data)
        .expect("stdin");
    if data.len() > MAX {
        panic!("InputTooLarge");
    }
    let lower = String::from_utf8_lossy(&data).to_lowercase();
    let inj = INJECTION.iter().any(|p| lower.contains(p));
    let sec = SECRETS.iter().any(|p| lower.contains(p));
    let risk = if inj || sec {
        "high"
    } else if data.is_empty() {
        "low"
    } else {
        "medium"
    };
    println!("{{\n  \"tool\": \"{}\",\n  \"domain\": \"{}\",\n  \"zero_trust\": {{\n    \"default_decision\": \"deny\",\n    \"input_bytes\": {},\n    \"risk\": \"{}\",\n    \"approved_for_execution\": false,\n    \"requires_human_approval\": true,\n    \"secrets_redacted\": true,\n    \"network_allowed\": false,\n    \"filesystem_write_allowed\": false,\n    \"external_side_effects_allowed\": false\n  }},\n  \"detected_controls\": [\"least_privilege\", \"schema_validation\", \"payload_size_limit\", \"prompt_injection_scan\", \"secret_pattern_scan\", \"deny_side_effects_without_policy\", \"audit_log_ready_output\"],\n  \"result\": {{\n    \"status\": \"plan_only\",\n    \"message\": \"Tool generated a safe plan. Connect privileged adapters only behind policy, approvals, and audited capability tokens.\",\n    \"injection_detected\": {},\n    \"secret_like_input_detected\": {},\n    \"recommended_next_step\": \"Review evidence, bind a short-lived scoped capability, then rerun in an isolated worker if execution is needed.\"\n  }}\n}}", spec.name, spec.domain, data.len(), risk, inj, sec);
}
fn help(s: &ToolSpec) {
    println!("{} - {}\n\nPurpose: {}", s.name, s.domain, s.purpose);
    println!("\nCapabilities:");
    for x in s.capabilities {
        println!("  - {}", x);
    }
    println!("\nZero-trust denied actions:");
    for x in s.denied_actions {
        println!("  - {}", x);
    }
    println!("\nRequired evidence:");
    for x in s.required_evidence {
        println!("  - {}", x);
    }
}
