#!/usr/bin/env bash
# AC1 (NEGATIVE CONTROL — must be RED before patch): unpatched lib emits absolute `file`.
# Saves the red baseline line to baseline-red.txt.
# ⚠️ Usage: run ONCE before patching common.sh (or against an unpatched checkout).
#    Re-running after the patch would emit a relative path and OVERWRITE the red
#    baseline — so the write is guarded: only an absolute file overwrites the file.
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
. "$FIX/harness.sh"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
LIB="$ROOT/.tad/hooks/lib/common.sh"

# Negative control must observe an absolute path on the UNPATCHED lib
BOX=$(mk_sandbox "repo")
printf 'content' > "$BOX/some-file.md"
LINE=$(emit "$LIB" "$BOX" "$BOX/some-file.md")

printf '%s\n' "$LINE" | grep -q '"file":"/' || {
  echo "AC1 NOTE: lib is patched (relative path) — red baseline already captured, not overwriting." >&2
  exit 0
}

echo "$LINE" > "$FIX/baseline-red.txt"
echo "AC1 PASS (red on unpatched lib — file starts with /)"