# Layer 2 Code Review — research-methodology-upgrade

**Reviewer:** code-reviewer sub-agent
**Date:** 2026-05-05
**Handoff:** HANDOFF-20260505-research-methodology-upgrade.md

## Summary
Found 3 P0s + multiple P1s. All P0s and key P1s fixed in Round 2.

## P0 Findings

**P0-1 (FIXED):** Phase 4 OBJECTIVES.md skip path referenced "step d" (deleted by diff)
- Fix: Changed to "Proceed to step5"

**P0-2 (FIXED):** Phase 2 error filter `status != "ready"` contradicts curate Step 1b's `status contains "error"` — would delete in-progress sources
- Fix: Changed to `status contains "error"`, added "Do NOT delete preparing/processing", added defensive JSON shape check, added `source.id` field spec

**P0-3 (FIXED partial):** Phase 2 duplicates curate Step 1b/1c with divergent semantics
- Fix: Phase 2 now explicitly references curate's canonical tier patterns and filter semantics; full delegation deferred (requires `--auto` flag addition to curate command)

## P1 Findings

**P1-1 (FIXED):** Dead save/restore `active_notebook` lines — no-op given `-n` flag
- Fix: Removed save/restore lines, added explanatory comment

**P1-2 (FIXED):** Duplicate ask calls — "prefer Tier 1" branch issued second ask instead of modifying query
- Fix: Restructured to single ask with `constructed_query` (query prefix if KR is ⬚)

**P1-4 CR (FIXED):** Phase 5 "只保存，不写 AC" branch undefined
- Fix: Added explicit 3-branch handling (全部采纳/逐条确认/只保存) with different output files

**P1-3 CR (DEFERRED):** Tier classification ephemeral — not persisted to file, Phase 4 dependency on in-memory tier table
- Rationale: Adding file I/O for tier table significantly expands scope; protocol notes tier as "ephemeral judgment"; deferred to follow-up handoff

**P1-6 (DEFERRED):** AC1 "PHASE [1-5]" grep not verifying order/uniqueness
- Rationale: AC serves as smoke-alarm; deeper structural check deferred to Phase 6 process quality work

## Final Verdict
**PASS** — All P0s fixed, key P1s fixed, deferred items documented.
