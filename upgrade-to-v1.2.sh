#!/bin/bash

# TAD Framework v1.1 → v1.2 Upgrade Script
# MCP Integration Enhancement

set -e

echo "========================================"
echo "TAD Framework v1.1 → v1.2 Upgrade"
echo "MCP Integration Enhancement"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .tad directory exists (already installed)
if [ ! -d ".tad" ]; then
    echo -e "${RED}Error: .tad directory not found${NC}"
    echo "This script is for upgrading existing TAD v1.1 installations."
    echo "For new installation, please run: bash install.sh"
    exit 1
fi

# Check current version
if [ -f ".tad/version.txt" ]; then
    CURRENT_VERSION=$(cat .tad/version.txt)
    echo -e "Current version: ${YELLOW}v${CURRENT_VERSION}${NC}"
else
    echo -e "${YELLOW}Warning: version.txt not found, assuming v1.1${NC}"
    CURRENT_VERSION="1.1"
fi

# Verify version
if [ "$CURRENT_VERSION" != "1.1" ]; then
    echo -e "${RED}Error: This upgrade script is for v1.1 only${NC}"
    echo "Current version: v${CURRENT_VERSION}"
    exit 1
fi

echo ""
echo "This upgrade will add MCP integration to your TAD installation."
echo ""
echo "Changes:"
echo "  ✓ Add MCP tool registry and configuration"
echo "  ✓ Enhance requirement elicitation with MCP"
echo "  ✓ Update agent definitions (Alex & Blake)"
echo "  ✓ Add project type detection"
echo "  ✓ Add comprehensive MCP usage guide"
echo ""
echo "Your existing configurations and data will be preserved."
echo ""

# Ask for confirmation
read -p "Continue with upgrade? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Upgrade cancelled."
    exit 0
fi

echo ""
echo "Starting upgrade..."
echo ""

# Backup current installation
BACKUP_DIR=".tad_backup_$(date +%Y%m%d_%H%M%S)"
echo "Creating backup at ${BACKUP_DIR}..."
cp -r .tad "$BACKUP_DIR"
echo -e "${GREEN}✓ Backup created${NC}"

# Step 1: Add new MCP files
echo ""
echo "[1/6] Adding MCP configuration files..."

# Copy new files from repository
NEW_FILES=(
    ".tad/mcp-registry.yaml"
    ".tad/project-detection.yaml"
    ".tad/MCP_USAGE_GUIDE.md"
    ".tad/MCP_INTEGRATION_SUMMARY.md"
)

for file in "${NEW_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file already exists (from git pull)"
    else
        echo "  ✗ $file not found - please run 'git pull' first"
        exit 1
    fi
done

echo -e "${GREEN}✓ MCP files verified${NC}"

# Step 2: Update requirement-elicitation.md
echo ""
echo "[2/6] Updating requirement elicitation task..."
# File already updated via git, just verify
if grep -q "Round 0: MCP Pre-Elicitation Checks" .tad/tasks/requirement-elicitation.md; then
    echo -e "${GREEN}✓ requirement-elicitation.md updated${NC}"
else
    echo -e "${YELLOW}⚠ requirement-elicitation.md may need manual update${NC}"
fi

# Step 3: Update agent definitions
echo ""
echo "[3/6] Updating agent definitions..."

# Verify Alex (Agent A) update
if grep -q "mcp_integration:" .tad/agents/agent-a-architect-v1.1.md; then
    echo -e "${GREEN}✓ Agent A (Alex) updated with MCP integration${NC}"
else
    echo -e "${YELLOW}⚠ Agent A may need manual update${NC}"
fi

# Verify Blake (Agent B) update
if grep -q "mcp_integration:" .tad/agents/agent-b-executor-v1.1.md; then
    echo -e "${GREEN}✓ Agent B (Blake) updated with MCP integration${NC}"
else
    echo -e "${YELLOW}⚠ Agent B may need manual update${NC}"
fi

# Step 4: Update config-v3.yaml (if using)
echo ""
echo "[4/6] Checking config file..."

if [ -f ".tad/config-v3.yaml" ]; then
    if grep -q "mcp_tools:" .tad/config-v3.yaml; then
        echo -e "${GREEN}✓ config-v3.yaml updated with MCP enforcement${NC}"
    else
        echo -e "${YELLOW}⚠ config-v3.yaml may need manual update${NC}"
    fi
else
    echo "  ℹ config-v3.yaml not in use, skipping"
fi

# Step 5: Clean up config files
echo ""
echo "[5/7] Cleaning up configuration files..."

# Create archive directory
mkdir -p .tad/archive/configs

# Archive old config files
if [ -f ".tad/config-v1.1.yaml" ]; then
    mv .tad/config-v1.1.yaml .tad/archive/configs/
    echo "  ✓ config-v1.1.yaml → .tad/archive/configs/"
fi

if [ -f ".tad/config-v2.yaml" ]; then
    mv .tad/config-v2.yaml .tad/archive/configs/
    echo "  ✓ config-v2.yaml → .tad/archive/configs/"
fi

# Handle config.yaml and config-v3.yaml
if [ -f ".tad/config-v3.yaml" ]; then
    if [ -L ".tad/config.yaml" ]; then
        # It's a symlink, remove it
        rm .tad/config.yaml
    elif [ -f ".tad/config.yaml" ]; then
        # It's a regular file, archive it
        mv .tad/config.yaml .tad/archive/configs/config-old.yaml
    fi

    # Rename v3 to config.yaml
    mv .tad/config-v3.yaml .tad/config.yaml
    echo "  ✓ Main config: .tad/config.yaml (from v3)"
fi

# Update agent file references
sed -i.bak 's/config-v1\.1\.yaml/config.yaml/g' .tad/agents/agent-a-architect-v1.1.md 2>/dev/null && rm .tad/agents/agent-a-architect-v1.1.md.bak 2>/dev/null || true
sed -i.bak 's/config-v1\.1\.yaml/config.yaml/g' .tad/agents/agent-b-executor-v1.1.md 2>/dev/null && rm .tad/agents/agent-b-executor-v1.1.md.bak 2>/dev/null || true

echo -e "${GREEN}✓ Configuration files cleaned up${NC}"

# Step 6: Update version
echo ""
echo "[6/7] Updating version..."
echo "1.2" > .tad/version.txt
echo -e "${GREEN}✓ Version updated to 1.2${NC}"

# Step 7: Create logs directory (if not exists)
echo ""
echo "[7/7] Setting up MCP directories..."
mkdir -p .tad/logs
echo -e "${GREEN}✓ Logs directory ready${NC}"

# Success message
echo ""
echo "========================================"
echo -e "${GREEN}Upgrade Complete!${NC}"
echo "========================================"
echo ""
echo "TAD Framework is now at v1.2 with MCP Enhancement"
echo ""
echo "What's New:"
echo "  • MCP (Model Context Protocol) tool integration"
echo "  • Smart project type detection (Round 2.5)"
echo "  • Enhanced requirement elicitation (Round 0)"
echo "  • 70-85% efficiency improvement potential"
echo ""
echo "Next Steps:"
echo "  1. Verify installation: ./tad doctor"
echo "  2. Read the MCP Usage Guide: .tad/MCP_USAGE_GUIDE.md"
echo "  3. Start development: /alex or /blake"
echo "  4. Alex will auto-install MCP tools when needed (Round 2.5)"
echo ""
echo "Backup saved at: ${BACKUP_DIR}"
echo "If you encounter issues, restore with:"
echo "  rm -rf .tad && mv ${BACKUP_DIR} .tad"
echo ""
echo "Happy coding! 🚀"
