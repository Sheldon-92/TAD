#!/usr/bin/env bash
set -euo pipefail
out=$(python3 research/scripts/search.py query "MCP prompt injection" --limit 3)
printf '%s\n' "$out" | grep -Eq 'research/(wiki|canon)/[^:]+:[0-9]+-[0-9]+'
echo 'AC1 PASS'
