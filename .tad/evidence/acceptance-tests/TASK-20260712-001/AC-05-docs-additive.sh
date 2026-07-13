#!/usr/bin/env bash
# AC5: CLAUDE.md 7.5 + runbook gotcha both additive
cd "$(git rev-parse --show-toplevel)"
A=$(grep -c 'Memory Capture Layer' CLAUDE.md)
B=$(grep -c 'memory-redirect' .claude/skills/release-runbook/SKILL.md)
D1=$(comm -23 <(git show HEAD:CLAUDE.md | sort -u) <(sort -u CLAUDE.md) | wc -l | tr -d ' ')
D2=$(comm -23 <(git show HEAD:.claude/skills/release-runbook/SKILL.md | sort -u) <(sort -u .claude/skills/release-runbook/SKILL.md) | wc -l | tr -d ' ')
[ "$A" -ge 1 ] && [ "$B" -ge 1 ] && [ "$D1" -eq 0 ] && [ "$D2" -eq 0 ] && { echo "AC5 PASS: claude=$A runbook=$B del=$D1/$D2"; exit 0; }
echo "AC5 FAIL: claude=$A runbook=$B del=$D1/$D2"; exit 1
