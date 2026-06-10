verdict: FAIL

PARTIALLY_SATISFIED
- Constraint: `All Codex exec must be sandboxed to evidence directories`
  Evidence in `T1-full-cycle-v0.137.0.md` says the runs used `workspace-write`, while only the created artifacts were confined to `.tad/evidence/.../sandbox/`. That shows path discipline, but not directory-scoped sandboxing. The constraint is stricter than the evidence provided.

- T1 requested-version alignment
  `requested_codex_version: 0.137.0` but `actual_codex_version: 0.138.0`. The version was correctly recorded, so the recording constraint is satisfied, but the named regression target was not executed on the pinned version.

NOT_SATISFIED
- None beyond the sandboxing-compliance gap above. The remaining acceptance surfaces appear satisfied:
  AC1, AC2, AC3, AC5, AC6, AC7, and AC8 are covered by the provided artifacts.
  T3 and T4 reports exist with `verdict: PASS`.
  `ACCEPTANCE-SUMMARY.md` contains the required matrix, gap classifications, n=3 waiver, evidence links, and release recommendation.