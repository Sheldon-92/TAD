# Security Review: Phase 4 Merge Capability (migration-engine.sh)

**Reviewer**: Security Auditor (impl-review-sec)
**Commit**: 68e2e46 (with fixups through db794e0)
**Scope**: `execute_merge_entry()` function + merge dispatch in `execute_manifest()` (L717-L819, L917-L934)
**Date**: 2026-06-10

---

## Verification Matrix (requested checks)

| Property | Verdict | Evidence |
|----------|---------|----------|
| Marker treated as literal (grep -F) | PASS | L743: `grep -nF "$m_marker"`, L751: `grep -nF "$m_marker"`. Both use `-F` (fixed string). No regex interpretation of marker content. |
| Temp file uses mktemp / unpredictable name | PASS | L784: `mktemp "${target_file}.merge-XXXXXX"`. Six random chars. No predictable path. |
| No eval/source of content | PASS | Zero `eval` in file. All `source` occurrences are variable names (source_base, source_file, source_head, source_marker_line), not the `source` builtin. Content never loaded into an execution context. |
| Write cannot escape containment | PASS | Merge paths pass `validate_full()` at L471 (validate_path + check_containment + check_zero_touch). Backup goes through `do_backup()` which re-checks containment at L649. mv target is the same validated path. |
| Short marker rejected | PASS | L724: `${#m_marker} -lt 10` returns fatal (rc=1). Min 10 chars. |

---

## Findings

### P0: None

No P0 findings. The core security properties are correctly implemented.

### P1: None

All previously identified P1 issues (P1-1 temp cleanup, P1-2 mktemp, P1-3 short marker) are confirmed fixed in this commit.

### P2 Findings

#### P2-1: Global `M_FROM`/`M_TO` used inside `execute_merge_entry` despite P0-2 "explicit params instead of globals"

- **Severity**: P2 (Low - design inconsistency, not exploitable)
- **Location**: L721 `local backup_base="$target_base/.tad-backup/${M_FROM}-to-${M_TO}"`
- **Description**: The completion report states P0-2 was fixed ("Explicit params instead of globals — Function signature: `execute_merge_entry m_path m_marker target_base source_base dry_run`"). The function does receive target_base and source_base as params, but still reads `M_FROM` and `M_TO` as globals for constructing the backup path. This is not a security vulnerability because `M_FROM`/`M_TO` are parsed from the manifest and validated (filename-field invariant at L434-440), and `do_backup()` independently re-validates containment. However, it contradicts the stated P0-2 fix and creates an implicit coupling.
- **Impact**: If `execute_merge_entry` were ever called outside the `execute_manifest` loop (where `M_FROM`/`M_TO` are set by `parse_manifest`), the backup path would use stale/empty globals. Currently not exploitable because the call chain is `main -> execute_manifest -> execute_merge_entry` and `parse_manifest` always runs first.
- **Remediation**: Pass `M_FROM` and `M_TO` as additional function parameters, or pass the pre-computed `backup_base` directly (which `execute_manifest` already constructs at L826 but doesn't pass).

#### P2-2: `cleanup_merge_tmp()` redefined on every invocation inside function body

- **Severity**: P2 (Low - correctness risk, not security)
- **Location**: L791 `cleanup_merge_tmp() { ... }` inside `execute_merge_entry()`
- **Description**: The helper function is redefined every time `execute_merge_entry` is called. In bash, nested function definitions create global-scope functions. If `execute_merge_entry` is called multiple times in a loop (which it is, at L930), each call redefines `cleanup_merge_tmp`. This is functionally harmless because the definition is identical each time, but it is unusual and could mask a bug if the definition were accidentally made call-dependent.
- **Impact**: None currently. The function is stateless and its argument is always the local `$tmp_file`.
- **Remediation**: Move `cleanup_merge_tmp()` to file-level scope alongside `guarded_remove()`, or define it once before the merge loop.

#### P2-3: Source file path not independently contained within SOURCE directory

- **Severity**: P2 (Low - defense-in-depth gap)
- **Location**: L720 `local source_file="$source_base/$m_path"`, used at L730, L751, L762, L795
- **Description**: `validate_full()` at L471 validates merge paths against `$TARGET` (the target directory). The source path `$source_base/$m_path` is constructed from the same `m_path` but is never independently containment-checked against `$SOURCE`. Since `m_path` passes `validate_path()` (no `..`, no absolute paths, no symlinks, prefix allow-list), this is already well-protected. However, `check_containment()` with its physical-resolve symlink walk is only applied to the target side.
- **Impact**: If the SOURCE directory contained a symlink at a component of `m_path`, the source read could follow it outside SOURCE. This requires the SOURCE (framework repo) to be compromised, which is outside the normal threat model (the source is the trusted upstream). Not exploitable under normal conditions.
- **Remediation**: Consider calling `check_containment "$SOURCE" "$m_path"` as defense-in-depth, or document that SOURCE is treated as trusted.

#### P2-4: Info disclosure of full source path in error message

- **Severity**: P2 (Informational)
- **Location**: L731 `report_line "merge" "error" "$m_path" "source file not found: $source_file"`
- **Description**: The error detail includes the full filesystem path of the source file (`$source_base/$m_path`). In a migration engine running locally this is acceptable, but it reveals the absolute path of the framework source directory to anyone reading the TSV report.
- **Impact**: Minor information disclosure. The TSV report is written to the target's `.tad-backup/` directory which is already a local artifact.
- **Remediation**: Optional. Could replace `$source_file` with `$m_path` in the error message if path privacy is desired.

---

## Positive Security Properties Confirmed

1. **No eval/source of file content**: Content flows through `head`/`tail` pipes directly to temp file. Variable capture (`$()`) is used only for the idempotency check (L762/L765), and the comment at L758-759 correctly documents this is symmetric and not written to disk.

2. **Marker is never interpreted as regex**: Both grep calls use `-F` (fixed-string mode). A marker containing regex metacharacters (`.`, `*`, `[`, etc.) is treated literally.

3. **Temp file is unpredictable**: `mktemp` with 6-char random suffix. Same-directory placement ensures same-filesystem for atomic `mv`.

4. **Non-empty guard before mv**: L805 prevents replacing target with empty file if the pipe assembly fails silently.

5. **Backup before write**: L779 calls `do_backup()` which creates a copy before any modification, and refuses to overwrite existing backups (L655).

6. **Path validation is complete**: Merge paths go through the same 5-step validation (validate_path -> check_containment -> check_zero_touch) as delete/rename paths at manifest validation time (L471).

7. **Strategy dispatch is closed**: Only `tad-head-marker` is executed (L922). Unknown strategies fall through to `manual-required` report (L923), never executed.

8. **Return convention is correct**: rc=0 (done), rc=1 (fatal -> fail-fast at L931), rc=2 (skipped/already-current -> no count increment). Fatal errors stop the chain immediately.

9. **No `set +e` in new code**: Confirmed 0 occurrences. Error handling uses `|| return 1` pattern throughout.

10. **Marker minimum length (10 chars)**: Prevents empty/short markers from matching every line via `grep -F ""`.

---

## Summary

| Severity | Count | Items |
|----------|-------|-------|
| P0 | 0 | -- |
| P1 | 0 | -- |
| P2 | 4 | Global M_FROM/M_TO coupling, cleanup_merge_tmp redefinition, source containment gap, info disclosure |

**Verdict**: PASS. The merge implementation is sound. All 5 requested security properties are verified. The 4 P2 findings are defense-in-depth improvements, none exploitable under the current threat model. No blocking issues.
