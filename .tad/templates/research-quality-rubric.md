# Research Quality Rubric (Phase 4c — 5-dim, advisory)

> Consumed by `research_plan_protocol` PHASE 4c **Step 4b** (Quality Rubric scoring).
> The same Codex+Gemini adversarial-challenge invocation that emits the
> INSUFFICIENT/ADEQUATE/STRONG verdict ALSO emits the 5-dim scores (via the
> `## Quality Rubric` block in the `findings` variant of
> `.tad/templates/research-challenge-prompt.md`). This file is the **rater calibration
> reference**: per-dim anchors, the orthogonality logic (§3), the embedded tier
> table (§2), the hybrid aggregation rule (§4), and ≥20 calibration cases (§5).
>
> ⚠️ This rubric is **ADVISORY**. A low overall produces a WARN; it NEVER halts research
> (single-user CLI principle). It does not change the PASS/FAIL challenge gate.

---

## 1. The 4 Scored Dimensions + 1 Advisory

Each scored dimension takes exactly one of **0.0 / 0.5 / 1.0** (three anchors — no in-between).
Two raters scoring the same findings should land on the same anchor; that is the design goal.

### D1 — `citation_accuracy` (scored) — citation MECHANICS only
Verifiable WITHOUT domain knowledge: does the citation exist, is the source real/reachable,
and does the cited text actually say what the claim attributes to it?

| Score | Anchor |
|-------|--------|
| 0.0 | Claims have no citations at all, OR cited sources are fabricated / unreachable / do not exist. |
| 0.5 | Citations exist and sources are real, but ≥1 citation misrepresents what its source says (quote ≠ source), OR a meaningful share of load-bearing claims are uncited. |
| 1.0 | Every load-bearing claim carries a real, reachable citation whose text genuinely supports the claim. |

### D2 — `factual_accuracy` (scored) — claim TRUTH only
Requires domain judgment: even where a claim is correctly cited, is the claim/interpretation
itself correct? A correctly-cited claim can still be a wrong interpretation of a real source.

| Score | Anchor |
|-------|--------|
| 0.0 | ≥1 load-bearing conclusion is factually wrong or is a fabricated number/threshold (even if "cited"). |
| 0.5 | Core conclusions are correct, but ≥1 secondary claim overstates / over-generalizes / interpolates a method-level range into a specific value. |
| 1.0 | All conclusions are factually defensible; numbers trace to their actual measured source (no interpolation). |

### D3 — `completeness` (scored) — coverage RATIO
`completeness = (# targeted KRs addressed) / (# targeted KRs)`, where "addressed" = ≥1 Tier-1 or
Tier-2 source contributes evidence to that KR.

| Score | Anchor |
|-------|--------|
| 0.0 | < ~25% of targeted KRs addressed (most objectives unanswered). |
| 0.5 | ~half (≈40-70%) of targeted KRs addressed. |
| 1.0 | (Nearly) all targeted KRs addressed by ≥1 Tier-1/Tier-2 source. |

### D4 — `source_quality` (scored) — tier mix
Judged against the embedded tier table below. Higher primary-source share → higher score.

| Score | Anchor |
|-------|--------|
| 0.0 | Predominantly Tier-3 (blogs / general web), no primary/official sources on load-bearing claims. |
| 0.5 | Mixed; load-bearing claims lean on Tier-2 with few Tier-1 primaries. |
| 1.0 | Load-bearing claims are backed by Tier-1 primaries (official docs / peer-reviewed / first-party data), Tier-2/3 only supplementary. |

### D5 — `efficiency` (ADVISORY — UNSCORED)
A one-line qualitative note on signal density (e.g., "high signal — few padding paragraphs" or
"diluted — many generic restatements"). **NOT** part of the numeric aggregate. Demoted to advisory
because there is no reliable, logged tool-call denominator to make it inter-rater scorable.

---

## 2. Embedded Source Tier Table (self-contained — do NOT defer to curate tiers)

