# Phase 3 Design Review — Dual-Caller Integration (Updated)

**Reviewer**: Code Review Agent (shell-portability + integration-architect)
**Date**: 2026-06-10
**Handoff**: HANDOFF-20260610-dual-caller-integration-phase3.md
**Grounding**: phase3-grounding.md + tad.sh source (L670-900, L1090-1280) + migration-engine.sh (L1-50, L840-897) + derive-sync-set.sh (L1-100)

---

## Summary

The handoff designs the integration of migration-engine.sh into two upgrade paths (tad.sh remote install and *sync local protocol). The overall architecture is sound: both callers converge on the same engine binary with identical argument patterns, exit code handling is explicitly mapped, and the version-capture timing is correct (CURRENT_VERSION captured at L894, copy_framework_files at L1133/1209 -- variable is a shell snapshot unaffected by file overwrite). However, there are critical issues with ERR trap handling, a data-loss scenario in the migrate case, and AC verifiability gaps.

---

## P0 -- Critical (Must Fix Before Implementation)

### P0-1: `set +e` Does NOT Suppress ERR Trap in bash 3.2 -- Will Trigger rollback_on_failure

**Location**: Handoff section 4.2 (call_migration_engine function body), tad.sh L818

**Problem**: The handoff proposes:
```bash
set +e
bash "$engine" --from "$old_ver" --to "$new_ver" --target . --source "$src"
engine_rc=$?
set -e
```

tad.sh L818 sets `trap 'rollback_on_failure' ERR`. In bash 3.2 (macOS system bash, /usr/bin/bash), `set +e` disables the `errexit` built-in but does NOT suppress an already-armed `trap ... ERR`. The ERR trap fires on any command returning non-zero UNLESS the command is in a conditional context (part of `if`, `while`, `until`, or followed by `||`/`&&`).

This means: if the engine returns exit 1 or exit 2, the ERR trap fires FIRST (calling `rollback_on_failure` which does `rm -rf .tad; mv "$BACKUP_PATH" .tad; exit 1`), BEFORE `engine_rc=$?` ever executes. The copy_framework_files output is destroyed. The "graceful degradation" the handoff designs is actually a destructive rollback.

**Evidence**: bash 3.2.57 manual: "The ERR trap is not executed if the failed command is part of the command list immediately following a while or until keyword, part of the test in an if statement, part of a command executed in a && or || list."

**Risk**: On macOS (the primary TAD user platform), engine exit 1/2 causes tad.sh to rollback the entire installation -- the opposite of the intended behavior. Users lose their freshly-copied framework files.

**Fix**: Replace `set +e / set -e` with a pattern that places the engine call in a conditional context:
```bash
local engine_rc=0
bash "$engine" --from "$old_ver" --to "$new_ver" --target . --source "$src" || engine_rc=$?
```
Or:
```bash
local engine_rc=0
if ! bash "$engine" --from "$old_ver" --to "$new_ver" --target . --source "$src"; then
    engine_rc=$?
fi
```
Both patterns suppress the ERR trap by placing the command in a `||`/`if` context. The `set +e`/`set -e` pattern ONLY works reliably in bash 4.1+ where `set +e` also suppresses ERR trap.

### P0-2: `.tad-backup/` Directory Collision in "migrate" Case -- DATA LOSS RISK

**Location**: tad.sh L1158-1161, Handoff section 4.2 (migrate case call site), section 10.2

**Problem**: The "migrate" case (L1153) does:
```bash
if [ -d ".tad-backup" ]; then
    rm -rf .tad-backup          # L1158-1159: Destroys ENTIRE .tad-backup/ tree
fi
cp -r .tad .tad-backup          # L1161: Creates flat backup of .tad/
```

Then after copy_framework_files (L1209), the handoff inserts `call_migration_engine`. The engine creates per-version backups at `.tad-backup/{from}-to-{to}/MIGRATION-REPORT.tsv`.

Scenario: User runs `tad.sh --yes` (migrate path) twice:
1. First run: L1158 no-ops (no .tad-backup), L1161 creates backup, engine creates `.tad-backup/2.26.0-to-2.27.0/`
2. Second run: L1158 `rm -rf .tad-backup` destroys EVERYTHING including engine's per-version backup from run 1

The engine's exit-1 warn message says "Backup exists in .tad-backup/ for recovery" -- this is now a lie after the second migrate run.

The handoff acknowledges this in section 10.2 and says "actually safe (deletion happens before engine)" but misses the cross-run recovery scenario. A user who encounters engine exit-1, doesn't fix the issue, and runs tad.sh again will lose their engine backup.

