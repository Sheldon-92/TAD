# Phase 3 Design Review — Backend Architecture Perspective (v2 — Re-review)

**Reviewer**: integration-architect (backend architecture focus)
**Date**: 2026-06-09 (v2 re-review)
**Handoff**: HANDOFF-20260610-dual-caller-integration-phase3.md
**Grounding**: phase3-grounding.md, tad.sh (1310 lines, full read L50-1310), migration-engine.sh L1-55 + L840-897
**Scope**: Blast radius, ordering constraints, error handling, dual-caller consistency, backward compatibility

---

## Summary Verdict

**2 P0, 4 P1, 4 P2**

The design is fundamentally sound -- the ordering is correct, the exit-code matrix is well-reasoned, and the "zero dual-implementation" constraint is properly enforced. The two P0 findings relate to: (1) the ERR-trap suppression mechanism prescribed (`set +e`) being unreliable on bash 3.2, and (2) a latent `.tad-backup/` namespace collision in the "migrate" case that needs explicit resolution. Recommend fixing both P0s in the handoff before Blake begins implementation.

---

## 1. Blast Radius Analysis

### What breaks if engine fails mid-way in tad.sh?

**Failure scenario**: Engine exits 1 (fail-fast during execution). At this point:
- `backup_existing()` has already created `.tad.backup.{timestamp}` (L115-124)
- `copy_framework_files` has already completed (new framework files are in place)
- `apply_deprecations` has already run (called inside copy_framework_files at L474)
- `verify_install_complete` has already passed (called inside copy_framework_files at L555)
- `version.txt` has NOT yet been written at L1150/1269 (comes after engine call)

**If ERR trap fires (the P0-1 scenario)**:
`rollback_on_failure()` (L797-808) executes `rm -rf .tad && mv "$BACKUP_PATH" .tad`, destroying all successfully copied framework files and reverting to the pre-upgrade backup. The user sees "Installation failed. Rolling back..." for what was actually a successful copy with a non-critical engine warning.

**If ERR trap is correctly suppressed**:
The user has new framework files in place, old deprecated files removed, engine backup at `.tad-backup/{from}-to-{to}/`, but version.txt not yet written. Next steps continue (version.txt write, validate_generated_configs, cleanup). This is the intended behavior.

**Residual risk for engine exit 1**: If engine exit 1 means a PARTIAL migration (some deletes executed, some not), the user has a hybrid state. The engine backup directory allows manual recovery. This is acceptable -- the user gets new files but some dead files remain, which is strictly better than a full rollback.

---

## 2. Ordering Constraints

### Proposed tad.sh path:
```
detect_state + capture CURRENT_VERSION (L892-896)
  --> backup_existing (timestamped .tad.backup)
    --> download + extract to $TAD_SRC
      --> copy_framework_files (includes apply_deprecations@L474 + verify_install_complete@L555)
        --> call_migration_engine  <-- PROPOSED INSERTION
          --> echo TARGET_VERSION > .tad/version.txt (L1150/1269)
            --> validate_generated_configs
              --> rm -rf $TAD_SRC (L1280)
```

### Correctness assessment:

| Constraint | Status | Detail |
|-----------|--------|--------|
| old_version captured before copy overwrites version.txt | CORRECT | CURRENT_VERSION set at L894, before copy at L1133/1209 |
| engine binary available at call time | CORRECT | Design uses `$src/.tad/hooks/lib/migration-engine.sh` (source dir) |
| apply_deprecations (frozen <=v2.26.0) runs before engine (v2.27.0+) | CORRECT | apply_deprecations at L474 inside copy_framework_files; engine call is after copy returns |
| version.txt not yet updated when engine runs | CORRECT | version.txt write at L1150/1269 is after engine call |
| verify_install_complete runs before engine | ACCEPTABLE | verify at L555 checks new files landed; engine then deletes old files that are NOT in the new version |
| $TAD_SRC persists through engine execution | CORRECT | cleanup at L1280 is after the entire case block |

**Ordering verdict**: CORRECT. The engine AFTER copy but BEFORE verify_generated_configs is the right position.

---

## 3. Findings

### P0 (Must fix before implementation)

#### P0-1: `set +e` does NOT reliably suppress ERR trap on bash 3.2 -- use trap-swap or `|| rc=$?` pattern

**Location**: Handoff section 4.2 "Modification Point 2", the `call_migration_engine()` function design.

**Problem**: The handoff prescribes:
```bash
set +e
bash "$engine" --from "$old_ver" --to "$new_ver" --target . --source "$src"
engine_rc=$?
set -e
```

