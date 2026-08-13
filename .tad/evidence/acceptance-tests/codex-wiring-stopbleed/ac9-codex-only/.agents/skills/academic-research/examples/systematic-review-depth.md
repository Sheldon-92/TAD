---
name: systematic-review-depth
description: "Tests depth-tier classification + PRISMA pipeline + citation-integrity self-check on a systematic review request"
pack: academic-research
tests_rules:
  - "Step 1: Detect Research Task Type (tier → min tool calls)"
  - "literature-search.md PRISMA pipeline + PRISMA-ScR vs PRISMA 2020 decision rule"
  - "literature-search.md screening kappa-paradox → Gwet's AC1"
  - "scholar-eval.md 8-dimension rubric"
  - "zero-hallucination.md 4-point citation check"
min_marker_count: 3
# DISCRIMINATIVE gate: ONLY pack-specific markers. Excludes generic PRISMA / "literature
# review" / "meta-analysis" (any senior researcher emits these). Discriminative terms are
# pack introductions a no-pack agent does not name: ScholarEval (8-dim rubric),
# DerSimonian-Laird (named estimator), the tier tool-call depth contract, the PRISMA-ScR
# 20+2 vs PRISMA-2020 27-item instrument-selection rule, and Gwet's AC1 for rare-class
# screening (kappa paradox). min_discriminative=2 stays conservative (tighter than the
# number of available markers) so a partial-but-genuine pack output still PASSes while a
# no-pack control — which emits none of these named introductions — FAILs.
discriminative_pattern: "ScholarEval|DerSimonian.?Laird|min(imum)? tool calls|tool.?call (budget|minimum|floor|contract)|depth tier|PRISMA-ScR|20 ?\\+ ?2|Gwet|AC1|kappa paradox"
min_discriminative: 2
---

# Fixture: Systematic Review Depth Enforcement

## Input Scenario

"Conduct a systematic review of CBT interventions for anxiety disorders. I want a PRISMA-compliant meta-analysis covering RCTs from 2018-2025."

## Expected Markers

When an AI agent processes the Input Scenario with the academic-research pack loaded,
the output MUST contain these markers:

1. **Tier classification with depth threshold** [structural]: the agent explicitly classifies this as a Systematic review tier and commits to its minimum depth (80+ tool calls / 4-6 phases), rather than launching into ad-hoc searching
   grep pattern: `[Ss]ystematic review|80\+|4.6 phases|min(imum)? tool calls`
2. **PRISMA pipeline**: explicit PRISMA-stage flow (identification → screening → eligibility → inclusion), not just "I'll search papers"
   grep pattern: `PRISMA|identification.+screening|eligibility|records? screened`
3. **Effect-size / heterogeneity statistics**: meta-analytic machinery the pack introduces
   grep pattern: `DerSimonian.?Laird|I.?squared|I²|effect size|random.?effects|forest plot`
4. **ScholarEval / citation integrity**: quality scoring threshold or the 4-point citation self-check
   grep pattern: `ScholarEval|0\.75|citation.+(trace|integrity)|every citation`
5. **Correct reporting instrument**: picks PRISMA 2020 (27-item) for THIS systematic review and distinguishes it from PRISMA-ScR (20+2) for scoping reviews — the pack's instrument-selection rule
   grep pattern: `PRISMA-ScR|20 ?\+ ?2|27.item`
6. **Rare-class screening agreement**: names Gwet's AC1 (not Cohen's kappa alone) for include/exclude screening — the pack's kappa-paradox rule
   grep pattern: `Gwet|AC1|kappa paradox`

## Verification Command

```bash
grep -oE 'systematic review|80\+|min tool calls|PRISMA|identification.+screening|eligibility|DerSimonian.?Laird|I.?squared|effect size|random.?effects|forest plot|ScholarEval|0\.75|every citation' systematic-review-depth-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "ScholarEval" (the pack's 8-dimension weighted rubric — a no-pack agent does not name this)
- ✅ "DerSimonian-Laird" (specific random-effects meta-analysis estimator from statistics.md)
- ✅ "80+ tool calls / 4-6 phases" (pack's tier-based depth enforcement — no-pack agent has no depth contract)
- ✅ "PRISMA-ScR / 20+2 items" (the pack's instrument-selection rule — a no-pack agent conflates all reviews under PRISMA 2020's 27 items)
- ✅ "Gwet's AC1 / kappa paradox" (the pack's rare-class screening rule — a no-pack agent reaches for Cohen's kappa alone)
- ❌ "PRISMA" alone (generic — any senior researcher emits the word for a systematic review)
- ❌ "literature review" (generic — any agent says this for a review request)
- ❌ "meta-analysis" alone (in the input; not discriminative on its own)
- ❌ "anxiety" / "CBT" (from the input, not the pack)
- ❌ "Cohen's kappa" alone (a no-pack agent names it; only the AC1/paradox refinement is discriminative)
