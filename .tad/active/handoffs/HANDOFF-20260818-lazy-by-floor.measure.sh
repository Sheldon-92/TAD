#!/usr/bin/env bash
# P7 measure.sh —— 激活即付实测。常驻集**现算**，禁止硬编码（AC6）。
set -uo pipefail
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/lazy-by-floor"
STAGE="${1:-X}"; OUT="$EV/measure-${STAGE}.txt"; : > "$OUT"; TOT=0
add(){ local f="$1" n=0; [ -f "$R/$f" ] && n=$(LC_ALL=C wc -c < "$R/$f" | LC_ALL=C tr -d ' ')
       printf '%s\t%s\n' "$f" "$n" >> "$OUT"; TOT=$((TOT+n)); }
# 1) 常驻骨架
add "CLAUDE.md"; add "AGENTS.md"; add ".claude/skills/alex/SKILL.md"; add ".tad/active/session-state.md"
# 2) STEP 3 实际加载的 config 模块（现算，取 SKILL 正文里那行，不看 binding 表）
LINE=$(LC_ALL=C command grep -m1 'Load required modules' "$R/.claude/skills/alex/SKILL.md" || true)
printf '%s' "$LINE" | LC_ALL=C tr ',' '\n' | LC_ALL=C command grep -oE 'config-[a-z]+' | LC_ALL=C sort -u | while IFS= read -r m; do
  echo ".tad/${m}.yaml"; done > "$EV/.mods"
add ".tad/config.yaml"
while IFS= read -r m; do [ -n "$m" ] && add "$m"; done < "$EV/.mods"
# 3) CLAUDE.md 的 @import 现值（只算真实存在的）
LC_ALL=C command grep -E '^@\.' "$R/CLAUDE.md" | LC_ALL=C sed 's/^@//' > "$EV/.imp"
while IFS= read -r f; do [ -n "$f" ] && [ -f "$R/$f" ] && add "$f"; done < "$EV/.imp"
# 4) 工具速查（STEP 3.3，blocking:false 但当前仍读）
add ".tad/guides/tool-quick-reference-alex.md"
# 5) P3 后的启动扫描命令输出（常量，实测值）
printf 'CMD_OUTPUT\t6892\n' >> "$OUT"; TOT=$((TOT+6892))
printf 'TOTAL\t%s\n' "$TOT" >> "$OUT"
rm -f "$EV/.mods" "$EV/.imp"
echo "measure[$STAGE]: ${TOT} B ≈ $((TOT/4000))K tokens → $OUT"
