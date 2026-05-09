#!/bin/bash
# AC-02: tad-blake.md mandatory rules contains acceptance_verification
if grep -q "acceptance_verification:" .claude/commands/tad-blake.md && \
   grep -q "MUST generate and execute" .claude/commands/tad-blake.md; then
  echo "PASS: mandatory rules contains acceptance_verification"
  exit 0
else
  echo "FAIL: mandatory rules missing acceptance_verification"
  exit 1
fi
