# Code Review Round 3
## Date: 2026-06-09
## Reviewer: code-reviewer (sub-agent)

## N1 Fix Verification

- date_to_epoch: returns 1 on failure? **YES** (line 43: `return 1`)
- days_between: catches return code with || exit 2? **YES** (lines 49-50: `|| { echo ERROR >&2; echo GATE; exit 2; }`)
- exit 2 runs in main script context? **PARTIAL** -- see N2 below

### Detail

The fix correctly addresses the original N1 bug at the `date_to_epoch` level:
- `date_to_epoch` now uses `return 1` instead of `exit 2` (line 43)
- `days_between` catches the failure with `|| { ... exit 2; }` on lines 49 and 50
- When `days_between` is called **directly** (not via `$(...)`), the `exit 2` terminates the main script

However, `days_between` is **never called directly**. It is always called via command substitution:
- Line 106: `age=$(days_between "$last_ver" "$TODAY")`
- Line 136: `review_age=$(days_between "$next_rev" "$TODAY")`

This means the `exit 2` inside `days_between`'s error handler terminates the `$(...)` subshell, not the main script -- the **same bug class** as the original N1, shifted one level up.

**Saving grace**: `set -e` (line 5) catches the non-zero exit from the failed command substitution and terminates the main script. The **exit code is correct (2)**. But the `echo "GATE: runtime-freshness exit=2"` output is captured into the variable (`$age` or `$review_age`) instead of being printed to stdout. The GATE line is **swallowed**.

## Fixture Results

| # | Test | Expected | Actual | Status |
|---|------|----------|--------|--------|
| 1 | invalid last_verified `2026-13-45` in ledger row | exit 2 + GATE line on stdout | exit 2 (correct), stderr has ERROR, **stdout missing GATE line** (captured into `$age`) | PARTIAL -- exit code correct, GATE line swallowed |
| 2 | invalid TODAY `2026-13-45` (passes regex, fails semantic parse) | exit 2 + GATE line on stdout | exit 2 (correct), stderr has ERROR, **stdout missing GATE line** (captured into `$age`) | PARTIAL -- exit code correct, GATE line swallowed |
| 3 | current real ledgers (`2026-06-09`) | exit 0, 21 PASS | exit 0, `Total: 21 | PASS: 21 | WARN: 0 | BLOCK: 0`, VERDICT: PASS | PASS |
| 4 | stale high-vol fixture (last_verified `2026-04-30`, 40 days) | exit 1, BLOCK | exit 1, `Total: 4 | PASS: 2 | WARN: 0 | BLOCK: 2`, VERDICT: BLOCK, `GATE: runtime-freshness exit=1` | PASS |
| 5 | counter Total = PASS + WARN + BLOCK (stale fixture) | 2 + 0 + 2 = 4 = Total | 2 + 0 + 2 = 4 = 4 | PASS |

### Fixture reproduction commands

```bash
# Test 1: invalid last_verified
FIXTURE_DIR=$(mktemp -d) && mkdir -p "$FIXTURE_DIR/.tad/runtime-compat"
# ... (codex.md with last_verified=2026-13-45, claude-code.md empty table)
bash .tad/hooks/lib/runtime-freshness-verify.sh "$FIXTURE_DIR" "2026-06-09"
# stdout: banner only. stderr: ERROR: cannot parse date '2026-13-45'. Exit: 2.
# GATE: line is MISSING from stdout (captured into $age variable).

# Test 2: invalid TODAY
bash .tad/hooks/lib/runtime-freshness-verify.sh . "2026-13-45"
# stdout: banner only. stderr: ERROR: cannot parse date '2026-13-45'. Exit: 2.
# GATE: line is MISSING from stdout.

# Test 3: current ledgers
bash .tad/hooks/lib/runtime-freshness-verify.sh . "2026-06-09"
# Total: 21 entries | PASS: 21 | WARN: 0 | BLOCK: 0. Exit: 0.

# Test 4: stale high-vol
# (codex.md with 2 high-vol entries last_verified=2026-04-30 + 1 fresh medium)
bash .tad/hooks/lib/runtime-freshness-verify.sh "$FIXTURE_DIR" "2026-06-09"
# BLOCK x2, PASS x2. Total: 4. Exit: 1.
```

### Trace evidence for N2 (bash -x)

```
++ days_between 2026-13-45 2026-06-09
++ local d1=2026-13-45 d2=2026-06-09
++ local s1 s2
+++ date_to_epoch 2026-13-45
+++ local d=2026-13-45
+++ date -j -f %Y-%m-%d 2026-13-45 +%s
+++ date -d 2026-13-45 +%s
+++ return 1           # <-- date_to_epoch correctly returns 1
++ s1=                  # <-- || handler fires
++ echo 'ERROR: cannot parse date '\''2026-13-45'\'''
++ echo 'GATE: runtime-freshness exit=2'
++ exit 2              # <-- exits the $() subshell, NOT main script
+ age='GATE: runtime-freshness exit=2'  # <-- GATE line captured into $age
                       # set -e then kills the script (exit code 2 is correct)
```

