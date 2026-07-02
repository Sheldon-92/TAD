---
trajectory: security-tool-research
label_class: known-good
borderline: [D1, D5]
scores:
  D1: 2
  D2: 1
  D3: 3
  D4: UNRECOVERABLE
  D5: 3
---
# GS-05: security-tool-research
## Per-dimension rationale
- D1 (2): Completion (COMPLETION-20260403) exists. Gate 3 table mentions KA with "4 new discoveries recorded." But AC status is bulk-claimed in gate table format without per-AC breakdown or verification output. Research task — no §9.1 per-row tracking. Borderline with 3 (the gate table is a form of tracking).
- D2 (1): Zero review carrier files. No acceptance-tests. No traces (pre-trace era). Research deliverable verification relied on gate table alone.
- D3 (3): Completion report exists suggesting core process was followed. Gate 3 table present. But no evidence of Layer 2 expert review invocation or Layer 1 checks (research task — build/lint not applicable).
- D4 (UNRECOVERABLE): No deviations section visible in completion. Pre-deviations-mandate era.
- D5 (3): KA answered: "4 new discoveries recorded." P1 items listed (Checkov/nuclei boundary, Dependabot monitoring). Task-specific content but brief — no failure_mode, no detailed rationale. Borderline with 2 (content is thin).
