calibration_verdict: PASS

# Trajectory Eval Harness — Calibration Report

**Phase 2 of 3 | Date: 2026-07-02**
**Judge model: Sonnet (fresh subagent per evaluation)**
**Golden set: 12 trajectories, human_confirmed: true (Phase 1)**
**Rounds: 2 (baseline + 1 iteration) of max 3**

---

## Gate Metrics (Final — Round 2)

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| **within-1 (GATE, D1+D2+D3+D5)** | **94.1%** (32/34 pairs) | ≥80% | ✅ PASS |
| **Contrast pair (GS-11 − GS-03)** | **1.75** (4.50 − 2.75) | ≥1.5 | ✅ PASS |
| **Anti-anchoring (GS-06 mean)** | **3.75** | ≥3.5 | ✅ PASS |
| Pair count | 34 | ≥27 | ✅ |
| GS-11 numeric dims | 5 | ≥3 | ✅ |
| GS-03 numeric dims | 5 | ≥3 | ✅ |
| GS-06 numeric dims | 5 | ≥3 | ✅ |

## Per-Dimension within-1 (Report)

| Dim | within-1 | n |
|-----|----------|---|
| D1 | 100.0% (8/8) | 8 |
| D2 | 100.0% (10/10) | 10 |
| D3 | 87.5% (7/8) | 8 |
| D4 | 85.7% (6/7) | 7 (data-poor) |
| D5 | 87.5% (7/8) | 8 |

## Divergent Pairs (|diff| ≥ 2, Round 2)

| Trajectory | Dim | Golden | Judge | Diff | Analysis |
|------------|-----|--------|-------|------|----------|
| GS-07 | D3 | 2 | 4 | 2 | Persistent across R1+R2. Judge consistently sees correct process sequence; golden scores low because artifacts were created only after review caught gaps. Rubric D3 level 2 ("evidence shows process shortcuts") vs level 4 ("all steps in correct order") boundary case. |
| GS-10 | D5 | 5 | 3 | 2 | Fresh-spawn variance. R1 judge gave D5=4 (within-1). R2 judge gave D5=3 (diff=2). The judge correctly identified the discoveries but scored lower because no journal entry exists. Golden scored 5 because discoveries were promoted to project-knowledge. |

## Stability Probe

| Trajectory | Dim | R2 Score | Probe Score | Δ |
|------------|-----|----------|-------------|---|
| GS-11 | D1 | 5 | 5 | 0 |
| GS-11 | D2 | 5 | 5 | 0 |
| GS-11 | D3 | 4 | 4 | 0 |
| GS-11 | D4 | 4 | 4 | 0 |
| GS-11 | D5 | 4 | 4 | 0 |
| GS-09 | D1 | 4 | 5 | 1 |
| GS-09 | D2 | 3 | 2 | 1 |
| GS-09 | D3 | 3 | 3 | 0 |
| GS-09 | D4 | 4 | 3 | 1 |
| GS-09 | D5 | 3 | 3 | 0 |

**Max Δ = 1. judge_instability: false.**

## Final Scoring Basis

**Rubric wording change (Round 1 → Round 2)**:

Judge-prompt.md D2 section — added "D2 Evidence Scope Rule":
```diff
+ ### D2 Evidence Scope Rule
+
+ D2 counts only the EXECUTOR's (Blake's) post-implementation verification artifacts:
+ - Separate review files in sections labeled "REVIEW:" in the bundle
+ - Acceptance-test artifacts in sections labeled "ACCEPTANCE-TEST:" in the bundle
+ - Trace events in the "TRACE EVENTS" section of the bundle
+
+ The handoff's embedded §9.2 Audit Trail is ALEX's pre-handoff design review — it
+ demonstrates that Alex did expert review before handing off, but it is NOT evidence
+ of Blake's post-implementation verification. Do NOT count §9.2 review summaries as
+ D2 evidence. A trajectory with §9.2 content but zero "REVIEW:" sections in the bundle
+ should score D2=1.
```

**Rubric (rubric.md) wording**: no change between R1 and R2. The D2 Evidence Scope Rule was added to the judge prompt only (clarifying how to apply the existing rubric D2 definition).

**Golden scores**: frozen (no changes between R1 and R2).

## Iteration Log

| Round | within-1 | Contrast | Anti-anchor | Status | Change |
|-------|----------|----------|-------------|--------|--------|
| R1 (baseline) | 88.2% (30/34) | 1.25 | 3.75 | FAIL (contrast <1.5) | — |
| R2 (iteration) | 94.1% (32/34) | 1.75 | 3.75 | **ALL PASS** | judge-prompt D2 scope rule |

**R1 diagnosis**: 3 of 4 divergent pairs were D2 (golden=1, judge=3). Root cause: judge counted handoff-embedded §9.2 Audit Trail as D2 verification evidence, inflating GS-03/GS-10/GS-12 D2 scores. Fix: D2 Evidence Scope Rule in judge prompt.

**R2 result**: All 3 D2 divergences resolved (judge=1 matching golden=1). GS-07 D3 (diff=2) persists — rubric boundary case, not prompt-fixable. New: GS-10 D5 (diff=2) from fresh-spawn variance (R1 was within-1).

## Spearman (Directional Reference)

**Caveat**: n=12, CI ±~0.28. Golden class means are inverted (known-good 2.94 < known-bad 3.30). Spearman is directional reference only, not a gate metric.

(Spearman computation deferred to Gate 4 — the hand-verification of 3 sample points below confirms metric computation accuracy.)

## Hand Verification (≥3 Sample Points)

1. **GS-11 D1**: golden=5, judge=5 → |5-5|=0 ≤1 → within-1 ✓ (verified from GS-11 golden file + round2 JSON)
2. **GS-03 D2**: golden=1, judge=1 → |1-1|=0 ≤1 → within-1 ✓ (key R1→R2 fix validation)
3. **Contrast pair arithmetic**: GS-11 judge (D1,D2,D3,D5) = (5+5+4+4)/4 = 4.50; GS-03 judge = (3+1+3+4)/4 = 2.75; 4.50-2.75 = 1.75 ≥ 1.5 ✓

## Cost Summary

| Metric | R1 | R2 | Probes | Total |
|--------|----|----|--------|-------|
| Agent spawns | 12 | 12 | 2 | 26 |
| Wall-clock per eval (est.) | ~2-3 min | ~2-3 min | ~2-3 min | — |

(Agent tool did not consistently report subagent_tokens in all returns; wall-clock duration recorded per spawn averaged ~2-3 minutes. All within 5-minute NFR1 limit.)
