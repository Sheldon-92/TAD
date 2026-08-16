#!/bin/bash
# AC-06 (E2/E3 regression): e2e_required:yes without evidence -> BLOCK (E2);
# research_required:yes without evidence -> BLOCK (E3). Two sandboxed scenarios.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$SCRIPT_DIR" && git rev-parse --show-toplevel)"
case "$PWD" in
  "$REPO"|"$REPO"/*) printf 'REFUSING: fixture must never run inside the repo\n' >&2; exit 1 ;;
esac
D="$(mktemp -d)"; trap 'rm -rf "$D"' EXIT
fail=0

# E2 scenario
mkdir -p "$D/e2e/.tad/active/handoffs"
printf '%s\n' '---' 'e2e_required: yes' 'research_required: no' '---' '# HANDOFF' > "$D/e2e/.tad/active/handoffs/HANDOFF-20260816-fixture.md"
printf '%s\n' '# COMPLETION' '**Gate 3 v2 结果**: ✅ PASS' > "$D/e2e/.tad/active/handoffs/COMPLETION-20260816-fixture.md"
( cd "$D/e2e" && printf '%s' '{"tool_name":"Skill","tool_input":{"skill":"gate","args":"3"}}' \
    | bash "$REPO/.tad/hooks/pre-gate-check.sh" >"$D/e2e/out" 2>"$D/e2e/err" )
RC=$?
[ "$RC" -eq 2 ] || { echo "FAIL(E2): expected exit 2, got $RC"; fail=1; }
grep -Fq 'BLOCKED: Handoff requires E2E' "$D/e2e/err" || { echo "FAIL(E2): stderr missing E2E BLOCKED text"; fail=1; }

# E3 scenario
mkdir -p "$D/e3/.tad/active/handoffs"
printf '%s\n' '---' 'e2e_required: no' 'research_required: yes' '---' '# HANDOFF' > "$D/e3/.tad/active/handoffs/HANDOFF-20260816-fixture.md"
printf '%s\n' '# COMPLETION' '**Gate 3 v2 结果**: ✅ PASS' > "$D/e3/.tad/active/handoffs/COMPLETION-20260816-fixture.md"
( cd "$D/e3" && printf '%s' '{"tool_name":"Skill","tool_input":{"skill":"gate","args":"3"}}' \
    | bash "$REPO/.tad/hooks/pre-gate-check.sh" >"$D/e3/out" 2>"$D/e3/err" )
RC=$?
[ "$RC" -eq 2 ] || { echo "FAIL(E3): expected exit 2, got $RC"; fail=1; }
grep -Fq 'BLOCKED: Handoff requires research' "$D/e3/err" || { echo "FAIL(E3): stderr missing research BLOCKED text"; fail=1; }

[ "$fail" -eq 0 ] && echo "PASS: AC-06 E2/E3 still BLOCK without evidence" && exit 0
echo "AC-06 FAILED"; exit 1
