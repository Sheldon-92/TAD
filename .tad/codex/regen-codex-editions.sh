#!/usr/bin/env bash
# regen-codex-editions.sh — Regenerate BOTH Codex editions atomically.
# Human-invoked (NOT called by *publish). Requires codex CLI.
# After success: review `git diff .tad/codex/` then commit manually.
# Exit: 0=both regenerated; 1=at least one failed (live editions UNTOUCHED).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

ALEX_SOURCE="$REPO_ROOT/.claude/skills/alex/SKILL.md"
BLAKE_SOURCE="$REPO_ROOT/.claude/skills/blake/SKILL.md"
ALEX_LIVE="$REPO_ROOT/.tad/codex/codex-alex-skill.md"
BLAKE_LIVE="$REPO_ROOT/.tad/codex/codex-blake-skill.md"
PARITY_CHECK="$REPO_ROOT/.tad/hooks/lib/codex-parity-check.sh"
REGEN_PROCEDURE="$REPO_ROOT/.tad/evidence/spikes/codex-parity/regen-procedure.md"

echo "========================================="
echo "REGEN CODEX EDITIONS (atomic)"
echo "========================================="
echo ""

# Preflight: codex available?
if ! command -v codex >/dev/null 2>&1; then
  echo "ERROR: codex CLI not found." >&2
  echo "" >&2
  echo "Escape valve:" >&2
  echo "  1. Install codex:  npm install -g @openai/codex" >&2
  echo "  2. OR hand-port per .tad/portable-rules.md (apply Strip->Replace manually)" >&2
  echo "" >&2
  echo "The *publish gate will continue to block on drift until editions are updated." >&2
  exit 1
fi

# Preflight: sources + check exist?
for f in "$ALEX_SOURCE" "$BLAKE_SOURCE" "$PARITY_CHECK" "$REGEN_PROCEDURE"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: required file missing: $f" >&2
    exit 1
  fi
done

# Create scratch files (same filesystem as live for atomic mv)
SCRATCH_ALEX=$(mktemp "$REPO_ROOT/.tad/codex/.regen-alex-XXXXXX")
SCRATCH_BLAKE=$(mktemp "$REPO_ROOT/.tad/codex/.regen-blake-XXXXXX")
trap 'rm -f "$SCRATCH_ALEX" "$SCRATCH_BLAKE"' EXIT

echo "--- Regenerating alex edition via codex exec ---"
echo "Read $REGEN_PROCEDURE and $ALEX_SOURCE. Follow the regen procedure to produce a Codex-edition of the alex SKILL. Write the output to $SCRATCH_ALEX. Write ONLY the raw Codex-edition content to that file, nothing else." \
  | codex exec --full-auto 2>/dev/null
ALEX_SIZE=$(wc -c < "$SCRATCH_ALEX" | tr -d ' ')
echo "  alex scratch: $ALEX_SIZE bytes"

echo "--- Regenerating blake edition via codex exec ---"
echo "Read $REGEN_PROCEDURE and $BLAKE_SOURCE. Follow the regen procedure to produce a Codex-edition of the blake SKILL. Write the output to $SCRATCH_BLAKE. Write ONLY the raw Codex-edition content to that file, nothing else." \
  | codex exec --full-auto 2>/dev/null
BLAKE_SIZE=$(wc -c < "$SCRATCH_BLAKE" | tr -d ' ')
echo "  blake scratch: $BLAKE_SIZE bytes"
echo ""

# Parity-check BOTH scratches before touching live
echo "--- Parity-checking alex scratch ---"
ALEX_OK=0
bash "$PARITY_CHECK" "$ALEX_SOURCE" "$SCRATCH_ALEX" > /dev/null 2>&1 && ALEX_OK=1
echo "  alex: $([ $ALEX_OK -eq 1 ] && echo 'PASS' || echo 'FAIL')"

echo "--- Parity-checking blake scratch ---"
BLAKE_OK=0
bash "$PARITY_CHECK" "$BLAKE_SOURCE" "$SCRATCH_BLAKE" > /dev/null 2>&1 && BLAKE_OK=1
echo "  blake: $([ $BLAKE_OK -eq 1 ] && echo 'PASS' || echo 'FAIL')"
echo ""

# BATCH mv only if BOTH pass — live untouched otherwise
if [ $ALEX_OK -eq 1 ] && [ $BLAKE_OK -eq 1 ]; then
  mv "$SCRATCH_ALEX" "$ALEX_LIVE"
  mv "$SCRATCH_BLAKE" "$BLAKE_LIVE"
  trap '' EXIT
  echo "========================================="
  echo "BOTH editions regenerated successfully."
  echo "Review:  git diff .tad/codex/"
  echo "Commit:  git add .tad/codex/ && git commit -m 'chore: regen codex editions to vX.Y.Z'"
  echo "========================================="
  exit 0
else
  DEBUG_ALEX="$REPO_ROOT/.tad/codex/.regen-debug-alex"
  DEBUG_BLAKE="$REPO_ROOT/.tad/codex/.regen-debug-blake"
  cp "$SCRATCH_ALEX" "$DEBUG_ALEX" 2>/dev/null || true
  cp "$SCRATCH_BLAKE" "$DEBUG_BLAKE" 2>/dev/null || true
  echo "========================================="
  echo "REGEN FAILED — live editions UNTOUCHED."
  [ $ALEX_OK -eq 0 ] && echo "  alex:  FAIL — debug: bash $PARITY_CHECK $ALEX_SOURCE $DEBUG_ALEX"
  [ $BLAKE_OK -eq 0 ] && echo "  blake: FAIL — debug: bash $PARITY_CHECK $BLAKE_SOURCE $DEBUG_BLAKE"
  echo ""
  echo "Scratch copies saved for debugging (rm manually after)."
  echo "========================================="
  exit 1
fi
