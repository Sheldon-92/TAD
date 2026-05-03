# Spike A: Reviewer A (General-Purpose Agent) — Code Review Output

**Model**: Claude Sonnet 4.6 via general-purpose Agent tool (no code-reviewer persona)
**Target**: commit 95b154b — 2 bash files, 71 lines changed
**Wall-clock time**: ~44s (Agent tool call, measured by Blake session)
**Prompt**: Identical to Reviewer B (no additional context)

---

## Findings

| # | Severity | File | Issue | Suggestion |
|---|----------|------|-------|------------|
| 1 | P1 | `AC-P1.4-router-event-filter.sh` | **Race condition on `.router.log`**: `pre_count` captured before `_invoke_hook`, `post_count` after. If another process writes to `.router.log` between those two calls, `post_count > pre_count` is true even if this test's hook didn't cause the write. `last_pack` reflects the other process's entry. | Use `pre_count` to index: after hook returns, read `sed -n "$((pre_lines + 1)),\$p" "$log"` and take last of new lines. |
| 2 | P1 | `run-phase2b-tests.sh` | **Same race condition**: `pre_lines` captured before `subprocess.run`, then `lines = f.readlines()` after. Concurrent hook write corrupts attribution. `lines[-1]` may belong to different concurrent invocation. | After reading full file post-run, slice `lines[pre_lines:]` and take last element. |
| 3 | P1 | `run-phase2b-tests.sh` | **TOCTOU on log file open**: File opened twice — once to count `pre_lines`, once to read all lines. If file rotated/deleted between opens, second open raises `FileNotFoundError` (caught by outer `except Exception` but with wrong logic: `pre_lines=0` while new file has 0 lines → `len(lines) <= pre_lines` incorrectly true). | Open file once post-run with single `try/except`. |
| 4 | P1 | `run-phase2b-tests.sh` | **`ratio == "0"` check is string-fragile**: If hook ever emits `0/13` (zero matches out of N), `ratio == "0"` is False and treated as valid match. Log format comment says `<matched/total\|0>` — sentinel `0` and `matched/total` form are conflated in one field. | Check `ratio.startswith("0/") or ratio == "0"` to cover both forms, or enforce hook uses distinct sentinel token. |
| 5 | P1 | `run-phase2b-tests.sh` | **`import os` inside function body on every call**: Python caches imports so not a correctness bug, but signals import belongs at module top-level. | Move `import os` to top-level import block. |
| 6 | P1 | `AC-P1.4-router-event-filter.sh` | **`wc -l` on non-existent file / async flush assumption**: If hook creates log file asynchronously (hook returns before log flush), `post_count` will be total line count, not delta. Logic is order-dependent and breaks on async flush. | Add sync barrier or retry loop, or document assumption. |
| 7 | P2 | `AC-P1.4-router-event-filter.sh` | **`tail -1 "$log" 2>/dev/null \| awk '{print $3}'` no guard on awk empty output**: If last line malformed (<3 fields), awk outputs empty string. `last_pack=""` falls through to FAIL with misleading `got:` (blank). | Add `[ -z "$last_pack" ] && last_pack="LOG_PARSE_ERR"` after awk call. |
| 8 | P2 | `run-phase2b-tests.sh` | **`return (None, f"LOG_PARSE_ERR:{last}")` leaks list repr**: When `len(last) < 5`, `last` is a Python list. `f"LOG_PARSE_ERR:{last}"` produces `LOG_PARSE_ERR:['2026-04-27T09:30:59']`. | Use `f"LOG_PARSE_ERR:{'|'.join(last)}"`. |
| 9 | P2 | `AC-P1.4-router-event-filter.sh` | **`wc -l` platform variation**: BSD/macOS `wc -l` pads with leading spaces. `tr -d ' '` strips correctly. But `${var:-0}` fallback only triggers on empty string, not `" "` — could cause integer comparison failure. | Use `awk 'END{print NR}' "$log" 2>/dev/null` (portable, whitespace-free). |
| 10 | P2 | `run-phase2b-tests.sh` | **`lines = f.readlines()` loads entire log into memory**: Long test suites produce large `.router.log`. | Slice `lines[pre_lines:]` after read (correct), but cap read at reasonable line count. |
| 11 | P2 | `AC-P1.4-router-event-filter.sh` | **No timeout on `_invoke_hook`**: If hook hangs, CI runs silently hang rather than fail fast. | Wrap with `timeout 10 _invoke_hook ...`, check exit code 124. |

## Summary
- P0 (must fix): 0
- P1 (should fix): 6
- P2 (nice to have): 5
