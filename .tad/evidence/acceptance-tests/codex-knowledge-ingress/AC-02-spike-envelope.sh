#!/bin/bash
# AC-02 — Spike C report and field mapping.
set -eu

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
DIR="$ROOT/.tad/evidence/acceptance-tests/codex-knowledge-ingress"
REPORT="$DIR/spike-c.md"
MAPPING="$ROOT/.tad/guides/hooks-platform-mapping.md"

for term in \
  'SessionStart' \
  'PostToolUse' \
  'no stdin observed by a hook' \
  'no hook env observed' \
  'no hook argv observed' \
  'not substituted'; do
  grep -F -q -e "$term" "$REPORT"
done
for field in HOOK_EVENT HOOK_SOURCE HOOK_TOOL_NAME HOOK_FILE_PATH HOOK_SKILL HOOK_SKILL_ARGS HOOK_SESSION_ID HOOK_CWD; do
  grep -F -q -e "$field" "$ROOT/.tad/hooks/lib/hook-envelope.sh"
done
grep -F -q -e 'absent/unsupported Codex field stays empty' "$MAPPING"
grep -F -q -e 'measured Codex path' "$MAPPING"
jq empty "$DIR/spike-work/.codex/hooks.json"

printf '%s\n' 'AC-02 PASS: per-event no-delivery observation and envelope mapping are explicit.'
