set -uo pipefail
R="/path/to/TAD"
EV="$R/.tad/evidence/acceptance-tests/review-scaling"
T0=47918da
B1="$R/.claude/skills/blake-lite/SKILL.md"; B2="$R/.agents/skills/blake-lite/SKILL.md"
P1=".claude/skills/blake-lite/SKILL.md";    P2=".agents/skills/blake-lite/SKILL.md"
FAIL=0; fail(){ echo "GATE FAIL: $*"; FAIL=1; }
# ⚠️ rev3 自查 P0-E：脚本在 AC15 处因 set -u 崩溃，末行没有 RESULT= —— 而 §8 把「红」定义为
# 「exit ≠ 0 **且** 末行 RESULT=FAIL」，崩溃两条只满足一条 → 既不算红也不算绿 = 未定义状态。
# 该 trap 保证**任何**中止路径都留下 RESULT= 末行。DONE 在最后一行前置 1。
trap 'rc=$?; [ "${DONE:-0}" = "1" ] || { echo "RESULT=FAIL (脚本异常中止 rc=$rc)"; exit 1; }' EXIT
git -C "$R" rev-parse --verify --quiet "$T0^{commit}" >/dev/null || { echo "RESULT=FAIL (T0 无效)"; exit 1; }

R1='spawn 1 个 code-reviewer subagent（Agent tool），prompt：'
R2='P0 修复若改动了 reviewer 未见过的文件 → 追加同 reviewer 增量复核（只给 fix 部分，'
R2B='成本 ≈1/5 首轮）。'
R3='mandate 内 reviewer/gate 缺陷由 Blake 有界修复、重跑受影响 AC 并增量复核，无逐 repair 请示。'
R4='修复后重跑受影响 AC 与 reviewer，再回本 Gate。'
R4N='修复后按「修复门禁」单轮验完，再回本 Gate；不得追加复核轮次。'
HH="$R/.tad/active/handoffs/HANDOFF-20260813-review-scaling.md"

# AC1 旧文消失（⚠️ 显式列出两个文件，不用 for f in $VAR —— zsh 下只迭代 1 次）
for f in "$B1" "$B2"; do
  for s in "$R1" "$R2" "$R2B" "$R3" "$R4"; do
    [ "$(command grep -cFx -e "$s" "$f" || true)" -eq 0 ] || fail "AC1 旧文仍在: $f :: $s"
  done
  [ "$(command grep -cFx -e "$R4N" "$f" || true)" -eq 1 ] || fail "AC1 R4 新行缺失/重复: $f"
done

# AC2 哨兵成对
for f in "$B1" "$B2"; do
  for m in REVIEWER-FANOUT REPAIR-GATE; do
    b=$(command grep -cxF -e "<!-- $m-BEGIN -->" "$f" || true)
    e=$(command grep -cxF -e "<!-- $m-END -->"   "$f" || true)
    [ "$b" -eq 1 ] && [ "$e" -eq 1 ] || fail "AC2 哨兵 $m 不成对/重复: $f (b=$b e=$e)"
  done
done

# AC3/AC4 条款在文 + T=0 计数须为 0（防永真）
check_new(){ # $1=活文件 $2=T0路径 $3=串
  b=$(git -C "$R" show "$T0:$2" | command grep -cF -e "$3" || true)
  [ "$b" -eq 0 ] || fail "判据永真（T=0 已命中 $b 次）: $3"
  [ "$(command grep -cF -e "$3" "$1" || true)" -ge 1 ] || fail "缺条款: $3"
}
# ⚠️ 本表每一串都必须真出现在 §7.2/§7.4 哨兵块里（AC14 锁块内容逐字等于契约）。
# rev3 自查 P0-A：此表曾遗留 5 个 rev2 串（'审查扇出（机器判定，不问人）'/'扇出判定: F1='/
# 'F1 的路径表非穷举'/'收窄 F1 的单必然自命中 F1'/'加派上限 2 个'），rev3 块内一个都没有
# → AC3 与 AC14 互斥，契约在任何实现下都不可能通过。已按块实际内容重列并实测全命中。
for s in '审查扇出（按档位，机器按自报值执行）' '只审这一个维度，其他维度有别人负责' \
         '档位判定: 新建判断=' '兜底判定:' '问题原文:' \
         '哪条 AC 是永真的' '这次授权会不会让下次不再需要人' '静默失败的路径在哪' \
         '修复之间不互斥' '没有把响亮失败换成静默成功' '数字断言有来源' \
         '5 条全过即结束，不得追加轮次' '修复门禁: 执行者=' '不由 Blake 自查' \
         '新建判断: {n}' '产物是否成为判据: {是|否}' '失败是否可见: {是|否}' \
         '加派上限 2' '非穷举，存疑按命中' '报 P0 tier-underreport' \
         'code-reviewer#base' 'security-auditor#invisible' \
         '修复文本在位' '新命令能跑' '自报值必须被底座 reviewer 核'; do
  check_new "$B1" "$P1" "$s"
