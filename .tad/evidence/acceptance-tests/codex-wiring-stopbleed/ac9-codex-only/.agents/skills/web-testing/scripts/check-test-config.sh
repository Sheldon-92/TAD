#!/usr/bin/env bash
# check-test-config.sh — Assert a Vitest config declares PER-MODULE coverage thresholds
#                        (not a single global-only target).
#
# Why this exists (Rule S2 / U4): a single global `coverage.thresholds.lines: 80` hides
# auth at 40% behind getters at 100%. Per-module targets (auth 90 / logic 80 / UI 60) are
# the pack's specific rule. This is a deterministic structural check — not a "punt to Claude".
#
# Usage: bash scripts/check-test-config.sh [vitest.config.ts|vitest.config.js|path]
#        Default: searches CWD for vitest.config.{ts,js,mts,mjs}
#
# Exit 0: per-module (glob-scoped) thresholds found
# Exit 1: only a global-flat threshold found (or no thresholds at all)
# Exit 2: no config file found / bad usage

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Usage: bash scripts/check-test-config.sh [vitest.config.ts]"
  echo "  Asserts per-module coverage thresholds (auth 90 / logic 80 / UI 60), NOT global-only."
  echo "  Exit 0 = per-module thresholds present | 1 = global-only | 2 = no config"
  exit 0
fi

CONFIG="${1:-}"
if [[ -z "$CONFIG" ]]; then
  for f in vitest.config.ts vitest.config.js vitest.config.mts vitest.config.mjs vite.config.ts; do
    if [[ -f "$f" ]]; then CONFIG="$f"; break; fi
  done
fi

if [[ -z "$CONFIG" || ! -f "$CONFIG" ]]; then
  echo "✗ No Vitest config found (looked for vitest.config.{ts,js,mts,mjs})." >&2
  echo "  Pass an explicit path: bash scripts/check-test-config.sh path/to/vitest.config.ts" >&2
  exit 2
fi

echo "=== Coverage Threshold Check: $CONFIG ==="
echo ""

# Does the config even declare a coverage.thresholds block?
if ! grep -qE 'thresholds' "$CONFIG"; then
  echo "✗ FAIL — no coverage 'thresholds' block found."
  echo "  -> Add per-module thresholds (Rule S2): auth 90 / logic 80 / UI 60."
  exit 1
fi

# Per-module thresholds use glob keys like 'src/auth/**' or 'src/**/*.ts' as object keys.
# A global-only config has thresholds directly holding lines/branches with no glob key.
# Heuristic: count quoted glob keys (contain a slash or a '*') that sit inside the config.
GLOB_KEYS=$(grep -oE "['\"][^'\"]*[*/][^'\"]*['\"][[:space:]]*:" "$CONFIG" | grep -cE "[*/]" || true)

# Flag the specific recommended tiers if present (informational, not required to pass).
HAS_AUTH=$(grep -ciE "auth.*: ?\{?.*(9[0-9]|100)" "$CONFIG" || true)

if [[ "${GLOB_KEYS:-0}" -ge 2 ]]; then
  echo "✓ PASS — $GLOB_KEYS glob-scoped (per-module) threshold key(s) found."
  echo "  Per-module targets defeat the 'global 80% lie' (Rule S2 / U4)."
  if [[ "${HAS_AUTH:-0}" -ge 1 ]]; then
    echo "  ✓ A high-risk (auth-like) module is held to >=90%."
  else
    echo "  ℹ Confirm critical modules (auth/payments) are at 90%, not 60-80%."
  fi
  exit 0
else
  echo "✗ FAIL — coverage thresholds look global-only ($GLOB_KEYS glob-scoped key(s) found; need >=2)."
  echo "  A single flat target hides untested critical code behind tested trivial code."
  echo "  -> Set per-module thresholds (Rule S2):"
  echo "       'src/auth/**':       { lines: 90, branches: 85 }"
  echo "       'src/lib/**':        { lines: 80, branches: 75 }"
  echo "       'src/components/**': { lines: 60, branches: 50 }"
  exit 1
fi
