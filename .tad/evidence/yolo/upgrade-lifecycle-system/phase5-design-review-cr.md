# Phase 5 Design Review — Code Review Report

**Reviewer**: code-review (design-phase expert review)
**Handoff**: HANDOFF-20260610-publish-gate-phase5.md
**Date**: 2026-06-10
**Focus**: Unmanifested deletion detection, git query scoping, AC verifiability, edge cases

---

## Summary

The handoff is well-structured with clear separation of concerns (3 deliverables + 1 integration point), thorough edge-case enumeration, and strong grounding against live code. The design correctly inherits patterns from the existing `version` mode in release-verify.sh. However, there are issues with the `git describe` tag-detection algorithm, an unspecified manifest-count discrepancy, and a gap in how ZERO_TOUCH filtering applies to the `git diff --name-status` scoping approach.

---

## P0 — Critical (Must Fix Before Implementation)

### P0-1: `git describe --tags --abbrev=0 HEAD^` returns the wrong tag when HEAD has commits after the last tag

**Location**: Handoff section 4.2.1 Algorithm step 1, FR1.2

**Problem**: The prescribed command `git describe --tags --abbrev=0 HEAD^` finds the nearest tag reachable from the PARENT of HEAD. This works when HEAD is directly at a tag or one commit after one, but it has two failure modes:

1. **When HEAD IS at a tag** (the publish moment): `HEAD^` is the commit before the tag. `git describe --tags --abbrev=0 HEAD^` returns v2.27.0 (the previous tag reachable from the parent). This is CORRECT for publish-time behavior.

2. **When HEAD has multiple untagged commits past the last tag**: `HEAD^` still resolves to the most recent tag reachable from that commit, which is the same tag as for HEAD itself. This is correct.

However, the REAL issue is: **the command finds the tag most recently reachable from HEAD^, but that may not be the "previous version" tag.** If you have lightweight AND annotated tags, or if tag topology is non-linear (e.g., tags on branches), `git describe` may pick an unexpected tag. More critically:

**The actual P0**: The publish workflow runs at the moment BEFORE the new tag is created (step3d runs before step4 "Push + Tag"). At that moment, HEAD is NOT tagged yet. So `git describe --tags --abbrev=0 HEAD^` finds the most recent tag reachable from HEAD's parent. But the migration mode needs to compare against the tag from which the CURRENT release differs -- that is `git describe --tags --abbrev=0 HEAD` (without the `^`), because HEAD itself is not yet tagged.

Using `HEAD^` at publish-time means: if there are 2+ commits after the last tag, `HEAD^` and `HEAD` reach the same most-recent tag, so the result is the same. But if HEAD is EXACTLY one commit after a tag, `HEAD^` is the tagged commit itself, and `git describe --tags --abbrev=0` on a tagged commit returns THAT tag -- making `PREV_TAG` equal to the tag you are about to create (wrong).

Wait -- re-examining: `HEAD^` on a commit where `HEAD^` IS the tagged commit returns that tag. Then `prev_tag..HEAD` would be a one-commit diff. That is actually correct for publish-time (you want to see what changed since the last tag).

Let me reconsider: The actual scenario during `*publish` is:
- User bumps version to 2.28.0, makes commits, step3d runs
- `git describe --tags --abbrev=0 HEAD^` = v2.27.0 (the last tag)
- `git diff --name-status -M v2.27.0..HEAD` = correct (all changes since v2.27.0)

This IS correct. The `HEAD^` is needed to avoid `HEAD` itself if HEAD were tagged. Since at publish-time HEAD is NOT tagged, `HEAD^` vs `HEAD` yield the same `describe` result when there are 2+ commits. When there is exactly 1 commit past the tag, `HEAD^` IS the tagged commit, and describe returns that tag -- still correct.

**REVISED**: The `HEAD^` approach is actually correct for the publish scenario. However, there is a distinct failure mode: **What if `HEAD^` does not exist (initial commit)?** `git describe --tags --abbrev=0 HEAD^` fails with "unknown revision" on a repo with only one commit. FR1.2 says "if no previous tag exists, exit 0", but the error is "unknown revision HEAD^", not "no tag found". The script must handle this.

**Severity**: Downgraded from P0 to P1. See P1-1 below.

### P0-1 (REVISED): Manifest count is contradictory in section 6 (Phase 1 Implementation hints)

**Location**: Section 6, Phase 1, Implementation hints (lines 416-425)

