#!/usr/bin/env bash
set -uo pipefail
REPO="$1"
source "$REPO/.tad/hooks/lib/migration-engine.sh"
inf=0; total=0; rej=0
while IFS= read -r line; do
  printf '%s' "$line" | grep -qE '^[[:space:]]+"[0-9]+\.[0-9]+\.[0-9]+":' && { inf=0; continue; }
  printf '%s' "$line" | grep -qE '^[[:space:]]+files:[[:space:]]*$' && { inf=1; continue; }
  [ "$inf" = 1 ] && printf '%s' "$line" | grep -qE '^[[:space:]]+[a-z_]+:' && { inf=0; continue; }
  if [ "$inf" = 1 ] && printf '%s' "$line" | grep -qE '^[[:space:]]+-[[:space:]]+'; then
    p=$(printf '%s' "$line" | sed -E 's/^[[:space:]]+-[[:space:]]+//' | tr -d '"')
    total=$((total+1))
    if ! validate_path "$p" >/dev/null 2>&1; then
      rej=$((rej+1)); echo "REJECTED-BY-validate_path: $p"
    fi
  fi
done < "$REPO/.tad/deprecation.yaml"
echo "----"
echo "清单条目总数: $total"
echo "会被 validate_path 拒绝: $rej"
