#!/bin/bash
# AC-02 (E4 regression): verdict line contains FAIL -> BLOCK (exit 2), stderr text.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$SCRIPT_DIR" && git rev-parse --show-toplevel)"
case "$PWD" in
  "$REPO"|"$REPO"/*) printf 'REFUSING: fixture must never run inside the repo\n' >&2; exit 1 ;;
esac
D="$(mktemp -d)"; trap 'rm -rf "$D"' EXIT
mkdir -p "$D/.tad/active/handoffs"
printf '%s\n' '# COMPLETION' '**Gate 3 v2 结果**: ❌ FAIL' > "$D/.tad/active/handoffs/COMPLETION-20260816-fixture.md"
( cd "$D" && printf '%s' '{"tool_name":"Skill","tool_input":{"skill":"gate","args":"3"}}' \
    | bash "$REPO/.tad/hooks/pre-gate-check.sh" >"$D/out" 2>"$D/err" )
RC=$?
fail=0
[ "$RC" -eq 2 ] || { echo "FAIL: expected exit 2, got $RC"; fail=1; }
grep -Fq 'BLOCKED: Completion report shows Gate 3 FAIL' "$D/err" || { echo "FAIL: stderr missing BLOCKED text"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: AC-02 FAIL verdict -> BLOCK with stderr text" && exit 0
echo "AC-02 FAILED (rc=$RC)"; exit 1
