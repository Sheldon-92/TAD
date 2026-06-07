#!/usr/bin/env bash
set -euo pipefail
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"
PACK_NAME="ai-podcast-production"
SKILL_DIR=".claude/skills/$PACK_NAME"
mkdir -p "$SKILL_DIR/references"
cp "$PACK_DIR/CAPABILITY.md" "$SKILL_DIR/SKILL.md"
cp "$PACK_DIR/references/"*.md "$SKILL_DIR/references/" 2>/dev/null || true
echo "Installed $PACK_NAME to $SKILL_DIR"
