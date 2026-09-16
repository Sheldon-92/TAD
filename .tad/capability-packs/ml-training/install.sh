#!/usr/bin/env bash
# install.sh — ML Training Capability Pack installer
# v3.0.0: Codex support (.agents/skills target)
# Phase 3 (future): Codex, Cursor, Gemini — interfaces reserved via --agent flag
#
# Usage: bash install.sh [--dry-run] [--force] [--global] [--agent=codex|cursor|gemini]

set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
FORCE=false
ALLOW_GLOBAL=false
AGENT="codex"

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
      echo "  --global           Allow install to ~/.agents/ when no project .agents/ is found"
      echo "  --agent=NAME       Agent to install for (default: codex)"
      echo "                     Supported: codex"
      echo "                     Planned (Phase 3): cursor, gemini"
      exit 0
      ;;
    *)
      echo "Unknown flag: $arg. Run with --help for usage." >&2
      exit 1
      ;;
  esac
done

echo "=== ML Training Capability Pack Installer ==="
echo "Pack location: $PACK_DIR"
echo ""

# ── Phase 3 stubs ────────────────────────────────────────────────────────────
case "$AGENT" in
  codex)
    ;;
  cursor|gemini)
    echo "⚠️  Phase 3 ($AGENT) is not yet implemented." >&2
    echo "   For now, install with --agent=codex and adapt manually." >&2
    exit 2
    ;;
  *)
    echo "Unknown agent: $AGENT. Supported: codex (others in Phase 3)" >&2
    exit 1
    ;;
esac

# ── Detect install target ──────────────────────────────────────────────────
SKILLS_ROOT=""
if [ "$AGENT" = "codex" ]; then
  SKILLS_ROOT=".agents"
  echo "✓ Codex install — target .agents/skills/"
elif [ -d ".agents" ]; then
  SKILLS_ROOT=".agents"
  echo "✓ .agents/ detected — Codex project install"
elif [ "$ALLOW_GLOBAL" = true ] && [ -d "$HOME/.agents" ]; then
  SKILLS_ROOT="$HOME/.agents"
  echo "✓ ~/.agents/ detected — Codex global install (--global flag set)"
elif [ -d "$HOME/.agents" ]; then
  if [ "$DRY_RUN" = true ]; then
    echo "ℹ No .agents/ in current directory. Found ~/.agents/ — showing global install preview:"
    SKILLS_ROOT="$HOME/.agents"
  else
    echo "✗ No .agents/ in current directory." >&2
    echo "  Found ~/.agents/ — use --global to install globally, or cd to your project first." >&2
    exit 1
  fi
else
  echo "✗ Codex not found (.agents/ or ~/.agents/ missing)." >&2
  exit 1
fi

TARGET_DIR="${SKILLS_ROOT}/skills/ml-training"
echo "Target: ${TARGET_DIR}/"
echo ""

# ── Copy plan ────────────────────────────────────────────────────────────────
declare -a COPY_PAIRS=(
  "SKILL.md:${TARGET_DIR}/SKILL.md"
  "references/platform-selection.md:${TARGET_DIR}/references/platform-selection.md"
  "references/lora-finetune.md:${TARGET_DIR}/references/lora-finetune.md"
  "references/data-preparation.md:${TARGET_DIR}/references/data-preparation.md"
  "references/mcp-collaboration.md:${TARGET_DIR}/references/mcp-collaboration.md"
  "references/cost-estimation.md:${TARGET_DIR}/references/cost-estimation.md"
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
    echo "⚠️  Some files exist. Use --force to overwrite."
  fi
  exit 0
fi

# Pre-flight write check
if ! mkdir -p "${TARGET_DIR}" 2>/dev/null; then
  echo "Error: cannot create ${TARGET_DIR} — permission denied" >&2
  exit 1
fi
if ! touch "${TARGET_DIR}/.write-test" 2>/dev/null; then
  echo "Error: ${TARGET_DIR} is not writable" >&2
  exit 1
fi
rm -f "${TARGET_DIR}/.write-test"

mkdir -p "${TARGET_DIR}/references"

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
    echo "  ! Skipped (exists, use --force): $dst"
    EXISTED=$((EXISTED + 1))
    continue
  fi

  cp "$src_full" "$dst"
  echo "  ✓ Installed: $dst"
  INSTALLED=$((INSTALLED + 1))
done

echo ""
echo "=== Installation complete ==="
echo "  Installed: ${INSTALLED} files"
echo "  Skipped (missing source): ${SKIPPED} files"
echo "  Skipped (already exist): ${EXISTED} files (use --force to overwrite)"
echo ""
echo "SKILL.md available at: ${TARGET_DIR}/SKILL.md"
echo ""
echo "To activate in Codex:"
echo "  Reference 'ml-training' skill in your conversation."
echo "  Or: 'Help me fine-tune a model on cloud GPU.'"
