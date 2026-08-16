#!/bin/bash
# AC-07 (carrier): the WARNING must survive BOTH output_response implementations.
# (a) jq path: parse additionalContext with jq, assert the text.
# (b) no-jq path (PATH=/usr/bin:/bin): manual JSON construction, assert the text
#     survives in the raw output (newlines flattened, text intact).
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$SCRIPT_DIR" && git rev-parse --show-toplevel)"
case "$PWD" in
  "$REPO"|"$REPO"/*) printf 'REFUSING: fixture must never run inside the repo\n' >&2; exit 1 ;;
esac
D="$(mktemp -d)"; trap 'rm -rf "$D"' EXIT
mkdir -p "$D/.tad/active/handoffs"
printf '%s\n' '# COMPLETION REPORT' '## Gate 3' 'Implementation complete.' > "$D/.tad/active/handoffs/COMPLETION-20260816-fixture.md"
fail=0

# (a) with jq
( cd "$D" && printf '%s' '{"tool_name":"Skill","tool_input":{"skill":"gate","args":"3"}}' \
    | bash "$REPO/.tad/hooks/pre-gate-check.sh" >"$D/out" 2>"$D/err" )
RC=$?
[ "$RC" -eq 0 ] || { echo "FAIL(a): expected exit 0, got $RC"; fail=1; }
if command -v jq >/dev/null 2>&1; then
  jq -e -r '.hookSpecificOutput.additionalContext' "$D/out" 2>/dev/null | grep -Fq 'No Gate 3 verdict line found' \
    || { echo "FAIL(a): additionalContext (jq path) missing the WARNING"; fail=1; }
else
  echo "WARN(a): jq unavailable; jq half marked EQUIVALENT_SUBSTITUTE (no-jq branch below)"
fi

# (b) no jq
( cd "$D" && printf '%s' '{"tool_name":"Skill","tool_input":{"skill":"gate","args":"3"}}' \
    | env PATH=/usr/bin:/bin bash "$REPO/.tad/hooks/pre-gate-check.sh" >"$D/out2" 2>"$D/err2" )
RC=$?
[ "$RC" -eq 0 ] || { echo "FAIL(b): expected exit 0, got $RC"; fail=1; }
grep -Fq 'No Gate 3 verdict line found' "$D/out2" || { echo "FAIL(b): manual JSON path lost the WARNING text"; fail=1; }
grep -Fq 'hookSpecificOutput' "$D/out2" || { echo "FAIL(b): output is not a hook envelope"; fail=1; }

[ "$fail" -eq 0 ] && echo "PASS: AC-07 carrier survives jq and no-jq output_response" && exit 0
echo "AC-07 FAILED"; exit 1
