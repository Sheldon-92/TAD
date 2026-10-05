# Gate 4 Acceptance — Framework-Health Close-out A (Installer Data-Safety Remainder)

**Handoff**: `HANDOFF-20260903-framework-health-phase2-remainder.md` (archived)
**Completion**: `COMPLETION-20260903-framework-health-phase2-remainder.md` (archived)
**Design**: `DESIGN-20260903-framework-health-phase2-remainder.md` (archived)
**Task ID**: `TASK-20260903-FWHEALTH-A`
**Gate-4 authority**: Human (2026-09-03, "1" = accept implementation; publish decision explicitly deferred)
**Verdict**: ✅ **PASS** — Phase-2 remainder accepted; Epic publish ban LIFTED (condition met); no publish executed.

## 1. Business acceptance (requirement alignment)

- FR-1 `--source` offline mode: shipped (trust boundary + arg-parse-time validation + disjointness + probe bypass + single cleanup chokepoint). Sandbox matrix proves offline full installs on all 3 platforms. ✅
- FR-5 owner-aware acceptance: user-owned paths asserted present + byte-identical post-install. ✅
- F-05/F-06/F-07/F-08 + F-34: all closed with red→green evidence (rollback granularity + atomicity were genuine P0s found by review, fixed, re-proven). ✅
- AC2.5 machine guard: `installer-destructive-guard` + 26-id appendix + 2 mutation probes. ✅
- Boundaries kept: `deprecation.yaml`, migration-engine, skills, gates, DENY_LIST content untouched; `upgrade-acceptance.sh` untouched (AC2.7 green-kept); no push/tag/release/sync at any point. ✅
- Gate chain integrity: Gate 2 (security FAIL→integrated, code FAIL→integrated, R2 CONDITIONAL) → implementation (degraded path, disclosed) → Gate 3 (Layer-1 14/14 + full-track dual review + fix-round re-review 5/5 PASS) → this Gate 4. ✅

## 2. Accepted commits (local only, NOT pushed)

- `f61c1892` — implementation (FR-1 + fixes + guard + fixture suite)
- `1a256534` — fix round (manifest restore, file atomicity, literal-prefix guards)
- `b09aa052` — fixture cleanup-prefix fix
- Future publishes MUST name their exact SHA; nothing here authorizes any push/tag.

## 3. Epic effect

- `EPIC-20260816-framework-health-repair` Phase 2: all rows DONE (F-01/02/03 carried + FR-1/FR-5/AC2.5 this track). Hard constraint 1 ("Phase 2 Gate 4 前禁止 publish/sync") is SATISFIED → ban lifted automatically.
- v2.43.1 publish still requires a separate explicit human instruction (pending decision a/b). Track B (1b + re-slim) is next, independent of publish.

## 4. Knowledge Assessment — distill DECISION: APPROVED (1 entry, applied)

- Appended to `.tad/project-knowledge/patterns/shell-portability.md`: red-first on installer-risky edits + cancelled-subagent tree check + `printf '--'` dash-trap live specimen + mktemp-family prefix lesson. Variabilize test passes (applies to any destructive-path + fixture work).
- Remaining candidates (harness-bug anecdotes) stay in COMPLETION/journal — one-off, not patterns.
