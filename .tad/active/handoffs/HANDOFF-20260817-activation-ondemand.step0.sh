#!/usr/bin/env bash
# P3 Step 0 —— 冻结基线。Blake 动手前运行，不得修改（AC9 守其哈希）。
set -uo pipefail
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/activation-ondemand"; mkdir -p "$EV/negative-controls"
HB=".tad/active/handoffs/HANDOFF-20260817-activation-ondemand"
A1="$R/.claude/skills/alex/SKILL.md"; A2="$R/.agents/skills/alex/SKILL.md"
T0=$(git -C "$R" rev-parse --short HEAD); echo "$T0" > "$EV/t0.txt"
for f in "$HB.md" "$HB.step0.sh" "$HB.pins.tsv"; do
  git -C "$R" ls-files --error-unmatch "$f" >/dev/null 2>&1 \
    || { echo "Step 0 失败：$f 未被 git 追踪，AC9 无外部载体"; exit 1; }
done

# pins 校验：7 条，每条 OLD 在两个 alex 文件各唯一命中、NEW 各 0 次
: > "$EV/pins-verified.txt"; BAD=0
while IFS=$'\t' read -r id old new; do
  [ -n "${id:-}" ] || continue
  for f in "$A1" "$A2"; do
    co=$(LC_ALL=C command grep -cFx -e "$old" "$f" || true)
    cn=$(LC_ALL=C command grep -cFx -e "$new" "$f" || true)
    printf '%s\t%s\told=%s\tnew=%s\n' "$id" "$(basename "$(dirname "$(dirname "$f")")")" "$co" "$cn" >> "$EV/pins-verified.txt"
    { [ "$co" -eq 1 ] && [ "$cn" -eq 0 ]; } || BAD=$((BAD+1))
  done
done < "$R/$HB.pins.tsv"
N=$(command grep -c . "$R/$HB.pins.tsv")
[ "$N" -eq 7 ] || { echo "Step 0 失败：pins 条数 $N，应 7"; exit 1; }
[ "$BAD" -eq 0 ] || { echo "Step 0 失败：$BAD 处 pins 唯一性不符（停下退回 Alex）"; cat "$EV/pins-verified.txt"; exit 1; }

# 纪律基线：两个 alex 文件 × 五类
for f in .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md; do
  for k in MUST MANDATORY VIOLATION forbidden 不得; do
    echo "${f}|${k}|$(LC_ALL=C command grep -cF -e "$k" "$R/$f" || true)"
  done
done > "$EV/discipline-baseline.txt"

# 激活时整读字节基线：7 个扫描源（session-state 不计——本单不动它）
: > "$EV/measure-base.txt"
TOT=0
for f in NEXT.md PROJECT_CONTEXT.md .tad/research-notebooks/REGISTRY.yaml \
         .tad/dependencies/scan-results.yaml .tad/dependencies/REGISTRY.yaml \
         OBJECTIVES.md .tad/github-registry/scan-log.yaml; do
  n=0; [ -f "$R/$f" ] && n=$(LC_ALL=C wc -c < "$R/$f" | LC_ALL=C tr -d ' ')
  printf '%s\t%s\n' "$f" "$n" >> "$EV/measure-base.txt"; TOT=$((TOT+n))
done
printf 'TOTAL\t%s\n' "$TOT" >> "$EV/measure-base.txt"

{ git -C "$R" -c core.quotePath=false diff --name-only HEAD -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-baseline.txt"
echo "Step 0 OK: T0=$T0 | pins 7 条全合格 | 激活整读基线 ${TOT} B"
