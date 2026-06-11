#!/usr/bin/env bash
# AI Agent Architecture Capability Pack Installer
# Installs the capability into the appropriate AI agent's skills directory.
# Usage:
#   ./install.sh [--agent=claude-code] [--dry-run]
#   ./install.sh --agent=codex          # Phase 3 stub (not yet implemented)
#   ./install.sh --agent=cursor         # Phase 3 stub (not yet implemented)
#   ./install.sh --agent=gemini         # Phase 3 stub (not yet implemented)

set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT="claude-code"
DRY_RUN=false
FORCE=false
ALLOW_GLOBAL=false

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --agent=*)
      AGENT="${arg#--agent=}"
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    --force)
      FORCE=true
      ;;
    --global)
      ALLOW_GLOBAL=true
      ;;
    --help|-h)
      echo "Usage: $0 [--agent=claude-code] [--dry-run] [--global]"
      echo ""
      echo "Options:"
      echo "  --agent=NAME   Target agent (claude-code [default], codex, cursor, gemini)"
      echo "  --global       Allow install to ~/.claude/ when no project .claude/ is found"
      echo "  --dry-run      Show what would be installed without making changes"
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg"
      echo "Run with --help for usage."
      exit 1
      ;;
  esac
done

install_pack() {
  local PLATFORM="${1:-claude-code}"
  if [[ "$PLATFORM" = "codex" ]]; then
    TARGET_DIR=".agents/skills/ai-agent-architecture"
  elif [[ -d ".claude" ]]; then
    TARGET_DIR=".claude/skills/ai-agent-architecture"
  elif [[ "$ALLOW_GLOBAL" = true ]] && [[ -d "$HOME/.claude" ]]; then
    TARGET_DIR="$HOME/.claude/skills/ai-agent-architecture"
  elif [[ -d "$HOME/.config/claude" ]]; then
    TARGET_DIR="$HOME/.config/claude/skills/ai-agent-architecture"
  else
    echo "✗ Claude Code not found. Run from your project root, or use --global." >&2
    exit 1
  fi

  echo "Agent:      $PLATFORM"
  echo "Source:     $PACK_DIR"
  echo "Target:     $TARGET_DIR"
  echo "Dry run:    $DRY_RUN"
  echo ""

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "DRY RUN — would install:"
    echo "  mkdir -p $TARGET_DIR/references"
    echo "  cp $PACK_DIR/SKILL.md -> $TARGET_DIR/SKILL.md"
    for f in "$PACK_DIR"/references/*.md; do
      echo "  cp $f -> $TARGET_DIR/references/$(basename "$f")"
    done
    echo "  cp $PACK_DIR/LICENSE -> $TARGET_DIR/LICENSE"
    echo "  cp $PACK_DIR/LICENSE-ATTRIBUTION.md -> $TARGET_DIR/LICENSE-ATTRIBUTION.md"
    echo ""
    echo "DRY RUN complete. No files written."
    exit 0
  fi

  # Install
  mkdir -p "$TARGET_DIR/references"
  cp "$PACK_DIR/SKILL.md" "$TARGET_DIR/SKILL.md"
  cp "$PACK_DIR"/references/*.md "$TARGET_DIR/references/"
  cp "$PACK_DIR/LICENSE" "$TARGET_DIR/LICENSE"
  cp "$PACK_DIR/LICENSE-ATTRIBUTION.md" "$TARGET_DIR/LICENSE-ATTRIBUTION.md"

  echo "Installation complete."
  echo ""
  echo "Installed files:"
  find "$TARGET_DIR" -name "*.md" | sort | while read -r f; do
    size=$(wc -l < "$f")
    echo "  $(basename "$f") ($size lines)"
  done
  echo ""
  echo "To use: In Claude Code, reference /ai-agent-architecture or"
  echo "        ask 'help me design an agent system' to activate /design mode"
}

# Route by agent type
case "$AGENT" in
  claude-code)
    install_pack "claude-code"
    ;;
  codex)
    install_pack "codex"
    ;;
  cursor)
    echo "Phase 3 stub: Cursor installation not yet implemented."
    echo "Expected target: ~/.cursor/rules/ai-agent-architecture/"
    echo "Expected install: copy CAPABILITY.md as .cursorrules integration"
    exit 2
    ;;
  gemini)
    echo "Phase 3 stub: Gemini installation not yet implemented."
    echo "Expected target: ~/gemini/skills/ai-agent-architecture/"
    exit 2
    ;;
  *)
    echo "Unknown agent: $AGENT"
    echo "Supported agents: claude-code, codex (Phase 3), cursor (Phase 3), gemini (Phase 3)"
    exit 1
    ;;
esac
