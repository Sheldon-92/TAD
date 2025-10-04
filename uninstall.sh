#!/bin/bash

# TAD Framework Uninstaller
# Removes TAD installation from current project

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================"
echo -e "${RED}TAD Framework Uninstaller${NC}"
echo "========================================"
echo ""

# Check if TAD is installed
if [ ! -d ".tad" ] && [ ! -d ".claude" ] && [ ! -f "tad" ]; then
    echo -e "${YELLOW}⚠️  TAD Framework is not installed in this directory${NC}"
    echo ""
    echo "No TAD files found. Nothing to uninstall."
    exit 0
fi

# Show what will be removed
echo "The following will be removed from current directory:"
echo ""

if [ -d ".tad" ]; then
    TAD_SIZE=$(du -sh .tad 2>/dev/null | cut -f1)
    echo -e "  ${YELLOW}✗${NC} .tad/ directory (${TAD_SIZE})"
fi

if [ -d ".claude" ]; then
    # Check if .claude contains TAD commands
    TAD_COMMANDS=$(ls .claude/commands/tad-*.md 2>/dev/null | wc -l | tr -d ' ')
    if [ "$TAD_COMMANDS" -gt 0 ]; then
        echo -e "  ${YELLOW}✗${NC} .claude/commands/ - TAD slash commands (${TAD_COMMANDS} files)"
    fi
fi

if [ -f "tad" ]; then
    echo -e "  ${YELLOW}✗${NC} tad CLI script"
fi

echo ""
echo -e "${RED}⚠️  WARNING: This action cannot be undone!${NC}"
echo ""

# Ask for confirmation
read -p "Are you sure you want to uninstall TAD? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo "Uninstalling TAD Framework..."
echo ""

# Create backup option
read -p "Create backup before uninstall? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    BACKUP_DIR=".tad_backup_$(date +%Y%m%d_%H%M%S)"
    echo "Creating backup at ${BACKUP_DIR}..."

    mkdir -p "$BACKUP_DIR"

    if [ -d ".tad" ]; then
        cp -r .tad "$BACKUP_DIR/"
    fi

    if [ -d ".claude" ]; then
        mkdir -p "$BACKUP_DIR/.claude"
        cp .claude/commands/tad-*.md "$BACKUP_DIR/.claude/" 2>/dev/null || true
    fi

    if [ -f "tad" ]; then
        cp tad "$BACKUP_DIR/"
    fi

    echo -e "${GREEN}✓ Backup created${NC}"
    echo ""
fi

# Remove TAD files
echo "Removing TAD files..."
echo ""

if [ -d ".tad" ]; then
    rm -rf .tad
    echo -e "${GREEN}✓ Removed .tad/ directory${NC}"
fi

if [ -d ".claude/commands" ]; then
    # Only remove TAD-specific commands
    rm -f .claude/commands/tad-*.md
    echo -e "${GREEN}✓ Removed TAD slash commands${NC}"

    # Remove .claude directory if it's now empty
    if [ -z "$(ls -A .claude/commands 2>/dev/null)" ]; then
        rm -rf .claude/commands
        echo -e "${GREEN}✓ Removed empty .claude/commands/ directory${NC}"
    fi

    if [ -d ".claude" ] && [ -z "$(ls -A .claude 2>/dev/null)" ]; then
        rm -rf .claude
        echo -e "${GREEN}✓ Removed empty .claude/ directory${NC}"
    fi
fi

if [ -f "tad" ]; then
    rm -f tad
    echo -e "${GREEN}✓ Removed tad CLI script${NC}"
fi

# Clean up .gitignore
if [ -f ".gitignore" ]; then
    if grep -q ".tad/" .gitignore 2>/dev/null; then
        # Remove TAD-related entries from .gitignore
        sed -i.bak '/^# TAD Framework/,/^$/d' .gitignore 2>/dev/null || true
        sed -i.bak '/^\.tad\//d' .gitignore 2>/dev/null || true
        rm -f .gitignore.bak
        echo -e "${GREEN}✓ Cleaned .gitignore${NC}"
    fi
fi

echo ""
echo "========================================"
echo -e "${GREEN}✅ TAD Framework Uninstalled!${NC}"
echo "========================================"
echo ""

if [ -d "$BACKUP_DIR" ]; then
    echo "Backup saved at: ${BACKUP_DIR}"
    echo ""
    echo "To restore TAD:"
    echo "  cp -r ${BACKUP_DIR}/.tad ./"
    echo "  cp -r ${BACKUP_DIR}/.claude ./"
    echo "  cp ${BACKUP_DIR}/tad ./"
    echo ""
fi

echo "To reinstall TAD:"
echo "  curl -fsSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash"
echo ""
