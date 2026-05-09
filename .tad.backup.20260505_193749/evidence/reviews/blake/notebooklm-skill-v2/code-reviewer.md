# Code Review — notebooklm-skill-v2 (Blake Layer 2)

**Reviewer**: code-reviewer subagent (Round 1 of Layer 2)
**Date**: 2026-05-04
**Task**: TASK-20260504-002

## Verdict: PASS (after P0/P1 fixes integrated)

## Initial Findings

| Priority | Count | Status |
|----------|-------|--------|
| P0 | 3 | All fixed in commit b12a63e |
| P1 | 5 | All fixed in commit b12a63e |
| P2 | 6 | Advisory — deferred |

## P0 Issues Found + Fixed
- P0-1: C2 report --dry-run semantics wrong (empty-artifact false-negative) → fixed: drop capability check, preflight 0.3.4+ sufficient
- P0-2: C6 ingest hypothesis framing contradicts empirically verified GO state → fixed: reframed as verified, --verify default
- P0-3: list Step 2 per-notebook cloud calls → fixed: single cloud call + jq membership check

## P1 Issues Found + Fixed
- P1-1: "measure wall-clock time" dangling → removed
- P1-2: ingest --verify opt-in was wrong → made default (--no-verify opt-out)
- P1-3: topics didn't update last_queried → added Step 3 REGISTRY update
- P1-4: configure exclusive case ambiguity → restructured with resolved (persona, mode) tuple
- P1-5: report retry flat 10s → exponential 10s/20s/30s

## P2 (Deferred)
- Version regex future-proofing (sort -V approach already applied in preflight)
- Preflight auth liveness probe
- 500KB size cap citation
- curate URL-only filter note (already present in spec)
- report slug for non-ASCII
- Knowledge gap: Phase 2 deferred commands section
