#!/bin/bash
# 实现后 AC1-AC9 验证 — TASK-20260805-P1a-fix（期望：全静默无输出；AC9 parity 判定行单独贴）
S=.tad/evidence/acceptance-tests/pricing-gate-scan-fix
BASE=4b29dc263a5368c0b598fc1030f465fc7ebdbc10

echo "========== AC1 落地命令整行逐字 =========="
for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md; do
  grep -Fxq '  awk -v t="$(date +%F)" '"'"'/[Pp][Rr][Oo][Vv][Ii][Ss][Ii][Oo][Nn][Aa][Ll][:：]?/ {' "$f" || echo "AC1 FAIL 命令第1行(前置过滤) [$f]"
  grep -Fxq '    if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|?[[:space:]]*$/)) {' "$f" || echo "AC1 FAIL 命令第2行 [$f]"
  grep -Fxq '      d = substr($0, RSTART+23, 10); if (d < t) print "OVERDUE: " $0 }' "$f" || echo "AC1 FAIL 命令第3行 [$f]"
  grep -Fxq '    else print "MALFORMED(须人工处置): " $0 }'"'"' \' "$f" || echo "AC1 FAIL 逃逸检测行 [$f]"
  grep -Fxq '    .tad/evidence/audits/lite-constraint-ledger.md' "$f" || echo "AC1 FAIL 台账路径行 [$f]"
  grep -Fq '仅限转为终态（HAS-CARRIER / NO-CARRIER / SUPERSEDED / RETIRED）' "$f" \
    || echo "AC1 FAIL 终态枚举缺失 [$f]"
  grep -Fq '禁止静默续期' "$f" || echo "AC1 FAIL 静默续期禁令 [$f]"
  grep -Fq '状态列恒为末列' "$f" || echo "AC1 FAIL 列序不变量 [$f]"
  grep -Fq '不要重复 PROVISIONAL 字样' "$f" || echo "AC1 FAIL 处置行踩雷提示缺失 [$f]"
  grep -Fq 'RSTART+10' "$f" && echo "AC1 FAIL 旧偏移残留 [$f]"
  grep -Fq '写进备注列' "$f" && echo "AC1 FAIL 旧备注列措辞残留 [$f]"
done
echo "AC1 完毕"

echo "========== AC2 节外内容与 BASE 逐字节相同 =========="
strip() { a=$(grep -c '^## 约束准入' "$1"); b=$(grep -c '^## Forbidden' "$1")
          { [ "$a" -eq 1 ] && [ "$b" -eq 1 ]; } || { echo "STRIP-FAIL 锚点非唯一 $1" >&2; return 1; }
          x=$(grep -n '^## 约束准入' "$1"|cut -d: -f1); y=$(grep -n '^## Forbidden' "$1"|cut -d: -f1)
          [ "$x" -lt "$y" ] || { echo "STRIP-FAIL 顺序错 $1" >&2; return 1; }
          sed "${x},$((y-1))d" "$1"; }
ok=0
for f in alex-lite blake-lite; do
  git show "$BASE:.claude/skills/$f/SKILL.md" > "$S/base-$f.md"
  strip "$S/base-$f.md" > "$S/base-strip-$f.md" || continue
  strip ".claude/skills/$f/SKILL.md" > "$S/cur-strip-$f.md" || continue
  cmp "$S/base-strip-$f.md" "$S/cur-strip-$f.md" || echo "AC2 FAIL 节外内容被改动 [$f]"
  ok=$((ok+1))
done
[ "$ok" -eq 2 ] || echo "AC2 FAIL 只跑了 $ok/2 个 skill（AC 未真正执行）"
echo "AC2 完毕"

echo "========== AC3 两节逐字节相同且仍在 ## Forbidden 前 =========="
rm -f "$S/sec-alex-lite.txt" "$S/sec-blake-lite.txt"
for f in alex-lite blake-lite; do SK=.claude/skills/$f/SKILL.md
  a=$(grep -n '^## 约束准入' "$SK"|cut -d: -f1); b=$(grep -n '^## Forbidden' "$SK"|cut -d: -f1)
  { [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ]; } || { echo "AC3 FAIL 位置 [$f] a=$a b=$b"; continue; }
  sed -n "$a,$((b-1))p" "$SK" > "$S/sec-$f.txt"; done
cmp "$S/sec-alex-lite.txt" "$S/sec-blake-lite.txt" 2>/dev/null || echo "AC3 FAIL 两节不一致或缺失"
[ -s "$S/sec-alex-lite.txt" ] || echo "AC3 FAIL 节为空 (alex)"
[ -s "$S/sec-blake-lite.txt" ] || echo "AC3 FAIL 节为空 (blake)"
echo "AC3 完毕"

echo "========== AC4a 命令级八场景 =========="
out=$(awk -v t="$(date +%F)" '/[Pp][Rr][Oo][Vv][Ii][Ss][Ii][Oo][Nn][Aa][Ll][:：]?/ {
  if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|?[[:space:]]*$/)) {
    d = substr($0, RSTART+23, 10); if (d < t) print "OVERDUE=" $2 }
  else print "MALFORMED=" $2 }' "$S/probe-cmd.md")
