#!/usr/bin/env bash
# P7 measure.sh（rev5）—— 激活即付实测。常驻集**现算**，禁止硬编码（AC7）。
#
# 历轮缺陷与修法：
#  R3 (1) 模块集只从 SKILL 正文那行现算 → 改两个词取到 0 个模块，凭空省 76,699 B 而 AC 全绿
#      (2) `CMD_OUTPUT` 写死 6,892 B  (3) `session-state.md` 进分母 → 测量不可复现
#  R4 P0-1 分母是**固定文件清单** → 新建一个文件放 29 条祈使句：AC1 绿、AC7 **奖励**（0 B 成本），
#          义务全部落进 agent 读不到的地方 → 本单承重归零。**分母与常驻层必须是同一个集合。**
#     P0-2 `grep -m1 'Load required modules'` 可被任意更早的一行含该子串的注释劫持。
#     P1-7 从 Blake 可写的文件里抽字符串直接 `bash -c` = 被验证方控制验证器执行的代码。
#     P2-4 `CMD_OUTPUT` 随工作树状态漂移，"严格下降"混进无关噪声。
# rev5 修法：分母 = `resident.sh` 的输出（常驻层的唯一定义，AC1/AC7/AC8 共用）；
#            模块行锚定唯一编号行（在 resident.sh 内，命中≠1 直接 error）；
#            扫描命令**前缀白名单**后才执行；同时输出 TOTAL 与 TOTAL_STATIC，
#            AC7 的"严格下降"判在 **TOTAL_STATIC**（不含随树漂移的 CMD_OUTPUT）。
set -uo pipefail
DONE=0; trap '[ "$DONE" = 1 ] || { echo "RESULT=FAIL (measure.sh 中途退出)"; exit 1; }' EXIT
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/lazy-by-floor"
HB="$R/.tad/archive/handoffs/HANDOFF-20260818-lazy-by-floor"
A1="$R/.claude/skills/alex/SKILL.md"
STAGE="${1:-X}"; OUT="$EV/measure-${STAGE}.txt"; : > "$OUT"; TOT=0; ERR=0
fail(){ echo "  !! $*"; ERR=$((ERR+1)); }

# 1) 分母 = 常驻层闭集（唯一定义在 resident.sh；AC1/AC8 读同一个集合）
RS=$(bash "$HB.resident.sh") || { echo "RESULT=FAIL (resident.sh 报错，见上)"; exit 1; }
NRS=$(printf '%s\n' "$RS" | command grep -c . || true)
[ "${NRS:-0}" -ge 5 ] || fail "常驻层只解析出 ${NRS} 个文件，疑似抽取失效"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  n=$(LC_ALL=C wc -c < "$R/$f" | LC_ALL=C tr -d ' ')
  printf '%s\t%s\n' "$f" "$n" >> "$OUT"; TOT=$((TOT+n))
done <<< "$RS"

# 2) 与 T0 常驻层比对：**双向**。
#    新增 → 违反 §7.0（不得新增常驻层成员）；
#    减少 → 违反 AC2（模块集只增不减）——⚠️ 这一条**必须查**：
#    实测负控，把 STEP 3 那行从 4 个模块砍到 1 个，STATIC 256,313 → 207,988（−48,325 B），
#    若只查新增则 `RESULT=PASS`，正是第三轮那条"4 条纪律变暗、AC 全绿"的攻击原样复活。
if [ -f "$EV/resident-set-base.txt" ]; then
  printf '%s\n' "$RS" | LC_ALL=C sort -u > "$EV/.rs"
  ADD=$(LC_ALL=C comm -13 "$EV/resident-set-base.txt" "$EV/.rs" | LC_ALL=C tr '\n' ' ')
  LOST=$(LC_ALL=C comm -23 "$EV/resident-set-base.txt" "$EV/.rs" | LC_ALL=C tr '\n' ' ')
  [ -z "$ADD" ] || fail "常驻层新增成员：${ADD} —— §7.0 不允许，须退回 Alex 改契约"
  [ -z "$LOST" ] || fail "常驻层丢失成员：${LOST} —— AC2 只增不减；每条被弃载的纪律须逐条落盘可达性记录"
  rm -f "$EV/.rs"
fi

# 3) binding 集：AC2 要求**两个**集合各自 comm —— 早期版本只比计数，
#    改一个字母（config-cogniti**v**）计数不变即 PASS，正是 principles.md 2026-06-01
#    「全局计数底线抓不到 must-cover 丢失」的同一类失败。
LC_ALL=C awk '/^command_module_binding:/{b=1} b && /^  tad-alex:/{a=1} a && /modules:/{print; exit}' "$R/.tad/config.yaml" \
  | LC_ALL=C tr ',' '\n' | LC_ALL=C command grep -oE 'config-[a-z]+' | LC_ALL=C sort -u > "$EV/.bind"
