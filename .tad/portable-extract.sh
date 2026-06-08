#!/usr/bin/env bash
# portable-extract.sh — Copy TAD portable files to codex-tad-bundle/ for use on Codex CLI
# Usage: bash .tad/portable-extract.sh [--dry-run]
# Output: ./codex-tad-bundle/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/codex-tad-bundle"
DRY_RUN=false

# Parse flags
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --help|-h)
      echo "Usage: bash .tad/portable-extract.sh [--dry-run]"
      echo "  --dry-run   Print files that would be copied, do not copy"
      exit 0
      ;;
  esac
done

# Portable file list (per .tad/portable-rules.md classification)
PORTABLE_FILES=(
  # Config (Portable)
  ".tad/config.yaml"
  ".tad/config-agents.yaml"
  ".tad/config-quality.yaml"
  ".tad/config-workflow.yaml"
  ".tad/config-execution.yaml"
  ".tad/config-platform.yaml"
  ".tad/config-cognitive.yaml"
  ".tad/portable-rules.md"

  # Templates (Portable)
  ".tad/templates/handoff-a-to-b.md"
  ".tad/templates/completion-report.md"
  ".tad/templates/session-state-template.md"

  # Hooks lib (Portable — run manually on Codex)
  ".tad/hooks/lib/gate3-git-tracked-check.sh"
  ".tad/hooks/lib/layer2-audit.sh"
  ".tad/hooks/lib/drift-check.sh"
  ".tad/hooks/lib/stale-knowledge-check.sh"
  ".tad/hooks/lib/common.sh"

  # Domains (Portable)
  ".tad/domains/"

  # Codex migration readme
  ".tad/codex/"
)

if [ "$DRY_RUN" = true ]; then
  echo "DRY RUN — files that would be copied to $OUTPUT_DIR:"
  echo ""
fi

copy_count=0
skip_count=0

for item in "${PORTABLE_FILES[@]}"; do
  src="$PROJECT_ROOT/$item"
  if [ ! -e "$src" ]; then
    echo "  ⚠️  SKIP (not found): $item"
    skip_count=$((skip_count + 1))
    continue
  fi

  dst="$OUTPUT_DIR/$item"

  if [ "$DRY_RUN" = true ]; then
    echo "  COPY: $item"
    copy_count=$((copy_count + 1))
    continue
  fi

  mkdir -p "$(dirname "$dst")"
  if [ -d "$src" ]; then
    cp -r "$src" "$dst"
  else
    cp "$src" "$dst"
  fi
  copy_count=$((copy_count + 1))
done

echo ""
echo "Summary: $copy_count files/dirs copied, $skip_count skipped"

if [ "$DRY_RUN" = false ]; then
  echo "Output: $OUTPUT_DIR"
  echo ""
  echo "Quick start on Codex:"
  echo "  cd <project-root>"
  echo "  bash tad.sh --platform codex --yes    # Install for Codex"
  echo "  # Then say '当 Alex' or '当 Blake' in Codex (AGENTS.md auto-loads)"
fi
