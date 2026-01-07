#!/bin/bash

# TAD Configuration Cleanup Script
# Purpose: Clean up multiple config versions, keep only config.yaml
# Version: 1.0

set -e

echo "=========================================="
echo "TAD Configuration Cleanup"
echo "=========================================="
echo ""

# Check if we're in a TAD project
if [ ! -d ".tad" ]; then
    echo "❌ Error: .tad directory not found"
    echo "This script must be run from a TAD project root."
    exit 1
fi

# Check current version
if [ -f ".tad/version.txt" ]; then
    VERSION=$(cat .tad/version.txt)
    echo "Current TAD version: $VERSION"
else
    echo "⚠️  Warning: version.txt not found"
    VERSION="unknown"
fi

echo ""
echo "This script will:"
echo "  1. Archive old config files (v1.1, v2) to .tad/archive/"
echo "  2. Rename config-v3.yaml to config.yaml (if not already symlink)"
echo "  3. Update agent file references to use config.yaml"
echo ""

# Ask for confirmation
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Starting cleanup..."
echo ""

# Step 1: Create archive directory
echo "[1/4] Creating archive directory..."
mkdir -p .tad/archive/configs
echo "✓ Archive directory created"

# Step 2: Archive old config files
echo ""
echo "[2/4] Archiving old config files..."

if [ -f ".tad/config-v1.1.yaml" ]; then
    mv .tad/config-v1.1.yaml .tad/archive/configs/
    echo "✓ config-v1.1.yaml → .tad/archive/configs/"
fi

if [ -f ".tad/config-v2.yaml" ]; then
    mv .tad/config-v2.yaml .tad/archive/configs/
    echo "✓ config-v2.yaml → .tad/archive/configs/"
fi

# Step 3: Handle config.yaml and config-v3.yaml
echo ""
echo "[3/4] Setting up main config file..."

# First check if v3 exists
if [ -f ".tad/config-v3.yaml" ]; then
    # v3 exists - this is the new master config

    if [ -L ".tad/config.yaml" ]; then
        # It's a symlink, remove it
        echo "  - Removing symlink config.yaml"
        rm .tad/config.yaml
    elif [ -f ".tad/config.yaml" ]; then
        # It's a regular file, archive it
        echo "  - Archiving old config.yaml"
        mv .tad/config.yaml .tad/archive/configs/config-old.yaml
    fi

    # Now rename v3 to config.yaml
    echo "  - Renaming config-v3.yaml to config.yaml"
    mv .tad/config-v3.yaml .tad/config.yaml
    echo "✓ Main config file: .tad/config.yaml (from v3)"
else
    # No v3 exists - check what we have
    if [ -f ".tad/config.yaml" ]; then
        echo "  ⚠️  Warning: No config-v3.yaml found"
        echo "  - Keeping existing config.yaml"
        echo "  - You may be on an older TAD version"
        echo "✓ Main config file: .tad/config.yaml (unchanged)"
    else
        echo "  ❌ Error: No config files found!"
        echo "  - Neither config-v3.yaml nor config.yaml exists"
        exit 1
    fi
fi

# Step 4: Update agent file references
echo ""
echo "[4/4] Updating agent file references..."

# Update agent-a
if [ -f ".tad/agents/agent-a-architect-v1.1.md" ]; then
    sed -i.bak 's/config-v1\.1\.yaml/config.yaml/g' .tad/agents/agent-a-architect-v1.1.md
    rm .tad/agents/agent-a-architect-v1.1.md.bak 2>/dev/null || true
    echo "✓ Updated agent-a-architect-v1.1.md"
fi

# Update agent-b
if [ -f ".tad/agents/agent-b-executor-v1.1.md" ]; then
    sed -i.bak 's/config-v1\.1\.yaml/config.yaml/g' .tad/agents/agent-b-executor-v1.1.md
    rm .tad/agents/agent-b-executor-v1.1.md.bak 2>/dev/null || true
    echo "✓ Updated agent-b-executor-v1.1.md"
fi

# Create a README in archive
cat > .tad/archive/configs/README.md << 'EOF'
# Archived TAD Configuration Files

These are historical configuration files from previous TAD versions.

## Files

- `config-v1.1.yaml` - TAD v1.1 configuration (BMAD integration)
- `config-v2.yaml` - TAD v2.0 configuration (experimental)
- `config-old.yaml` - Previous config.yaml (if existed)

## Purpose

These files are kept for:
1. Reference when debugging issues
2. Understanding TAD's evolution
3. Migrating custom configurations

## Current Configuration

The active configuration is: `.tad/config.yaml`

**Do not modify these archived files** - they are for reference only.

## TAD Version

These files were archived during upgrade to TAD v1.2+
Date: $(date +%Y-%m-%d)
EOF

echo "✓ Created archive README"

# Success message
echo ""
echo "=========================================="
echo "✅ Cleanup Complete!"
echo "=========================================="
echo ""
echo "Results:"
echo "  ✓ Old configs archived to .tad/archive/configs/"
echo "  ✓ Main config: .tad/config.yaml"
echo "  ✓ Agent files updated to reference config.yaml"
echo ""
echo "Files in archive:"
ls -lh .tad/archive/configs/*.yaml 2>/dev/null | awk '{print "  - " $9 " (" $5 ")"}'
echo ""
echo "Your TAD installation is now clean and ready to use!"
echo ""