On bash 3.2 (macOS default -- the stated target per NFR1), the interaction between `set +e` and `trap ... ERR` has a known behavioral difference from bash 4+. Specifically:

1. In bash 4+: `set +e` reliably prevents ERR trap from firing on non-zero exit codes.
2. In bash 3.2: The ERR trap behavior under `set +e` is less well-defined and has been observed to still fire in certain pipeline/subshell contexts.

More critically: even if `set +e` works correctly on bash 3.2 for simple commands, the `set +e / set -e` window creates a scope where ANY failure is silently swallowed -- including failures of code a future maintainer might insert between the lines.

The SAFE and PORTABLE alternative is the `|| rc=$?` idiom:
```bash
local engine_rc=0
bash "$engine" --from "$old_ver" --to "$new_ver" --target . --source "$src" || engine_rc=$?
```

Under POSIX and all bash versions: `cmd || other` does NOT trigger the ERR trap because the overall expression succeeds (the `||` branch executes). This is guaranteed behavior, not version-dependent.

Alternatively, the explicit trap-swap pattern:
```bash
local engine_rc=0
trap - ERR
bash "$engine" --from "$old_ver" --to "$new_ver" --target . --source "$src" || engine_rc=$?
trap 'rollback_on_failure' ERR
```

**Blast radius if unfixed**: Complete loss of the upgrade on bash 3.2 when engine returns non-zero. The user's `.tad/` is rolled back to the pre-upgrade backup, but the new version's files (just successfully copied) are destroyed. User sees "Installation failed. Rolling back..." for what should be a non-critical warning.

**Recommended fix**: Replace `set +e / set -e` with `|| engine_rc=$?` (single line, zero scope expansion, portable).

**Severity justification**: P0 because the prescribed mechanism can trigger data-destructive rollback on the stated target platform (bash 3.2 / macOS). The handoff correctly identifies the ERR trap risk in section 10.1 but prescribes a solution that does not reliably address it.

---

#### P0-2: "migrate" case: `.tad-backup/` namespace collision between v1.x full-tree backup and engine per-version backup

**Location**: tad.sh L1158-1161 (existing "migrate" case code) + proposed engine call insertion.

**Problem**: The "migrate" case has this sequence:
```
L1158: if [ -d ".tad-backup" ]; then rm -rf .tad-backup; fi
L1161: cp -r .tad .tad-backup    <-- FULL .tad clone
...
L1209: copy_framework_files "$TAD_SRC"
(proposed): call_migration_engine  --> creates .tad-backup/{from}-to-{to}/MIGRATION-REPORT.tsv
```

The `.tad-backup/` directory after engine execution contains:
- A full clone of the OLD `.tad` tree (from L1161) -- potentially hundreds of files
- The engine's per-version surgical backup subdirectory (e.g., `.tad-backup/1.4.0-to-2.28.0/`)

This creates several issues:

1. **Recovery ambiguity**: If the user needs to recover, `.tad-backup/` is a confusing mix. The top-level clone and the engine's subdirectory serve different purposes with different recovery procedures.

2. **Future migrate re-run**: If a second "migrate" ever runs (e.g., interrupted first attempt), L1158 `rm -rf .tad-backup` wipes BOTH the full-tree backup AND any engine per-version backups from a previous partial run. The engine's backup -- which might be needed for recovery -- is destroyed.

3. **For v1.4/v1.6/v1.8 to current**: The engine will exit 0 (no manifests for this range), so the engine subdirectory is NOT created. The problem only manifests when manifests cover the version range, which is not the case today but WILL be in Phase 5+.

The handoff acknowledges this in section 10.2 ("Known Constraints") but classifies it as "safe because delete happens before engine runs." This is correct for the CURRENT single-manifest scenario, but creates a latent conflict that Phase 5/6 will hit.

**Recommended fix**: Either:
- (a) Rename the v1.x migrate backup: `cp -r .tad .tad-migration-backup.$(date +%Y%m%d_%H%M%S)` -- separating the v1.x structural backup namespace from the engine's `.tad-backup/` namespace, OR
- (b) Add an explicit AC + code comment documenting the dual-purpose nature and requiring Phase 5 to reconcile before generating manifests that cover v1.x -> v2.x range, OR
- (c) Have `call_migration_engine` in the "migrate" case use a different `--target` backup prefix (engine supports this implicitly via `--target` path -- the backup goes under `$TARGET/.tad-backup/`).

