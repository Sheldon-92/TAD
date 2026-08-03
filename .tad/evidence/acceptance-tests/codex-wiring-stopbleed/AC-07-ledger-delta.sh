#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO="$(cd "$SCRIPT_DIR/../../../../" && pwd -P)"
cd "$REPO"
escalation="$REPO/.tad/evidence/acceptance-tests/codex-wiring-stopbleed/ac7-branch-escalation.md"
grep -Fq '| codex | `ask_user_question_hook` |' "$escalation"

alpha="$(bash .tad/hooks/lib/runtime-freshness-verify.sh . 2026-08-03 2>&1)"
alpha_rc=$?
[ "$alpha_rc" -eq 0 ]
printf '%s\n' "$alpha" | grep -q 'Total: 21 entries | PASS: 21 | WARN: 0 | BLOCK: 0'

fixture="$(mktemp -d)"
mkdir -p "$fixture/.tad/runtime-compat"
rsync -a .tad/runtime-compat/ "$fixture/.tad/runtime-compat/"
perl -pi -e 'if (/^\| ask_user_question_hook \|/) { s/\| accepted_limitation \|$/| unknown_current_behavior |/; }' "$fixture/.tad/runtime-compat/codex.md"
set +e
beta="$(bash .tad/hooks/lib/runtime-freshness-verify.sh "$fixture" 2026-08-03 2>&1)"
beta_rc=$?
set -e
[ "$beta_rc" -eq 1 ]
beta_blocks="$(printf '%s\n' "$beta" | grep '^BLOCK \[codex\] ' || true)"
[ "$(printf '%s\n' "$beta_blocks" | sed '/^$/d' | wc -l | tr -d ' ')" -lt 5 ]
printf '%s\n' "$beta_blocks" | grep -Fxq 'BLOCK [codex] ask_user_question_hook: unknown_current_behavior on safety/quality surface'
if printf '%s\n' "$beta_blocks" | grep -qE '^BLOCK \[codex\] (skill_loading|hooks|subagents_custom_agents|codex_cloud|context_compaction|sandbox_approval_permissions|trace_evidence_capture)'; then
  exit 1
fi
echo 'AC7 PASS: alpha=0 and beta=registered one-row honest_partial fixture'