## New Findings

| # | Severity | Location | Finding |
|---|----------|----------|---------|
| N2 | P2 | L49-50 + L106, L136 | **GATE line swallowed on date-parse failure (same bug class as N1, one level up).** `days_between` is always called via `$(...)` (lines 106, 136), so `exit 2` inside the `|| { ... }` handler terminates the subshell, not the main script. `set -e` then correctly terminates the main script with exit code 2, so **the exit code is correct**. However, the `echo "GATE: runtime-freshness exit=2"` output is captured into `$age`/`$review_age` instead of being printed to stdout. The handoff spec (HANDOFF-20260609-runtime-freshness-loop.md) requires `GATE: runtime-freshness exit=<n>` on non-zero exits. **Impact: LOW** -- the exit code (the machine-parseable contract) is correct; only the human-readable GATE annotation is lost. The ERROR message does reach stderr. Upstream regex guards (L21, L93) prevent most invalid dates from reaching this path; only semantically impossible but format-valid dates (month 13, day 45) trigger it. **Fix when convenient**: change `days_between` to return 1 on failure (same pattern as the `date_to_epoch` fix), and add `|| { echo ERROR >&2; echo "GATE: ..."; exit 2; }` at the call sites (lines 106, 136) where the function runs in main-script context, not inside `$(...)`. Alternatively, redirect the GATE echo to stderr (`>&2`) so it is never captured by command substitution. |

### N2 severity rationale

Classified as P2, not P1, because:
1. **Exit code is correct** (2) -- `set -e` propagates the subshell failure to the main script
2. **The ERROR diagnostic reaches stderr** -- operators see what went wrong
3. **Only the GATE annotation line is lost** -- this is a logging/observability gap, not a behavioral correctness bug
4. **Trigger conditions are narrow** -- requires a semantically impossible but format-valid date (e.g., month 13) to bypass the upstream regex guard
5. The original N1 was worse because without `set -e` awareness, the script could have continued with garbage in `$age` -- but `set -e` prevents that

### Suggested fix (copy-paste ready)

```bash
days_between() {
  local d1="$1" d2="$2"
  local s1 s2
  s1=$(date_to_epoch "$d1") || { echo "ERROR: cannot parse date '$d1'" >&2; return 1; }
  s2=$(date_to_epoch "$d2") || { echo "ERROR: cannot parse date '$d2'" >&2; return 1; }
  echo $(( (s2 - s1) / 86400 ))
}

# At call sites (lines 106, 136):
age=$(days_between "$last_ver" "$TODAY") || { echo "GATE: runtime-freshness exit=2"; exit 2; }
review_age=$(days_between "$next_rev" "$TODAY") || { echo "GATE: runtime-freshness exit=2"; exit 2; }
```

This pattern ensures:
- `date_to_epoch` returns 1 on failure (already done)
- `days_between` returns 1 on failure (new: mirrors the date_to_epoch pattern)
- The GATE echo runs in main-script context at the call site (not inside `$(...)`)
- The `exit 2` at the call site runs in main-script context (not a subshell)

## Summary

- P0: 0
- P1: 0
- P2: 6 total (5 carried from R1 [F3-F7] + 1 new N2: GATE line swallowed in subshell)

### P2 inventory

| # | Source | Description | Status |
|---|--------|-------------|--------|
| F3 | R1 | Unquoted `$FRESH_TODAY` in release-verify.sh | Carried, acknowledged |
| F4 | R1 | No WARN for non-safety `unknown_current_behavior` | Carried, acknowledged |
| F5 | R1 | Fragile header regex; silent empty parse | Carried, acknowledged |
| F6 | R1 | SAFETY_SURFACES as string not array | Carried, acknowledged |
| F7 | R1 | skill_loading volatility discrepancy (high vs Phase 1 medium) | Carried, acknowledged |
| N2 | R3 | GATE line swallowed when days_between called via $() | New (this round) |

Note: R2's N1 (date_to_epoch exit propagation) is now **resolved** -- the fix correctly addresses that level. N2 is the residual at the next nesting level.

## Verdict: PASS

The N1 fix is correctly implemented. `date_to_epoch` uses `return 1`, and `days_between` catches it with `|| { ... exit 2; }`. The script terminates with the correct exit code in all tested scenarios. The new N2 finding (GATE line swallowed) is P2 severity -- the exit code contract is intact, only the human-readable annotation is lost under narrow trigger conditions. No P0 or P1 issues found.