**Severity justification**: P0 because without resolution, a future Phase 5 manifest covering v1.4 -> v2.28.0 would create engine backups inside the full-tree clone, and a re-run would silently destroy the engine's recovery data. The handoff must prescribe a resolution before Blake implements.

---

### P1 (Should fix)

#### P1-1: sync-protocol step3.b has hardcoded 14-dir allow-list -- `.tad/migrations/` not listed

**Location**: sync-protocol.md L93-111 (step3.b "Framework files").

**Problem**: The handoff proposes adding step3.b2 (migration engine call) after step3.b. But step3.b itself still contains the old hardcoded 14-directory allow-list:
```
- .tad/agents/
- .tad/data/
- .tad/domains/
- .tad/gates/
- .tad/guides/
- .tad/hooks/
- .tad/ralph-config/
- .tad/references/
- .tad/schemas/
- .tad/skills/
- .tad/sub-agents/
- .tad/tasks/
- .tad/templates/
- .tad/workflows/
```

The `.tad/migrations/` directory is NOT in this list. In tad.sh, the deny-list derivation auto-includes `migrations/` (it is not in ZERO_TOUCH or TRANSIENT). But when Alex executes `*sync` manually following sync-protocol.md step3.b, the `migrations/` directory will NOT be copied to target projects.

**Consequence**: The engine call in step3.b2 will find no manifests (they were never copied to the target) and exit 0 ("no manifests found"). Migration silently becomes a permanent no-op on all `*sync`-managed projects.

**Note**: `migrations/` is under `.tad/hooks/` in the actual file tree -- wait, let me re-check. The grounding doc says manifests are at `$source/.tad/migrations/`. If this is a TOP-LEVEL `.tad/` subdirectory, the sync-protocol list is missing it. If it is under `.tad/hooks/lib/` or similar, then `.tad/hooks/` copy would include it.

From migration-engine.sh L852: `local migrations_dir="$SOURCE/.tad/migrations"` -- this is a top-level `.tad/` subdirectory. It is NOT under `.tad/hooks/`. The sync-protocol hardcoded list does not include it.

**Fix**: Add to the handoff Phase 2 deliverables: "Add `.tad/migrations/` to sync-protocol.md step3.b Framework subdirectories list." Or note that this is a known stale hardcoded list (per principles.md) and that tad.sh's deny-list derivation handles it correctly -- Alex should use `derive_framework_dirs` output as the authoritative list during `*sync`.

**Severity**: P1 because it causes `*sync` to silently skip manifest distribution, making engine calls a no-op on all downstream projects.

---

#### P1-2: Engine uses `CHAIN_MANIFESTS` array -- verify `resolve_chain` does not use bash 4+ features

**Location**: migration-engine.sh L853-858, not fully read.

**Problem**: The handoff's NFR1 requires bash 3.2 compatibility for tad.sh code. The `call_migration_engine` wrapper IS bash-3.2-safe. But the engine itself (invoked as a child process) uses arrays and potentially bash 4+ features. The engine starts with `#!/usr/bin/env bash` -- on macOS, this invokes `/bin/bash` (3.2) by default unless the user has Homebrew bash in PATH.

Indexed arrays (`arr=()`, `${arr[@]}`, `${#arr[@]}`) work on bash 3.2. BUT `readarray`/`mapfile` (bash 4+) do NOT. If `resolve_chain` uses `readarray`, the engine fails silently (command not found -> engine exits with error -> caller sees exit 1 or 127).

The handoff acknowledges bash 3.2 compat for NEW code but does not verify the engine (Phase 2 deliverable) was actually tested on bash 3.2.

**Fix**: Blake should verify: `grep -n 'readarray\|mapfile\|declare -A\|${.*,,}\|${.*^^}' .tad/hooks/lib/migration-engine.sh`. If any match, the engine needs a bash 3.2 compatibility fix. Add this as a pre-implementation verification step.

**Severity**: P1 because if the engine uses bash 4+ features, migration is a permanent no-op on stock macOS (engine fails, caller warns and continues).

---

#### P1-3: Version capture for "migrate" case -- CURRENT_VERSION may be a v1.x version string the engine cannot chain-resolve

**Location**: Handoff section 4.5 "Version Capture Timing".

**Problem**: For STATE="v1.4" (version.txt starts with "1.4"), CURRENT_VERSION = "1.4.x". The engine gets `--from 1.4.x --to 2.28.0`. The engine's `resolve_chain` looks for manifests named `{from}-to-{intermediate}.yaml` in `.tad/migrations/`. For v1.4 -> v2.28.0, there would need to be a chain like `1.4.0-to-2.0.0.yaml -> 2.0.0-to-2.26.0.yaml -> 2.26.0-to-2.27.0.yaml -> ...`.