**Risk**: Loss of engine-created migration backups on repeated migrate runs. User cannot recover from a failed migration if they retry.

**Fix**: Either:
(a) Rename the migrate case's backup to `.tad-v1x-migration-backup.{timestamp}` (separate namespace from engine)
(b) Have the engine check for existing `.tad-backup/` contents before starting and refuse if it finds non-engine data
(c) At minimum: change the warn text in call_migration_engine to NOT promise recovery when ACTION="migrate", and add a prominent comment at L1158 documenting the collision

---

## P1 -- Important (Should Fix)

### P1-1: migration-engine.sh Uses bash 4+ Arrays but tad.sh Invokes It with System bash

**Location**: migration-engine.sh L669, L699, L855, L861-862; tad.sh L7 (`set -euo pipefail` confirms bash invocation context)

**Problem**: migration-engine.sh uses:
- `CHAIN_MANIFESTS=()` (L669) -- empty array initialization
- `CHAIN_MANIFESTS+=("$mf")` (L699) -- array append with `+=`
- `${#CHAIN_MANIFESTS[@]}` (L855) -- array length
- `local parsed_data=()` (L861)
- `for mf in "${CHAIN_MANIFESTS[@]}"` (L862, L869)

All of these require bash 4+. The `+=` append syntax for arrays was introduced in bash 3.1, but `local arr=()` within functions has edge-case bugs in bash 3.2.

The proposed `call_migration_engine()` invokes: `bash "$engine" ...`. On macOS with system bash, this resolves to `/usr/bin/bash` (3.2.57). If the user's PATH has Homebrew bash first, `bash` resolves to bash 5.x and works fine. But for users without Homebrew bash, this WILL fail with syntax errors.

**Risk**: Engine fails with cryptic array-related errors on macOS systems using only system bash. No clear error message to the user.

**Fix**: Either:
(a) Add a bash version check at the top of migration-engine.sh: `if ((BASH_VERSINFO[0] < 4)); then printf 'ERROR: migration-engine requires bash 4+\n' >&2; exit 2; fi`
(b) Or in `call_migration_engine`, attempt to find bash 4+ before invoking: `local bash_bin; bash_bin="$(command -v bash)"; if ! "$bash_bin" --version | grep -qE 'version [4-9]'; then log_warn "Bash 4+ required for migration engine"; return 0; fi`
(c) Document this as a known requirement -- if Phase 2 already addressed it, reference the solution

### P1-2: AC5 (Zero Dual-Implementation) Expected Output Is Wrong

**Location**: Handoff section 9.1, AC5

**Problem**: AC5 verification:
```bash
grep -n 'rm.*migration\|mv.*migration\|rm.*\.tad/hooks/old\|rm.*deprecated' tad.sh | grep -v '#' | grep -v 'call_migration_engine' | wc -l
```
Expected output: `0`

The handoff note says: "False positives from existing apply_deprecations are expected." But if false positives are expected, the expected value CANNOT be 0. Running this pattern against the current tad.sh:
- L726: `rm -rf -- "$target"` (inside apply_deprecations, but the `grep -v '#'` won't filter it because it's code, not a comment)
- The pattern `rm.*deprecated` would NOT match L726 (no "deprecated" on that line)
- Pattern `rm.*migration` would NOT match (no "migration" in apply_deprecations)

Testing more carefully: the grep patterns are `rm.*migration`, `mv.*migration`, `rm.*\.tad/hooks/old`, `rm.*deprecated`. In current tad.sh, L726 has `rm -rf -- "$target"` inside apply_deprecations -- no substring "deprecated" or "migration" on that line itself. So the AC5 expected value of 0 MAY be correct for the current codebase. But the handoff note about "expected false positives" is misleading -- there may not actually be any.

**Fix**: Blake should run AC5 against the CURRENT (pre-modification) tad.sh to establish the true baseline. If baseline is already 0, the AC is correct. If non-zero, adjust. The handoff note about "expected false positives" should be verified or removed.

### P1-3: CURRENT_VERSION Not Trimmed at Read Site (tad.sh L894-895)

**Location**: tad.sh L894-895

**Problem**: 
```bash
CURRENT_VERSION=$(cat .tad/version.txt)
```

No `head -1` or `tr -d '[:space:]'` is applied. Compare with how `apply_deprecations` reads it (L685):
```bash
current_version=$(head -1 .tad/version.txt | tr -d '[:space:]')
```

