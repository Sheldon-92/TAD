#!/bin/bash
# AC-05 (E1 regression): empty handoffs dir -> exit 2, stderr text.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$SCRIPT_DIR" && git rev-parse --show-toplevel)"
case "$PWD" in
  "$REPO"|"$REPO"/*) printf 'REFUSING: fixture must never run inside the repo\n' >&2; exit 1 ;;
esac
D="$(mktemp -d)"; trap 'rm -rf "$D"' EXIT
mkdir -p "$D/.tad/active/handoffs"
( cd "$D" && printf '%s' '{"tool_name":"Skill","tool_input":{"skill":"gate","args":"3"}}' \
    | bash "$REPO/.tad/hooks/pre-gate-check.sh" >"$D/out" 2>"$D/err" )
RC=$?
fail=0
[ "$RC" -eq 2 ] || { echo "FAIL: expected exit 2, got $RC"; fail=1; }
grep -Fq 'no COMPLETION report found' "$D/err" || { echo "FAIL: stderr missing E1 text"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: AC-05 no COMPLETION -> BLOCK with stderr text" && exit 0
echo "AC-05 FAILED (rc=$RC)"; exit 1
