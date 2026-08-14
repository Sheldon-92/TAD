#!/usr/bin/env bash
# P7 measure.sh（rev3）—— 激活即付实测。常驻集**现算**，禁止硬编码（AC7）。
#
# rev2 缺陷（Gate 2 第三轮实测）：
#  (1) 模块集只从 SKILL 正文 `Load required modules` 那行现算 → 措辞改两个词就取到 0 个模块，
#      凭空省出 76,699 B 而 AC 全绿；
#  (2) `CMD_OUTPUT` 写死 6892 B（P3 时的实测值），改了扫描命令也不会变；
#  (3) `session-state.md` 进了分母 —— 它在会话中会变，测量不可复现。
# rev3 修法：
#  (1) 正文集与 binding 集**分别**现算、**分别**与 T0 比对（不取并集：binding ⊇ 正文，
#      取并集会让"改正文里的模块名"这类攻击完全隐形）；正文集为空或少于 T0 项数 → RESULT=FAIL；
#  (2) `CMD_OUTPUT` 从 SKILL 里现抽启动扫描命令、**实跑取 `wc -c`**；抽到 0 条 → FAIL；
#  (3) `session-state.md` 移出分母。
set -uo pipefail
DONE=0; trap '[ "$DONE" = 1 ] || { echo "RESULT=FAIL (measure.sh 中途退出)"; exit 1; }' EXIT
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/lazy-by-floor"
A1="$R/.claude/skills/alex/SKILL.md"
STAGE="${1:-X}"; OUT="$EV/measure-${STAGE}.txt"; : > "$OUT"; TOT=0; ERR=0
fail(){ echo "  !! $*"; ERR=$((ERR+1)); }
add(){ local f="$1" n=0; [ -f "$R/$f" ] && n=$(LC_ALL=C wc -c < "$R/$f" | LC_ALL=C tr -d ' ')
       printf '%s\t%s\n' "$f" "$n" >> "$OUT"; TOT=$((TOT+n)); }

# 1) 常驻骨架（⚠️ 不含 session-state.md：会话中会变，进分母则测量不可复现）
add "CLAUDE.md"; add "AGENTS.md"; add ".claude/skills/alex/SKILL.md"; add ".tad/config.yaml"

# 2) 模块集：正文集（Alex 实际会读的）与 binding 集，分别现算
LC_ALL=C command grep -m1 'Load required modules' "$A1" \
  | LC_ALL=C tr ',' '\n' | LC_ALL=C command grep -oE 'config-[a-z]+' | LC_ALL=C sort -u > "$EV/.mods-prose"
LC_ALL=C awk '/^command_module_binding:/{b=1} b && /^  tad-alex:/{a=1} a && /modules:/{print; exit}' "$R/.tad/config.yaml" \
  | LC_ALL=C tr ',' '\n' | LC_ALL=C command grep -oE 'config-[a-z]+' | LC_ALL=C sort -u > "$EV/.mods-bind"
NP=$(command grep -c . "$EV/.mods-prose" || true); NB=$(command grep -c . "$EV/.mods-bind" || true)
[ "${NP:-0}" -ge 1 ] || fail "正文模块集取到 0 项 —— 抽取失效或模块被摘光（rev2 的假绿路径）"
if [ -f "$EV/module-set-base.txt" ]; then
  BP=$(LC_ALL=C awk -F'\t' '$1=="prose"' "$EV/module-set-base.txt" | command grep -c . || true)
  BB=$(LC_ALL=C awk -F'\t' '$1=="binding"' "$EV/module-set-base.txt" | command grep -c . || true)
  [ "${NP:-0}" -ge "${BP:-0}" ] || fail "正文模块集 ${NP} < T0 的 ${BP}（AC2：只增不减）"
  [ "${NB:-0}" -ge "${BB:-0}" ] || fail "binding 模块集 ${NB} < T0 的 ${BB}（AC2：只增不减）"
  LC_ALL=C awk -F'\t' '$1=="prose"{print $2}' "$EV/module-set-base.txt" | LC_ALL=C sort -u > "$EV/.bp"
  MISS=$(LC_ALL=C comm -23 "$EV/.bp" "$EV/.mods-prose" | LC_ALL=C tr '\n' ' ')
  [ -z "$MISS" ] || fail "正文模块集缺失：${MISS}"
  rm -f "$EV/.bp"
fi
while IFS= read -r m; do [ -n "$m" ] && add ".tad/${m}.yaml"; done < "$EV/.mods-prose"
# binding 有而正文没有的模块 = 纪律已暗（另开单，不计入本单分母，但每次都报出来）
DARK=$(LC_ALL=C comm -13 "$EV/.mods-prose" "$EV/.mods-bind" | LC_ALL=C tr '\n' ' ')
[ -z "$DARK" ] || printf '# WARN 已暗模块(binding 有、STEP 3 不读)\t%s\n' "$DARK" >> "$OUT"

# 3) CLAUDE.md 的 @import 现值（只算真实存在的）
LC_ALL=C command grep -E '^@\.' "$R/CLAUDE.md" | LC_ALL=C sed 's/^@//' > "$EV/.imp"
while IFS= read -r f; do [ -n "$f" ] && [ -f "$R/$f" ] && add "$f"; done < "$EV/.imp"

# 4) 工具速查（STEP 3.3，blocking:false 但当前仍读）
add ".tad/guides/tool-quick-reference-alex.md"

# 5) 启动扫描命令的输出：从 SKILL 现抽 + 实跑 wc -c（不写死）
LC_ALL=C command grep -h '禁止整读' "$A1" | LC_ALL=C sed -n 's/.*：`\(.*\)`.*/\1/p' > "$EV/.scan"
NC=$(command grep -c . "$EV/.scan" || true)
[ "${NC:-0}" -ge 1 ] || fail "启动扫描命令抽到 0 条 —— 抽取失效"
CO=0
while IFS= read -r c; do
  [ -n "$c" ] || continue
  n=$(cd "$R" && bash -c "$c" 2>&1 | LC_ALL=C wc -c | LC_ALL=C tr -d ' ')
  CO=$((CO+n))
done < "$EV/.scan"
printf 'CMD_OUTPUT(%s cmds, 实跑)\t%s\n' "$NC" "$CO" >> "$OUT"; TOT=$((TOT+CO))

printf 'TOTAL\t%s\n' "$TOT" >> "$OUT"
rm -f "$EV/.mods-prose" "$EV/.mods-bind" "$EV/.imp" "$EV/.scan"
echo "measure[$STAGE]: ${TOT} B ≈ $((TOT/4000))K tokens → $OUT"
DONE=1; trap - EXIT
[ "$ERR" -eq 0 ] || { echo "RESULT=FAIL (${ERR} 项校验失败)"; exit 1; }
echo "RESULT=PASS"
