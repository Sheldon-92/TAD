# Gate 4 Acceptance Report — gate-roi-measurement

**Date**: 2026-07-12
**Handoff**: HANDOFF-surplus-gate-roi-measurement.md v3.3.0 (Gate 2 PASS same day)
**Deliverable**: `.tad/evidence/research/gate-roi-measurement-2026-07.md` (417 lines, git-staged)
**Mode**: YOLO Conductor (user-directed "全部一起跑完") — implementer agent + 2 independent blind FR8 panels + Alex full raw recompute

## Prerequisite: Gate 3

- Implementer ran all §9.1 ACs green, wrote COMPLETION with raw outputs, gate3_verdict: pass.
- FR8 spot-check round 1 (implementer-spawned blind agent, rows GR-03/09/20/24/27): 4/5 agreement
  (sole disagreement GR-27 = stage-eligibility question, not counterfactual class; sensitivity:
  verdict unchanged either way).

## Alex independent recompute (NOT paper acceptance)

| Check | Alex result | Matches claim |
|-------|------------|---------------|
| AC1 size | 417 lines | ✅ |
| AC2 rows | 27 | ✅ |
| AC3 citations | 0 uncited; 0 MISSING (all 27 evidence paths test -f OK) | ✅ |
| AC4 sections | 6 | ✅ |
| AC5 verdict line | 1 | ✅ |
| AC6 rec/date/cost | 1 / 1 / 1 | ✅ |
| AC7 baseline diff | only foreign file = DR-20260712-native-capability-overlap-verdicts.md (parallel *discuss session artifact, verified NOT written by this task; not in protected paths) | ✅ |
| AC8 unclassified | 0 | ✅ |
| AC9 limitations | 1 / 4 | ✅ |
| AC10 labels | 3 distinct; P01 recomputed from Defect Detail = 26 P0 + 65 P1 = 91 == Verdict | ✅ |
| AC11 rule verbatim | 1 | ✅ |
| AC12 none-rows | 6 (counterfactual column-scoped) | ✅ |
| Frame integrity | report evidence files == frozen /tmp/gate-roi-sample.txt (diff empty) — sample membership untouched | ✅ |
| NC recount | 17/27 = 63.0% | ✅ |
| FR7 branch | 63.0% >= 25% AND 91 >= 10 → net-positive → GO (mechanical) | ✅ |

## FR8 round 2 (Alex-selected rows, zero overlap with round 1)

Blind agent (rubric + evidence files only; report unseen), rows GR-01/06/13/18/25:
5/5 enum agreement (silent-degradation ×4, none ×1). Combined FR8: 9/10 across two
independent panels — classification layer robust, >=4/5 threshold cleared twice.

## Result

- **Verdict**: net-positive (defect-catch effectiveness; cost side unmeasured by design)
- **Recommendation**: GO — revisit the 2026-04-15 mechanical-enforcement decision; next step
  is cost-side measurement.
- Key aggregates: S=27, NC=17 (63.0%), P01=91 (26 P0 / 65 P1; 48 P2; 139 total), zero-catch 6/27 (22.2%).
- Honesty markers held: 6 none-rows survived; 49/139 defects classified DOWN as low-confidence
  cosmetic (bias against gates); strict pre-registered bar cleared with margin.

## Knowledge Assessment (step7.C — Alex own observations)

1. Phantom-completion incident preceding this run: a claimed "yolo完成" left ZERO artifacts
   (no report, no COMPLETION, no trace events, no worktree). Conductor's first acceptance act
   must be deliverable-existence, which caught it. Reinforces "executed ≠ delivered" (existing
   lesson; second live instance).
2. The strict pre-registered rule cleared at 63% vs the 25% bar — 2.5x margin means the verdict
   is robust to substantial classification error (even reclassifying every low-confidence NC row
   away would need to remove 11 of 17 NC rows to flip; only 3 rows' row-level class rests on
   low-confidence evidence, none in the NC set).
3. Dual-blind FR8 (producer-hired panel + acceptor-hired panel, disjoint rows) is cheap (~75K
   tokens) and materially stronger than single spot-check — candidate pattern for rubric-based
   deliverable gates.

**Gate 4 status**: technical acceptance COMPLETE; human business confirmation (verdict
plausibility — human domain) recorded as: PENDING at report write time → see session log for
human decision.
