# Phase 4 Implementation Review — Merge Capability

**Reviewer**: Code Review (impl-review-cr)
**Date**: 2026-06-10
**Commit**: 68e2e46
**Scope**: migration-engine.sh `execute_merge_entry()` + F16-F19 fixtures
**Verdict**: PASS (0 P0, 2 P1, 3 P2)

---

## P0 Checklist (from review request)

| # | Check | Result | Evidence |
|---|-------|--------|----------|
| 1 | `execute_merge_entry` returns 0/1/2 correctly | PASS | L738=2 (skip), L746=2 (skip), L754=1 (fatal), L769=2 (already-current), L775=2 (dry-run), L818=0 (done). Only `return 0` on actual merge. |
| 2 | Caller only increments `merged` on rc=0 | PASS | L932: `if [ "$merge_rc" -eq 0 ]; then merged=$((merged + 1)); fi` — rc=2 skips increment |
| 3 | Function receives explicit params (no globals for TARGET/SOURCE/DRY_RUN) | PASS (with note) | L718: 5 explicit params. Uses lowercase `$dry_run` at L773, not global `$DRY_RUN`. **Note**: L721 still uses globals `$M_FROM`/`$M_TO` for backup path — see P2-1 |
| 4 | `grep -F` used (no regex) | PASS | L743, L751: both use `grep -nF` (fixed-string match) |
| 5 | Temp file cleaned up on failure | PASS | L799, L806, L812: all failure paths call `cleanup_merge_tmp` before returning |
| 6 | Single `rm` preserved | PASS (justified addition) | `rm` count = 2: L231 (`guarded_remove`, existing user-file rm) + L791 (`cleanup_merge_tmp`, temp-file-only rm). New rm never touches user files. Distinct chokepoints. |
| 7 | All fixtures pass | PASS | 19/19 pass (live run confirmed) |

---

## P1 Issues (Should Fix)

### P1-1: Nested function `cleanup_merge_tmp` leaks to global scope on every call

**Location**: `.tad/hooks/lib/migration-engine.sh` L791

**Problem**: `cleanup_merge_tmp()` is defined inside `execute_merge_entry()` at L791. In bash, nested function definitions are NOT scoped to the enclosing function — they pollute the global namespace. Every call to `execute_merge_entry` redefines this global function. This works today (redefinition is idempotent), but:
- It's misleading — the code structure suggests local scoping that doesn't exist
- If a future function defines its own `cleanup_merge_tmp` for a different purpose, the last caller wins
- Multiple concurrent invocations (if ever parallelized) would race on the definition

**Suggested fix**: Move the function definition above `execute_merge_entry()` as a peer-level function (same pattern as `guarded_remove` and `do_backup`). Alternatively, inline the cleanup logic at each call site since it's a one-liner.

```bash
# Move BEFORE execute_merge_entry, as a top-level helper
cleanup_merge_tmp() { [ -n "${1:-}" ] && [ -f "$1" ] && rm -f -- "$1"; }
```

### P1-2: Handoff design pseudocode had `return 0` for target-not-found but implementation correctly returns `return 2` — deviation is correct but undocumented

**Location**: Handoff Section 4.2 L227 vs implementation L738

**Problem**: The handoff pseudocode at Section 4.2 step 2 says `return 0  # not a failure, just skip` for target-not-found. The actual implementation correctly returns `return 2` (matching the documented convention 0=done, 2=skipped). The implementation is correct and the handoff pseudocode had a bug. The completion report does not mention this deviation.

**Impact**: Low (the implementation is correct). But the completion report should have called out the handoff deviation as a design-fix to maintain audit trail integrity.

**Suggested fix**: Add a note to the completion report documenting this handoff-deviation-fix, e.g.: "Handoff Section 4.2 step 2 had `return 0` for target-not-found; corrected to `return 2` per the documented convention."

---

## P2 Issues (Consider)

### P2-1: `M_FROM`/`M_TO` globals used inside `execute_merge_entry` despite P0-2 intent