done

# AC5 冻结补集（含纯增行）
for pair in "$B1|$P1" "$B2|$P2"; do
  live="${pair%%|*}"; pth="${pair##*|}"   # ⚠️ 禁用 path/argv/cdpath/manpath/status —— zsh 下是特殊变量
  base=$(git -C "$R" show "$T0:$pth" | command grep -vxF -e "$R1" -e "$R2" -e "$R2B" -e "$R3" -e "$R4")
  now=$(sed -e '/^<!-- REVIEWER-FANOUT-BEGIN -->$/,/^<!-- REVIEWER-FANOUT-END -->$/d' \
            -e '/^<!-- REPAIR-GATE-BEGIN -->$/,/^<!-- REPAIR-GATE-END -->$/d' "$live" \
       | command grep -vxF -e "$R4N")
  [ "$base" = "$now" ] || fail "AC5 $pth 在钉死行与哨兵块之外发生改动（含纯增行）"
done

# AC6 删除预算恰好 10
read -r ADDED DELETED <<<"$(git -C "$R" diff --numstat "$T0" -- "$P1" "$P2" \
  | LC_ALL=C awk '{a+=$1;d+=$2} END{print a+0,d+0}')"
echo "added=$ADDED deleted=$DELETED"
[ "$DELETED" -eq 10 ] || fail "AC6 删除行数 $DELETED != 10"
WANT=$(( $(sed -n '/^<!-- REVIEWER-FANOUT-BEGIN -->$/,/^<!-- REVIEWER-FANOUT-END -->$/p' "$HH" | wc -l) \
       + $(sed -n '/^<!-- REPAIR-GATE-BEGIN -->$/,/^<!-- REPAIR-GATE-END -->$/p' "$HH" | wc -l) + 1 ))
[ "$ADDED" -eq $(( WANT * 2 )) ] || fail "AC6 新增行数 $ADDED != $(( WANT * 2 ))（块外或块内有夹带）"

# AC7 扇出判别力（4 fixture，ROSTER 首行逐字比对 —— ⚠️ 显式成对列出，不用 for..in $VAR）
# rev3 自查 P0-B：此处曾是 rev2 的 6 份 f1-f6，且用了 §8 AC7 明文禁止的 grep -qF '只有底座'
#（把那四个字打进文件就能过）。已改为逐字 ROSTER 断言。
[ -d "$EV/fixtures" ] || fail "AC7 缺 fixtures 目录"
E_t0='ROSTER=code-reviewer#base'
E_tj='ROSTER=code-reviewer#base,code-reviewer#judgment'
E_tc='ROSTER=code-reviewer#base,code-reviewer#criterion'
E_th='ROSTER=code-reviewer#base,code-reviewer#criterion,security-auditor#invisible'
chk7(){ # $1=fixture 名 $2=期望 ROSTER 行
  f="$EV/fanout-$1.out"
  [ -s "$f" ] || { fail "AC7 缺 $1 判定输出"; return; }
  got=$(command sed -n '1p' "$f")
  [ "$got" = "$2" ] || fail "AC7 $1 ROSTER 不符：期望[$2] 实际[$got]"
}
chk7 t0-light     "$E_t0"
chk7 t1-judgment  "$E_tj"
chk7 t1-criterion "$E_tc"
chk7 t3-heavy     "$E_th"
# 四份两两不等（防止全部塞同一行也能过）
[ "$(printf '%s\n%s\n%s\n%s\n' "$E_t0" "$E_tj" "$E_tc" "$E_th" | LC_ALL=C sort -u | command grep -c . || true)" -eq 4 ] \
  || fail "AC7 期望值本身不是两两不等（契约缺陷，非实现缺陷）"

# AC8 parity
cmp -s "$B1" "$B2" || fail "parity blake-lite"

# AC9 L3.5 未改
b=$(git -C "$R" show "$T0:$P1" | sed -n '/^## L3.5 /,$p' | sed -n '1p;2,${/^## /q;p;}' | command grep -vxF -e "$R4")
n=$(sed -n '/^## L3.5 /,$p' "$B1" | sed -n '1p;2,${/^## /q;p;}' | command grep -vxF -e "$R4N")
[ "$(printf '%s\n' "$b" | command grep -c . || true)" -ge 5 ] || fail "AC9 基线取不到 L3.5 节"
[ "$b" = "$n" ] || fail "AC9 L3.5 被改动"

# AC10 alex-lite / full 零改动
[ "$(git -C "$R" diff --name-only "$T0" -- \
   .claude/skills/alex-lite .agents/skills/alex-lite \
   .claude/skills/alex .claude/skills/blake .claude/skills/gate \
   .agents/skills/alex .agents/skills/blake .agents/skills/gate | wc -l)" -eq 0 ] || fail "AC10 越界改动"

