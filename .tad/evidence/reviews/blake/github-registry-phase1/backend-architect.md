# Backend Architecture Review — github-registry-phase1
**Reviewer**: backend-architect subagent
**Date**: 2026-05-04
**Task**: TASK-20260504-004

## Findings

| Severity | ID | Description | Status |
|----------|----|-------------|--------|
| P0 | BA-P0-1 | `created_by` field schema mismatch with research-notebooks REGISTRY template. YAML extra fields are accepted without error; reverse-sync (rule #2) documented as manual action. | Fixed: Step 10 now notes created_by as extension field + documents reverse-sync limitation |
| P0 | BA-P0-2 | (INVALID) `notebooklm create` alleged not to exist in 0.3.4. Empirically verified: `notebooklm create` IS in 0.3.4 help output. Finding rejected. | N/A |
| P0 | BA-P0-3 | `explore` Step 6 fetched description only — no stars attached to selected repos. "Keep top 3 repos only" in notebook Step 6 couldn't execute. | Fixed: Step 6 now fetches both `.stargazers_count` and `.description` per repo |
| P0 | BA-P0-4 | `git/trees?recursive=1` truncation not handled — repos >100K files or >7MB silently return partial list. | Fixed: Step 4 now checks `.truncated` flag + falls back to root contents listing |
| P1 | BA-P1-1 | `list` command Step 2 declared staleness check in §4.5 but not implemented in SKILL. | Fixed: list command now has Step 2 (load research-notebooks REGISTRY) + Step 3 staleness check |
| P1 | BA-P1-2 | No rollback for partial Step 8 source-add failures. | Fixed: Added failure threshold (>50%) + AskUserQuestion with Delete option |
| P1 | BA-P1-3 | Phase 2 extensibility (auto_query_keywords, query_priority) not in schema. | Deferred: YAML schema is open; Phase 2 will extend without breaking Phase 1. Documented as Phase 2 scope. |
| P1 | BA-P1-4 | `gh api commits --limit 1` invalid flag for gh api (--limit is for gh search). | Fixed: changed to `?per_page=1` query parameter |
| P1 | BA-P1-5 | Cross-registry write ordering not specified — race window if write (a) succeeds but write (b) fails. | Fixed: Step 10 now specifies order: (b) research-notebooks first, then (a) github-registry |
| P2 | BA-P2-1 | (INVALID) Alleged DovAmir duplicate causing <50 entries. Verified: 50 entries, no duplicate. | N/A |
| P2 | BA-P2-2 | ~30s latency per source add → 50 sources = 25 min blocking. No progress reporting. | Noted advisory: Step 8 tracks success_count but no time estimate warning. Acceptable for Phase 1. |
| P2 | BA-P2-3 | Cross-registry sync rule #2 (archive → null notebook_id) unimplementable without *research-notebook archive modification. | Accepted: documented as manual action in SKILL. Phase 2 scope. |

## Round 2 Verdict
After P0 + P1 fixes applied: P0=0, P1=0 → **PASS**
(P1-3 and reverse-sync limitation deferred to Phase 2 with explicit documentation)
