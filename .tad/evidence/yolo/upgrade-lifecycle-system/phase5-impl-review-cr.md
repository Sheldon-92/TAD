# Phase 5 Implementation Review — Code Review

**Reviewer**: code-review-specialist
**Date**: 2026-06-10
**Scope**: Phase 5 deliverables — migration-draft.sh, release-verify.sh migration mode, 11 historical manifests, publish-protocol.md step3d, 3 fixture tests (MG1/MG2/MG3)
**Verdict**: CONDITIONAL PASS (1 P0, 2 P1, 3 P2)

---

## Summary

Phase 5 delivers a publish-time migration gate that detects unmanifested file deletions/renames between git tags, a draft manifest generator, 12 historical manifests, and the publish-protocol integration. The implementation is well-structured, follows project conventions (BSD/macOS compat, no grep -P, proper quoting), and all 22 fixture tests pass. However, the secondary rename detection in `release-verify.sh` contains a logic bug that causes every deleted file to be classified as a "POSSIBLE RENAME" whenever any added file exists in the diff, regardless of basename match.

---

## P0 — Must Fix

### P0-1: Secondary rename detection in release-verify.sh always returns true when ADDED is non-empty

**File**: `.tad/hooks/lib/release-verify.sh`, lines 432-435
**Severity**: P0 (logic correctness — gate produces false findings)

```bash
if printf '%s\n' "$ADDED" | while IFS= read -r a_path; do
  [ -n "$a_path" ] || continue
  if [ "$(basename "$a_path")" = "$d_base" ]; then exit 0; fi
done; then
  is_possible_rename=1
fi
```

The `printf | while` construct runs the `while` loop in a subshell (pipe creates a subshell in bash). When the loop completes normally without hitting `exit 0` (i.e., no basename match found), the subshell exits 0 — the default exit status of a completed loop. The `if ... then` always evaluates true regardless of whether a match was found.

**Consequence**: When a tag pair has both D (delete) and A (add) entries with different basenames, every deleted file is incorrectly reported as "POSSIBLE RENAME (basename match in added files)". This produces false findings that can mask real "UNMANIFESTED DELETE" reports and mislead the operator. The gate's bias-to-false-positive intent is correct, but this is uncontrolled — it fires on EVERY delete when any add exists, not just on actual basename matches.

**Why fixtures pass**: MG1 passes because its scenario has no A entries (only a deletion), so `$ADDED` is empty and the `if [ -n "$ADDED" ]` guard on line 430 prevents the bug from triggering. The bug is latent — it fires only when unrelated A entries coexist with D entries in the same diff.

**Fix** (replace lines 432-435):
```bash
d_base="$(basename "$d_path")"
is_possible_rename=0
if [ -n "$ADDED" ]; then
  if printf '%s\n' "$ADDED" | grep -qxF "$d_base" 2>/dev/null; then
    # Note: this compares basename of deleted against full path of added,
    # which won't match. Need to compare against basenames of ADDED.
    # Better approach:
    :
  fi
  # Build added_basenames like migration-draft.sh does:
  added_basenames=""
  while IFS= read -r a_path; do
    [ -n "$a_path" ] || continue
    added_basenames="${added_basenames}$(basename "$a_path")"$'\n'
  done <<ABEOF
$ADDED
ABEOF
  if printf '%s\n' "$added_basenames" | grep -qxF "$d_base" 2>/dev/null; then
    is_possible_rename=1
  fi
fi
```

Or more concisely, reuse the same `grep -qxF` pattern that `migration-draft.sh` already uses correctly on line 157:
```bash
is_possible_rename=0
if [ -n "$ADDED" ]; then
  d_base="$(basename "$d_path")"
  added_bases=""
  while IFS= read -r a_p; do
    [ -n "$a_p" ] || continue
    added_bases="${added_bases}$(basename "$a_p")"$'\n'
  done <<ABEOF
$ADDED
ABEOF
  if printf '%s\n' "$added_bases" | grep -qxF "$d_base"; then
    is_possible_rename=1
  fi
fi
```

**Also needed**: Add a fixture that exercises this code path — a scenario where D and A entries coexist with DIFFERENT basenames, asserting that the D entry is reported as "UNMANIFESTED DELETE" not "POSSIBLE RENAME".

---

## P1 — Should Fix

### P1-1: Historical manifest 2.25.0-to-2.26.0.yaml has 14 unresolved TODO placeholders

**File**: `.tad/migrations/2.25.0-to-2.26.0.yaml`
**Severity**: P1 (data quality — the only manifest with actual delete entries ships with placeholder reasons)

All 14 delete entries contain `reason: "TODO: add reason"`. The handoff AC13 spot-check confirmed path correctness, but the reasons were left as placeholders. Since this is the only non-trivial historical manifest (the rest are empty-section), and the migration-engine.sh uses the `reason` field in user-facing output (TSV reports), these TODOs will appear in downstream upgrade reports.

The 2.26.0-to-2.27.0 manifest (manually written) has proper reasons — this inconsistency suggests the draft-generated manifests were committed without the intended human-review pass on reasons.

