#!/usr/bin/env bash
# install.sh — Web Frontend Capability Pack installer
# Installs judgment rules for AI agents to write production-grade React code
#
# Usage:
#   bash install.sh                         # Install project-local (default)
#   bash install.sh --agent=codex     # Explicit Codex install
#   bash install.sh --global               # Install to ~/.agents/ (all projects)
#   bash install.sh --dry-run               # Show what would be installed, don't copy
#   bash install.sh --agent=codex           # Phase 3 (not yet implemented)

set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT="codex"
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
      echo "Web Frontend Capability Pack — Installer"
      echo ""
      echo "Usage:"
      echo "  bash install.sh [--agent=AGENT] [--dry-run] [--global]"
      echo ""
      echo "Supported agents:"
      echo "  codex    Codex CLI (default)"
      echo "  codex          OpenAI Codex CLI (Phase 3 — not yet available)"
      echo "  cursor         Cursor IDE (Phase 3 — not yet available)"
      echo "  gemini         Gemini CLI (Phase 3 — not yet available)"
      echo ""
      echo "Options:"
      echo "  --global       Allow install to ~/.agents/ when no project .agents/ is found"
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

install_pack() {
  local PLATFORM="${1:-codex}"
  if [[ "$PLATFORM" = "codex" ]]; then
    SKILLS_ROOT=".agents"
    echo "✓ Codex install — target .agents/skills/"
  elif [[ -d ".agents" ]]; then
    SKILLS_ROOT=".agents"
    echo "✓ .agents/ detected — Codex project install"
  elif [[ "$ALLOW_GLOBAL" = true ]] && [[ -d "${HOME}/.agents" ]]; then
    SKILLS_ROOT="${HOME}/.agents"
    echo "✓ ~/.agents/ detected — Codex global install (--global flag set)"
  elif [[ -d "${HOME}/.agents" ]]; then
    echo "ℹ No .agents/ in current directory. Found ~/.agents/ — use --global to install globally, or cd to your project first." >&2
    exit 1
  else
    echo "✗ Codex not found (.agents/ or ~/.agents/ missing)." >&2
    exit 1
  fi
  TARGET_DIR="${SKILLS_ROOT}/skills/web-frontend"

  echo "Web Frontend Capability Pack — Installing for Codex"
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

  if [[ -d "$TARGET_DIR" ]] && [[ "$FORCE" = false ]]; then
    echo "⚠️  Existing installation found at $TARGET_DIR"
    echo "   Use --force to overwrite."
    exit 0
  fi

  # Create target directory structure
  mkdir -p "$TARGET_DIR/references"
  mkdir -p "$TARGET_DIR/checklists"
  mkdir -p "$TARGET_DIR/scripts"

  # Copy files
  echo "Installing files..."

  # Main files
  cp "$PACK_DIR/SKILL.md" "$TARGET_DIR/SKILL.md"
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
  echo "Codex will now load the web-frontend skill automatically when you"
  echo "discuss component architecture, state management, design tokens, styling,"
  echo "performance, accessibility, or testing."
  echo ""
  echo "Verify installation:"
  echo "  head -5 $TARGET_DIR/SKILL.md"
  echo ""
  echo "Run validation scripts (requires running app):"
  echo "  bash $TARGET_DIR/scripts/lighthouse-check.sh http://localhost:3000"
  echo "  bash $TARGET_DIR/scripts/a11y-scan.sh http://localhost:3000"
  echo "  bash $TARGET_DIR/scripts/bundle-check.sh"
}

# Dispatch
case "$AGENT" in
  codex)
    install_pack "codex"
    ;;
  codex)
    install_pack "codex"
    ;;
  cursor)
    echo "INFO: Cursor IDE support is planned for Phase 3."
    echo "For now, use: bash install.sh --agent=codex"
    exit 2
    ;;
  gemini)
    echo "INFO: Gemini CLI support is planned for Phase 3."
    echo "For now, use: bash install.sh --agent=codex"
    exit 2
    ;;
  *)
    echo "ERROR: Unknown agent: $AGENT. Supported: codex, codex"
    exit 1
    ;;
esac
