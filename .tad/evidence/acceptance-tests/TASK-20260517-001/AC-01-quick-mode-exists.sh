#!/bin/bash
# AC1: quick_mode exists in accept_command with 3 steps
FILE=".claude/skills/alex/SKILL.md"
count=$(grep -c 'quick_mode:' "$FILE")
steps=$(grep -c 'step[123]_\(identify\|archive\|update\):' "$FILE")
if [ "$count" -eq 1 ] && [ "$steps" -ge 3 ]; then
  echo "PASS: quick_mode found ($count) with $steps steps"
  exit 0
else
  echo "FAIL: quick_mode=$count, steps=$steps"
  exit 1
fi
