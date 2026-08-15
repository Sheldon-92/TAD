set -uo pipefail
R="/path/to/TAD"
EV="$R/.tad/evidence/acceptance-tests/requirement-first"
CP=".tad/active/handoffs/HANDOFF-20260812-requirement-first.md"
T0=d225585
FAIL=0; fail(){ echo "GATE FAIL: $*"; FAIL=1; }
git -C "$R" rev-parse --verify --quiet "$T0^{commit}" >/dev/null || { echo "RESULT=FAIL (T0 无效)"; exit 1; }
mkdir -p "$EV"

OLDC_LINE='`/alex-lite` → `/blake-lite`：**默认通道**。文件数、协议密度、是否触及协议契约均不构成升级理由；'
NEWC_LINE='`/alex-lite` → `/blake-lite`：**默认通道**。页数、文件数、知识量不构成升级理由；但**创建 Epic / 多阶段任务 / 修改框架自身 / 对外发布或同步**四类，**通道由人裁定**，agent 只评估给建议，不得按"lite 是默认"自行继续，**边界存疑一律按命中处理**；'
OLDS='- 页数、文件数、协议密度或知识量不触发 full；需细节用 linked appendix。'
NEWS1='- 页数、文件数或知识量不触发 full；需细节用 linked appendix。'
SKILLS=".claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md .agents/skills/alex-lite/SKILL.md .agents/skills/blake-lite/SKILL.md"

# V1 AC1
[ "$(command grep -cF -e "$OLDC_LINE" "$R/CLAUDE.md" || true)" -eq 0 ] || fail "AC1 CLAUDE.md 旧行仍在"
for f in $SKILLS; do
  [ "$(command grep -cF -e "$OLDS" "$R/$f" || true)" -eq 0 ] || fail "AC1 旧行仍在: $f"
  [ "$(command grep -cFx -e "$NEWS1" "$R/$f" || true)" -eq 1 ] || fail "AC1 新文第1行缺失/重复: $f"
done
for f in CLAUDE.md $SKILLS; do
  [ "$(command grep -cF -e '通道由人裁定' "$R/$f" || true)" -eq 1 ] || fail "AC1 新文缺失或重复: $f"
done

# V2 AC2
for f in CLAUDE.md $SKILLS; do
  [ "$(command grep -cF -e '协议密度' "$R/$f" || true)" -eq 0 ] || fail "AC2 「协议密度」未删净: $f"
  [ "$(command grep -cF -e '文件数'   "$R/$f" || true)" -ge 1 ] || fail "AC2 「文件数」被误删: $f"
done

# V13 AC13 冻结补集
[ "$(git -C "$R" show "$T0:CLAUDE.md" | command grep -cxF -e "$OLDC_LINE" || true)" -eq 1 ] || fail "AC13 基线旧行未唯一命中"
[ "$(command grep -cxF -e "$NEWC_LINE" "$R/CLAUDE.md" || true)" -eq 1 ] || fail "AC13 新行未唯一出现"
b=$(git -C "$R" show "$T0:CLAUDE.md" | command grep -vxF -e "$OLDC_LINE")
n=$(command grep -vxF -e "$NEWC_LINE" "$R/CLAUDE.md")
[ "$b" = "$n" ] || fail "AC13 CLAUDE.md 在钉死行之外发生改动"
NEWS2=$(command grep -m1 -F -e '「修改框架自身」含' "$R/.claude/skills/alex-lite/SKILL.md" || true)
[ -n "$NEWS2" ] || fail "AC13 取不到 NEWS2（新行缺失）"
for f in $SKILLS; do
  for m in GOALQ-L1A GOALQ-CHECK; do
    bg=$(command grep -cxF -e "<!-- $m-BEGIN -->" "$R/$f" || true)
    en=$(command grep -cxF -e "<!-- $m-END -->"   "$R/$f" || true)
    [ "$bg" -eq "$en" ] && [ "$bg" -le 1 ] || fail "AC13 哨兵 $m 不成对/重复: $f"
  done
  b=$(git -C "$R" show "$T0:$f" | command grep -vxF -e "$OLDS")
  n=$(sed -e '/^<!-- GOALQ-L1A-BEGIN -->$/,/^<!-- GOALQ-L1A-END -->$/d' \
          -e '/^<!-- GOALQ-CHECK-BEGIN -->$/,/^<!-- GOALQ-CHECK-END -->$/d' "$R/$f" \
       | command grep -vxF -e "$NEWS1" -e "$NEWS2")
  [ "$b" = "$n" ] || fail "AC13 $f 在哨兵块与钉死行之外发生改动"
done
echo "V1 V2 V13 OK"

# V3 AC3 目标题检查判别力
[ -s "$EV/goal-check.sh" ] || fail "AC3 缺 goal-check.sh（Step 0 未跑）"
for x in good-mid good-last; do
  zsh "$EV/goal-check.sh" "$EV/fixtures/$x.md" > "$EV/ac3-$x.out" 2>&1 \
    || fail "AC3 $x 应 exit0"
