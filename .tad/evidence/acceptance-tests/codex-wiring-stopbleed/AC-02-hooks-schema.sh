#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO="$(cd "$SCRIPT_DIR/../../../../" && pwd -P)"
SPIKE="$REPO/.tad/evidence/acceptance-tests/codex-wiring-stopbleed"

cmp -s "$REPO/.codex/hooks.json" "$SPIKE/spike-work/.codex/hooks.json"
set +e
out="$(env CODEX_HOME="$SPIKE/spike-codex-home" codex exec --cd "$SPIKE/spike-work" --ephemeral --json --color never --sandbox read-only 'Do not use any tools or write files. Reply with exactly SPIKE_SCHEMA_REVALIDATED.' 2>&1)"
rc=$?
set -e
[ "$rc" -eq 0 ]
if printf '%s\n' "$out" | grep -qiE 'failed to parse hooks config|unknown field.*(SessionStart|PostToolUse)'; then
  echo 'AC2 FAIL: hooks parse warning present' >&2
  exit 1
fi
printf '%s\n' "$out" | grep -Fq 'SPIKE_SCHEMA_REVALIDATED'
echo 'AC2 PASS: repository/scratch cmp and trusted candidate session revalidation'
