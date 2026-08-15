#!/usr/bin/env bash
# AC verify — HANDOFF-20260815-discipline-enumeration (rev2)
# Red: exit != 0 AND last line RESULT=FAIL.  Per-AC checks; --negative <fixture> mode
# substitutes the disposition file for adversarial runs (AC9 negative controls).
set -u
R="$(git rev-parse --show-toplevel)"
EV="$R/.tad/evidence/acceptance-tests/discipline-enumeration"
H="$R/.tad/active/handoffs/HANDOFF-20260815-discipline-enumeration.md"
S0="$R/.tad/active/handoffs/HANDOFF-20260815-discipline-enumeration.step0.sh"
DISP="${1:-$R/.tad/evidence/designs/discipline-inventory/disposition-60.md}"   # --negative <fixture>
if [ "${1:-}" = "--negative" ]; then DISP="$2"; fi
T0=$(cat "$EV/t0.txt")
export LC_ALL=C
FAILED=0; DONE=0; ACN_FAILS=0
trap 'if [ "${DONE:-0}" = "1" ]; then echo "RESULT=PASS"; exit 0; else echo "RESULT=FAIL"; exit 1; fi' EXIT
ac_fail() { ACN_FAILS=$((ACN_FAILS+1)); FAILED=1; echo "  AC FAIL: $*"; }
verdict() { if [ "$ACN_FAILS" = "0" ]; then echo "$1 PASS"; else echo "$1 FAIL"; fi; }

# ── AC1: first 3 cols == blocks.txt, exactly 60 rows ──
ACN_FAILS=0; echo "AC1: disposition cols 1-3 == blocks.txt"
nrows=$(command grep -c . "$DISP" || true)
if [ "$nrows" != "60" ]; then ac_fail "rows=$nrows (want 60)"; fi
LC_ALL=C cut -f1-3 "$DISP" | LC_ALL=C sort > "$EV/.ac1-disp"
LC_ALL=C sort "$EV/blocks.txt" | LC_ALL=C cut -f1-3 > "$EV/.ac1-blocks"
LC_ALL=C comm -3 "$EV/.ac1-disp" "$EV/.ac1-blocks" > "$EV/.ac1-comm"
if [ -s "$EV/.ac1-comm" ]; then ac_fail "comm diff:"; LC_ALL=C cut -c1-90 "$EV/.ac1-comm" | head -5; fi
rm -f "$EV/.ac1-comm" "$EV/.ac1-disp" "$EV/.ac1-blocks"
verdict AC1

# ── AC2: disposition col4 regex + 已有:{X} X in names.txt ──
ACN_FAILS=0; echo "AC2: 归宿 syntax + 已有名 ∈ names.txt"
LC_ALL=C awk -F'\t' '$4 !~ /^(已有:.+|新增:.+|非纪律)$/{print NR": "$4}' "$DISP" > "$EV/.ac2a"
if [ -s "$EV/.ac2a" ]; then ac_fail "bad 归宿:"; LC_ALL=C cut -c1-90 "$EV/.ac2a" | head -5; fi
LC_ALL=C awk -F'\t' '$4 ~ /^已有:/{n=$4; sub(/^已有:/,"",n); print n}' "$DISP" | LC_ALL=C sort -u > "$EV/.ac2b"
LC_ALL=C comm -23 "$EV/.ac2b" "$EV/names.txt" > "$EV/.ac2c"
if [ -s "$EV/.ac2c" ]; then ac_fail "已有名不在 names.txt:"; cat "$EV/.ac2c"; fi
rm -f "$EV/.ac2a" "$EV/.ac2b" "$EV/.ac2c"
verdict AC2

# ── AC3: reason codes R1..R5, only on 非纪律 rows ──
ACN_FAILS=0; echo "AC3: 理由码闭集 + 仅非纪律行非空"
LC_ALL=C awk -F'\t' '$5!="" && $4!="非纪律"{print NR": 非纪律行带理由码"}' "$DISP" > "$EV/.ac3a"
LC_ALL=C awk -F'\t' '$5!="" && $5 !~ /^R[1-5]$/{print NR": bad code "$5}' "$DISP" > "$EV/.ac3b"
LC_ALL=C awk -F'\t' '$4=="非纪律" && $5==""{print NR": 非纪律行缺理由码"}' "$DISP" > "$EV/.ac3c"
if [ -s "$EV/.ac3a" ] || [ -s "$EV/.ac3b" ] || [ -s "$EV/.ac3c" ]; then
  ac_fail "AC3 violations:"; cat "$EV/.ac3a" "$EV/.ac3b" "$EV/.ac3c" | LC_ALL=C cut -c1-90 | head -8
