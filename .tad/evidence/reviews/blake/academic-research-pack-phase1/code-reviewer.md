# Spec Compliance Review — academic-research-pack-phase1

**Reviewer**: code-reviewer (Layer 2)
**Date**: 2026-05-28
**Handoff**: HANDOFF-20260527-academic-research-pack-phase1.md
**Deliverables reviewed**: architecture-analysis.md, skill-taxonomy.md, tad-mapping-blueprint.md

---

## Spec Compliance Checklist

| AC | Status | Verification Result | Finding |
|----|--------|---------------------|---------|
| AC1 | SATISFIED | `test -d /tmp/scienceclaw-study/skills` = EXISTS | Clone present with skills/ directory |
| AC2 | SATISFIED | `find ... \| wc -l` = 285 | Matches taxonomy row count (285) |
| AC3 | SATISFIED | `grep -cE` = 10 (threshold >= 8) | All 8 subsystems covered; 10 matches because some headings appear in multiple contexts |
| AC4 | SATISFIED | Row count = 285 (threshold >= 250) | All 285 skills present in taxonomy table |
| AC5 | PARTIALLY_SATISFIED | All 285 rows have 9 columns, 0 empty cells, all column values valid (Priority 1/2/3, Anti-Slop H/M/L, TAD Mapping judgment-rule/executable-reference/skip, Confidence high/low). **However**: 3 duplicate skill names found (geopandas-spatial, patent-analysis, scientific-problem-selection) causing 3 actual skills to be MISSING (materials-project, research-literature, scientific-reasoning). | No empty cells per AC5 literal requirement, but data integrity issue with duplicates |
| AC6 | SATISFIED | `grep -c '^### Decision'` = 7 (threshold >= 6) | 7 decisions documented (spec asked for 6 minimum; 7th is effort estimation) |
| AC7a | SATISFIED | `grep -c 'skills/'` = 16 (threshold >= 15) | Sufficient skills/ path citations |
| AC7b | SATISFIED | `grep -c 'src/'` = 17 (threshold >= 15) | Sufficient src/ path citations |
| AC7c | SATISFIED | `grep -c 'extensions/'` = 7 (threshold >= 5) | Sufficient extensions/ path citations |
| AC8 | SATISFIED | P1=60 / total=285 = 21% (threshold <= 30%) | Well within target. NOTE: handoff's own AC8 grep command (`grep -cE '^\|[^|]+\|...\| 1 '`) returns 0 because table uses `| # |` with spaces. The command in the handoff has a regex bug — Blake's actual data is correct. |
| AC9 | SATISFIED | `grep -c 'src/memory\|extensions/memory'` = 10 (threshold >= 5) | Memory section cites src/memory/manager.ts, memory-schema.ts, extensions/memory-core, extensions/memory-lancedb with specific line numbers |
| AC10 | SATISFIED | H-rated P1 = 35 / total P1 = 60 = 58% (threshold >= 50%) | Exceeds target. NOTE: same grep command bug as AC8 — handoff command returns 0, but actual data verifies. |
| AC11 | SATISFIED | `grep -c 'src/agents\|src/context-engine\|src/routing'` = 9 (threshold >= 6) | Section 7 covers context engine, routing, and agent scope with specific file citations |

---

## Findings

### P0 — Critical (Must Fix)

None.

### P1 — Important (Should Fix)

**P1-1: 3 missing skills / 3 duplicate entries in taxonomy**

Rows 283-285 duplicate skills already listed earlier in the table:
- Row 231 and 285: `geopandas-spatial` (both in utility cluster)
- Row 250 and 284: `patent-analysis` (both in utility cluster)
- Row 62 and 283: `scientific-problem-selection` (research-workflow vs utility cluster)

Three actual ScienceClaw skills are missing from the taxonomy entirely:
- `materials-project`
- `research-literature`
- `scientific-reasoning`

**Impact**: The taxonomy claims to be a "complete enumeration" of all 285 skills but is actually 282 unique + 3 duplicates. Phase 3 migration would miss 3 skills.

**Fix**: Remove rows 283-285, add entries for materials-project, research-literature, scientific-reasoning with appropriate cluster/priority assignments.

---

**P1-2: Anti-Slop Analysis summary section contains incorrect data**

The "Priority 1 Skills by Anti-Slop Score" summary table at the bottom of skill-taxonomy.md claims:
- L count = 3 (5% of P1), citing "canvas, brainstorming, literature (umbrella)" as examples

Actual data from the taxonomy rows shows:
- H = 35, M = 25, L = 0 among P1 skills
- The three examples cited (canvas, brainstorming, literature) are all Priority 3, not Priority 1

**Impact**: Summary section contradicts the actual data rows. If downstream consumers (Alex Phase 2 design) rely on the summary, they will have incorrect anti-slop distribution information.

**Fix**: Correct the summary to: H=35 (58%), M=25 (42%), L=0 (0%). Remove the L row or note it as 0.

---

### P2 — Minor (Consider)

**P2-1: AC8/AC10 verification commands in handoff are broken**

The handoff's own AC8 command `grep -cE '^\|[^|]+\|...\| 1 '` returns 0 because the taxonomy table uses `| # |` format with leading space after pipe, not `|#|`. The command was not dry-run against actual output format (this is an instance of the known AC Verification Drift Pattern from architecture.md).

This is a handoff spec bug, not a Blake implementation bug. Blake's actual data is correct and passes the intent of both ACs.

---

**P2-2: Only 11 deep-read skills vs handoff's 15-20 target**

NFR1 and Task 2b specified "15-20 representative skills" for deep reading. Only 11 skills are marked `confidence: high`. The handoff listed specific skill names to deep-read (e.g., literature-search, systematic-review, citation-analysis, data-analysis, meta-analysis, etc.) -- not all of these appear as high-confidence in the taxonomy.

**Impact**: Lower confidence in Priority/Anti-Slop assignments for the 4-9 skills that should have been deep-read but were only metadata-scanned. Downstream Phase 3 migration decisions may need to re-examine these.

---

**P2-3: `scientific-problem-selection` cluster assignment inconsistency**

This skill appears in row 62 (research-workflow cluster) and row 283 (utility cluster). Even after deduplication, the correct cluster needs to be determined. The skill directory content should guide which cluster is appropriate.

---

## Summary

Overall quality is strong. The architecture-analysis.md is thorough with specific file paths and line numbers. The tad-mapping-blueprint.md makes well-reasoned decisions with clear evaluation matrices. The taxonomy covers all 285 directory slots, but has 3 duplicates (P1-1) and a summary data error (P1-2). Both P1s are straightforward fixes that do not require re-analysis -- just data correction.

**Verdict**: CONDITIONAL PASS -- resolve P1-1 and P1-2 before Gate 3.
