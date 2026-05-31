# UX Expert Methodology Review — research-breadth-quality-phase5
## Artifact: `.tad/templates/research-quality-rubric.md` (post-implementation)
## Reviewer: ux-expert-reviewer
## Review type: Post-implementation methodology re-review
## Date: 2026-05-31
## Commit scope: 5456afb (worktree agent-ab6b738c712ec7d0f)

---

## OVERALL VERDICT: CONDITIONAL PASS

One new finding of P1 severity (calibration validity undermined by tag design) must be addressed before the rubric can be considered production-ready as a rater calibration reference. All prior P0/P1 findings are RESOLVED. Two prior P2-level findings are also resolved. No prior finding is UNRESOLVED.

---

## Prior Findings Resolution Status

### P0-1 — factual_accuracy vs citation_accuracy orthogonality
**STATUS: RESOLVED**

The rubric delivers a precise three-branch decision tree in §3 with clearly labelled paths:
- No citation at all → penalize citation_accuracy ONLY, with the explicit instruction "(Do NOT touch factual_accuracy — uncited ≠ false)"
- Citation misrepresents its source → penalize BOTH
- Citation is correct but conclusion is false/overstated → penalize factual_accuracy ONLY

The tree is visually rendered as an ASCII branch diagram, not prose, which eliminates ambiguity about which condition governs. The parenthetical on the "no citation" branch ("uncited ≠ false") directly addresses the pre-impl gap where raters would penalize factual_accuracy on the false assumption that an absence of evidence is evidence of falsehood. The D1 and D2 dimension descriptions reinforce the split: D1 is scoped to "citation MECHANICS only" and D2 to "claim TRUTH only," with D2 explicitly noting "even where a claim is correctly cited."

### P0-2 — efficiency demoted to advisory-unscored
**STATUS: RESOLVED**

D5 is explicitly titled "efficiency (ADVISORY — UNSCORED)" and the text states "NOT part of the numeric aggregate." The aggregation formula in §4 uses only four scored dimensions (citation_accuracy, factual_accuracy, completeness, source_quality) and the closing note reiterates "efficiency is never in the aggregate (advisory only)." The SKILL.md Step 4b rubric description at line 1615 also lists the four scored dims and marks efficiency as "ADVISORY note — NOT scored, never in the aggregate," confirming the consuming protocol agrees.

### P1-1 — completeness defined as KR coverage ratio
**STATUS: RESOLVED**

D3 defines completeness as a formal ratio: "(# targeted KRs addressed) / (# targeted KRs)" with "addressed" operationally defined as "≥1 Tier-1 or Tier-2 source contributes evidence to that KR." The score anchors (0.0 = < ~25%, 0.5 = ~40-70%, 1.0 = nearly all) map directly to that ratio, which was the missing precision in the pre-impl spec. The "addressed" bar is explicit and ties to the same tier classification used in D4, maintaining internal consistency.

### P1-2 — source_quality tier table embedded and self-contained
**STATUS: RESOLVED**

§2 is titled "Embedded Source Tier Table (self-contained — do NOT defer to curate tiers)" and provides a complete three-row table with Tier definitions and concrete examples (official docs, peer-reviewed papers, primary databases for Tier 1; vendor engineering blogs, reputable guides for Tier 2; random blogs, SEO content, LLM-generated summaries for Tier 3). No external reference is required. The instruction "do NOT defer to curate tiers" eliminates the pre-impl risk of raters reading different tier definitions than the rubric intends.

### P1-3 — calibration cases count and score-range distribution
**STATUS: RESOLVED**

§5 delivers 22 cases against the required minimum of 20. Distribution check (explicitly stated in the rubric at line 168):
- Bucket A (overall < 0.5): cases 1-6 = 6 cases, exceeding the ≥5 requirement
- Bucket B (0.5-0.65 borderline): cases 7-13 = 7 cases, exceeding ≥5 requirement
- Bucket C (≥0.7): cases 14-22 = 9 cases

All three required distribution bands are populated. This is a marked improvement over the pre-impl state where no cases existed at all.

### P2-1 — hybrid floor aggregation specified
**STATUS: RESOLVED**

§4 provides the hybrid floor rule as a code block with explicit IF/ELSE branches and inline rationale ("a plain mean lets the highest-consequence failure (fabrication: factual_accuracy = 0.0) hide behind three good scores"). The rule name is consistent between the rubric file (§4 heading), the calibration cases table ("branch" column shows "floor" vs "mean"), and the SKILL.md Step 4b description at lines 1619-1625. The 0.6 threshold is stated as "fixed (not illustrative)."

### P2-3 — Calibration Metadata block present
**STATUS: RESOLVED**

The file closes with a YAML block containing `last_calibrated: 2026-05-31`, `cases_count: 22`, and a `review_trigger` field specifying four concrete re-calibration conditions: dimension set change, tier table revision, ≥6 months elapsed, and rater divergence ≥1 anchor in real use. All three required fields from the pre-impl spec are present.

---

## New Findings

### NEW-P1 — "degraded-hypothetical" tag undermines calibration validity as a rater reference

**Severity: P1**

The rubric's stated purpose is "rater calibration reference" — it is the document two independent raters consult to understand what each anchor means before scoring a real findings file. Seven of the 22 Bucket A and Bucket B cases are tagged [degraded-hypothetical], meaning the scores reflect a described degradation of the cited file's actual content, not the file's observable state.

The provenance note in §5 handles this honestly ("Cases tagged [degraded-hypothetical] describe a deliberately weakened variant of a real file's content...the cited real file is NOT itself low-quality; the row scores the described degradation"). The intent is legitimate: populating the low-score buckets without fabricating separate source files.

