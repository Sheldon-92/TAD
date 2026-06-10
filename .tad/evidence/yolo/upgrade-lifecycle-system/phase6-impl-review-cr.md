# Phase 6 Implementation Review — Code Quality & Correctness

**Date**: 2026-06-10
**Reviewer**: code-quality-reviewer
**Scope**: .tad/tests/upgrade-acceptance.sh, .tad/tests/gate-exercise.sh, .tad/evidence/acceptance-tests/upgrade-lifecycle/

## Summary

Phase 6 delivers two well-structured verification scripts (255 + 153 lines) and a clean evidence directory with chain dry-run proof. Both scripts pass `bash -n` syntax checks, the fixture harness passes 22/22, and the gate exercise correctly detects an unmanifested delete (exit 1 + "UNMANIFESTED DELETE" in output). Code is clean, idiomatic shell with proper `set -euo pipefail`, trap cleanup, and macOS-compatible grep patterns (no `grep -P`). The README documents merge-strategy projects and the warn-to-hard-block recommendation as required.

## Verification Results

| Check | Result |
|-------|--------|
| `bash -n upgrade-acceptance.sh` | PASS (exit 0) |
| `bash -n gate-exercise.sh` | PASS (exit 0) |
| gate-exercise.sh outputs PASS + contains "UNMANIFESTED DELETE" | PASS |
| chain-dry-run-output.txt exists and shows exit 0 | PASS (12 manifests resolved) |
| README documents merge-strategy projects | PASS (3 projects: openclaw, toy, memory-management) |
| Fixtures 22/22 | PASS |

---

## P0 — Critical Issues (Must Fix)

**None found.**

All core functionality works correctly. Scripts produce correct exit codes for their primary paths, the gate exercise proves non-theater, and evidence artifacts are complete.

---

## P1 — Important Issues (Should Fix)

### P1-1: Unguarded `$2` access in argument parsing causes cryptic error under `set -u`

**Files**: upgrade-acceptance.sh L51-54, gate-exercise.sh L25

**Problem**: When an argument flag is provided as the last positional parameter without a value (e.g., `bash upgrade-acceptance.sh --target`), the `$2` reference triggers an "unbound variable" error from `set -u` with exit code 1 instead of producing a clean usage message with exit code 2.

**Observed**:
```
$ bash upgrade-acceptance.sh --target
.tad/tests/upgrade-acceptance.sh: line 51: $2: unbound variable
EXIT:1
```

Expected: `ERROR: --target requires a value` followed by usage text, exit 2.

**Impact**: Minor UX issue — the user gets a confusing internal bash error instead of actionable guidance. The exit code 1 also conflates "usage error" with "verification failure" contrary to the exit code contract (0=pass, 1=fail, 2=usage).

**Fix** (upgrade-acceptance.sh, apply similar to gate-exercise.sh):
```bash
while [ $# -gt 0 ]; do
  case "$1" in
    --target)
      [ $# -ge 2 ] || { printf 'ERROR: %s requires a value\n' "$1" >&2; usage; exit 2; }
      TARGET="$2"; shift 2 ;;
    --expected-version)
      [ $# -ge 2 ] || { printf 'ERROR: %s requires a value\n' "$1" >&2; usage; exit 2; }
      EXPECTED_VERSION="$2"; shift 2 ;;
    # ... same for --snapshot and --expect-migration-from
```

### P1-2: deprecation.yaml parsed relative to SCRIPT_DIR, but target's own deprecation.yaml is ignored

**File**: upgrade-acceptance.sh L20

**Problem**: `DEPRECATION_YAML="$SCRIPT_DIR/../deprecation.yaml"` always reads the SOURCE repo's deprecation.yaml (relative to the script's installed location). When the script is distributed to and run from a target project, this works correctly because the script lives inside `.tad/tests/`. However, if the user copies the script elsewhere or runs it in a context where the relative path resolves differently, the wrong deprecation.yaml would be used.

