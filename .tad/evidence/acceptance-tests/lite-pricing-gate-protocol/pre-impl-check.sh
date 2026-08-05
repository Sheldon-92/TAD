#!/bin/bash
S=.tad/evidence/acceptance-tests/lite-pricing-gate-protocol
BASE=31a96aae3332adc87c565d06defff808cc8bef06
echo "=== AC1 (expect 28 FAIL lines pre-impl) ==="
for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md; do
  for s in '## 约束准入' '每单成本' '挡什么失败模式' '载体路径' 'HAS-CARRIER' 'NO-CARRIER' \
           'PROVISIONAL: review-by' 'SUPERSEDED' 'RETIRED' '追加台账行前的强制前置动作' \
           '没有后台自动机制' '复查默认动作 = 删除' '反合理化（准入侧）' '反合理化（复查侧）'; do
    grep -Fq "$s" "$f" || echo "AC1 FAIL [$f] $s"
  done
done
echo "=== AC2 (expect position FAIL + cmp FAIL + empty FAIL) ==="
rm -f "$S/sec-alex-lite.txt" "$S/sec-blake-lite.txt"
for f in alex-lite blake-lite; do
  SK=.claude/skills/$f/SKILL.md
  a=$(grep -n '^## 约束准入' "$SK" | cut -d: -f1)
  b=$(grep -n '^## Forbidden' "$SK" | cut -d: -f1)
  { [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ]; } \
    || { echo "AC2 FAIL 位置 [$f] a=$a b=$b"; continue; }
  sed -n "$a,$((b-1))p" "$SK" > "$S/sec-$f.txt"
done
cmp "$S/sec-alex-lite.txt" "$S/sec-blake-lite.txt" 2>/dev/null \
  || echo "AC2 FAIL: 两 skill 的约束准入节不一致或缺失"
[ -s "$S/sec-alex-lite.txt" ] || echo "AC2 FAIL: 节为空 (alex)"
[ -s "$S/sec-blake-lite.txt" ] || echo "AC2 FAIL: 节为空 (blake)"
echo "=== AC3 (expect ledger missing FAIL) ==="
L=.tad/evidence/audits/lite-constraint-ledger.md
[ -s "$L" ] || { echo "AC3 FAIL: ledger missing/empty"; }
grep -Fq '| 日期 | skill | 节 | 约束摘要 | 每单成本 | 挡什么失败模式 | 载体路径 | 状态 |' "$L" 2>/dev/null || echo "AC3 FAIL: 表头"
grep -Fxq '|---|---|---|---|---|---|---|---|' "$L" 2>/dev/null || echo "AC3 FAIL: 分隔行"
n=$(grep -cE '^\|[^-]' "$L" 2>/dev/null); [ "$n" -eq 1 ] || echo "AC3 FAIL: 应仅表头 1 行，实为 $n"
echo "=== AC4 (expect FAIL: n=0) ==="
git diff --numstat "$BASE" \
  -- .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md \
| awk 'BEGIN{n=0} {n++; if($2!="0") bad=1; if($1+0==0) bad=1} END{if(n!=2||bad) print "AC4 FAIL"}'
echo "=== AC5 baseline (expect silent — before==after) ==="
ALLOW=$(cat "$S/allow.txt")
git diff --name-only "$BASE" | LC_ALL=C sort > "$S/tracked-after.txt"
comm -13 "$S/tracked-before.txt" "$S/tracked-after.txt" | grep -vE "$ALLOW"
echo "=== AC5b baseline (expect silent — sha equal) ==="
if [ -s "$S/tracked-before.txt" ]; then
  git diff "$BASE" -- $(tr '\n' ' ' < "$S/tracked-before.txt") | shasum > "$S/tracked-after.sha"
else : > "$S/tracked-after.sha"; fi
cmp -s "$S/tracked-before.sha" "$S/tracked-after.sha" || echo "AC5b FAIL: 预存在脏文件被改动"
echo "=== AC6 baseline (expect silent — before==after) ==="
ALLOW=$(cat "$S/allow.txt")
git -c core.quotePath=false status --porcelain --untracked-files=all \
  | grep '^??' | cut -c4- | LC_ALL=C sort > "$S/untracked-after.txt"
comm -13 "$S/untracked-before.txt" "$S/untracked-after.txt" | grep -vE "$ALLOW"
echo "=== AC7 (expect AGENTS-MISSING x2) ==="
for f in alex-lite blake-lite; do
  grep -Fq '## 约束准入' .agents/skills/$f/SKILL.md || echo "AC7 FAIL AGENTS-MISSING $f"
  cmp -s .claude/skills/$f/SKILL.md .agents/skills/$f/SKILL.md || echo "AC7 FAIL DIFF $f"
done
bash .tad/hooks/lib/release-verify.sh parity . 2>&1 | tail -3
echo "=== done ==="
