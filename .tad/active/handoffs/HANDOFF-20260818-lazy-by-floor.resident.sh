#!/usr/bin/env bash
# P7 resident.sh（rev5 新增）—— **常驻层的唯一定义**。
#
# Gate 2 第四轮 P0-1：契约 8 处写「常驻层」，无一处枚举它是哪些文件 → 解释权在 Blake 手里。
# 且 `measure.sh` 的分母是固定清单 → 新建一个文件放祈使句，AC1 绿、AC7 还**奖励**这么做
# （0 B 成本），29 条义务全部落进 agent 读不到的地方 = 本单承重归零。
#
# 修法：常驻层 = 本脚本输出的闭集。AC1 / AC7 / AC8 三者**都从这里读**，
# 因此「AC1 grep 的文件集 == measure.sh 的分母」是构造性成立的，不靠 Blake 自觉。
# ⚠️ **本单不得新增常驻层成员**：要新增须退回 Alex 改契约（本脚本受 AC12 哈希保护）。
#
# 用法：bash resident.sh          → 每行一个相对路径（仅输出真实存在的）
#       bash resident.sh --declared → 连不存在的也输出（用于差异排查）
set -uo pipefail
R="/Users/sheldonzhao/01-on progress programs/TAD"
A1="$R/.claude/skills/alex/SKILL.md"
MODE="${1:-}"
OUT=""

emit(){ [ "$MODE" = "--declared" ] && { OUT="${OUT}$1"$'\n'; return; }
        [ -f "$R/$1" ] && OUT="${OUT}$1"$'\n'; }

# 1) 骨架（⚠️ 不含 session-state.md：会话中会变，进了则测量不可复现）
emit "CLAUDE.md"
emit "AGENTS.md"
emit ".claude/skills/alex/SKILL.md"
emit ".tad/config.yaml"

# 2) STEP 3 正文实际加载的 config 模块
#    ⚠️ P0-2：不得用 `grep -m1 'Load required modules'`（子串 + 只取第一行）——
#    在文件任意更早处插一行含该子串的注释即可劫持抽取，从而掩盖真正的 STEP 3 被改。
#    这里锚定唯一的编号行，且**命中必须恰好 1 次**，否则整个脚本报错退出。
NL=$(LC_ALL=C command grep -cE '^ +[0-9]+\. Load required modules: ' "$A1" || true)
if [ "${NL:-0}" -ne 1 ]; then
  echo "RESIDENT_SET_ERROR: STEP 3 模块行命中 ${NL} 次（须恰好 1）——疑似诱饵行或结构被改" >&2
  exit 1
fi
LC_ALL=C command grep -E '^ +[0-9]+\. Load required modules: ' "$A1" \
  | LC_ALL=C tr ',' '\n' | LC_ALL=C command grep -oE 'config-[a-z]+' | LC_ALL=C sort -u > /tmp/.p7mods.$$
while IFS= read -r m; do [ -n "$m" ] && emit ".tad/${m}.yaml"; done < /tmp/.p7mods.$$
rm -f /tmp/.p7mods.$$

# 3) CLAUDE.md 的 @import 现值
while IFS= read -r f; do [ -n "$f" ] && emit "$f"; done < <(LC_ALL=C command grep -E '^@\.' "$R/CLAUDE.md" | LC_ALL=C sed 's/^@//')

# 4) 工具速查（STEP 3.3）
emit ".tad/guides/tool-quick-reference-alex.md"

printf '%s' "$OUT"
