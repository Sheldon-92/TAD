#!/bin/bash
# cora-check-budget-fixture.sh - the Budget-line forms `cora-check.sh dispatches` reads an estimate from.
# Each .tad/tests/cora-check-fixtures/bd-<x>/ holds one Epic (count 0) and `expected-estimate` (a number, or
# `none`). A number must print `estimate: <N>`; `none` must print the no-estimate note; exit 0 either way.
# Bash 3.2 safe. Run from anywhere: bash .tad/tests/cora-check-budget-fixture.sh
HERE="$(cd "$(dirname "$0")" && pwd -P)"
CHECK="$HERE/../hooks/lib/cora-check.sh"
fail=0
for d in "$HERE"/cora-check-fixtures/bd-*/; do
  name=$(basename "$d"); want=$(cat "$d/expected-estimate")
  out=$(cd "$d" && /bin/bash "$CHECK" dispatches .tad/active/epics/EPIC-20990101-bd.md 2>&1); rc=$?
  if [ "$want" = none ]; then
    exp="estimate: none (old Epic; no checkpoint or alarm)"
  else
    exp="estimate: $want"
  fi
  if [ "$rc" -eq 0 ] && printf '%s\n' "$out" | grep -qxF "$exp"; then
    echo "PASS $name ($want)"
  else
    echo "FAIL $name: want '$exp' rc 0, got rc $rc: $out"; fail=1
  fi
done
# Threshold dirs: th-<x> holds an Epic (estimate 10) with a known dispatch count, `expected-line` (the one
# CHECKPOINT / ALARM line that must print, or `none`: neither may print) and `expected-rc`.
for d in "$HERE"/cora-check-fixtures/th-*/; do
  name=$(basename "$d"); want=$(cat "$d/expected-line"); wrc=$(cat "$d/expected-rc")
  out=$(cd "$d" && /bin/bash "$CHECK" dispatches .tad/active/epics/EPIC-20990101-th.md 2>&1); rc=$?
  ok=0
  if [ "$rc" -eq "$wrc" ]; then
    if [ "$want" = none ]; then
      printf '%s\n' "$out" | grep -qE '^(CHECKPOINT|ALARM):' || ok=1
    else
      printf '%s\n' "$out" | grep -qxF "$want" && ok=1
    fi
  fi
  if [ "$ok" = 1 ]; then echo "PASS $name"; else echo "FAIL $name: want '$want' rc $wrc, got rc $rc: $out"; fail=1; fi
done
exit $fail
