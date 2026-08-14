#!/usr/bin/env bash
# P7 budget.sh（rev3）—— 机械计算「最小常驻集」字节。Blake 只填载体路径，字节不由他写（AC1）。
#
# rev2 缺陷（Gate 2 第三轮实测）：块边界靠 `^#{1,3} ` 猜 → 分不清 markdown 标题与 YAML 注释行，
#   17 项跨度 >100×（`Forbidden 清单本体` 记成 45 B、`启动扫描` 记成 0 B、`需求澄清` 吞掉 4092 B）；
#   且把 gate/blake/blake-lite 的 8 项也算进"常驻"，10,304/18,784 B（55%）是 Alex 根本不加载的文件。
# rev3 修法：块边界改由 `*.blocks.tsv`（Alex 逐项人工确认、已 commit、AC12 守哈希）给出
#   起/止锚串（exact full line），锚点找不到 / 不唯一 / 顺序反了一律 **FAIL 报错**，不再静默记 0；
#   `常驻=否` 的 8 项单独列出但**不计入总额**。
set -uo pipefail
DONE=0; trap '[ "$DONE" = 1 ] || { echo "RESULT=FAIL (budget.sh 中途退出)"; exit 1; }' EXIT
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/lazy-by-floor"
BLK="$R/.tad/active/handoffs/HANDOFF-20260818-lazy-by-floor.blocks.tsv"
OUT="$EV/budget-computed.tsv"; : > "$OUT"; TOT=0; ERR=0

fail(){ echo "  !! $*"; ERR=$((ERR+1)); }

while IFS=$'\t' read -r name carrier anchor; do
  [ -n "${name:-}" ] || continue
  # 常驻标志与起止锚串来自冻结的 blocks.tsv，按纪律名精确匹配
  meta=$(LC_ALL=C awk -F'\t' -v n="$name" '!/^#/ && $1==n{print $2"\t"$3"\t"$4; exit}' "$BLK")
  [ -n "$meta" ] || { fail "$name: blocks.tsv 无此行"; continue; }
  IFS=$'\t' read -r res sa ea <<<"$meta"

  if [ "$res" != "是" ]; then
    printf '%s\t%s\t-\tNON_RESIDENT\n' "$name" "$carrier" >> "$OUT"; continue
  fi
  [ -f "$R/$carrier" ] || { fail "$name: 载体不存在 $carrier"; continue; }

  ns=$(LC_ALL=C command grep -cFx -e "$sa" "$R/$carrier" || true)
  [ "$ns" = "1" ] || { fail "$name: 起锚串命中 ${ns} 次（须恰好 1）：$sa"; continue; }
  s=$(LC_ALL=C command grep -nFx -e "$sa" "$R/$carrier" | LC_ALL=C cut -d: -f1)

  if [ "$ea" = "<EOF>" ]; then
    e=$(( $(LC_ALL=C wc -l < "$R/$carrier" | LC_ALL=C tr -d ' ') + 1 ))
  else
    ne=$(LC_ALL=C command grep -cFx -e "$ea" "$R/$carrier" || true)
    [ "$ne" = "1" ] || { fail "$name: 止锚串命中 ${ne} 次（须恰好 1）：$ea"; continue; }
    e=$(LC_ALL=C command grep -nFx -e "$ea" "$R/$carrier" | LC_ALL=C cut -d: -f1)
  fi
  [ "$e" -gt "$s" ] || { fail "$name: 止锚(${e}) 不在起锚(${s}) 之后"; continue; }

  # 承重断言：地板表那条锚点必须落在 [起,止) 内 —— 否则边界画错了
  inb=$(sed -n "${s},$((e-1))p" "$R/$carrier" | LC_ALL=C command grep -cF -e "$anchor" || true)
  [ "${inb:-0}" -ge 1 ] || { fail "$name: 地板锚点不在块 [${s},$((e-1))] 内"; continue; }

  n=$(sed -n "${s},$((e-1))p" "$R/$carrier" | LC_ALL=C wc -c | LC_ALL=C tr -d ' ')
  printf '%s\t%s\t%s-%s\t%s\n' "$name" "$carrier" "$s" "$((e-1))" "$n" >> "$OUT"
  TOT=$((TOT+n))
done < "$EV/floor-anchors.tsv"

printf 'TOTAL_RESIDENT\t-\t-\t%s\n' "$TOT" >> "$OUT"
NR_=$(LC_ALL=C command grep -c 'NON_RESIDENT' "$OUT" || true)
echo "budget: 常驻 $(( $(command grep -c . "$OUT" || true) - 1 - NR_ )) 项 = ${TOT} B ≈ $((TOT/4000))K tokens；非常驻 ${NR_} 项已排除"
DONE=1; trap - EXIT
[ "$ERR" -eq 0 ] || { echo "RESULT=FAIL (${ERR} 项锚点解析失败)"; exit 1; }
echo "RESULT=PASS"