**Fix**: Replace all 14 `"TODO: add reason"` entries with a consistent reason string such as `"Codex integration removed in v2.26.0 (EPIC-20260609 skill-progressive-loading)"` for the 13 `.tad/codex/` entries and `"Codex parity check removed — codex adapter architecture retired"` for the `.tad/hooks/lib/codex-parity-check.sh` entry.

### P1-2: ADDED basenames computed inside the delete-loop (O(D*A) per-path) — inefficient for large diffs

**File**: `.tad/hooks/lib/release-verify.sh`, lines 420-450
**Severity**: P1 (performance — quadratic basename computation on every D iteration)

The code re-iterates over all ADDED entries for every single DELETE entry to check basename matches. For the current TAD repo this is fine (small diffs), but the ADDED basename list could be built once before the delete-processing loop, as migration-draft.sh already does (lines 146-152). This is both a performance concern and a code clarity concern — the duplicated loop makes the logic harder to follow.

**Fix**: Extract ADDED basenames into a newline-delimited string before the delete-processing loop (same pattern as migration-draft.sh lines 146-152).

---

## P2 — Consider

### P2-1: migration-draft.sh possible-rename grep uses substring match, not line-anchored

**File**: `.tad/hooks/lib/migration-draft.sh`, line 197
**Severity**: P2 (theoretical false-positive)

```bash
if printf '%s\n' "$POSSIBLE_RENAMES" | grep -qF "$d_path	"; then
```

`grep -F` matches substrings. If `d_path=".tad/codex"` and `POSSIBLE_RENAMES` contains a line starting with `.tad/codex/foo.md\t...`, the grep would match the prefix. In practice, DELETES contains full file paths (not directory prefixes), so this is extremely unlikely. But using `grep -qxF` (exact line match) or anchoring with `^` would be more robust.

### P2-2: No fixture for the "D + A with matching basenames" positive case

**File**: `.tad/tests/migration-fixtures/run-fixtures.sh`
**Severity**: P2 (test coverage gap)

The MG3 fixture tests git-detected renames (R entries), but there is no fixture that exercises the SECONDARY rename detection (a D + A pair with matching basenames where git -M did NOT detect the rename). This is the code path with the P0 bug, and a positive-case fixture would have caught it.

### P2-3: TOTAL count in run-fixtures.sh is hardcoded to 22

**File**: `.tad/tests/migration-fixtures/run-fixtures.sh`, line 13
**Severity**: P2 (maintenance burden)

`TOTAL=22` is hardcoded but never used for assertion — the harness counts PASS_COUNT and FAIL_COUNT dynamically. The variable is dead code that could drift out of sync when new fixtures are added. Consider either removing it or using it as an assertion (`[ "$PASS_COUNT" -eq "$TOTAL" ]`).

---

## Positive Observations

1. **CONTRACT header documentation** (lines 65-75): The migration mode's exit-code semantics, ZERO_TOUCH exclusion, and the "script always exits honestly, caller handles warn/block" pattern are clearly documented. This follows the established convention from structural and version modes.

2. **YAML validation**: All 12 manifests pass Ruby YAML.safe_load validation — the printf-based YAML emission in migration-draft.sh produces well-formed output.

3. **Fixture design**: MG1 (round-trip from exit-1 to exit-0 after adding manifest), MG2 (ZERO_TOUCH exclusion), and MG3 (rename detection) cover the three primary gate behaviors. The fixtures follow the established harness pattern with proper cleanup.

4. **publish-protocol.md integration**: step3d mirrors step3c's exit-code branching pattern exactly (exit 2 = hard block, exit 1 + warn = advisory), maintaining consistency across the publish gate chain.

5. **Version normalization**: Both scripts handle 2-segment versions (e.g., "2.27" from version.txt) by appending ".0", matching the manifest filename convention.

6. **No grep -P**: Confirmed zero code-level usage of `grep -P` in both scripts (only appears in comments documenting the restriction).

---

## Verification Results

| Check | Result |
|-------|--------|
| `bash -n release-verify.sh` | PASS (exit 0) |
| `bash -n migration-draft.sh` | PASS (exit 0) |
| All 22 fixtures pass | PASS (22/22) |
| 12 manifest YAML files valid | PASS (Ruby YAML.safe_load) |
| Chain completeness v2.19.0-v2.27.0 | PASS (12 pairs, 0 missing) |
| No grep -P in code | PASS |
| publish-protocol.md has step3d | PASS |
| Migration gate on TAD repo | PASS (exit 0, no D/R at HEAD) |
| Secondary rename detection logic | FAIL (P0-1: always true when ADDED non-empty) |

---

## Action Items

1. **[P0-1] MUST FIX**: Replace pipe|while subshell pattern with grep-based basename matching in release-verify.sh lines 428-439. Add a fixture testing D+A with non-matching basenames.
2. **[P1-1] SHOULD FIX**: Fill in the 14 TODO reasons in 2.25.0-to-2.26.0.yaml.
3. **[P1-2] SHOULD FIX**: Pre-compute ADDED basenames before the delete-processing loop.
4. **[P2-1] CONSIDER**: Use anchored grep for possible-rename substring check in migration-draft.sh.
5. **[P2-2] CONSIDER**: Add secondary-rename positive/negative case fixtures.
6. **[P2-3] CONSIDER**: Remove or use the dead TOTAL variable in run-fixtures.sh.
