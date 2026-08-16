#!/usr/bin/env bash
# AC6: path outside any repo (/tmp/x) → keep absolute, stderr empty.
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
. "$FIX/harness.sh"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
LIB="$ROOT/.tad/hooks/lib/common.sh"

BOX=$(mk_sandbox "repo")
TMPF="/tmp/outside-$$.txt"
printf 'x' > "$TMPF"
ERR="$BOX/err.log"
LINE=$(emit "$LIB" "$BOX" "$TMPF" 2>"$ERR")

if [ -s "$ERR" ]; then echo "AC6 FAIL: stderr not empty: $(cat "$ERR")" >&2; rm -f "$TMPF"; exit 1; fi
case "$LINE" in
  *'"file":"'"$TMPF"'"'* ) echo "AC6 PASS (/tmp path kept absolute, stderr empty)" ;;
  * ) echo "AC6 FAIL: /tmp path changed: $LINE" >&2; rm -f "$TMPF"; exit 1 ;;
esac
rm -f "$TMPF"