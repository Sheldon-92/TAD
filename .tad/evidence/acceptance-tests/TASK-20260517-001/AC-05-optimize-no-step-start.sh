#!/bin/bash
# AC5: optimize step2_aggregate has 5 metrics without step_start/step_end
FILE=".claude/skills/alex/SKILL.md"
# Extract step2_aggregate section and check for step_start
section=$(awk '/step2_aggregate:/,/step2b_project_knowledge:/' "$FILE")
has_step_start=$(echo "$section" | grep -c 'step_start')
has_metrics=$(echo "$section" | grep -c 'Zombie rate\|Completion cycle time\|Evidence production rate\|Activity timeline\|Trace type breakdown')
if [ "$has_step_start" -eq 0 ] && [ "$has_metrics" -ge 5 ]; then
  echo "PASS: step2_aggregate has $has_metrics metrics, 0 step_start references"
  exit 0
else
  echo "FAIL: step_start=$has_step_start, metrics=$has_metrics"
  exit 1
fi
