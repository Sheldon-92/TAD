#!/usr/bin/env bash
# AC3 (DISCRIMINATING — cwd MUST be a subdirectory): size_bytes must equal true byte count and ≠ 0.
# The discriminating config: cwd≠repo root catches a mis-ordered patch (stat before conversion).
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
. "$FIX/harness.sh"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
LIB="$ROOT/.tad/hooks/lib/common.sh"

BOX=$(mk_sandbox "repo")
mkdir -p "$BOX/sub"
printf 'hello world' > "$BOX/sub/data.txt"   # 11 bytes
BYTES=$(wc -c < "$BOX/sub/data.txt" | tr -d ' ')

LINE=$(emit "$LIB" "$BOX/sub" "$BOX/sub/data.txt")

printf '%s\n' "$LINE" | grep -Fq "\"size_bytes\":$BYTES" \
  && echo "AC3 PASS (cwd=sub, size_bytes=${BYTES})" \
  || { echo "AC3 FAIL: size_bytes wrong (expected ${BYTES}). line=$LINE" >&2; exit 1; }