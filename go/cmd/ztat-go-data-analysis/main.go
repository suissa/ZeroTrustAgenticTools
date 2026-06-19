package main

import "github.com/zerotrustagentictools/go-tools/internal/common"

func main() {
	common.Run(common.ToolSpec{Name: "ztat-go-data-analysis", Domain: "data analysis", Purpose: "dataset profiling, metric definitions, anomaly triage, report outlines", Capabilities: []string{"dataset profiling, metric definitions, anomaly triage, report outlines", "validates all input as untrusted", "returns plan-only JSON by default", "requires scoped capability tokens for side effects"}, DeniedActions: []string{"no autonomous money movement, purchasing, deletion, messaging, or network access", "no secret echoing or credential persistence", "no execution of user-provided commands"}, RequiredEvidence: []string{"authenticated actor and tenant", "explicit task policy", "source provenance", "approval for regulated or irreversible actions", "audit correlation id"}})
}
