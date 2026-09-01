#!/usr/bin/env bash
set -euo pipefail
bash research/canon/lint.sh >/dev/null
tmp1=$(mktemp); tmp2=$(mktemp)
trap 'rm -f "$tmp1" "$tmp2"' EXIT
python3 research/scripts/generate.py --emit all >"$tmp1"
python3 research/scripts/generate.py --emit all >"$tmp2"
diff -u "$tmp1" "$tmp2"
echo 'AC5 PASS'