**Location**: `.tad/hooks/lib/migration-engine.sh` L721

**Problem**: P0-2 mandated "explicit params instead of globals" but only scoped it to `TARGET/SOURCE/DRY_RUN`. L721 constructs `backup_base` using globals `$M_FROM` and `$M_TO`. These are manifest-parser globals that are stable within a manifest execution, so this is safe. However, if the function were ever called outside `execute_manifest` (e.g., unit testing), it would silently depend on unset globals.

**Suggested fix (future)**: Either pass `M_FROM`/`M_TO` as params 6-7, or pass the pre-computed `backup_base` directly. This is consistent with how `execute_manifest` already computes `backup_base` at L826.

### P2-2: `grep -F` matches marker as substring, not whole-line

**Location**: `.tad/hooks/lib/migration-engine.sh` L743

**Problem**: `grep -nF "$m_marker"` will match any line that contains the marker as a substring, e.g., `some text <!-- TAD:PROJECT-CONTENT-BELOW --> more text`. The handoff convention says "The marker MUST be on its own line" (Section 3.3), so this should not occur in practice. But the code doesn't enforce whole-line matching.

**Suggested fix (optional)**: Use `grep -nxF "$m_marker"` (the `-x` flag requires the entire line to match). This would enforce the "own line" convention at the code level. Evaluate whether existing CLAUDE.md files might have leading/trailing whitespace on the marker line — if so, `-x` would break them.

### P2-3: F18 idempotency fixture removes backup dir between runs

**Location**: `.tad/tests/migration-fixtures/run-fixtures.sh` F18 (in diff)

**Problem**: F18 removes `$tgt/.tad-backup` between the first and second run (`rm -rf "$tgt/.tad-backup"`). This is necessary because `do_backup` refuses to overwrite existing backups, so the second run would fail at backup, not at the idempotency check. The fixture works correctly, but it tests the idempotency check in isolation from the backup-collision guard. A real-world second run (without backup cleanup) would fail at `do_backup` before reaching the idempotency check — which is arguably the correct behavior (don't re-merge if backup already exists), but the fixture doesn't document this interaction.

**Suggested fix**: Add a comment in the fixture explaining why backup removal is necessary and what would happen without it.

---

## Positive Observations

1. **Direct pipe for byte-identity** (L793-798): Content flows from `head`/`tail` directly to the temp file, never stored in bash variables. This correctly avoids `$(...)` trailing-newline stripping — the key byte-identity guarantee.

2. **mktemp with suffix** (L784): `mktemp "${target_file}.merge-XXXXXX"` creates unpredictable temp files in the same directory as target (same filesystem for atomic `mv`).

3. **Non-empty guard** (L804-808): Refuses to `mv` an empty temp file onto the target. Defense-in-depth against a scenario where both `head` and `tail` produce nothing.

4. **Return code convention** (0/1/2): Clean separation of semantics — caller can distinguish "something changed" (0) from "nothing needed" (2) from "broken" (1). The caller correctly fail-fasts on 1 and ignores 2.

5. **Fixture quality**: F16 uses `cmp -s` on the tail content (marker + below) to verify byte-identity. F17 uses `cmp -s` on the whole file. F18 tests actual idempotency. F19 verifies both output message and file immutability. All four test meaningful conditions.

6. **Marker length guard** (L723-726): Rejects markers under 10 characters, preventing `grep -F ""` from matching every line.

---

## Summary

The implementation is solid. All 7 P0-critical checks pass. The return code convention is correctly implemented (deviation from handoff pseudocode was a correct fix). The 2 P1 issues are real but non-blocking: the nested function definition is a bash scoping misunderstanding that works in practice, and the undocumented handoff deviation is an audit gap. The 3 P2 items are future-proofing suggestions.

Fixtures are well-designed with proper byte-identity assertions (`cmp -s`), and the direct-pipe approach correctly solves the trailing-newline problem that the handoff's expert reviewers identified.
