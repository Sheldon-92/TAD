#!/usr/bin/env bash
# verify-prereqs.sh — Verify the Step-0 pack prerequisites with explicit exit codes.
#
# Wraps the SKILL.md Step 0 verify line
#   (ffmpeg -version && node --version && npx hyperframes --version)
# into a deterministic preflight so an agent never starts a composition against a
# missing/under-version toolchain (per QUALITY-BAR A10: deterministic ops to code).
#
# Usage:   bash scripts/verify-prereqs.sh            # HyperFrames default
#          bash scripts/verify-prereqs.sh --remotion # check Remotion instead
#
# Pinned versions (verified 2026-06-14 — refresh on tool-freshness review):
#   Node.js   >= 22         (HyperFrames + Remotion runtime floor)
#   HyperFrames CLI         v0.6.97   (heygen-com/hyperframes, still current 2026-06-14)
#   Remotion                v4.0.477  (latest stable 2026-06-14, supersedes 4.0.447)
#
# Exit codes:
#   0  — all required prereqs present and meet the version floor
#   1  — ffmpeg missing
#   2  — node missing or below v22
#   3  — composition CLI (hyperframes / remotion) missing
#
# Requirements: bash, the tools being checked. No npm install, no Windows paths.

set -uo pipefail

ENGINE="hyperframes"
if [ "${1:-}" = "--remotion" ]; then
  ENGINE="remotion"
fi

NODE_MIN_MAJOR=22
HYPERFRAMES_PINNED="0.6.97"   # verified 2026-06-13
REMOTION_PINNED="4.0.477"     # verified 2026-06-14 (latest stable)

echo "=== Video-Creation Prereq Check (engine: $ENGINE) ==="

# 1) FFmpeg ────────────────────────────────────────────────────────────────
if command -v ffmpeg >/dev/null 2>&1; then
  ver="$(ffmpeg -version 2>/dev/null | head -1)"
  echo "✓ ffmpeg: $ver"
else
  echo "✗ ffmpeg not found. Install: brew install ffmpeg  (macOS) / apt-get install ffmpeg (Debian)" >&2
  exit 1
fi

# 2) Node.js >= 22 ───────────────────────────────────────────────────────────
if command -v node >/dev/null 2>&1; then
  node_raw="$(node --version 2>/dev/null)"          # e.g. v22.3.0
  node_major="${node_raw#v}"; node_major="${node_major%%.*}"
  if [ -n "$node_major" ] && [ "$node_major" -ge "$NODE_MIN_MAJOR" ] 2>/dev/null; then
    echo "✓ node: $node_raw (>= v${NODE_MIN_MAJOR})"
  else
    echo "✗ node $node_raw is below the v${NODE_MIN_MAJOR} floor. Upgrade: nvm install ${NODE_MIN_MAJOR}" >&2
    exit 2
  fi
else
  echo "✗ node not found. Install Node.js >= ${NODE_MIN_MAJOR}: https://nodejs.org / nvm install ${NODE_MIN_MAJOR}" >&2
  exit 2
fi

# 3) Composition CLI ─────────────────────────────────────────────────────────
if [ "$ENGINE" = "remotion" ]; then
  if npx --no-install remotion --version >/dev/null 2>&1 || npx remotion --version >/dev/null 2>&1; then
    rv="$(npx remotion --version 2>/dev/null | tail -1)"
    echo "✓ remotion: ${rv:-installed} (pinned reference v${REMOTION_PINNED})"
  else
    echo "✗ remotion CLI not available. Add it: npm i remotion@${REMOTION_PINNED}" >&2
    exit 3
  fi
else
  if npx --no-install hyperframes --version >/dev/null 2>&1 || npx hyperframes --version >/dev/null 2>&1; then
    hv="$(npx hyperframes --version 2>/dev/null | tail -1)"
    echo "✓ hyperframes: ${hv:-installed} (pinned reference v${HYPERFRAMES_PINNED})"
  else
    echo "✗ hyperframes CLI not available. Add it: npm i -g hyperframes@${HYPERFRAMES_PINNED} OR npx hyperframes@${HYPERFRAMES_PINNED}" >&2
    exit 3
  fi
fi

echo ""
echo "✓ PASS — all prereqs for the $ENGINE workflow are present. Safe to scaffold."
exit 0
