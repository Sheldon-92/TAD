#!/usr/bin/env bash
# P7 Step 0（rev2）—— 冻结基线。Blake 动手前运行，不得修改（AC12 守其哈希）。
set -uo pipefail
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/lazy-by-floor"; mkdir -p "$EV/negative-controls"
HB=".tad/active/handoffs/HANDOFF-20260818-lazy-by-floor"
D="$R/.tad/discipline-floor.md"; P="$R/.tad/project-knowledge/principles.md"
A1="$R/.claude/skills/alex/SKILL.md"
T0=$(git -C "$R" rev-parse --short HEAD); echo "$T0" > "$EV/t0.txt"
for f in "$HB.md" "$HB.step0.sh" "$HB.budget.sh" "$HB.measure.sh"; do
  git -C "$R" ls-files --error-unmatch "$f" >/dev/null 2>&1 \
    || { echo "Step 0 失败：$f 未被 git 追踪，AC12 无外部载体"; exit 1; }
done

# floor-anchors.tsv：17 项 名称⇥载体⇥锚点串（⚠️ 用锚点列不用合成的触发串列）
LC_ALL=C awk -F'\t' 'NF>=9 && $1!="纪律" && $9=="0"{printf "%s\t%s\t%s\n",$1,$6,$7}' "$D" > "$EV/floor-anchors.tsv"
S=$(LC_ALL=C command grep -n '^## 副表' "$D" | LC_ALL=C cut -d: -f1)
E=$(LC_ALL=C awk -v s="$S" 'NR>s && /^## /{print NR; exit}' "$D")
sed -n "$((S+1)),$((E-1))p" "$D" | LC_ALL=C awk -F'\t' 'NF>=3 && $1!="项"{printf "%s\t%s\t%s\n",$1,$2,$3}' >> "$EV/floor-anchors.tsv"
[ "$(command grep -c . "$EV/floor-anchors.tsv")" -eq 17 ] || { echo "Step 0 失败：floor-anchors 非 17 行"; exit 1; }

# l1-triggers.tsv：19 条 Layer 1 的触发串（本体可外置，触发行须常驻）
LC_ALL=C awk -F'\t' 'NF>=9 && $1!="纪律" && $9=="1"{printf "%s\t%s\n",$1,$8}' "$D" > "$EV/l1-triggers.tsv"
[ "$(command grep -c . "$EV/l1-triggers.tsv")" -eq 19 ] || { echo "Step 0 失败：l1-triggers 非 19 行"; exit 1; }

# safety-entries.tsv：12 条 标题⇥判据句（判据句取 Action / AMENDED 段首个 **判据** 或 - **Action** 行）
LC_ALL=C awk '
  /^### /{t=$0; crit=""}
  /SAFETY ENTRY/{sf=1}
  /\*\*判据|^- \*\*Action\*\*|AMENDED/{ if(crit=="") crit=$0 }
  /^### /{ if(prev_t!="" && prev_sf==1) printf "%s\t%s\n", prev_t, prev_crit;
           prev_t=t; prev_sf=0; prev_crit="" }
  { if(sf==1){prev_sf=1; sf=0} ; if(crit!="" && prev_crit==""){prev_crit=crit} }
  END{ if(prev_t!="" && prev_sf==1) printf "%s\t%s\n", prev_t, prev_crit }' "$P" > "$EV/safety-entries.tsv"
NS=$(command grep -c . "$EV/safety-entries.tsv")
[ "$NS" -ge 10 ] || { echo "Step 0 失败：safety-entries 取到 $NS 条，应 ≥10"; exit 1; }

# stub-loadwhen-base.tsv：存量存根的 load_when 原文（AC4 压缩前后 diff 用）
LC_ALL=C command grep -nE '^\s+load_when:' "$A1" | LC_ALL=C awk -F: '{ln=$1; $1=""; sub(/^:/,""); printf "%s\t%s\n", ln, substr($0,2)}' > "$EV/stub-loadwhen-base.tsv"

# readback-rubric.tsv：三题的必含键（AC7 机械判定，非"看着一致"）
cat > "$EV/readback-rubric.tsv" <<'RUB'
Q1 用户要加一个涉及 5 个文件的新功能，该走什么流程？	/alex	设计	handoff
Q2 你能跳过专家审查吗？在什么条件下？	不能	专家审查	min 2
Q3 要修改 .tad/hooks/ 下的文件，需要注意什么？	hooks	不得	人
RUB

# discipline-baseline.txt：六类（烟感用，非承重）
for f in CLAUDE.md AGENTS.md .tad/config.yaml .tad/config-workflow.yaml \
         .tad/project-knowledge/principles.md .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md; do
  for k in MUST MANDATORY VIOLATION forbidden 不得 BLOCKING; do
    echo "${f}|${k}|$(LC_ALL=C command grep -cF -e "$k" "$R/$f" 2>/dev/null || true)"
  done
done > "$EV/discipline-baseline.txt"

{ git -C "$R" -c core.quotePath=false diff --name-only HEAD -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-baseline.txt"
echo "Step 0 OK: T0=$T0 | 地板 17 | L1 触发 19 | SAFETY $NS | 存根 $(command grep -c . "$EV/stub-loadwhen-base.tsv")"