| Tier | Definition | Examples |
|------|-----------|----------|
| **Tier 1** | Primary / official / peer-reviewed / first-party measured data | Official tool docs & specs, peer-reviewed papers, primary databases (USDA FoodData Central, arXiv preprints by the authors), first-party benchmark results, the canonical source repo. |
| **Tier 2** | Credible secondary / vendor / well-maintained community | Vendor engineering blogs, reputable framework guides, widely-cited community write-ups, maintained awesome-lists with provenance. |
| **Tier 3** | General web / unvetted | Random blogs, SEO content farms, forum hearsay, undated tutorials, LLM-generated summaries with no source trail. |

---

## 3. Orthogonality Decision Tree (prevents double-counting the shared "missing citation" failure)

The single most common rater divergence is a missing/weak citation getting scored against BOTH
`citation_accuracy` and `factual_accuracy`. Use this decision tree per claim:

```
For each load-bearing claim:
  ┌─ Is there a citation?
  │
  ├─ NO citation at all
  │     → penalize citation_accuracy ONLY.
  │       (Do NOT touch factual_accuracy — uncited ≠ false.)
  │
  ├─ YES, but the citation MISREPRESENTS its source (quote ≠ what source says)
  │     → penalize BOTH citation_accuracy AND factual_accuracy.
  │       (Mechanics broken AND the claim it "supports" is unsupported.)
  │
  └─ YES, citation is CORRECT, but the CONCLUSION drawn is false / overstated
        → penalize factual_accuracy ONLY.
          (The cite is mechanically fine; the interpretation is wrong.)
```

---

## 4. Aggregation — Hybrid Floor Rule (NOT a plain mean)

```
IF factual_accuracy < 0.5 OR citation_accuracy < 0.5:
    overall = min(factual_accuracy, citation_accuracy)        # floored to the worse accuracy dim
ELSE:
    overall = mean(citation_accuracy, factual_accuracy, completeness, source_quality)
```

The **floor rule** exists because a plain mean lets the highest-consequence failure
(fabrication: `factual_accuracy = 0.0`) hide behind three good scores → 0.75 overall,
masking exactly the thing the rubric must surface. When either accuracy dim falls below 0.5,
the overall is pinned to the worse of the two and cannot be averaged back up.

`efficiency` is never in the aggregate (advisory only).

### Advisory verdict (NEVER halts)
- `overall < 0.6` → **WARN** with per-dim severity labels, research still PROCEEDS:
  - `factual_accuracy` / `citation_accuracy` low → "accuracy concern — verify before citing"
  - `completeness` low → "coverage gap — consider re-ask"
  - `source_quality` low → "weak sources — add primary"
- `overall ≥ 0.6` → note "overall {score} — OK" and PROCEED.

The threshold **0.6** is fixed (not illustrative).

---

## 5. Calibration Cases (≥20)

> **Provenance discipline:** the `Findings file` column references REAL files under
> `.tad/evidence/research/`. The per-dim scores are **calibration JUDGMENTS** anchored to the
> rubric above — they are illustrative rater targets, NOT claims about research numbers.
> Cases tagged **[degraded-hypothetical]** describe a deliberately weakened variant of a real
> file's content to populate the low-score buckets HONESTLY (the cited real file is NOT itself
> low-quality; the row scores the described degradation). Cases tagged **[as-is]** score the
> real file's actual observable shape.
>
> Distribution (mandated): ≥5 below 0.5 · ≥5 in 0.5-0.65 · rest ≥0.7.

