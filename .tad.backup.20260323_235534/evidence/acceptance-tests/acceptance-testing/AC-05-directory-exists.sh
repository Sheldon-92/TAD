#!/bin/bash
# AC-05: .tad/evidence/acceptance-tests/ directory exists
if [ -d ".tad/evidence/acceptance-tests" ] && [ -f ".tad/evidence/acceptance-tests/.gitkeep" ]; then
  echo "PASS: acceptance-tests directory exists with .gitkeep"
  exit 0
else
  echo "FAIL: acceptance-tests directory or .gitkeep missing"
  exit 1
fi
