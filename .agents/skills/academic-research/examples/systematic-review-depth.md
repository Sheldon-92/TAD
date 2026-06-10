---
name: systematic-review-depth
description: "Tests depth-tier classification + PRISMA pipeline + citation-integrity self-check on a systematic review request"
pack: academic-research
tests_rules:
  - "Step 1: Detect Research Task Type (tier → min tool calls)"
  - "literature-search.md PRISMA pipeline"
  - "scholar-eval.md 8-dimension rubric"
  - "zero-hallucination.md 4-point citation check"
min_marker_count: 3
# DISCRIMINATIVE gate: ONLY pack-specific markers. Excludes generic PRISMA / "literature
# review" / "meta-analysis" (any senior researcher emits these). ScholarEval and
# DerSimonian-Laird are named pack introductions; the tool-call depth contract is the
# pack's tier enforcement. min_discriminative=2 (genuinely thin once PRISMA is excluded —
# only 2-3 strongly pack-unique terms remain; tighter is safer than a false PASS).
discriminative_pattern: "ScholarEval|DerSimonian.?Laird|min(imum)? tool calls|tool.?call (budget|minimum|floor|contract)|depth tier"
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
- ✅ "PRISMA identification→screening→eligibility" stages (pack's literature-search pipeline)
- ❌ "literature review" (generic — any agent says this for a review request)
- ❌ "meta-analysis" alone (in the input; not discriminative on its own)
- ❌ "anxiety" / "CBT" (from the input, not the pack)
