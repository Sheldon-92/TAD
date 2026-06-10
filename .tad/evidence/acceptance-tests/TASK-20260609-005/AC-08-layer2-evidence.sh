#!/usr/bin/env bash
set -euo pipefail

count=$(find .tad/evidence/codex-regression .tad/evidence/dual-platform-regression \( -name '*review*' -o -name '*layer2*' \) | wc -l | awk '{print $1}')
if [ "$count" -ge 1 ]; then
  echo "PASS AC8 count=$count"
  exit 0
fi
echo "FAIL AC8 count=$count"
exit 1