However, the approach creates a practical calibration problem. A rater using this document to calibrate their scoring judgment works by reading a case and then (optionally) reading the cited real file to verify their interpretation. For [as-is] cases this works as expected. For [degraded-hypothetical] cases the cited real file will produce different scores than the table shows, because the degradation exists only in the table's description column, not in the file itself. A rater who follows the reference to the actual evidence file will find a well-cited, accurate source — inconsistent with the scores shown. This creates two failure modes:

1. A rater who does not read the file closely will simply accept the scores, which is fine for the individual row but provides no anchoring value since the case is unfalsifiable.
2. A rater who does read the file will see a discrepancy and lose confidence in the rubric's accuracy, or worse, incorrectly conclude that a high-quality file should score low on certain dimensions.

The core calibration validity requirement — "two raters scoring the same findings should land on the same anchor" — cannot be independently verified for [degraded-hypothetical] cases because the described degradation is not present in any artifact a second rater can inspect. These cases are more like worked examples of the scoring logic than calibration cases in the psychometric sense.

**Required fix:** The rubric should be explicit that [degraded-hypothetical] cases are ILLUSTRATIVE SCORING EXAMPLES, not independently verifiable calibration cases. The current Calibration Metadata block declares `cases_count: 22` without distinguishing the 13 [as-is] from the 9 [degraded-hypothetical]. The `review_trigger` condition "two raters diverge by >= 1 anchor on the same findings in real use" implicitly assumes raters can score the SAME observable artifact. That check only applies to the 13 [as-is] cases (11 in Bucket C, 2 that contribute to Buckets A and B). The 9 [degraded-hypothetical] cases cannot be used for inter-rater reliability measurement.

**Minimum fix required before PASS:** Add a clarifying note in §5's provenance block or immediately after the table that explicitly states:
- [degraded-hypothetical] cases are illustrative examples of how the decision tree + floor rule produce low scores, not independently auditable calibration points
- Inter-rater reliability measurement applies only to [as-is] cases
- The `review_trigger` rater-divergence condition should specify it applies to real findings files, not to the hypothetical cases

This does not require rebuilding the calibration cases. The [degraded-hypothetical] cases remain useful as worked scoring examples. The fix is a classification note + a clarification to the review_trigger condition.

---

### NEW-P2 — Completeness anchor upper boundary leaves a gray zone at the 25-40% range

**Severity: P2 (advisory — does not block CONDITIONAL PASS)**

D3 defines its anchors as:
- 0.0 = "< ~25%"
- 0.5 = "~half (≈40-70%)"
- 1.0 = "(Nearly) all"

The range 25-39% is undefined. A findings file that addresses 30% of KRs could score either 0.0 (below the 0.5 anchor's stated floor of "≈40%") or 0.5 (the next anchor). The tilde on "~25%" is intentionally soft, but both bounds of the 0.5 anchor use approximation markers ("~half", "≈40-70%"), leaving the 25-40% zone genuinely ambiguous.

This gap is more visible than a typical calibration edge case because the rater must decide between a 0.0 (most KRs unanswered) and a 0.5 (roughly half addressed) anchor, which is a consequential difference in the hybrid aggregation.

**Suggested fix (advisory):** Reword the 0.0 anchor to "> half of targeted KRs unanswered" or rephrase 0.5 as "≥25% and < ~75%" to eliminate the dead zone. Alternatively, add a note that the 25-40% zone defaults to 0.0 ("most objectives unanswered" applies below ~40%).

---

### NEW-P3 — SKILL.md and rubric are in sync on all load-bearing details

**Status: Confirmed consistent (no finding)**

The consuming protocol at SKILL.md lines 1606-1637 was checked against the rubric file on every load-bearing point:
- Four scored dimensions + efficiency advisory: consistent
- Hybrid floor rule formula: reproduced verbatim at lines 1619-1623
- 0.6 advisory threshold: consistent
- Per-dim severity labels: consistent
- "NEVER blocks" principle: consistent
- Single-model degradation handling: consistent with rubric's advisory-unscored handling
- The rubric is cited by path at line 1625 for "anchors + decision tree"

No divergence detected between spec and consumer.

---

## Summary Table

| Finding | Pre-impl priority | Status |
|---------|------------------|--------|
| P0-1 orthogonality decision tree | P0 | RESOLVED |
| P0-2 efficiency advisory-unscored | P0 | RESOLVED |
| P1-1 completeness as KR ratio | P1 | RESOLVED |
| P1-2 tier table self-contained | P1 | RESOLVED |
| P1-3 ≥20 calibration cases with distribution | P1 | RESOLVED |
| P2-1 hybrid floor aggregation | P2 | RESOLVED |
| P2-3 Calibration Metadata block | P2 | RESOLVED |
| NEW-P1 degraded-hypothetical invalidates rater verification | NEW | OPEN — blocks full PASS |
| NEW-P2 completeness 25-40% gray zone | NEW | OPEN — advisory only |

---

## Required Actions Before Full PASS

1. **NEW-P1 (blocking):** Add a clarifying annotation in §5 distinguishing [degraded-hypothetical] as illustrative scoring examples versus independently verifiable calibration cases. Revise the `review_trigger` rater-divergence condition to specify it applies to real (observable) findings files. The existing cases do not need to be rebuilt.

2. **NEW-P2 (advisory):** Consider clarifying the completeness 0.0/0.5 boundary for the 25-40% zone. Not required for CONDITIONAL PASS.