exp='OVERDUE=A1
OVERDUE=A2
MALFORMED=A6
MALFORMED=A8
MALFORMED=B1
MALFORMED=B2
MALFORMED=B3
OVERDUE=A7'
[ "$out" = "$exp" ] || { echo "AC4a FAIL 实际输出："; printf '%s\n' "$out"; }
echo "AC4a 完毕（旧命令对照见 old-cmd-ac4a.txt / new-cmd-ac4a.txt）"

echo "========== AC4b 约定级（僵旗）：就地转终态后静默 =========="
cat > "$S/probe-zombie.md" <<'PEOF'
| 日期 | skill | 节 | 约束摘要 | 每单成本 | 挡什么失败模式 | 载体路径 | 状态 |
|---|---|---|---|---|---|---|---|
| 2026-08-05 | a | 精髓 | 乙 | 低 | Y | p2 | RETIRED |
| 2026-08-06 | a | 精髓 | 乙(处置记录，原 review-by 2025-01-01) | 低 | Y | p2 | RETIRED |
PEOF
n=$(awk -v t="$(date +%F)" '/[Pp][Rr][Oo][Vv][Ii][Ss][Ii][Oo][Nn][Aa][Ll][:：]?/ {
  if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|?[[:space:]]*$/)) {
    d = substr($0, RSTART+23, 10); if (d < t) print $0 } else print $0 }' "$S/probe-zombie.md" | wc -l | tr -d ' ')
[ "$n" -eq 0 ] || echo "AC4b FAIL 僵旗未消除或处置行被误报：$n（期望 0）"
echo "AC4b 完毕"

echo "========== AC5 正向对照：真超期必须仍被抓，基线纯净 =========="
SCAN='/[Pp][Rr][Oo][Vv][Ii][Ss][Ii][Oo][Nn][Aa][Ll][:：]?/ { if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|?[[:space:]]*$/)) { d = substr($0, RSTART+23, 10); if (d < t) print $0 } }'
base=$(awk -v t="$(date +%F)" "$SCAN" "$S/probe-zombie.md" | wc -l | tr -d ' ')
[ "$base" -eq 0 ] || echo "AC5 FAIL 基线不纯净：$base（期望 0）"
cp "$S/probe-zombie.md" "$S/probe-positive.md"
printf '| 2026-08-07 | a | L2 AC 自验 | 戊 | 低 | V | p5 | PROVISIONAL: review-by 2024-06-01 |\n' >> "$S/probe-positive.md"
n=$(awk -v t="$(date +%F)" "$SCAN" "$S/probe-positive.md" | wc -l | tr -d ' ')
[ "$n" -eq 1 ] || echo "AC5 FAIL 真超期未被抓或多报：$n（期望 1）"
echo "AC5 完毕"

echo "========== AC6 台账：0 数据行 + 前言同步 =========="
L=.tad/evidence/audits/lite-constraint-ledger.md
n=$(grep -cE '^\|[^-]' "$L"); [ "$n" -eq 1 ] || echo "AC6 FAIL 表格数据行=$((n-1))，应为 0"
grep -Fq '状态列可就地转移为终态' "$L" || echo "AC6 FAIL 前言未同步"
grep -Fq '删除约束也追加 RETIRED 行' "$L" && echo "AC6 FAIL 旧前言残留"
echo "AC6 完毕"

echo "========== AC7 tracked 围栏 =========="
ALLOW=$(cat "$S/allow.txt")
git diff --name-only "$BASE" | LC_ALL=C sort > "$S/tracked-after.txt"
comm -13 "$S/tracked-before.txt" "$S/tracked-after.txt" | grep -vE "$ALLOW"
echo "AC7 完毕（新增 tracked 经授权集过滤后：$(comm -13 "$S/tracked-before.txt" "$S/tracked-after.txt" | grep -cvE "$ALLOW" || true) 条命中）"

echo "========== AC8 untracked 围栏 =========="
git -c core.quotePath=false status --porcelain --untracked-files=all \
  | grep '^??' | cut -c4- | LC_ALL=C sort > "$S/untracked-after.txt"
comm -13 "$S/untracked-before.txt" "$S/untracked-after.txt" | grep -vE "$ALLOW"
echo "AC8 完毕（新增 untracked 经授权集过滤后：$(comm -13 "$S/untracked-before.txt" "$S/untracked-after.txt" | grep -cvE "$ALLOW" || true) 条命中）"

echo "========== AC9 .agents/ 镜像 =========="
for f in alex-lite blake-lite; do
  grep -Fq 'MALFORMED(须人工处置)' .agents/skills/$f/SKILL.md || echo "AC9 FAIL AGENTS-MISSING $f"
  cmp -s .claude/skills/$f/SKILL.md .agents/skills/$f/SKILL.md || echo "AC9 FAIL DIFF $f"
done
bash .tad/hooks/lib/release-verify.sh parity .
echo "AC9 完毕"

echo "========== post-impl 全部 AC 执行完毕 =========="
