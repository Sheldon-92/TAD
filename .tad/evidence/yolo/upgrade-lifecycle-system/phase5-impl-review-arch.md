# Phase 5 Implementation Review (Architecture)

**Reviewer**: backend-architecture-reviewer
**Date**: 2026-06-10
**Scope**: Phase 5/6 — Publish Migration Gate (migration-draft.sh, release-verify.sh migration mode, historical manifests, publish-protocol step3d)
**Files reviewed**:
- `.tad/hooks/lib/migration-draft.sh` (292 lines, new)
- `.tad/hooks/lib/release-verify.sh` (483 lines, modified — migration case arm lines 311-477)
- `.tad/tests/migration-fixtures/run-fixtures.sh` (1256 lines, modified — MG1/MG2/MG3 added)
- `.claude/skills/alex/references/publish-protocol.md` (163 lines, modified — step3d added)
- `.tad/migrations/*.yaml` (12 files, 11 new + 1 existing)

---

## Findings

### P0-1: Secondary rename detection in release-verify.sh always returns true (lines 432-437)

**Location**: `.tad/hooks/lib/release-verify.sh` lines 432-437

**Code**:
```bash
if printf '%s\n' "$ADDED" | while IFS= read -r a_path; do
    [ -n "$a_path" ] || continue
    if [ "$(basename "$a_path")" = "$d_base" ]; then exit 0; fi
done; then
    is_possible_rename=1
fi
```

**Problem**: The `while` loop runs in a pipeline subshell. When a match IS found, `exit 0` terminates the subshell with status 0. When NO match is found, the while loop finishes naturally — and a while loop that completes (its condition `read` returns EOF) also exits with status 0. Therefore, the `if` condition is ALWAYS true when `$ADDED` is non-empty, regardless of whether any basename matched.

**Impact**: Every uncovered delete is labeled "POSSIBLE RENAME" instead of "UNMANIFESTED DELETE" when there are any added files in the same diff. The gate still exits 1 correctly (the finding is still reported), so no missing-manifest silently ships. But the diagnostic label is wrong, which misleads the operator about what action to take (the operator sees "POSSIBLE RENAME" for a genuine delete and might waste time looking for a rename partner that does not exist).

**Contrast**: `migration-draft.sh` line 157 uses the correct pattern: `if printf '%s\n' "$added_basenames" | grep -qxF "$d_base"; then` — this properly returns non-zero when no match is found.

**Fix**: Replace the while-loop subshell with `grep -qxF` on a pre-built basenames list (same pattern as migration-draft.sh), or add `exit 1` after `done` (before the pipeline closes) so the while loop signals failure when no match was found:
```bash
added_basenames=""
while IFS= read -r a_path; do
    [ -n "$a_path" ] || continue
    added_basenames="${added_basenames}$(basename "$a_path")"$'\n'
done <<ABEOF
$ADDED
ABEOF
# ...
if printf '%s\n' "$added_basenames" | grep -qxF "$d_base"; then
    is_possible_rename=1
fi
```

**Severity**: P0 — correctness bug in diagnostic output. The gate catches the issue (exit 1) but every label is wrong when ADDED is non-empty. Operators see "POSSIBLE RENAME" for genuine deletes, which is actively misleading.

---

### P1-1: migration-draft.sh does not accept --output-dir with = syntax

**Location**: `.tad/hooks/lib/migration-draft.sh` lines 31-42

**Problem**: The argument parser only handles `--output-dir <dir>` (two-arg form). If a user passes `--output-dir=<dir>` (common shell convention), it falls through to the `*) echo "ERROR: unknown argument"` case and exits 2. This is not a correctness bug but a usability issue for future maintainers who may expect `=` form.

**Impact**: Low — all current callers use the two-arg form. But as a reusable tool for future releases, supporting `=` form is standard practice.

**Fix**: Add a case for `--output-dir=*`:
```bash
--output-dir=*)
    OUTPUT_DIR="${1#--output-dir=}"
    shift
    ;;
```

**Severity**: P1 — usability/robustness for a tool intended for future reuse.

---

### P1-2: migration-draft.sh calls derive-sync-set.sh --zero-touch without repo root argument

**Location**: `.tad/hooks/lib/migration-draft.sh` line 83

**Code**: `ZT_DIRS="$(bash "$DERIVE" --zero-touch 2>/dev/null)" || true`

