#!/usr/bin/env bash
# codex-tad-blake.sh — Launch Codex with Blake (Execution Master) TAD persona
# Usage: bash .tad/codex/codex-tad-blake.sh [--dry-run | --extract-only]
#
# Options:
#   --dry-run       Print SKILL file path + size, do not launch Codex
#   --extract-only  Print SKILL content to stdout, do not launch Codex

set -euo pipefail

# Detect project root (parent of .tad/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_FILE="$ROOT/.tad/codex/codex-blake-skill.md"

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
    echo "Blake SKILL: $SKILL_FILE"
    echo "Size: ${SKILL_SIZE} bytes"
    echo "(dry-run: Codex not launched)"
    exit 0
    ;;
  --extract-only)
    cat "$SKILL_FILE"
    exit 0
    ;;
  --help|-h)
    echo "Usage: bash .tad/codex/codex-tad-blake.sh [--dry-run | --extract-only]"
    echo ""
    echo "  --dry-run       Print SKILL path + size, do not launch Codex"
    echo "  --extract-only  Print SKILL content to stdout, do not launch Codex"
    echo ""
    echo "Default: launches Codex with Blake persona using codex exec --full-auto"
    echo "For file-write tasks (sandbox): omit --full-auto with interactive codex"
    exit 0
    ;;
esac

# Pre-flight write test (detect read-only sandbox)
# Use mktemp for a unique per-process path; fallback to /tmp/.tad-write-test.$$ if mktemp unavailable.
TEST_FILE="$(mktemp -t tad-write-test.XXXXXX 2>/dev/null || echo "/tmp/.tad-write-test.$$")"
SANDBOX_READONLY=false
if ! touch "$TEST_FILE" 2>/dev/null; then
  SANDBOX_READONLY=true
fi
rm -f "$TEST_FILE"  # always cleanup, regardless of touch result

if [ "$SANDBOX_READONLY" = true ]; then
  echo "⚠️  /tmp is not writable. Codex sandbox may be read-only."
  echo "   Blake file-write operations will likely fail."
  echo "   Alternative: Use interactive codex (without --full-auto) to approve writes manually."
  echo "   Launch: cat \"$SKILL_FILE\" | codex \"You are Blake (Execution Master). Follow the TAD protocol above.\""
  echo "   Or extract SKILL: bash \"$0\" --extract-only | less"
  echo "   Aborting --full-auto launch. Use interactive mode for write ops."
  exit 1
fi

# Change to project root (required by Codex — .tad/ must be present)
cd "$ROOT"

echo "Launching Codex with Blake persona..."
echo "SKILL: $SKILL_FILE (${SKILL_SIZE} bytes)"
echo ""

# Default launch: codex exec --full-auto (spike-proven, non-interactive)
# For file-write tasks where sandbox is not read-only, this works.
# If sandbox is read-only, user is warned above to use interactive mode instead.
cat "$SKILL_FILE" | codex exec --full-auto \
  "You are Blake (Execution Master). Follow the TAD protocol above. Check .tad/active/handoffs/ for pending work."
