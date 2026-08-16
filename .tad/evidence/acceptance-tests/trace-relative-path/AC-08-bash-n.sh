#!/usr/bin/env bash
# AC8: bash -n on common.sh exits 0.
set -u
FIX="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(git -C "$FIX" rev-parse --show-toplevel)"
if bash -n "$ROOT/.tad/hooks/lib/common.sh"; then
  echo "AC8 PASS (bash -n common.sh)"
else
  echo "AC8 FAIL: bash -n reported syntax error" >&2; exit 1
fi