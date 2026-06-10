# Completion Report: Dual-Caller Integration (Phase 3/6)

**Task ID:** TASK-20260610-001
**Handoff:** HANDOFF-20260610-dual-caller-integration-phase3.md
**Epic:** EPIC-20260609-upgrade-lifecycle-system.md (Phase 3/6)
**Completed:** 2026-06-10
**Agent:** Blake (Agent B)

---

## Summary

Integrated migration-engine.sh into both tad.sh upgrade paths (upgrade + migrate cases), updated sync-protocol.md with step3.b3 migration engine call and PRESERVE entry, fixed the migrate case backup namespace collision (P0-2), and fixed the L721 comment. Created 7 integration sub-test fixtures covering all edge cases.

---

## Changes Made

### tad.sh
1. **Added `call_migration_engine()` function** (~L670-714) — wrapper that calls the engine with `|| engine_rc=$?` ERR-trap-safe pattern, handles exit codes 0/1/2/* with appropriate log messages
2. **Inserted call in "upgrade" case** — after `copy_framework_files "$TAD_SRC"`, before `# Update CLAUDE.md`
3. **Inserted call in "migrate" case** — after `copy_framework_files "$TAD_SRC"`, before `# Copy root files`
4. **P0-2: Renamed migrate backup** — `.tad-backup` to `.tad-migrate-backup` in all 12 occurrences within the migrate case, preventing namespace collision with migration-engine.sh's per-version `.tad-backup/` directory
5. **Fixed L721 comment** — changed "lexicographic is fine for semver with fixed digits" to "version_le uses sort -V"

### .claude/skills/alex/references/sync-protocol.md
1. **Added step3.b3** — migration engine call specification with exit code handling, placed between step b2 (Capability Pack installation) and step c (Deprecation cleanup)
2. **Added `.tad-backup/` to PRESERVE list** — migration engine backups are per-version, target-side only

### .tad/tests/migration-fixtures/test-15-dual-caller-integration.sh (new)
7 sub-tests covering:
- T15a: Full upgrade path — engine deletes old file, creates backup
- T15b: old_ver="none" skip (fresh install)
- T15c: old_ver=new_ver skip (same version)
- T15d: Engine binary missing — graceful skip
- T15e: Engine exit 2 — warn, no crash
- T15f: Engine exit 1 — warn, no crash
- T15g: Non-TTY mode (</dev/null) — no hang

---

## Verification Evidence

### Layer 1 Checks

| Check | Result |
|-------|--------|
| `bash -n tad.sh` | PASS (syntax valid) |
| `bash -n .tad/hooks/lib/migration-engine.sh` | PASS (unchanged) |
| `bash .tad/tests/migration-fixtures/run-fixtures.sh` | 15/15 PASS (14 fixtures + AC17) |
| `bash .tad/tests/migration-fixtures/test-15-dual-caller-integration.sh` | 7/7 PASS |
| `bash tad.sh --verify-denylist` | PASS (13 entries match) |
| `grep -c 'call_migration_engine' tad.sh` | 3 (1 def + 2 calls) |
| `grep -c 'tad-migrate-backup' tad.sh` | 12 |
| `grep -c 'lexicographic' tad.sh` | 0 |
| `grep -c 'migration-engine' sync-protocol.md` | 1 |
| `grep -c 'tad-backup' sync-protocol.md` | 2 |

### AC Verification

| AC# | Description | Method | Result |
|-----|-------------|--------|--------|
| AC1 | call_migration_engine function exists | `grep -c 'call_migration_engine()' tad.sh` | 1 |
| AC2 | Engine called in upgrade case | `awk '/upgrade/,/;;/' \| grep -c` | 1 |
| AC3 | Engine called in migrate case | `awk '/migrate/,/;;/' \| grep -c` | 1 |
| AC4 | Engine NOT called in install case | `awk '/install/,/;;/' \| grep -c` | 0 |
| AC6 | L721 fix: "sort -V" present | Line 769 contains "version_le uses sort -V" | PASS |
| AC7 | L721 fix: no "lexicographic" | `grep -c 'lexicographic'` = 0 | PASS |
| AC8 | sync-protocol.md has migration-engine step | grep count >= 1 | PASS |
| AC9 | sync-protocol.md PRESERVE has .tad-backup | grep count >= 1 | PASS |
| AC10 | tad.sh syntax valid | `bash -n tad.sh` exit 0 | PASS |
| AC11 | Denylist drift check passes | `bash tad.sh --verify-denylist` exit 0 | PASS |
| AC14 | New fixtures pass | test-15 exit 0 | PASS (7/7) |
| AC15 | Existing 14 fixtures pass (regression) | run-fixtures.sh exit 0 | PASS (15/15) |
| AC16 | Non-TTY fixture passes | test-15 </dev/null exit 0 | PASS |
| AC17 | No version.txt → engine skipped | T15b fixture | PASS |

### P0 Fixes Applied

- **P0-1**: Used `bash "$engine" ... || engine_rc=$?` pattern (NOT set +e/set -e). The `||` makes the compound command always succeed under bash 3.2's ERR trap.
- **P0-2**: Renamed migrate case structural backup from `.tad-backup` to `.tad-migrate-backup`. Engine's `.tad-backup/` is now exclusively for per-version migration recovery data.

---

## Sub-Agent Usage

| Sub-Agent | Called | Timing | Notes |
|-----------|--------|--------|-------|
| test-runner | No | — | Ran fixtures directly in Blake session |

---

## Knowledge Assessment

### What I Learned
- bash 3.2's `set +e` does NOT suppress an already-armed ERR trap; the `|| rc=$?` pattern is the correct portable way to capture non-zero exits without triggering the trap
- macOS does not ship `timeout` (coreutils) — used background process + kill pattern for the non-TTY hang test

### Decisions Made
- Placed `call_migration_engine` after `copy_framework_files` (not before) because the engine binary comes from the source and needs to be available at the target path for execution
- Used step numbering "b3" (not "b2") in sync-protocol.md because "b2" was already taken by Capability Pack installation
- Used background+wait pattern for timeout in T15g rather than depending on GNU coreutils

---

## Files Changed

```
tad.sh                                                          # +48 lines (function + 2 calls + P0-2 rename + comment fix)
.claude/skills/alex/references/sync-protocol.md                 # +17 lines (step b3 + PRESERVE entry)
.tad/tests/migration-fixtures/test-15-dual-caller-integration.sh  # NEW (233 lines, 7 sub-tests)
```
