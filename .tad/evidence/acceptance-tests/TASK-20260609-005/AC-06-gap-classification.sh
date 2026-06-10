#!/usr/bin/env bash
set -euo pipefail

count=$(grep -ciE 'protocol_bug|adapter_bug|documentation_bug|accepted_limitation|process_blemish|deferred' .tad/evidence/dual-platform-regression/ACCEPTANCE-SUMMARY.md || true)
if [ "$count" -ge 1 ]; then
  echo "PASS AC6 count=$count"
  exit 0
fi
echo "FAIL AC6 count=$count"
exit 1
