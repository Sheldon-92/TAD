#!/usr/bin/env bash
# codex-tad-alex.sh — Launch Codex with Alex (Solution Lead) TAD persona
# Usage: bash .tad/codex/codex-tad-alex.sh [--dry-run | --extract-only]
#
# Options:
#   --dry-run       Print SKILL file path + size, do not launch Codex
#   --extract-only  Print SKILL content to stdout, do not launch Codex

set -euo pipefail

# Detect project root (parent of .tad/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_FILE="$ROOT/.tad/codex/codex-alex-skill.md"

# Validate SKILL file exists
if [ ! -f "$SKILL_FILE" ]; then
  echo "ERROR: SKILL file not found: $SKILL_FILE" >&2
  echo "Run from project root containing .tad/" >&2
  exit 1
fi

SKILL_SIZE=$(wc -c < "$SKILL_FILE")

# Parse flags
case "${1:-}" in
  --dry-run)
    echo "Alex SKILL: $SKILL_FILE"
    echo "Size: ${SKILL_SIZE} bytes"
    echo "(dry-run: Codex not launched)"
    exit 0
    ;;
  --extract-only)
    cat "$SKILL_FILE"
    exit 0
    ;;
  --help|-h)
    echo "Usage: bash .tad/codex/codex-tad-alex.sh [--dry-run | --extract-only]"
    echo ""
    echo "  --dry-run       Print SKILL path + size, do not launch Codex"
    echo "  --extract-only  Print SKILL content to stdout, do not launch Codex"
    echo ""
    echo "Default: launches Codex with Alex persona using codex exec --full-auto"
    echo "Alex is read-only (design only, no implementation) — --full-auto is safe."
    exit 0
    ;;
esac

# Change to project root (required by Codex — .tad/ must be present)
cd "$ROOT"

echo "Launching Codex with Alex persona..."
echo "SKILL: $SKILL_FILE (${SKILL_SIZE} bytes)"
echo ""

# Alex is always launched with codex exec --full-auto:
# Alex is read-only (no file writes needed for design/analysis).
# Blake launcher uses interactive mode as fallback for write ops, Alex does not need it.
cat "$SKILL_FILE" | codex exec --full-auto \
  "You are Alex (Solution Lead). Follow the TAD protocol above. Check .tad/active/session-state.md and .tad/active/handoffs/ for context."
