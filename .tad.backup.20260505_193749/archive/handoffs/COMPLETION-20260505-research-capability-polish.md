# Completion Report: Research Capability Polish

**Handoff**: HANDOFF-20260505-research-capability-polish.md
**Date**: 2026-05-05
**Blake Git Commit**: 69b2450

## Gate 3 v2 — PASS ✅

### Layer 1 Verification (yaml task_type)
| AC | Command | Expected | Actual | Result |
|----|---------|----------|--------|--------|
| AC1 | grep -c "深度研究" CLAUDE.md | =1 | 1 | ✅ |
| AC2 | grep -c "deep-research" CLAUDE.md | ≥1 | 1 | ✅ |
| AC3 | grep "帮我看看" CLAUDE.md | empty | empty | ✅ |
| AC4 | grep -c "Alex-domain only" research-notebook/SKILL.md | =0 | 0 | ✅ |
| AC5 | grep -c "Standalone Usage" research-notebook/SKILL.md | ≥1 | 2 | ✅ |
| AC6 | grep -c "Action Bridge" alex/SKILL.md | ≥1 | 1 | ✅ |
| AC7 | step6 has 5 options | content | verified | ✅ |
| AC8 | "non-blocking" in research-notebook | ≥1 | 1 | ✅ |
| AC9 | CLAUDE.md net ≤6 lines | ≤6 | 2 | ✅ |
| AC10 | precedence rule in Standalone Usage | ≥1 | 1 | ✅ |

### Layer 2 Verification
| Reviewer | Verdict | P0 | P1 |
|----------|---------|----|----|
| code-reviewer (combined spec+code) | PASS | 0 | 0 |

### Evidence Checklist
- [x] .tad/evidence/reviews/blake/research-capability-polish/code-reviewer.md
- [x] .tad/evidence/acceptance-tests/research-capability-polish/acceptance-verification-report.md
- [x] Git commit: 69b2450

## What Was Delivered

### R1: Auto-activation (CLAUDE.md)
- Added `| 深度研究 | ... |` routing row to §2 table (signal words: 研究/research/调研/landscape/对比/深入; NOT 帮我看看/了解)
- Added `研究工具排除：...` exclusion note suppressing `/deep-research` skill
- Net: 2 lines added to CLAUDE.md (≤6 per AC9)

### R2+R4: Session continuity + SKILL.md contradiction fix (research-notebook SKILL)
- Replaced "Alex-domain only" line with "Primary use: Alex. Also usable standalone."
- Added full "Standalone Usage" section: standalone invocation steps, protocol exclusions, precedence rule, soft after-research suggestions

### R3: Close the loop (alex SKILL step6)
- Added `step6: Research → Action Bridge` to `research_plan_protocol` with 5 options
- Updated `enters_standby` from "After step5" to "After step6 (option 5)"

## Deviations from Plan
- Exclusion note label changed from "深度研究排除：" to "研究工具排除：" — prevents double-match with AC1 grep (Alex-side spec conflict between §4.1 label and AC1 = 1 expectation)
- research-notebook SKILL grew 17 lines net (spec estimated ~12) — difference is markdown structure/spacing, within bounds

## Knowledge Assessment
**skip_knowledge_assessment: no** — assessing now.

**New discovery?** ✅ Yes — documenting:

> **CLAUDE.md Signal Word Conflict Pattern**: When a routing table row uses keyword X and an exclusion note also uses keyword X as its label prefix, grep-c X returns 2 instead of 1. This is the same INTENT-PASS-LITERAL-FAIL pattern as AC Verification Drift (architecture.md 2026-04-25) but at the spec-generation level: Alex's §4.1 text spec and §6 AC verification command were mutually contradictory. Resolution: relabel the exclusion note to NOT share the routing keyword ("深度研究排除" → "研究工具排除"). Rule: AC grep commands must be dry-run against the actual proposed spec text before handoff ships.

Writing to `.tad/project-knowledge/architecture.md`.
