#!/bin/bash
# AC-07: Existing completion_protocol steps (step1-step3, step4-step8) unchanged
FILE=".claude/commands/tad-blake.md"
PASS=0
TOTAL=4

grep -q 'step1: "使用' "$FILE" && PASS=$((PASS+1)) || echo "  CHANGED: step1"
grep -q 'step2: "通过 Layer 1' "$FILE" && PASS=$((PASS+1)) || echo "  CHANGED: step2"
grep -q 'step4: "执行 Gate 3 v2' "$FILE" && PASS=$((PASS+1)) || echo "  CHANGED: step4"
grep -q 'step8: "生成给 Alex 的信' "$FILE" && PASS=$((PASS+1)) || echo "  CHANGED: step8"

if [ "$PASS" -eq "$TOTAL" ]; then
  echo "PASS: existing steps unchanged ($PASS/$TOTAL)"
  exit 0
else
  echo "FAIL: some steps were modified ($PASS/$TOTAL)"
  exit 1
fi
