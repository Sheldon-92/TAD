# Code Review — Web Frontend Capability Pack

**Reviewer**: code-reviewer sub-agent
**Date**: 2026-05-08
**Verdict**: GO (after P0 fixes)

## AC Verification Matrix

| AC | Status | Notes |
|----|--------|-------|
| AC1 | PASS | Zero TAD file dependencies |
| AC2 | PASS | YAML frontmatter present |
| AC3 | PASS | 7 files in references/ |
| AC4 | PASS | 4 Vue/Svelte annotations in CONVENTIONS.md (≥2) |
| AC5 | PASS | Tier 1: 19, Tier 2: 11, Tier 3: 7 (all exceed minimums) |
| AC6 | PASS | `--agent=codex` exits 2 with informative message |
| AC7 | PASS | 41 rules total (within 35-50) |
| AC8 | PASS | 41 each of When/Decision/Threshold (123 total ≥105) |
| AC9 | PASS | 41 Source attributions (≥35) |
| AC10 | PASS (after fix) | "Gate" TAD leak fixed → "CI check" |
| AC11 | PASS | DESIGN.md mentioned 15× |
| AC12 | PASS | 18 Style Dictionary/DTCG mentions |
| AC13 | PASS | All "consider" uses anchored to thresholds |
| AC14 | PASS | "CONSUMES" on line 8 |
| AC15 | PASS | React 19 referenced in performance.md + accessibility.md |
| AC16 | PASS | Largest reference 231 lines (≤800) |
| AC17 | PASS | All 3 scripts have `--help` and proper exit codes |
| AC18 | PASS | Zero inline rules in CAPABILITY.md |
| AC19 | PASS | 2,693 total lines (≤5000) |

## Findings

### P0 (Resolved)
- P0-1: "Gate" TAD terminology in performance.md:21 — FIXED: changed to "CI check" with INP proxy note

### P1 (Resolved)
- P1-1: SC2295 pattern expansion in install.sh:72 and bundle-check.sh — FIXED: quoted `"$PACK_DIR"/` and `"$BUILD_DIR"/`
- P1-2: Dead `IS_INITIAL` variable in bundle-check.sh — FIXED: removed IS_INITIAL, logic is now directly in INITIAL_TOTAL tracking
- P1-3: Lighthouse INP/TBT label misleading — FIXED: dynamic label + disclosure note in both script and reference rule

### P2 (Advisory — not blocking)
- P2-1: Missing trailing newline in accessibility.md
- P2-2: React 19 annotation density could be higher
- P2-3: install.sh `read -r -p` pipe issue
- P2-4: README doesn't show install target path
- P2-5/P2-6: React 19 annotations inline in code vs rule headers

## Strengths
- Excellent rule structure consistency across all 7 reference files
- Strong concrete thresholds (38/41 rules have numeric triggers)
- 41 Source citations with specific URLs
- DESIGN.md consumption properly threaded (Step 0 + design-tokens.md + styling.md)
- Vue/Svelte annotations are thoughtful (not just "same")
