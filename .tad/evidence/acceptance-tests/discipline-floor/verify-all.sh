#!/usr/bin/env bash
# AC verify — HANDOFF-20260816-discipline-floor (rev2)
# Red: exit != 0 AND last line RESULT=FAIL. --negative <fixture> substitutes the main table.
R="/path/to/TAD"
EV="$R/.tad/evidence/acceptance-tests/discipline-floor"
H="$R/.tad/active/handoffs/HANDOFF-20260816-discipline-floor.md"
S0="$R/.tad/active/handoffs/HANDOFF-20260816-discipline-floor.step0.sh"
K30="$R/.tad/active/handoffs/HANDOFF-20260816-discipline-floor.keys30.tsv"
MAIN="${1:-$R/.tad/discipline-floor.md}"
if [ "${1:-}" = "--negative" ]; then MAIN="$2"; fi
T0=$(cat "$EV/t0.txt")
export LC_ALL=C
FAILED=0; DONE=0; ACN_FAILS=0
trap 'if [ "${DONE:-0}" = "1" ]; then echo "RESULT=PASS"; exit 0; else echo "RESULT=FAIL"; exit 1; fi' EXIT
ac_fail() { ACN_FAILS=$((ACN_FAILS+1)); FAILED=1; echo "  AC FAIL: $*"; }
verdict() { if [ "$ACN_FAILS" = "0" ]; then echo "$1 PASS"; else echo "$1 FAIL"; fi; }

MR="$EV/.main-rows.tsv"
LC_ALL=C awk -F'\t' 'NF>=12 && $1!="" && $1!~/^#/ && $1!~/^\|/ && $1!="纪律" {print}' "$MAIN" > "$MR"

# ── AC1: main table 30 rows; cols 1-4 == verdicts.tsv ──
ACN_FAILS=0; echo "AC1: 30 rows, cols 1-4 == verdicts.tsv"
nrows=$(command grep -c . "$MR" || true)
if [ "$nrows" != "30" ]; then ac_fail "rows=$nrows (want 30)"; fi
LC_ALL=C cut -f1-4 "$MR" | LC_ALL=C sort > "$EV/.ac1-a"
LC_ALL=C sort "$EV/verdicts.tsv" | LC_ALL=C cut -f1-4 > "$EV/.ac1-b"
LC_ALL=C comm -3 "$EV/.ac1-a" "$EV/.ac1-b" > "$EV/.ac1-c"
if [ -s "$EV/.ac1-c" ]; then ac_fail "AC1 comm diff:"; LC_ALL=C cut -c1-80 "$EV/.ac1-c" | head -5; fi
rm -f "$EV/.ac1-a" "$EV/.ac1-b" "$EV/.ac1-c"
verdict AC1

# ── AC2: 循环? enum; 否 rows have non-empty 解除待判 ──
ACN_FAILS=0; echo "AC2: 循环? enum + 否 行解除待判非空"
LC_ALL=C awk -F'\t' '$5!="是" && $5!="否" && $5!="无法判定"{print NR": bad 循环? "$5}' "$MR" > "$EV/.ac2a"
LC_ALL=C awk -F'\t' '$5=="否" && ($12=="" || $12=="-"){print NR": 否 行解除待判空"}' "$MR" > "$EV/.ac2b"
if [ -s "$EV/.ac2a" ] || [ -s "$EV/.ac2b" ]; then ac_fail "AC2:"; cat "$EV/.ac2a" "$EV/.ac2b" | LC_ALL=C cut -c1-90 | head -6; fi
rm -f "$EV/.ac2a" "$EV/.ac2b"
verdict AC2