fi
rm -f "$EV/.ac3a" "$EV/.ac3b" "$EV/.ac3c"
verdict AC3

# ── AC4 + AC4b: 一句话 fragment checks (per hits tier) + hit counts vs hits.tsv ──
ACN_FAILS=0; echo "AC4: 原文片段分档 + AC4b: 命中数列 == hits.tsv"
if PY4=$(python3 - "$R" "$EV" "$DISP" 2>&1 <<'PYEOF'
import sys, subprocess, re
R, EV, DISP = sys.argv[1:4]
WIDE = open(f"{EV}/wide-markers.txt", encoding="utf-8").read().rstrip("\n")
def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, encoding="utf-8").stdout
def block_text(f, s, e):
    return run(f'sed -n "{s},{e}p" "{R}/{f}"')
rows = [l.rstrip("\n").split("\t") for l in open(DISP, encoding="utf-8") if l.strip()]
blocks = [l.rstrip("\n").split("\t") for l in open(f"{EV}/blocks.txt", encoding="utf-8")]
ranges = [l.rstrip("\n").split("\t") for l in open(f"{EV}/ranges.txt", encoding="utf-8")]
hits = [l.rstrip("\n").split("\t") for l in open(f"{EV}/hits.tsv", encoding="utf-8")]
assert len(rows) == len(blocks) == len(ranges) == len(hits) == 60
fails = []
marker_re = re.compile(r"(?:" + WIDE + r")")
for i in range(60):
    f, s, e = ranges[i]
    sentence = rows[i][5] if len(rows[i]) > 5 else ""
    hit_col = rows[i][6] if len(rows[i]) > 6 else ""
    want_hit = hits[i][2]
    if hit_col != want_hit:
        fails.append(f"row {i+1}: hit col '{hit_col}' != hits.tsv '{want_hit}'"); continue
    w = int(want_hit)
    text = block_text(f, s, e)
    lines = [ln for ln in text.split("\n")]
    # user ruling 2026-08-15: block with NO >=12B text in range (gate:2 "name: gate", 10B)
    # is exempt from the >=12B fragment requirement — fragment = block-name line is enough
    maxlen = max((len(ln) for ln in lines), default=0)
    if maxlen < 12:
        if "name: gate" not in sentence and not any(ln.strip() and ln.strip() in sentence for ln in lines):
            fails.append(f"row {i+1}: short block fragment missing")
        if w == 0 and rows[i][3] != "非纪律" and "零标记但仍属纪律·理由：" not in sentence:
            fails.append(f"row {i+1}: short block hits=0 non-非纪律 missing 零标记理由 marker")
        continue
    # longest in-range fragment scan: grow each start position until mismatch
    frag_found = None; frag_line_hit = False
    for k in range(len(sentence)):
        j = k
        while j < len(sentence) and sentence[k:j+1] in text:
            j += 1
        if len(sentence[k:j].encode("utf-8")) >= 12:
            frag_found = sentence[k:j]
            for ln in lines:
                if frag_found in ln and marker_re.search(ln):
                    frag_line_hit = True
                    break
            break
    if not frag_found:
        fails.append(f"row {i+1}: no >=12B block fragment in sentence")
        continue
    if w >= 1 and not frag_line_hit:
        fails.append(f"row {i+1}: fragment line does not hit wide markers (hits={w})")
    if w == 0 and rows[i][3] != "非纪律" and "零标记但仍属纪律·理由：" not in sentence:
        fails.append(f"row {i+1}: hits=0 non-非纪律 missing 零标记理由 marker")
    if w == 0 and rows[i][3] != "非纪律":
        tail = sentence.split("零标记但仍属纪律·理由：", 1)
        if len(tail) == 2 and len(tail[1].encode("utf-8")) < 20:
            fails.append(f"row {i+1}: 零标记理由 < 20 bytes")
print("; ".join(fails) if fails else "AC4 OK")
sys.exit(1 if fails else 0)
PYEOF
); then
  echo "  $PY4"
else
  echo "$PY4"
  ac_fail "AC4/AC4b"
fi
verdict AC4

