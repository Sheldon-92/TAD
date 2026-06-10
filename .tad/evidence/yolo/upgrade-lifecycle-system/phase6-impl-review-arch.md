# Phase 6 Implementation Review — Architecture

**Reviewer**: Architecture (backend systems, reliability, shell portability)
**Date**: 2026-06-10
**Scope**: gate-exercise.sh, upgrade-acceptance.sh, evidence/acceptance-tests/upgrade-lifecycle/

---

## Verification Method

All claims in COMPLETION-20260610-acceptance-phase6.md were independently verified:

1. **Gate exercise genuinely produces exit 1**: Ran `bash gate-exercise.sh` live. Confirmed: creates temp git repo, commits a file at v0.1.0, deletes without manifest at v0.2.0, release-verify.sh correctly exits 1 with "UNMANIFESTED DELETE" in output. Script exits 0 (PASS). No side effects on the source repo.

2. **Chain dry-run proves all 12 manifests parseable**: Created temp dir with version.txt=2.19.0, iterated all 12 manifests via migration-engine.sh --dry-run. All resolve successfully. Final version reaches 2.27.0. Exit 0.

3. **Evidence chain complete**: fixture-run-output.txt (22/22), gate-exercise-output.txt (PASS + "UNMANIFESTED DELETE"), chain-dry-run-output.txt (12 steps, exit=0), README.md (evidence index + recommendation + human steps). All 4 files present with correct content.

4. **README provides actionable human steps**: Merge-strategy section names 3 specific projects, gives the exact marker line to add (`<!-- TAD:PROJECT-CONTENT-BELOW -->`), explains where to place it, and specifies "re-run *sync" as the follow-up. Sufficient for a human to execute without additional context.

---

## P0 Findings

None.

---

## P1 Findings

### P1-1: upgrade-acceptance.sh detects source-repo deprecated files as FAIL (false positive when self-tested)

**Location**: `.tad/tests/upgrade-acceptance.sh` check_deprecated function
**Issue**: When the script is pointed at the TAD source repo itself (`--target .`), it correctly finds AGENTS.md and .codex/ — which are legitimately present in the SOURCE repo (they exist so they can be synced/referenced, and deprecation only applies to downstream projects). The completion report acknowledges this ("detection is working as designed") but the script has no way to distinguish "I am the source repo" from "I am a stale target". This means the script cannot be used as a self-test of the source repo without producing a FAIL verdict.

**Impact**: Operational confusion. A maintainer running `bash upgrade-acceptance.sh --target . --expected-version 2.27.0` as a sanity check will see FAIL. The completion report's AC6 marks this as PASS ("correct detection") which is technically right but could mislead future maintainers.

**Recommendation**: Add a `--source-repo` flag (or detect `.tad/migrations/` presence) that skips the deprecated-files check when running against the source, OR document this explicitly in the script header comment as expected behavior.

---

## P2 Findings

### P2-1: --zero-touch passes TARGET arg to derive-sync-set.sh but it is unused

**Location**: `.tad/tests/upgrade-acceptance.sh` line 118
**Code**: `zt_dirs="$(bash "$DERIVE" --zero-touch "$TARGET" 2>/dev/null)"`
**Issue**: `derive-sync-set.sh --zero-touch` at line 105 just prints the hardcoded `$ZERO_TOUCH` list (`printf '%s\n' "$ZERO_TOUCH" | LC_ALL=C sort`). The `$2` positional (ROOT) is only used by `--dirs` (via `emit_dirs`). Passing `$TARGET` is harmless but misleading — it implies the zero-touch list is derived from TARGET's structure when it is actually a fixed set.

**Impact**: None (the extra arg is silently ignored). Misleading to future readers.

**Recommendation**: Either remove the `"$TARGET"` argument from the call, or add a comment explaining it's passed for forward-compat if `--zero-touch` ever becomes target-aware.

### P2-2: check_deprecated awk parser does not handle unquoted YAML list entries

**Location**: `.tad/tests/upgrade-acceptance.sh` lines 166-177
**Issue**: The awk parser matches `^      - ` (6 spaces + dash + space) then strips quotes. The current deprecation.yaml uses both quoted (`".claude/commands/tad.md"`) and unquoted (`AGENTS.md`) entries. The parser handles both correctly today. However, if a future entry uses YAML flow syntax (`files: [a.md, b.md]`) or has a different indent (e.g., from a YAML editor auto-format), it will silently miss entries.

**Impact**: Low. The existing deprecation.yaml is human-maintained with consistent formatting. A `files: []` entry (v2.8.4) is already handled correctly (no output). This is a robustness concern for future evolution, not a current bug.

**Recommendation**: Add a comment in the awk block documenting the expected YAML format, or add a fallback that warns if `files:` is seen but no entries are extracted for a version block (detects format drift).

### P2-3: gate-exercise.sh creates 16 .tad/ subdirectories but only some are needed

**Location**: `.tad/tests/gate-exercise.sh` lines 76-91
**Issue**: The script creates 16 `.tad/` subdirectories to satisfy `derive-sync-set.sh`. Over time, if derive-sync-set.sh's DENY_LIST or emit_dirs changes, this static list may drift. The script works today because `release-verify.sh migration` only needs git history + a manifest lookup — the 16 dirs are defensive overkill.

**Impact**: None currently. Minor maintenance burden if `derive-sync-set.sh` starts requiring a specific structure.

**Recommendation**: Document which dirs are actually required (likely just `.tad/migrations/` and `.tad/hooks/lib/`) vs which are precautionary.

### P2-4: Evidence README "Engine Version: 2.29.0" vs "TAD Version: 2.27.0" — version semantics could confuse readers

**Location**: `.tad/evidence/acceptance-tests/upgrade-lifecycle/README.md` line 8
**Issue**: Two different version numbers in the header (TAD 2.27.0, Engine 2.29.0) without explaining the relationship. A reader unfamiliar with the system might wonder why the engine version is higher than the framework version.

**Impact**: Documentation clarity only.

**Recommendation**: Add a one-line note: "Engine Version is the migration-engine.sh internal version (independent of TAD release version)."

---

## Summary

| Severity | Count | Verdict |
|----------|-------|---------|
| P0 | 0 | -- |
| P1 | 1 | Addressable in post-Epic polish |
| P2 | 4 | Low-priority improvements |

**Overall assessment**: The Phase 6 implementation is architecturally sound. The gate exercise is GENUINE — it creates real git state, provokes a real exit 1 from release-verify.sh, and verifies the failure message. The evidence chain is complete and independently reproducible. The chain dry-run proves all 12 historical manifests are parseable without error. The README provides sufficient actionable steps for the human post-Epic work (merge-strategy markers).

The single P1 is an operational UX issue (self-test false positive), not a correctness bug. The phase is ACCEPTABLE for Epic completion.