| # | Findings file (real) | Tag | cite | fact | compl | src | overall | branch | Calibration note |
|---|----------------------|-----|------|------|-------|-----|---------|--------|------------------|
| **Bucket A — overall < 0.5 (≥5 cases, each driven by a different scored dim)** |
| 1 | ai-voice-production/2026-05-28-ask-findings-summary.md | [degraded-hypothetical] | 1.0 | 0.0 | 1.0 | 1.0 | **0.0** | floor (fact<0.5) | Per-tool minimums fabricated by splitting a method-level "10-30s" range into specific tools → factual=0.0; floor pins overall to 0.0 despite 3 perfect dims. (Real lesson: 2026-05-28 provenance.) |
| 2 | web-backend-capability-pack/2026-05-07-deep-ask-findings.md | [degraded-hypothetical] | 0.0 | 1.0 | 1.0 | 1.0 | **0.0** | floor (cite<0.5) | Claims stripped of all citations → citation_accuracy=0.0 (no-citation branch: factual untouched, stays 1.0); floor → 0.0. |
| 3 | ml-training-pack/deep-ask-findings.md | [degraded-hypothetical] | 0.0 | 0.0 | 0.5 | 0.5 | **0.0** | floor (both<0.5) | Fabricated VRAM/pricing numbers (real 2026-05-29 P0s) presented with mismatched cites → both accuracy dims 0.0; floor=min(0,0)=0.0. |
| 4 | scienceclaw/2026-05-27-deep-research-findings.md | [degraded-hypothetical] | 0.5 | 0.0 | 1.0 | 1.0 | **0.0** | floor (fact<0.5) | Correct cites but a false conclusion about runtime coupling (misreads decoupling evidence) → factual=0.0 only (correct-cite-false-claim branch); floor → 0.0. |
| 5 | 2026-05-14-kr2-kr3-ask-findings.md | [degraded-hypothetical] | 0.0 | 0.5 | 0.5 | 0.5 | **0.0** | floor (cite<0.5) | Uncited load-bearing claims → citation=0.0; floor pins to min(0.0,0.5)=0.0. source_quality leaning Tier-3. |
| 6 | google-skills/2026-05-27-ask-findings.md | [degraded-hypothetical] | 0.5 | 0.5 | 0.0 | 0.5 | **0.375** | mean (no floor) | cite=0.5 and fact=0.5 are NOT <0.5 → no floor; mean(0.5,0.5,0.0,0.5)=0.375. Near-empty coverage drags overall below 0.5 via the mean, demonstrating the non-floor low-score path. |
| **Bucket B — overall 0.5-0.65 borderline (≥5 cases)** |
| 7 | food-science-pilot/soy-sauce-cross-cultural-report.md | [degraded-hypothetical] | 1.0 | 0.5 | 0.5 | 0.5 | **0.625** | mean (no floor) | One over-generalized claim (fact=0.5) atop the known Thai-DB coverage gap (compl=0.5) and recipe-site/USDA tier mix (src=0.5) → mean=0.625, in the WARN band. |
| 8 | ai-voice-production/2026-05-28-ask-findings-summary.md | [degraded-hypothetical] | 0.5 | 1.0 | 0.5 | 0.5 | **0.625** | mean | Some cites weak but present (cite=0.5 ≥0.5 → no floor); partial coverage + mixed tiers → mean=0.625. |
| 9 | web-backend-capability-pack/2026-05-07-deep-ask-findings.md | [degraded-hypothetical] | 1.0 | 0.5 | 0.5 | 0.5 | **0.625** | mean | One overstated "top 5 problems" generalization → fact=0.5; rest mixed → mean=0.625. |
| 10 | google-skills/2026-05-27-ask-findings.md | [degraded-hypothetical] | 0.5 | 0.5 | 0.5 | 1.0 | **0.625** | mean | Both accuracy dims exactly at 0.5 (no floor trigger), strong sources, half coverage → mean=0.625. |
| 11 | scienceclaw/2026-05-27-deep-research-findings.md | [degraded-hypothetical] | 1.0 | 1.0 | 0.5 | 0.0 | **0.625** | mean | Accurate + well-cited but only Tier-3 blog sources on load-bearing claims (src=0.0) and half coverage → mean=0.625; "weak sources — add primary" advisory noted. |
| 12 | ml-training-pack/deep-ask-findings.md | [degraded-hypothetical] | 0.5 | 1.0 | 1.0 | 0.0 | **0.625** | mean | Full coverage, accurate, but cites weak (0.5) and Tier-3-heavy (src=0.0) → mean=0.625. |
| 13 | dreaming-knowledge-consolidation/2026-05-14-ask-findings.md | [degraded-hypothetical] | 0.5 | 0.5 | 1.0 | 0.5 | **0.625** | mean | Borderline cites + borderline facts (neither <0.5) with full coverage and mixed sources → mean=0.625. |
| **Bucket C — overall ≥ 0.7 (the rest, healthy findings)** |
| 14 | web-backend-capability-pack/2026-05-07-deep-ask-findings.md | [as-is] | 1.0 | 1.0 | 1.0 | 1.0 | **1.0** | mean | ~41 sources (30 GitHub primaries + deep research), per-Q structure, specific CLI tools → all dims 1.0. |
| 15 | ml-training-pack/deep-ask-findings.md | [as-is] | 1.0 | 1.0 | 1.0 | 0.5 | **0.875** | mean | 14 sources / 8 rounds, broad coverage; mix of primary docs + community → src=0.5 → mean=0.875 (post-fix, after the interpolation P0s were corrected). |
| 16 | scienceclaw/2026-05-27-deep-research-findings.md | [as-is] | 1.0 | 1.0 | 1.0 | 0.5 | **0.875** | mean | 19 sources, repo-primary (MIT, stars), accurate decoupling analysis; some secondary blogs → src=0.5 → mean=0.875. |
| 17 | google-skills/2026-05-27-ask-findings.md | [as-is] | 1.0 | 1.0 | 0.5 | 1.0 | **0.875** | mean | 50 sources, 4 seeds (3+1 adaptive); a couple KRs only partially covered → compl=0.5 → mean=0.875. |
| 18 | ai-voice-production/2026-05-28-ask-findings-summary.md | [as-is] | 1.0 | 1.0 | 0.5 | 1.0 | **0.875** | mean | 26 sources, 5 deep rounds, threshold-dense; summary form leaves some KRs thin → compl=0.5 → mean=0.875. |
| 19 | 2026-05-05-tad-evolution-deep-ask-findings.md | [as-is] | 1.0 | 1.0 | 1.0 | 1.0 | **1.0** | mean | Deep ask findings with strong internal-evidence grounding across all targeted KRs. |
| 20 | research-methodology-capability-pack/2026-05-07-ask-findings.md | [as-is] | 1.0 | 1.0 | 1.0 | 0.5 | **0.875** | mean | Pipeline-design findings, accurate + complete; mix of primary + community sources → src=0.5 → mean=0.875. |
| 21 | web-testing-capability-pack/2026-05-15-deep-ask-findings.md | [as-is] | 1.0 | 1.0 | 1.0 | 1.0 | **1.0** | mean | Tool-doc-grounded (Playwright/Vitest/k6/axe-core/Pact) → Tier-1 primaries across the board. |
| 22 | food-science-pilot/soy-sauce-cross-cultural-report.md | [as-is] | 1.0 | 1.0 | 0.5 | 0.5 | **0.75** | mean | Strong cites (USDA FDC#, papers) but Thai-DB coverage gap → compl=0.5; recipe-site (Tier-3) + USDA (Tier-1) mix → src=0.5; mean=0.75. |

Distribution check: Bucket A (overall <0.5) = cases 1-6 (6 ≥ 5 ✓; failing driver spans factual #1/#4, citation #2/#5, both #3, completeness-via-mean #6) · Bucket B (0.5-0.65) = cases 7-13 (7 ≥ 5 ✓) · Bucket C (≥0.7) = cases 14-22 (9) ✓. Total = 22 ≥ 20 ✓.

---

## Calibration Metadata

```yaml
last_calibrated: 2026-05-31
cases_count: 22
review_trigger: >
  Re-calibrate when (a) the scored-dimension set changes, (b) the tier table is revised,
  (c) >= 6 months elapse (training-corpus drift moves the anti-slop bar), or
  (d) two raters diverge by >= 1 anchor on the same findings in real use.
```
