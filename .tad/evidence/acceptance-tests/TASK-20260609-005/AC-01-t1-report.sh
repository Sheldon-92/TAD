#!/usr/bin/env bash
set -euo pipefail

test -f .tad/evidence/codex-regression/T1-full-cycle-v0.137.0.md
count=$(grep -ci 'verdict:.*PASS' .tad/evidence/codex-regression/T1-full-cycle-v0.137.0.md || true)
if [ "$count" -ge 1 ]; then
  echo "PASS AC1 count=$count"
  exit 0
fi
echo "FAIL AC1 count=$count"
exit 1