# ── AC5: existing 15 rows verbatim (vs git show T0) + body row count ──
ACN_FAILS=0; echo "AC5: inventory 既有15行逐字 + 行数"
INV="$R/.tad/evidence/designs/discipline-inventory/discipline-inventory.md"
git -C "$R" show "${T0}:.tad/evidence/designs/discipline-inventory/discipline-inventory.md" > "$EV/.inv-t0" 2>/dev/null || { ac_fail "T0 inventory missing"; }
# existing rows = T0 table body (lines 13..27 in T0)
sed -n '13,27p' "$EV/.inv-t0" > "$EV/.inv15"
# live: 15 rows still at 13..27 if only 表尾追加 happened; locate by table start
hdr=$(command grep -n '^| 纪律 | 来源 |' "$INV" | LC_ALL=C cut -d: -f1 | head -1)
if [ -z "$hdr" ]; then ac_fail "inventory table header not found"; else
  sed -n "$((hdr+2)),$((hdr+16))p" "$INV" > "$EV/.inv-live15"
  if ! LC_ALL=C cmp -s "$EV/.inv15" "$EV/.inv-live15"; then ac_fail "既有15行被改动"; fi
  # body rows count: data rows from hdr+2 to end of table
  end=$(awk -v s=$((hdr+2)) 'NR>=s && /^$/{print NR; exit}' "$INV")
  [ -z "$end" ] && end=$(wc -l < "$INV" | tr -d ' ')
  body=$(( end - (hdr+2) ))
  nadd=$(LC_ALL=C awk -F'\t' '$4 ~ /^新增:/{print $4}' "$DISP" | LC_ALL=C sed 's/（非候选新增）//' | LC_ALL=C sort -u | command grep -c . || true)
  want=$((15 + nadd))
  if [ "$body" != "$want" ]; then ac_fail "inventory body rows=$body (want $want, 新增去重=$nadd)"; else echo "  body=$body OK (15+$nadd)"; fi
fi
rm -f "$EV/.inv-t0" "$EV/.inv15" "$EV/.inv-live15"
verdict AC5

# ── AC6: each 新增 exactly once in inventory; per-column whitelist; col count == header ──
ACN_FAILS=0; echo "AC6: 新增唯一 + 白名单列 + 列数"
hdr=$(command grep -n '^| 纪律 | 来源 |' "$INV" | LC_ALL=C cut -d: -f1 | head -1)
hdrcols=$(sed -n "${hdr}p" "$INV" | awk -F'|' '{print NF-2}')
for name in $(LC_ALL=C awk -F'\t' '$4 ~ /^新增:/{print $4}' "$DISP" | LC_ALL=C sed 's/（非候选新增）//' | LC_ALL=C sort -u); do
  cnt=$(LC_ALL=C command grep -cF "| ${name#新增:} |" "$INV" || true)
  if [ "$cnt" != "1" ]; then ac_fail "新增 ${name} 在 inventory 出现 ${cnt} 次"; fi
done
# appended rows are those after the 15 existing ones; check whitelist + col count
end=$(awk -v s=$((hdr+2)) 'NR>=s && /^$/{print NR; exit}' "$INV"); [ -z "$end" ] && end=$(wc -l < "$INV" | tr -d ' ')
sed -n "$((hdr+17)),$((end-1))p" "$INV" > "$EV/.inv-new"
LC_ALL=C awk -F'|' -v want="$hdrcols" 'NF-2 != want{print NR": cols="NF-2" want="want}' "$EV/.inv-new" > "$EV/.ac6a"
# whitelist columns 2,3,4,5,7,9 (纪律/来源/成本/频率/三类判定/地板·可缩放)
LC_ALL=C awk -F'|' '{
  v2=$2;v3=$3;v4=$4;v5=$5;v7=$7;v9=$9
  if(v2 ~ /^ *$|^ *- *$/) print NR": 纪律列空"
  if(v3 ~ /^ *$|^ *- *$/) print NR": 来源列空"
  if(v4 ~ /^ *$|^ *- *$/) print NR": 成本列空"
  if(v5 ~ /^ *$|^ *- *$/) print NR": 频率列空"
  if(v7 ~ /^ *$|^ *- *$/) print NR": 三类判定列空"
  if(v9 ~ /^ *$|^ *- *$/) print NR": 地板·可缩放列空"
}' "$EV/.inv-new" > "$EV/.ac6b"
if [ -s "$EV/.ac6a" ] || [ -s "$EV/.ac6b" ]; then ac_fail "AC6:"; cat "$EV/.ac6a" "$EV/.ac6b" | LC_ALL=C cut -c1-90 | head -8; fi
rm -f "$EV/.inv-new" "$EV/.ac6a" "$EV/.ac6b"
verdict AC6

