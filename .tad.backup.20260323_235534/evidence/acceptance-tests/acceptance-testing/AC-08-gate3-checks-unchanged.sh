#!/bin/bash
# AC-08: Gate 3 Critical Check 5 items unchanged
FILE=".claude/commands/tad-gate.md"
PASS=0
TOTAL=5

grep -q "Code complete (all handoff tasks done)" "$FILE" && PASS=$((PASS+1)) || echo "  MISSING: Code complete"
grep -q "Tests pass (no failing tests)" "$FILE" && PASS=$((PASS+1)) || echo "  MISSING: Tests pass"
grep -q "Standards met (linting, formatting)" "$FILE" && PASS=$((PASS+1)) || echo "  MISSING: Standards met"
grep -q "Evidence file exists" "$FILE" && PASS=$((PASS+1)) || echo "  MISSING: Evidence file"
grep -q "Knowledge Assessment complete" "$FILE" && PASS=$((PASS+1)) || echo "  MISSING: Knowledge Assessment"

if [ "$PASS" -eq "$TOTAL" ]; then
  echo "PASS: Gate 3 Critical Check unchanged ($PASS/$TOTAL)"
  exit 0
else
  echo "FAIL: Gate 3 Critical Check modified ($PASS/$TOTAL)"
  exit 1
fi
