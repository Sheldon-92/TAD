#!/bin/bash
# AC-01: tad-blake.md completion_protocol contains step3b_acceptance_verification
# (with violations, process, verification_quality)
FILE=".claude/commands/tad-blake.md"
PASS=0
TOTAL=4

grep -q "step3b:" "$FILE" && ((PASS++)) || echo "  MISSING: step3b in completion_protocol"
grep -q "step3b_acceptance_verification:" "$FILE" && ((PASS++)) || echo "  MISSING: step3b_acceptance_verification section"
grep -q "跳过验收验证直接进 Gate 3 = VIOLATION" "$FILE" && ((PASS++)) || echo "  MISSING: violations"
grep -q "verification_quality:" "$FILE" && ((PASS++)) || echo "  MISSING: verification_quality"

if [ "$PASS" -eq "$TOTAL" ]; then
  echo "PASS: step3b_acceptance_verification complete ($PASS/$TOTAL checks)"
  exit 0
else
  echo "FAIL: step3b_acceptance_verification incomplete ($PASS/$TOTAL checks)"
  exit 1
fi
