#!/bin/bash
# cora-check-judge-rounds-fixture.sh - the judge-first and rounds subcommands of cora-check.sh
# (report-upgrades Phase 3). Each .tad/tests/cora-check-fixtures/jf-<x>/ and rd-<x>/ is a mini
# repo root holding `args` (one line), `expected-rc` and `expected-out` (the exact stdout; empty
# for a usage case). The runner does `cd <dir> && /bin/bash <check> $(cat args)`, captures stdout
# (stderr dropped) and prints `PASS <name>` or `FAIL <name>: <want/got>`; last line
# CORA-CHECK-JUDGE-ROUNDS-FIXTURE: PASS|FAIL; exit 0/1. A group (jf, rd) with no dir is a FAIL.
# Bash 3.2 safe, no git, writes nothing (no scratch needed). Run from anywhere:
#   /bin/bash .tad/tests/cora-check-judge-rounds-fixture.sh [--check <cora-check.sh>]
HERE="$(cd "$(dirname "$0")" && pwd -P)"
CHECK="$HERE/../hooks/lib/cora-check.sh"
if [ "$1" = "--check" ]; then
  [ -n "$2" ] && [ -f "$2" ] || { echo "usage: $0 [--check <cora-check.sh>]" >&2; exit 2; }
  # resolve to an absolute path before any cd into a fixture dir
  CHECK="$(cd "$(dirname "$2")" && pwd -P)/$(basename "$2")"
fi
fail=0
for g in jf rd; do
  seen=0
  for d in "$HERE"/cora-check-fixtures/$g-*/; do
    [ -d "$d" ] || continue
    seen=1
    name=$(basename "$d")
    args=$(cat "$d/args"); wrc=$(cat "$d/expected-rc"); want=$(cat "$d/expected-out")
    # word-split args on purpose (bash, not zsh): one line of space-separated arguments
    got=$(cd "$d" && /bin/bash "$CHECK" $args 2>/dev/null); rc=$?
    if [ "$rc" = "$wrc" ] && [ "$got" = "$want" ]; then
      echo "PASS $name"
    else
      echo "FAIL $name: want rc $wrc out [$want] / got rc $rc out [$got]"; fail=1
    fi
  done
  if [ "$seen" = 0 ]; then echo "FAIL $g: no $g-* fixture dir"; fail=1; fi
done
if [ "$fail" = 0 ]; then echo "CORA-CHECK-JUDGE-ROUNDS-FIXTURE: PASS"; exit 0; fi
echo "CORA-CHECK-JUDGE-ROUNDS-FIXTURE: FAIL"; exit 1
