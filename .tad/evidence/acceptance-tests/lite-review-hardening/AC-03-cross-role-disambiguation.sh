#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT" || exit 1
B=.claude/skills/blake-lite/SKILL.md
A=.claude/skills/alex-lite/SKILL.md
fail=0
for f in "$A" "$B"; do
  n=$(grep -c '^## 跨角色请求消歧' "$f" || true)
  [ "$n" -eq 1 ] || { echo "FAIL: $f section count=$n"; fail=1; }
  start=$(grep -n '^## 跨角色请求消歧' "$f" | cut -d: -f1)
  end=$(grep -n '^## Forbidden' "$f" | cut -d: -f1)
  [ "$start" -lt "$end" ] || { echo "FAIL: $f section placement"; fail=1; }
  for term in 触发消歧 逐字记录 拒绝执行 NOT_via_suggestion cross_role_request; do
    n=$(awk '/^## 跨角色请求消歧/,/^## Forbidden/' "$f" | grep -c "$term" || true)
    [ "$n" -ge 1 ] || { echo "FAIL: $f missing $term"; fail=1; }
  done
done
grep -Fxq -e '- 写实现代码 / 自行调用 blake-lite 或用 Agent tool 实现任务 /' "$A" || { echo 'FAIL: Alex Forbidden redline'; fail=1; }
grep -Fxq -e '1. 角色分离：alex-lite 永不写实现代码（design-only）' "$A" || { echo 'FAIL: Alex essence redline'; fail=1; }
grep -Fxq -e '- 跳过 L3 reviewer（任何理由，包括"改动很小"）/' "$B" || { echo 'FAIL: Blake Forbidden redline'; fail=1; }
grep -Fxq -e '- Stop: 未获确认不交接。Alex-Lite 保持 design-only——不实现应用改动、' "$A" || { echo 'FAIL: Alex Stop redline'; fail=1; }
if git diff --unified=0 -- "$A" "$B" .agents/skills/alex-lite/SKILL.md .agents/skills/blake-lite/SKILL.md | grep -F -e '- 写实现代码 / 自行调用 blake-lite 或用 Agent tool 实现任务 /' -e '1. 角色分离：alex-lite 永不写实现代码（design-only）' -e '- 跳过 L3 reviewer（任何理由，包括"改动很小"）/' -e '- Stop: 未获确认不交接。Alex-Lite 保持 design-only——不实现应用改动、' >/dev/null; then
  echo 'FAIL: protected redline appears in a diff hunk'; fail=1
fi
if [ "$fail" -eq 0 ]; then echo 'PASS: AC3 cross-role disambiguation and redlines'; else exit 1; fi
