#!/bin/bash

# TAD Framework Quick Installer v1.2
# Usage: curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "======================================"
echo -e "${BLUE}TAD Framework Installer v1.2${NC}"
echo "======================================"
echo ""

# Detect if upgrading or fresh install
if [ -d ".tad" ]; then
    # Check version
    CURRENT_VERSION="1.0"
    if [ -f ".tad/version.txt" ]; then
        CURRENT_VERSION=$(cat .tad/version.txt)
    fi

    if [ "$CURRENT_VERSION" = "1.2" ]; then
        echo -e "${YELLOW}TAD v1.2 is already installed${NC}"
        echo "No installation needed"
        exit 0
    fi

    echo -e "${YELLOW}TAD v$CURRENT_VERSION detected${NC}"
    echo ""
    echo "Would you like to:"
    echo "1) Upgrade to v1.2 (preserves your work)"
    echo "2) Fresh install v1.2 (removes existing TAD)"
    echo "3) Cancel"
    echo ""
    read -p "Select option (1-3): " -n 1 -r
    echo ""

    if [[ $REPLY == "1" ]]; then
        echo "Running upgrade..."
        # Determine which upgrade script to use
        if [ "$CURRENT_VERSION" = "1.1" ]; then
            curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/upgrade-to-v1.2.sh | bash
        elif [ "$CURRENT_VERSION" = "1.0" ]; then
            echo "Upgrading from v1.0 to v1.2 (via v1.1)..."
            curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/upgrade-to-v1.1.sh | bash
            curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/upgrade-to-v1.2.sh | bash
        fi
        exit 0
    elif [[ $REPLY == "2" ]]; then
        echo "Performing fresh install..."
        # Backup important files
        if [ -d ".tad/working" ] || [ -d ".tad/context" ]; then
            BACKUP_DIR=".tad-backup-$(date +%Y%m%d-%H%M%S)"
            mkdir -p "$BACKUP_DIR"
            [ -d ".tad/working" ] && cp -r .tad/working "$BACKUP_DIR/"
            [ -d ".tad/context" ] && cp -r .tad/context "$BACKUP_DIR/"
            echo -e "${GREEN}✓ Backup created in $BACKUP_DIR${NC}"
        fi
        rm -rf .tad .claude/commands/tad*.md
    else
        echo "Installation cancelled"
        exit 0
    fi
fi

echo "🚀 Installing TAD Framework v1.2..."

# Check if in a git repository
if [ -d ".git" ]; then
    echo -e "${GREEN}✅ Git repository detected${NC}"
else
    echo -e "${YELLOW}⚠️  Not a git repository. Initializing...${NC}"
    git init
fi

# Download TAD from GitHub
echo ""
echo "📥 Downloading TAD Framework..."
curl -sSL https://github.com/Sheldon-92/TAD/archive/refs/heads/main.tar.gz | tar -xz

# Install core TAD files
echo "📦 Installing TAD core files..."

# Install .tad directory structure
if [ -d "TAD-main/.tad" ]; then
    cp -r TAD-main/.tad ./
    echo -e "${GREEN}✅ Installed .tad directory${NC}"
fi

# Install v1.1 specific files if not present in tar
mkdir -p .tad/tasks
mkdir -p .tad/workflows
mkdir -p .tad/data

# Merge .claude directory
if [ -d "TAD-main/.claude" ]; then
    mkdir -p .claude/commands
    # Copy all TAD commands including v1.1 commands
    cp TAD-main/.claude/commands/*.md .claude/commands/ 2>/dev/null || true
    # Only create settings.json if it doesn't exist
    if [ ! -f ".claude/settings.json" ]; then
        cp TAD-main/.claude/settings.json .claude/ 2>/dev/null || true
    fi
    echo -e "${GREEN}✅ Installed slash commands${NC}"
fi

# Create version marker
echo "1.2" > .tad/version.txt

# Create logs directory for MCP
mkdir -p .tad/logs

# Config.yaml is now a real file (not a symlink) after v1.2.2 cleanup
# No need to create symlink - config.yaml is copied directly from TAD-main/.tad/

# Install tad CLI script
if [ -f "TAD-main/tad" ]; then
    cp TAD-main/tad ./
    chmod +x tad
    echo -e "${GREEN}✅ Installed tad CLI${NC}"
fi

# Clean up
rm -rf TAD-main

# Update .gitignore for v1.2
echo "📝 Updating .gitignore..."
if [ ! -f ".gitignore" ]; then
    touch .gitignore
fi

# Check if TAD section exists in .gitignore
if ! grep -q "# TAD Framework" .gitignore 2>/dev/null; then
    cat >> .gitignore << 'EOF'

# TAD Framework
.tad/working/
.tad/context/PROJECT.md
.tad/context/REQUIREMENTS.md
.tad/context/ARCHITECTURE.md
.tad/context/DECISIONS.md
.tad/evidence/project-logs/*/
.tad/logs/
*.log
*.tmp

