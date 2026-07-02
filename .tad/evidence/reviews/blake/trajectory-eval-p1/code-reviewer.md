# Code Review: trajectory-eval-p1

**Reviewer**: code-reviewer (sub-agent)
**Date**: 2026-07-02
**Verdict**: CONDITIONAL PASS → PASS (2 P1 fixed)

## P0 Issues (0)
None.

## P1 Issues (2) — Both Resolved

**P1-1**: D4 effective n=7, below Phase 2 data-poor threshold (<8)
- **Issue**: Audit report understated UNRECOVERABLE impact; D4 has only 7 scorable trajectories
- **Fix**: Added per-dimension effective n table to audit report; D4 flagged as data-poor
- **Status**: Resolved (trajectory-data-audit.md updated)

**P1-2**: D1 anchor wording at levels 3-4 bleeds into D2 territory (r=0.839 correlation)
- **Issue**: "verification output recorded" in D1 anchors could be confused with D2's evidence-file-on-disk concept
- **Fix**: Added D1/D2 boundary clarification note to rubric header with concrete GS examples
- **Status**: Resolved (rubric.md updated)

## P2 Issues (5) — Advisory

1. D1-D2 Spearman r=0.839 is sample-composition artifact, not MECE violation (bimodal sample, ceiling relationship)
2. D2 floor clustering (6/12 at level 1) — Phase 2 should report per-dimension agreement
3. Blind pack omits GS-06 (silent-bad, most calibration-interesting) — advisory, mandate satisfied
4. INDEX lacks label_class semantic note (outcome vs process quality) — advisory
5. D5 level-5 "actionable knowledge" is slightly conclusion-adjacent — monitor in Phase 2

## Positive Observations

- GS-06 silent-bad is excellent calibration entry (high scores + known defect)
- UNRECOVERABLE used with discipline — no fabricated scores
- All 25 rubric anchors rigor-oriented, not conclusion-directed
- Known-bad selection satisfies all 4 handoff mandates
- Statistical power honesty statement present and well-calibrated
- Per-dimension rationales cite specific artifacts, not memory
