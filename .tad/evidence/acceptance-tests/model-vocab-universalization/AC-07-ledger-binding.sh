#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"

BASELINE=".tad/evidence/acceptance-tests/model-vocab-universalization/baseline.md"
BASELINE_SHA="$(sed -n 's/^BASELINE_COMMIT=//p' "$BASELINE")"
CURRENT_ROW="$(grep -F -e "| ask_user_question_hook |" .tad/runtime-compat/codex.md)"
BASELINE_ROW="$(git show "$BASELINE_SHA:.tad/runtime-compat/codex.md" | grep -F -e "| ask_user_question_hook |")"

field() {
  local row="$1" number="$2"
  printf '%s\n' "$row" | awk -F'|' -v n="$number" '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $n); print $n}'
}

status="$(field "$CURRENT_ROW" 12)"
notes="$(field "$CURRENT_ROW" 11)"
current_verified="$(field "$CURRENT_ROW" 7)"
baseline_verified="$(field "$BASELINE_ROW" 7)"
COMPLETION=".tad/active/handoffs/COMPLETION-20260803-model-vocabulary-universalization.md"
HANDOFF_ID="HANDOFF-20260803-model-vocabulary-universalization"
TODAY="$(date +%Y-%m-%d)"

if [ "$status" != "accepted_limitation" ]; then
  echo "FAIL AC7: ask_user_question_hook status changed to '$status'"
  exit 1
fi
if [ "$(printf '%s\n' "$notes" | grep -F -c -e "numbered-options" || true)" -lt 1 ]; then
  echo "FAIL AC7: numbered-options runtime binding note missing"
  exit 1
fi
if [ "$current_verified" != "$baseline_verified" ]; then
  if [ ! -f "$COMPLETION" ]; then
    echo "FAIL AC7: last_verified changed without this handoff's Completion file"
    exit 1
  fi
  for needle in \
    "**Handoff ID:** $HANDOFF_ID" \
    "$TODAY" \
    "真实重验证" \
    "AC-09-codex-key-reprobe.sh"; do
    if ! grep -Fq -e "$needle" "$COMPLETION"; then
      echo "FAIL AC7: Completion lacks bound re-verification evidence: $needle"
      exit 1
    fi
  done
fi

echo "AC7 PASS: status accepted_limitation, numbered-options note, and last_verified change binding hold"