**Problem**: The `--zero-touch` call omits the `<root>` argument. `derive-sync-set.sh` defaults to `ROOT="${2:-.}"` (cwd). The script also runs `git diff` without `-C`, relying on cwd being the repo root. This works when run from the repo root (the expected invocation) but fails silently if run from any other directory — `--zero-touch` would exit 2 (no .tad/ found), the `|| true` swallows the error, `ZT_DIRS` is empty, and ZERO_TOUCH paths are NOT filtered out of the draft manifest.

**Impact**: If a user runs `bash /path/to/migration-draft.sh v2.25.0 v2.26.0` from a non-repo directory, the draft manifest would include ZERO_TOUCH paths (e.g., `.tad/active/` deletions). The `git diff` call would also fail (not in a repo), so the script would produce an empty manifest. The combined failure modes mean the practical risk is low (git diff fails first), but the ZERO_TOUCH filter silently degrading is the deeper concern.

**Comparison**: `release-verify.sh` migration mode correctly passes `"$REPO"` to `--zero-touch` (line 365).

**Fix**: Pass `"$PWD"` (or derive repo root) to `--zero-touch`:
```bash
ZT_DIRS="$(bash "$DERIVE" --zero-touch "$PWD" 2>/dev/null)" || true
```

**Severity**: P1 — silent degradation of a safety filter. Low practical risk because git diff fails first, but the asymmetry with release-verify.sh is a maintenance hazard.

---

### P1-3: Historical manifests retain "TODO: add reason" placeholders

**Location**: All 11 generated manifests, e.g., `.tad/migrations/2.25.0-to-2.26.0.yaml` lines 8, 11, 14, etc.

**Problem**: The manifests contain `reason: "TODO: add reason"` for every entry. The handoff (FR3.3) says "Human-review at least 2 manifests" — the spot-check verifies path correctness but does not require filling in reasons. The completion report confirms 2 manifests were spot-checked (path correctness verified), but reasons remain TODO.

**Impact**: The manifests are functionally correct (the migration engine reads `path` and `type`, not `reason`). But the `reason` field exists to provide documentation value for future maintainers. The historical manifests are the retroactive record; leaving TODO placeholders reduces their documentation utility. For the only manifest with actual content (v2.25.0-to-2.26.0 with 14 codex deletions), a meaningful reason like "Codex edition removed in v2.26.0 SKILL progressive loading restructure" would be valuable.

**Fix**: Fill in reason fields for the non-empty manifest (v2.25.0-to-2.26.0). Empty manifests have no entries, so this does not apply to them.

**Severity**: P1 — documentation quality. Does not affect functionality but reduces the value of the historical audit trail.

---

### P2-1: TOTAL variable in run-fixtures.sh is dead code

**Location**: `.tad/tests/migration-fixtures/run-fixtures.sh` line 13

**Code**: `PASS_COUNT=0 FAIL_COUNT=0 TOTAL=22`

**Problem**: `TOTAL` is declared but never referenced in the actual pass/fail logic. The harness uses `$((PASS_COUNT + FAIL_COUNT))` for totals. The hardcoded "22/22" in the success message (line 1254) and the "18 fixtures + 1 inline AC17 + 3 migration gate" label (line 1245) are string literals, not derived from `TOTAL`. If a future contributor adds a fixture and updates `TOTAL` but forgets the string literals (or vice versa), the count would be inconsistent.

**Fix**: Either derive the success message from `TOTAL` or remove the dead variable.

**Severity**: P2 — code hygiene, no functional impact.

---

### P2-2: ZERO_TOUCH reading code is duplicated between version and migration modes in release-verify.sh

**Location**: `.tad/hooks/lib/release-verify.sh` lines 216-227 (version mode) and lines 361-372 (migration mode)

**Problem**: The handoff (Phase 2, step 3) noted this: "The ZERO_TOUCH reading code from version mode should ideally be extracted into a shared function." The implementation chose duplication with the ZT_RE regex being slightly different between modes (`(^|/)\.tad/` in version mode vs `^\.tad/` in migration mode). Both are correct for their respective contexts (version mode greps file paths that may or may not have a prefix; migration mode greps paths from git diff which are always repo-relative), but the duplication is a maintenance burden.

**Impact**: Low — both copies work correctly. But future changes to the ZERO_TOUCH filter will need to be applied to both locations.

**Severity**: P2 — code duplication, acknowledged in the handoff as a known tradeoff.

---

### P2-3: Manifest cross-reference uses grep -F, which can match in YAML comments

**Location**: `.tad/hooks/lib/release-verify.sh` lines 424 and 457

