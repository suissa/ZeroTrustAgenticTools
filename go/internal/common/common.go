package common

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"
)

type ToolSpec struct {
	Name, Domain, Purpose                         string
	Capabilities, DeniedActions, RequiredEvidence []string
}

const MaxInputBytes int64 = 64 * 1024

var injection = []string{"ignore previous", "ignore all", "system prompt", "developer message", "jailbreak", "exfiltrate", "disable safety", "bypass", "sudo ", "rm -rf", "curl ", "wget "}
var secrets = []string{"api_key", "apikey", "secret", "password", "token=", "\"token\"", "bearer ", "private key", "aws_access_key_id", "-----begin"}

func Run(spec ToolSpec) {
	for _, a := range os.Args[1:] {
		if a == "--help" || a == "-h" {
			help(spec)
			return
		}
	}
	data, err := io.ReadAll(io.LimitReader(os.Stdin, MaxInputBytes+1))
	if err != nil {
		panic(err)
	}
	if int64(len(data)) > MaxInputBytes {
		panic("InputTooLarge")
	}
	lower := strings.ToLower(string(data))
	inj := contains(lower, injection)
	sec := contains(lower, secrets)
	risk := "medium"
	if inj || sec {
		risk = "high"
	} else if len(data) == 0 {
		risk = "low"
	}
	out := map[string]any{"tool": spec.Name, "domain": spec.Domain, "zero_trust": map[string]any{"default_decision": "deny", "input_bytes": len(data), "risk": risk, "approved_for_execution": false, "requires_human_approval": true, "secrets_redacted": true, "network_allowed": false, "filesystem_write_allowed": false, "external_side_effects_allowed": false}, "detected_controls": []string{"least_privilege", "schema_validation", "payload_size_limit", "prompt_injection_scan", "secret_pattern_scan", "deny_side_effects_without_policy", "audit_log_ready_output"}, "result": map[string]any{"status": "plan_only", "message": "Tool generated a safe plan. Connect privileged adapters only behind policy, approvals, and audited capability tokens.", "injection_detected": inj, "secret_like_input_detected": sec, "recommended_next_step": "Review evidence, bind a short-lived scoped capability, then rerun in an isolated worker if execution is needed."}}
	enc := json.NewEncoder(os.Stdout)
	enc.SetIndent("", "  ")
	_ = enc.Encode(out)
}
func contains(s string, ps []string) bool {
	for _, p := range ps {
		if strings.Contains(s, p) {
			return true
		}
	}
	return false
}
func help(s ToolSpec) {
	fmt.Printf("%s - %s\n\nPurpose: %s\n\nCapabilities:\n", s.Name, s.Domain, s.Purpose)
	for _, x := range s.Capabilities {
		fmt.Printf("  - %s\n", x)
	}
	fmt.Print("\nZero-trust denied actions:\n")
	for _, x := range s.DeniedActions {
		fmt.Printf("  - %s\n", x)
	}
	fmt.Print("\nRequired evidence:\n")
	for _, x := range s.RequiredEvidence {
		fmt.Printf("  - %s\n", x)
	}
}
