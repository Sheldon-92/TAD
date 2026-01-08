#!/bin/bash

# TAD v1.5 Migration Script
# Migrates from v1.4 (or earlier) directory structure to v1.5
# Separates framework files (.tad/) from user work (tad-work/)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "======================================"
echo -e "${BLUE}TAD v1.5 Migration${NC}"
echo "======================================"
echo ""

# Check if in a TAD project
if [ ! -d ".tad" ]; then
    echo -e "${RED}❌ Error: Not in a TAD project directory${NC}"
    echo "Please run this script from your project root"
    exit 1
fi

# Check current version
CURRENT_VERSION="unknown"
if [ -f ".tad/version.txt" ]; then
    CURRENT_VERSION=$(cat .tad/version.txt)
fi

echo -e "📌 Current version: ${YELLOW}$CURRENT_VERSION${NC}"

if [ "$CURRENT_VERSION" = "1.5" ] || [ "$CURRENT_VERSION" = "1.5.0" ]; then
    echo -e "${GREEN}✅ Already on v1.5${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}This will migrate your project to TAD v1.5:${NC}"
echo ""
echo "  📁 New structure:"
echo "     .tad/        → Framework files (config, templates, tasks)"
echo "     tad-work/    → Your work (handoffs, context, evidence)"
echo ""
echo "  ✅ Benefits:"
echo "     • Clean separation of framework and user data"
echo "     • Safe framework upgrades (won't touch your work)"
echo "     • Clearer version control"
echo ""
read -p "Continue migration? (y/n): " -n 1 -r < /dev/tty
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Migration cancelled"
    exit 0
fi

echo ""
echo "🔄 Starting migration..."

# Step 1: Create tad-work directory structure
echo ""
echo "📁 Creating tad-work/ directory..."
mkdir -p tad-work/{handoffs,archive,context,working,learnings/{pending,pushed},evidence/{gates,patterns,metrics,project-logs}}

# Step 2: Move user data from .tad/ to tad-work/
echo "📦 Moving user data to tad-work/..."

# Move handoffs (if exists)
if [ -d ".tad/active/handoffs" ] && [ "$(ls -A .tad/active/handoffs 2>/dev/null)" ]; then
    echo "  → handoffs/"
    mv .tad/active/handoffs/* tad-work/handoffs/ 2>/dev/null || true
    rm -rf .tad/active
fi

# Move archive (if exists)
if [ -d ".tad/archive" ] && [ "$(ls -A .tad/archive 2>/dev/null)" ]; then
    echo "  → archive/"
    cp -r .tad/archive/* tad-work/archive/ 2>/dev/null || true
fi

# Move context (if exists)
if [ -d ".tad/context" ] && [ "$(ls -A .tad/context 2>/dev/null | grep -v .gitkeep)" ]; then
    echo "  → context/"
    mv .tad/context/* tad-work/context/ 2>/dev/null || true
fi

# Move working (if exists)
if [ -d ".tad/working" ] && [ "$(ls -A .tad/working 2>/dev/null | grep -v .gitkeep)" ]; then
    echo "  → working/"
    mv .tad/working/* tad-work/working/ 2>/dev/null || true
fi

# Move evidence (if exists)
if [ -d ".tad/evidence" ] && [ "$(ls -A .tad/evidence 2>/dev/null)" ]; then
    echo "  → evidence/"
    cp -r .tad/evidence/* tad-work/evidence/ 2>/dev/null || true
fi

# Move gates (if exists)
if [ -d ".tad/gates" ] && [ "$(ls -A .tad/gates 2>/dev/null)" ]; then
    echo "  → gates/"
    cp -r .tad/gates/* tad-work/gates/ 2>/dev/null || true
fi

# Create .gitkeep files
touch tad-work/handoffs/.gitkeep
touch tad-work/context/.gitkeep
touch tad-work/working/.gitkeep

# Step 3: Download and install v1.5 framework
echo ""
echo "📥 Downloading TAD v1.5 framework..."
curl -sSL https://github.com/Sheldon-92/TAD/archive/refs/heads/main.tar.gz | tar -xz

echo "📦 Updating framework files..."

# Update config files
cp TAD-main/.tad/config.yaml .tad/
cp TAD-main/.tad/skills-config.yaml .tad/ 2>/dev/null || true

# Update commands
cp TAD-main/.claude/commands/tad-*.md .claude/commands/

# Update templates
cp -r TAD-main/.tad/templates/* .tad/templates/ 2>/dev/null || true

# Update tasks
cp -r TAD-main/.tad/tasks/* .tad/tasks/ 2>/dev/null || true

# Update CLAUDE.md
cp TAD-main/CLAUDE.md ./ 2>/dev/null || true

# Copy tad-work README
cp TAD-main/tad-work/README.md tad-work/

# Remove deprecated files
echo "🗑️  Removing deprecated files..."
rm -rf .tad/active 2>/dev/null || true
rm -f .tad/agents/agent-a-architect*.md 2>/dev/null || true
rm -f .tad/agents/agent-b-executor*.md 2>/dev/null || true

# Update version
echo "1.5" > .tad/version.txt

# Clean up
rm -rf TAD-main

# Step 4: Update .gitignore
echo ""
echo "📝 Updating .gitignore..."
if [ ! -f ".gitignore" ]; then
    touch .gitignore
fi

# Add tad-work section if not present
if ! grep -q "# TAD v1.5 Work Directory" .gitignore 2>/dev/null; then
    cat >> .gitignore << 'GITIGNORE'

# TAD v1.5 Work Directory
# Temporary work files (optional to exclude)
tad-work/working/*
!tad-work/working/.gitkeep

# Session context (optional - keep if you want to preserve)
# tad-work/context/*
# !tad-work/context/.gitkeep

# Everything else in tad-work/ should be committed
GITIGNORE
fi

echo ""
echo "======================================"
echo -e "${GREEN}✅ Migration Complete!${NC}"
echo "======================================"
echo ""
echo "📋 Changes made:"
echo "  • Created tad-work/ directory"
echo "  • Moved all user data to tad-work/"
echo "  • Updated framework to v1.5"
echo "  • Updated .gitignore"
echo ""
echo "📁 New structure:"
echo "  .tad/         - Framework (can be safely upgraded)"
echo "  tad-work/     - Your work (preserved during upgrades)"
echo ""
echo "🎯 Next steps:"
echo "  1. Review tad-work/ to ensure all files migrated"
echo "  2. Commit changes: git add . && git commit -m 'Upgrade to TAD v1.5'"
echo "  3. Restart Claude Code"
echo "  4. Run /alex or /blake to verify"
echo ""
