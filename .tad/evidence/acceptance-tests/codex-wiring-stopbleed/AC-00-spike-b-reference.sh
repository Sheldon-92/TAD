#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO="$(cd "$SCRIPT_DIR/../../../../" && pwd -P)"
REPORT="$REPO/.tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-b-report.md"

grep -Fq '**PASS.**' "$REPORT"
grep -Fq 'Claude Code — direct Read sequence' "$REPORT"
grep -Fq 'Codex — direct file-reader sequence' "$REPORT"
grep -Fq 'No Glob/Grep/Bash/find/search fallback' "$REPORT"
echo 'AC0 PASS: Spike B has direct-read evidence for both platforms'