# ── AC3: Layer mechanical derivation + 定档依据 ──
ACN_FAILS=0; echo "AC3: Layer 机械推导"
LC_ALL=C awk -F'\t' '{
  v=$2; c=$5; l=$9; b=$10; err=""
  if (v=="地板") { if (l!="0") err="地板→Layer " l " 应0" }
  else if (v=="可缩放") { if (l=="0") err="可缩放→Layer 0 违规"; if (l!="1" && l!="2") err="可缩放→Layer " l " 应1|2" }
  else if (v=="待判") {
    if (c=="是" || c=="无法判定") { if (l!="0") err="待判+" c "→Layer " l " 应0"; if (b!="待判默认") err="定档依据 " b " 应待判默认" }
    else if (c=="否") { if (l!="1" && l!="2") err="待判+否→Layer " l " 应1|2"; if (b!="循环触发实测") err="定档依据 " b " 应循环触发实测" }
  }
  if (v=="地板" && b!="既有判定") err="地板定档依据 " b " 应既有判定"
  if (v=="可缩放" && b!="既有判定") err="可缩放定档依据 " b " 应既有判定"
  if (err!="") print NR": " $1 " — " err
}' "$MR" > "$EV/.ac3"
if [ -s "$EV/.ac3" ]; then ac_fail "AC3:"; cat "$EV/.ac3" | LC_ALL=C cut -c1-100 | head -8; fi
rm -f "$EV/.ac3"
verdict AC3

# ── AC4: anchor binds discipline — in carrier, >=12B, matches keys30 discriminator ──
ACN_FAILS=0; echo "AC4: 锚点绑定纪律"
while IFS=$'\t' read -r name key; do
  [ -n "$name" ] || continue
  row=$(LC_ALL=C awk -F'\t' -v n="$name" '$1==n{print}' "$MR" | head -1)
  [ -z "$row" ] && { ac_fail "AC4: $name 不在主表"; continue; }
  carrier=$(printf '%s' "$row" | LC_ALL=C cut -f6)
  anchor=$(printf '%s' "$row" | LC_ALL=C cut -f7)
  if [ ! -f "$R/$carrier" ]; then ac_fail "AC4 $name: 载体不存在 $carrier"; continue; fi
  if ! LC_ALL=C command grep -Fq -e "$anchor" "$R/$carrier"; then ac_fail "AC4 $name: 锚点不在载体"; continue; fi
  b=$(printf '%s' "$anchor" | LC_ALL=C wc -c | tr -d ' ')
  [ "$b" -ge 12 ] || ac_fail "AC4 $name: 锚点仅 ${b}B"
  if ! printf '%s' "$anchor" | LC_ALL=C command grep -iEq -e "$key"; then ac_fail "AC4 $name: 锚点未命中判别词"; fi
done < "$K30"
verdict AC4

# ── AC5: trigger string — contains anchor, >=12B, hits wide markers ──
ACN_FAILS=0; echo "AC5: 触发串双向锚定"
W=$(cat "$EV/wide-markers.txt")
LC_ALL=C awk -F'\t' '{print $1"\t"$6"\t"$7"\t"$8}' "$MR" > "$EV/.ac5-main"
while IFS=$'\t' read -r name carrier anchor trig; do
  [ -n "$name" ] || continue
  if ! printf '%s' "$trig" | LC_ALL=C command grep -Fq -e "$anchor"; then ac_fail "AC5 $name: 触发串不含锚点"; fi
  b=$(printf '%s' "$trig" | LC_ALL=C wc -c | tr -d ' ')
  [ "$b" -ge 12 ] || ac_fail "AC5 $name: 触发串仅 ${b}B"
  if ! printf '%s' "$trig" | LC_ALL=C command grep -Eq -e "$W"; then ac_fail "AC5 $name: 触发串未命中宽词表"; fi
done < "$EV/.ac5-main"
rm -f "$EV/.ac5-main"
verdict AC5

# ── AC6: carrier dispersion — >=5 distinct files, single carrier <=10 rows ──
ACN_FAILS=0; echo "AC6: 载体分散度"
nf=$(LC_ALL=C cut -f6 "$MR" | LC_ALL=C sort -u | command grep -c . || true)
if [ "$nf" -lt 5 ]; then ac_fail "AC6: 载体文件仅 $nf 个（需≥5）"; fi
LC_ALL=C cut -f6 "$MR" | LC_ALL=C sort | LC_ALL=C uniq -c | LC_ALL=C awk '$1>10{print $2": "$1" 行"}' > "$EV/.ac6"
if [ -s "$EV/.ac6" ]; then ac_fail "AC6: 单载体超10行:"; cat "$EV/.ac6"; fi
rm -f "$EV/.ac6"
verdict AC6

