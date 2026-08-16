#!/usr/bin/env bash
# AC5 (no-jq branch): HAS_JQ=false after source → relative path must still apply.
# Guard: assert HAS_JQ really IS false at call time (if still true → FAIL).
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
. "$FIX/harness.sh"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
LIB="$ROOT/.tad/hooks/lib/common.sh"

BOX=$(mk_sandbox "repo")
printf 'content' > "$BOX/some-file.md"

# Emit with nojq=true; capture HAS_JQ via stdout (echo inside the $() capture)
rm -rf "$BOX/.tad/evidence/traces"
LINE=$(
  cd "$BOX" && source "$LIB" && HAS_JQ=false && \
  { printf 'HAS_JQ_AT_CALL=%s\n' "$HAS_JQ"; record_trace "evidence_created" "$BOX/some-file.md"; }
  tail -1 "$BOX"/.tad/evidence/traces/*.jsonl
)
REAL_HIVAL=$(printf '%s\n' "$LINE" | grep -o 'HAS_JQ_AT_CALL=[a-z]*' | head -1 | cut -d= -f2)
TRACE_LINE=$(printf '%s\n' "$LINE" | grep '"file"' | head -1)

if [ "$REAL_HIVAL" != "false" ]; then
  echo "AC5 FAIL: HAS_JQ was '$REAL_HIVAL' at call time (guard)". >&2; exit 1
fi
case "$TRACE_LINE" in
  *'"file":"some-file.md"'* ) echo "AC5 PASS (no-jq branch, relative path)" ;;
  * ) echo "AC5 FAIL: no-jq branch wrong file. line=$TRACE_LINE" >&2; exit 1 ;;
esac