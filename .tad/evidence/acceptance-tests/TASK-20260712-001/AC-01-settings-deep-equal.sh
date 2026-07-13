#!/usr/bin/env bash
# AC1: settings.local.json only gained autoMemoryDirectory; permissions deep-equal
cd "$(git rev-parse --show-toplevel)"
BEFORE=.tad/evidence/ralph-loops/TASK-20260712-001-ac1-permissions-before.json
jq -S .permissions .claude/settings.local.json > /tmp/ac1-after.json
diff "$BEFORE" /tmp/ac1-after.json || exit 1
V=$(jq -r '.autoMemoryDirectory' .claude/settings.local.json)
case "$V" in /*".tad/memory") echo "AC1 PASS: permissions deep-equal; autoMemoryDirectory=$V"; exit 0;; *) echo "AC1 FAIL: $V"; exit 1;; esac
