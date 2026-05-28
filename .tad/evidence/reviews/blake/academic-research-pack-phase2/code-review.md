# Code Review: academic-research-pack-phase2

**Reviewer**: code-reviewer sub-agent
**Date**: 2026-05-28
**Verdict**: PASS (after P0 fix)

## Findings Summary
- **P0**: 1 (fixed) — Source citation discrepancy on adapted tool-call thresholds
- **P1**: 3 (2 fixed, 1 deferred)
- **P2**: 4 (2 fixed, 2 accepted as-is)

## P0 Resolution
| # | Issue | Resolution |
|---|-------|-----------|
| P0-1 | Adapted tool-call thresholds cited SCIENCE.md but values came from tad-mapping-blueprint.md | Fixed: source lines now say "Adapted from SCIENCE.md lines 111-121, adjusted per tad-mapping-blueprint.md Decision 6" |

## P1 Resolution
| # | Issue | Resolution |
|---|-------|-----------|
| P1-1 | pack-registry.yaml `last_scanned` stale | Deferred: manual append is acceptable for single-pack addition; scan-packs.sh can regenerate later |
| P1-2 | Substring keyword collision (元分析⊃分析, etc.) | Mitigated: disambiguation section in SKILL.md handles ambiguous cases; keywords use exact-match in pack-registry |
| P1-3 | install.sh relative path detection | Fixed: now uses `git rev-parse --show-toplevel` for project root resolution |

## Strengths Noted
- Strong anti-slop content (specific thresholds: ScholarEval weights, PRISMA 27 items, FDR < 0.05)
- Excellent cross-reference integrity between 5 reference files
- Well-designed scope disambiguation avoiding research-methodology collision
- ScholarEval formula internally consistent (weights sum to 100%)
