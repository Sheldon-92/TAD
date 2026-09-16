#!/usr/bin/env bash
# install.sh — Web Deployment Capability Pack installer
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

echo "=== Web Deployment Capability Pack Installer ==="
echo "Pack location: $PACK_DIR"
echo ""

# -- Phase 3 stubs -------------------------------------------------------
case "$AGENT" in
  codex)
    # v3.0.0 — implemented below
    ;;
  *claude*)
    echo "Error: --agent='$AGENT' was removed in TAD v3.0.0 (Claude Code path deleted)." >&2
    echo "  Re-run with --agent=codex. No files were changed." >&2
    exit 1
    ;;
  cursor)
    echo "Phase 3 (cursor) is not yet implemented." >&2
    echo "   Phase 3 will install to:" >&2
    echo "   .cursor/rules/web-deployment.md" >&2
    echo "   For now, install with --agent=codex and adapt manually." >&2
    exit 2
    ;;
  gemini)
    echo "Phase 3 (gemini) is not yet implemented." >&2
    echo "   Phase 3 will install to:" >&2
    echo "   CAPABILITY.md (project root, loaded via 'gemini -p @CAPABILITY.md')" >&2
    echo "   For now, install with --agent=codex and adapt manually." >&2
    exit 2
    ;;
  *)
    echo "Unknown agent: $AGENT. Supported: codex (others in Phase 3)" >&2
    exit 1
    ;;
esac

# -- Codex: detect install target -----------------------------------
AGENTS_DIR=""
if [ -d ".agents" ]; then
  AGENTS_DIR=".agents"
  echo "  .agents/ detected — Codex project install"
elif [ "$ALLOW_GLOBAL" = true ] && [ -d "$HOME/.agents" ]; then
  AGENTS_DIR="$HOME/.agents"
  echo "  ~/.agents/ detected — Codex global install (--global flag set)"
elif [ -d "$HOME/.agents" ]; then
  if [ "$DRY_RUN" = true ]; then
    echo "  No .agents/ in current directory. Found ~/.agents/ — showing global install preview:"
    AGENTS_DIR="$HOME/.agents"
  else
    echo "No .agents/ in current directory." >&2
    echo "  Found ~/.agents/ — use --global to install globally, or cd to your project first." >&2
    exit 1
  fi
else
  echo "Codex not found (.agents/ or ~/.agents/ missing)." >&2
  exit 1
fi

TARGET_DIR="${AGENTS_DIR}/skills/web-deployment"
echo "Target: ${TARGET_DIR}/"
echo ""

# -- Copy plan ------------------------------------------------------------
declare -a COPY_PAIRS=(
  "CAPABILITY.md:${TARGET_DIR}/SKILL.md"
  "LICENSE:${TARGET_DIR}/LICENSE"
  "references/platform-selection-rules.md:${TARGET_DIR}/references/platform-selection-rules.md"
  "references/ci-cd-pipeline-rules.md:${TARGET_DIR}/references/ci-cd-pipeline-rules.md"
  "references/environment-config-rules.md:${TARGET_DIR}/references/environment-config-rules.md"
  "references/monitoring-rules.md:${TARGET_DIR}/references/monitoring-rules.md"
  "references/rollback-rules.md:${TARGET_DIR}/references/rollback-rules.md"
  "references/security-hardening-rules.md:${TARGET_DIR}/references/security-hardening-rules.md"
  "references/domain-dns-rules.md:${TARGET_DIR}/references/domain-dns-rules.md"
)

echo "Files to install:"
WILL_OVERWRITE=false
for pair in "${COPY_PAIRS[@]}"; do
  src="${pair%%:*}"
  dst="${pair##*:}"
  if [ -f "${PACK_DIR}/${src}" ]; then
    if [ -f "$dst" ]; then
      echo "  [exists] ${src} -> ${dst}"
      WILL_OVERWRITE=true
    else
      echo "  ${src} -> ${dst}"
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
    echo "  Some files exist. Use --force to overwrite."
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
  echo "  Installed: $dst"
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
echo "  Reference 'web-deployment' skill in your conversation."
echo "  Or: 'Use the web-deployment capability pack to review this deployment setup.'"
