#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT" || exit 1
B=.claude/skills/blake-lite/SKILL.md
A=.claude/skills/alex-lite/SKILL.md
fail=0
for f in "$B" "$A"; do
  n=$(grep -c '^### Reviewer 档位规则' "$f" || true)
  [ "$n" -eq 1 ] || { echo "FAIL: $f reviewer-rule title count=$n"; fail=1; }
done
blake_rule=$(grep -n '^### Reviewer 档位规则' "$B" | cut -d: -f1)
blake_l3=$(grep -n '^## L3 独立审查' "$B" | cut -d: -f1)
blake_l35=$(grep -n '^## L3\.5' "$B" | cut -d: -f1)
alex_rule=$(grep -n '^### Reviewer 档位规则' "$A" | cut -d: -f1)
alex_l25=$(grep -n '^### \*\*L2\.5' "$A" | cut -d: -f1)
alex_l3=$(grep -n '^### \*\*L3 —' "$A" | cut -d: -f1)
[ "$blake_rule" -gt "$blake_l3" ] && [ "$blake_rule" -lt "$blake_l35" ] || { echo 'FAIL: Blake rule placement'; fail=1; }
[ "$alex_rule" -gt "$alex_l25" ] && [ "$alex_rule" -lt "$alex_l3" ] || { echo 'FAIL: Alex rule placement'; fail=1; }
blake_region=$(awk '/^### Reviewer 档位规则/,/^## /' "$B")
alex_region=$(awk '/^### Reviewer 档位规则/,/^### \*\*L3 —/' "$A")
for name in Blake Alex; do
  if [ "$name" = Blake ]; then region=$blake_region; else region=$alex_region; fi
  n=$(printf '%s\n' "$region" | grep -c 'route_level' || true)
  [ "$n" -ge 1 ] || { echo "FAIL: $name route_level"; fail=1; }
  n=$(printf '%s\n' "$region" | grep -c 'execution_depth' || true)
  [ "$n" -eq 0 ] || { echo "FAIL: $name execution_depth regression"; fail=1; }
  n=$(printf '%s\n' "$region" | grep -c 'REVIEWER-TIER-DEGRADED' || true)
  [ "$n" -ge 1 ] || { echo "FAIL: $name degraded tier rule"; fail=1; }
done
if [ "$fail" -eq 0 ]; then echo 'PASS: AC2 reviewer tier rules and placement'; else exit 1; fi