The command substitution `$(cat ...)` strips trailing newlines (bash behavior), so a normal version.txt ending with `\n` is safe. But if version.txt has leading/trailing spaces, extra lines, or CRLF line endings (possible if edited on Windows), CURRENT_VERSION will carry garbage into the engine's `--from` argument.

The handoff section 8.3 claims: "CURRENT_VERSION contains spaces/special chars: version_le and engine both handle via tr -d '[:space:]'". But this is NOT true for the engine -- `parse_args` does `FROM_VER="$2"` with zero trimming.

**Risk**: Corrupted `--from` argument if version.txt has unexpected whitespace. The engine would fail to find manifests (no match for "2.26.0 " vs "2.26.0") and exit 0 (no manifests) -- silently skipping migration.

**Fix**: Add trimming in `call_migration_engine`:
```bash
old_ver="$(printf '%s' "$old_ver" | tr -d '[:space:]')"
new_ver="$(printf '%s' "$new_ver" | tr -d '[:space:]')"
```
Or fix at the source (L895): `CURRENT_VERSION=$(head -1 .tad/version.txt | tr -d '[:space:]')`

### P1-4: sync-protocol.md step3.b Still Has Hardcoded 14-Dir Allow-List

**Location**: sync-protocol.md L92-128

**Problem**: The sync-protocol.md step3.b (L92-128) contains a hardcoded list of 14 framework directories. This contradicts the project principle "Deny-List Beats Allow-List for Sync Sets" (principles.md). The handoff adds step3.b2 (migration engine) after this section but does not fix or flag this stale allow-list.

This is not Phase 3's job to fix, but the handoff should carry-forward this inconsistency. Without doing so, Blake may assume the listed directories are authoritative and make decisions based on a stale list.

**Fix**: Add to section 10.2 (Known Constraints): "sync-protocol.md step3.b still shows a hardcoded dir list -- derive-sync-set.sh --dirs is the authoritative source of truth. The stale list is a known inconsistency to be cleaned up separately."

### P1-5: tad.sh:721 Comment Fix -- Line Number Will Shift After Function Insertion

**Location**: Handoff section 4.2 modification point 3, AC6/AC7

**Problem**: The handoff instructs fixing L721. After inserting `call_migration_engine()` (~25-40 lines) in the "~L670 area" (per handoff instruction), the comment at L721 will shift to approximately L745-760. AC6/AC7 use `sed -n '715,725p'` which will be wrong post-insertion.

The handoff's micro-task ordering (section 6.1) has task #1 = "Add call_migration_engine() function" and task #4 = "Fix L721 comment". If Blake follows this order, by the time task #4 runs, L721 is no longer at line 721.