**Problem**: The handoff contains a visible self-correction that reaches the right answer (11 to generate) but the narrative is confusing and could mislead Blake:

- Line 389: "12 historical manifests" in Phase 1 deliverables
- Line 425: "Generate 11 new manifests" (correct conclusion)
- Line 467: `ls .tad/migrations/ | wc -l` = 12 (11 new + 1 existing = 12 total)
- AC3: "12 manifest files exist (11 new + 1 existing)"

The thinking-out-loud block (lines 422-425) is confusing but ultimately correct. The numbers are consistent: 12 total in `.tad/migrations/`, of which 11 are new and 1 already exists. However, the Phase 1 deliverable header says "12 historical manifests" when it should say "11 historical manifests" (the existing 2.26.0-to-2.27.0.yaml is not a Phase 5 deliverable).

**Risk**: Blake could attempt to regenerate the existing 2.26.0-to-2.27.0.yaml, which would be caught by FR2.11 (refuse-to-overwrite). Low risk, but the deliverable count should be corrected.

**Recommendation**: Change "12 historical manifests" to "11 historical manifests" in Phase 1 deliverables. The final self-correction is correct; just clean up the deliverable header.

**Severity**: Downgraded to P2 (the self-correction is present and FR2.11 guards against the mistake).

---

## P0 — NONE REMAINING

After re-analysis, no P0 issues remain. All apparent P0 candidates resolved to P1 or P2 upon deeper examination.

---

## P1 — Important (Should Fix)

### P1-1: `HEAD^` failure on shallow clone or first-commit repos

**Location**: Section 4.2.1 Algorithm step 1

**Problem**: `git describe --tags --abbrev=0 HEAD^` will fail with a fatal error if:
- The repo has only one commit (HEAD^ does not exist)
- The repo is a shallow clone where the parent commit is pruned

FR1.2 says to exit 0 with "no previous tag" on failure, but the error check only looks at `2>/dev/null` exit code. The `HEAD^` resolution failure has a different error message than "no tag found" but both result in non-zero exit. If the script checks only `$?`, both cases are handled. But if someone later adds error-message parsing, the two failure modes look different.

**Recommendation**: Use a two-step approach:
```bash
PREV_TAG="$(git -C "$REPO" describe --tags --abbrev=0 HEAD^ 2>/dev/null)" || PREV_TAG=""
if [ -z "$PREV_TAG" ]; then
  echo "No previous tag found — nothing to check"
  exit 0
fi
```

This cleanly handles all failure modes. The handoff already implies this pattern but should state it explicitly in the algorithm.

### P1-2: ZERO_TOUCH filtering applied AFTER git diff, but `.tad/active/` and `.tad/evidence/` appear in git diff output

**Location**: Section 4.2.1 steps 5-6, FR1.7

**Problem**: The git diff command scopes to `-- .tad/ .claude/ .codex/ .agents/ CLAUDE.md AGENTS.md tad.sh`. This includes ALL `.tad/` subdirectories, including ZERO_TOUCH ones like `.tad/active/`, `.tad/archive/`, `.tad/evidence/`, etc. The filtering in step 6 then removes these.

This is functionally correct (filter-after-diff), but the performance concern is real: between v2.26.0 and v2.27.0, I observed ~30 entries in `.tad/active/` and `.tad/evidence/` alone. For large version jumps, there could be hundreds of ZERO_TOUCH entries in the diff, all of which are immediately filtered out.

**Recommendation**: Consider pre-scoping the git diff to only SYNC directories:
```bash
# Build git diff path scope from SYNC dirs only (exclude ZERO_TOUCH at source)
DIFF_PATHS=()
while IFS= read -r d; do
  [ -n "$d" ] || continue
  DIFF_PATHS+=(".tad/$d/")
done < <(bash "$DERIVE" --dirs "$REPO")
DIFF_PATHS+=(".claude/" ".codex/" ".agents/" "CLAUDE.md" "AGENTS.md" "tad.sh")
git -C "$REPO" diff --name-status -M "$PREV_TAG"..HEAD -- "${DIFF_PATHS[@]}"
```

This is a performance optimization, not a correctness fix. The current design is correct but generates noise. The tradeoff: using `--dirs` adds a subprocess call but eliminates hundreds of irrelevant diff entries. Given NFR3 (<10 seconds), this is acceptable either way.

