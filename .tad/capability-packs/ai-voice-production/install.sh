#!/usr/bin/env bash
# AI Voice Production Capability Pack installer
# Copies pack files to the target AI agent's skills directory

set -euo pipefail

PACK_NAME="ai-voice-production"
PACK_VERSION="0.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: bash install.sh [OPTIONS]

Options:
  --agent <name>    Target agent runtime (default: claude-code)
                    Supported: claude-code
                    Planned: codex, cursor, gemini (Phase 2)
  --target <path>   Override install target directory
  --check           Check tool prerequisites only, do not install
  --help            Show this message

Examples:
  bash install.sh                          # Install for Claude Code (default)
  bash install.sh --agent claude-code      # Explicit Claude Code
  bash install.sh --check                  # Check prerequisites only
EOF
  exit 0
}

# Parse arguments
AGENT="claude-code"
CUSTOM_TARGET=""
CHECK_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      AGENT="${2:-}"
      shift 2
      ;;
    --target)
      CUSTOM_TARGET="${2:-}"
      shift 2
      ;;
    --check)
      CHECK_ONLY=true
      shift
      ;;
    --force)
      shift
      ;;
    --help|-h)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

# Tool detection
check_prerequisites() {
  local missing=()
  local warnings=()

  echo "=== Tool Prerequisites Check ==="

  # Python 3.10+
  if command -v python3 >/dev/null 2>&1; then
    PY_VERSION=$(python3 --version 2>&1 | sed 's/Python //')
    PY_MAJOR=$(echo "$PY_VERSION" | cut -d. -f1)
    PY_MINOR=$(echo "$PY_VERSION" | cut -d. -f2)
    if [[ "$PY_MAJOR" -gt 3 || ( "$PY_MAJOR" -eq 3 && "$PY_MINOR" -ge 10 ) ]]; then
      echo "✅  Python: ${PY_VERSION}"
    else
      warnings+=("Python ≥3.10 required (found ${PY_VERSION})")
      echo "⚠️   Python: ${PY_VERSION} (requires ≥3.10)"
      echo "    Upgrade: brew install python@3.12  OR  use pyenv/uv"
    fi
  else
    missing+=("Python ≥3.10")
    echo "❌  Python: not found"
    echo "    Install: brew install python@3.12  OR  https://www.python.org/downloads/"
  fi

  # FFmpeg
  if command -v ffmpeg >/dev/null 2>&1; then
    echo "✅  FFmpeg: $(ffmpeg -version 2>&1 | head -1 | cut -d' ' -f3)"
  else
    missing+=("FFmpeg")
    echo "❌  FFmpeg: not found"
    echo "    Install: brew install ffmpeg  OR  apt install ffmpeg"
  fi

  # pip / uv (virtual-env package manager)
  if command -v uv >/dev/null 2>&1; then
    echo "✅  uv: $(uv --version 2>/dev/null | head -1 || echo found)"
  elif command -v pip3 >/dev/null 2>&1; then
    echo "✅  pip3: $(pip3 --version 2>/dev/null | cut -d' ' -f2 || echo found)"
  else
    warnings+=("No pip3 or uv found — needed to install TTS tooling in a venv")
    echo "⚠️   pip/uv: not found (required to install TTS engines in a virtual environment)"
    echo "    Install: python3 -m ensurepip  OR  brew install uv"
  fi

  # TTS engines are installed per-project into a virtual environment (optional at pack-install time)
  echo "ℹ️   TTS engines (ChatTTS / XTTS-v2 / CosyVoice / etc.): install per-project in a venv"
  echo "    See references/tool-landscape.md and references/apple-silicon.md for selection + setup."

  echo ""
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "❌ Missing required tools: ${missing[*]}"
    echo "   Install the missing tools above before using this pack."
    return 1
  elif [[ ${#warnings[@]} -gt 0 ]]; then
    echo "⚠️  Warnings: ${warnings[*]}"
    echo "   Pack will install but some features may not work correctly."
    return 0
  else
    echo "✅ All prerequisites satisfied."
    return 0
  fi
}

# Install for Claude Code
install_claude_code() {
  if [[ -n "$CUSTOM_TARGET" ]]; then
    TARGET_DIR="$CUSTOM_TARGET"
  elif [[ -d ".claude" ]]; then
    TARGET_DIR=".claude/skills/${PACK_NAME}"
  elif [[ -d "${HOME}/.claude" ]]; then
    TARGET_DIR="${HOME}/.claude/skills/${PACK_NAME}"
  else
    echo "✗ Claude Code not found (.claude/ or ~/.claude/ missing)." >&2
    exit 1
  fi

  echo "=== Installing ${PACK_NAME} v${PACK_VERSION} for Claude Code ==="
  echo "Target: ${TARGET_DIR}"
  echo ""

  mkdir -p "${TARGET_DIR}/references"

  # Copy CAPABILITY.md
  cp "${SCRIPT_DIR}/CAPABILITY.md" "${TARGET_DIR}/SKILL.md"
  echo "✅  SKILL.md"

  # Copy all references
  for ref_file in "${SCRIPT_DIR}/references/"*.md; do
    filename="$(basename "$ref_file")"
    cp "$ref_file" "${TARGET_DIR}/references/${filename}"
    echo "✅  references/${filename}"
  done

  # Copy all examples (behavioral eval fixtures)
  if [[ -d "${SCRIPT_DIR}/examples" ]]; then
    mkdir -p "${TARGET_DIR}/examples"
    local found_examples=0
    for ex_file in "${SCRIPT_DIR}/examples/"*.md; do
      [[ -f "$ex_file" ]] || continue
      filename="$(basename "$ex_file")"
      cp "$ex_file" "${TARGET_DIR}/examples/${filename}"
      echo "✅  examples/${filename}"
      found_examples=1
    done
    if [[ "$found_examples" -eq 0 ]]; then
      echo "ℹ️   examples/: directory exists but contains no .md files"
    fi
  fi

  echo ""
  echo "✅ ${PACK_NAME} v${PACK_VERSION} installed to: ${TARGET_DIR}"
  echo ""
  echo "Next steps:"
  echo "  1. Restart Claude Code (or reload the session)"
  echo "  2. The pack activates automatically when you work on voice/TTS tasks"
  echo "  3. Use CAPABILITY.md Step 1 to detect context → load the right reference"
}

# Phase 2 stub: Codex
install_codex() {
  echo "ℹ️  Codex installation is planned for Phase 2."
  echo ""
  echo "What Phase 2 Codex install will do:"
  echo "  - Copy CAPABILITY.md to ~/.codex/skills/${PACK_NAME}/"
  echo "  - Register in AGENTS.md with role-switch trigger"
  echo "  - Create codex-${PACK_NAME}-skill.md (stripped version)"
  echo ""
  echo "For now, copy files manually:"
  echo "  cp -r ${SCRIPT_DIR}/ ~/.codex/skills/${PACK_NAME}/"
  exit 2
}

# Phase 2 stub: Cursor
install_cursor() {
  echo "ℹ️  Cursor installation is planned for Phase 2."
  echo ""
  echo "What Phase 2 Cursor install will do:"
  echo "  - Copy references/ to .cursor/rules/${PACK_NAME}/"
  echo "  - Create .cursorrules entry for voice/TTS context detection"
  echo ""
  echo "For now, copy files manually:"
  echo "  cp -r ${SCRIPT_DIR}/references/ .cursor/rules/${PACK_NAME}/"
  exit 2
}

# Phase 2 stub: Gemini
install_gemini() {
  echo "ℹ️  Gemini CLI installation is planned for Phase 2."
  echo ""
  echo "What Phase 2 Gemini install will do:"
  echo "  - Copy references/ to ~/.gemini/skills/${PACK_NAME}/"
  echo "  - Create a GEMINI.md context file"
  echo ""
  echo "For now, reference files are available at: ${SCRIPT_DIR}/references/"
  exit 2
}

# Main
if $CHECK_ONLY; then
  check_prerequisites
  exit $?
fi

check_prerequisites || true  # warn but don't block install

echo ""

case "$AGENT" in
  claude-code)
    install_claude_code
    ;;
  codex)
    install_codex
    ;;
  cursor)
    install_cursor
    ;;
  gemini)
    install_gemini
    ;;
  *)
    echo "Unknown agent: ${AGENT}"
    echo "Supported: claude-code (installed), codex/cursor/gemini (Phase 2)"
    exit 1
    ;;
esac
