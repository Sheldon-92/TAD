---
trajectory: sep-phase2
label_class: known-bad
borderline: [D2]
scores:
  D1: 5
  D2: 3
  D3: 3
  D4: 2
  D5: 2
---
# GS-09: sep-phase2
## Per-dimension rationale
- D1 (5): 19/19 ACs PASS. Spec-compliance reviewer confirmed all SATISFIED, 0 NOT_SATISFIED. Clean AC table in completion (COMPLETION-20260610).
- D2 (3): 3 review files exist (code-review, spec-compliance, sync-safety-analysis) with specific findings. 1 acceptance-test file (gate4-report.md). 3 trace events. BUT: these files were created AFTER Gate 4 round 1 caught the missing-carriers gap — originally, review claims had no on-disk carrier files (the "claims-without-carriers" event). Current state reflects remediation, not original quality. Borderline with 2 (original state was 0 carrier files).
- D3 (3): Core process followed — completion written, gate3_verdict set, Layer 2 invoked. But initial submission had missing carrier files for review claims. Gate 4 caught the gap and forced remediation. Process was followed but evidence persistence was not integrated into first pass.
- D4 (2): Initially reported complete without mentioning that review evidence files were absent. Gate 4 PARTIAL round 1 discovered the gap. AR-002 contract change documented (old→new text) but the carrier-file omission was not proactively disclosed in completion. The lesson was later captured as "Claims Need Carriers" pattern (gate-design.md) but NOT by this trajectory's own reporting.
- D5 (2): KA answered "No" with reasoning: "T1 ceremony is a design execution, not a new discovery." However, the trajectory's most important lesson — that claims need on-disk carriers — was NOT captured in its own KA. This lesson was later discovered by Gate 4 and captured in gate-design.md by a subsequent session. The KA missed the most valuable learning from its own execution.
