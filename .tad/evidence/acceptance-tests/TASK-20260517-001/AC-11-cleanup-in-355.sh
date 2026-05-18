#!/bin/bash
# AC11: Cleanup actions in STEP 3.55, not STEP 3.5
FILE=".claude/skills/alex/SKILL.md"
step355=$(grep -c 'STEP 3.55' "$FILE")
# Verify STEP 3.55 has the AskUserQuestion cleanup
has_cleanup=$(awk '/STEP 3.55:/,/STEP 3.8:/' "$FILE" | grep -c 'AskUserQuestion')
if [ "$step355" -ge 1 ] && [ "$has_cleanup" -ge 1 ]; then
  echo "PASS: STEP 3.55 exists ($step355 refs) with cleanup AskUserQuestion ($has_cleanup)"
  exit 0
else
  echo "FAIL: STEP 3.55=$step355, cleanup=$has_cleanup"
  exit 1
fi
