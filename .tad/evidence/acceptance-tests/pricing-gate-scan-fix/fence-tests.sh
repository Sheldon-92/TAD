#!/bin/bash
# AC7/AC8 围栏双向自测 — TASK-20260805-P1a-fix
# 负向：禁区种文件 → 必须被抓；正向：git add 授权集 untracked 文件 → 必须静默
S=.tad/evidence/acceptance-tests/pricing-gate-scan-fix
BASE=4b29dc263a5368c0b598fc1030f465fc7ebdbc10
ALLOW=$(cat "$S/allow.txt")

echo "========== 负向自测：禁区 untracked 文件必须被抓 =========="
PLANT=".tad/active/epics/PLANTED-fence-probe.md"
touch "$PLANT"
git -c core.quotePath=false status --porcelain --untracked-files=all \
  | grep '^??' | cut -c4- | LC_ALL=C sort > "$S/untracked-after-fence.md"
HITS=$(comm -13 "$S/untracked-before.txt" "$S/untracked-after-fence.md" | grep -vE "$ALLOW")
if echo "$HITS" | grep -q "PLANTED-fence-probe"; then
  echo "✓ 负向探针被 AC8 围栏抓获：$HITS"
else
  echo "✗ NEGATIVE-FENCE-FAIL 探针未被抓获：$HITS"
fi
rm -f "$PLANT"

echo "========== 正向自测：git add 授权集 untracked 文件后仍静默 =========="
git add "$S/probe-cmd.md"
git -c core.quotePath=false status --porcelain --untracked-files=all \
  | grep '^??' | cut -c4- | LC_ALL=C sort > "$S/untracked-after-fence2.md"
HITS2=$(comm -13 "$S/untracked-before.txt" "$S/untracked-after-fence2.md" | grep -vE "$ALLOW")
if [ -z "$HITS2" ]; then
  echo "✓ 正向自测静默（授权集 untracked 加入 index 后围栏无输出）"
else
  echo "✗ POSITIVE-FENCE-FAIL 授权集内文件被误报：$HITS2"
fi
git reset -q HEAD "$S/probe-cmd.md" && echo "✓ git add 已回滚（unstage）"

echo "========== 围栏双向自测完毕 =========="
