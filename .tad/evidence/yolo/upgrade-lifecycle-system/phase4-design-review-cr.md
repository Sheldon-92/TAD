# Phase 4 Design Review — Merge Capability (Code Review)

**Reviewer**: code-reviewer (CR perspective)
**Date**: 2026-06-10
**Handoff**: HANDOFF-20260610-merge-capability-phase4.md
**Grounding**: phase4-grounding.md, migration-engine.sh (L641-662, L808-812), migration-manifest-schema-v1.md (L159-193)
**Focus**: Merge logic correctness, backup-before-merge, idempotency, || pattern compliance, AC verifiability

---

## Summary

The handoff designs a `tad-head-marker` merge strategy for migration-engine.sh, replacing the `manual-required` placeholder. The design is well-structured with clear data flow, proper fixture coverage planning (F16-F19), and good alignment with the existing sync-protocol.md merge algorithm. The expert review (shell-portability + safety) already caught and resolved the most critical byte-identity issue (variable capture vs direct pipe). However, this review identifies 2 P0 issues, 3 P1 issues, and 4 P2 suggestions.

---

## P0 — Critical Issues (Must Fix Before Implementation)

### P0-1: `merged` counter increments for ALL tad-head-marker entries, not just `done` status

**Location**: Handoff Section 4.3, L310-314

The integration code (Section 4.3) increments `merged` unconditionally after `execute_merge_entry` returns 0:

```bash
execute_merge_entry "$m_path" "$m_marker" "$m_missing" || return 1
merged=$((merged + 1))
```

But `execute_merge_entry` returns 0 for FOUR different outcomes: `done`, `skipped-no-marker`, `already-current`, and `would-merge` (dry-run). Section 4.6 Implementation Hints says "Only increment for `done` status" but the code design doesn't implement this. The `merged` counter in the summary line will over-count, making the summary report inaccurate and misleading.

**Impact**: Summary line reports `merged=3` when only 1 file was actually merged, 1 was skipped, and 1 was already-current. This degrades operator trust in the migration report.

**Fix**: Either (a) have `execute_merge_entry` communicate the outcome status back (e.g., via a global variable like `LAST_MERGE_STATUS`), or (b) restructure the counter logic to distinguish outcomes. The simplest bash 3.2-compatible approach:

```bash
local MERGE_RESULT=""
# Inside execute_merge_entry, set MERGE_RESULT before each return
# In the loop:
execute_merge_entry "$m_path" "$m_marker" "$m_missing" || return 1
case "$MERGE_RESULT" in
    done) merged=$((merged + 1)) ;;
    skipped-no-marker|already-current) skipped=$((skipped + 1)) ;;
esac
```

Alternatively, increment a status-specific counter inside `execute_merge_entry` directly (simpler, matches how `deleted` works being incremented at the call site for the `done` case only in delete/rename).

### P0-2: `execute_merge_entry` uses `$M_FROM` and `$M_TO` for backup_base but these are globals from parse_manifest, not passed as parameters

**Location**: Handoff Section 4.2, L214

```bash
local backup_base="$TARGET/.tad-backup/${M_FROM}-to-${M_TO}"
```

This references `$M_FROM` and `$M_TO` which are globals set by `parse_manifest()`. While this works because `execute_manifest()` also uses these same globals (L718: `local backup_base="$TARGET/.tad-backup/${M_FROM}-to-${M_TO}"`), the function design creates a hidden dependency: `execute_merge_entry()` silently depends on `$TARGET`, `$M_FROM`, `$M_TO`, `$DRY_RUN`, and `$SOURCE` being set by the caller's context.

Compare with the existing `do_backup()` which explicitly receives `$backup_base` as a parameter. The handoff ALSO passes `$m_missing` as parameter 3 to `execute_merge_entry` but never uses it inside the function body (the function hardcodes `skipped-no-marker` behavior regardless of `$m_missing`).

**Impact**: If `execute_merge_entry` is ever called outside `execute_manifest()` (e.g., standalone test), it will silently get empty/stale globals. The unused `$m_missing` parameter is confusing.

