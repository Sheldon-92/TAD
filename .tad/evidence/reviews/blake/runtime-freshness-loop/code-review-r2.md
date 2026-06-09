# Code Review Round 2
## Date: 2026-06-09
## Reviewer: code-reviewer (sub-agent)

## P1 Fix Verification

| P1# | Fix Description | Verified? | Evidence |
|-----|----------------|-----------|----------|
| F1 | `date_to_epoch()` with BSD-then-GNU fallback | YES | Function at L38-46. BSD path `date -j -f "%Y-%m-%d"` tested on macOS: correctly converts 2026-06-09 (epoch 1781021120) and 2026-04-30 (epoch 1777565120). `days_between` produces correct 40-day delta. GNU fallback `date -d` present at L42. Both paths use `2>/dev/null` + `&& return 0` to fall through silently. |
| F2 | `entry_result` variable tracks worst result; single counter increment via `case` | YES | `entry_result="pass"` initialized at L107. Age check sets `entry_result="block"` or `"warn"` (L114, L120, L125). Next-review overdue respects worst-result: HIGH always sets block (L143), non-HIGH only escalates to warn if not already block (L146). Single counter increment at L155-159 via `case "$entry_result"`. **Counter consistency proven** across 4 test fixtures (see below). |

## Counter Consistency Test

### Test 1: Basic mixed fixture (4 entries)

```
Codex #1: hooks, HIGH, 40d old (>30 BLOCK), next_review 10d overdue (HIGH BLOCK) -> single BLOCK
Codex #2: sandbox, MEDIUM, 39d old (<=60), next_review not overdue -> PASS
Codex #3: trace, LOW, 8d old (<=180), next_review not overdue -> PASS
Claude #1: compaction, MEDIUM, 8d old (<=60), next_review not overdue -> PASS
```

**Output**: `Total: 4 entries | PASS: 3 | WARN: 0 | BLOCK: 1`
**Arithmetic**: 3 + 0 + 1 = 4 = Total. **CONSISTENT.**

### Test 2: Double-trigger stress test (3 entries, all trigger BOTH age + next_review)

```
hooks: HIGH, 40d (BLOCK) + overdue (BLOCK) -> single BLOCK
mcp: MEDIUM, 69d (WARN) + overdue (WARN) -> single WARN
config_toml: LOW, 190d (WARN) + overdue (WARN) -> single WARN
```

**Output**: `Total: 3 entries | PASS: 0 | WARN: 2 | BLOCK: 1`
**Arithmetic**: 0 + 2 + 1 = 3 = Total. **CONSISTENT.**

### Test 3: Next-review-only trigger (age is fine, only next_review overdue)

```
mcp: MEDIUM, 20d old (<=60, no age issue), next_review 8d overdue -> WARN
```

**Output**: `Total: 1 entries | PASS: 0 | WARN: 1 | BLOCK: 0`
**Arithmetic**: 0 + 1 + 0 = 1 = Total. **CONSISTENT.**

### Test 4: `unknown_current_behavior` safety surface path

```
hooks: safety surface + unknown_current_behavior -> BLOCK (via continue at L105)
mcp: verified, fresh -> PASS
```

**Output**: `Total: 2 entries | PASS: 1 | WARN: 0 | BLOCK: 1`
**Arithmetic**: 1 + 0 + 1 = 2 = Total. **CONSISTENT.**

### Test 5: Production ledgers (21 entries)

**Output**: `Total: 21 entries | PASS: 21 | WARN: 0 | BLOCK: 0`
**Arithmetic**: 21 + 0 + 0 = 21 = Total. **CONSISTENT.**

## New Findings

| # | Severity | Location | Finding |
|---|----------|----------|---------|
| N1 | P2 | L38-46, L48-54 | `date_to_epoch()` exit propagation in nested command substitution. When `date_to_epoch` fails (e.g., impossible date "2026-13-45" that passes regex), `exit 2` inside `$(...)` only terminates the subshell, not the script. Under `set -euo pipefail`, the captured stdout "GATE: runtime-freshness exit=2" is assigned to `s1`, and subsequent arithmetic `$(( (s2 - s1) / 86400 ))` causes `set -u` to trigger "GATE: unbound variable" (bash interprets `$GATE` as a variable). **Practical impact: LOW** -- all date inputs are regex-validated before reaching `date_to_epoch` (L21 for TODAY, L95 for last_verified, L136 for next_review). Only semantically impossible but format-valid dates (month 0, month 13+, day 0) would trigger this. macOS `date` actually accepts some impossible dates like Feb 30 (wraps to Mar 2). **Fix when convenient**: Replace `exit 2` in `date_to_epoch` with `return 2`, and add `|| { echo "GATE: runtime-freshness exit=2"; exit 2; }` after the `date_to_epoch` calls in `days_between`. |

No P0 or P1 issues found.

## Summary

- P0: 0
- P1: 0 (both F1 and F2 fixed and verified with 5 independent test fixtures)
- P2: 6 (5 carried from R1 + 1 new: N1 date_to_epoch exit propagation in nested subshell)

## Verdict: PASS

Both P1 fixes are correctly implemented. Counter consistency `Total = PASS + WARN + BLOCK` holds across all test scenarios including edge cases. The new P2 finding (N1) has low practical impact due to upstream regex guards and does not block acceptance.
