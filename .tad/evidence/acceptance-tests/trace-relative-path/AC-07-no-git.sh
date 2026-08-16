#!/usr/bin/env bash
# AC7: directory NOT git-init'd → value kept as-is, stderr empty.
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
. "$FIX/harness.sh"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
LIB="$ROOT/.tad/hooks/lib/common.sh"

NOGIT=$(mktemp -d); NOGIT=$(cd "$NOGIT" && pwd -P)
mkdir -p "$NOGIT/no-git/.tad/evidence"
printf 'x' > "$NOGIT/no-git/f.md"
ERR="$NOGIT/err.log"

rm -rf "$NOGIT/no-git/.tad/evidence/traces"
LINE=$(
  (
    cd "$NOGIT/no-git" && source "$LIB" && record_trace "evidence_created" "$NOGIT/no-git/f.md"
    tail -1 "$NOGIT"/no-git/.tad/evidence/traces/*.jsonl
  ) 2>"$ERR"
)
# F1 修复:2> 必须在 $(…) 内、显式子 shell 整体上,外部放置无法捕获内部 stderr(F1 P0)

if [ -s "$ERR" ]; then echo "AC7 FAIL: stderr not empty: $(cat "$ERR")" >&2; exit 1; fi
case "$LINE" in
  *'"file":"'"$NOGIT"'/no-git/f.md"'* ) echo "AC7 PASS (no-git dir, value kept)" ;;
  * ) echo "AC7 FAIL: no-git value mangled: $LINE" >&2; exit 1 ;;
esac