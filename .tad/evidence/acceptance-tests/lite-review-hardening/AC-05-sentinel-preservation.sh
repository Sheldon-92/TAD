#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT" || exit 1
expected=4c55bcb6563f24dc78449fb19ff76067
fail=0
for f in .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md; do
  actual=$(awk '/^<!-- ESCALATION-LIST-BEGIN -->$/,/^<!-- ESCALATION-LIST-END -->$/' "$f" | md5 -q)
  [ "$actual" = "$expected" ] || { echo "FAIL: $f sentinel md5=$actual"; fail=1; }
  begin=$(grep -c '^<!-- ESCALATION-LIST-BEGIN -->$' "$f" || true)
  end=$(grep -c '^<!-- ESCALATION-LIST-END -->$' "$f" || true)
  [ "$begin" -eq 1 ] || { echo "FAIL: $f BEGIN count=$begin"; fail=1; }
  [ "$end" -eq 1 ] || { echo "FAIL: $f END count=$end"; fail=1; }
done
if [ "$fail" -eq 0 ]; then echo 'PASS: AC5 sentinel preservation'; else exit 1; fi
