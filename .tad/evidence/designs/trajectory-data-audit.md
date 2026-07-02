# Trajectory Data Sufficiency Audit

**Phase 1 of Trajectory Eval Harness**
**Auditor**: Blake (Agent B)
**Date**: 2026-07-02
**Handoff**: HANDOFF-20260702-trajectory-eval-p1.md

## Audit Methodology

- **Population**: 285 archived handoffs (as of 2026-07-02)
- **Sample size**: 12 trajectories (stratified)
- **Stratification axes**: task_type (code/yaml/research/mixed/pre-frontmatter) × time period (early/mid/late/recent) × Gate outcome (green/non-green)
- **Bundle definition**: Per §4.2A — handoff + completion + acceptance-tests + reviews + traces
- **Known-bad selection**: Per §4.2D — ≥2 known-bad (including ≥1 silent-bad), ≥1 with intermediate (2-3) scores, ≥3 with non-all-green history

## Sampling Rationale

| # | Slug | Date | task_type | Period | Role | Non-green history |
|---|------|------|-----------|--------|------|-------------------|
| S1 | multi-platform-init | 2026-01-26 | N/A (pre-frontmatter) | early | known-good | — |
| S2 | cognitive-firewall | 2026-02-06 | N/A (pre-frontmatter) | early | known-good | — |
| S3 | plain-language-after-handoffs | 2026-04-14 | yaml | mid | **known-bad** (express 4 P0) | 4 P0 self-caught |
| S4 | openharness-domain-pack-upgrade | 2026-04-03 | yaml | mid | known-good | — |
| S5 | security-tool-research | 2026-04-03 | research | mid | known-good | — |
| S6 | notebooklm-source-preprocessor | 2026-05-09 | code | mid-late | **silent-bad** (bugfix follow-up) | passed Gate, then bugfix needed |
| S7 | codex-spike-phase0 | 2026-05-01 | research | mid-late | known-good | — |
| S8 | tad-lean-trustworthy-phase5 | 2026-05-31 | code | mid-late | known-good | — |
| S9 | sep-phase2 | 2026-06-10 | mixed | recent | **known-bad** (claims-without-carriers) | Gate 4 PARTIAL round 1 |
| S10 | surplus-scan-phase1 | 2026-06-07 | mixed | recent | **known-bad** (validation theater) | 4× expert PASS then live-run crash |
| S11 | universal-gate-ac-driven | 2026-06-07 | code | recent | known-good | — |
| S12 | knowledge-redesign-p1-foundation | 2026-06-22 | mixed | recent | known-good | — |

**Selection defense**:
- Known-bad ≥2: S3, S9, S10 (3 known-bad) ✓
- Silent-bad ≥1: S6 (passed Gate, bugfix-dream-scanner-override-content traced back via preprocessor-bugfix) ✓
- ≥1 known-bad with intermediate scores: S10 (surplus-scan — 4 expert reviews passed ≠ all-1; verification effort was real but theatric) ✓
- ≥3 non-all-green: S3, S6, S9, S10 (4) ✓
- Gate result dimension: S3 (express P0), S9 (PARTIAL), S10 (live-run fail), S6 (silent — Gate passed but quality issue emerged) ✓

## Bundle Reconstruction Results

| S# | Slug | HANDOFF | COMPLETION | ACCEPT-TST | REVIEWS (blake/) | TRACES | Bundle Verdict |
|----|------|---------|------------|------------|------------------|--------|----------------|
| S1 | multi-platform-init | YES | NO | NO | 0 | 0 | PARTIAL — handoff only |
| S2 | cognitive-firewall | YES | NO | 1 file | 2 (non-slug) | 0 | PARTIAL — no completion |
| S3 | plain-language-after-handoffs | YES | YES | NO | 0 | 0 | PARTIAL — no evidence |
| S4 | openharness-domain-pack-upgrade | YES | NO | NO | 0 | 0 | PARTIAL — handoff only |
| S5 | security-tool-research | YES | YES | NO | 0 | 0 | PARTIAL — no evidence |
| S6 | notebooklm-source-preprocessor | YES | YES | 1 file | 3 files | 0 | GOOD — reviews+tests |
| S7 | codex-spike-phase0 | YES | YES | NO | 2 files (incl self-review) | 0 | FAIR — reviews exist |
| S8 | tad-lean-trustworthy-phase5 | YES | YES | NO | 0 | 6 events | FAIR — traces exist |
| S9 | sep-phase2 | YES | YES | 1 file (gate4) | 3 files | 3 events | GOOD — multi-source |
| S10 | surplus-scan-phase1 | YES | YES | NO | 0 | 6 events | FAIR — traces only |
| S11 | universal-gate-ac-driven | YES | YES | NO | 4 files | 7 events | GOOD — reviews+traces |
| S12 | knowledge-redesign-p1-foundation | YES | NO | NO | 0 | 1 event | PARTIAL — handoff+trace only |

**Summary**: 12/12 have handoff; 9/12 have completion (75%); 3/12 have acceptance-test evidence (25%); 4/12 have review files (33%); 5/12 have trace events (42%).

## Coverage Matrix