**Impact**: Low -- the current filter-after approach works. This is a "should fix for clarity" not a must-fix.

### P1-3: `grep -F` manifest cross-reference has a specific false-negative: YAML comment lines

**Location**: Section 4.2.1 step 7, section 4.2.1 "YAML checking without yq" rationale

**Problem**: The handoff correctly identifies that `grep -F "$path" "$manifest_file"` is approximate and that a path appearing in a YAML comment is a false-negative (gate passes when it should warn). However, the handoff describes the consequence as "the same outcome as not having the gate at all."

This understates the risk. A manifest with a commented-out delete entry is a meaningful signal:
```yaml
delete:
  # - path: ".claude/skills/old-ref.md"   # decided to keep
  #   type: "file"
```

Here `grep -F ".claude/skills/old-ref.md"` returns a match, but the file is NOT actually covered by the manifest. The operator thinks the gate passed when the deletion is actually unmanifested.

**Recommendation**: Use a slightly more targeted grep that excludes comment lines:
```bash
grep -vE '^\s*#' "$manifest_file" | grep -qF "$path"
```

This is still not a YAML parser, but it eliminates the most common false-negative case (commented-out entries). Cost: one extra pipe per path check. Still no yq dependency.

### P1-4: Version normalization may produce incorrect manifest filename for non-standard version.txt

**Location**: Section 4.2.1 Algorithm step 3

**Problem**: The handoff says "add .0 if only 2-segment like '2.27'". The current version.txt contains `2.27.0` (already 3-segment). But the algorithm needs to handle:
- `2.27` -> `2.27.0` (documented)
- `2.27.0` -> `2.27.0` (pass-through)
- `v2.27.0` -> `2.27.0` (strip v prefix, documented for tags but not for version.txt)
- `2.27.0\n` -> `2.27.0` (trailing newline -- "first line, trimmed")

The handoff says "first line, trimmed" but doesn't specify what "trimmed" means. Does it strip trailing whitespace? Carriage returns? The `read` builtin in bash handles newlines but not all whitespace.

**Recommendation**: Specify the exact normalization command:
```bash
EXP_VER="$(head -1 "$REPO/.tad/version.txt" | tr -d '[:space:]')"
EXP_VER="${EXP_VER#v}"  # strip leading v
case "$EXP_VER" in
  *.*.*)  ;;  # already 3-segment
  *.*)    EXP_VER="${EXP_VER}.0" ;;  # add patch
  *)      echo "ERROR: cannot parse version: $EXP_VER" >&2; exit 2 ;;
esac
```

### P1-5: No explicit handling of `git diff` rename status codes (R050, R100, etc.)

**Location**: Section 4.3, FR1.5

**Problem**: `git diff --name-status -M` outputs rename entries with a similarity percentage: `R100\t.tad/old.md\t.tad/new.md` or `R050\t...`. The data model in section 4.3 shows `R100` but the algorithm steps 8-9 do not specify how to parse the variable-length status code.

In particular, when parsing tab-separated fields:
- D entries: `D\tpath` (2 fields)
- R entries: `R###\told_path\tnew_path` (3 fields, where status includes a number)
- A entries: `A\tpath` (2 fields)

Blake needs to handle the R-status by matching `R*` or `R[0-9]*` rather than exact `R`. The handoff shows `R100` in the data model but doesn't specify the parsing regex.

**Recommendation**: Add explicit parsing guidance:
```bash
case "$status" in
  D)     # handle delete ;;
  R*)    # handle rename — extract old_path and new_path from fields 2 and 3 ;;
  A)     # handle add ;;
  M|T|C*) continue ;;  # modifications, type changes, copies — skip
esac
```

### P1-6: Fixture test for migration gate goes into existing `run-fixtures.sh` which tests migration-engine.sh, not release-verify.sh

**Location**: Section 8.2, section 6 Phase 2, AC6, AC14

**Problem**: The existing `run-fixtures.sh` tests `migration-engine.sh` (the engine that EXECUTES migrations). The new fixtures test `release-verify.sh migration` mode (the gate that DETECTS missing manifests). These are different scripts with different purposes.

AC14 says "All existing fixtures still pass" and refers to `run-fixtures.sh`. If Blake adds migration-gate fixtures to `run-fixtures.sh`, the harness mixes two different systems. The existing harness sets `ENGINE=` and calls `bash "$ENGINE"` -- adding release-verify tests would require a different test target.

