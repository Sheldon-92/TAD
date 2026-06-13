# Phase 5 Review — academic-research — Correctness Lens

- **Lens**: correctness (do claims resolve / internally consistent / actionable; adversarial — try to REFUTE bar)
- **Reviewer**: subagent (Opus 4.8)
- **Date**: 2026-06-13
- **meets_bar**: true

---

## Verdict

The upgraded `academic-research` SKILL.md **clears the correctness bar**. I attempted to refute it on three angles — broken cross-references, internal threshold conflicts, and stale counts — and the load-bearing guidance held up. The defects I found are two **stale prose drifts** in non-actionable sentences (a transition label and a Notes footer), neither of which corrupts a routing decision, a threshold, the fixture, or any cited rule. Every cited rule, file, and number that an agent would *act on* resolves correctly.

---

## Findings

### What I verified (the load-bearing parts are correct)

- **Layer A structure all PASS**: A1 frontmatter (name+description, 3rd person, what+when) ✓; A2 aux files (references/ scripts/ examples/) ✓; A3 body 256 lines < 550 ✓; A4 Step 0-6 workflow + routing tables ✓; A5 CONSUMES/PRODUCES (2 hits) ✓; A6 explicit Anti-Skip/Anti-Rationalization table ✓; A7 Quick Rule Index + Available Tools ✓; A8 fixture present (examples/systematic-review-depth.md) ✓; A9 `discriminative_pattern` + `min_discriminative: 2` wired ✓; A10 4 scripts incl. 2 executable .sh ✓. → 10/10, far above the 7 floor.
- **Layer B depth**: specN = 138 specific-threshold matches (UTF-8 locale) → band 5 (≥60). Reference files carry research-grounded thresholds (PRISMA 27 items, PRISMA-ScR 20+2, DerSimonian-Laird, Gwet's AC1, ScholarEval 0.75/0.60/0.40 bands, I²/Q). Not LLM-restatable boilerplate.
- **Cross-reference integrity — all resolve**: every rule cited in the SKILL Anti-Skip table exists in the named reference at the claimed semantics: research-protocol.md Rule 1 (≥2 databases, L108), Rule 4 (Methods section, L111), Rule 8 (save to file, L115), Rule 9 (count tool calls, L116); zero-hallucination.md "4-Point Self-Check" (L36); literature-search.md Gwet's AC1 / kappa paradox (L16, L127), PRISMA-ScR 20+2 vs PRISMA 2020 27-item decision rule (L13-14, L110-111).
- **Threshold consistency**: SKILL Step 1 tier floors (survey 20-40, comprehensive 40-80, systematic 80+) match research-protocol.md L90-92 exactly; the Anti-Skip "tier floor in Step 1: 20-40 survey / 80+ systematic" cite matches. ScholarEval ≥0.75 Accept bar in SKILL Step 5 matches scholar-eval.md L36/L148. reflexion-cycle.md is genuinely 5-dimension as the index claims; scholar-eval.md is genuinely 8-dimension.
- **Script claims resolve**: academic-search.sh supports exactly the 6 databases the SKILL lists (semantic-scholar, openalex, pubmed, arxiv, europeana, usda-food); both .sh scripts are executable; setup-cv.sh exists as referenced.
- **Fixture is correctly discriminative**: `discriminative_pattern` regex is syntactically valid and matches ONLY pack-specific markers (ScholarEval, DerSimonian-Laird, depth tier, PRISMA-ScR/20+2, Gwet/AC1, kappa paradox). The fixture explicitly excludes generic markers (PRISMA alone, "literature review", "meta-analysis", "Cohen's kappa" alone) — consistent with QUALITY-BAR §3 discriminative gate, NOT the combined fallback. min_discriminative=2 is conservative vs ~6 available markers.
- **All 18 referenced cluster/protocol files exist** and are flat (one-level-deep — Layer A soft constraint met). Multimodal tier's 3 references (multimodal-research, pattern-extraction, quantitative-analysis) all present.

### Defects found (both NON-fatal stale prose — do not block bar)

1. **DEFECT (minor, prose): "one of four tiers" but the table has 5 rows.** SKILL.md L39 says "Classify the user's request into **one of four tiers**" and attributes the table to "SCIENCE.md lines 111-121", but the Step 1 table has **5** rows (Multimodal research was added). The label and source attribution were not updated when the 5th tier was appended. Actionable impact: low — the table itself is correct and an agent routes off the table, not the sentence; but the count is internally inconsistent and the SCIENCE.md L111-121 attribution does not cover the multimodal row. Recommend: change "four tiers" → "five tiers" and qualify the multimodal-row source.

2. **DEFECT (minor, prose): stale "15 reference files" count.** SKILL.md L256 Notes: "86 unique ScienceClaw skills cited across **15** reference files". Actual count is **18** reference files (and the Step-2 cluster index itself lists 18). Stale number from before the 3 multimodal references were added. The "86 skills / 150 P1+P2" figures are also unverifiable from the artifact (SCIENCE.md source not shipped in the pack), but that is a provenance note, not actionable guidance. Recommend: update 15 → 18.

### Refutation attempt that FAILED (i.e., pack is fine)

- **Alleged 2-vs-3 database conflict — WITHDRAWN.** research-protocol.md states "at least 2 databases" (general baseline, Rules L108 + Mandatory Search Protocol L129 + Search Quality Checklist L155) and "Minimum 3 databases" (L171). These are NOT contradictory: the 3-database floor is scoped specifically to the **PRISMA 2020 systematic-review protocol**, a stricter superset of the general 2-database baseline. Contextually consistent.

---

## Fact-Checks

- `wc -l SKILL.md` = 256 (< 550 floor) — PASS, confirmed.
- specN (DISC alternation over SKILL.md + references/*.md, LC_ALL=en_US.UTF-8, dedup) = 138 → Layer B band 5 — confirmed.
- research-protocol.md numbered Anti-Premature-Conclusion Rules = exactly 10 (L108-117), matching SKILL "10 Anti-Premature-Conclusion Rules" claim — confirmed.
- Cited rule semantics (Rule 1/4/8/9, 4-Point Self-Check, Gwet AC1, PRISMA-ScR 20+2, PRISMA-2020 27-item, ScholarEval 0.75) all present in the named reference files at the claimed meaning — confirmed by grep.
- academic-search.sh advertised databases (6) match SKILL.md Supported-databases list exactly — confirmed.
- discriminative_pattern regex validity: `echo test | grep -oE "<pattern>"` exit=1 (valid regex, no spurious match) — confirmed.
- "four tiers" (SKILL L39) vs 5 table rows — MISMATCH confirmed (defect 1).
- "15 reference files" (SKILL L256) vs 18 actual files in references/ — MISMATCH confirmed (defect 2).

---

## Why meets_bar = true

The correctness bar asks whether the guidance is internally consistent and actionable and whether its claims resolve. Every claim an agent would *execute on* — routing tables, tier floors, cited rules, ScholarEval bands, script invocations, the discriminative fixture — resolves correctly and consistently. The two confirmed defects are stale descriptive numbers in a transition sentence (L39) and a footer Notes line (L256); they do not alter any decision, threshold, or cross-reference. They are worth a one-line fix but do not sink the lens. Bar cleared.
