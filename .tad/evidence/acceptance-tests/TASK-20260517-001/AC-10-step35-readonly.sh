#!/bin/bash
# AC10: STEP 3.5 zombie detection is READ-ONLY
FILE=".claude/skills/alex/SKILL.md"
section=$(awk '/STEP 3.5: Document health/,/STEP 3.6:/' "$FILE")
has_readonly=$(echo "$section" | grep -c 'READ-ONLY - do not modify any files')
if [ "$has_readonly" -ge 1 ]; then
  echo "PASS: STEP 3.5 contains READ-ONLY declaration ($has_readonly)"
  exit 0
else
  echo "FAIL: READ-ONLY declaration missing"
  exit 1
fi
