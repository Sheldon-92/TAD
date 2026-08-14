#!/usr/bin/env bash
# P7 budget.sh —— 机械计算「最小常驻集」字节。Blake 只填载体路径，字节不由他写（AC1）。
# 块定义：锚点行 → 下一个 ^#{1,3} / ^[a-z_]+: / ^\s+- STEP 边界前一行。
set -uo pipefail
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/lazy-by-floor"
OUT="$EV/budget-computed.tsv"; : > "$OUT"; TOT=0
while IFS=$'\t' read -r name carrier anchor; do
  [ -n "${name:-}" ] || continue
  n=0
  if [ -f "$R/$carrier" ]; then
    ln=$(LC_ALL=C command grep -nFx -e "$anchor" "$R/$carrier" 2>/dev/null | LC_ALL=C head -1 | LC_ALL=C cut -d: -f1)
    [ -z "$ln" ] && ln=$(LC_ALL=C command grep -nF -e "$anchor" "$R/$carrier" 2>/dev/null | LC_ALL=C head -1 | LC_ALL=C cut -d: -f1)
    if [ -n "$ln" ]; then
      end=$(LC_ALL=C awk -v s="$ln" 'NR>s && (/^#{1,3} /||/^[a-z_]+:/||/^ +- STEP /){print NR-1; exit}' "$R/$carrier")
      [ -z "$end" ] && end=$(LC_ALL=C wc -l < "$R/$carrier" | LC_ALL=C tr -d ' ')
      n=$(sed -n "${ln},${end}p" "$R/$carrier" | LC_ALL=C wc -c | LC_ALL=C tr -d ' ')
    fi
  fi
  printf '%s\t%s\t%s\n' "$name" "$carrier" "$n" >> "$OUT"; TOT=$((TOT+n))
done < "$EV/floor-anchors.tsv"
printf 'TOTAL\t-\t%s\n' "$TOT" >> "$OUT"
echo "budget: $(command grep -c . "$OUT") 行, 最小常驻集 ${TOT} B ≈ $((TOT/4000))K tokens"
