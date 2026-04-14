#!/bin/bash
# Experiment 3 — Basic evidence structure validator
# Input:  $1 = path to a .md file
# Check:  file exists + size > 100 bytes + contains ^Overall: (PASS|FAIL)$
# Output: exit 0 valid / exit 1 invalid (reason on stderr)
#
# NOTE: This is Phase 1a mechanism-existence check.
# Forgery resistance (padding/stale/copy-paste/symlink) is Phase 1b scope.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "FAIL: usage: $0 <path-to-md>" >&2
  exit 1
fi

file="$1"

if [ ! -f "$file" ]; then
  echo "FAIL: file not found: $file" >&2
  exit 1
fi

size=$(wc -c < "$file" | tr -d ' ')

# AC §8.3 EC3: strictly > 100 (not >=). 100 bytes exactly = invalid.
if [ "$size" -le 100 ]; then
  echo "FAIL: too small ($size bytes, need > 100)" >&2
  exit 1
fi

# Line-anchored + word-anchored match. grep -E, no -P (BSD grep).
if ! grep -qE '^Overall: (PASS|FAIL)$' "$file"; then
  echo "FAIL: missing '^Overall: (PASS|FAIL)\$' line" >&2
  exit 1
fi

exit 0
