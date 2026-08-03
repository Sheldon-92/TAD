#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO="$(cd "$SCRIPT_DIR/../../../../" && pwd -P)"
SPIKE="$REPO/.tad/evidence/acceptance-tests/codex-wiring-stopbleed"

test -f "$SPIKE/spike-codex-home/config.toml"
git -C "$SPIKE/spike-work" rev-parse --verify HEAD >/dev/null
grep -Fq 'unknown field `SessionStart`, expected `description` or `hooks`' "$SPIKE/spike-a-report.md"
grep -Fq 'same command returned no hooks parse error' "$SPIKE/spike-a-report.md"
echo 'AC1 PASS: real-session old-schema warning and accepted candidate evidence recorded'