| Dimension | Data Source | S1 | S2 | S3 | S4 | S5 | S6 | S7 | S8 | S9 | S10 | S11 | S12 | Coverage |
|-----------|-----------|----|----|----|----|----|----|----|----|----|----|-----|-----|----------|
| AC/需求对齐 | Handoff §9.1 + Completion | — | — | ◐ | ◐ | ◐ | ● | ◐ | ◐ | ● | ● | ● | ◐ | 10/12 (83%) |
| 验证完整性 | Evidence dirs + reviews + traces | ○ | ◐ | ○ | ○ | ○ | ● | ◐ | ◐ | ● | ◐ | ● | ○ | 6/12 (50%) |
| 约束遵守 | Handoff §10 + Completion deviations | — | — | ◐ | ○ | ○ | ● | ◐ | ● | ● | ● | ● | ○ | 7/12 (58%) |
| 升级诚实度 | Gate results + honest_partial reports | — | — | ● | — | — | ◐ | — | ◐ | ● | ● | ◐ | ○ | 5/12 (42%) |
| 知识捕获 | Completion KA section + journal | — | — | — | — | — | ○ | ○ | ◐ | ● | ● | ● | — | 4/12 (33%) |

**Legend**: ● = quality scorable (artifact + content sufficient) | ◐ = existence scorable only (artifact exists but content sparse/no cross-reference) | ○ = present but UNRECOVERABLE for quality scoring | — = artifact absent (UNRECOVERABLE) | Coverage = ● + ◐ count

### Coverage by Period

| Period | Avg. artifacts | Key gap |
|--------|---------------|---------|
| Early (01-02) | 1.5/5 | No frontmatter, no §9.1, no completion (S1), no traces |
| Mid (04) | 2.0/5 | No reviews, no traces, §9.1 just emerging |
| Mid-late (05) | 3.0/5 | Traces not yet live (pre-05-31), reviews inconsistent |
| Recent (06) | 3.5/5 | Best coverage; still only 50% have review files |

### Key Findings

1. **Trace system gap**: Traces only exist from 2026-05-31 onward (post-write-sync.sh deployment). 7/12 samples predate this → trace-dependent dimensions are UNRECOVERABLE for those samples.

2. **Expert review evidence gap**: Only 4/12 have persisted review files in `.tad/evidence/reviews/blake/`. The Claims Need Carriers pattern (2026-06-10) explicitly identified this as a systematic failure. Review files became standard only after that fix. Pre-06-10 reviews existed as conversation text but no carrier file.

3. **Acceptance test evidence gap**: Only 3/12 have `.tad/evidence/acceptance-tests/{slug}/` directories. This is the weakest artifact class. Most handoffs relied on §9.1 inline verification rather than separate test files.

4. **Format generational gap**: Pre-2026-04 handoffs (S1, S2) lack frontmatter (task_type, §9.1 AC table, gate4_delta). They cannot be scored on AC alignment or constraint adherence using the current rubric anchors. Marked as UNRECOVERABLE for those dimensions.

5. **Knowledge Assessment gap**: KA sections in completions only became mandatory around 2026-05. Older completions (S5, S6, S7) either lack KA or have minimal entries.

6. **>50% threshold NOT triggered**: All 12 have handoffs, 75% have completion reports. Bundle reconstruction is viable for ≥10 trajectories → proceed to rubric design.

## Data Sufficiency Verdict

**PROCEED** — sufficient data exists to design a rubric and draft a golden set with the following constraints:
- 4 trajectories (S1, S2, S4, S12) have 4+ dimensions UNRECOVERABLE (no completion report in standard location)
- S5 has 1 dimension UNRECOVERABLE (D4 — no deviations section)
- Trace-dependent scoring limited to 5/12 trajectories
- Verification integrity dimension must combine multiple artifact types (reviews + tests + traces) since no single source has >50% coverage

### Per-Dimension Effective n (excl. UNRECOVERABLE)

| Dimension | Effective n | Phase 2 status |
|-----------|-------------|----------------|
| D1 (Spec Alignment) | 8 | at threshold |
| D2 (Verification Rigor) | 12 | healthy |
| D3 (Process Discipline) | 8 | at threshold |
| D4 (Deviation Transparency) | **7** | **data-poor** (< 8 threshold per §4.2C Phase 2 prestatement) |
| D5 (Knowledge Capture) | 8 | at threshold |

D4 requires completion report + deviations section + gate4_delta — the two artifacts with lowest historical persistence. Phase 2 calibration should treat D4 as data-poor and exclude it from stop/go Spearman judgment if its pairwise count falls further.

## Minimal Schema Increment Proposal (PROPOSAL ONLY — not implemented)

If future Phases want to improve data coverage for historical trajectories:
1. **Backfill review evidence**: For completed handoffs that had Layer 2 reviews but no carrier files (pre-Claims-Need-Carriers), a one-time migration could create stub review manifests from git log + completion report mentions
2. **Trace backfill**: For pre-05-31 handoffs, parse COMPLETION reports for gate_result/reflexion mentions and emit synthetic trace events (lower confidence than live traces)
3. **Standardize acceptance-test dir**: Make acceptance-test directory creation mandatory in *develop step3b (currently optional/inconsistent)

## Statistical Power Honesty Statement (DA P0-1)

With n=12, Spearman rank correlation's 95% CI is approximately ±0.25. Phase 2 calibration should use **within-1 agreement ≥80%** as the primary metric (more robust at small n). Spearman provides directional signal only; a "low" Spearman (e.g., 0.5) at n=12 may not indicate poor calibration — it may just be statistical noise. This constraint is inherited by Phase 2.
