#!/usr/bin/env bash
# AC4 (space in sandbox dir name): AC2/AC3 must still hold with `a b/repo`.
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
. "$FIX/harness.sh"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
LIB="$ROOT/.tad/hooks/lib/common.sh"

BOX=$(mk_sandbox "a b/repo")
mkdir -p "$BOX/sub"
printf 'space test' > "$BOX/sub/data.txt"   # 10 bytes
BYTES=$(wc -c < "$BOX/sub/data.txt" | tr -d ' ')

LINE=$(emit "$LIB" "$BOX/sub" "$BOX/sub/data.txt")

printf '%s\n' "$LINE" | grep -Fq "\"size_bytes\":$BYTES" \
  && echo "AC4 PASS (space dir, size_bytes=${BYTES})" \
  || { echo "AC4 FAIL: space dir broke size. line=$LINE" >&2; exit 1; }