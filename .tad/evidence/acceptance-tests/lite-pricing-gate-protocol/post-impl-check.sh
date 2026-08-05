#!/bin/bash
S=.tad/evidence/acceptance-tests/lite-pricing-gate-protocol
BASE=31a96aae3332adc87c565d06defff808cc8bef06
: > "$S/AC1.txt"
for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md; do
  for s in '## 约束准入' '每单成本' '挡什么失败模式' '载体路径' 'HAS-CARRIER' 'NO-CARRIER' \
           'PROVISIONAL: review-by' 'SUPERSEDED' 'RETIRED' '追加台账行前的强制前置动作' \
           '没有后台自动机制' '复查默认动作 = 删除' '反合理化（准入侧）' '反合理化（复查侧）'; do
    grep -Fq "$s" "$f" || echo "AC1 FAIL [$f] $s" >> "$S/AC1.txt"
  done
done
: > "$S/AC2.txt"
rm -f "$S/sec-alex-lite.txt" "$S/sec-blake-lite.txt"
for f in alex-lite blake-lite; do
  SK=.claude/skills/$f/SKILL.md
  a=$(grep -n '^## 约束准入' "$SK" | cut -d: -f1)
  b=$(grep -n '^## Forbidden' "$SK" | cut -d: -f1)
  { [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ]; } \
    || { echo "AC2 FAIL 位置 [$f] a=$a b=$b" >> "$S/AC2.txt"; continue; }
  sed -n "$a,$((b-1))p" "$SK" > "$S/sec-$f.txt"
done
cmp "$S/sec-alex-lite.txt" "$S/sec-blake-lite.txt" 2>/dev/null \
  || echo "AC2 FAIL: 两 skill 的约束准入节不一致或缺失" >> "$S/AC2.txt"
[ -s "$S/sec-alex-lite.txt" ] || echo "AC2 FAIL: 节为空 (alex)" >> "$S/AC2.txt"
[ -s "$S/sec-blake-lite.txt" ] || echo "AC2 FAIL: 节为空 (blake)" >> "$S/AC2.txt"
: > "$S/AC3.txt"
L=.tad/evidence/audits/lite-constraint-ledger.md
[ -s "$L" ] || echo "AC3 FAIL: ledger missing/empty" >> "$S/AC3.txt"
grep -Fq '| 日期 | skill | 节 | 约束摘要 | 每单成本 | 挡什么失败模式 | 载体路径 | 状态 |' "$L" || echo "AC3 FAIL: 表头" >> "$S/AC3.txt"
grep -Fxq '|---|---|---|---|---|---|---|---|' "$L" || echo "AC3 FAIL: 分隔行" >> "$S/AC3.txt"
n=$(grep -cE '^\|[^-]' "$L"); [ "$n" -eq 1 ] || echo "AC3 FAIL: 应仅表头 1 行，实为 $n" >> "$S/AC3.txt"
: > "$S/AC4.txt"
git diff --numstat "$BASE" \
  -- .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md \
| awk 'BEGIN{n=0} {n++; if($2!="0") bad=1; if($1+0==0) bad=1} END{if(n!=2||bad) print "AC4 FAIL"}' >> "$S/AC4.txt"
: > "$S/AC5.txt"
ALLOW=$(cat "$S/allow.txt")
git diff --name-only "$BASE" | LC_ALL=C sort > "$S/tracked-after.txt"
comm -13 "$S/tracked-before.txt" "$S/tracked-after.txt" | grep -vE "$ALLOW" >> "$S/AC5.txt"
: > "$S/AC5b.txt"
if [ -s "$S/tracked-before.txt" ]; then
  git diff "$BASE" -- $(tr '\n' ' ' < "$S/tracked-before.txt") | shasum > "$S/tracked-after.sha"
else : > "$S/tracked-after.sha"; fi
cmp -s "$S/tracked-before.sha" "$S/tracked-after.sha" || echo "AC5b FAIL: 预存在脏文件被改动" >> "$S/AC5b.txt"
: > "$S/AC6.txt"
ALLOW=$(cat "$S/allow.txt")
git -c core.quotePath=false status --porcelain --untracked-files=all \
  | grep '^??' | cut -c4- | LC_ALL=C sort > "$S/untracked-after.txt"
comm -13 "$S/untracked-before.txt" "$S/untracked-after.txt" | grep -vE "$ALLOW" >> "$S/AC6.txt"
: > "$S/AC7.txt"
for f in alex-lite blake-lite; do
  grep -Fq '## 约束准入' .agents/skills/$f/SKILL.md || echo "AC7 FAIL AGENTS-MISSING $f" >> "$S/AC7.txt"
  cmp -s .claude/skills/$f/SKILL.md .agents/skills/$f/SKILL.md || echo "AC7 FAIL DIFF $f" >> "$S/AC7.txt"
done
echo "=== AC results ==="
for i in 1 2 3 4 5 5b 6 7; do
  if [ -s "$S/AC$i.txt" ]; then echo "AC$i: FAIL"; cat "$S/AC$i.txt"; else echo "AC$i: PASS (silent)"; fi
done
