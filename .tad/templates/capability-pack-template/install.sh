#!/bin/bash
# {{Pack Name}} Capability Pack Installer
# Usage: bash install.sh [--agent=claude-code|codex|cursor] [--force] [--dry-run]
set -euo pipefail

PACK_NAME="{{pack-name}}"
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"

# Parse flags
AGENT="claude-code"
FORCE=false
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --agent=*) AGENT="${arg#--agent=}" ;;
    --force) FORCE=true ;;
    --dry-run) DRY_RUN=true ;;
    --help) echo "Usage: bash install.sh [--agent=claude-code|codex|cursor] [--force] [--dry-run]"; exit 0 ;;
  esac
done

echo "=== ${PACK_NAME} Capability Pack Installer ==="
echo "Pack location: ${PACK_DIR}"
echo ""

# Determine target directory based on agent
case "$AGENT" in
  claude-code|claude)
    if [ -d ".claude" ]; then
      TARGET_DIR=".claude/skills/${PACK_NAME}"
    elif [ -d "$HOME/.claude" ]; then
      TARGET_DIR="$HOME/.claude/skills/${PACK_NAME}"
    else
      echo "❌ No .claude/ directory found. Run from a Claude Code project root."
      exit 1
    fi
    ;;
  codex)
    echo "⚠️  Codex: Add pack reference to AGENTS.md manually."
    echo "   Path: .claude/skills/${PACK_NAME}/SKILL.md"
    TARGET_DIR=".claude/skills/${PACK_NAME}"
    ;;
  cursor)
    TARGET_DIR=".cursor/rules/${PACK_NAME}"
    ;;
  *)
    echo "❌ Unknown agent: ${AGENT}. Supported: claude-code, codex, cursor"
    exit 1
    ;;
esac

echo "Target: ${TARGET_DIR}/"
echo ""

# Build file map: source:destination
declare -a FILE_MAP=(
  "CAPABILITY.md:${TARGET_DIR}/SKILL.md"
  "LICENSE:${TARGET_DIR}/LICENSE"
)

# Add all reference files
if [ -d "${PACK_DIR}/references" ]; then
  for ref in "${PACK_DIR}/references/"*.md; do
    [ -f "$ref" ] || continue
    ref_name=$(basename "$ref")
    FILE_MAP+=("references/${ref_name}:${TARGET_DIR}/references/${ref_name}")
  done
fi

# Dry-run mode
if [ "$DRY_RUN" = true ]; then
  echo "[DRY RUN] Would install ${#FILE_MAP[@]} files:"
  for entry in "${FILE_MAP[@]}"; do
    src="${entry%%:*}"
    dst="${entry##*:}"
    echo "  ${src} → ${dst}"
  done
  exit 0
fi

# Install files
mkdir -p "${TARGET_DIR}/references" 2>/dev/null || true
INSTALLED=0
for entry in "${FILE_MAP[@]}"; do
  src="${entry%%:*}"
  dst="${entry##*:}"
  src_path="${PACK_DIR}/${src}"

  if [ ! -f "$src_path" ]; then
    continue
  fi

  if [ -f "$dst" ] && [ "$FORCE" = false ]; then
    echo "  [skip] ${dst} (exists, use --force)"
    continue
  fi

  cp "$src_path" "$dst"
  echo "  ✓ Installed: ${dst}"
  INSTALLED=$((INSTALLED + 1))
done

echo ""
echo "=== Installation complete ==="
echo "  Installed: ${INSTALLED} files"
echo ""
echo "SKILL.md available at: ${TARGET_DIR}/SKILL.md"
