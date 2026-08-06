#!/bin/zsh
# Post-impl AC2-AC5 verification (contract HANDOFF-20260805-cut-routing-machinery.md §4)
cd "$(git rev-parse --show-toplevel)" || exit 1
OUT=.tad/evidence/acceptance-tests/cut-routing-machinery/post-impl-output.txt
{
echo "--- AC2 ---"
ac2=0
# ── 负向：必须为 0 ──
for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md \
         .agents/skills/alex-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do
  for pat in '## Route Contract' 'R0 — Route preflight' 'RouteDecision' 'route_level' \
             'blocked_missing_contract' 'blocked_stale_revision' 'escalated_full' \
             'design_depth' 'execution_depth' 'F0_FATAL' 'F1_GOVERNANCE' \
             'Standard is a profile' 'routing-contract.yaml' \
             'escalated_review' 'escalated' '额度出口' '升级清单' '转 full TAD' \
             '### Reviewer 档位规则' '强档' 'REVIEWER-TIER-DEGRADED' \
             'Model 行捕获纪律' 'Model 行捕获紀律' 'Model 行纪律' '格式同 Model 行' \
             'default_subagent_model' 'CODEX_HOME' 'alias-mapped'; do
    n=$(grep -cF -- "$pat" "$f"); [ "$n" -eq 0 ] || { echo "  AC2 FAIL [$f] 残留 '$pat' ×$n"; ac2=1; }
  done; done
for f in AGENTS.md .claude/skills/tad-help/SKILL.md .agents/skills/tad-help/SKILL.md; do
  for pat in 'Lite / Standard / Full Routing' 'Standard 是深度配置' '当前建议' \
             'routing profiles' 'Shared route contract' 'escalation valve' \
             'Independent depth selection' 'different profiles' 'explicit routing rules'; do
    n=$(grep -cF -- "$pat" "$f"); [ "$n" -eq 0 ] || { echo "  AC2 FAIL [$f] 残留 '$pat' ×$n"; ac2=1; }
  done; done
for pat in '## Lite / Standard / Full 路由' '涉及安全、协议契约或致命操作时进入 Full' 'routing-contract.yaml'; do
  n=$(grep -cF -- "$pat" INSTALLATION_GUIDE.md); [ "$n" -eq 0 ] || { echo "  AC2 FAIL [INSTALLATION_GUIDE.md] 残留 '$pat' ×$n"; ac2=1; }
done
n=$(grep -cF -- '非协议契约的小任务' CLAUDE.md); [ "$n" -eq 0 ] || { echo "  AC2 FAIL CLAUDE.md 旧 §2.5 残留"; ac2=1; }
# ── 正向：必须还在 ──
must() { n=$(grep -cF -- "$2" "$1"); [ "$n" -ge "$3" ] || { echo "  AC2 FAIL [$1] '$2' 只剩 $n（期望 ≥$3）"; ac2=1; }; }
for p in .claude .agents; do
  must "$p/skills/blake-lite/SKILL.md" '跳过 L3 reviewer' 1
  must "$p/skills/blake-lite/SKILL.md" '以自审、自我复核替代 subagent spawn' 1
  must "$p/skills/blake-lite/SKILL.md" '六条件自治修复' 1
  must "$p/skills/blake-lite/SKILL.md" 'UNVERIFIED-BY-EXECUTION' 1
  must "$p/skills/blake-lite/SKILL.md" '最小探针' 1
  must "$p/skills/blake-lite/SKILL.md" '**Model**: harness=' 1
  must "$p/skills/blake-lite/SKILL.md" '## L3 独立审查' 1
  must "$p/skills/blake-lite/SKILL.md" '## Forbidden' 1
  must "$p/skills/alex-lite/SKILL.md"  '以自审替代 reviewer spawn' 1
  must "$p/skills/alex-lite/SKILL.md"  '不得把 FAIL 契约交给 blake-lite' 1
  must "$p/skills/alex-lite/SKILL.md"  '## Forbidden' 1
done
must CLAUDE.md '默认通道' 1
[ $ac2 -eq 0 ] && echo "AC2 PASS" || echo "AC2 FAIL"

echo
echo "--- AC3 ---"
ac3=0
for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md \
         .agents/skills/alex-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do
  blk=$(awk '/ESCALATION-LIST-BEGIN/{f=1} f{print} /ESCALATION-LIST-END/{exit}' "$f")
  h=$(printf '%s\n' "$blk" | md5); n=$(printf '%s\n' "$blk" | wc -l | tr -d ' ')
  [ "$h" = "166464e66b98c701a2b892d6e773256f" ] && [ "$n" -eq 7 ] \
    && echo "  OK   $f" || { echo "  AC3 FAIL $f  $n 行(期望7) md5=$h"; ac3=1; }
done
[ $ac3 -eq 0 ] && echo "AC3 PASS" || echo "AC3 FAIL"

echo
echo "--- AC4 ---"
ac4=0; tot=0
for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md; do
  c=$(wc -c < "$f" | tr -d ' '); echo "  $f: $(wc -l < "$f" | tr -d ' ') 行 / $c 字符"; tot=$((tot + c))
done
echo "  两 skill 合计: $tot（改动前 64,050；期望带 44,000–47,000）"
[ "$tot" -le 47000 ] || { echo "  AC4 FAIL 合计 > 47,000（删得不够）"; ac4=1; }
[ "$tot" -ge 44000 ] || { echo "  AC4 FAIL 合计 < 44,000（删多了）"; ac4=1; }
for s in alex-lite blake-lite tad-help; do
  a=$(md5 -q ".claude/skills/$s/SKILL.md"); b=$(md5 -q ".agents/skills/$s/SKILL.md")
  [ "$a" = "$b" ] && echo "  OK   parity $s" || { echo "  AC4 FAIL parity $s"; ac4=1; }
done
[ $ac4 -eq 0 ] && echo "AC4 PASS" || echo "AC4 FAIL"

echo
echo "--- AC5 ---"
ac5=0
[ "$(git rev-parse HEAD)" = "6a7cef0b22fddcd050af53949fd43e3c8ca0a36a" ] \
  || { echo "  AC5 FAIL HEAD 已移动: $(git rev-parse HEAD)"; ac5=1; }
[ "$(git ls-files -v | grep -vc '^H ')" -eq 0 ] \
  || { echo "  AC5 FAIL index 有 assume-unchanged/skip-worktree"; ac5=1; }
A=$(mktemp); cat > "$A" <<'EOF'
.claude/skills/alex-lite/SKILL.md
.claude/skills/blake-lite/SKILL.md
.agents/skills/alex-lite/SKILL.md
.agents/skills/blake-lite/SKILL.md
.claude/skills/tad-help/SKILL.md
.agents/skills/tad-help/SKILL.md
AGENTS.md
CLAUDE.md
INSTALLATION_GUIDE.md
.tad/evidence/acceptance-tests/lite-pricing-gate-protocol/AC6.txt
.tad/evidence/acceptance-tests/lite-pricing-gate-protocol/tracked-after.txt
.tad/evidence/acceptance-tests/lite-pricing-gate-protocol/untracked-after.txt
.tad/research-notebooks/REGISTRY.yaml
EOF
V=$(mktemp)
git diff --name-only HEAD | LC_ALL=C sort -u | grep -vxF -f "$A" \
  | grep -vE '^\.tad/evidence/(journal|traces|decisions|ralph-loops)/|^\.tad/memory/|^\.tad/active/handoffs/COMPLETION-' > "$V"
[ -s "$V" ] && { echo "  AC5 FAIL tracked 越权改动:"; cat "$V"; ac5=1; }
for d in .claude/skills/alex-lite .claude/skills/blake-lite .agents/skills/alex-lite .agents/skills/blake-lite; do
  n=$(find "$d" -type f | wc -l | tr -d ' ')
  [ "$n" -eq 1 ] || { echo "  AC5 FAIL $d 有 $n 个文件（期望 1）"; find "$d" -type f; ac5=1; }
done
[ $ac5 -eq 0 ] && echo "AC5 PASS" || echo "AC5 FAIL"
} >> "$OUT" 2>&1
cat "$OUT"
