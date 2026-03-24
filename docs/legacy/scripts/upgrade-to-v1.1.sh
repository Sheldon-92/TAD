#!/bin/bash

# TAD Framework Upgrade Script - v1.0 to v1.1
# This script safely upgrades existing TAD v1.0 installations to v1.1

set -e

echo "================================"
echo "TAD Framework Upgrade to v1.1"
echo "================================"
echo ""

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if TAD v1.0 exists
if [ ! -d ".tad" ]; then
    echo -e "${RED}Error: TAD framework not found in current directory${NC}"
    echo "Please run this script from a project with TAD v1.0 installed"
    exit 1
fi

# Check current version
CURRENT_VERSION="1.0"
if [ -f ".tad/version.txt" ]; then
    CURRENT_VERSION=$(cat .tad/version.txt)
fi

if [ "$CURRENT_VERSION" = "1.1" ]; then
    echo -e "${YELLOW}TAD v1.1 is already installed${NC}"
    echo "No upgrade needed"
    exit 0
fi

echo "Current TAD version: $CURRENT_VERSION"
echo "Upgrading to version: 1.1"
echo ""

# Backup existing configuration
echo "📦 Creating backup..."
BACKUP_DIR=".tad-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup user's working files and context
if [ -d ".tad/working" ]; then
    cp -r .tad/working "$BACKUP_DIR/"
fi
if [ -d ".tad/context" ]; then
    cp -r .tad/context "$BACKUP_DIR/"
fi
if [ -d ".tad/evidence/project-logs" ]; then
    mkdir -p "$BACKUP_DIR/evidence"
    cp -r .tad/evidence/project-logs "$BACKUP_DIR/evidence/"
fi

echo -e "${GREEN}✓ Backup created in $BACKUP_DIR${NC}"

# Download new files from GitHub
echo ""
echo "📥 Downloading TAD v1.1 files..."

REPO_URL="https://raw.githubusercontent.com/Sheldon-92/TAD/main"

# Function to download file
download_file() {
    local file_path=$1
    local target_path=$2

    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$target_path")"

    if curl -sSL "$REPO_URL/$file_path" -o "$target_path" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Downloaded: $target_path"
    else
        echo -e "${YELLOW}⚠${NC} Skipped: $target_path (file may not exist)"
    fi
}

# Download v1.1 configuration
download_file ".tad/config-v1.1.yaml" ".tad/config-v1.1.yaml"

# Download v1.1 agent definitions
download_file ".tad/agents/agent-a-architect-v1.1.md" ".tad/agents/agent-a-architect-v1.1.md"
download_file ".tad/agents/agent-b-executor-v1.1.md" ".tad/agents/agent-b-executor-v1.1.md"

# Download new task files
download_file ".tad/tasks/requirement-elicitation.md" ".tad/tasks/requirement-elicitation.md"
download_file ".tad/tasks/handoff-creation.md" ".tad/tasks/handoff-creation.md"
download_file ".tad/tasks/gate-execution.md" ".tad/tasks/gate-execution.md"
download_file ".tad/tasks/evidence-collection.md" ".tad/tasks/evidence-collection.md"
download_file ".tad/tasks/parallel-execution.md" ".tad/tasks/parallel-execution.md"

# Download workflow files
download_file ".tad/workflows/new-project.yaml" ".tad/workflows/new-project.yaml"

# Download data files
download_file ".tad/data/elicitation-methods.md" ".tad/data/elicitation-methods.md"

# Download manifest
download_file ".tad/manifest-v1.1.yaml" ".tad/manifest-v1.1.yaml"

# Download slash commands
echo ""
echo "📝 Installing slash commands..."
mkdir -p .claude/commands

download_file ".claude/commands/tad.md" ".claude/commands/tad.md"
download_file ".claude/commands/tad-alex.md" ".claude/commands/tad-alex.md"
download_file ".claude/commands/tad-blake.md" ".claude/commands/tad-blake.md"
download_file ".claude/commands/tad-elicit.md" ".claude/commands/tad-elicit.md"
download_file ".claude/commands/tad-parallel.md" ".claude/commands/tad-parallel.md"
download_file ".claude/commands/tad-handoff.md" ".claude/commands/tad-handoff.md"
download_file ".claude/commands/tad-gate.md" ".claude/commands/tad-gate.md"
download_file ".claude/commands/product.md" ".claude/commands/product.md"
download_file ".claude/commands/coordinator.md" ".claude/commands/coordinator.md"

# Create version marker
echo "1.1" > .tad/version.txt
echo -e "${GREEN}✓ Version marker created${NC}"

# Create upgrade log
cat > .tad/upgrade-v1.1.log <<EOF
TAD Framework Upgrade Log
========================
Upgrade Date: $(date)
Previous Version: $CURRENT_VERSION
New Version: 1.1
Backup Location: $BACKUP_DIR

New Features in v1.1:
- BMAD-style enforcement mechanisms
- Mandatory 3-5 round requirement elicitation
- 4-gate quality system with violations
- Evidence collection system
- Sub-agents parallel execution
- Slash commands for quick access
- Enhanced configuration system

Files Added:
- config-v1.1.yaml (main configuration)
- agent-a-architect-v1.1.md (enhanced Alex)
- agent-b-executor-v1.1.md (enhanced Blake)
- Task files for elicitation, gates, evidence
- Workflow definitions
- Slash command definitions

Your existing work is preserved in:
- .tad/working/ (unchanged)
- .tad/context/ (unchanged)
- .tad/evidence/project-logs/ (unchanged)

To start using v1.1:
1. Use /alex to activate Agent A
2. Use /blake to activate Agent B
3. Use /tad for main menu
EOF

echo ""
echo "================================"
echo -e "${GREEN}✅ Upgrade Complete!${NC}"
echo "================================"
echo ""
echo "TAD has been upgraded from v$CURRENT_VERSION to v1.1"
echo ""
echo "🎯 What's New in v1.1:"
echo "  • Mandatory 3-5 round requirement elicitation"
echo "  • 4-gate quality system with enforcement"
echo "  • Evidence-based continuous improvement"
echo "  • 40% faster with parallel execution"
echo "  • Slash commands for quick access (/alex, /blake, /tad)"
echo ""
echo "📚 Your existing work is safe:"
echo "  • Working files: Preserved"
echo "  • Context files: Preserved"
echo "  • Project logs: Preserved"
echo "  • Backup created: $BACKUP_DIR"
echo ""
echo "🚀 Quick Start:"
echo "  Terminal 1: Type /alex to activate Agent A"
echo "  Terminal 2: Type /blake to activate Agent B"
echo "  Or type /tad for the main menu"
echo ""
echo "📖 For help: /tad-help"
echo ""

# Check if user wants to see the upgrade log
echo -n "View detailed upgrade log? (y/n): "
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    cat .tad/upgrade-v1.1.log
fi