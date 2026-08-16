#!/usr/bin/env bash
# AC14 (pins degradation): symlink-form path (/tmp vs /private/tmp) → keep ABSOLUTE.
# mktemp gives /var/... ; pwd -P resolves to /private/var/... . Feed the /var form:
# git rev-parse returns the /private form → prefix mismatch → NOT converted.
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
. "$FIX/harness.sh"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
LIB="$ROOT/.tad/hooks/lib/common.sh"

BOX=$(mk_sandbox "repo")                     # /private/var/... (pwd -P form)
PHYS_BOX="$BOX"
SYMLINK_FORM="${PHYS_BOX#/private}"          # /var/... (symlink form)
mkdir -p "$SYMLINK_FORM"
printf 'x' > "$SYMLINK_FORM/f.md"
ERR="$BOX/err.log"

rm -rf "$BOX/.tad/evidence/traces"
LINE=$(
  (
    cd "$BOX" && source "$LIB" && record_trace "evidence_created" "$SYMLINK_FORM/f.md"
    tail -1 "$BOX"/.tad/evidence/traces/*.jsonl
  ) 2>"$ERR"
)
# F1 修复:2> 必须在 $(…) 内、显式子 shell 整体上(F1 P0)

if [ -s "$ERR" ]; then echo "AC14 FAIL: stderr not empty: $(cat "$ERR")" >&2; exit 1; fi
case "$LINE" in
  *'"file":"'"$SYMLINK_FORM"'/f.md"'* ) echo "AC14 PASS (symlink form kept absolute — pinned degradation)" ;;
  * ) echo "AC14 FAIL: symlink-form path converted (unexpected): $LINE" >&2; exit 1 ;;
esac