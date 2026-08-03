#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT" || exit 1
cmp -s .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md || { echo 'FAIL: Blake mirrors differ'; exit 1; }
cmp -s .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md || { echo 'FAIL: Alex mirrors differ'; exit 1; }
echo 'PASS: AC4 mirror parity'
