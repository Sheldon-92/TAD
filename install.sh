#!/bin/bash

# TAD Framework Quick Installer
# Usage: curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash

echo "🚀 Installing TAD Framework v2.0 (MVP Improved)..."

# Check if in a git repository
if [ -d ".git" ]; then
    echo "✅ Git repository detected"
else
    echo "⚠️  Not a git repository. Initializing..."
    git init
fi

# Check if TAD already exists
if [ -d ".tad" ]; then
    echo "⚠️  TAD already exists in this project."
    read -p "Do you want to reinstall? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    rm -rf .tad .claude
fi

# Download TAD from GitHub
echo "📥 Downloading TAD Framework..."
curl -sSL https://github.com/Sheldon-92/TAD/archive/refs/heads/main.tar.gz | tar -xz

# Only install necessary TAD files (not documentation)
echo "📦 Installing TAD core files..."

# Install .tad directory
if [ -d "TAD-main/.tad" ]; then
    cp -r TAD-main/.tad ./
    echo "✅ Installed .tad directory"
fi

# Merge .claude directory (don't overwrite existing)
if [ -d "TAD-main/.claude" ]; then
    mkdir -p .claude/commands
    # Only copy TAD commands, don't overwrite existing settings
    cp TAD-main/.claude/commands/tad-*.md .claude/commands/ 2>/dev/null
    # Only create settings.json if it doesn't exist
    if [ ! -f ".claude/settings.json" ]; then
        cp TAD-main/.claude/settings.json .claude/
    fi
    echo "✅ Merged .claude commands"
fi

# Clean up
rm -rf TAD-main

# Update .gitignore
if ! grep -q ".tad/working/" .gitignore 2>/dev/null; then
    echo "📝 Updating .gitignore..."
    cat >> .gitignore << 'EOF'

# TAD Framework
.tad/working/
.tad/context/*.md
!.tad/context/.gitkeep
EOF
fi

# Create initial directories including v2.0 additions
mkdir -p .tad/context
mkdir -p .tad/working
mkdir -p .tad/working/gates
mkdir -p .tad/evidence/project-logs
mkdir -p .tad/evidence/patterns
mkdir -p .tad/evidence/metrics
touch .tad/context/.gitkeep
touch .tad/working/.gitkeep
touch .tad/working/gates/.gitkeep
touch .tad/evidence/project-logs/.gitkeep

echo "✅ TAD Framework installed successfully!"
echo ""
echo "📚 Quick Start Guide:"
echo ""
echo "1. Open two Claude Code terminals"
echo ""
echo "2. In Terminal 1, activate Agent A:"
echo "   Copy and paste this:"
echo "   ----------------------------------------"
echo "   You are Agent A. Read .tad/agents/agent-a-architect.md"
echo "   ----------------------------------------"
echo ""
echo "3. In Terminal 2, activate Agent B:"
echo "   Copy and paste this:"
echo "   ----------------------------------------"
echo "   You are Agent B. Read .tad/agents/agent-b-executor.md"
echo "   ----------------------------------------"
echo ""
echo "4. Start working with TAD commands:"
echo "   /tad-status    - Check installation"
echo "   /tad-init      - Initialize project"
echo "   /tad-scenario  - Start a workflow"
echo "   /tad-help      - Get help"
echo ""
echo "Documentation: https://github.com/Sheldon-92/TAD"