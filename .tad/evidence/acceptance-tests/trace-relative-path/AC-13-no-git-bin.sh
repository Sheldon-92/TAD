#!/usr/bin/env bash
# AC13: git binary unavailable (PATH shim exit 127) → value kept, stderr empty.
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
. "$FIX/harness.sh"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
LIB="$ROOT/.tad/hooks/lib/common.sh"

BOX=$(mk_sandbox "repo")
mkdir -p "$BOX/fakebin"
printf '#!/bin/sh\nexit 127\n' > "$BOX/fakebin/git"
chmod +x "$BOX/fakebin/git"
printf 'x' > "$BOX/f.md"
ERR="$BOX/err.log"

rm -rf "$BOX/.tad/evidence/traces"
LINE=$(
  (
    cd "$BOX"
    export PATH="$BOX/fakebin:$PATH"
    source "$LIB"
    record_trace "evidence_created" "$BOX/f.md"
    tail -1 "$BOX"/.tad/evidence/traces/*.jsonl
  ) 2>"$ERR"
)
# F1 修复:2> 必须在 $(…) 内、显式子 shell 整体上(F1 P0)

if [ -s "$ERR" ]; then echo "AC13 FAIL: stderr not empty: $(cat "$ERR")" >&2; exit 1; fi
case "$LINE" in
  *'"file":"'"$BOX"'/f.md"'* ) echo "AC13 PASS (no git binary, value kept, stderr empty)" ;;
  * ) echo "AC13 FAIL: value mangled without git: $LINE" >&2; exit 1 ;;
esac