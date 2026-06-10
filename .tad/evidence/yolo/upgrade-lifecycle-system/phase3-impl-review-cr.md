# Phase 3 Implementation Review — Code Review (CR)

**Reviewer**: code-review-specialist (impl-review-cr)
**Date**: 2026-06-10
**Commit**: 44a13d5
**Scope**: tad.sh integration of migration-engine.sh + sync-protocol.md + test-15 fixture

---

## P0-Critical Verification Checklist

| # | Check | Result | Evidence |
|---|-------|--------|----------|
| 1 | Engine call uses `\|\| engine_rc=$?` (NOT set +e) | PASS | L698: `bash "$engine" ... \|\| engine_rc=$?` |
| 2 | Migrate backup renamed to `.tad-migrate-backup` (NOT `.tad-backup`) | PASS | 12 occurrences at L1209-1326 all use `.tad-migrate-backup` |
| 3 | No `grep -P` in new code | PASS | No `grep -P` in tad.sh or test-15 |
| 4 | `bash -n tad.sh` passes | PASS | exit 0 |
| 5 | Existing fixtures still pass | PASS | 15/15 (14 fixtures + AC17 inline) |
| 6 | CURRENT_VERSION captured BEFORE copy_framework_files | PASS | L941-943 captures; copy at L1181/L1260 |
| 7 | call_migration_engine in both upgrade and migrate cases | PASS | L1184 (upgrade), L1263 (migrate); 0 in install |

All 7 P0-critical checks: **PASS**

---

## P0 Issues (Must Fix)

None found.

---

## P1 Issues (Should Fix)

### P1-1: User-facing help text at L1022 still says `.tad-backup/`

**File**: tad.sh, L1022
**Code**: `echo "  1. Backup existing .tad/ to .tad-backup/"`

This is the "migrate" case pre-confirmation info message shown to users. The actual backup now goes to `.tad-migrate-backup` (L1212), but the help text still promises `.tad-backup/`. Users who read this and then look for `.tad-backup/` will be confused.

**Fix**:
```bash
echo "  1. Backup existing .tad/ to .tad-migrate-backup/"
```

### P1-2: sync-protocol.md step numbering says "b3" but handoff designed it as "b2"

**File**: .claude/skills/alex/references/sync-protocol.md, L147
**Context**: The handoff document (section 4.4) designed this as "step3.b2", and several references in the handoff say "step3.b2". The completion report and implementation use "b3" because b2 was already taken by capability-pack installation. This is correct behavior (Blake adapted to the actual file state), but creates a discrepancy with the handoff text. Not a code bug — just a documentation note for future reference.

**Verdict**: No action needed. Blake correctly adapted. Noting for traceability only.

---

## P2 Issues (Consider)

### P2-1: L1207 comment references "engine's .tad-backup/" but is part of the code block that creates .tad-migrate-backup

**File**: tad.sh, L1207
**Code**: `# Structural backup for v1.x->v2.x migration (separate from engine's .tad-backup/)`

The comment is technically correct (it explains why the rename happened), but a future reader might be confused that `.tad-backup/` is mentioned in a comment immediately above code that creates `.tad-migrate-backup`. This is minor — the parenthetical is explanatory context. No change needed.

### P2-2: Test harness at test-15 L98 uses `->` instead of the Unicode arrow from tad.sh

**File**: .tad/tests/migration-fixtures/test-15-dual-caller-integration.sh, L96-97
**Context**: The harness recreates the call_migration_engine function but uses ASCII `->` instead of the real tad.sh's Unicode `→`. This is intentional (CI/non-UTF8 safety in test harness) and correct. No action needed.

### P2-3: Non-zero engine exit does not log to a file for post-mortem

The `call_migration_engine()` function logs warnings to stdout/stderr but does not capture engine output to a file. For exit 1/2 cases, the user sees only the summary warning. The engine itself may produce diagnostic output that would help with troubleshooting. Consider piping engine output to a log file (e.g., `.tad-backup/migration.log`) in a future phase.

---

## Positive Observations

1. **ERR trap handling is correct**: The `|| engine_rc=$?` pattern at L698 is the proper bash 3.2-safe way to suppress the ERR trap. This avoids the well-documented issue where `set +e` does NOT suppress an already-armed ERR trap in bash 3.2.

2. **Function placement is sound**: `call_migration_engine` at L677 is placed between `verify_install_complete` (L578) and `apply_deprecations` (L718), maintaining logical phase ordering.

3. **Guard clauses are defensive**: The function checks for "none" version, same-version equality, and missing engine binary before any work — correct fail-open behavior.

4. **Test coverage is comprehensive**: 7 sub-tests cover the key paths (happy path, skip conditions, missing binary, each exit code, non-TTY). The background+wait timeout pattern for T15g avoids GNU coreutils dependency.

5. **Namespace collision fix is thorough**: All 12 migrate-case references to `.tad-backup` were renamed to `.tad-migrate-backup`, including the final success message at L1326.

---

## Summary

| Severity | Count |
|----------|-------|
| P0 | 0 |
| P1 | 1 (L1022 stale help text) |
| P2 | 3 (comment clarity, test aesthetic, future log capture) |

**Verdict**: PASS with 1 P1 advisory. The implementation is correct, bash 3.2-safe, and well-tested. The single P1 (stale user-facing message at L1022) is a cosmetic inconsistency that should be fixed but does not affect functionality.