**Current mitigation**: The script is designed to be run in-place inside `.tad/tests/`, so relative pathing is correct for the primary use case.

**Recommendation**: Add a comment clarifying this coupling, or accept `--deprecation-yaml` as an optional override. Low severity because the intended usage pattern always resolves correctly.

---

## P2 — Suggestions (Consider)

### P2-1: The deprecated-files check legitimately fails on the source TAD repo

**File**: upgrade-acceptance.sh, check_deprecated()

**Context**: Running `upgrade-acceptance.sh --target .` against the TAD source repo correctly detects AGENTS.md and .codex/ as stale deprecated files. The completion report documents this as "working as designed" since the script is meant for TARGET projects, not the source.

**Suggestion**: Consider adding a `--source-repo` flag or detecting `.tad/hooks/lib/migration-engine.sh` presence to emit a warning: "You appear to be running against the source repo — deprecated files in source are expected." This would prevent confusion during self-testing.

### P2-2: gate-exercise.sh uses `cd "$TMP_DIR"` which changes the working directory permanently

**File**: gate-exercise.sh L69

**Context**: After `cd "$TMP_DIR"`, the script operates in the temp dir for the remainder. This is fine because: (a) the temp dir is cleaned up by trap, and (b) the script doesn't need to return to the original directory. However, a subshell `(cd "$TMP_DIR" && ...)` would be slightly more defensive.

**Impact**: None in practice — the script exits after completing and the trap cleans up. Style preference only.

### P2-3: awk state machine doesn't reset `in_version` flag

**File**: upgrade-acceptance.sh L167

**Context**: The `in_version=1` flag is set but never reset (unlike `in_files` which resets at L176). This works because `in_version` is never tested conditionally — it only serves as implicit documentation. The `in_files` state machine is the load-bearing one and it correctly resets.

**Impact**: None — the awk logic is correct. The unused flag is just noise.

### P2-4: Evidence directory contains 4 files but AC15 expects 3

**File**: .tad/evidence/acceptance-tests/upgrade-lifecycle/

**Context**: The evidence dir has 4 files (fixture-run-output.txt, gate-exercise-output.txt, chain-dry-run-output.txt, README.md) but AC15 in the handoff says "3 files". The completion report correctly notes 4 files ("3 required + 1 bonus"). The chain-dry-run-output.txt is the P0-1 evidence added beyond the original spec. AC15 uses `wc -l` which would return 4, not 3 — the AC was validated against `>= 3` (which passes).

**Impact**: None — the extra evidence is a bonus, not a violation.

---

## Positive Observations

1. **Correct `local` + command substitution pattern** (L117-121): Declares `local zt_dirs` separately from the assignment, avoiding the well-known bash pitfall where `local var=$(cmd)` masks the command's exit code.

2. **Idiomatic error handling**: Both scripts use `set -euo pipefail` and `|| { ... }` patterns consistently. The gate-exercise.sh correctly captures the exit code with `|| gate_rc=$?` to avoid triggering `set -e`.

3. **trap cleanup in gate-exercise.sh** (L60): `trap 'rm -rf "$TMP_DIR"' EXIT` ensures cleanup even on assertion failures — exactly what the handoff required.

4. **No grep -P anywhere**: Both scripts are fully macOS/BSD compatible. Only `grep -q` used, which is POSIX.

5. **Clear output formatting**: PASS/FAIL/SKIP with color codes (only when terminal supports) makes output human-readable.

6. **diff -rq for ZERO_TOUCH verification**: Uses the principle-prescribed omission catcher, not presence-only checks.

7. **Chain dry-run evidence is thorough**: 12 manifests resolved with correct already-applied detection for v2.25.0-to-v2.26.0.

---

## Verdict

**PASS with 2 P1 items (non-blocking for acceptance).**

P1-1 (unguarded `$2`) is a UX polish issue that only manifests on malformed invocations — all documented usage patterns work correctly. P1-2 is a coupling comment, not a functional defect. Neither blocks the Epic completion. Fix P1-1 in the next maintenance pass.
