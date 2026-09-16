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
  --agent=<name>    Target agent runtime (default: codex)
                    Supported: codex, codex
  --agent <name>    Same (space-separated form)
  --target <path>   Override install target directory
  --dry-run         Show what would be installed without copying files
  --force           Overwrite existing installation
  --help            Show this message

Examples:
  bash install.sh                          # Install for Codex (default)
  bash install.sh --agent=codex      # Explicit Codex
  bash install.sh --agent=codex            # Install for Codex (.agents/skills/)
  bash install.sh --dry-run                # Preview without writing
EOF
  exit "${1:-0}"
}

AGENT="codex"
CUSTOM_TARGET=""
DRY_RUN=false
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent=*)
      AGENT="${1#--agent=}"
      shift
      ;;
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
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --force)
      FORCE=true
      shift
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

install_pack() {
  local PLATFORM="$1"
  if [[ -n "$CUSTOM_TARGET" ]]; then
    TARGET_DIR="$CUSTOM_TARGET"
  elif [[ "$PLATFORM" = "codex" ]]; then
    TARGET_DIR=".agents/skills/${PACK_NAME}"
  else
    PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    if [[ -d "${PROJECT_ROOT}/.agents" ]]; then
      TARGET_DIR="${PROJECT_ROOT}/.agents/skills/${PACK_NAME}"
    elif [[ -d "${HOME}/.agents" ]]; then
      TARGET_DIR="${HOME}/.agents/skills/${PACK_NAME}"
    else
      echo "✗ Codex not found (.agents/ or ~/.agents/ missing)." >&2
      exit 1
    fi
  fi

  echo "=== Installing ${PACK_NAME} v${PACK_VERSION} for ${PLATFORM} ==="
  echo "Target: ${TARGET_DIR}"
  echo ""

  if [[ "$DRY_RUN" = true ]]; then
    echo "DRY RUN — No files will be copied."
    echo "Would install SKILL.md + references/ to: ${TARGET_DIR}"
    return 0
  fi

  if [[ -d "$TARGET_DIR" ]] && [[ "$FORCE" = false ]]; then
    echo "⚠️  Existing installation found at $TARGET_DIR"
    echo "   Use --force to overwrite."
    exit 0
  fi

  mkdir -p "${TARGET_DIR}/references"

  cp "${SCRIPT_DIR}/SKILL.md" "${TARGET_DIR}/SKILL.md"
  grep -q '^name:' "${TARGET_DIR}/SKILL.md" || { echo "ERROR: SKILL.md missing 'name:' frontmatter" >&2; exit 1; }
  echo "✅  SKILL.md (frontmatter verified)"

  for ref_file in "${SCRIPT_DIR}/references/"*.md; do
    filename="$(basename "$ref_file")"
    cp "$ref_file" "${TARGET_DIR}/references/${filename}"
    echo "✅  references/${filename}"
  done

  if [[ -d "${SCRIPT_DIR}/scripts" ]]; then
    mkdir -p "${TARGET_DIR}/scripts"
    for script_file in "${SCRIPT_DIR}/scripts/"*; do
      [[ -f "$script_file" ]] || continue
      filename="$(basename "$script_file")"
      cp "$script_file" "${TARGET_DIR}/scripts/${filename}"
      chmod +x "${TARGET_DIR}/scripts/${filename}" 2>/dev/null || true
      echo "✅  scripts/${filename}"
    done
  fi

  echo ""
  echo "✅ ${PACK_NAME} v${PACK_VERSION} installed to: ${TARGET_DIR}"
  echo ""
  echo "Next steps:"
  echo "  1. Restart Codex (or reload the session)"
  echo "  2. The pack activates on academic/scientific research keywords"
  echo "  3. Keywords: 学术, academic, 论文, paper, 文献, literature, PRISMA, PubMed"
}

case "$AGENT" in
  codex)
    install_pack "codex"
    ;;
  codex)
    install_pack "codex"
    ;;
  *)
    echo "Unknown agent: ${AGENT}"
    echo "Supported: codex, codex"
    exit 1
    ;;
esac
