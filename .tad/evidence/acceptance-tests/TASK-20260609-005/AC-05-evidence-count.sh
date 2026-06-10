#!/usr/bin/env bash
set -euo pipefail

count=$(find .tad/evidence/codex-regression .tad/evidence/dual-platform-regression -name '*.md' | wc -l | awk '{print $1}')
if [ "$count" -ge 5 ]; then
  echo "PASS AC5 count=$count"
  exit 0
fi
echo "FAIL AC5 count=$count"
exit 1
