#!/usr/bin/env bash
set -euo pipefail

count=$(grep -ci 'release_readiness:' .tad/evidence/dual-platform-regression/ACCEPTANCE-SUMMARY.md || true)
if [ "$count" -ge 1 ]; then
  echo "PASS AC7 count=$count"
  exit 0
fi
echo "FAIL AC7 count=$count"
exit 1
