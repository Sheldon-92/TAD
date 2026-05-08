#!/usr/bin/env bash
# install.sh — Web UI Design Capability Pack installer
# Phase 1: Claude Code support
# Phase 3 (future): Codex, Cursor, Gemini — interfaces reserved via --agent flag
#
# Usage: bash install.sh [--dry-run] [--force] [--global] [--agent=claude|codex|cursor|gemini]

set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
FORCE=false
ALLOW_GLOBAL=false
AGENT="claude"

# Parse flags
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
      echo "  --dry-run      Show what would be installed without writing files"
      echo "  --force        Overwrite existing files without warning"
      echo "  --global       Allow install to ~/.claude/ when no project .claude/ is found"
      echo "  --agent=NAME   Agent to install for (default: claude)"
      echo "                 Supported: claude"
      echo "                 Planned (Phase 3): codex, cursor, gemini"
      exit 0
      ;;
    *)
      echo "Unknown flag: $arg. Run with --help for usage." >&2
      exit 1
      ;;
  esac
done

echo "=== Web UI Design Capability Pack Installer ==="
echo "Pack location: $PACK_DIR"
echo ""

# --- Phase 3 interface stub (not yet implemented) ---
case "$AGENT" in
  claude)
    # Phase 1 — implemented below
    ;;
  codex|cursor|gemini)
    echo "⚠️  Phase 3 ($AGENT) is not yet implemented." >&2
    echo "   Phase 3 will install to:" >&2
    case "$AGENT" in
      codex)  echo "   AGENTS.md (project root, appended reference)" >&2 ;;
      cursor) echo "   .cursor/rules/web-ui-design.md" >&2 ;;
      gemini) echo "   CAPABILITY.md (project root, passed via -p flag)" >&2 ;;
    esac
    echo "   For now, install with --agent=claude and adapt manually." >&2
    exit 2
    ;;
  *)
    echo "Unknown agent: $AGENT. Supported: claude (others in Phase 3)" >&2
    exit 1
    ;;
esac

# --- Claude Code: detect install target ---

CLAUDE_DIR=""
if [ -d ".claude" ]; then
  CLAUDE_DIR=".claude"
  echo "✓ .claude/ detected — Claude Code project install"
elif [ "$ALLOW_GLOBAL" = true ] && [ -d "$HOME/.claude" ]; then
  CLAUDE_DIR="$HOME/.claude"
  echo "✓ ~/.claude/ detected — Claude Code global install (--global flag set)"
elif [ -d "$HOME/.claude" ]; then
  echo "✗ No .claude/ in current directory." >&2
  echo "  Found ~/.claude/ — use --global to install globally, or cd to your project first." >&2
  exit 1
else
  echo "✗ Claude Code not found (.claude/ or ~/.claude/ missing)." >&2
  echo "  Install Claude Code: https://claude.ai/code" >&2
  exit 1
fi

SKILL_DIR="${CLAUDE_DIR}/skills/web-ui-design"
echo "Target: ${SKILL_DIR}/"
echo ""

# --- Copy plan ---

declare -a COPY_PAIRS=(
  "CAPABILITY.md:${SKILL_DIR}/SKILL.md"
  "DESIGN-TEMPLATE.md:${SKILL_DIR}/DESIGN-TEMPLATE.md"
  "LICENSE:${SKILL_DIR}/LICENSE"
  "LICENSE-ATTRIBUTION.md:${SKILL_DIR}/LICENSE-ATTRIBUTION.md"
  "checklists/accessibility.md:${SKILL_DIR}/checklists/accessibility.md"
  "checklists/anti-slop.md:${SKILL_DIR}/checklists/anti-slop.md"
  "checklists/responsive.md:${SKILL_DIR}/checklists/responsive.md"
  "checklists/post-generation.md:${SKILL_DIR}/checklists/post-generation.md"
  "tools/tool-registry.md:${SKILL_DIR}/tools/tool-registry.md"
  "tools/component-matrix.md:${SKILL_DIR}/tools/component-matrix.md"
  "tools/tokens-to-css.sh:${SKILL_DIR}/tools/tokens-to-css.sh"
  "references/brand-tokens.md:${SKILL_DIR}/references/brand-tokens.md"
  "references/design-system-patterns.md:${SKILL_DIR}/references/design-system-patterns.md"
  "references/awesome-lists.md:${SKILL_DIR}/references/awesome-lists.md"
  "examples/starter-tokens.json:${SKILL_DIR}/examples/starter-tokens.json"
)

echo "Files to install:"
WILL_OVERWRITE=false
for pair in "${COPY_PAIRS[@]}"; do
  src="${pair%%:*}"
  dst="${pair##*:}"
  if [ -f "${PACK_DIR}/${src}" ]; then
    if [ -f "$dst" ]; then
      echo "  [exists] ${src} → ${dst}"
      WILL_OVERWRITE=true
    else
      echo "  ${src} → ${dst}"
    fi
  else
    echo "  [MISSING] ${src} — skip"
  fi
done
echo ""

if [ "$DRY_RUN" = true ]; then
  echo "=== DRY RUN — no files written ==="
  echo "Run without --dry-run to install."
  if [ "$WILL_OVERWRITE" = true ] && [ "$FORCE" = false ]; then
    echo "⚠️  Some files exist and will be skipped. Use --force to overwrite."
  fi
  exit 0
fi

# Pre-flight: write permission check
if ! mkdir -p "${SKILL_DIR}" 2>/dev/null; then
  echo "Error: cannot create ${SKILL_DIR} — permission denied" >&2
  exit 1
fi
if ! touch "${SKILL_DIR}/.write-test" 2>/dev/null; then
  echo "Error: ${SKILL_DIR} is not writable" >&2
  exit 1
fi
rm -f "${SKILL_DIR}/.write-test"

# --- Install phase ---

mkdir -p "${SKILL_DIR}/checklists" \
         "${SKILL_DIR}/tools" \
         "${SKILL_DIR}/references" \
         "${SKILL_DIR}/examples"

INSTALLED=0
SKIPPED=0
EXISTED=0

for pair in "${COPY_PAIRS[@]}"; do
  src="${pair%%:*}"
  dst="${pair##*:}"
  src_full="${PACK_DIR}/${src}"

  if [ ! -f "$src_full" ]; then
    echo "  - Skipped (not found): $src"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  if [ -f "$dst" ] && [ "$FORCE" = false ]; then
    echo "  ! Skipped (exists, use --force to overwrite): $dst"
    EXISTED=$((EXISTED + 1))
    continue
  fi

  cp "$src_full" "$dst"
  echo "  ✓ Installed: $dst"
  INSTALLED=$((INSTALLED + 1))
done

# Make scripts executable
if [ -f "${SKILL_DIR}/tools/tokens-to-css.sh" ]; then
  chmod +x "${SKILL_DIR}/tools/tokens-to-css.sh"
fi

echo ""
echo "=== Installation complete ==="
echo "  Installed: ${INSTALLED} files"
echo "  Skipped (missing source): ${SKIPPED} files"
echo "  Skipped (already exist): ${EXISTED} files (use --force to overwrite)"
echo ""
echo "SKILL.md available at: ${SKILL_DIR}/SKILL.md"
echo ""
echo "To activate in Claude Code:"
echo "  Reference 'web-ui-design' skill in your conversation"
echo "  Or: 'Design this using the web-ui-design capability pack'"