# ── AC7: main+sub (carrier,anchor) unique count == 30 + subrows ──
ACN_FAILS=0; echo "AC7: 防双计"
SUB=$(LC_ALL=C awk -F'\t' '/^## /{f=0} /^## 副表/{f=1; next} f && NF>0 && $1!="项" && $1!~/^[|#-]/ && $1!=""{print}' "$MAIN" | command grep -c . || true)
{ LC_ALL=C cut -f6,7 "$MR"; LC_ALL=C awk -F'\t' '/^## 副表/{f=1; next} f && NF>=2 && $1!="项" && $1!="" && $1!~/^[|#]/ {print $2"\t"$3}' "$MAIN"; } | LC_ALL=C sort -u | command grep -c . > "$EV/.ac7n"
want=$((30 + SUB))
got=$(cat "$EV/.ac7n")
if [ "$got" != "$want" ]; then ac_fail "AC7: 唯一(载体,锚点)=$got 应 $want (副表 $SUB 行)"; fi
rm -f "$EV/.ac7n"
verdict AC7

# ── AC8: subtable >=6 rows, contains 反合理化 & Forbidden, no 平台绑定交互决策 ──
ACN_FAILS=0; echo "AC8: 副表"
SUBREGION=$(LC_ALL=C awk '/^## 副表/{f=1;next} /^## / && f && $0!="## 副表"{exit} f{print}' "$MAIN")
if ! printf '%s' "$SUBREGION" | LC_ALL=C command grep -q '反合理化'; then ac_fail "AC8: 副表缺 反合理化"; fi
if ! printf '%s' "$SUBREGION" | LC_ALL=C command grep -q 'Forbidden'; then ac_fail "AC8: 副表缺 Forbidden"; fi
if printf '%s' "$SUBREGION" | LC_ALL=C command grep -q '平台绑定交互决策'; then ac_fail "AC8: 副表不得含 平台绑定交互决策"; fi
[ "$SUB" -ge 6 ] || ac_fail "AC8: 副表仅 $SUB 行（需≥6）"
# sub rows pass AC4/AC5-style checks
LC_ALL=C awk -F'\t' '/^## 副表/{f=1; next} f && NF>=4 && $1!="项" && $1!="" && $1!~/^[|#]/ && $4!="" {print $1"\t"$2"\t"$3"\t"$4}' "$MAIN" > "$EV/.ac8sub"
while IFS=$'\t' read -r item carrier anchor trig; do
  [ -n "$item" ] || continue
  if [ ! -f "$R/$carrier" ]; then ac_fail "AC8 $item: 载体不存在"; continue; fi
  if ! LC_ALL=C command grep -Fq -e "$anchor" "$R/$carrier"; then ac_fail "AC8 $item: 锚点不在载体"; fi
  b=$(printf '%s' "$anchor" | LC_ALL=C wc -c | tr -d ' ')
  [ "$b" -ge 12 ] || ac_fail "AC8 $item: 锚点仅 ${b}B"
  if ! printf '%s' "$trig" | LC_ALL=C command grep -Fq -e "$anchor"; then ac_fail "AC8 $item: 触发串不含锚点"; fi
  if ! printf '%s' "$trig" | LC_ALL=C command grep -Eq -e "$W"; then ac_fail "AC8 $item: 触发串未命中宽词表"; fi
done < "$EV/.ac8sub"
rm -f "$EV/.ac8sub"
verdict AC8

# ── AC9: 20 待判 rows have non-empty 解除待判, no TBD/待定/N/A, >=10 distinct ──
ACN_FAILS=0; echo "AC9: 待判解除条件"
LC_ALL=C awk -F'\t' '$2=="待判" && ($12=="" || $12=="-"){print NR": 解除待判空"}' "$MR" > "$EV/.ac9a"
LC_ALL=C awk -F'\t' '$2=="待判" && $12 ~ /TBD|待定|N\/A/{print NR": 禁用词 "$12}' "$MR" > "$EV/.ac9b"
nd=$(LC_ALL=C awk -F'\t' '$2=="待判"{print $12}' "$MR" | LC_ALL=C sort -u | command grep -c . || true)
if [ "$nd" -lt 10 ]; then ac_fail "AC9: 解除待判去重仅 $nd 种（需≥10）"; else echo "  AC9 去重 $nd 种"; fi
if [ -s "$EV/.ac9a" ] || [ -s "$EV/.ac9b" ]; then ac_fail "AC9:"; cat "$EV/.ac9a" "$EV/.ac9b" | LC_ALL=C cut -c1-90 | head -6; fi
rm -f "$EV/.ac9a" "$EV/.ac9b"
verdict AC9