**Fix**: Pass `backup_base` as a parameter (matching the `do_backup()` contract), and either use `$m_missing` to gate behavior or remove it from the signature. The simplest fix: pass `$backup_base` from the loop in Section 4.3 (where it's already a local variable in `execute_manifest`).

---

## P1 — Important Issues (Should Fix)

### P1-1: Temp file not cleaned up on failure between write and mv

**Location**: Handoff Section 4.5 (revised approach), L350-358

```bash
local tmp_file="${target_file}.merge-tmp"
{
    head -n $((source_marker_line - 1)) "$source_file"
    tail -n +"${marker_line_num}" "$target_file"
} > "$tmp_file"
mv -- "$tmp_file" "$target_file"
```

If the `mv` command fails (e.g., permission denied on target_file), the temp file `${target_file}.merge-tmp` is left on disk. Under `set -e`, the script exits immediately, but the stale `.merge-tmp` file remains. On a subsequent run, the temp file doesn't interfere (it gets overwritten by `>`), but it is still orphan litter.

More critically: if the `head`/`tail` pipeline fails (e.g., source_file deleted between check and use — TOCTOU), an empty or partial `.merge-tmp` is written, and then `mv` replaces the target with garbage. The original target is lost (backup exists, but the user sees a corrupted file).

**Impact**: Partial write + mv = user sees corrupted file until they restore from backup. The backup IS there, but the user must know to look.

**Fix**: Add a size/integrity check before mv, or use a trap to clean up the temp file:

```bash
local tmp_file="${target_file}.merge-tmp"
{
    if [ "$source_marker_line" -gt 1 ]; then
        head -n $((source_marker_line - 1)) "$source_file"
    fi
    tail -n +"${marker_line_num}" "$target_file"
} > "$tmp_file" || { rm -f "$tmp_file"; return 1; }

# Sanity: temp file should be non-empty (at minimum contains the marker line)
if [ ! -s "$tmp_file" ]; then
    rm -f "$tmp_file"
    report_line "merge" "error" "$m_path" "assembled file is empty"
    return 1
fi

mv -- "$tmp_file" "$target_file" || { rm -f "$tmp_file"; return 1; }
```

### P1-2: Idempotency check (Section 4.2 step 6) still uses variable capture for comparison, contradicting Section 4.5's direct-pipe mandate

**Location**: Handoff Section 4.2 L254-262, Section 4.5 expert-review resolution

Section 4.2 step 6 captures content in variables for the idempotency check:

```bash
local current_head=""
if [ "$marker_line_num" -gt 1 ]; then
    current_head="$(head -n $((marker_line_num - 1)) "$target_file")"
fi
if [ "$current_head" = "$source_head" ]; then
    report_line "merge" "already-current" ...
```

The expert review says "For idempotency check ONLY, variable comparison is acceptable because both sides are extracted the same way -- stripping is symmetric." This is correct for trailing newlines, but there is an edge case: if the content above the marker has embedded null bytes (unlikely but possible in a CLAUDE.md with certain content), `$(...)` will also strip those, making the comparison unreliable. More practically: if source_head is empty (marker at line 1) and current_head is also empty, the check reports `already-current` even if the target had content above its marker that differs from the source.

Wait -- re-reading: if source marker is at line 1, `source_head=""`. If target marker is at line 3, `current_head` will contain lines 1-2 of target. Then `"" != "lines 1-2"` so this correctly does NOT report already-current. The only issue is when BOTH are empty (both markers at line 1). In that case, already-current is correct.

**Revised assessment**: The symmetric-stripping argument is sound for this use case. However, the idempotency check is done BEFORE the direct-pipe write, and it uses step 4's `source_marker_line` variable. If Blake implements Section 4.2 literally (with variable capture) for steps 4-6 and then switches to Section 4.5's direct pipe for step 9, there will be TWO code patterns in the same function -- one using variable capture for the idempotency check and another using direct pipe for the write. This is confusing and Blake may accidentally use the variable-capture pattern for the write too.

**Fix**: The handoff should explicitly state in Section 4.2 that steps 4-6 (read + idempotency check) use variable capture intentionally, while step 9 (write) MUST use direct pipe. Add a comment annotation in the pseudocode: `# Variable capture OK here (comparison only, not disk write)`.

### P1-3: Missing fixture for source-file-missing edge case (FR8)

**Location**: Handoff Section 4.6, Section 8.1

FR8 says: "If source file does not exist at `$SOURCE/{path}`, report error and return failure." This is a `return 1` case that would cause `execute_merge_entry` to fail, which would then `|| return 1` from `execute_manifest`, which would `|| exit 1` from main.

But there is no fixture testing this case. F16-F19 cover: marker present, marker absent, idempotent, dry-run. None test the source-missing error path. AC14 checks `grep 'source file not found'` (string exists in the code) but does NOT verify the behavior works at runtime.

**Impact**: The source-missing error path is untested. If `execute_merge_entry` returns 1 for source-missing, does the engine fail-fast correctly? Without a fixture, this is a trust gap.

**Fix**: Add F20: source file missing for merge entry. Manifest has a merge entry pointing to a path that exists in TARGET but not in SOURCE. Assert: exit code 1, TSV contains `merge error`, target file unchanged.

---

## P2 — Suggestions (Consider)

### P2-1: Section 4.2 and Section 4.5 present two conflicting implementations

Section 4.2 gives the complete `execute_merge_entry()` function using variable capture (`source_head="$(head ...)"`, `target_tail="$(tail ...)"`, then `printf '%s\n'`). Section 4.5 then says "IMPORTANT" and "Use this approach" with a revised direct-pipe implementation. Blake must mentally merge these two sections, which risks confusion about which is authoritative.

**Suggestion**: Remove the write logic from Section 4.2 (steps 8-9) and replace with a forward reference: "See Section 4.5 for the write implementation (direct pipe, no variable capture)." Or consolidate into a single authoritative function.

### P2-2: `mv --` portability note contradicts expert review resolution

Section 4.5 uses `mv -- "$tmp_file" "$target_file"`. The expert review says "BSD mv supports `--`" which is correct for macOS `/bin/mv`. However, `mv --` is a GNU convention and while BSD/macOS mv does accept it, it is not documented in the POSIX spec for `mv`. Since this is a TAD framework targeting macOS primarily, this is fine in practice, but the expert review resolution could note it's not POSIX-strict.

**Suggestion**: Keep `mv --` (defense in depth), but add a comment in the implementation noting it's specifically for filenames starting with `-` and that macOS `/bin/mv` supports it.

### P2-3: The `on_missing_marker` field is parsed but hardcoded to one behavior

The handoff acknowledges this (Section 4.2 step 3 comment: "on_missing_marker is always skip_and_report (schema v1)") and `$m_missing` is passed to `execute_merge_entry` but never checked. This is forward-compatible design, but the unused parameter adds confusion (see P0-2).

**Suggestion**: Either add a `case "$m_missing" in skip_and_report) ...` guard (making it explicit and extensible), or remove `$m_missing` from the parameter list and add a comment: `# on_missing_marker: only skip_and_report in schema v1; parameter reserved for future strategies`.

### P2-4: No test for multiple markers in the same file

Section 8.3 documents "Multiple markers in file: First occurrence wins (grep head -1 pattern)" as an edge case. However, no fixture tests this. While unlikely in practice, a regression that changes from `head -1` to `tail -1` would silently corrupt user content (replacing everything above the LAST marker, not the first).

**Suggestion**: Add a fixture (F21) with a file containing the marker twice. Assert that only content above the FIRST marker is replaced, and content between the two markers is preserved.

---

## Positive Observations

1. **Direct-pipe pattern for byte-identity**: The Section 4.5 revised approach correctly avoids `$(...)` newline stripping. This is the right call and well-reasoned.

2. **Backup-before-merge**: Reuses existing `do_backup()` with the same `|| return 1` pattern as delete. Consistent and correct.

3. **Marker search uses `grep -nF`**: Fixed-string match avoids regex interpretation of `<!-- -->` characters. This is exactly right.

4. **Idempotency check design**: Symmetric variable capture for comparison-only is sound reasoning. The expert review correctly identified this as safe.

5. **Strategy dispatch with forward compatibility**: Unknown strategy falls through to `manual-required` instead of failing. Good forward-compat design.

6. **Fixture discrimination**: F17 (marker absent) and F16 (marker present) form a discriminative pair. F18 (idempotent) tests the negative of F16's precondition. Good fixture design.

7. **Alignment with sync-protocol.md**: The algorithm matches sync-protocol.md L86-88 exactly: find marker, replace above, preserve below. Semantic parity achieved.

---

## AC Verifiability Assessment

| AC | Verifiable? | Notes |
|----|-------------|-------|
| AC1 | Yes | `bash -n` is mechanical |
| AC2 | Yes | grep is mechanical |
| AC3 | Yes | grep pipeline is mechanical |
| AC4-AC9 | Yes | Fixture execution is mechanical |
| AC10 | Yes | grep is mechanical |
| AC11-AC12 | Yes | grep is mechanical |
| AC13 | Yes | grep absence check is mechanical |
| AC14 | Partial | Checks string exists in code, NOT that it works (see P1-3) |
| AC15 | Yes | grep is mechanical |

All ACs are post-impl-verifiable with mechanical commands. AC14 is the weakest -- it verifies the error string exists in source code but not that the error path actually executes correctly at runtime. Adding a fixture (P1-3) would make this fully verifiable.

---

## Verdict

**CONDITIONAL PASS** -- 2 P0, 3 P1 must be resolved before Blake begins implementation.

| Severity | Count | Blocking? |
|----------|-------|-----------|
| P0 | 2 | Yes -- counter logic bug + hidden global dependency |
| P1 | 3 | Yes -- temp file cleanup, code pattern confusion, missing fixture |
| P2 | 4 | No -- suggestions for clarity and completeness |
