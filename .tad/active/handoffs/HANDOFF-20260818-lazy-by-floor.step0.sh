#!/usr/bin/env bash
# P7 Step 0 —— 冻结基线。Blake 动手前运行，不得修改（AC12 守其哈希）。
set -uo pipefail
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/lazy-by-floor"; mkdir -p "$EV/negative-controls"
HB=".tad/active/handoffs/HANDOFF-20260818-lazy-by-floor"
T0=$(git -C "$R" rev-parse --short HEAD); echo "$T0" > "$EV/t0.txt"
for f in "$HB.md" "$HB.step0.sh"; do
  git -C "$R" ls-files --error-unmatch "$f" >/dev/null 2>&1 \
    || { echo "Step 0 失败：$f 未被 git 追踪，AC12 无外部载体"; exit 1; }
done

# 受影响文件全集（AC2 逐类计数的域）
cat > "$EV/affected.txt" <<'AFF'
CLAUDE.md
.tad/config.yaml
.tad/config-agents.yaml
.tad/config-quality.yaml
.tad/config-workflow.yaml
.tad/config-platform.yaml
.tad/project-knowledge/principles.md
.claude/skills/alex/SKILL.md
.agents/skills/alex/SKILL.md
AFF

# 逐类纪律基线：六类 × 受影响文件（含 references/ 目录合计，防"搬进 references 就不算了"）
: > "$EV/discipline-baseline.txt"
while IFS= read -r f; do
  [ -f "$R/$f" ] || continue
  for k in MUST MANDATORY VIOLATION forbidden 不得 BLOCKING; do
    echo "${f}|${k}|$(LC_ALL=C command grep -cF -e "$k" "$R/$f" || true)"
  done
done < "$EV/affected.txt"
for d in .claude/skills/alex/references .agents/skills/alex/references; do
  for k in MUST MANDATORY VIOLATION forbidden 不得 BLOCKING; do
    n=$(cat "$R/$d"/*.md 2>/dev/null | LC_ALL=C command grep -cF -e "$k" || true)
    echo "${d}/*|${k}|${n}"
  done
done >> "$EV/discipline-baseline.txt"

# floor-triggers.tsv：11 条 Layer0 主表 + 副表各项的 纪律名 ⇥ 触发串
LC_ALL=C awk -F'\t' 'NF>=9 && $1!="纪律" && $9=="0"{printf "%s\t%s\n",$1,$8}' "$R/.tad/discipline-floor.md" > "$EV/floor-triggers.tsv"
S=$(LC_ALL=C command grep -n '^## 副表' "$R/.tad/discipline-floor.md" | LC_ALL=C cut -d: -f1)
E=$(LC_ALL=C awk -v s="$S" 'NR>s && /^## /{print NR; exit}' "$R/.tad/discipline-floor.md")
sed -n "$((S+1)),$((E-1))p" "$R/.tad/discipline-floor.md" | LC_ALL=C awk -F'\t' 'NF>=4 && $1!="项"{printf "%s\t%s\n",$1,$4}' >> "$EV/floor-triggers.tsv"
NT=$(command grep -c . "$EV/floor-triggers.tsv")
[ "$NT" -ge 17 ] || { echo "Step 0 失败：触发串取到 $NT 条，应 ≥17（地板表结构漂移）"; exit 1; }

# safety-titles.txt：principles.md 中含 SAFETY ENTRY 的条目标题
LC_ALL=C awk '/^### /{t=$0; buf=""} {buf=buf"\n"$0} /SAFETY ENTRY/{if(t!=""){print t; t=""}}' \
  "$R/.tad/project-knowledge/principles.md" | LC_ALL=C sort -u > "$EV/safety-titles.txt"
NS=$(command grep -c . "$EV/safety-titles.txt")
[ "$NS" -ge 10 ] || { echo "Step 0 失败：SAFETY 标题取到 $NS 条，应 ≥10"; exit 1; }

# measure-base.txt：激活即付（常驻整读集 + P3 后的命令输出估值 6892）
: > "$EV/measure-base.txt"; TOT=6892
for f in .claude/skills/alex/SKILL.md .tad/config.yaml .tad/config-agents.yaml \
         .tad/config-quality.yaml .tad/config-workflow.yaml .tad/config-platform.yaml \
         CLAUDE.md .tad/project-knowledge/principles.md .tad/project-knowledge/patterns/_index.md \
         .tad/project-knowledge/frontend-design.md .tad/guides/tool-quick-reference-alex.md \
         .tad/active/session-state.md; do
  n=0; [ -f "$R/$f" ] && n=$(LC_ALL=C wc -c < "$R/$f" | LC_ALL=C tr -d ' ')
  printf '%s\t%s\n' "$f" "$n" >> "$EV/measure-base.txt"; TOT=$((TOT+n))
done
printf 'CMD_OUTPUT\t6892\nTOTAL\t%s\n' "$TOT" >> "$EV/measure-base.txt"

# AC7 三题（基线答案须由 Blake 在动手前 spawn fresh subagent 产出，落 readback-base.txt）
cat > "$EV/readback-questions.txt" <<'Q'
Q1 用户要加一个涉及 5 个文件的新功能，该走什么流程？
Q2 你能跳过专家审查吗？在什么条件下？
Q3 要修改 .tad/hooks/ 下的文件，需要注意什么？
Q
{ git -C "$R" -c core.quotePath=false diff --name-only HEAD -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-baseline.txt"
echo "Step 0 OK: T0=$T0 | 触发串 $NT 条 | SAFETY 标题 $NS 条 | 激活即付基线 ${TOT} B"
