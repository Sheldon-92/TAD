#!/bin/bash
# AC-06: acceptance-verification-guide.md exists with verification type table + naming + quality + examples
FILE=".tad/templates/acceptance-verification-guide.md"
PASS=0
TOTAL=5

[ -f "$FILE" ] && PASS=$((PASS+1)) || { echo "FAIL: guide file missing"; exit 1; }
grep -q "Verification Type Selection" "$FILE" && PASS=$((PASS+1)) || echo "  MISSING: verification type table"
grep -q "Naming Convention" "$FILE" && PASS=$((PASS+1)) || echo "  MISSING: naming convention"
grep -q "Quality Requirements" "$FILE" && PASS=$((PASS+1)) || echo "  MISSING: quality requirements"
grep -q "Common Verification Patterns" "$FILE" && PASS=$((PASS+1)) || echo "  MISSING: examples"

if [ "$PASS" -eq "$TOTAL" ]; then
  echo "PASS: guide complete ($PASS/$TOTAL sections)"
  exit 0
else
  echo "FAIL: guide incomplete ($PASS/$TOTAL sections)"
  exit 1
fi
