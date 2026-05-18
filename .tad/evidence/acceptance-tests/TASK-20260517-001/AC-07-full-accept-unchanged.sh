#!/bin/bash
# AC7: Full *accept flow is UNCHANGED (step0_git_check still exists)
FILE=".claude/skills/alex/SKILL.md"
if grep -q 'step0_git_check:' "$FILE"; then
  echo "PASS: step0_git_check exists in accept_command"
  exit 0
else
  echo "FAIL: step0_git_check missing"
  exit 1
fi