# ── AC10: 清单缺口 section ──
ACN_FAILS=0; echo "AC10: 清单缺口节"
for tok in "凭据" "修改框架自身" "R6" "CLAUDE.md:50"; do
  LC_ALL=C command grep -qF "$tok" "$MAIN" || ac_fail "AC10: 缺逐字 $tok"
done
if ! LC_ALL=C awk -F'\t' '$11=="是"{print $1}' "$MR" | LC_ALL=C command grep -qF "版本发布管理"; then
  ac_fail "AC10: 不可降级=是 行无 版本发布管理"
fi
verdict AC10

# ── AC11: 承接单 section ──
ACN_FAILS=0; echo "AC11: 承接单节"
LC_ALL=C command grep -q 'expert-criteria' "$MAIN" || ac_fail "AC11: 缺 expert-criteria"
LC_ALL=C command grep -q 'expert-criteria-wiring' "$MAIN" || ac_fail "AC11: 缺承接单名 expert-criteria-wiring"
LC_ALL=C command grep -qE 'grep|awk|find|ls-files' "$MAIN" || ac_fail "AC11: 缺测量命令"
LC_ALL=C command grep -qE '[0-9]+/[0-9]+' "$MAIN" || ac_fail "AC11: 缺分子/分母"
LC_ALL=C command grep -qE '[0-9]+(\.[0-9]+)?%' "$MAIN" || ac_fail "AC11: 缺百分比"
if LC_ALL=C command grep -q '86%\|4557' "$MAIN"; then ac_fail "AC11: 出现禁用数字 86% 或 4557"; fi
verdict AC11

# ── AC12: contract/step0/keys30 unchanged vs T0 ──
ACN_FAILS=0; echo "AC12: 三输入冻结"
if git -C "$R" diff --quiet "${T0}" -- "$H" "$S0" "$K30"; then echo "  AC12 frozen OK"; else ac_fail "AC12: 输入被改"; fi
verdict AC12

