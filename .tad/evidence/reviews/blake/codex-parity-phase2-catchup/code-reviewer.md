# Code Review — codex-parity-phase2-catchup

## Summary
0 P0, 2 P1, 4 P2. Core per-owner SAFETY presence logic is architecturally sound.

## Findings

| ID | Severity | Issue | Status |
|----|----------|-------|--------|
| P1-1 | P1 | Pin file missing = WARN → should be exit 1 for LIVE gate | **FIXED** (fb43be2) |
| P1-2 | P1 | Section header self-counting in awk — symmetric now, fragile | Deferred to P3 (pins calibrated, symmetric) |
| P2-1 | P2 | `grep -coE` portability in secondary signal | Accepted (secondary WARN only) |
| P2-2 | P2 | EXPECTED_ABSENT dual-use semantics | Noted |
| P2-3 | P2 | on_start surplus in Blake codex (4 vs 2) | Documented in trace |
| P2-4 | P2 | Case-insensitive feature marker check | No action needed |

## Positive Observations
- Per-owner-body presence blocks the compensation attack by design
- 0-source-category SKIP correctly handles Blake asymmetry
- Pin table self-validation is a strong parser guard
- BSD/macOS compatibility clean throughout
