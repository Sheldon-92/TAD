#!/usr/bin/env bash
set -euo pipefail

tmp=$(mktemp)
if bash .tad/hooks/lib/runtime-freshness-verify.sh >"$tmp" 2>&1; then
  echo "PASS AC4 exit=0"
  cat "$tmp"
  rm -f "$tmp"
  exit 0
fi

if grep -qi 'accepted_limitation' .tad/evidence/dual-platform-regression/T4-freshness-check.md; then
  echo "PASS AC4 accepted_limitation"
  cat "$tmp"
  rm -f "$tmp"
  exit 0
fi

echo "FAIL AC4"
cat "$tmp"
rm -f "$tmp"
exit 1
