#!/usr/bin/env bash
# AC2: after patch — `file` does NOT start with / and equals the expected repo-relative path.
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
. "$FIX/harness.sh"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
LIB="$ROOT/.tad/hooks/lib/common.sh"

BOX=$(mk_sandbox "repo")
printf 'content' > "$BOX/some-file.md"
LINE=$(emit "$LIB" "$BOX" "$BOX/some-file.md")

EXPECT="some-file.md"
case "$LINE" in
  *'"file":"'"$EXPECT"'"'* )
    echo "AC2 PASS (file=${EXPECT})" ;;
  * )
    echo "AC2 FAIL: file field wrong. line=$LINE" >&2; exit 1 ;;
esac