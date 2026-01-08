#!/bin/bash

# TAD Framework Quick Installer v1.5
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
echo -e "${BLUE}TAD Framework Installer v1.5${NC}"
echo "======================================"
echo ""

# Detect if upgrading or fresh install
if [ -d ".tad" ]; then
    # Check version
    CURRENT_VERSION="1.0"
    if [ -f ".tad/version.txt" ]; then
        CURRENT_VERSION=$(cat .tad/version.txt)
    fi

    if [ "$CURRENT_VERSION" = "1.5" ] || [ "$CURRENT_VERSION" = "1.5.0" ]; then
        echo -e "${YELLOW}TAD v1.5 is already installed${NC}"
        echo "No installation needed"
        exit 0
    fi

    # For v1.4 users, recommend migration script
    if [ "$CURRENT_VERSION" = "1.4" ] || [ "$CURRENT_VERSION" = "1.4.0" ]; then
        echo -e "${YELLOW}TAD v1.4 detected${NC}"
        echo ""
        echo -e "${BLUE}⭐ Recommended: Use migration script for v1.5${NC}"
        echo "  curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/migrate-to-v1.5.sh | bash"
        echo ""
        echo "Or force fresh install (will lose tad-work/ separation benefits):"
        read -p "Continue with fresh install? (y/n): " -n 1 -r < /dev/tty
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi

    echo -e "${YELLOW}TAD v$CURRENT_VERSION detected${NC}"
    echo ""
    echo "Would you like to:"
    echo "1) Migrate to v1.5 (recommended - preserves work + new structure)"
    echo "2) Fresh install v1.5 (removes existing TAD)"
    echo "3) Cancel"
    echo ""
    read -p "Select option (1-3): " -n 1 -r < /dev/tty
    echo ""

    if [[ $REPLY == "1" ]]; then
        echo "Running migration to v1.5..."
        curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/migrate-to-v1.5.sh | bash
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

echo "🚀 Installing TAD Framework v1.4..."

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
echo "1.5" > .tad/version.txt

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

# Install tad-work README (v1.5)
if [ -f "TAD-main/tad-work/README.md" ]; then
    cp TAD-main/tad-work/README.md tad-work/
    echo -e "${GREEN}✅ Installed tad-work README${NC}"
fi

# Clean up
rm -rf TAD-main

# Update .gitignore for v1.5
echo "📝 Updating .gitignore..."
if [ ! -f ".gitignore" ]; then
    touch .gitignore
fi

# Check if TAD section exists in .gitignore
if ! grep -q "# TAD Framework" .gitignore 2>/dev/null; then
    cat >> .gitignore << 'EOF'

# TAD Framework - Version Control Recommended
# ⚠️  IMPORTANT: TAD files SHOULD be version controlled to preserve development history
# Only exclude user-specific local settings below

# Local settings (user-specific, should not be shared)
.claude/settings.local.json

# Temporary files
*.log
*.tmp
*.bak
EOF
fi

# Create necessary directories
echo "📁 Creating directory structure..."
# Framework directories (.tad/)
mkdir -p .tad/tasks
mkdir -p .tad/workflows
mkdir -p .tad/data
mkdir -p .tad/checklists
mkdir -p .tad/templates
mkdir -p .tad/learnings/pending
mkdir -p .tad/learnings/pushed
mkdir -p .claude/skills

# User work directories (tad-work/) - NEW in v1.5
mkdir -p tad-work/handoffs
mkdir -p tad-work/archive
mkdir -p tad-work/context
mkdir -p tad-work/working
mkdir -p tad-work/evidence/gates
mkdir -p tad-work/evidence/patterns
mkdir -p tad-work/evidence/metrics
mkdir -p tad-work/evidence/project-logs

# Create .gitkeep files
touch tad-work/handoffs/.gitkeep
touch tad-work/context/.gitkeep
touch tad-work/working/.gitkeep
touch tad-work/evidence/project-logs/.gitkeep

echo ""
echo "======================================"
echo -e "${GREEN}✅ TAD Framework v1.5 Installed!${NC}"
echo "======================================"
echo ""
echo "🎯 What's New in v1.5:"
echo "  • ${BLUE}Directory Separation${NC} - .tad/ (framework) + tad-work/ (your data)"
echo "  • ${BLUE}Safe Upgrades${NC} - Framework updates won't touch your work"
echo "  • ${BLUE}Clear Ownership${NC} - Know what's framework vs your files"
echo "  • ${BLUE}Better Git Control${NC} - Separate .gitignore rules"
echo ""
echo "🎯 Previous Features (v1.4 & earlier):"
echo "  • ${BLUE}Skills System${NC} - 42 built-in skills, auto-match"
echo "  • ${BLUE}MQ6 Research${NC} - Proactive technical research"
echo "  • ${BLUE}Evidence-Based${NC} - MQ1-5 prevent common failures"
echo "  • ${BLUE}Learn System${NC} - Framework improvement tracking"
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
echo "  Terminal 1: You are Agent A. Read .tad/agents/agent-a-architect.md"
echo "  Terminal 2: You are Agent B. Read .tad/agents/agent-b-executor.md"
echo ""
echo "📖 MCP Tools (Optional but Recommended):"
echo "  ${BLUE}Install core tools:${NC} tad mcp install --core"
echo "  ${BLUE}Read MCP guide:${NC}   cat .tad/MCP_USAGE_GUIDE.md"
echo "  ${BLUE}Check MCP status:${NC} tad mcp status"
echo ""
echo "📖 Useful Commands:"
echo "  ${BLUE}/tad-help${NC}     - Get help"
echo "  ${BLUE}/tad-status${NC}   - Check status"
echo "  ${BLUE}/tad-learn${NC}    - Record framework improvements (v1.4)"
echo "  ${BLUE}/elicit${NC}       - Start requirements"
echo "  ${BLUE}/parallel${NC}     - Use parallel execution"
echo "  ${BLUE}/gate${NC}         - Run quality gates"
echo ""
echo "📚 Documentation:"
echo "  • GitHub: https://github.com/Sheldon-92/TAD"
echo "  • MCP Guide: .tad/MCP_USAGE_GUIDE.md"
echo "  • Integration Summary: .tad/MCP_INTEGRATION_SUMMARY.md"
echo ""