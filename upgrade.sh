#!/bin/bash

# TAD Framework Upgrade Script v1.0 → v2.0
# Usage: curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/upgrade.sh | bash

echo "🔄 Upgrading TAD Framework v1.0 → v2.0..."

# Check if TAD v1.0 exists
if [ ! -d ".tad" ]; then
    echo "❌ No existing TAD installation found."
    echo "Use install.sh for fresh installation."
    exit 1
fi

echo "✅ Existing TAD installation detected"

# Backup existing configuration
echo "📦 Backing up existing configuration..."
if [ -d ".tad" ]; then
    cp -r .tad .tad-backup-$(date +%Y%m%d-%H%M%S)
    echo "✅ Backup created"
fi

# Download new TAD version
echo "📥 Downloading TAD Framework v2.0..."
curl -sSL https://github.com/Sheldon-92/TAD/archive/refs/heads/main.tar.gz | tar -xz

# Upgrade strategy: Replace core files, preserve project-specific data
echo "🔄 Upgrading TAD components..."

# 1. Upgrade agent definitions (these have major improvements)
if [ -d "TAD-main/.tad/agents" ]; then
    echo "  📝 Upgrading agent definitions..."
    cp TAD-main/.tad/agents/* .tad/agents/
    echo "  ✅ Agent definitions upgraded with v2.0 improvements"
fi

# 2. Add new template system
if [ -d "TAD-main/.tad/templates" ]; then
    echo "  📋 Installing new handoff templates..."
    mkdir -p .tad/templates
    cp -r TAD-main/.tad/templates/* .tad/templates/
    echo "  ✅ Handoff templates installed"
fi

# 3. Add new quality gate system
if [ -d "TAD-main/.tad/gates" ]; then
    echo "  🚪 Installing quality gate system..."
    mkdir -p .tad/gates
    cp -r TAD-main/.tad/gates/* .tad/gates/
    echo "  ✅ Quality gates installed"
fi

# 4. Add evidence collection system
if [ -d "TAD-main/.tad/evidence" ]; then
    echo "  📊 Installing evidence collection system..."
    mkdir -p .tad/evidence
    cp -r TAD-main/.tad/evidence/* .tad/evidence/
    echo "  ✅ Evidence system installed"
fi

# 5. Update configuration (preserve existing project context)
if [ -f "TAD-main/.tad/config.yaml" ]; then
    echo "  ⚙️  Updating configuration..."
    cp TAD-main/.tad/config.yaml .tad/
    echo "  ✅ Configuration updated to v2.0"
fi

# 6. Upgrade Claude commands
if [ -d "TAD-main/.claude/commands" ]; then
    echo "  🤖 Upgrading Claude commands..."
    mkdir -p .claude/commands
    cp TAD-main/.claude/commands/tad-*.md .claude/commands/
    echo "  ✅ Commands upgraded with new output formats"
fi

# 7. Create new working directories
echo "  📁 Setting up new directory structure..."
mkdir -p .tad/working/gates
touch .tad/working/gates/.gitkeep

# Clean up download
rm -rf TAD-main

# Clean up old .gitignore TAD rules (v1.4 improvement)
if [ -f ".gitignore" ]; then
    if grep -q "\.tad/" .gitignore 2>/dev/null; then
        echo "📝 Cleaning up old .gitignore TAD rules..."
        # Create a backup
        cp .gitignore .gitignore.backup

        # Remove all lines containing .tad/ ignores
        sed -i.tmp '/^\.tad\//d' .gitignore
        sed -i.tmp '/^# TAD v2\.0 Evidence System/d' .gitignore
        sed -i.tmp '/^# TAD Framework$/d' .gitignore

        # Remove the temporary file created by sed
        rm -f .gitignore.tmp

        # Add new TAD section if not exists
        if ! grep -q "# TAD Framework - Version Control Recommended" .gitignore 2>/dev/null; then
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

        echo "✅ Old .gitignore rules removed. Backup saved as .gitignore.backup"
    fi
fi

echo ""
echo "🎉 TAD Framework successfully upgraded to v2.0!"
echo ""
echo "🆕 New Features in v2.0:"
echo "  ✅ Mandatory startup checklists (fixes identity issues)"
echo "  ✅ Parameterized handoff templates (prevents incomplete specs)"
echo "  ✅ Quality gate system (prevents function errors & data flow issues)"
echo "  ✅ 16 real Claude Code sub-agents (no more fictional agents)"
echo "  ✅ Evidence collection (learn from successes and failures)"
echo ""
echo "📚 Updated Usage:"
echo "  Terminal 1: You are Agent A. Read .tad/agents/agent-a-architect.md"
echo "  Terminal 2: You are Agent B. Read .tad/agents/agent-b-executor.md"
echo ""
echo "🔍 Check installation: /tad-status"
echo "📖 Get help: /tad-help"
echo ""
echo "🔗 Documentation: https://github.com/Sheldon-92/TAD"