Currently only `2.26.0-to-2.27.0.yaml` exists. The engine will find no chain and exit 0 (correct). The handoff correctly identifies this in the call_migration_engine guard: `if [ "$old_ver" = "none" ]; then return 0`.

BUT: the handoff does NOT add a guard for old_ver < "2.26.0". This means the engine is called for v1.4/v1.6/v1.8/v2.0 upgrades, runs `resolve_chain`, finds nothing, and exits 0. This is CORRECT behavior but WASTEFUL (the engine does file-system traversal of `.tad/migrations/` for no reason).

More importantly: if Phase 5 generates manifests with broad ranges (e.g., `2.0.0-to-2.26.0.yaml`), old v2.0 installs WOULD execute migration manifests. The handoff should document this is the INTENDED future behavior.

**Fix**: Add documentation note: "For 'migrate' case (v1.4/v1.6/v1.8 -> current), the engine finds no manifests and exits 0. This is expected. The v1.x -> v2.x structural migration is handled by existing migrate-case code (L1184-1198), not the engine. The engine is designed for v2.x -> v2.y+ delta migrations only (Phase 5+ will generate these manifests)."

**Severity**: P1 (documentation gap that could cause confusion + potential Phase 5 interaction).

---

#### P1-4: `$TAD_SRC` used as engine source but `$TAD_SRC` may be relative path

**Location**: tad.sh L1006 (`TAD_SRC="TAD-main"`), proposed engine call `bash "$engine" ... --source "$src"`.

**Problem**: `TAD_SRC` is set to `"TAD-main"` (a RELATIVE path). The engine receives `--source TAD-main`. Inside the engine, `SOURCE="TAD-main"` is used to construct `$SOURCE/.tad/migrations`. If tad.sh's working directory changes between L1006 and the engine call, the relative path breaks.

Currently, tad.sh does NOT `cd` between L1006 and L1133 (or L1209). The `copy_framework_files` function does not `cd` either. So the relative path resolves correctly.

But if Blake inserts the engine call AFTER `copy_framework_files` (which itself does not `cd`), the relative path `$TAD_SRC` = `"TAD-main"` still resolves from the project root (cwd). This is safe.

**Fix**: Defensive improvement: resolve `TAD_SRC` to absolute path at L1006:
```bash
TAD_SRC="$(cd TAD-main && pwd)"
```
This prevents any future `cd` from breaking the path. Minor effort, high defensiveness.

**Severity**: P1 (preventive -- no current bug, but fragile coupling to cwd stability).

---

### P2 (Nice to have)

#### P2-1: Exit code 127 (engine binary not found despite -f check) and 126 (permission denied) not explicitly documented

**Location**: Handoff section 4.2, `case $engine_rc in` block.

**Problem**: The wildcard `*)` case handles these, but the message "unexpected exit code" does not guide the user. Exit 127 from `bash "$engine"` would occur if `$engine` path resolves to a non-existent file (race condition with cleanup) or if bash itself cannot be found (impossible in practice).

**Fix**: The wildcard handler is sufficient. Optionally differentiate 127 with "engine binary not found".

---

#### P2-2: AC5 grep pattern for "zero dual-implementation" will produce false positives

**Location**: Handoff section 9.1, AC5.

**Problem**: `grep -n 'rm.*migration|mv.*migration|rm.*\.tad/hooks/old|rm.*deprecated' tad.sh | grep -v '#' | grep -v 'call_migration_engine' | wc -l` -- the expected result is 0. But `apply_deprecations` (L726) has `rm -rf -- "$target"` and the "migrate" case (L1159) has `rm -rf .tad-backup`. These will match `rm.*deprecated` or `rm.*migration` patterns depending on variable expansion context.

Since these are existing (not new) code, the AC note says "False positives from existing apply_deprecations are expected." But the expected result is "0" which contradicts this acknowledgment.

**Fix**: Change expected to "0 new matches" with baseline exclusion, or adjust the grep pattern.

---

#### P2-3: Subtle messaging asymmetry between tad.sh exit 2 ("consider clean reinstall") and *sync (no specific guidance)

**Location**: Handoff section 4.2 vs section 4.4.

**Problem**: tad.sh adds "If upgrading from a very old version, consider a clean reinstall" on exit 2. The *sync protocol says "Do NOT block sync." For *sync, "clean reinstall" makes less sense -- the user should re-sync after fixing the manifest.

