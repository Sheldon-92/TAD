#!/bin/bash
# 实现前判别力自检 — TASK-20260805-P1a-fix（期望：AC1 20 FAIL / AC6 2 FAIL / AC9 2 FAIL；
# AC2/AC3/AC7/AC8 设计上 PASS——AC2 为否定断言无判别力（§5 注释）；AC4a/b/AC5 内联规格命令，
# 判别力由 AC1 钉死落地文本 + AC4a 旧命令对照提供）
S=.tad/evidence/acceptance-tests/pricing-gate-scan-fix
BASE=4b29dc263a5368c0b598fc1030f465fc7ebdbc10

echo "========== AC1 实现前（期望每文件 10 条 FAIL，共 20）=========="
for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md; do
  grep -Fxq '  awk -v t="$(date +%F)" '"'"'/[Pp][Rr][Oo][Vv][Ii][Ss][Ii][Oo][Nn][Aa][Ll][:：]?/ {' "$f" || echo "AC1 FAIL 命令第1行(前置过滤) [$f]"
  grep -Fxq '    if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|?[[:space:]]*$/)) {' "$f" || echo "AC1 FAIL 命令第2行 [$f]"
  grep -Fxq '      d = substr($0, RSTART+23, 10); if (d < t) print "OVERDUE: " $0 }' "$f" || echo "AC1 FAIL 命令第3行 [$f]"
  grep -Fxq '    else print "MALFORMED(须人工处置): " $0 }'"'"' \' "$f" || echo "AC1 FAIL 逃逸检测行 [$f]"
  grep -Fxq '    .tad/evidence/audits/lite-constraint-ledger.md' "$f" || echo "AC1 FAIL 台账路径行 [$f]"
  grep -Fq '仅限转为终态（HAS-CARRIER / NO-CARRIER / SUPERSEDED / RETIRED）' "$f" || echo "AC1 FAIL 终态枚举缺失 [$f]"
  grep -Fq '禁止静默续期' "$f" || echo "AC1 FAIL 静默续期禁令 [$f]"
  grep -Fq '状态列恒为末列' "$f" || echo "AC1 FAIL 列序不变量 [$f]"
  grep -Fq '不要重复 PROVISIONAL 字样' "$f" || echo "AC1 FAIL 处置行踩雷提示缺失 [$f]"
  grep -Fq 'RSTART+10' "$f" && echo "AC1 FAIL 旧偏移残留 [$f]"
  grep -Fq '写进备注列' "$f" && echo "AC1 FAIL 旧备注列措辞残留 [$f]"
done
echo "AC1 实现前检查完毕"

echo "========== AC4a 判别力留证：BASE 版旧命令对探针的命中集 =========="
cat > "$S/probe-cmd.md" <<'PEOF'
| 日期 | skill | 节 | 约束摘要 | 每单成本 | 挡什么失败模式 | 载体路径 | 状态 |
|---|---|---|---|---|---|---|---|
| A1 | a | 身份 | 甲 | 低 | X | p1 | PROVISIONAL: review-by 2024-01-01
| A2 | a | 精髓 | 乙 | 低 | Y | p2 | PROVISIONAL: review-by 2024-02-02 |
| A3 | a | Forbidden | 丙 | 低 | Z | p3 | PROVISIONAL: review-by 2027-01-01 |
| A4 | a | L1 实现 | 丁 | 低 | W | p4 | RETIRED |
| A5 | a | L2 AC 自验 | 戊(原 review-by 2020-01-01) | 低 | V | p5 | HAS-CARRIER |
| A6 | a | L3 独立审查 | 己 | 低 | U | p6 | PROVISIONAL: review-by 2024-03-03 | 备注 |
| A8 | a | Forbidden | 辛 | 低 | S | p8 | PROVISIONAL: review-by 2026-7-1 |
| B1 | a | 身份 | 甲 | 低 | X | p1 | PROVISIONAL： review-by 2024-01-01 |
| B2 | a | 身份 | 甲 | 低 | X | p1 | PROVISIONAL review-by 2024-01-01 |
| B3 | a | 身份 | 甲 | 低 | X | p1 | Provisional: review-by 2024-01-01 |
| B9 | a | L3 独立审查 | 己 | 低 | U | p6 | N/A: 无约束条目 |
PEOF
printf '| A7 | a | L1 实现 | 庚 | 低 | T | p7 | PROVISIONAL: review-by 2024-04-04 |\t\n' >> "$S/probe-cmd.md"
echo "--- 旧命令输出（BASE 版，须与新命令命中集不同）---"
awk -v t="$(date +%F)" '/review-by/ {
  if (match($0, /review-by [0-9-]+/)) {
    d = substr($0, RSTART+10, 10); if (d < t) print "OVERDUE: " $0 } }' \
  "$S/probe-cmd.md" | sed 's/|.*//' | sort > "$S/old-cmd-ac4a.txt"
cat "$S/old-cmd-ac4a.txt"
echo "旧命令命中行数: $(wc -l < "$S/old-cmd-ac4a.txt" | tr -d ' ')"
echo "--- 新命令（规格字面量）对照 ---"
out=$(awk -v t="$(date +%F)" '/[Pp][Rr][Oo][Vv][Ii][Ss][Ii][Oo][Nn][Aa][Ll][:：]?/ {
  if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|?[[:space:]]*$/)) {
    d = substr($0, RSTART+23, 10); if (d < t) print "OVERDUE=" $2 }
  else print "MALFORMED=" $2 }' "$S/probe-cmd.md")
echo "$out"
[ "$(echo "$out" | grep -c OVERDUE)" -gt 0 ] && echo "新命令命中数: $(echo "$out" | wc -l | tr -d ' ')"
echo "（新旧命中集不同即判别力成立；实现前两者都跑通属正常——命令是规格字面量）"

echo "========== AC6 实现前（期望 2 FAIL：前言未同步）=========="
L=.tad/evidence/audits/lite-constraint-ledger.md
n=$(grep -cE '^\|[^-]' "$L"); [ "$n" -eq 1 ] || echo "AC6 FAIL 表格数据行=$((n-1))，应为 0"
grep -Fq '状态列可就地转移为终态' "$L" || echo "AC6 FAIL 前言未同步"
grep -Fq '删除约束也追加 RETIRED 行' "$L" && echo "AC6 FAIL 旧前言残留"

echo "========== AC9 实现前（期望 2 FAIL：AGENTS-MISSING）=========="
for f in alex-lite blake-lite; do
  grep -Fq 'MALFORMED(须人工处置)' .agents/skills/$f/SKILL.md || echo "AC9 FAIL AGENTS-MISSING $f"
  cmp -s .claude/skills/$f/SKILL.md .agents/skills/$f/SKILL.md || echo "AC9 FAIL DIFF $f"
done

echo "========== 实现前自检完毕 =========="
