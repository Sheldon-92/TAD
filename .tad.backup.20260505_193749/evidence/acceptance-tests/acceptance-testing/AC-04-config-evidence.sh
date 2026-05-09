#!/bin/bash
# AC-04: config-quality.yaml gate3_v2 evidence contains acceptance-verification-report + verification-scripts
FILE=".tad/config-quality.yaml"
PASS=0
TOTAL=3

grep -q "acceptance_verification_evidence:" "$FILE" && ((PASS++)) || echo "  MISSING: acceptance_verification_evidence"
grep -q "acceptance-verification-report" "$FILE" && ((PASS++)) || echo "  MISSING: report pattern"
grep -q 'AC-\*' "$FILE" && ((PASS++)) || echo "  MISSING: scripts pattern"

if [ "$PASS" -eq "$TOTAL" ]; then
  echo "PASS: config-quality evidence complete ($PASS/$TOTAL)"
  exit 0
else
  echo "FAIL: config-quality evidence incomplete ($PASS/$TOTAL)"
  exit 1
fi
