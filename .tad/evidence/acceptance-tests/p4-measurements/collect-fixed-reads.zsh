#!/bin/zsh
# P4 A 段：固定读取量 13 行测量 + 双合计（zsh 5.9 直跑，macOS/BSD wc）
# 第 1 行参数：alex|blake —— 决定第 1 项取哪个 skill 文件
# 用法：zsh collect-fixed-reads.zsh alex | zsh collect-fixed-reads.zsh blake
# $HOME 写法：`~` 在引号中不展开，第 3 项必须用 "$HOME/.claude/CLAUDE.md"
# wc -c 与 -m 互斥且不报错，必须分两次调用
side=${1:-alex}
skill=.claude/skills/alex-lite/SKILL.md
[ "$side" = blake ] && skill=.claude/skills/blake-lite/SKILL.md
paths=(
  "$skill"
  "CLAUDE.md"
  "$HOME/.claude/CLAUDE.md"
  ".tad/project-knowledge/principles.md"
  ".tad/project-knowledge/patterns/_index.md"
  ".tad/project-knowledge/testing.md"
  ".tad/project-knowledge/ux.md"
  ".tad/project-knowledge/performance.md"
  ".tad/project-knowledge/api-integration.md"
  ".tad/project-knowledge/mobile-platform.md"
  ".tad/project-knowledge/frontend-design.md"
  ".tad/brain-index.md"
  ".tad/memory/MEMORY.md"
)
# 逐行测量（缺失记 0）
out=""
for p in $paths; do
  if test -f "$p"; then
    b=$(wc -c < "$p"); c=$(wc -m < "$p")
    printf '%s|%s|%s\n' "$p" "$b" "$c"
  else
    printf 'MISSING|%s|0|0\n' "$p"
  fi
done | tee /tmp/p4-fixed-reads-$side.txt
echo "--- 双合计 ---"
# 合计-项目内：排除第 3 项（用户全局 CLAUDE.md）
awk -F'|' '$1 !~ /\.claude\/CLAUDE\.md$|MISSING/ {b+=$2; c+=$3} END {printf "合计-项目内|%s|%s\n", b, c}' /tmp/p4-fixed-reads-$side.txt
awk -F'|' '$1 ~ /MISSING/ {next} {b+=$2; c+=$3} END {printf "合计-实际注入|%s|%s\n", b, c}' /tmp/p4-fixed-reads-$side.txt
