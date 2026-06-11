# Code Review: Pack System Unification Phase 3

**Reviewer**: code-reviewer (Layer 2)
**Date**: 2026-06-11
**Commit**: 4c64e19
**Scope**: `.tad/hooks/lib/release-verify.sh` platform-skills mode + protocol/doc/evidence changes
**Files reviewed**: 19 files changed (469 insertions, 8 deletions)

---

## Summary

The `platform-skills` mode adds a post-sync/post-install verifier that checks framework-owned skill symmetry between `.claude/skills` and `.agents/skills` in a target project. The implementation is structurally sound: it derives framework-owned skills from the source tree (FR2), checks target-side byte-symmetry (FR3), reports local-only skills as INFO (FR6), and includes a source precondition gate. Shell syntax validates (`bash -n` PASS). Protocol and doc updates are symmetric and placed correctly. Evidence includes all four required output fixtures.

Overall quality: **solid implementation with 2 P1 and 3 P2 findings**.

---

## Findings

### P0 (Critical) -- 0 found

No P0 issues identified.

---

### P1 (Important, Should Fix) -- 2 found

#### P1-1: Source precondition does not detect source-only-on-one-platform skills

**File**: `.tad/hooks/lib/release-verify.sh` lines 706-717
**Issue**: The source precondition check (lines 708-717) only fires when a skill exists on BOTH source platforms (`if [ -d "$SRC/.claude/skills/$skill" ] && [ -d "$SRC/.agents/skills/$skill" ]`). If a skill exists only in source `.claude/skills/foo` but NOT in source `.agents/skills/foo`, it is silently added to `fw_skills` and the precondition check skips it entirely. The verifier then proceeds to require it on both target platforms (lines 748-762), which would fail even though the source itself is asymmetric.

This is not a theoretical concern: the handoff explicitly notes `research-methodology` was "flag-only" in Phase 2 and could have asymmetric source state. If any future skill is added to `.claude/skills` first (which is the normal workflow since `.claude` is source-of-truth), the precondition would silently miss the source asymmetry.

**Recommendation**: Add an explicit check for skills present on only one source platform:

```bash
for skill in $fw_skills; do
  src_claude="$SRC/.claude/skills/$skill"
  src_agents="$SRC/.agents/skills/$skill"
  if [ -d "$src_claude" ] && [ -d "$src_agents" ]; then
    sout="$(diff -rq "$src_claude" "$src_agents" 2>&1)" || true
    if [ -n "$sout" ]; then
      echo "  SOURCE PRECONDITION: $skill differs between .claude and .agents in source"
      printf '%s\n' "$sout" | sed 's/^/      /' | head -4
      src_fails=$((src_fails + 1))
    fi
  elif [ -d "$src_claude" ] || [ -d "$src_agents" ]; then
    echo "  SOURCE PRECONDITION: $skill exists only on one source platform"
    src_fails=$((src_fails + 1))
  fi
done
```

**Severity justification**: The verifier's purpose is to catch asymmetry. A source that is itself asymmetric is the most important case to detect early, and the current code silently skips it.

---

#### P1-2: AC5 fixture tests DRIFT, not MISSING -- fixture/AC semantic mismatch

**Handoff**: Section 9.1, AC5 block (lines 425-435)
**Evidence**: `platform-skills-missing-fail.txt` line 18

**Issue**: AC5 is documented as "missing framework-owned target skill fails." The fixture runs `rm -f "$tmp_missing/.agents/skills/blake/SKILL.md"` which removes a FILE but leaves the `blake/` directory intact (it still contains `references/`). The verifier therefore reports this as `DRIFT: blake` (line 764, the `diff -rq` branch), NOT as `MISSING: blake` (the `[ ! -d "$agents_dir" ]` branch on line 758). The evidence confirms: `platform-skills-missing-fail.txt` says "DRIFT: blake" not "MISSING: blake".

The verifier's MISSING detection code path (lines 748-762) is never exercised by any fixture. A real missing-directory scenario (e.g., `rm -rf "$tmp_missing/.agents/skills/blake"`) would test the intended path.

**Recommendation**: Either:
(a) Change the fixture to `rm -rf "$tmp_missing/.agents/skills/blake"` to truly test the MISSING path, OR
(b) Add a second fixture that tests MISSING (entire dir gone) alongside the current one that tests single-file-removal-as-drift, and update AC5 description to match what is actually tested.

**Severity justification**: The MISSING code path is untested. If there is a bug in lines 748-762, no fixture would catch it. The fixture gives a false sense of coverage.

---

### P2 (Suggestions, Consider) -- 3 found

#### P2-1: CONTRACT header block does not document the new `platform-skills` mode