# Local settings
.claude/settings.local.json

# MCP (Model Context Protocol)
.tad/mcp-config.json
EOF
fi

# Create necessary directories
echo "📁 Creating directory structure..."
mkdir -p .tad/context
mkdir -p .tad/working
mkdir -p .tad/evidence/project-logs
mkdir -p .tad/evidence/patterns
mkdir -p .tad/evidence/metrics
mkdir -p .tad/evidence/gates
mkdir -p .tad/gates
mkdir -p .tad/tasks
mkdir -p .tad/workflows
mkdir -p .tad/data
mkdir -p .tad/checklists
mkdir -p .tad/templates

# Create .gitkeep files
touch .tad/context/.gitkeep
touch .tad/working/.gitkeep
touch .tad/evidence/project-logs/.gitkeep

echo ""
echo "======================================"
echo -e "${GREEN}✅ TAD Framework v1.2 Installed!${NC}"
echo "======================================"
echo ""
echo "🎯 What's New in v1.2:"
echo "  • ${BLUE}MCP Integration${NC} - 70-85% efficiency boost"
echo "  • ${BLUE}Smart project detection${NC} - Auto-recommend tools"
echo "  • ${BLUE}Enhanced elicitation${NC} - Round 0 & Round 2.5"
echo "  • ${BLUE}7 Core MCP tools${NC} - context7, memory-bank, etc."
echo "  • ${BLUE}Project-specific tools${NC} - Web, ML, DevOps, etc."
echo "  • ${BLUE}Comprehensive guide${NC} - 1176-line usage guide"
echo ""
echo "📚 Quick Start with Slash Commands:"
echo ""
echo "  ${YELLOW}Option 1: Main Menu${NC}"
echo "  Type: ${BLUE}/tad${NC}"
echo ""
echo "  ${YELLOW}Option 2: Direct Agent Activation${NC}"
echo "  Terminal 1: ${BLUE}/alex${NC}  (Activate Agent A - Solution Lead)"
echo "  Terminal 2: ${BLUE}/blake${NC} (Activate Agent B - Execution Master)"
echo ""
echo "  ${YELLOW}Option 3: Classic Activation${NC}"
echo "  Terminal 1: You are Agent A. Read .tad/agents/agent-a-architect-v1.1.md"
echo "  Terminal 2: You are Agent B. Read .tad/agents/agent-b-executor-v1.1.md"
echo ""
echo "📖 MCP Tools (Optional but Recommended):"
echo "  ${BLUE}Install core tools:${NC} tad mcp install --core"
echo "  ${BLUE}Read MCP guide:${NC}   cat .tad/MCP_USAGE_GUIDE.md"
echo "  ${BLUE}Check MCP status:${NC} tad mcp status"
echo ""
echo "📖 Useful Commands:"
echo "  ${BLUE}/tad-help${NC}     - Get help"
echo "  ${BLUE}/tad-status${NC}   - Check status"
echo "  ${BLUE}/elicit${NC}       - Start requirements"
echo "  ${BLUE}/parallel${NC}     - Use parallel execution"
echo "  ${BLUE}/gate${NC}         - Run quality gates"
echo ""
echo "📚 Documentation:"
echo "  • GitHub: https://github.com/Sheldon-92/TAD"
echo "  • MCP Guide: .tad/MCP_USAGE_GUIDE.md"
echo "  • Integration Summary: .tad/MCP_INTEGRATION_SUMMARY.md"
echo ""