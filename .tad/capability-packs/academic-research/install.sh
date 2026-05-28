#!/usr/bin/env bash
# Academic Research Capability Pack installer
# Copies pack files to the target AI agent's skills directory

set -euo pipefail

PACK_NAME="academic-research"
PACK_VERSION="0.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: bash install.sh [OPTIONS]

Options:
  --agent <name>    Target agent runtime (default: claude-code)
                    Supported: claude-code
  --target <path>   Override install target directory
  --help            Show this message

Examples:
  bash install.sh                          # Install for Claude Code (default)
  bash install.sh --agent claude-code      # Explicit Claude Code
EOF
  exit "${1:-0}"
}

AGENT="claude-code"
CUSTOM_TARGET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      [[ -z "${2:-}" ]] && echo "Missing value for --agent" && exit 1
      AGENT="$2"
      shift 2
      ;;
    --target)
      [[ -z "${2:-}" ]] && echo "Missing value for --target" && exit 1
      CUSTOM_TARGET="$2"
      shift 2
      ;;
    --help|-h)
      usage 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage 1
      ;;
  esac
done

install_claude_code() {
  if [[ -n "$CUSTOM_TARGET" ]]; then
    TARGET_DIR="$CUSTOM_TARGET"
  else
    PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    if [[ -d "${PROJECT_ROOT}/.claude" ]]; then
      TARGET_DIR="${PROJECT_ROOT}/.claude/skills/${PACK_NAME}"
    elif [[ -d "${HOME}/.claude" ]]; then
      TARGET_DIR="${HOME}/.claude/skills/${PACK_NAME}"
    else
      echo "✗ Claude Code not found (.claude/ or ~/.claude/ missing)." >&2
      exit 1
    fi
  fi

  echo "=== Installing ${PACK_NAME} v${PACK_VERSION} for Claude Code ==="
  echo "Target: ${TARGET_DIR}"
  echo ""

  mkdir -p "${TARGET_DIR}/references"

  cp "${SCRIPT_DIR}/CAPABILITY.md" "${TARGET_DIR}/SKILL.md"
  grep -q '^name:' "${TARGET_DIR}/SKILL.md" || { echo "ERROR: SKILL.md missing 'name:' frontmatter" >&2; exit 1; }
  echo "✅  SKILL.md (frontmatter verified)"

  for ref_file in "${SCRIPT_DIR}/references/"*.md; do
    filename="$(basename "$ref_file")"
    cp "$ref_file" "${TARGET_DIR}/references/${filename}"
    echo "✅  references/${filename}"
  done

  echo ""
  echo "✅ ${PACK_NAME} v${PACK_VERSION} installed to: ${TARGET_DIR}"
  echo ""
  echo "Next steps:"
  echo "  1. Restart Claude Code (or reload the session)"
  echo "  2. The pack activates on academic/scientific research keywords"
  echo "  3. Keywords: 学术, academic, 论文, paper, 文献, literature, PRISMA, PubMed"
}

case "$AGENT" in
  claude-code)
    install_claude_code
    ;;
  *)
    echo "Unknown agent: ${AGENT}"
    echo "Supported: claude-code"
    exit 1
    ;;
esac
