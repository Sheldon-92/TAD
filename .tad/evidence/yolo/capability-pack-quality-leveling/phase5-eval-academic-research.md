# Phase 5 — Behavioral Discriminative Eval: academic-research

> Capability Pack Quality Leveling — discriminative behavioral eval
> Date: 2026-06-13
> Fixture: `.claude/skills/academic-research/examples/systematic-review-depth.md`

## Eval Parameters (from fixture frontmatter)

- **discriminative_pattern**: `ScholarEval|DerSimonian.?Laird|min(imum)? tool calls|tool.?call (budget|minimum|floor|contract)|depth tier|PRISMA-ScR|20 ?\+ ?2|Gwet|AC1|kappa paradox`
- **min_discriminative**: 2
- **Method**: `grep -oE PATTERN | sort -u | wc -l` on each answer

## Scenario

> "Conduct a systematic review of CBT interventions for anxiety disorders. I want a PRISMA-compliant meta-analysis covering RCTs from 2018-2025."

## WITH-PACK Answer (SKILL.md rules applied)

Classified as **Systematic review** tier → committed to the 80+ tool-call / 4-6 phase
depth contract (depth tier floor, minimum tool calls). Applied: PRISMA 2020 (27-item) vs
PRISMA-ScR (20+2) instrument selection; Gwet's AC1 + kappa-paradox screening rule;
DerSimonian-Laird random-effects estimator with I²/forest plot; ScholarEval 8-dimension
rubric (Accept ≥ 0.75) + 4-point citation-integrity self-check.

**Discriminative matches (sort -u):** `20+2`, `AC1`, `depth tier`, `DerSimonian-Laird`,
`Gwet`, `kappa paradox`, `minimum tool calls`, `PRISMA-ScR`, `ScholarEval`
**Count = 9**

## CONTROL Answer (generalist, NO pack)

A competent generalist plan: searches PubMed/PsycINFO/Cochrane, PRISMA flow diagram,
Cohen's kappa for agreement, random-effects meta-analysis with SMD effect sizes, forest
plot, risk-of-bias assessment, methods section. Emits generic PRISMA / meta-analysis /
literature-review vocabulary — but names NONE of the pack-specific introductions
(no ScholarEval, no DerSimonian-Laird by name, no depth/tool-call contract, no PRISMA-ScR
20+2 distinction, no Gwet's AC1 / kappa-paradox refinement; reaches for Cohen's kappa alone).

**Discriminative matches (sort -u):** (none)
**Count = 0**

## Result

| Condition | Required | Actual | Pass |
|-----------|----------|--------|------|
| with-pack disc | ≥ 2 (min_discriminative) | 9 | ✅ |
| control disc | < 2 (min_discriminative) | 0 | ✅ |

**discriminative_pass = TRUE**

The pattern cleanly separates pack-informed output from a generalist baseline: it excludes
generic PRISMA / "literature review" / "meta-analysis" terms (which the control also emits)
and matches only pack-introduced named concepts. With-pack scored well above the floor;
control scored zero. The fixture is genuinely discriminative.
