#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT" || exit 1
B=.claude/skills/blake-lite/SKILL.md
fail=0
probe=$(awk '/^## L3 独立审查/,/^## L3\.5/' "$B" | awk '/spawn 1 个 code-reviewer/,/verdict PASS\/CONDITIONAL\/FAIL"/')
for term in '执行验证义务' 'UNVERIFIED-BY-EXECUTION'; do
  n=$(printf '%s\n' "$probe" | grep -c "$term" || true)
  [ "$n" -ge 1 ] || { echo "FAIL: missing $term"; fail=1; }
done
n=$(printf '%s\n' "$probe" | grep -cE '执行实证|阅读推断' || true)
[ "$n" -ge 1 ] || { echo 'FAIL: missing finding classification'; fail=1; }
l3=$(awk '/^## L3 独立审查/,/^## L3\.5/' "$B")
printf '%s\n' "$l3" | grep -q 'Completion 摘录 reviewer 结论时保留“执行实证/阅读推断”标注' \
  || { echo 'FAIL: missing Completion classification retention rule'; fail=1; }
if [ "$fail" -eq 0 ]; then echo 'PASS: AC1 execution probe obligation'; else exit 1; fi