# ── AC7: 强制子键 col == subkeys.tsv set (sorted), every subkey explainable ──
ACN_FAILS=0; echo "AC7: 子键集合逐字 + 子键可解释"
LC_ALL=C awk -F'\t' '{print $1"\t"$2"\t"$3}' "$EV/subkeys.tsv" | LC_ALL=C sort -u > "$EV/.sk-all"
for i in $(seq 1 60); do
  f=$(sed -n "${i}p" "$EV/blocks.txt" | LC_ALL=C cut -f1)
  s=$(sed -n "${i}p" "$EV/blocks.txt" | LC_ALL=C cut -f2)
  got=$(sed -n "${i}p" "$DISP" | LC_ALL=C cut -f8 | tr ',' '\n' | LC_ALL=C sed 's/^ *//;s/ *$//' | LC_ALL=C grep -v '^$' | LC_ALL=C grep -v '^-$' | LC_ALL=C sort -u)
  want=$(LC_ALL=C awk -F'\t' -v f="$f" -v s="$s" '$1==f && $2==s{print $3}' "$EV/subkeys.tsv" | LC_ALL=C sort -u)
  if [ "$got" != "$want" ]; then
    ac_fail "row $i ${f}:$s subkey set mismatch"
    echo "    got:  $(echo "$got" | tr '\n' ',' | head -c 150)"
    echo "    want: $(echo "$want" | tr '\n' ',' | head -c 150)"
  fi
done
# explainability: the hand-written sentence must explain the block's subkeys — mention 子键
# and at least one of this block's subkey names (guards against mechanically appended lists).
miss=0
while IFS=$'\t' read -r f s k; do
  sentence=$(LC_ALL=C awk -F'\t' -v f="$f" -v s="$s" '$1==f && $2==s{print $6}' "$DISP" | head -1)
  if ! printf '%s' "$sentence" | LC_ALL=C command grep -qF "子键"; then miss=$((miss+1)); continue; fi
  named=0
  for kk in $(LC_ALL=C awk -F'\t' -v f="$f" -v s="$s" '$1==f && $2==s{print $3}' "$EV/subkeys.tsv" | LC_ALL=C sort -u); do
    if printf '%s' "$sentence" | LC_ALL=C command grep -qF "$kk"; then named=1; break; fi
  done
  [ "$named" = "1" ] || miss=$((miss+1))
done < "$EV/.sk-all"
if [ "$miss" != "0" ]; then ac_fail "AC7: $miss subkey-blocks not explained (sentence must mention 子键 + at least one subkey name)"; fi
rm -f "$EV/.sk-all"
verdict AC7

