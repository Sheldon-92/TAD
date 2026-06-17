#!/usr/bin/env bash
# install.sh — Agent Computer Interface Capability Pack installer
# SINGLE-SOURCE COPY: copies from .claude/skills/agent-computer-interface/ (authoritative)
# Does NOT regenerate SKILL.md from a secondary source.
#
# Usage: bash install.sh [--dry-run] [--force] [--global] [--agent=claude-code|codex]

set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
FORCE=false
ALLOW_GLOBAL=false
AGENT="claude-code"

for arg in "$@"; do
  case "$arg" in
    --dry-run)     DRY_RUN=true ;;
    --force)       FORCE=true ;;
    --global)      ALLOW_GLOBAL=true ;;
    --agent=*)     AGENT="${arg#--agent=}" ;;
    --help|-h)
      echo "Usage: bash install.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --dry-run          Show what would be installed without writing files"
      echo "  --force            Overwrite existing files without warning"
      echo "  --global           Allow install to ~/.claude/ when no project .claude/ is found"
      echo "  --agent=NAME       Agent to install for (default: claude-code)"
      echo "                     Supported: claude-code, codex"
      exit 0
      ;;
    *)
      echo "Unknown flag: $arg. Run with --help for usage." >&2
      exit 1
      ;;
  esac
done

PACK_NAME="agent-computer-interface"
echo "=== ${PACK_NAME} Capability Pack Installer ==="

# Locate the authoritative source (single source of truth)
# PACK_DIR = .tad/capability-packs/{pack}/ → project root is 3 levels up
# Source is .claude/skills/{pack}/ in the same project
PROJECT_ROOT=""
# .tad/ is 2 levels up from PACK_DIR; config.yaml lives in .tad/
if [ -f "${PACK_DIR}/../../config.yaml" ]; then
  PROJECT_ROOT="$(cd "${PACK_DIR}/../../.." && pwd)"
fi

SKILL_SOURCE=""
if [ -n "$PROJECT_ROOT" ] && [ -f "${PROJECT_ROOT}/.claude/skills/${PACK_NAME}/SKILL.md" ]; then
  SKILL_SOURCE="${PROJECT_ROOT}/.claude/skills/${PACK_NAME}"
elif [ -f ".claude/skills/${PACK_NAME}/SKILL.md" ]; then
  # Running from project root directly
  SKILL_SOURCE="$(pwd)/.claude/skills/${PACK_NAME}"
else
  echo "Error: Cannot find authoritative source for ${PACK_NAME}" >&2
  echo "Expected: .claude/skills/${PACK_NAME}/SKILL.md relative to project root" >&2
  echo "Hint: Run from project root or ensure .claude/skills/${PACK_NAME}/ exists" >&2
  exit 1
fi

echo "Source: ${SKILL_SOURCE}"

# Agent routing
case "$AGENT" in
  claude-code|claude|codex)
    ;;
  *)
    echo "Unknown agent: $AGENT. Supported: claude-code, codex" >&2
    exit 1
    ;;
esac

# Detect install target
CLAUDE_DIR=""
if [ "$AGENT" = "codex" ]; then
  if [ -d ".agents" ]; then
    CLAUDE_DIR=".agents"
  else
    echo "Error: .agents/ directory not found for codex agent" >&2
    exit 1
  fi
elif [ -d ".claude" ]; then
  CLAUDE_DIR=".claude"
elif [ "$ALLOW_GLOBAL" = true ] && [ -d "$HOME/.claude" ]; then
  CLAUDE_DIR="$HOME/.claude"
else
  echo "Error: .claude/ not found. Run from project root or use --global." >&2
  exit 1
fi

TARGET_DIR="${CLAUDE_DIR}/skills/${PACK_NAME}"
echo "Target: ${TARGET_DIR}/"
echo ""

# Build copy manifest from source directory
if [ "$DRY_RUN" = true ]; then
  echo "=== DRY RUN — scanning source ==="
fi

# Create target directories
if [ "$DRY_RUN" = false ]; then
  mkdir -p "${TARGET_DIR}/references" "${TARGET_DIR}/scripts" "${TARGET_DIR}/examples"
fi

INSTALLED=0
EXISTED=0

# Copy all files from source, preserving directory structure
while IFS= read -r src_file; do
  rel_path="${src_file#${SKILL_SOURCE}/}"
  dst_file="${TARGET_DIR}/${rel_path}"
  dst_dir="$(dirname "$dst_file")"

  if [ "$DRY_RUN" = true ]; then
    if [ -f "$dst_file" ]; then
      echo "  [exists] ${rel_path}"
      EXISTED=$((EXISTED + 1))
    else
      echo "  ${rel_path}"
      INSTALLED=$((INSTALLED + 1))
    fi
    continue
  fi

  mkdir -p "$dst_dir"

  if [ -f "$dst_file" ] && [ "$FORCE" = false ]; then
    echo "  ! Skipped (exists, use --force): ${rel_path}"
    EXISTED=$((EXISTED + 1))
    continue
  fi

  cp "$src_file" "$dst_file"
  echo "  ✓ Installed: ${rel_path}"
  INSTALLED=$((INSTALLED + 1))
done < <(find "$SKILL_SOURCE" -type f -not -name '.*' | sort)

# Make scripts executable
if [ "$DRY_RUN" = false ]; then
  chmod +x "${TARGET_DIR}/scripts/"*.sh 2>/dev/null || true
fi

echo ""
if [ "$DRY_RUN" = true ]; then
  echo "=== DRY RUN complete — no files written ==="
  echo "  Would install: ${INSTALLED} files"
  echo "  Already exist: ${EXISTED} files (use --force to overwrite)"
else
  echo "=== Installation complete ==="
  echo "  Installed: ${INSTALLED} files"
  echo "  Skipped (exists): ${EXISTED} files (use --force to overwrite)"
  echo ""
  echo "SKILL.md: ${TARGET_DIR}/SKILL.md"
  echo ""
  echo "To activate: mention 'agent-computer-interface' or browser/automation keywords in conversation."
fi
