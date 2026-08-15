#!/usr/bin/env bash
# P2b Step 0 —— 冻结基线。Blake 动手前运行，不得修改（AC12 守其哈希）。
set -uo pipefail
R="$(git rev-parse --show-toplevel)"
EV="$R/.tad/evidence/acceptance-tests/discipline-floor"; mkdir -p "$EV/negative-controls"
HB=".tad/active/handoffs/HANDOFF-20260816-discipline-floor"
D="$R/.tad/evidence/designs/discipline-inventory/discipline-inventory.md"
T0=$(git -C "$R" rev-parse --short HEAD); echo "$T0" > "$EV/t0.txt"
for f in "$HB.md" "$HB.step0.sh" "$HB.keys30.tsv"; do
  git -C "$R" ls-files --error-unmatch "$f" >/dev/null 2>&1 \
    || { echo "Step 0 失败：$f 未被 git 追踪，AC12 无外部载体"; exit 1; }
done
printf '%s\n' 'MUST|MANDATORY|BLOCKING|VIOLATION|forbidden|Forbidden|MUST NOT|NEVER|never |shall |required|Required|blocking: *true|不得|必须|禁止|严禁|一律|不可|不允许|应当|⚠️' > "$EV/wide-markers.txt"

# verdicts.tsv：纪律 ⇥ 既有判定 ⇥ 通道 ⇥ 触发条件（表列 $2/$9/$3/$8，逐字，零裁量）
sed -n '/^| 纪律 | 来源 |/,/^$/p' "$D" | command grep -v '^| 纪律 \|^|---' \
  | LC_ALL=C awk -F'|' 'NF>2{n=$2;v=$9;c=$3;t=$8;
      gsub(/^ +| +$/,"",n); gsub(/^ +| +$/,"",v); gsub(/^ +| +$/,"",c); gsub(/^ +| +$/,"",t);
      if(n!="") printf "%s\t%s\t%s\t%s\n", n, v, c, t}' > "$EV/verdicts.tsv"
LC_ALL=C cut -f1 "$EV/verdicts.tsv" | LC_ALL=C sort > "$EV/names30.txt"
N=$(command grep -c . "$EV/names30.txt")
[ "$N" -eq 30 ] || { echo "Step 0 失败：纪律数 $N，应 30（清单漂移，停下退回 Alex）"; exit 1; }
LC_ALL=C awk -F'\t' 'NF!=4{b++} END{exit (b+0)>0}' "$EV/verdicts.tsv" || { echo "Step 0 失败：verdicts.tsv 非四段"; exit 1; }

# 分布断言 7/3/20
F=$(LC_ALL=C awk -F'\t' '$2=="地板"{n++} END{print n+0}' "$EV/verdicts.tsv")
S=$(LC_ALL=C awk -F'\t' '$2=="可缩放"{n++} END{print n+0}' "$EV/verdicts.tsv")
P=$(LC_ALL=C awk -F'\t' '$2=="待判"{n++} END{print n+0}' "$EV/verdicts.tsv")
[ "$F" -eq 7 ] && [ "$S" -eq 3 ] && [ "$P" -eq 20 ] \
  || { echo "Step 0 失败：分布 地板=$F 可缩放=$S 待判=$P，应 7/3/20"; exit 1; }

# keys30.tsv 名单必须与 names30 逐字相等（否则 AC4 有纪律无判别词）
LC_ALL=C cut -f1 "$R/$HB.keys30.tsv" | LC_ALL=C sort > "$EV/.k"
LC_ALL=C comm -3 "$EV/.k" "$EV/names30.txt" | command grep -q . \
  && { echo "Step 0 失败：keys30.tsv 名单与 names30 不符"; LC_ALL=C comm -3 "$EV/.k" "$EV/names30.txt"; exit 1; }
LC_ALL=C awk -F'\t' 'NF!=2{b++} END{exit (b+0)>0}' "$R/$HB.keys30.tsv" || { echo "Step 0 失败：keys30.tsv 非两段"; exit 1; }
rm -f "$EV/.k"

{ git -C "$R" -c core.quotePath=false diff --name-only HEAD -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-baseline.txt"
echo "Step 0 OK: T0=$T0 | 30 条 | 地板 $F / 可缩放 $S / 待判 $P | keys30 已校验"
