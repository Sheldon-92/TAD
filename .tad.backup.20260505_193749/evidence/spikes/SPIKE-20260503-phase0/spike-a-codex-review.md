# Spike A: Reviewer B (Codex CLI) — Code Review Output

**Model**: Codex CLI (gpt-5.5 via ChatGPT account)
**Target**: commit 95b154b via stdin fallback (diff piped to `codex exec --full-auto`)
**Invocation**: `{ echo "Review this git diff:"; echo ""; cat /tmp/spike-a-diff.txt; } | codex exec --full-auto "..."`
**Wall-clock time**: 28s
**Note on `codex exec review --commit`**: Command failed — `--commit` and `--full-auto [PROMPT]` cannot be used together. Used stdin fallback per handoff §2.3 fallback instructions.
**Prompt**: Identical to Reviewer A (same generic prompt, no code-reviewer persona)

---

## Findings

| # | Severity | File | Issue | Suggestion |
|---|----------|------|-------|------------|
| 1 | P1 | `run-phase2b-tests.sh` | **Race condition on `.router.log`**: `run_case()` counts lines before invoking hook, then reads `lines[-1]` after. Concurrent hook write produces false pass/fail. | Read only `lines[pre_lines:]` and select first line attributable to this invocation. Better: add per-invocation nonce/request id. |
| 2 | P1 | `AC-P1.4-router-event-filter.sh` | **Same race condition**: `_assert_match()` uses log line-count delta + `tail -1`. Concurrent invocations can validate wrong entry. Tests can pass for wrong prompt or fail nondeterministically under parallel runs. | Capture and inspect only appended lines after `pre_count`, or add invocation id. |
| 3 | P2 | `AC-P1.4-router-event-filter.sh` | **`wc -l < "$log" 2>/dev/null \| tr -d ' '`** can still emit shell redirection error in some shells when `$log` does not exist. | Use file existence guard: `if [ -f "$log" ]; then pre_count=$(wc -l < "$log" | tr -d ' '); else pre_count=0; fi`. |
| 4 | P2 | `run-phase2b-tests.sh` | **`os.path.dirname(hook)` without abspath**: If caller passes just `router.sh` (no directory component), `dirname()` is empty and code reads `.router.log` from current working directory. | Normalize: `hook_dir = os.path.dirname(os.path.abspath(hook))`. |
| 5 | P2 | `run-phase2b-tests.sh` | **`ratio == "0"` check is fragile**: If future logs write `0/13`, numerator-zero form is not handled. | Parse structurally: treat `"0"` and strings whose numerator is `0` as no match. |

## Summary
- P0 (must fix): 0
- P1 (should fix): 2
- P2 (nice to have): 3
