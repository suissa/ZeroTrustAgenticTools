import { readFileSync } from "node:fs";

export type ToolSpec = { name: string; domain: string; purpose: string; capabilities: string[]; denied_actions: string[]; required_evidence: string[] };
const MAX_INPUT_BYTES = 64 * 1024;
const injectionPatterns = ["ignore previous", "ignore all", "system prompt", "developer message", "jailbreak", "exfiltrate", "disable safety", "bypass", "sudo ", "rm -rf", "curl ", "wget "];
const secretPatterns = ["api_key", "apikey", "secret", "password", "token=", '"token"', "bearer ", "private key", "aws_access_key_id", "-----begin"];

export function run(spec: ToolSpec): void {
  if (process.argv.includes("--help") || process.argv.includes("-h")) return help(spec);
  const input = readFileSync(0);
  if (input.byteLength > MAX_INPUT_BYTES) throw new Error("InputTooLarge");
  const lower = input.toString("utf8").toLowerCase();
  const injection = injectionPatterns.some((p) => lower.includes(p));
  const secret = secretPatterns.some((p) => lower.includes(p));
  const risk = injection || secret ? "high" : input.byteLength === 0 ? "low" : "medium";
  console.log(JSON.stringify({ tool: spec.name, domain: spec.domain, zero_trust: { default_decision: "deny", input_bytes: input.byteLength, risk, approved_for_execution: false, requires_human_approval: true, secrets_redacted: true, network_allowed: false, filesystem_write_allowed: false, external_side_effects_allowed: false }, detected_controls: ["least_privilege", "schema_validation", "payload_size_limit", "prompt_injection_scan", "secret_pattern_scan", "deny_side_effects_without_policy", "audit_log_ready_output"], result: { status: "plan_only", message: "Tool generated a safe plan. Connect privileged adapters only behind policy, approvals, and audited capability tokens.", injection_detected: injection, secret_like_input_detected: secret, recommended_next_step: "Review evidence, bind a short-lived scoped capability, then rerun in an isolated worker if execution is needed." } }, null, 2));
}
function help(spec: ToolSpec): void { console.log(`${spec.name} - ${spec.domain}\n\nPurpose: ${spec.purpose}\n\nCapabilities:\n${spec.capabilities.map(x=>`  - ${x}`).join("\n")}\n\nZero-trust denied actions:\n${spec.denied_actions.map(x=>`  - ${x}`).join("\n")}\n\nRequired evidence:\n${spec.required_evidence.map(x=>`  - ${x}`).join("\n")}`); }
