#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT" || exit 1
A=.claude/skills/alex-lite/SKILL.md
B=.claude/skills/blake-lite/SKILL.md
fail=0
n=$(grep -c 'Reviewer: {待填} | model=' "$A" || true)
[ "$n" -ge 1 ] || { echo 'FAIL: Alex Contract Review model carrier'; fail=1; }
n=$(grep -c 'model={reviewer 自报' "$B" || true)
[ "$n" -ge 1 ] || { echo 'FAIL: Blake Completion model carrier'; fail=1; }
n=$(awk '/^### \*\*L2\.5/,/^### \*\*L3 —/' "$A" | grep -c '自报' || true)
[ "$n" -ge 1 ] || { echo 'FAIL: Alex L2.5 self-report instruction'; fail=1; }
if [ "$fail" -eq 0 ]; then echo 'PASS: AC9 reviewer model carriers'; else exit 1; fi