# ── AC13: fence ──
ACN_FAILS=0; echo "AC13: fence"
{
  git -C "$R" -c core.quotePath=false diff --name-only HEAD -- .
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard
} | LC_ALL=C sort -u > "$EV/.ac13-now"
ac13_bad=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  case "$f" in
    .tad/discipline-floor.md) ;;
    .tad/evidence/acceptance-tests/discipline-floor/*) ;;
    .tad/archive/handoffs/COMPLETION-20260816-discipline-floor.md) ;;
    *) if LC_ALL=C command grep -qxF "$f" "$EV/fence-baseline.txt"; then :;
       elif [[ "$f" == .tad/evidence/traces/*.jsonl || "$f" == .tad/evidence/decisions/*.jsonl ]]; then :;
       else ac13_bad=1; echo "  AC13 OUT OF FENCE: $f"; fi ;;
  esac
done < "$EV/.ac13-now"
if [ "$ac13_bad" = "0" ]; then echo "  AC13 fence clean"; else ac_fail "AC13 fence breach"; fi
rm -f "$EV/.ac13-now"
verdict AC13

# ── AC14: summary figures recomputed + wording + lite exclusion ──
ACN_FAILS=0; echo "AC14: 汇总真实"
if PY14=$(python3 - "$R" "$MAIN" 2>&1 <<'PYEOF'
import sys, re, os
R, MAIN = sys.argv[1:3]
def bytelist(rows, col):
    return sum(len(r[col].encode("utf-8")) for r in rows)
main_rows = [l.rstrip("\n").split("\t") for l in open(MAIN, encoding="utf-8") if l.strip() and not l.startswith("#") and not l.startswith("|")]
# main table rows = 12 cols
main_rows = [r for r in main_rows if len(r) >= 12]
layer0 = [r for r in main_rows if r[8] == "0"]
full = [r for r in layer0 if r[2] in ("both", "full")]
lite = [r for r in layer0 if r[2] in ("both", "lite")]
both = [r for r in layer0 if r[2] == "both"]
def parse_sub(txt):
    rows = []
    in_sub = False
    for line in txt.split("\n"):
        if line.startswith("## 副表"): in_sub = True; continue
        if in_sub and line.startswith("## "): break
        if in_sub and line.strip() and not line.startswith("#") and not line.startswith("|"):
            p = line.split("\t")
            if len(p) >= 4 and p[0] != "项": rows.append(p)
    return rows
sub = parse_sub(open(MAIN, encoding="utf-8").read())
carrier_files = {}
for r in main_rows: carrier_files.setdefault(r[5], 1)
for r in sub: carrier_files.setdefault(r[1], 1)
carrier_b = sum(os.path.getsize(os.path.join(R, f)) for f in carrier_files if os.path.exists(os.path.join(R, f)))
out = {
 "full_rows": len(full), "full_b": bytelist(full, 7),
 "lite_rows": len(lite), "lite_b": bytelist(lite, 7),
 "both_rows": len(both), "both_b": bytelist(both, 7),
 "sub_rows": len(sub), "sub_b": bytelist(sub, 3),
 "carrier_b": carrier_b,
}
print(" ".join(f"{k}={v}" for k, v in out.items()))
PYEOF
); then
  # compare ALL five lines with the recomputed figures
  while IFS=' ' read -r want_rows want_bytes; do :; done <<< "$PY14"
  for pair in "full|full_rows|full_b" "lite|lite_rows|lite_b" "共有(both)|both_rows|both_b" "副表|sub_rows|sub_b"; do
    head=${pair%%|*}; rest=${pair#*|}; rows_k=${rest%%|*}; bytes_k=${rest##*|}
    case "$head" in
      "共有(both)") prefix="共有(both)      :";;
      "副表")       prefix="副表            :";;
      *)            prefix="$head 激活 Layer0:";;
    esac
    want_line="$prefix 行数 $(echo "$PY14" | LC_ALL=C sed -n "s/.*$rows_k=\([0-9]*\).*/\1/p") 触发串合计 $(echo "$PY14" | LC_ALL=C sed -n "s/.*$bytes_k=\([0-9]*\).*/\1/p") bytes"
    got_line=$(LC_ALL=C command grep -F "$prefix" "$MAIN" | head -1)
    if [ "$got_line" != "$want_line" ]; then ac_fail "AC14: 行不符 [$head]"; echo "  got:  $got_line"; echo "  want: $want_line"; fi
  done
  sec_carrier=$(LC_ALL=C command grep -F '触发串所在载体文件当前整读合计' "$MAIN" | head -1)
  want_carrier="触发串所在载体文件当前整读合计: $(echo "$PY14" | LC_ALL=C sed -n 's/.*carrier_b=\([0-9]*\).*/\1/p') bytes   ← P7 前的真实下界"
  if [ "$sec_carrier" != "$want_carrier" ]; then ac_fail "AC14: carrier 行不符"; echo "  got:  $sec_carrier"; echo "  want: $want_carrier"; fi
  # lite not counted into full: verify full sums exclude lite-only rows (liteless)
  if ! LC_ALL=C command grep -qF '本数为触发串之和（bytes），SC1 的 107.7K 为单次 full 激活的整读量（tokens 口径），两者不可直接比较。' "$MAIN"; then
    ac_fail "AC14: 口径警告未逐字"
  fi
  if ! LC_ALL=C command grep -q 'lite.*不计入 SC1' "$MAIN"; then ac_fail "AC14: 缺 lite 不计入 SC1 说明"; fi
else
  echo "$PY14"
  ac_fail "AC14: 汇总重算失败"
fi
verdict AC14

if [ "$FAILED" = "0" ]; then DONE=1; fi
