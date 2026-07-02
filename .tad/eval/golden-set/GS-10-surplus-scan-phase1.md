---
trajectory: surplus-scan-phase1
label_class: known-bad
borderline: [D1]
scores:
  D1: 3
  D2: 1
  D3: 3
  D4: 4
  D5: 5
---
# GS-10: surplus-scan-phase1
## Per-dimension rationale
- D1 (3): 12/17 ACs PASS with 5 honestly deferred to live Workflow runtime (AC5, AC6, AC9, AC16, AC17). Static ACs tracked per-item with verification output. But 5/17 unverifiable without live run. Borderline with 4 (deferral is honest and rational — runtime-only ACs cannot be verified statically).
- D2 (1): Zero blake review carrier files in evidence/reviews/. No acceptance-test dir. 6 trace events exist (4 decision_point, 1 task_completed, 1 handoff_created) but no gate_result trace. Expert review occurred at handoff level (code-reviewer 4 P0, backend-architect 4 P0 — all resolved) but left no Blake-side evidence. This is the validation theater case: 4 expert reviews passed but the first live Workflow run crashed on 2 bugs (top-level-array StructuredOutput schema + stale-copy invocation).
- D3 (3): Completion written, process narrative present. Core process followed — handoff read, implementation done, 3 deviations documented. But 5 ACs could not be verified without live run, and the live run (when finally attempted) crashed. Process followed but incomplete verification.
- D4 (4): 3 deviations proactively documented with specific rationale: (1) writeFile not a runtime primitive — workflow returns data, SKILL persists; (2) AC1 bare node --check impossible for workflow files; (3) AC7 quote style mismatch. Honest about 5/17 deferred ACs. Good transparency about limitations.
- D5 (5): 2 excellent discoveries promoted to project-knowledge: (1) "node --check false-FAIL for workflow files" pattern → ac-verification.md; (2) "sandbox seam: render in workflow, persist in SKILL" → hook-contracts/workflow conventions. Both variabilizable, both include concrete technical rationale.

**Note (label_class=known-bad rationale)**: Validation theater — 4 expert reviews all PASSED (handoff-level code-reviewer + backend-architect), but the first live Workflow run crashed on 2 bugs neither static review caught (StructuredOutput top-level-array schema rejection + stale-copy invocation). High D4/D5 scores reflect honest reporting and good knowledge capture, but D2=1 reflects the core failure: no Blake-side review evidence, and the reviews that existed couldn't catch runtime-only issues.
