#!/usr/bin/env bash
# install.sh — Research Methodology Capability Pack installer
#
# Usage:
#   bash install.sh --agent=claude-code          Install to Claude Code
#   bash install.sh --agent=claude-code --dry-run  Show paths without installing
#   bash install.sh --agent=codex                Print "not yet implemented" (exit 2)
#   bash install.sh --agent=cursor               Print "not yet implemented" (exit 2)
#   bash install.sh --agent=gemini               Print "not yet implemented" (exit 2)
#   bash install.sh --help                       Show this help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_NAME="research-methodology"

usage() {
  cat >&2 <<EOF
Usage: bash install.sh --agent=<agent> [--dry-run]

Options:
  --agent=claude-code   Install to Claude Code (.claude/skills/)
  --agent=codex         Not yet implemented (exits 2)
  --agent=cursor        Not yet implemented (exits 2)
  --agent=gemini        Not yet implemented (exits 2)
  --dry-run             Show target paths without writing files
  --help                Show this message

Examples:
  bash install.sh --agent=claude-code
  bash install.sh --agent=claude-code --dry-run
EOF
  exit 0
}

AGENT=""
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --agent=*)
      AGENT="${arg#--agent=}"
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    --help|-h)
      usage
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Run: bash install.sh --help" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$AGENT" ]]; then
  echo "Error: --agent=<agent> required" >&2
  usage
fi

# ─── Phase 3 stubs (not yet implemented) ───────────────────────────────────
case "$AGENT" in
  claude-code|codex)
    : # both install to .claude/skills/ — handled below
    ;;
  cursor)
    echo "Error: --agent=cursor is not yet implemented." >&2
    exit 2
    ;;
  gemini)
    echo "Error: --agent=gemini is not yet implemented." >&2
    exit 2
    ;;
  *)
    echo "Error: Unknown agent '${AGENT}'. Supported: claude-code, codex" >&2
    exit 1
    ;;
esac

# ─── Claude Code installation ───────────────────────────────────────────────
TARGET_DIR=".claude/skills/${PACK_NAME}"
SKILL_DEST="${TARGET_DIR}/SKILL.md"
REF_DEST="${TARGET_DIR}/references"
SCRIPTS_DEST="${TARGET_DIR}/scripts"
CHECKLIST_DEST="${TARGET_DIR}/checklists"

echo "Research Methodology Capability Pack — Claude Code installer"
echo ""
echo "Target paths:"
echo "  SKILL:      ${SKILL_DEST}"
echo "  References: ${REF_DEST}/"
echo "  Scripts:    ${SCRIPTS_DEST}/"
echo "  Checklists: ${CHECKLIST_DEST}/"
echo ""

if $DRY_RUN; then
  echo "[DRY RUN] No files written."
  exit 0
fi

# Check for existing installation (warn before overwrite)
if [[ -f "${SKILL_DEST}" ]]; then
  echo "⚠️  WARNING: Existing installation detected at ${SKILL_DEST}"
  echo "   Files about to be overwritten:"
  find "${TARGET_DIR}" -type f | sed "s|^|     |"
  echo ""
  echo "   To back up first: cp -r ${TARGET_DIR} ${TARGET_DIR}.backup-$(date +%Y%m%d%H%M%S)"
  echo "   Press Ctrl+C to cancel, or wait 3 seconds to continue..."
  sleep 3
fi

# Create directories
mkdir -p "${TARGET_DIR}" "${REF_DEST}" "${SCRIPTS_DEST}" "${CHECKLIST_DEST}"

# Copy CAPABILITY.md → SKILL.md
cp "${SCRIPT_DIR}/CAPABILITY.md" "${SKILL_DEST}"

# Copy references (guard: only if source files exist)
if compgen -G "${SCRIPT_DIR}/references/*.md" > /dev/null 2>&1; then
  cp "${SCRIPT_DIR}/references/"*.md "${REF_DEST}/"
fi

# Copy scripts (and make executable)
if compgen -G "${SCRIPT_DIR}/scripts/*.sh" > /dev/null 2>&1; then
  cp "${SCRIPT_DIR}/scripts/"*.sh "${SCRIPTS_DEST}/"
  chmod +x "${SCRIPTS_DEST}/"*.sh
fi

# Copy checklists
if compgen -G "${SCRIPT_DIR}/checklists/*.md" > /dev/null 2>&1; then
  cp "${SCRIPT_DIR}/checklists/"*.md "${CHECKLIST_DEST}/"
fi

# .gitignore update (NFR4 — append .research/ if not already present)
GITIGNORE=".gitignore"
if [[ -f "$GITIGNORE" ]]; then
  if ! grep -qxF '.research/' "$GITIGNORE"; then
    echo "" >> "$GITIGNORE"
    echo "# Research Methodology Capability Pack session data" >> "$GITIGNORE"
    echo ".research/" >> "$GITIGNORE"
    echo "Added .research/ to .gitignore"
  else
    echo ".research/ already in .gitignore — skipped"
  fi
else
  cat > "$GITIGNORE" <<EOF
# Research Methodology Capability Pack session data
.research/
EOF
  echo "Created .gitignore with .research/"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Quick start:"
echo "  1. Reload Claude Code (or open new chat)"
echo "  2. Say: '研究一下 [your topic]'"
echo "  3. The pack activates automatically via keyword routing"
echo ""
echo "Manual activation:"
echo "  'Use the research-methodology capability pack to research [topic]'"