if [ -f "$EV/binding-set-base.txt" ]; then
  BLOST=$(LC_ALL=C comm -23 "$EV/binding-set-base.txt" "$EV/.bind" | LC_ALL=C tr '\n' ' ')
  [ -z "$BLOST" ] || fail "binding 模块集丢失成员：${BLOST} —— AC2 只增不减"
fi
printf '%s\n' "$RS" | LC_ALL=C command grep -oE 'config-[a-z]+' | LC_ALL=C sort -u > "$EV/.pros"
DARK=$(LC_ALL=C comm -13 "$EV/.pros" "$EV/.bind" | LC_ALL=C tr '\n' ' ')
[ -z "$DARK" ] || printf '# WARN 已暗模块(binding 有、STEP 3 不读)\t%s\n' "$DARK" >> "$OUT"
rm -f "$EV/.bind" "$EV/.pros"

TOT_STATIC=$TOT
printf 'TOTAL_STATIC\t%s\n' "$TOT_STATIC" >> "$OUT"

# 4) 启动扫描命令的输出：现抽 + **只跑 T0 冻结集里的原命令** + 实跑取 wc -c（不写死）
#    ⚠️ P1-7：`alex/SKILL.md` 是 Blake 可写文件，未加约束地 `bash -c` = 把验证器交给被验证方。
#    ⚠️ 这里**不做前缀/关键词白名单**：shell 语法是无界集合，deny/allow 关键词都会误判
#       （实测：P3 那条合法命令里有个叫 `cp` 的变量，就被关键词过滤当成拷贝命令毙掉，
#        CMD_OUTPUT 从 5,859 静默变成 3,096 —— 守卫误伤反而制造了假数字）。
#    正确判据是**有界集合**：命令集必须与 T0 冻结的逐字相同，多一条少一条改一字都 FAIL。
LC_ALL=C command grep -h '禁止整读' "$A1" | LC_ALL=C sed -n 's/.*：`\(.*\)`.*/\1/p' > "$EV/.scan"
NC=$(command grep -c . "$EV/.scan" || true)
[ "${NC:-0}" -ge 1 ] || fail "启动扫描命令抽到 0 条 —— 抽取失效"
if [ -f "$EV/scan-cmds-base.txt" ]; then
  if ! LC_ALL=C diff -q "$EV/scan-cmds-base.txt" "$EV/.scan" >/dev/null 2>&1; then
    fail "启动扫描命令集与 T0 不一致（本单不改扫描命令；要改须退回 Alex）"
    LC_ALL=C diff "$EV/scan-cmds-base.txt" "$EV/.scan" | LC_ALL=C head -6
  fi
fi
CO=0; RUN=0
while IFS= read -r c; do
  [ -n "$c" ] || continue
  # 只执行 T0 冻结集里逐字存在的命令；新增/被改的命令一律不跑（上面已计 FAIL）
  if [ -f "$EV/scan-cmds-base.txt" ] && ! LC_ALL=C command grep -qxF -e "$c" "$EV/scan-cmds-base.txt"; then
    fail "拒绝执行不在 T0 冻结集里的扫描命令：$(printf '%s' "$c" | LC_ALL=C cut -c1-50)…"; continue
  fi
  # ⚠️ `< /dev/null`：`bash -c` 会继承本循环的 stdin，任何读 stdin 的扫描命令
  #    （哪怕只是一个裸 `cat`）会把剩下的命令全部吃掉，而标签仍写着"5 cmds 实跑"
  #    —— 审查员实测：−4,447 B 且 RESULT=PASS，人读证据时看到的是 5 条全跑了。
  n=$(cd "$R" && bash -c "$c" </dev/null 2>&1 | LC_ALL=C wc -c | LC_ALL=C tr -d ' ')
  CO=$((CO+n)); RUN=$((RUN+1))
done < "$EV/.scan"
[ "${RUN:-0}" -eq "${NC:-0}" ] || fail "扫描命令实跑 ${RUN} 条 ≠ 抽到 ${NC} 条"
if [ -f "$EV/scan-cmds-base.txt" ]; then
  NB=$(command grep -c . "$EV/scan-cmds-base.txt" || true)
  [ "${RUN:-0}" -eq "${NB:-0}" ] || fail "扫描命令实跑 ${RUN} 条 ≠ T0 冻结的 ${NB} 条"
fi
printf 'CMD_OUTPUT(%s/%s cmds 实跑, 随树漂移不计入 STATIC)\t%s\n' "$RUN" "$NC" "$CO" >> "$OUT"
TOT=$((TOT+CO))
printf 'TOTAL\t%s\n' "$TOT" >> "$OUT"
rm -f "$EV/.scan"
echo "measure[$STAGE]: STATIC ${TOT_STATIC} B ≈ $((TOT_STATIC/4000))K tokens | TOTAL ${TOT} B → $OUT"
DONE=1; trap - EXIT
[ "$ERR" -eq 0 ] || { echo "RESULT=FAIL (${ERR} 项校验失败)"; exit 1; }
echo "RESULT=PASS"
