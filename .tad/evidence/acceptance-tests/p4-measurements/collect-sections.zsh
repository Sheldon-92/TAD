#!/bin/zsh
# P4 A 段：逐节 bytes/chars 测量（zsh 5.9 直跑，macOS/BSD wc）
# 用法：zsh collect-sections.zsh（或粘贴下方 for 循环于仓库根目录）
# 节 = 行首 `## ` 起的块；文件头到第一个节 = __PREAMBLE__
# wc -c 与 -m 互斥且不报错，必须分两次调用
for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md; do
  echo "===== $f ====="
  total=$(wc -l < "$f")
  # zsh 数组从 1 开始
  starts=($(grep -n '^## ' "$f" | cut -d: -f1))
  n=${#starts}
  # __PREAMBLE__ = 1..starts[1]-1
  end=$((starts[1] - 1))
  b=$(sed -n "1,${end}p" "$f" | wc -c)
  c=$(sed -n "1,${end}p" "$f" | wc -m)
  printf '__PREAMBLE__|%s|%s\n' "$b" "$c"
  # 逐节（标题 = 原文，含 `## ` 前缀；32 个标题均不含 `|` 已核验）
  for ((i=1; i<=n; i++)); do
    s=${starts[$i]}
    title=$(sed -n "${s}p" "$f")
    if [ "$i" -lt "$n" ]; then e=$((starts[$((i+1))] - 1)); else e=$total; fi
    b=$(sed -n "${s},${e}p" "$f" | wc -c)
    c=$(sed -n "${s},${e}p" "$f" | wc -m)
    printf '%s|%s|%s\n' "$title" "$b" "$c"
  done
  echo "---"
done
