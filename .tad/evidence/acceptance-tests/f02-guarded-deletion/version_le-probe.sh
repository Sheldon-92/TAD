#!/usr/bin/env bash
set -uo pipefail
REPO="$1"          # 存到独立变量,避免被 set -- 覆盖
PAIRS=("2.0.0 2.42.0" "2.42.0 2.0.0" "2.42.0 2.42.0" "2.9.0 2.10.0" "2.10.0 2.9.0")
eval "$(sed -n '/^version_le()/,/^}/p' "$REPO/tad.sh")"
echo "--- tad.sh 原版 ---"
for p in "${PAIRS[@]}"; do
  a=${p% *}; b=${p#* }
  version_le "$a" "$b" && r=true || r=false
  printf '  version_le(%s,%s)=%s\n' "$a" "$b" "$r"
done
source "$REPO/.tad/hooks/lib/migration-engine.sh"
echo "--- 引擎覆盖后 ---"
for p in "${PAIRS[@]}"; do
  a=${p% *}; b=${p#* }
  version_le "$a" "$b" && r=true || r=false
  printf '  version_le(%s,%s)=%s\n' "$a" "$b" "$r"
done
