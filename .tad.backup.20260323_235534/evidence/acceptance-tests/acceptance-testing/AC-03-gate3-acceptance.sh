#!/bin/bash
# AC-03: tad-gate.md Gate 3 contains Acceptance_Verification (blocking, if_missing, if_exists.checks)
FILE=".claude/commands/tad-gate.md"
PASS=0
TOTAL=4

grep -q "Acceptance_Verification:" "$FILE" && ((PASS++)) || echo "  MISSING: Acceptance_Verification section"
grep -q "BLOCK Gate 3" "$FILE" && ((PASS++)) || echo "  MISSING: blocking action"
grep -q "if_missing:" "$FILE" && ((PASS++)) || echo "  MISSING: if_missing"
grep -q "报告中 FAIL 数量 = 0" "$FILE" && ((PASS++)) || echo "  MISSING: if_exists.checks"

if [ "$PASS" -eq "$TOTAL" ]; then
  echo "PASS: Gate 3 Acceptance_Verification complete ($PASS/$TOTAL)"
  exit 0
else
  echo "FAIL: Gate 3 Acceptance_Verification incomplete ($PASS/$TOTAL)"
  exit 1
fi
