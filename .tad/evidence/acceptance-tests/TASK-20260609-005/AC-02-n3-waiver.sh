#!/usr/bin/env bash
set -euo pipefail

count=$(grep -ci 'n=3.*waiver\|waiver.*n=3\|stability.*waiver' .tad/evidence/dual-platform-regression/ACCEPTANCE-SUMMARY.md || true)
if [ "$count" -ge 1 ]; then
  echo "PASS AC2 count=$count"
  exit 0
fi
echo "FAIL AC2 count=$count"
exit 1
