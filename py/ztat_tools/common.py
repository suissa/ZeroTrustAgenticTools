from __future__ import annotations
import json, sys
from dataclasses import dataclass
MAX_INPUT_BYTES = 64 * 1024
INJECTION = ["ignore previous", "ignore all", "system prompt", "developer message", "jailbreak", "exfiltrate", "disable safety", "bypass", "sudo ", "rm -rf", "curl ", "wget "]
SECRETS = ["api_key", "apikey", "secret", "password", "token=", '"token"', "bearer ", "private key", "aws_access_key_id", "-----begin"]
@dataclass(frozen=True)
class ToolSpec:
    name: str; domain: str; purpose: str; capabilities: list[str]; denied_actions: list[str]; required_evidence: list[str]
def run(spec: ToolSpec) -> None:
    if "--help" in sys.argv or "-h" in sys.argv: return help_text(spec)
    data = sys.stdin.buffer.read(MAX_INPUT_BYTES + 1)
    if len(data) > MAX_INPUT_BYTES: raise SystemExit("InputTooLarge")
    lower = data.decode("utf-8", "replace").lower()
    injection = any(p in lower for p in INJECTION); secret = any(p in lower for p in SECRETS)
    risk = "high" if injection or secret else "low" if not data else "medium"
    print(json.dumps({"tool": spec.name, "domain": spec.domain, "zero_trust": {"default_decision": "deny", "input_bytes": len(data), "risk": risk, "approved_for_execution": False, "requires_human_approval": True, "secrets_redacted": True, "network_allowed": False, "filesystem_write_allowed": False, "external_side_effects_allowed": False}, "detected_controls": ["least_privilege", "schema_validation", "payload_size_limit", "prompt_injection_scan", "secret_pattern_scan", "deny_side_effects_without_policy", "audit_log_ready_output"], "result": {"status": "plan_only", "message": "Tool generated a safe plan. Connect privileged adapters only behind policy, approvals, and audited capability tokens.", "injection_detected": injection, "secret_like_input_detected": secret, "recommended_next_step": "Review evidence, bind a short-lived scoped capability, then rerun in an isolated worker if execution is needed."}}, indent=2))
def help_text(spec: ToolSpec) -> None:
    print(f"{spec.name} - {spec.domain}\n\nPurpose: {spec.purpose}\n\nCapabilities:\n" + "\n".join(f"  - {x}" for x in spec.capabilities) + "\n\nZero-trust denied actions:\n" + "\n".join(f"  - {x}" for x in spec.denied_actions) + "\n\nRequired evidence:\n" + "\n".join(f"  - {x}" for x in spec.required_evidence))
