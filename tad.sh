#!/bin/bash

# TAD Framework - Unified Install & Upgrade Script v2.0
# One command for all scenarios: fresh install, upgrade, or migration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Version
TARGET_VERSION="2.0"
REPO_URL="https://github.com/Sheldon-92/TAD"
DOWNLOAD_URL="https://github.com/Sheldon-92/TAD/archive/refs/heads/main.tar.gz"

echo ""
echo -e "${CYAN}=====================================${NC}"
echo -e "${CYAN}   TAD Framework v${TARGET_VERSION}${NC}"
echo -e "${CYAN}=====================================${NC}"
echo ""

# Detect current state
detect_state() {
    if [ ! -d ".tad" ] && [ ! -d ".claude/commands" ]; then
        echo "fresh"
    elif [ -f ".tad/version.txt" ]; then
        local ver=$(cat .tad/version.txt)
        if [[ "$ver" == "$TARGET_VERSION" ]]; then
            echo "current"
        elif [[ "$ver" == "1.8"* ]]; then
            echo "v1.8"
        elif [[ "$ver" == "1.6"* ]] || [[ "$ver" == "1.5"* ]]; then
            echo "v1.6"
        elif [[ "$ver" == "1.4"* ]]; then
            echo "v1.4"
        else
            echo "old"
        fi
    elif [ -d ".tad" ]; then
        # Has .tad but no version file - old version
        echo "old"
    else
        echo "partial"
    fi
}

STATE=$(detect_state)
CURRENT_VERSION="none"
if [ -f ".tad/version.txt" ]; then
    CURRENT_VERSION=$(cat .tad/version.txt)
fi

# Display current state
echo -e "${BLUE}📍 Detecting environment...${NC}"
echo ""

case $STATE in
    "fresh")
        echo -e "   Status: ${GREEN}Fresh install${NC}"
        echo "   No existing TAD installation found"
        ACTION="install"
        ;;
    "current")
        echo -e "   Status: ${GREEN}Already v${TARGET_VERSION}${NC}"
        echo "   You're on the latest version!"
        ACTION="none"
        ;;
    "v1.8")
        echo -e "   Status: ${YELLOW}Upgrade available${NC}"
        echo "   Current: v${CURRENT_VERSION} → Target: v${TARGET_VERSION}"
        echo "   (Will add Ralph Loop configuration)"
        ACTION="upgrade"
        ;;
    "v1.6")
        echo -e "   Status: ${YELLOW}Upgrade available${NC}"
        echo "   Current: v${CURRENT_VERSION} → Target: v${TARGET_VERSION}"
        ACTION="upgrade"
        ;;
    "v1.4"|"old")
        echo -e "   Status: ${YELLOW}Migration + Upgrade needed${NC}"
        echo "   Current: v${CURRENT_VERSION} → Target: v${TARGET_VERSION}"
        echo "   (Will migrate to new directory structure)"
        ACTION="migrate"
        ;;
    "partial")
        echo -e "   Status: ${YELLOW}Partial installation${NC}"
        echo "   Will complete installation"
        ACTION="install"
        ;;
esac

echo ""

# If already current, exit
if [ "$ACTION" == "none" ]; then
    echo -e "${GREEN}✅ Nothing to do. TAD v${TARGET_VERSION} is already installed.${NC}"
    echo ""
    echo "Available commands:"
    echo "  /alex  - Start Agent A (Solution Lead)"
    echo "  /blake - Start Agent B (Execution Master)"
    echo "  /gate  - Run quality gate"
    echo ""
    exit 0
fi

# Show what will happen
echo -e "${BLUE}📋 What will happen:${NC}"
echo ""

case $ACTION in
    "install")
        echo "  1. Create .tad/ directory structure"
        echo "  2. Create .claude/commands/ with TAD commands"
        echo "  3. Create .claude/skills/ with core skills"
        echo "  4. Create CLAUDE.md project rules"
        echo "  5. Create PROJECT_CONTEXT.md and NEXT.md"
        ;;
    "upgrade")
        echo "  1. Update .claude/commands/ (tad-*.md, research.md)"
        echo "  2. Update .claude/skills/ (archive old, add code-review/)"
        echo "  3. Update .tad/config.yaml and templates/"
        echo "  4. Add .tad/templates/output-formats/ (12 templates)"
        echo "  5. Update CLAUDE.md rules"
        echo ""
        echo -e "  ${GREEN}✓ Preserved:${NC} handoffs, learnings, evidence, project-knowledge"
        ;;
    "migrate")
        echo "  1. Backup existing .tad/ to .tad-backup/"
        echo "  2. Create new v1.6 directory structure"
        echo "  3. Migrate your handoffs and learnings"
        echo "  4. Install new commands and templates"
        echo ""
        echo -e "  ${GREEN}✓ Preserved:${NC} All your work data will be migrated"
        ;;
