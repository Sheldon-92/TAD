#!/bin/bash

# TAD Framework Upgrade Script: v1.3 → v1.4
# Usage: curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/upgrade-to-v1.4.sh | bash

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "======================================"
echo -e "${BLUE}TAD Framework Upgrade: v1.3 → v1.4${NC}"
echo "======================================"
echo ""

# Check if TAD is installed
if [ ! -d ".tad" ]; then
    echo -e "${RED}Error: TAD is not installed in this directory${NC}"
    echo "Please run the install script first:"
    echo "curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash"
    exit 1
fi

# Check current version
CURRENT_VERSION="1.0"
if [ -f ".tad/version.txt" ]; then
    CURRENT_VERSION=$(cat .tad/version.txt)
fi

if [ "$CURRENT_VERSION" = "1.4" ] || [ "$CURRENT_VERSION" = "1.4.0" ]; then
    echo -e "${YELLOW}TAD v1.4 is already installed${NC}"
    exit 0
fi

if [[ ! "$CURRENT_VERSION" =~ ^1\.3 ]]; then
    echo -e "${RED}Error: This script upgrades from v1.3.x to v1.4${NC}"
    echo "Current version: $CURRENT_VERSION"
    echo "Please run the appropriate upgrade scripts first."
    exit 1
fi

echo -e "${GREEN}Upgrading from v$CURRENT_VERSION to v1.4...${NC}"
echo ""

# Backup current config
echo "📦 Creating backup..."
cp .tad/config.yaml .tad/config.yaml.v1.3.bak
echo -e "${GREEN}✓ Backup created: .tad/config.yaml.v1.3.bak${NC}"

# Download latest TAD files
echo ""
echo "📥 Downloading TAD v1.4 files..."
curl -sSL https://github.com/Sheldon-92/TAD/archive/refs/heads/main.tar.gz | tar -xz

# Update config.yaml
echo ""
echo "📝 Updating configuration..."
if [ -f "TAD-main/.tad/config.yaml" ]; then
    cp TAD-main/.tad/config.yaml .tad/config.yaml
    echo -e "${GREEN}✓ Updated config.yaml${NC}"
fi

# Create new directories for v1.4
echo ""
echo "📁 Creating v1.4 directories..."

# Learnings directories
mkdir -p .tad/learnings/pending
mkdir -p .tad/learnings/pushed
mkdir -p .tad/learnings/suggestions
echo -e "${GREEN}✓ Created learnings directories${NC}"

# Skills directory
mkdir -p .claude/skills
echo -e "${GREEN}✓ Created skills directory${NC}"

# Install built-in skills
echo ""
echo "📚 Installing built-in skills..."
if [ -d "TAD-main/.claude/skills" ]; then
    cp TAD-main/.claude/skills/*.md .claude/skills/ 2>/dev/null || true
    echo -e "${GREEN}✓ Installed ui-design.md${NC}"
    echo -e "${GREEN}✓ Installed skill-creator.md${NC}"
fi

# Install /tad-learn command
echo ""
echo "⌨️ Installing new commands..."
if [ -f "TAD-main/.claude/commands/tad-learn.md" ]; then
    cp TAD-main/.claude/commands/tad-learn.md .claude/commands/
    echo -e "${GREEN}✓ Installed /tad-learn command${NC}"
fi

# Update other command files if they exist
if [ -d "TAD-main/.claude/commands" ]; then
    # Update existing commands
    for cmd in TAD-main/.claude/commands/*.md; do
        filename=$(basename "$cmd")
        if [ -f ".claude/commands/$filename" ]; then
            cp "$cmd" ".claude/commands/$filename"
        fi
    done
    echo -e "${GREEN}✓ Updated existing commands${NC}"
fi

# Update version marker
echo "1.4" > .tad/version.txt

# Clean up
rm -rf TAD-main

echo ""
echo "======================================"
echo -e "${GREEN}✅ Upgrade to v1.4 Complete!${NC}"
echo "======================================"
echo ""
echo "🎯 What's New in v1.4:"
echo "  • ${BLUE}MQ6 Technical Research${NC} - All tech decisions trigger search"
echo "  • ${BLUE}Research Phase${NC} - Inline research + final tech review"
echo "  • ${BLUE}Skills System${NC} - .claude/skills/ knowledge base"
echo "  • ${BLUE}Learn System${NC} - /tad-learn records framework improvements"
echo "  • ${BLUE}Built-in Skills${NC} - ui-design.md, skill-creator.md"
echo ""
echo "📖 New Commands:"
echo "  ${BLUE}/tad-learn${NC} - Record framework improvements"
echo ""
echo "📁 New Directories:"
echo "  .claude/skills/        - Knowledge base files"
echo "  .tad/learnings/        - Framework learning records"
echo ""
echo "📚 Built-in Skills:"
echo "  .claude/skills/ui-design.md       - UI/UX design knowledge"
echo "  .claude/skills/skill-creator.md   - How to create new skills"
echo ""
echo "💡 To rollback: cp .tad/config.yaml.v1.3.bak .tad/config.yaml"
echo ""
