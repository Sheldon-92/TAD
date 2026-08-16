#!/bin/bash
# AC-04 (FR3c regression): verdict line exists but has no PASS/FAIL (TBD)
# -> existing inner else WARNING ("doesn't contain PASS or FAIL"), not the new one.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$SCRIPT_DIR" && git rev-parse --show-toplevel)"
case "$PWD" in
  "$REPO"|"$REPO"/*) printf 'REFUSING: fixture must never run inside the repo\n' >&2; exit 1 ;;
esac
D="$(mktemp -d)"; trap 'rm -rf "$D"' EXIT
mkdir -p "$D/.tad/active/handoffs"
printf '%s\n' '# COMPLETION' '**Gate 3 Result**: TBD' > "$D/.tad/active/handoffs/COMPLETION-20260816-fixture.md"
( cd "$D" && printf '%s' '{"tool_name":"Skill","tool_input":{"skill":"gate","args":"3"}}' \
    | bash "$REPO/.tad/hooks/pre-gate-check.sh" >"$D/out" 2>"$D/err" )
RC=$?
fail=0
[ "$RC" -eq 0 ] || { echo "FAIL: expected exit 0, got $RC"; fail=1; }
grep -Fq "doesn't contain PASS or FAIL" "$D/out" || { echo "FAIL: inner-else WARNING missing"; fail=1; }
grep -Fq 'No Gate 3 verdict line found' "$D/out" && { echo "FAIL: new else-branch text appeared on TBD line"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: AC-04 TBD line -> inner else WARNING only" && exit 0
echo "AC-04 FAILED (rc=$RC)"; exit 1
