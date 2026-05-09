# Architectural Review: Blake `notebooklm_access` Section

**Reviewer:** backend-architect subagent  
**Date:** 2026-05-04  
**Round:** Layer 2 Group 2  
**Initial Verdict:** REQUEST CHANGES (2 P0, 3 P1, 2 P2)  
**After Fixes:** PASS (all P0/P1 resolved)

## P0 Issues — All Resolved

### P0-1 (RESOLVED): `use <id>` writes REGISTRY.yaml
- **Issue:** `*research-notebook use <id>` writes `active_notebook` to REGISTRY.yaml — Alex-owned state. Blake silently changing Alex's active notebook violates terminal isolation principles.
- **Fix applied:** Moved `use <id>` to `forbidden` list. Added requirement that Blake uses `--notebook <id>` flag explicitly on all query commands.

### P0-2 (RESOLVED): `ingest` is permanent source add, not note creation
- **Issue:** `ingest` runs `source add` (permanent NotebookLM source + REGISTRY.yaml increment), but `scope` said "read-only + note creation ONLY" — architecturally incorrect.
- **Fix applied (Option C):** Added `mutation_scope` block explicitly documenting what ingest writes + constraints. Updated `scope` field to "read-only + controlled ingest (see mutation_scope)". Confirmation gate already in *research-notebook ingest Step 2.

## P1 Issues — All Resolved

### P1-1 (RESOLVED): `language set` writes persistent per-notebook config
- **Fix applied:** Removed `language set` from allowed list. Moved to `forbidden`. Kept `language get` and `language list` (read-only) in allowed.

### P1-2 (RESOLVED): `terminal_isolation` claim understated the risks
- **Fix applied:** Updated `terminal_isolation` block to accurately describe the read-only vs mutation boundary. Now explicitly states "REGISTRY.yaml mutation routes through Alex only."

### P1-3 (RESOLVED): Missing `default_rule`
- **Fix applied:** Added `default_rule: "deny"` and `default_rule_explanation` block to the section.

## P2 Advisory (not blocking)

### P2-1: quiz/flashcards for Blake is unusual use case
- Not fixed (advisory). Accepted as-is — may be useful for Blake understanding research context.

### P2-2: `topics` without `--notebook` leaks active notebook
- Partially addressed by requiring `--notebook <id>` in `when_to_use` step 2. Updated in section.

## Architectural Note
The deeper issue: `research-notebook` is designed as Alex-only. Phase 4 follow-up: add `--caller {alex|blake}` flag to research-notebook SKILL itself (Option 2 from review) to enforce capability fencing at the tool level rather than relying on Blake's SKILL allowlist.
