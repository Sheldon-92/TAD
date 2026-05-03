# Code Review — Cross-Model Phase 0 Spikes

**Date**: 2026-05-03
**Reviewer**: code-reviewer subagent (2 rounds: methodology review + production baseline)

## Round 1: Methodology Review (P0 fixes applied to SPIKE-REPORT)

### P0 Issues Found + Resolved
- P0-1: Spike B verdict INTEGRATE → DEFER (asymmetric prompts + BSD grep regex incompatibility)
- P0-2: Spike A caveat added (generic Agent ≠ production code-reviewer)
- P0-3: Spike C scoped to `*publish` only with budget cap

### P1 Issues Acknowledged
- P1-1: Single-rater methodology
- P1-2: Gemini `(?!...)` lookahead fails macOS BSD grep -E
- P1-3: Latency comparison different overhead profiles
- P1-4: "4 novel patterns" corrected to 2 genuinely unique
- P1-5: Codex image cost envelope
- P1-6: AC4 thin but met

## Round 2: Production Baseline (commit 95b154b — same diff as Spike A)

| # | Severity | Issue |
|---|----------|-------|
| 1 | P0 | `_assert_skip` is no-op in passive mode — 5 of 7 skip assertions trivially pass without testing event filter |
| 2 | P1 | Race window on pre/post log-line count (concurrent hook writes) |
| 3 | P1 | Python FileNotFoundError gap in run_case post-read |
| 4 | P1 | `.router.log` 5-tuple CONTRACT block still missing from producer |
| 5 | P2 | Misleading P0-B comment |
| 6 | P2 | `import os` inside function |
| 7 | P2 | NO_LOG_DELTA signal lost in ratio column |
| 8 | P2 | `out` variable captured but unused |

**Totals**: 1 P0, 3 P1, 4 P2 = 8 total

**Three-way comparison**:
| Reviewer | P0 | P1 | Total |
|----------|----|----|-------|
| Production code-reviewer | 1 | 3 | 8 |
| Generic Claude | 0 | 6 | 11 |
| Codex | 0 | 2 | 5 |

**Verdict**: SKIP for Codex code review confirmed — no Codex-unique P0/P1. Production code-reviewer found P0 that generic Claude missed.

## Overall Layer 2 Group 1 Verdict: PASS (with spike methodology fixes applied)
