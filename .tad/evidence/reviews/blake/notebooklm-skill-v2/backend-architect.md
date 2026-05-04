# Backend Architect Review — notebooklm-skill-v2 (Blake Layer 2)

**Reviewer**: backend-architect subagent (Round 1 of Layer 2)
**Date**: 2026-05-04
**Task**: TASK-20260504-002

## Verdict: PASS (after P0/P1 fixes integrated)

## Key CLI Discovery
- `ask --new` flag does NOT exist in 0.3.4 (confirmed empirically — "No such option: --new")
- `research wait` has native `--timeout INTEGER` and `--import-all` flags (verified via --help)
- `-c 00000000-0000-0000-0000-000000000000` IS the correct fresh-conversation mechanism

## Initial Findings

| Priority | Count | Status |
|----------|-------|--------|
| P0 | 3 | All fixed in commit b12a63e |
| P1 | 4 | All fixed in commit b12a63e |
| P2 | 6 | Advisory — deferred |

## P0 Issues Found + Fixed
- P0-1: gtimeout/timeout not on macOS → use `research wait --timeout 600 --import-all` native flag
- P0-2: stale-stderr regex unvalidated → retry on any non-zero exit (simpler, correct)
- P0-3: download report --help grep brittle → drop check, preflight version covers it

## P1 Issues Found + Fixed
- P1-1: list --json membership test under-specified → specified jq .notebooks[].id schema
- P1-2: ingest --verify default wrong direction → made verify default, add --no-verify
- P1-3: configure flag-combination logic had menu-path hole → resolved (persona,mode) tuple approach
- P1-4: topics Layer 2 pattern inconsistent with ask → unified to any-non-zero-exit retry

## P2 (Deferred)
- topics config switch research_notebook.topics_updates_last_queried
- report non-ASCII slug edge case
- source guide schema source_id field
- generate report --wait timeout
- curate >20 URL sources pagination