done
for pair in 'bad-no-null:null=0' 'bad-two-null:null=2' 'bad-letter-oob:inset=0' 'bad-chose-null:wrong=1'; do
  x=${pair%%:*}; key=${pair#*:}
  zsh "$EV/goal-check.sh" "$EV/fixtures/$x.md" > "$EV/ac3-$x.out" 2>&1 && fail "AC3 $x 应 exit1"
  command grep -qF -e "$key" "$EV/ac3-$x.out" || fail "AC3 $x 未点名违反项（缺 $key）"
done
for s in "grep -cF '[不是这个意思]'" "grep -cE '^用户选择: [A-Z]\$'" '"$o" -ge 2' '"$n" -eq 1' '"$w" -eq 0'; do
  [ "$(command grep -cF -e "$s" "$R/.claude/skills/blake-lite/SKILL.md" || true)" -ge 1 ] \
    || fail "AC3 blake-lite 缺检查要素: $s"
done
echo "V3 OK"

# V4 AC4 L1a 条款
for f in .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md; do
  L1A=$(sed -n '/^### \*\*L1a — 目标题/,$p' "$R/$f" | sed -n '1p;2,${/^### /q;p;}')
  [ -n "$L1A" ] || { fail "AC4 取不到 L1a 节: $f"; continue; }
  for s in '**≥2 个选项**' '仅措辞不同不算' '必须恰好有一个 `[不是这个意思]` 选项' \
           '**不得由 Alex 自选**' '**不得隐藏 Alex 想到过的读法**' '不覆盖 L1a' \
           '是**第一类（初始 contract）的组成部分**'; do
    [ "$(printf '%s\n' "$L1A" | command grep -cF -e "$s" || true)" -ge 1 ] || fail "AC4 缺串「$s」: $f"
  done
done
[ "$(git -C "$R" show "$T0:.claude/skills/alex-lite/SKILL.md" \
     | sed -n '/^### \*\*L1a — 目标题/,$p' | wc -l | tr -d ' ')" -eq 0 ] \
  || fail "AC4 判据永真：L1a 节在 T=0 已存在"
echo "V4 OK"

# V5 AC5 删除预算
read -r ADDED DELETED <<<"$(git -C "$R" diff --numstat "$T0" -- CLAUDE.md $SKILLS \
  | LC_ALL=C awk '{a+=$1;d+=$2} END{print a+0,d+0}')"
echo "added=$ADDED deleted=$DELETED"
[ "$DELETED" -eq 5 ] || fail "AC5 删除行数 $DELETED != 5"

# V6 AC6 parity
cmp -s "$R/.claude/skills/alex-lite/SKILL.md"  "$R/.agents/skills/alex-lite/SKILL.md"  || fail "parity alex"
cmp -s "$R/.claude/skills/blake-lite/SKILL.md" "$R/.agents/skills/blake-lite/SKILL.md" || fail "parity blake"

# V7 AC7 闭集未改
for f in alex-lite blake-lite; do
  base=$(git -C "$R" show "$T0:.claude/skills/$f/SKILL.md" | awk '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/')
  now=$(awk '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/' "$R/.claude/skills/$f/SKILL.md")
  [ "$(printf '%s\n' "$base" | command grep -c . || true)" -ge 3 ] || fail "AC7 基线区间过短"
  [ "$base" = "$now" ] || fail "AC7 闭集被改: $f"
done

# V8 AC8 决策点锚
command grep -Fxq 'Execution Mandate、下方闭集中的实质边界变化、最终业务验收。命令、工具、exit、retry、' \
  "$R/.claude/skills/alex-lite/SKILL.md" || fail "AC8 决策点锚被改"

# V9 AC9 上一单 Epic 闸未被改
b=$(git -C "$R" show "$T0:.claude/skills/alex-lite/SKILL.md" | sed -n '/^## Epic Objective 闸/,$p' | sed -n '1p;2,${/^## /q;p;}')
n=$(sed -n '/^## Epic Objective 闸/,$p' "$R/.claude/skills/alex-lite/SKILL.md" | sed -n '1p;2,${/^## /q;p;}')
[ "$(printf '%s\n' "$b" | command grep -c . || true)" -ge 5 ] || fail "AC9 基线取不到 Epic 闸节"
[ "$b" = "$n" ] || fail "AC9 Epic Objective 闸被改动"

# V10 AC10 full 未被碰
[ "$(git -C "$R" diff --name-only "$T0" -- \
   .claude/skills/alex .claude/skills/blake .claude/skills/gate \
   .agents/skills/alex .agents/skills/blake .agents/skills/gate | wc -l)" -eq 0 ] || fail "full 被改"

# V11 AC11 围栏
ALLOW='^CLAUDE\.md$|^\.claude/skills/(alex|blake)-lite/SKILL\.md$|^\.agents/skills/(alex|blake)-lite/SKILL\.md$|^\.tad/evidence/acceptance-tests/requirement-first/|^\.tad/archive/handoffs/COMPLETION-20260812-requirement-first\.md$|^\.tad/evidence/journal/lite-discoveries\.md$'
HOOK='^\.tad/evidence/(traces|decisions)/[0-9]{4}-[0-9]{2}-[0-9]{2}\.jsonl$'
[ -n "$ALLOW" ] && [ -n "$HOOK" ] || fail "ALLOW/HOOK 为空"
{ git -C "$R" -c core.quotePath=false diff --name-only "$T0" -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-now.txt"
[ -s "$EV/fence-baseline.txt" ] || fail "AC11 基线缺失（Step 0 未跑）"
LEFT=$(LC_ALL=C comm -13 "$EV/fence-baseline.txt" "$EV/fence-now.txt" | command grep -vE "$ALLOW" | command grep -vE "$HOOK" || true)
[ -z "$LEFT" ] || { printf '%s\n' "$LEFT"; fail "围栏残留"; }

# V12 AC12 契约未被改
[ -s "$EV/contract.sha256" ] || fail "AC12 基线 sha 为空"
[ "$(shasum -a 256 "$R/$CP" | LC_ALL=C awk '{print $1}')" = "$(cat "$EV/contract.sha256")" ] || fail "契约被改"

[ "$FAIL" -eq 0 ] && { echo "RESULT=PASS"; exit 0; } || { echo "RESULT=FAIL"; exit 1; }
