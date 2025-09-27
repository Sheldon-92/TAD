#!/bin/bash

# TAD Framework Quick Installer
# Usage: curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash

echo "🚀 Installing TAD Framework v1.0..."

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

# Move files to correct locations
echo "📦 Installing TAD files..."
mv TAD-main/.tad ./
mv TAD-main/.claude ./
cp TAD-main/WORKFLOW_PLAYBOOK.md ./
cp TAD-main/CLAUDE_CODE_SUBAGENTS.md ./
cp TAD-main/README.md ./.tad/
cp TAD-main/CONFIG_AGENT_PROMPT.md ./.tad/

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

# Create initial directories
mkdir -p .tad/context
mkdir -p .tad/working
touch .tad/context/.gitkeep
touch .tad/working/.gitkeep

echo "✅ TAD Framework installed successfully!"
echo ""
echo "Next steps:"
echo "1. Open project with Claude Code: claude ."
echo "2. Run /tad-status to verify installation"
echo "3. Run /tad-init to initialize project"
echo "4. Start with /tad-scenario [scenario_name]"
echo ""
echo "Available scenarios:"
echo "  - new_project"
echo "  - add_feature"
echo "  - bug_fix"
echo "  - performance"
echo "  - refactoring"
echo "  - deployment"
echo ""
echo "Documentation: https://github.com/Sheldon-92/TAD"