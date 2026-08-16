#!/usr/bin/env bash
# AC12 (cross-repo, pins known residue): cwd=repoX, file in repoY → keep ABSOLUTE, exit 0.
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
. "$FIX/harness.sh"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
LIB="$ROOT/.tad/hooks/lib/common.sh"

BOX_X=$(mk_sandbox "repoX")
BOX_Y=$(mk_sandbox "repoY")
printf 'y' > "$BOX_Y/file-y.md"

rm -rf "$BOX_X/.tad/evidence/traces"
LINE=$(
  cd "$BOX_X" && source "$LIB" && record_trace "evidence_created" "$BOX_Y/file-y.md"
  tail -1 "$BOX_X"/.tad/evidence/traces/*.jsonl
)

case "$LINE" in
  *'"file":"'"$BOX_Y"'/file-y.md"'* ) echo "AC12 PASS (cross-repo kept absolute, as pinned)" ;;
  * ) echo "AC12 FAIL: cross-repo path mangled: $LINE" >&2; exit 1 ;;
esac