#!/bin/bash
# AC-03 (FR3b regression): verdict line contains PASS -> quiet (exit 0).
# Liveness positive: "Gate 3 prerequisites met" still emitted.
# Negative: new else-branch text must NOT appear.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$SCRIPT_DIR" && git rev-parse --show-toplevel)"
case "$PWD" in
  "$REPO"|"$REPO"/*) printf 'REFUSING: fixture must never run inside the repo\n' >&2; exit 1 ;;
esac
D="$(mktemp -d)"; trap 'rm -rf "$D"' EXIT
mkdir -p "$D/.tad/active/handoffs"
printf '%s\n' '# COMPLETION' '**Gate 3 v2 结果**: ✅ PASS' > "$D/.tad/active/handoffs/COMPLETION-20260816-fixture.md"
( cd "$D" && printf '%s' '{"tool_name":"Skill","tool_input":{"skill":"gate","args":"3"}}' \
    | bash "$REPO/.tad/hooks/pre-gate-check.sh" >"$D/out" 2>"$D/err" )
RC=$?
fail=0
[ "$RC" -eq 0 ] || { echo "FAIL: expected exit 0, got $RC"; fail=1; }
grep -Fq 'Gate 3 prerequisites met' "$D/out" || { echo "FAIL: liveness text 'Gate 3 prerequisites met' missing"; fail=1; }
grep -Fq 'No Gate 3 verdict line found' "$D/out" && { echo "FAIL: new else-branch text appeared on PASS"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: AC-03 PASS verdict -> quiet, liveness text present" && exit 0
echo "AC-03 FAILED (rc=$RC)"; exit 1
