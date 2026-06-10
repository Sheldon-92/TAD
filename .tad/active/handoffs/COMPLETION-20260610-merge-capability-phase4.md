# Completion Report: Merge Capability Phase 4

**Task ID:** TASK-20260610-001
**Epic:** EPIC-20260609-upgrade-lifecycle-system.md (Phase 4/6)
**Date:** 2026-06-10
**Implementer:** Blake (Agent B)

---

## Summary

Implemented the `tad-head-marker` merge strategy in the migration engine, replacing the `manual-required` placeholder with actual merge execution. The engine now reads the target file, finds the marker, replaces everything above the marker with source content, and preserves the marker and everything below (byte-identical).

## Files Modified

| File | Change |
|------|--------|
| `.tad/hooks/lib/migration-engine.sh` | Added `execute_merge_entry()` function, replaced merge loop with strategy dispatch, added `merged=` counter to summary, bumped ENGINE_VERSION to 2.29.0 |
| `.tad/tests/migration-fixtures/run-fixtures.sh` | Updated F8 (unknown strategy), added F16 (marker present), F17 (marker absent), F18 (idempotent), F19 (dry-run) |
| `.tad/evidence/designs/migration-manifest-schema-v1.md` | Added Marker Convention section + Legacy Projects documentation |

## P0/P1 Fixes Applied

| Fix | Description | Implementation |
|-----|-------------|----------------|
| P0-1 | Return convention: 0=done, 1=fatal, 2=skipped/already-current | `execute_merge_entry` returns 0/1/2; caller only increments merged on rc=0 |
| P0-2 | Explicit params instead of globals | Function signature: `execute_merge_entry m_path m_marker target_base source_base dry_run` |
| P1-1 | Guard temp file cleanup on pipeline failure | `cleanup_merge_tmp` helper; non-empty check before mv |
| P1-2 | Use mktemp for temp file | `mktemp "${target_file}.merge-XXXXXX"` instead of predictable path |
| P1-3 | Reject markers shorter than 10 characters | Length check at function entry: `${#m_marker} -lt 10` returns fatal |

## Acceptance Criteria Verification

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| AC1 | Engine syntax valid | PASS | `bash -n` exit 0 |
| AC2 | execute_merge_entry function exists | PASS | `grep -c 'execute_merge_entry()' = 1` |
| AC3 | tad-head-marker strategy dispatch | PASS | L922 checks strategy, L930 calls execute_merge_entry |
| AC4 | Unknown strategy -> manual-required | PASS | F8 PASS |
| AC5 | Merge with marker present | PASS | F16 PASS |
| AC6 | Merge with marker absent -> skip | PASS | F17 PASS |
| AC7 | Merge idempotent | PASS | F18 PASS |
| AC8 | Merge dry-run | PASS | F19 PASS |
| AC9 | All fixtures pass (no regression) | PASS | 19/19 passed |
| AC10 | Summary line includes merged counter | PASS | `merged=$merged` in summary report_line |
| AC11 | Marker convention documented | PASS | `grep -c 'Marker Convention' = 1` |
| AC12 | Legacy projects documented | PASS | `grep -c 'my-openclaw-agents' >= 1` |
| AC13 | No set +e in new code | PASS | `grep 'set +e'` returns empty |
| AC14 | Source file missing -> error | PASS | `grep 'source file not found' = 1` |
| AC15 | ENGINE_VERSION bumped | PASS | `ENGINE_VERSION="2.29.0"` |

## Fixture Results

```
=== TAD Migration Engine Fixture Harness ===

  PASS: F1 normal-upgrade
  PASS: F2 idempotent-rerun
  PASS: F3 user-modified-mixed
  PASS: F4 detection-unavailable
  PASS: F5 chain-upgrade+gap
  PASS: F6 malicious-zero-touch x3
  PASS: F7 malicious-path x4
  PASS: F8 unknown-strategy
  PASS: F9 dir-delete dual-branch
  PASS: F10 delete-only-no-verify
  PASS: F11 zt-authority-unavailable
  PASS: F12 rm-site-recheck
  PASS: F13 mid-chain-malformed
  PASS: F14 backup-collision
  PASS: F16 merge-marker-present
  PASS: F17 merge-marker-absent
  PASS: F18 merge-idempotent
  PASS: F19 merge-dry-run
  PASS: AC17 min_engine_version

Passed: 19 / 19 (18 fixtures + 1 inline AC17)
ALL FIXTURES PASS (19/19)
```

## Layer 1 Checks

| Check | Result | Notes |
|-------|--------|-------|
| `bash -n migration-engine.sh` | PASS | |
| `run-fixtures.sh` all pass | PASS | 19/19 |
| `rm` count | 2 (was 1) | Justified: original `guarded_remove` (L231, rm -rf for user files) + new `cleanup_merge_tmp` helper (L791, rm -f for mktemp-created temp files only). P1-1 explicitly requires temp cleanup. The new rm never touches user files. |
| No `set +e` | PASS | Uses `|| return 1` pattern per historical lesson |

## Design Decisions

1. **Direct pipe for byte-identity**: File content piped from `head`/`tail` directly to temp file, never stored in bash variables (avoids `$(...)` trailing newline stripping). Variable capture used only for idempotency check (symmetric stripping, not going to disk).

2. **cleanup_merge_tmp helper**: Single helper function for temp file cleanup, clearly separated from `guarded_remove` (which is the user-file deletion chokepoint). This satisfies P1-1 while maintaining the intent of the rm chokepoint constraint.

3. **mktemp with suffix**: `mktemp "${target_file}.merge-XXXXXX"` creates unpredictable temp filenames in the same directory as the target (same filesystem for atomic mv).

4. **Marker length guard (P1-3)**: Minimum 10 characters rejects empty/short markers that would cause `grep -F` to match every line.

## Sub-Agent Usage

None required. Implementation was straightforward with clear handoff specifications.