**Problem**: The manifest cross-reference uses `grep -qF "$d_path" "$MANIFEST"` to check if a path is covered. As documented in the handoff (4.2.1 rationale), this is intentionally approximate — a path appearing in a YAML comment would cause a false negative (the gate thinks the path is covered when it is not). The handoff explicitly accepts this tradeoff because manifests are small, human-reviewed files.

The concern is that migration-draft.sh DOES emit comments for possible renames (line 218: `# POSSIBLE RENAME: basename matches added file "..."`) that include file paths. If a D entry's path appears in a POSSIBLE RENAME comment (not in a delete entry), `grep -F` would find it and report it as covered.

**Impact**: Very low in practice — the comment path is the ADDED path (the rename target), not the deleted path. The deleted path appears in the `delete:` entry itself. So the false-negative scenario requires the comment to contain the exact same path as a different delete entry, which is unlikely but theoretically possible if two files with the same name in different directories are involved.

**Severity**: P2 — theoretical false-negative in a deliberately approximate check. Documented and accepted in the handoff.

---

## Verification Results

| Check | Result | Evidence |
|-------|--------|----------|
| bash -n migration-draft.sh | PASS | Syntax OK, exit 0 |
| bash -n release-verify.sh | PASS | Syntax OK, exit 0 |
| No grep -P in code | PASS | Only in comments (line 12, line 93) |
| No declare -A (bash 3.2 compat) | PASS | 0 occurrences in both scripts |
| No readarray/mapfile (bash 3.2 compat) | PASS | 0 occurrences in both scripts |
| Chain completeness (12 pairs) | PASS | All 12 manifest files present, 0 gaps |
| Spot-check 2.25.0-to-2.26.0 | PASS | 14 D entries match raw git diff exactly |
| Spot-check 2.22.0-to-2.22.1 | PASS | Empty sections correct (2 D entries in ZERO_TOUCH active/) |
| Manifest v2.26.0-to-2.27.0 existing | PASS | 3 entries, manual authorship, correct |
| refuse-to-overwrite | PASS | migration-draft.sh v2.26.0 v2.27.0 exits 2 |
| ZERO_TOUCH filter regex | PASS | Both scripts correctly filter zero-touch paths |
| Live migration gate run | PASS | release-verify.sh migration "$PWD" exits 0 (HEAD at v2.27.0) |
| All fixtures pass | PASS | 22/22 ALL FIXTURES PASS |
| step3d in publish-protocol | PASS | Correctly mirrors step3c exit code handling pattern |
| TAD_RELEASE_GATE in publish-protocol | PASS | Referenced in both step3c and step3d |
| Change scope | PASS | Only Phase 5 files created/modified |

---

## Reusability Assessment

**migration-draft.sh** is well-designed for future reuse:
- Standalone with clear interface (from_tag, to_tag, --output-dir)
- Refuse-to-overwrite prevents accidental clobbering
- ZERO_TOUCH filtering via derive-sync-set.sh (single source of truth)
- Secondary rename detection with comments for human review
- "DRAFT — review manually" reminder in output
- Schema-v1 YAML template emission with quoted versions

**release-verify.sh migration mode** integrates cleanly:
- Follows the existing mode pattern (structural/version/freshness)
- EXIT code contract preserved (0/1/2)
- CONTRACT header updated with migration mode documentation
- ZERO_TOUCH filtering consistent with version mode

**Historical manifests** form a complete chain:
- 12 adjacent pairs from v2.19.0 to v2.27.0
- No gaps
- Empty manifests for no-op pairs (correct — proves the pair was audited)
- Non-empty manifest (v2.25.0-to-2.26.0) has correct entries

---

## Summary

| Severity | Count | Items |
|----------|-------|-------|
| P0 | 1 | Secondary rename detection always returns true (wrong diagnostic label) |
| P1 | 3 | --output-dir= syntax, missing repo root in --zero-touch call, TODO reason placeholders |
| P2 | 3 | Dead TOTAL variable, ZERO_TOUCH code duplication, grep -F comment false-negative |

**Overall**: The Phase 5 implementation is structurally sound. The gate detection works correctly (exit 1 on unmanifested removals, exit 0 when covered). The P0 is a diagnostic label bug, not a gate bypass — the gate still catches missing manifests. The historical manifests are complete and verified. The publish-protocol integration follows the established step3c pattern exactly. Fix the P0 before shipping to ensure operators see accurate diagnostic messages.