esac

echo ""
read -p "Continue? (y/n): " -n 1 -r < /dev/tty
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo -e "${BLUE}📥 Downloading TAD Framework v${TARGET_VERSION}...${NC}"

# Download
curl -sSL "$DOWNLOAD_URL" | tar -xz
TAD_SRC="TAD-main"

# Execute based on action
case $ACTION in
    "install")
        echo -e "${BLUE}📦 Installing TAD Framework...${NC}"

        # Create directories
        mkdir -p .tad/active/handoffs
        mkdir -p .tad/active/designs
        mkdir -p .tad/archive/handoffs
        mkdir -p .tad/evidence/reviews
        mkdir -p .tad/evidence/completions
        mkdir -p .tad/evidence/ralph-loops
        mkdir -p .tad/evidence/reviews/_iterations
        mkdir -p .tad/gates
        mkdir -p .tad/learnings/pending
        mkdir -p .tad/learnings/pushed
        mkdir -p .tad/project-knowledge
        mkdir -p .tad/templates/output-formats
        mkdir -p .tad/tasks
        mkdir -p .tad/reports
        mkdir -p .tad/ralph-config
        mkdir -p .tad/schemas
        mkdir -p .claude/commands
        mkdir -p .claude/skills

        # Copy framework files
        cp -r "$TAD_SRC"/.tad/config.yaml .tad/
        cp -r "$TAD_SRC"/.tad/skills-config.yaml .tad/ 2>/dev/null || true
        cp -r "$TAD_SRC"/.tad/gates/* .tad/gates/ 2>/dev/null || true
        cp -r "$TAD_SRC"/.tad/templates/* .tad/templates/ 2>/dev/null || true
        cp -r "$TAD_SRC"/.tad/tasks/* .tad/tasks/ 2>/dev/null || true
        cp -r "$TAD_SRC"/.tad/README.md .tad/ 2>/dev/null || true
        cp -r "$TAD_SRC"/.tad/project-knowledge/README.md .tad/project-knowledge/ 2>/dev/null || true

        # Copy Ralph Loop config (v2.0)
        cp -r "$TAD_SRC"/.tad/ralph-config/* .tad/ralph-config/ 2>/dev/null || true
        cp -r "$TAD_SRC"/.tad/schemas/* .tad/schemas/ 2>/dev/null || true

        # Copy commands
        cp "$TAD_SRC"/.claude/commands/*.md .claude/commands/
        cp "$TAD_SRC"/.claude/settings.json .claude/ 2>/dev/null || true

        # Copy skills (only active ones)
        cp -r "$TAD_SRC"/.claude/skills/code-review .claude/skills/ 2>/dev/null || true
        cp "$TAD_SRC"/.claude/skills/doc-organization.md .claude/skills/ 2>/dev/null || true

        # Copy root files
        cp "$TAD_SRC"/CLAUDE.md ./

        # Create user files if not exist
        if [ ! -f "PROJECT_CONTEXT.md" ]; then
            cat > PROJECT_CONTEXT.md << 'CTXEOF'
# Project Context

## Project Name
[Your Project Name]

## Description
[Brief project description]

## Tech Stack
- [Technology 1]
- [Technology 2]

## Key Decisions
(Alex will update this during development)

---
*Last Updated: [Date]*
CTXEOF
        fi

        if [ ! -f "NEXT.md" ]; then
            cat > NEXT.md << 'NEXTEOF'
# Next Steps

## Today

- [ ] [Your first task]

## This Week

- [ ] [Upcoming tasks]

## Completed

(Move completed items here)

---
*Managed by TAD Framework*
NEXTEOF
        fi

        # Set version
        echo "$TARGET_VERSION" > .tad/version.txt
        ;;

    "upgrade")
        echo -e "${BLUE}📦 Upgrading to v${TARGET_VERSION}...${NC}"

        # Ensure directories exist
        mkdir -p .tad/templates/output-formats
        mkdir -p .tad/tasks
        mkdir -p .tad/evidence/reviews
        mkdir -p .tad/evidence/completions
        mkdir -p .tad/evidence/ralph-loops
        mkdir -p .tad/evidence/reviews/_iterations
        mkdir -p .tad/project-knowledge
        mkdir -p .tad/ralph-config
        mkdir -p .tad/schemas
        mkdir -p .claude/skills/code-review

        # Update commands
        echo "  → Updating commands..."
        cp "$TAD_SRC"/.claude/commands/*.md .claude/commands/
        cp "$TAD_SRC"/.claude/settings.json .claude/ 2>/dev/null || true

        # Update skills - archive old, add new structure
        echo "  → Restructuring skills..."
        if [ -d ".claude/skills" ] && [ ! -d ".claude/skills/_archived" ]; then
            mkdir -p .claude/skills/_archived
            # Move old skills to archive (except code-review dir and doc-organization)
            for f in .claude/skills/*.md; do
                if [ -f "$f" ] && [ "$(basename "$f")" != "doc-organization.md" ]; then
                    mv "$f" .claude/skills/_archived/ 2>/dev/null || true
                fi
            done
        fi
        cp -r "$TAD_SRC"/.claude/skills/code-review/* .claude/skills/code-review/ 2>/dev/null || true

        # Update config
        echo "  → Updating config..."
        cp "$TAD_SRC"/.tad/config.yaml .tad/
        cp "$TAD_SRC"/.tad/skills-config.yaml .tad/ 2>/dev/null || true

        # Update gates
        echo "  → Updating gates..."
        cp -r "$TAD_SRC"/.tad/gates/* .tad/gates/ 2>/dev/null || true

        # Update templates
        echo "  → Updating templates..."
        cp -r "$TAD_SRC"/.tad/templates/* .tad/templates/

        # Update tasks
        echo "  → Updating tasks..."
        cp -r "$TAD_SRC"/.tad/tasks/* .tad/tasks/ 2>/dev/null || true

        # Install Ralph Loop config (v2.0 NEW)
        echo "  → Installing Ralph Loop config..."
        cp -r "$TAD_SRC"/.tad/ralph-config/* .tad/ralph-config/ 2>/dev/null || true
        cp -r "$TAD_SRC"/.tad/schemas/* .tad/schemas/ 2>/dev/null || true

        # Update CLAUDE.md
        echo "  → Updating CLAUDE.md..."
        cp "$TAD_SRC"/CLAUDE.md ./

        # Update project-knowledge README
        cp "$TAD_SRC"/.tad/project-knowledge/README.md .tad/project-knowledge/ 2>/dev/null || true

        # Set version
        echo "$TARGET_VERSION" > .tad/version.txt
        ;;

    "migrate")
        echo -e "${BLUE}📦 Migrating and upgrading to v${TARGET_VERSION}...${NC}"

        # Backup
        echo "  → Creating backup..."
        if [ -d ".tad-backup" ]; then
            rm -rf .tad-backup
        fi
        cp -r .tad .tad-backup

        # Create new structure
        echo "  → Creating new directory structure..."
        mkdir -p .tad/active/handoffs
        mkdir -p .tad/active/designs
        mkdir -p .tad/archive/handoffs
        mkdir -p .tad/evidence/reviews
        mkdir -p .tad/evidence/completions
        mkdir -p .tad/evidence/ralph-loops
        mkdir -p .tad/evidence/reviews/_iterations
        mkdir -p .tad/gates
        mkdir -p .tad/learnings/pending
        mkdir -p .tad/learnings/pushed
        mkdir -p .tad/project-knowledge
        mkdir -p .tad/templates/output-formats
        mkdir -p .tad/tasks
        mkdir -p .tad/reports
        mkdir -p .tad/ralph-config
        mkdir -p .tad/schemas
        mkdir -p .claude/commands
        mkdir -p .claude/skills/_archived
        mkdir -p .claude/skills/code-review

        # Migrate user data from backup
        echo "  → Migrating user data..."
        # Handoffs
        if [ -d ".tad-backup/handoffs" ]; then
            cp -r .tad-backup/handoffs/* .tad/active/handoffs/ 2>/dev/null || true
        fi
        if [ -d ".tad-backup/active/handoffs" ]; then
            cp -r .tad-backup/active/handoffs/* .tad/active/handoffs/ 2>/dev/null || true
        fi
        # Learnings
        if [ -d ".tad-backup/learnings" ]; then
            cp -r .tad-backup/learnings/* .tad/learnings/ 2>/dev/null || true
        fi
        # Working/context
        if [ -d ".tad-backup/working" ]; then
            cp -r .tad-backup/working/* .tad/active/ 2>/dev/null || true
        fi
        if [ -d ".tad-backup/context" ]; then
            cp -r .tad-backup/context/* .tad/active/ 2>/dev/null || true
        fi

        # Copy new framework files
        echo "  → Installing framework files..."
        cp -r "$TAD_SRC"/.tad/config.yaml .tad/
        cp -r "$TAD_SRC"/.tad/skills-config.yaml .tad/ 2>/dev/null || true
        cp -r "$TAD_SRC"/.tad/gates/* .tad/gates/ 2>/dev/null || true
        cp -r "$TAD_SRC"/.tad/templates/* .tad/templates/
        cp -r "$TAD_SRC"/.tad/tasks/* .tad/tasks/ 2>/dev/null || true
        cp -r "$TAD_SRC"/.tad/README.md .tad/ 2>/dev/null || true
        cp -r "$TAD_SRC"/.tad/project-knowledge/README.md .tad/project-knowledge/ 2>/dev/null || true

        # Install Ralph Loop config (v2.0 NEW)
        echo "  → Installing Ralph Loop config..."
        cp -r "$TAD_SRC"/.tad/ralph-config/* .tad/ralph-config/ 2>/dev/null || true
        cp -r "$TAD_SRC"/.tad/schemas/* .tad/schemas/ 2>/dev/null || true

        # Copy commands
        echo "  → Installing commands..."
        cp "$TAD_SRC"/.claude/commands/*.md .claude/commands/
        cp "$TAD_SRC"/.claude/settings.json .claude/ 2>/dev/null || true

        # Archive old skills, add new
        echo "  → Restructuring skills..."
        if [ -d ".claude/skills" ]; then
            for f in .claude/skills/*.md; do
                if [ -f "$f" ] && [ "$(basename "$f")" != "doc-organization.md" ]; then
                    mv "$f" .claude/skills/_archived/ 2>/dev/null || true
                fi
            done
        fi
        cp -r "$TAD_SRC"/.claude/skills/code-review/* .claude/skills/code-review/ 2>/dev/null || true

        # Copy root files
        cp "$TAD_SRC"/CLAUDE.md ./

        # Create user files if not exist
        if [ ! -f "PROJECT_CONTEXT.md" ]; then
            cat > PROJECT_CONTEXT.md << 'CTXEOF'
# Project Context

## Project Name
[Your Project Name]

## Description
[Brief project description]

## Tech Stack
- [Technology 1]
- [Technology 2]

## Key Decisions
(Alex will update this during development)

---
*Last Updated: [Date]*
CTXEOF
        fi

        if [ ! -f "NEXT.md" ]; then
            cat > NEXT.md << 'NEXTEOF'
# Next Steps

## Today

- [ ] [Your first task]

## This Week

- [ ] [Upcoming tasks]

## Completed

(Move completed items here)

---
*Managed by TAD Framework*
NEXTEOF
        fi

        # Set version
        echo "$TARGET_VERSION" > .tad/version.txt

        echo ""
        echo -e "  ${GREEN}✓ Backup saved to .tad-backup/${NC}"
        ;;
esac

# Cleanup
rm -rf "$TAD_SRC"

# Remove deprecated files
rm -f .tad/agents/agent-a-architect*.md 2>/dev/null || true
rm -f .tad/agents/agent-b-executor*.md 2>/dev/null || true

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}   ✅ TAD v${TARGET_VERSION} Ready!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "Directory structure:"
echo "  .tad/"
echo "  ├── active/handoffs/     # Current work"
echo "  ├── archive/handoffs/    # Completed work"
echo "  ├── evidence/"
echo "  │   ├── reviews/         # Gate evidence"
echo "  │   └── ralph-loops/     # Ralph iteration evidence (NEW)"
echo "  ├── ralph-config/        # Ralph Loop configuration (NEW)"
echo "  ├── schemas/             # JSON Schema validation (NEW)"
echo "  ├── project-knowledge/   # Project-specific knowledge"
echo "  └── templates/           # Handoff & output templates"
echo ""
echo "Quick start:"
echo "  1. Restart Claude Code (or open new terminal)"
echo "  2. Use ${CYAN}/alex${NC} to start Agent A (planning)"
echo "  3. Use ${CYAN}/blake${NC} to start Agent B (execution)"
echo "  4. Use ${CYAN}/gate${NC} to run quality checks"
echo ""
echo "Learn more: ${BLUE}${REPO_URL}${NC}"
echo ""