# AC14 哨兵块内容 == 契约逐字（契约 sha 已由 AC12 锁定）
for m in REVIEWER-FANOUT REPAIR-GATE; do
  want=$(sed -n "/^<!-- $m-BEGIN -->\$/,/^<!-- $m-END -->\$/p" "$HH")
  [ -n "$want" ] || fail "AC14 契约中取不到 $m 块"
  for f in "$B1" "$B2"; do
    got=$(sed -n "/^<!-- $m-BEGIN -->\$/,/^<!-- $m-END -->\$/p" "$f")
    [ "$want" = "$got" ] || fail "AC14 $m 块内容与契约不逐字相同: $f"
  done
done

# AC15 台账恰好新增 2 行
LED='.tad/evidence/audits/lite-constraint-ledger.md'
# ⚠️ awk 必须带 END：无 numstat 行时原写法一个字都不打印 → read 只赋 LA、LD 未定义
# → set -u 直接杀掉脚本（rev3 自查 P0-E 实测），AC11/AC12 从此不再执行。
LA=0; LD=0
read -r LA LD <<<"$(git -C "$R" diff --numstat "$T0" -- "$LED" | LC_ALL=C awk '{a=$1+0;d=$2+0} END{print a+0,d+0}')"
# ⚠️ ${LD} 必须带花括号：`$LD（` 会被吞掉全角括号的首字节 → 变量名变成 LD\xef → set -u 杀脚本
[ "${LA:-0}" -eq 2 ] && [ "${LD:-0}" -eq 0 ] || fail "AC15 台账新增=${LA} 删除=${LD}（应 2/0）"
# 三格齐全：新增的 2 行每行至少 3 个 | 分隔（每单成本 / 挡什么失败模式 / 载体路径）
NEW=$(git -C "$R" diff -U0 "$T0" -- "$LED" | command grep -E '^\+[^+]' || true)
THIN=$(printf '%s\n' "$NEW" | command grep -c . || true)
[ "$THIN" -eq 2 ] || fail "AC15 台账新增内容行=${THIN}（应 2）"
BAD=$(printf '%s\n' "$NEW" | command grep -vE '^\+.*\|.*\|.*\|' | command grep -c . || true)
[ "$BAD" -eq 0 ] || fail "AC15 台账有 ${BAD} 行不足三格"
# Completion 必须记录本次超期扫描结果（AC15 文字承诺过，rev3 脚本漏验）
CMP="$R/.tad/archive/handoffs/COMPLETION-20260813-review-scaling.md"
{ [ -f "$CMP" ] && command grep -qF '超期扫描' "$CMP"; } || fail "AC15 Completion 未记录超期扫描结果"

# AC11 围栏
# ⚠️ ALLOW 必须与 §6.1 的 6 项写权限逐项对应。rev3 自查 P0-C：台账被 §6.1 允许写、
# 被 AC15 强制写，却不在本 ALLOW 内 → 台账是 tracked 且 Step 0 时未改动，
# Blake 追加后必然出现在 comm -13 差集里 → 「围栏残留」必然 FAIL。这是 Gate 2 P1-4 同一个洞在另一处复发。
ALLOW='^\.claude/skills/blake-lite/SKILL\.md$|^\.agents/skills/blake-lite/SKILL\.md$|^\.tad/evidence/acceptance-tests/review-scaling/|^\.tad/archive/handoffs/COMPLETION-20260813-review-scaling\.md$|^\.tad/evidence/journal/lite-discoveries\.md$|^\.tad/evidence/audits/lite-constraint-ledger\.md$'
HOOK='^\.tad/evidence/(traces|decisions)/[0-9]{4}-[0-9]{2}-[0-9]{2}\.jsonl$'
[ -n "$ALLOW" ] && [ -n "$HOOK" ] || fail "ALLOW/HOOK 为空"
[ -s "$EV/fence-baseline.txt" ] || fail "AC11 基线缺失（Step 0 未跑）"
{ git -C "$R" -c core.quotePath=false diff --name-only "$T0" -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-now.txt"
LEFT=$(LC_ALL=C comm -13 "$EV/fence-baseline.txt" "$EV/fence-now.txt" | command grep -vE "$ALLOW" | command grep -vE "$HOOK" || true)
[ -z "$LEFT" ] || { printf '%s\n' "$LEFT"; fail "围栏残留"; }

# AC12 契约未被改
[ -s "$EV/handoff.sha256" ] || fail "AC12 基线 sha 缺失"
( cd "$R" && shasum -a 256 -c "$EV/handoff.sha256" ) >/dev/null 2>&1 || fail "契约被改"

DONE=1   # ⚠️ 必须在最后一行之前置 1，否则 EXIT trap 会把正常结束也判成异常中止
[ "$FAIL" -eq 0 ] && { echo "RESULT=PASS"; exit 0; } || { echo "RESULT=FAIL"; exit 1; }
