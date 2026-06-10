# Phase 3 Implementation Review — Architecture

**Reviewer**: integration-architect
**Date**: 2026-06-10
**Scope**: tad.sh call_migration_engine integration + sync-protocol.md step3.b3

---

## Verification Checklist

| # | Check | Verdict | Evidence |
|---|-------|---------|----------|
| 1 | Zero dual-implementation: only call_migration_engine calls engine | PASS | `grep -n 'migration-engine' tad.sh` returns only L687 (engine path inside call_migration_engine). No inline rm/mv for migration outside the function. |
| 2 | Ordering: engine call AFTER copy_framework_files, BEFORE version.txt write | PASS | Upgrade: copy L1181 -> engine L1184 -> version.txt L1201. Migrate: copy L1260 -> engine L1263 -> version.txt L1323. |
| 3 | Fresh install case does NOT call engine | PASS | `awk '/install/,/;;/' tad.sh | grep -c call_migration_engine` = 0. Install case (L1063-L1202) has no engine call. |
| 4 | sync-protocol step3.b3 matches tad.sh semantics | PASS | Both use same args (--from old --to new --target dir --source dir), same exit code handling (0=ok, 1=warn, 2=warn). Numbering correctly uses b3 (b2 = Capability Pack). |
| 5 | .tad-backup/ in PRESERVE list | PASS | sync-protocol.md L219: `- .tad-backup/ (migration engine backups -- per-version, target-side only)` |
| 6 | No bash 4+ syntax in new code | PASS | New lines use only: `local`, `[ ]`, `case/esac`, `||`. No `declare -A`, `local -n`, `${var,,}`, `mapfile`, `readarray` in diff. Pre-existing `[[ =~ ]]` at L1043 is untouched. |

---

## Findings

### P0 — None

No P0 issues found. The critical architectural constraints are all satisfied:
- Single call site pattern (function definition + 2 invocations) prevents dual-implementation drift
- ERR trap bypass via `|| engine_rc=$?` is correct for bash 3.2
- Fresh install skip logic (`old_ver = "none"`) prevents engine call on new installs
- Version capture timing is safe (CURRENT_VERSION is a shell variable snapshot, unaffected by copy_framework_files overwriting the file)

### P1

**P1-1: User-facing message at L1022 references stale path `.tad-backup/`**

Location: tad.sh L1022
```
echo "  1. Backup existing .tad/ to .tad-backup/"
```

The migrate case pre-confirmation message (shown BEFORE user types y/n) says backup goes to `.tad-backup/`, but the actual operation (L1212) now writes to `.tad-migrate-backup/`. The completion message at L1326 is correct (`log_success "Backup saved to .tad-migrate-backup/"`), but the preview message is stale.

Impact: User sees ".tad-backup/" in the plan, then if they look for their backup after the operation, it is at `.tad-migrate-backup/`. Confusion, not data loss.

Fix: Change L1022 to `echo "  1. Backup existing .tad/ to .tad-migrate-backup/"`.

### P2

**P2-1: Engine `--source` points to `$src` which is `$TAD_SRC` ("TAD-main" temp dir)**

In tad.sh the engine is called as `bash "$engine" ... --source "$src"` where `$src = $TAD_SRC = "TAD-main"`. The engine reads manifests from `$source/.tad/migrations/`. After `copy_framework_files`, the migrations dir also exists at the target (`.tad/migrations/`). This dual-availability is fine and engine correctly uses --source for manifest lookup, but worth noting that the temp dir `TAD-main` is cleaned up at L1334 (`rm -rf "$TAD_SRC"`). This is safe because engine runs synchronously before cleanup. No action needed.

**P2-2: Handoff document says "step3.b2" but implementation uses "step3.b3"**

The handoff document (sections 1.1, 3.1 FR2, 4.4, Phase 2 deliverables) references "step3.b2" for the migration engine call. Blake correctly identified that b2 was already taken by Capability Pack installation and numbered it b3. This is a doc-vs-impl naming divergence that is correct in implementation but could confuse future readers of the handoff. No code fix needed; documenting for clarity.

---

## Architecture Assessment

The integration is clean and well-structured:

1. **Single responsibility**: `call_migration_engine()` is a thin wrapper that handles only invocation + exit code routing. No migration logic leaks into tad.sh.

2. **Defensive guards**: Three-layer skip logic (old_ver="none", old_ver=new_ver, engine binary missing) ensures graceful degradation in all edge cases.

3. **ERR trap safety**: The `|| engine_rc=$?` pattern is the correct bash 3.2 approach. Comment at L695-696 accurately documents why `set +e` is insufficient.

4. **Ordering invariant**: Engine call placement (after copy, before version.txt write) satisfies both the "engine binary must exist" constraint and the "version.txt reflects success" semantic.

5. **sync-protocol alignment**: b3 step mirrors tad.sh semantics exactly. The PRESERVE entry correctly identifies `.tad-backup/` as target-side-only (never synced from source to target).

---

## Verdict

**PASS** with 1 P1 (stale user message at L1022). No blocking issues. Architecture constraints fully satisfied.