**File**: `.tad/hooks/lib/release-verify.sh` lines 5-109
**Issue**: The CONTRACT block documents `structural`, `version`, `migration`, and `parity` modes with their exit-code semantics. The new `platform-skills` mode is not documented there. The CONTRACT block header (line 6) states "The gate steps in alex/SKILL.md (publish_protocol + sync_protocol) READ these exit codes." Since `sync-protocol.md` now calls `platform-skills` with exit-code handling ("exit 0 = proceed; exit 1 = FAIL; exit 2 = ALWAYS HARD BLOCK"), the CONTRACT block should document this mode for consistency and so future maintainers see the full consumed-API surface.

**Recommendation**: Add a `platform-skills <source_root> <target_root>` entry to the CONTRACT block with its exit-code semantics (0 = symmetric, 1 = drift/missing, 2 = usage).

---

#### P2-2: Unquoted `$fw_skills` / `$tgt_skills` in `for` loops relies on convention, not enforcement

**File**: `.tad/hooks/lib/release-verify.sh` lines 708, 743, 775
**Issue**: The space-delimited string variable `fw_skills` is iterated via `for skill in $fw_skills` (unquoted word-splitting). This works because skill directory names are convention-enforced to contain no spaces, glob characters, or IFS-significant characters. However, this is a weaker contract than using an array or newline-delimited approach. If a skill name ever contained a space (e.g., from a downstream project's local skill), the set membership test (`case " $tgt_skills " in *" $name "*`) and the for-loop iteration would silently misbehave.

Current risk is low because all 46 framework skills use hyphenated lowercase names, and this code only runs on framework-owned names. The `tgt_skills` loop (line 775) also iterates local skill names from the target, which is the higher-risk surface.

**Recommendation**: For future robustness, consider using a newline-delimited accumulator with `while IFS= read -r skill` loops, consistent with the pattern used elsewhere in the same file (e.g., the `version` mode's `ZT_DIRS` array). Not blocking because current naming conventions prevent the failure.

---

#### P2-3: `_archived` is included as a framework-owned skill

**File**: `.tad/hooks/lib/release-verify.sh` line 683
**Evidence**: `platform-skills-source-pass.txt` line 6 shows `_archived symmetric`

**Issue**: The `_archived` directory under `.claude/skills/` and `.agents/skills/` is treated as a framework-owned "skill" by the verifier, because the glob `"$SRC/.claude/skills"/*/` picks up every subdirectory. This is a 47-file archive of retired skills (old `.md` files from Jan 2026). It is checked for symmetry like any other skill. The symmetry check is harmless (it passes), but the output is misleading: `_archived` is not a skill. If a downstream project does not sync the archive dir (which is plausible), it would report as MISSING, which is a false alarm.

**Recommendation**: Either exclude `_archived` from the framework-owned set (filter `name` starting with `_`), or accept this as a known cosmetic issue and document it. If downstream projects are expected to sync `_archived`, no action needed.

---

## Positive Observations

1. **Source precondition gate** (lines 706-720): Fail-fast when the source itself is drifted is the right architectural choice. This prevents cascading false failures downstream.

2. **FR7 local-skill INFO** (lines 774-783): The classification is correct -- target-only skills are not in the framework-owned set, so they get INFO treatment. The `case` pattern matching is clean and handles the space-delimited set correctly for the current naming convention.

3. **Protocol/runbook placement** is correct: the sync-protocol inserts the check as step `e` (after all skill copy/install writes, before registry update). The runbook inserts it after sync + pack install, before final step. Both placements match the handoff requirement (section 4.2).

4. **Counterpart symmetry verified**: `.claude/skills/alex/references/sync-protocol.md` and `.agents/skills/alex/references/sync-protocol.md` are byte-identical (confirmed via `diff`). Same for release-runbook SKILL.md.

5. **No NFR violations**: The mode does not mutate the target (NFR3), uses no `grep -P` or GNU-only flags (NFR1), adds no hooks or settings (NFR2), and failure output includes mode, target root, and skill name (NFR5).

6. **Evidence quality**: All four required fixture outputs are present and demonstrate the correct pass/fail/INFO behaviors. The fixture-notes.md correctly documents the `research-methodology` disposition.

---

## Blast Radius Assessment

All file changes are within handoff section 6 scope:

- `release-verify.sh`: new mode added, existing modes untouched (confirmed by reviewing full diff -- the only changes outside the new `platform-skills` case block are the `usage()` line addition)
- Protocol/runbook/docs: additive changes only, no existing content modified beyond what the handoff specifies
- Evidence/traces/decisions: standard TAD workflow artifacts
- `NEXT.md` / `PROJECT_CONTEXT.md`: status updates, not behavioral changes
- `.claude/scheduled_tasks.lock` deletion: cleanup of a stale lock file, unrelated to this phase but harmless
- `IDEA` status change: `captured` -> `promoted`, expected lifecycle

No out-of-scope files were modified. No existing mode behavior was altered.

---

## Verdict

| Severity | Count | Status |
|----------|-------|--------|
| P0 | 0 | -- |
| P1 | 2 | open |
| P2 | 3 | open |

**P1-1** (source precondition gap) and **P1-2** (untested MISSING code path) should be resolved before Gate 3 acceptance. Both are fixable with small, localized changes.