**Fix**: Cosmetic. Accept as-is or tailor message per context.

---

#### P2-4: Version bump / CHANGELOG coordination not mentioned

**Location**: Not in handoff.

**Problem**: Phase 3 adds a new function to tad.sh. TARGET_VERSION and CHANGELOG updates are not mentioned. Since this is Phase 3/6 of an Epic, the bump likely happens at completion.

**Fix**: Add note: "Version bump deferred to Epic completion (Phase 6). Do NOT change TARGET_VERSION in this phase."

---

## 4. Exit Code Handling Assessment

| Exit Code | Meaning | tad.sh Handler | *sync Handler | Correct? |
|-----------|---------|---------------|---------------|----------|
| 0 | Success / no manifests | log_success, continue | continue | YES |
| 1 | Execution failure (fail-fast) | log_warn + mention backup, continue | WARN + continue | YES |
| 2 | Refuse (invalid/chain gap) | log_warn + suggest reinstall, continue | WARN, continue | YES |
| 127 | Binary not found | `*)` wildcard warn, continue | not explicitly handled | ACCEPTABLE |
| * | Unexpected | `*)` wildcard warn, continue | (implied) | YES |

All exit code cases are covered. The key design decision -- non-fatal for all engine exits -- is correct because copy has already completed.

---

## 5. Dual-Caller Consistency Assessment

| Aspect | tad.sh | *sync protocol |
|--------|--------|----------------|
| Binary | `$src/.tad/hooks/lib/migration-engine.sh` | `{TAD_SOURCE}/.tad/hooks/lib/migration-engine.sh` |
| --from | `$CURRENT_VERSION` (target version.txt pre-copy) | `{old_version}` (target version.txt pre-copy) |
| --to | `$TARGET_VERSION` | `{current_version}` |
| --target | `.` (cwd = project root) | `{target_project_path}` |
| --source | `$TAD_SRC` (temp download dir) | `{TAD_SOURCE}` (local TAD repo) |
| Non-fatal semantics | YES (warn + continue) | YES (WARN + continue) |
| Manifest source | `$TAD_SRC/.tad/migrations/` | `{TAD_SOURCE}/.tad/migrations/` |

**Consistency verdict**: Semantically identical. Both callers use the same binary, same argument pattern, same exit-code interpretation. The only difference is path provenance (temp vs persistent), which does not affect engine behavior.

**Gap**: The *sync path relies on `.tad/migrations/` being present in `{TAD_SOURCE}` (the TAD repo -- always true) AND in `{target_project_path}` (only if step3.b copies it). See P1-1.

---

## 6. Backward Compatibility Assessment

### No manifests for version range = graceful no-op?

**CONFIRMED**. From migration-engine.sh L855-858:
```bash
if [ ${#CHAIN_MANIFESTS[@]} -eq 0 ]; then
    printf 'No manifests found for %s -> %s\n' "$FROM_VER" "$TO_VER"
    exit 0
fi
```

Caller sees exit 0, logs "Migration completed successfully", continues. Zero side effects.

### Engine binary missing in older sources?

The guard `if [ ! -f "$engine" ]; then return 0` handles this. Since the engine is called from `$src` (the new version's source), the engine always exists if `call_migration_engine` exists. The guard handles corrupt/partial downloads only.

### Existing 14 fixtures regression?

The existing fixtures test migration-engine.sh directly (not through tad.sh). Adding `call_migration_engine` to tad.sh does not affect them. New Phase 3 fixtures will test the integration path.

---

## Architecture Assessment

The design follows the correct integration topology:

1. **Engine as library**: Both callers invoke the same binary with identical semantics -- no business logic leaks.
2. **Idempotency**: Engine's oracle check (L874-878) means re-running after failure is safe.
3. **Fail-open after copy**: Engine failure leaves "new version installed but uncleaned" state -- strictly better than pre-upgrade.
4. **Version capture timing**: Reading old version before copy and passing as parameter eliminates TOCTOU race.
5. **Separation of concerns**: apply_deprecations (frozen, <=v2.26.0) and migration-engine (v2.27.0+) have non-overlapping version domains.

---

## Final Recommendation

Fix P0-1 and P0-2 in the handoff before Blake begins:
- **P0-1**: Replace `set +e / set -e` with `|| engine_rc=$?` (one-line fix in the handoff's code block)
- **P0-2**: Prescribe `.tad-backup/` namespace resolution for "migrate" case (rename v1.x backup or document coexistence policy)

P1 items can be fixed during implementation without handoff revision.
