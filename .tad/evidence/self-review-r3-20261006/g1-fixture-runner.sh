#!/usr/bin/env bash
# g1-fixture-runner.sh — R3 group 1 fixture runner.
#
# Runs the repo's state-surface-check.sh against the five fixture trees
# in ./g1-fixtures/ and asserts the per-tree expectations of
# HANDOFF-2026-10-06-self-review-r3 §4.1.4: the shared skeleton keeps
# check1-7 green on every tree, so each tree's exit code and FAIL lines
# are attributable to check8 alone.
#
#   pos         current header block + P2 bullet           -> exit 0, PASS check8
#   neg         incident header block (verbatim) + P2      -> exit 1, exactly one
#               FAIL line, check8, naming 'no lifecycle hooks'
#   exempt      current block + registered in-block note   -> exit 0, PASS check8
#   outside     current block + stale wording OUTSIDE the  -> exit 0, PASS check8
#               governed block
#   undecidable current block, P2 bullet absent            -> exit 1, FAIL check8
#               naming 'fact-source anchor missing'
#
# Per-tree raw output lands in g1-fixture-<tree>.log next to this
# script; assertion results land in g1-fixture-summary.log.
# Exit 0 = every assertion holds. Baseline tools only (bash/grep).
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$HERE/../../.." && pwd)"
CHECK="${1:-$REPO_ROOT/.tad/hooks/lib/state-surface-check.sh}"
TREES_DIR="$HERE/g1-fixtures"
SUMMARY="$HERE/g1-fixture-summary.log"

fails=0
note() { printf '%s\n' "$1" | tee -a "$SUMMARY"; }
: > "$SUMMARY"

run_tree() {
  local tree="$1" want_exit="$2" mode="$3"
  local log="$HERE/g1-fixture-$tree.log"
  bash "$CHECK" --repo "$TREES_DIR/$tree" > "$log" 2>&1
  local got_exit=$?
  local fail_lines
  fail_lines="$(grep -c '^FAIL' "$log" || true)"
  if [ "$got_exit" -ne "$want_exit" ]; then
    note "ASSERT-FAIL $tree: exit=$got_exit, expected $want_exit (FAIL lines=$fail_lines)"
    fails=$((fails + 1))
    return
  fi
  case "$mode" in
    pass)
      if grep -q '^PASS check8' "$log" && [ "$fail_lines" -eq 0 ]; then
        note "ASSERT-OK $tree: exit=$got_exit, PASS check8 present, FAIL lines=$fail_lines"
      else
        note "ASSERT-FAIL $tree: expected PASS check8 and zero FAIL lines (FAIL lines=$fail_lines)"
        fails=$((fails + 1))
      fi
      ;;
    neg)
      if [ "$fail_lines" -eq 1 ] && grep '^FAIL check8' "$log" | grep -Fq -e 'no lifecycle hooks'; then
        note "ASSERT-OK $tree: exit=$got_exit, exactly one FAIL line (check8, names 'no lifecycle hooks')"
      else
        note "ASSERT-FAIL $tree: expected exactly one FAIL line = check8 naming 'no lifecycle hooks' (FAIL lines=$fail_lines)"
        fails=$((fails + 1))
      fi
      ;;
    undecidable)
      if grep '^FAIL check8' "$log" | grep -Fq -e 'fact-source anchor missing'; then
        note "ASSERT-OK $tree: exit=$got_exit, FAIL check8 names 'fact-source anchor missing'"
      else
        note "ASSERT-FAIL $tree: expected FAIL check8 naming 'fact-source anchor missing'"
        fails=$((fails + 1))
      fi
      ;;
  esac
}

run_tree pos 0 pass
run_tree neg 1 neg
run_tree exempt 0 pass
run_tree outside 0 pass
run_tree undecidable 1 undecidable

if [ "$fails" -eq 0 ]; then
  note "g1-fixture-runner: ALL TREES OK (5/5)"
  exit 0
else
  note "g1-fixture-runner: $fails assertion(s) failed"
  exit 1
fi
