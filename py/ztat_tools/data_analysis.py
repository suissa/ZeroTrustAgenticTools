from .common import ToolSpec, run

def main() -> None:
    run(ToolSpec('ztat-py-data-analysis', 'data analysis', 'dataset profiling, metric definitions, anomaly triage, report outlines', ['dataset profiling, metric definitions, anomaly triage, report outlines', 'validates all input as untrusted', 'returns plan-only JSON by default', 'requires scoped capability tokens for side effects'], ['no autonomous money movement, purchasing, deletion, messaging, or network access', 'no secret echoing or credential persistence', 'no execution of user-provided commands'], ['authenticated actor and tenant', 'explicit task policy', 'source provenance', 'approval for regulated or irreversible actions', 'audit correlation id']))

if __name__ == "__main__":
    main()