# ── AC8: gate2-candidates.md — 10 rows, 采纳/驳回, 驳回≥20B, 属实 vs keyword ──
ACN_FAILS=0; echo "AC8: gate2-candidates.md"
G2="$R/.tad/evidence/designs/discipline-inventory/gate2-candidates.md"
n=$(command grep -c . "$G2" || true)
if [ "$n" != "10" ]; then ac_fail "rows=$n (want 10)"; fi
while IFS=$'\t' read -r name verdict fl verdict2 key reason; do
  [ -n "$name" ] || continue
  if [ "$verdict" != "驳回" ] && [[ "$verdict" != 采纳:* ]]; then ac_fail "bad verdict: $verdict"; fi
  if [ "$verdict" = "驳回" ]; then
    b=$(printf '%s' "$reason" | LC_ALL=C wc -c | tr -d ' ')
    [ "$b" -ge 20 ] || ac_fail "驳回理由仅 ${b}B: $name"
  fi
  fn=${fl%:*}; ln=${fl##*:}
  mech=$(sed -n "${ln}p" "$R/$fn" | LC_ALL=C command grep -Fq "$key" && echo 属实 || echo 不属实)
  if [ "$mech" != "$verdict2" ]; then ac_fail "AC8 $name: 标 $verdict2 但机械=$mech ($fn:$ln)"; fi
  # cross-check the (file:line, keyword) against the FROZEN candidates.tsv (contract AC8: 与 candidates.tsv 机械比对)
  ck=$(LC_ALL=C awk -F'\t' -v n="$name" '$1==n{print $2"\t"$3"\t"$4}' "$EV/candidates.tsv")
  cfl=${ck%%$'\t'*}; rest=${ck#*$'\t'}; cln=${rest%%$'\t'*}; ckey=${rest##*$'\t'}
  if [ "$fn:$ln" != "$cfl:$cln" ] || [ "$key" != "$ckey" ]; then ac_fail "AC8 $name: 与 candidates.tsv 不符 (G2=$fn:$ln/$key vs 候选=$cfl:$cln/$ckey)"; fi
done < "$G2"
verdict AC8

# ── AC10: no single 已有:{X} covers >24 rows ──
ACN_FAILS=0; echo "AC10: 已有 分布 ≤24"
LC_ALL=C awk -F'\t' '$4 ~ /^已有:/{print $4}' "$DISP" | LC_ALL=C sort | LC_ALL=C uniq -c | LC_ALL=C awk '$1>24{print $2": "$1" rows"}' > "$EV/.ac10"
if [ -s "$EV/.ac10" ]; then ac_fail "AC10:"; cat "$EV/.ac10"; fi
rm -f "$EV/.ac10"
verdict AC10

# ── AC11: 采纳↔新增 bidirectional binding ──
ACN_FAILS=0; echo "AC11: 采纳↔新增 绑定"
adopt=$(LC_ALL=C awk -F'\t' '$1!="" && $2 ~ /^采纳:/{sub(/^采纳:/,"",$2); print $2}' "$G2" | LC_ALL=C sort -u)
new_disp=$(LC_ALL=C awk -F'\t' '$4 ~ /^新增:/{print $4}' "$DISP" | LC_ALL=C sed 's/（非候选新增）//;s/^新增://' | LC_ALL=C sort -u)
# every adopted name must appear as 新增
for a in $adopt; do
  if ! printf '%s\n' "$new_disp" | LC_ALL=C command grep -qxF "$a"; then ac_fail "AC11: 采纳 ${a} 无对应 新增"; fi
done
# every 新增 must be adopted or marked 非候选新增
while IFS= read -r nd; do
  if ! printf '%s\n' "$adopt" | LC_ALL=C command grep -qxF "$nd"; then
    m=$(LC_ALL=C awk -F'\t' -v n="新增:${nd}" '$4==n || $4==n"（非候选新增）"{c++} END{print c+0}' "$DISP")
    marked=$(LC_ALL=C awk -F'\t' -v n="新增:${nd}" '$4==n"（非候选新增）"{print 1}' "$DISP" | head -1)
    if [ "$marked" != "1" ]; then ac_fail "AC11: 新增 ${nd} 未采纳且未标非候选新增"; fi
  fi
done <<< "$new_disp"
verdict AC11

# ── AC12: fence ──
ACN_FAILS=0; echo "AC12: fence"
{
  git -C "$R" -c core.quotePath=false diff --name-only HEAD -- .
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard
} | LC_ALL=C sort -u > "$EV/.ac12-now"
ac12_bad=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  case "$f" in
    .tad/evidence/designs/discipline-inventory/disposition-60.md) ;;
    .tad/evidence/designs/discipline-inventory/gate2-candidates.md) ;;
    .tad/evidence/designs/discipline-inventory/discipline-inventory.md) ;;
    .tad/evidence/acceptance-tests/discipline-enumeration/*) ;;
    .tad/archive/handoffs/COMPLETION-20260815-discipline-enumeration.md) ;;
    *) if LC_ALL=C command grep -qxF "$f" "$EV/fence-baseline.txt"; then :;
       elif [[ "$f" == .tad/evidence/traces/*.jsonl || "$f" == .tad/evidence/decisions/*.jsonl ]]; then :;
       else ac12_bad=1; echo "  AC12 OUT OF FENCE: $f"; fi ;;
  esac
done < "$EV/.ac12-now"
if [ "$ac12_bad" = "0" ]; then echo "  AC12 fence clean"; else ac_fail "AC12 fence breach"; fi
rm -f "$EV/.ac12-now"
verdict AC12

# ── AC13: contract + step0.sh unchanged vs T0 ──
ACN_FAILS=0; echo "AC13: contract + step0.sh frozen"
if git -C "$R" diff --quiet "${T0}" -- "$H" "$S0"; then echo "  AC13 frozen OK"; else ac_fail "AC13: contract/step0.sh changed"; fi
verdict AC13

if [ "$FAILED" = "0" ]; then DONE=1; fi
