#!/usr/bin/env bash
set -euo pipefail

test -f .tad/evidence/dual-platform-regression/T2-claude-code-compat.md
count=$(grep -ci 'verdict:.*PASS' .tad/evidence/dual-platform-regression/T2-claude-code-compat.md || true)
if [ "$count" -ge 1 ]; then
  echo "PASS AC3 count=$count"
  exit 0
fi
echo "FAIL AC3 count=$count"
exit 1
