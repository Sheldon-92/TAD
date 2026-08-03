#!/bin/bash
# AC-09 — release parity, skill-body, runtime ledger, and accepted limitation.
set -eu

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
PARITY_OUT="$(mktemp "${TMPDIR:-/tmp}/tad-ac9-parity.XXXXXX")"
SKILL_OUT="$(mktemp "${TMPDIR:-/tmp}/tad-ac9-skill.XXXXXX")"
RUNTIME_OUT="$(mktemp "${TMPDIR:-/tmp}/tad-ac9-runtime.XXXXXX")"
trap 'rm -f "$PARITY_OUT" "$SKILL_OUT" "$RUNTIME_OUT"' EXIT

bash "$ROOT/.tad/hooks/lib/release-verify.sh" parity "$ROOT" > "$PARITY_OUT"
bash "$ROOT/.tad/hooks/lib/skill-body-verify.sh" "$ROOT/.claude/skills/blake/SKILL.md" > "$SKILL_OUT"
grep -F -q -e 'OK:' "$SKILL_OUT"
bash "$ROOT/.tad/hooks/lib/runtime-freshness-verify.sh" "$ROOT" > "$RUNTIME_OUT"
grep -F -q -e 'Total: 21 entries | PASS: 21 | WARN: 0 | BLOCK: 0' "$RUNTIME_OUT"
grep -F -q -e 'VERDICT: runtime freshness PASS' "$RUNTIME_OUT"

ASKUSER_LINE=$(grep -F -e '| ask_user_question_hook |' "$ROOT/.tad/runtime-compat/codex.md")
grep -F -q -e 'accepted_limitation' <<< "$ASKUSER_LINE"
if grep -F -q -e 'verified' <<< "$ASKUSER_LINE"; then
  echo 'BLOCK: ask_user_question_hook was flipped to verified' >&2
  exit 1
fi

jq -e 'has("description") and (.hooks | type == "object") and (.hooks | has("SessionStart")) and (.hooks | has("PostToolUse"))' "$ROOT/.codex/hooks.json" >/dev/null
if jq -e 'has("SessionStart") or has("PostToolUse")' "$ROOT/.codex/hooks.json" >/dev/null; then
  echo 'BLOCK: legacy top-level hook event keys remain' >&2
  exit 1
fi
grep -F -q -e '"matcher": "startup|resume|compact"' "$ROOT/.codex/hooks.json"
grep -F -q -e '"matcher": "startup|resume|compact"' "$ROOT/tad.sh"

printf '%s\n' 'AC-09 PASS: parity, skill-body, runtime 21/21 PASS, accepted limitation, and current hook schema verified.'