**Fix**: Either (a) reorder: fix L721 comment FIRST (task #4 before task #1), or (b) instruct Blake to search by content (`grep -n 'lexicographic' tad.sh`) rather than by line number. Also note that AC6/AC7 sed ranges must be re-calibrated after all modifications.

---

## P2 -- Suggestions (Consider)

### P2-1: sync-protocol.md PRESERVE List Missing 2 Zero-Touch Dirs

derive-sync-set.sh ZERO_TOUCH has 9 entries (project-knowledge, active, archive, evidence, pair-testing, decisions, github-registry, research-notebooks, skillify-candidates). sync-protocol.md PRESERVE (L192-200) lists only 7 (missing research-notebooks, skillify-candidates). Adding .tad-backup/ to PRESERVE (as Phase 3 proposes) is correct but does not fix the existing gap. Worth noting as a carry-forward.

### P2-2: AC12 Only Checks Existence of `set +e`, Not Correct Positioning

AC12 verifies `grep -c 'set +e'` >= 1 in the function body. This would pass even if `set +e` appeared AFTER the bash invocation line. A more robust check would verify ordering: set +e/`||` comes before `bash "$engine"`, then set -e/result capture comes after.

### P2-3: No AC for Version-Capture Timing (Most Critical Invariant Has No Gate)

The handoff's most critical safety property is: `CURRENT_VERSION` is read BEFORE `copy_framework_files`. There is no AC that mechanically verifies this ordering. An AC like:
```bash
awk 'BEGIN{cap=0; copy=0} /CURRENT_VERSION=\$\(cat/{cap=NR} /copy_framework_files.*TAD_SRC/{if(!copy)copy=NR} END{print (cap>0 && copy>0 && cap<copy) ? "PASS" : "FAIL"}'  tad.sh
```
...would verify the capture occurs before the first copy call. Consider adding this as AC18.

### P2-4: Engine Path Depends on $TAD_SRC Not Being Cleaned Up

`call_migration_engine` locates the engine at `$src/.tad/hooks/lib/migration-engine.sh`. The cleanup at L1280 (`rm -rf "$TAD_SRC"`) happens AFTER the case block closes. If future refactoring moves cleanup earlier, the engine invocation will silently fail (file not found -> log_warn + return 0). Consider adding a defensive comment at the `rm -rf "$TAD_SRC"` line: "# MUST remain AFTER engine call -- engine binary is invoked from this path".

### P2-5: Fixture Naming Should Be Definitive

The handoff offers multiple naming options (test-15-tad-upgrade-engine-call.sh OR test-15-dual-caller-integration.sh). Pick one definitively to save Blake decision time. Suggest: `test-15-dual-caller-integration.sh` (covers all sub-tests in one file, matching the combined scope).

### P2-6: `((errors++))` Pattern in validate_generated_configs (L759-784) Is bash 4+ but Not Flagged

tad.sh L759-784 already uses `((errors++))` which can fail in bash 3.2 under `set -e` when `errors` is 0 (because `((0++))` returns 1 in bash 3.2, triggering ERR trap). This is a pre-existing issue not introduced by Phase 3, but Blake should be aware if they touch validate_generated_configs. Not Phase 3's scope.

---

## Verification: Specific Review Focus Questions

### Q1: Does tad.sh capture old_version BEFORE copy_framework_files overwrites version.txt?

**YES.** tad.sh L894-895:
```bash
CURRENT_VERSION=$(cat .tad/version.txt)
```
This executes at the top of `main()`, BEFORE the download (L1004), before `copy_framework_files` (L1038/1133/1209). The shell variable `$CURRENT_VERSION` is a snapshot unaffected by subsequent file copies. The handoff correctly identifies this in section 4.5.

### Q2: Is the ERR trap handled correctly (set +e around engine call)?

**NO.** The `set +e` pattern does NOT suppress ERR trap in bash 3.2. See P0-1 above. The correct pattern is `cmd || rc=$?` or `if ! cmd; then rc=$?; fi`.

### Q3: Are all ACs mechanically verifiable?

**MOSTLY.** AC1-4, AC6-11, AC14-17 are mechanically verifiable. AC5 has a potential baseline calibration issue (P1-2). AC12 checks existence but not ordering. AC13 is valid. Missing: an AC for version-capture timing (P2-3).

### Q4: Does the .tad-backup/ exclusion actually work given it is at PROJECT ROOT not under .tad/?

**YES, the exclusion is CORRECTLY analyzed.** The handoff's section 4.3 analysis is accurate: `.tad-backup/` is at project root, derive-sync-set.sh only scans `.tad/*/`, so it's invisible to the derive pipeline. The sync-protocol PRESERVE list is the correct place to document it (advisory for Alex during *sync). No mechanical exclusion needed in derive-sync-set.sh.

### Q5: Is tad.sh:721 comment fix included?

**YES.** Section 4.2 modification point 3 and AC6/AC7 explicitly cover it. The fix changes "lexicographic is fine for semver with fixed digits" to "version_le uses sort -V". Caveat: line numbers will shift after function insertion (P1-5).

---

## Summary Counts

| Severity | Count | IDs |
|----------|-------|-----|
| P0 | 2 | P0-1 (ERR trap not suppressed by set +e in bash 3.2), P0-2 (.tad-backup collision in migrate) |
| P1 | 5 | P1-1 (engine needs bash 4+), P1-2 (AC5 baseline), P1-3 (untrimmed version), P1-4 (stale allow-list not flagged), P1-5 (line number shift) |
| P2 | 6 | P2-1 through P2-6 |

---

## Gate Recommendation

**CONDITIONAL PASS** -- Proceed to implementation AFTER resolving:

1. **P0-1 (BLOCKING)**: Replace `set +e`/`set -e` with `bash "$engine" ... || engine_rc=$?` pattern in the handoff's function template. This is a correctness issue on the primary user platform (macOS).

2. **P0-2 (BLOCKING)**: Decide on the `.tad-backup/` collision resolution:
   - Option A (recommended): Rename migrate-case backup to `.tad-v1x-backup.{timestamp}` 
   - Option B: Add comment + adjust warn text to say "Backup MAY NOT exist if tad.sh was re-run"
   - Option C: Move engine call BEFORE the rm/cp block (but this conflicts with "engine available after copy" constraint)

3. **P1-1 through P1-5**: Can be resolved during implementation provided Blake is informed. Add a "Blake Implementation Notes" addendum to the handoff with these items.
