#!/bin/bash
# AC-06 — detect-platform table, stdout purity, and Spike E set equality.
set -eu

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
DETECT="$ROOT/.tad/hooks/lib/detect-platform.sh"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/tad-ac6.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

# Spike E measured {}. Assert the implementation has no automatic read of an
# unmeasured candidate; TAD_PLATFORM is an explicit control, not a harness read.
grep -F -q -e 'intentionally empty' "$DETECT"
if grep -nE '^[[:space:]]*(if|case|[A-Z_]+[[:space:]]*=).*\b(CLAUDECODE|CODEX_SANDBOX)' "$DETECT" >/dev/null; then
  echo 'BLOCK: detect-platform reads a signal absent from Spike E set' >&2
  exit 1
fi
grep -F -q -e 'empty harness-signal set' "$ROOT/.tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-e.md"

run_detect() {
  local label="$1" path="$2"
  shift 2
  set +e
  (cd "$TMP/project" && env -i PATH="$path" "$@" /bin/bash "$DETECT") > "$TMP/$label.out" 2> "$TMP/$label.err"
  printf '%s\n' "$?" > "$TMP/$label.rc"
  set -e
}

mkdir -p "$TMP/project/.claude/workflows" "$TMP/project/.tad" "$TMP/no-codex"
printf '%s\n' '// workflow fixture' > "$TMP/project/.claude/workflows/fixture.workflow.js"
CODEX_PATH="/opt/homebrew/bin:/usr/bin:/bin"
NO_CODEX_PATH="/usr/bin:/bin"

# Table rows 1-3: explicit override; row 4: workflow fallback; row 5: codex/none
# fallback. These are the only automatically measurable branches in Spike E.
run_detect override-workflow "$NO_CODEX_PATH" env TAD_PLATFORM=workflow
run_detect override-codex "$NO_CODEX_PATH" env TAD_PLATFORM=codex
run_detect override-none "$NO_CODEX_PATH" env TAD_PLATFORM=none
run_detect workflow-fallback "$CODEX_PATH" env
rm -f "$TMP/project/.claude/workflows/fixture.workflow.js"
run_detect codex-fallback "$CODEX_PATH" env
run_detect none-fallback "$NO_CODEX_PATH" env

[ "$(cat "$TMP/override-workflow.out")" = workflow ]
[ "$(cat "$TMP/override-codex.out")" = codex ]
[ "$(cat "$TMP/override-none.out")" = none ]
[ "$(cat "$TMP/workflow-fallback.out")" = workflow ]
[ "$(cat "$TMP/codex-fallback.out")" = codex ]
[ "$(cat "$TMP/none-fallback.out")" = none ]
for label in override-workflow override-codex override-none workflow-fallback codex-fallback none-fallback; do
  [ "$(cat "$TMP/$label.rc")" -eq 0 ]
  [ "$(wc -l < "$TMP/$label.out" | tr -d ' ')" -eq 1 ]
  grep -Eq '^(workflow|codex|none)$' "$TMP/$label.out"
done
grep -F -q -e 'no automatic harness signal observed' "$TMP/workflow-fallback.err"

printf '%s\n' 'AC-06 PASS: implementation signal reads equal Spike E {}; override/fallback table outputs are one clean word.'
