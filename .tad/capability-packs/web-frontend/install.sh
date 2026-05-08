#!/usr/bin/env bash
# install.sh — Web Frontend Capability Pack installer
# Installs judgment rules for AI agents to write production-grade React code
#
# Usage:
#   bash install.sh                         # Install project-local (default)
#   bash install.sh --agent=claude-code     # Explicit Claude Code install
#   bash install.sh --global               # Install to ~/.claude/ (all projects)
#   bash install.sh --dry-run               # Show what would be installed, don't copy
#   bash install.sh --agent=codex           # Phase 3 (not yet implemented)

set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT="claude-code"
DRY_RUN=false
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
    --global)
      ALLOW_GLOBAL=true
      ;;
    --help|-h)
      echo "Web Frontend Capability Pack — Installer"
      echo ""
      echo "Usage:"
      echo "  bash install.sh [--agent=AGENT] [--dry-run] [--global]"
      echo ""
      echo "Supported agents:"
      echo "  claude-code    Claude Code CLI (default)"
      echo "  codex          OpenAI Codex CLI (Phase 3 — not yet available)"
      echo "  cursor         Cursor IDE (Phase 3 — not yet available)"
      echo "  gemini         Gemini CLI (Phase 3 — not yet available)"
      echo ""
      echo "Options:"
      echo "  --global       Allow install to ~/.claude/ when no project .claude/ is found"
      echo "  --dry-run      Show what would be installed without copying files"
      echo "  --help         Show this help"
      exit 0
      ;;
    *)
      echo "ERROR: Unknown argument: $arg"
      echo "Run 'bash install.sh --help' for usage."
      exit 1
      ;;
  esac
done

install_claude_code() {
  # Canonical project-local / global pattern (matches ai-prompt-engineering)
  if [[ -d ".claude" ]]; then
    CLAUDE_DIR=".claude"
    echo "✓ .claude/ detected — Claude Code project install"
  elif [[ "$ALLOW_GLOBAL" = true ]] && [[ -d "${HOME}/.claude" ]]; then
    CLAUDE_DIR="${HOME}/.claude"
    echo "✓ ~/.claude/ detected — Claude Code global install (--global flag set)"
  elif [[ -d "${HOME}/.claude" ]]; then
    echo "ℹ No .claude/ in current directory. Found ~/.claude/ — use --global to install globally, or cd to your project first." >&2
    exit 1
  else
    echo "✗ Claude Code not found (.claude/ or ~/.claude/ missing)." >&2
    exit 1
  fi
  TARGET_DIR="${CLAUDE_DIR}/skills/web-frontend"

  echo "Web Frontend Capability Pack — Installing for Claude Code"
  echo ""
  echo "Source: $PACK_DIR"
  echo "Target: $TARGET_DIR"
  echo ""

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "DRY RUN — No files will be copied."
    echo ""
    echo "Would create: $TARGET_DIR"
    echo ""
    echo "Would install:"
    find "$PACK_DIR" \( -name "*.md" -o -name "*.sh" \) \
      -not -path "*/node_modules/*" \
      -not -name "install.sh" \
      | sort | while read -r f; do
        echo "  ${f#"$PACK_DIR"/}"
      done
    echo ""
    echo "Run without --dry-run to install."
    return 0
  fi

  # Check for existing installation
  if [[ -d "$TARGET_DIR" ]]; then
    echo "⚠️  Existing installation found at $TARGET_DIR"
    read -r -p "Overwrite? [y/N] " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      echo "Installation cancelled."
      exit 0
    fi
  fi

  # Create target directory structure
  mkdir -p "$TARGET_DIR/references"
  mkdir -p "$TARGET_DIR/checklists"
  mkdir -p "$TARGET_DIR/scripts"

  # Copy files
  echo "Installing files..."

  # Main files
  cp "$PACK_DIR/CAPABILITY.md" "$TARGET_DIR/CAPABILITY.md"
  cp "$PACK_DIR/CONVENTIONS.md" "$TARGET_DIR/CONVENTIONS.md"
  cp "$PACK_DIR/README.md" "$TARGET_DIR/README.md"
  cp "$PACK_DIR/LICENSE" "$TARGET_DIR/LICENSE"
  cp "$PACK_DIR/LICENSE-ATTRIBUTION.md" "$TARGET_DIR/LICENSE-ATTRIBUTION.md"
  cp "$PACK_DIR/CHANGELOG.md" "$TARGET_DIR/CHANGELOG.md"

  # References
  cp "$PACK_DIR/references/"*.md "$TARGET_DIR/references/"

  # Checklists
  cp "$PACK_DIR/checklists/"*.md "$TARGET_DIR/checklists/"

  # Scripts
  cp "$PACK_DIR/scripts/"*.sh "$TARGET_DIR/scripts/"
  chmod +x "$TARGET_DIR/scripts/"*.sh

  echo ""
  echo "✅ Installation complete!"
  echo ""
  echo "Claude Code will now load the web-frontend skill automatically when you"
  echo "discuss component architecture, state management, design tokens, styling,"
  echo "performance, accessibility, or testing."
  echo ""
  echo "Verify installation:"
  echo "  head -5 $TARGET_DIR/CAPABILITY.md"
  echo ""
  echo "Run validation scripts (requires running app):"
  echo "  bash $TARGET_DIR/scripts/lighthouse-check.sh http://localhost:3000"
  echo "  bash $TARGET_DIR/scripts/a11y-scan.sh http://localhost:3000"
  echo "  bash $TARGET_DIR/scripts/bundle-check.sh"
}

# Dispatch
case "$AGENT" in
  claude-code)
    install_claude_code
    ;;
  codex)
    echo "INFO: Codex CLI support is planned for Phase 3 and is not yet implemented."
    echo ""
    echo "Phase 3 will install to: ~/.codex/skills/web-frontend/"
    echo "This includes: CAPABILITY.md adapted for Codex AGENTS.md routing"
    echo ""
    echo "For now, use: bash install.sh --agent=claude-code"
    exit 2
    ;;
  cursor)
    echo "INFO: Cursor IDE support is planned for Phase 3 and is not yet implemented."
    echo ""
    echo "Phase 3 will install to: .cursor/rules/ as .cursorrules file"
    echo "This includes: rules condensed into Cursor-compatible format"
    echo ""
    echo "For now, use: bash install.sh --agent=claude-code"
    exit 2
    ;;
  gemini)
    echo "INFO: Gemini CLI support is planned for Phase 3 and is not yet implemented."
    echo ""
    echo "Phase 3 will install to: ~/.gemini/skills/web-frontend/"
    echo "This includes: CAPABILITY.md adapted for Gemini -p invocation"
    echo ""
    echo "For now, use: bash install.sh --agent=claude-code"
    exit 2
    ;;
  *)
    echo "ERROR: Unknown agent: $AGENT"
    echo ""
    echo "Supported agents: claude-code"
    echo "Planned (Phase 3): codex, cursor, gemini"
    echo ""
    echo "Run 'bash install.sh --help' for usage."
    exit 1
    ;;
esac
