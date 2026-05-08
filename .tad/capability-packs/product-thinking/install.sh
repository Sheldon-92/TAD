#!/usr/bin/env bash
# Product Thinking — Claude Code Installer
# Usage: bash install.sh [--dry-run] [--force] [--global] [--agent=<name>]

set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────────────
PACK_NAME="product-thinking"
PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=""
DRY_RUN=false
FORCE=false
AGENT="claude-code"

# ── Argument parsing ─────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY_RUN=true ;;
    --force)     FORCE=true ;;
    --global)    TARGET_DIR="$HOME/.claude/skills/$PACK_NAME" ;;
    --agent=*)   AGENT="${arg#--agent=}" ;;
    --help|-h)
      echo "Usage: bash install.sh [--dry-run] [--force] [--global] [--agent=<name>]"
      echo ""
      echo "Options:"
      echo "  --dry-run    Preview what will be installed without making changes"
      echo "  --force      Overwrite existing installation"
      echo "  --global     Install to ~/.claude/skills/ (all projects)"
      echo "  --agent=X    Target agent (default: claude-code)"
      echo "               Supported: claude-code"
      echo "               Phase 3: codex, cursor, gemini (not yet implemented)"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Run: bash install.sh --help"
      exit 1
      ;;
  esac
done

# ── Agent routing ────────────────────────────────────────────────────────────
case "$AGENT" in
  claude-code)
    if [ -z "$TARGET_DIR" ]; then
      TARGET_DIR=".claude/skills/$PACK_NAME"
    fi
    ;;
  codex|cursor|gemini)
    echo "⚠️  Agent '$AGENT' is reserved for Phase 3 (not yet implemented)."
    echo "   Phase 3 will add: $AGENT install target at the appropriate path."
    echo "   For now, use: bash install.sh (defaults to Claude Code)"
    exit 2
    ;;
  *)
    echo "Unknown agent: $AGENT"
    echo "Supported: claude-code"
    exit 1
    ;;
esac

# ── Preflight ────────────────────────────────────────────────────────────────
echo "Product Thinking Capability Pack — Installer"
echo "Agent: $AGENT"
echo "Target: $TARGET_DIR"
echo ""

# Validate CAPABILITY.md frontmatter
CAPABILITY_FILE="$PACK_DIR/skills/pressure-test.md"
if ! grep -q "^name:" "$CAPABILITY_FILE" 2>/dev/null; then
  echo "ERROR: skills/pressure-test.md is missing YAML frontmatter (name: field required)"
  echo "Installation aborted."
  exit 1
fi

# Check if already installed
if [ -d "$TARGET_DIR" ] && [ "$FORCE" = false ]; then
  echo "⚠️  Already installed at: $TARGET_DIR"
  echo "   Use --force to overwrite, or --dry-run to preview."
  exit 1
fi

# ── File list ────────────────────────────────────────────────────────────────
FILES=(
  "skills/pressure-test.md"
  "skills/shotgun.md"
  "skills/define.md"
  "adapters/software.md"
  "adapters/hardware.md"
  "adapters/ecommerce.md"
  "adapters/service.md"
  "adapters/content.md"
  "adapters/marketplace.md"
  "tools/tool-registry.md"
  "checklists/fatal-flaws.md"
  "checklists/per-type-validation.md"
  "examples/pressure-test-example.md"
  "README.md"
  "CHANGELOG.md"
  "LICENSE"
  "LICENSE-ATTRIBUTION.md"
)

# ── Dry run ──────────────────────────────────────────────────────────────────
if [ "$DRY_RUN" = true ]; then
  echo "DRY RUN — no files will be copied"
  echo ""
  echo "Would create: $TARGET_DIR/"
  for f in "${FILES[@]}"; do
    echo "  → $f"
  done
  echo ""
  echo "Total: ${#FILES[@]} files"
  exit 0
fi

# ── Install ──────────────────────────────────────────────────────────────────
echo "Installing..."

mkdir -p "$TARGET_DIR/skills"
mkdir -p "$TARGET_DIR/adapters"
mkdir -p "$TARGET_DIR/tools"
mkdir -p "$TARGET_DIR/checklists"
mkdir -p "$TARGET_DIR/examples"

for f in "${FILES[@]}"; do
  src="$PACK_DIR/$f"
  dst="$TARGET_DIR/$f"
  if [ -f "$src" ]; then
    cp "$src" "$dst"
    echo "  ✓ $f"
  else
    echo "  ⚠  MISSING: $f (skipped)"
  fi
done

# ── Session directory ─────────────────────────────────────────────────────────
SESSION_DIR="$HOME/.product-thinking"
if [ ! -d "$SESSION_DIR" ]; then
  mkdir -p "$SESSION_DIR"
  echo "  ✓ Created session directory: $SESSION_DIR"
fi

# Add to .gitignore if in a local (non-global) git repo install
if [[ "$TARGET_DIR" != "$HOME"* ]] && [ -f ".gitignore" ] && ! grep -q "\.product-thinking" .gitignore 2>/dev/null; then
  echo ".product-thinking/" >> .gitignore
  echo "  ✓ Added .product-thinking/ to .gitignore"
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "✅ Product Thinking installed at: $TARGET_DIR"
echo ""
echo "Skills available:"
echo "  /pressure-test — Adversarial product diagnosis (6 rounds + verdict)"
echo "  /shotgun       — Business model variant generation (4-perspective review)"
echo "  /define        — Executable product definition (auto-filled from prior steps)"
echo ""
echo "Start with: /pressure-test"
