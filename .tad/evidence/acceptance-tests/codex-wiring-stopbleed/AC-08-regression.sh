#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO="$(cd "$SCRIPT_DIR/../../../../" && pwd -P)"
cd "$REPO"
bash .tad/hooks/lib/skill-body-verify.sh >/dev/null
bash -n .tad/hooks/lib/release-verify.sh tad.sh
echo 'AC8 PASS: skill-body-verify and changed shell syntax checks'
