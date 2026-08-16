#!/bin/bash
# AC-01: COMPLETION exists but no Gate 3 verdict line -> new else branch fires
#         WARNING (exit 0), and names the file it read.
# Pre-change: MUST FAIL (saved as baseline-red.txt). Post-change: PASS.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$SCRIPT_DIR" && git rev-parse --show-toplevel)"
case "$PWD" in
  "$REPO"|"$REPO"/*) printf 'REFUSING: fixture must never run inside the repo\n' >&2; exit 1 ;;
esac
D="$(mktemp -d)"; trap 'rm -rf "$D"' EXIT
mkdir -p "$D/.tad/active/handoffs"
printf '%s\n' '# COMPLETION REPORT' '## Gate 3' 'Implementation complete.' > "$D/.tad/active/handoffs/COMPLETION-20260816-fixture.md"
( cd "$D" && printf '%s' '{"tool_name":"Skill","tool_input":{"skill":"gate","args":"3"}}' \
    | bash "$REPO/.tad/hooks/pre-gate-check.sh" >"$D/out" 2>"$D/err" )
RC=$?
fail=0
[ "$RC" -eq 0 ] || { echo "FAIL: expected exit 0, got $RC"; fail=1; }
grep -Fq 'No Gate 3 verdict line found' "$D/out" || { echo "FAIL: new WARNING text not emitted"; fail=1; }
grep -Fq 'COMPLETION-20260816-fixture.md' "$D/out" || { echo "FAIL: WARNING does not name the file it read"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: AC-01 missing-verdict -> WARNING naming the file, exit 0" && exit 0
echo "AC-01 FAILED (rc=$RC)"; exit 1