**Recommendation**: Create a separate fixture file (e.g., `test-migration-gate.sh`) in the same directory, following the T15 pattern (`test-15-dual-caller-integration.sh`). Have `run-fixtures.sh` call it at the end, or keep it standalone. This maintains separation of concerns.

The handoff says "Add fixture test(s) to `.tad/tests/migration-fixtures/`" (section 6, Phase 2) and also mentions "or new test file" in the micro-tasks table. This ambiguity should be resolved: Blake should create a new test file, not modify `run-fixtures.sh`.

---

## P2 — Suggestions (Consider)

### P2-1: Historical manifest deliverable count mismatch in Phase 1 header

**Location**: Section 6, Phase 1 deliverables

**Problem**: Header says "12 historical manifests" but only 11 are new (the 12th already exists). The self-correction at lines 422-425 reaches the right number. Clean up the header to say "11 new historical manifests" to avoid confusion.

### P2-2: `migration-draft.sh` does not validate schema_version of existing manifests it refuses to overwrite

**Location**: FR2.11

**Problem**: When the output file already exists, the script refuses to overwrite (exit 2). This is correct. But it would be useful to also report the existing manifest's schema_version in the warning message, so the operator knows whether the existing manifest is from a compatible schema.

### P2-3: No explicit test for "HEAD at a tag" edge case in fixtures

**Location**: Section 8.3

**Problem**: Edge case "HEAD is at a tag (no changes since last tag)" is listed but no fixture covers it. In the fixture harness, this would be: create two tags at the same commit, run migration mode, assert exit 0 with no findings.

### P2-4: The secondary rename detection (basename matching) could produce excessive false positives

**Location**: FR1.6, section 4.2.1 step 9

**Problem**: Matching by basename only (not directory structure or content similarity) means that if `README.md` is deleted in one directory and `README.md` is added in another, it will be flagged as a possible rename. For version bumps with many file moves, this could generate noise.

The handoff says "Prefer false-positive here" which is the correct principle, but the output format should clearly distinguish "POSSIBLE RENAME (needs review)" from "UNMANIFESTED DELETE" so the operator can triage quickly.

### P2-5: ZERO_TOUCH extraction into shared function is left as optional

**Location**: Section 6, Phase 2 step 3

**Problem**: The handoff says "If the extraction is clean, do it. If it would require restructuring, leave it as documented duplication with a TODO." This is pragmatic but the duplication is already present in version mode (lines 203-207) and will now appear a third time in migration-draft.sh. Three copies of the same pattern is a strong signal to extract.

### P2-6: publish-protocol.md currently mentions `release-verify.sh structural` in step3c comment but uses `version` mode

**Location**: Grounding file publish-protocol.md line 91

**Problem**: The step3c action comment says "Publish-side source-consistency = THIS step3c (version zero-stale)" which is accurate. But the phase5-grounding.md says "Currently calls release-verify.sh structural" which is WRONG -- step3c calls `version` mode, not `structural`. The `structural` mode is sync-only. This grounding error should not affect Blake's implementation but indicates the grounding document has stale information.

---

## Positive Observations

1. **Exit code contract clarity**: The FR1.9 CORRECTION is excellent -- explicitly stating that the script always exits 1 on findings and the CALLER handles warn/block is consistent with step3c's pattern and avoids the "who decides" ambiguity.

2. **Bash 3.2 compatibility note**: Explicitly calling out no `declare -A` and providing the `printf + grep -qxF` alternative prevents a common macOS pitfall.

3. **YAML emission without yq**: The decision to use heredoc templates for simple YAML emission is appropriate given NFR4 (no new dependencies).

4. **Expert review thoroughness**: Both reviewers caught substantive issues (bash 3.2 compat, version float quoting, warn/block semantics) that were properly resolved in the handoff.

5. **Phase 1-before-Phase 2 ordering**: Generating historical manifests first (Phase 1) means Phase 2's migration mode can be tested against real manifests immediately.

6. **FR2.11 refuse-to-overwrite**: Prevents accidental regeneration of manually-reviewed manifests.

---

## Verdict

**PASS with P1 fixes required.** 0 P0, 6 P1, 6 P2. The design is sound and well-grounded against live code. The P1 issues are implementation-guidance gaps that Blake should address during coding -- none require architectural redesign. The most impactful P1 is P1-3 (grep comment-line false-negative) which has a one-line fix, and P1-6 (fixture file separation) which prevents test-harness confusion.
