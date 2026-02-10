#!/bin/bash

# TAD Framework - Unified Install & Upgrade Script v2.2
# Multi-Platform Support: Claude Code, Codex CLI, Gemini CLI
# One command for all scenarios: fresh install, upgrade, or migration

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Version
TARGET_VERSION="2.2"
REPO_URL="https://github.com/Sheldon-92/TAD"
DOWNLOAD_URL="https://github.com/Sheldon-92/TAD/archive/refs/heads/main.tar.gz"

# Global variables
BACKUP_PATH=""
DETECTED_PLATFORMS=""

# ============================================
# Logging Functions
# ============================================
log_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

log_success() {
    echo -e "${GREEN}✓ ${NC}$1"
}

log_warn() {
    echo -e "${YELLOW}⚠ ${NC}$1"
}

log_error() {
    echo -e "${RED}✗ ${NC}$1"
}

# ============================================
# Phase 1: Environment Validation
# ============================================
validate_environment() {
    log_info "Validating environment..."

    # Check bash version
    if [[ "${BASH_VERSION%%.*}" -lt 4 ]]; then
        log_warn "Bash 4+ recommended, current: $BASH_VERSION"
    fi

    # Check required tools
    for cmd in grep sed curl tar; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Required command not found: $cmd"
            exit 1
        fi
    done

    log_success "Environment validated"
}

# ============================================
# Phase 2: Backup Existing Config
# ============================================
backup_existing() {
    local backup_dir=".tad.backup.$(date +%Y%m%d_%H%M%S)"

    if [ -d ".tad" ]; then
        log_info "Backing up existing .tad/ to $backup_dir"
        cp -r .tad "$backup_dir"
        BACKUP_PATH="$backup_dir"
    fi

    # Backup platform-specific dirs if they exist
    for dir in .codex .gemini; do
        if [ -d "$dir" ]; then
            mkdir -p "$backup_dir" 2>/dev/null || true
            cp -r "$dir" "${backup_dir}/${dir}" 2>/dev/null || true
        fi
    done

    # Backup instruction files
    for file in AGENTS.md GEMINI.md; do
        if [ -f "$file" ]; then
            mkdir -p "$backup_dir" 2>/dev/null || true
            cp "$file" "${backup_dir}/${file}" 2>/dev/null || true
        fi
    done
}

# ============================================
# Phase 3: Platform Detection
# ============================================
detect_installed_tools() {
    local tools=""

    # Claude Code
    if command -v claude &> /dev/null || [ -d "$HOME/.claude" ]; then
        tools="$tools claude"
        log_info "Detected: Claude Code"
    fi

    # Codex CLI
    if command -v codex &> /dev/null || [ -d "$HOME/.codex" ]; then
        tools="$tools codex"
        log_info "Detected: Codex CLI"
    fi

    # Gemini CLI
    if command -v gemini &> /dev/null || [ -d "$HOME/.gemini" ]; then
        tools="$tools gemini"
        log_info "Detected: Gemini CLI"
    fi

    if [ -z "$tools" ]; then
        log_warn "No AI CLI tools detected. Installing Claude Code configs only."
        tools="claude"
    fi

    # Trim leading space
    echo "${tools# }"
}

# ============================================
# Phase 4: Generate Codex Configuration
# ============================================
generate_codex_config() {
    log_info "Generating Codex CLI configuration..."

    local codex_prompts_dir="$HOME/.codex/prompts"
    local codex_skills_dir="$HOME/.codex/skills/tad"

    # Create directories
    mkdir -p "$codex_prompts_dir"
    mkdir -p "$codex_skills_dir"

    # Generate AGENTS.md from CLAUDE.md
    if [ -f "CLAUDE.md" ]; then
        log_info "  → Generating AGENTS.md from CLAUDE.md..."
        generate_agents_md
    fi

    # Convert commands to Codex format
    log_info "  → Converting commands to Codex format..."
    convert_commands_to_codex

    # Copy TAD skills to Codex skills directory
    log_info "  → Installing TAD skills to ~/.codex/skills/tad/..."
    if [ -d ".tad/skills" ]; then
        cp -r .tad/skills/* "$codex_skills_dir/" 2>/dev/null || true
    fi

    log_success "Codex CLI configuration generated"
}

generate_agents_md() {
    if [ ! -f "CLAUDE.md" ]; then
        log_warn "CLAUDE.md not found, skipping AGENTS.md generation"
        return
    fi

    cat > AGENTS.md << 'AGENTSEOF'
# TAD Framework - Codex CLI Instructions

This file provides TAD framework guidance for Codex CLI.
Converted from CLAUDE.md for multi-platform compatibility.

## TAD Framework Usage

### Core Commands
- `/prompts:tad_alex` - Start Alex (Solution Lead) for planning
- `/prompts:tad_blake` - Start Blake (Execution Master) for implementation
- `/prompts:tad_gate` - Run quality gate verification
- `/prompts:tad_init` - Initialize TAD in a project

### Workflow
1. Use Alex for requirements analysis and design
2. Alex creates handoff in `.tad/active/handoffs/`
3. Use Blake to execute the implementation
4. Run gates to verify quality

### Quality Gates
- Gate 1: Requirements clarity
- Gate 2: Design completeness
- Gate 3: Implementation quality (expanded in v2.0)
- Gate 4: Integration/Acceptance (simplified in v2.0)

### Skills (Self-Check Mode)
Since Codex CLI doesn't have native subagents, read skill definitions from:
`.tad/skills/{skill-id}/SKILL.md`

Execute checklist items manually and generate evidence files.

### Evidence Files
Save review evidence to: `.tad/evidence/reviews/{date}-{skill}-{task}.md`

---
*Generated by TAD v2.1 Installer*
*Source: CLAUDE.md*
AGENTSEOF

    log_success "  → AGENTS.md generated"
}

convert_commands_to_codex() {
    local source_dir=".claude/commands"
    local target_dir="$HOME/.codex/prompts"

    if [ ! -d "$source_dir" ]; then
        log_warn "No .claude/commands/ found to convert"
        return
    fi

    # Core TAD commands to convert
    local commands=("tad-alex" "tad-blake" "tad-gate" "tad-init")

    for cmd in "${commands[@]}"; do
        local source_file="$source_dir/${cmd}.md"
        local target_file="$target_dir/tad_${cmd#tad-}.md"

        if [ -f "$source_file" ]; then
            # Add Codex header and copy content
            cat > "$target_file" << CMDEOF
# TAD ${cmd#tad-} Command (Codex)

Converted from Claude Code command for Codex CLI compatibility.

---

$(cat "$source_file")

---

## Codex Execution Notes
- Use \$ARGUMENTS for user input
- Skills are in ~/.codex/skills/tad/
- Evidence goes to .tad/evidence/reviews/
CMDEOF
            log_info "  → Converted: $cmd → tad_${cmd#tad-}.md"
        fi
    done
}

# ============================================
# Phase 5: Generate Gemini Configuration
# ============================================
generate_gemini_config() {
    log_info "Generating Gemini CLI configuration..."

    local gemini_commands_dir=".gemini/commands"

    # Create directories
    mkdir -p "$gemini_commands_dir"

    # Generate GEMINI.md from CLAUDE.md
    if [ -f "CLAUDE.md" ]; then
        log_info "  → Generating GEMINI.md from CLAUDE.md..."
        generate_gemini_md
    fi

    # Convert commands to Gemini TOML format
    log_info "  → Converting commands to Gemini TOML format..."
    convert_commands_to_gemini

    log_success "Gemini CLI configuration generated"
}

generate_gemini_md() {
    if [ ! -f "CLAUDE.md" ]; then
        log_warn "CLAUDE.md not found, skipping GEMINI.md generation"
        return
    fi

    cat > GEMINI.md << 'GEMINIEOF'
# TAD Framework - Gemini CLI Instructions

This file provides TAD framework guidance for Gemini CLI.
Converted from CLAUDE.md for multi-platform compatibility.

## TAD Framework Usage

### Core Commands
- `/tad-alex` - Start Alex (Solution Lead) for planning
- `/tad-blake` - Start Blake (Execution Master) for implementation
- `/tad-gate` - Run quality gate verification
- `/tad-init` - Initialize TAD in a project

### Workflow
1. Use Alex for requirements analysis and design
2. Alex creates handoff in `.tad/active/handoffs/`
3. Use Blake to execute the implementation
4. Run gates to verify quality

### Quality Gates
- Gate 1: Requirements clarity
- Gate 2: Design completeness
- Gate 3: Implementation quality (expanded in v2.0)
- Gate 4: Integration/Acceptance (simplified in v2.0)

### Skills (Self-Check Mode)
Since Gemini CLI doesn't have native subagents, read skill definitions from:
`.tad/skills/{skill-id}/SKILL.md`

Execute checklist items manually and generate evidence files.

### Evidence Files
Save review evidence to: `.tad/evidence/reviews/{date}-{skill}-{task}.md`

### Memory Commands
- `/memory show` - View loaded context
- `/memory refresh` - Reload GEMINI.md files
- `/memory add` - Add to global context

---
*Generated by TAD v2.1 Installer*
*Source: CLAUDE.md*
GEMINIEOF

    log_success "  → GEMINI.md generated"
}

convert_commands_to_gemini() {
    local source_dir=".claude/commands"
    local target_dir=".gemini/commands"

    if [ ! -d "$source_dir" ]; then
        log_warn "No .claude/commands/ found to convert"
        return
    fi

    # Core TAD commands to convert
    local commands=("tad-alex" "tad-blake" "tad-gate" "tad-init")

    for cmd in "${commands[@]}"; do
        local source_file="$source_dir/${cmd}.md"
        local target_file="$target_dir/${cmd}.toml"

        if [ -f "$source_file" ]; then
            # Extract first line as description
            local description
            description=$(head -n 1 "$source_file" | sed 's/^#\s*//')

            # Generate TOML command file
            cat > "$target_file" << TOMLEOF
description = "TAD: $description"

prompt = """
$(cat "$source_file")

## Context
@{GEMINI.md}
@{.tad/skills/README.md}

## User Arguments
{{args}}

## Evidence Output
Generate evidence at: .tad/evidence/reviews/
"""
TOMLEOF
            log_info "  → Converted: $cmd → ${cmd}.toml"
        fi
    done
}

# ============================================
# Phase 6a: Copy ALL Framework Files
# ============================================
# Replaces manual file-by-file copy with comprehensive sync.
# Project-specific data (active/, archive/, evidence/, project-knowledge/,
# pair-testing/) is never overwritten.
copy_framework_files() {
    local src="$1"
    log_info "  → Syncing framework files from source..."

    # --- .tad/ framework files (copy everything except project data) ---

    # Top-level config & metadata files
    for f in "$src"/.tad/*.yaml "$src"/.tad/*.md "$src"/.tad/*.txt; do
        [ -f "$f" ] && cp "$f" .tad/ 2>/dev/null || true
    done

    # Framework subdirectories (full sync)
    for dir in agents data gates guides ralph-config references schemas skills sub-agents tasks templates workflows; do
        if [ -d "$src/.tad/$dir" ]; then
            mkdir -p ".tad/$dir"
            cp -r "$src/.tad/$dir/"* ".tad/$dir/" 2>/dev/null || true
        fi
    done

    # --- .claude/ framework files ---
    mkdir -p .claude/commands
    mkdir -p .claude/skills/code-review
    cp "$src"/.claude/commands/*.md .claude/commands/
    cp "$src"/.claude/settings.json .claude/ 2>/dev/null || true
    cp -r "$src"/.claude/skills/code-review/* .claude/skills/code-review/ 2>/dev/null || true
    cp "$src"/.claude/skills/doc-organization.md .claude/skills/ 2>/dev/null || true

    # Count installed files for verification
    local count
    count=$(find .tad -type f -not -path ".tad/active/*" -not -path ".tad/archive/*" -not -path ".tad/evidence/*" -not -path ".tad/project-knowledge/*" -not -path ".tad/pair-testing/*" | wc -l | tr -d ' ')
    log_success "  → Synced $count framework files to .tad/"
}

# ============================================
# Phase 6b: Validation
# ============================================
validate_generated_configs() {
    log_info "Validating generated configurations..."

    local errors=0

    # Check required files exist
    for file in ".tad/config.yaml" ".tad/version.txt"; do
        if [ ! -f "$file" ]; then
            log_error "Missing required file: $file"
            ((errors++))
        fi
    done

    # Check skills directory
    if [ ! -d ".tad/skills" ]; then
        log_error "Missing skills directory"
        ((errors++))
    fi

    # Check agents directory
    if [ ! -d ".tad/agents" ]; then
        log_error "Missing agents directory"
        ((errors++))
    fi

    # Check templates directory
    if [ ! -d ".tad/templates" ]; then
        log_error "Missing templates directory"
        ((errors++))
    fi

    # Check commands directory
    if [ ! -d ".claude/commands" ]; then
        log_error "Missing .claude/commands directory"
        ((errors++))
    fi

    if [ $errors -gt 0 ]; then
        return 1
    fi

    log_success "All configurations validated"
}

# ============================================
# Phase 7: Rollback on Failure
# ============================================
rollback_on_failure() {
    log_error "Installation failed. Rolling back..."

    if [ -n "${BACKUP_PATH:-}" ] && [ -d "$BACKUP_PATH" ]; then
        rm -rf .tad
        mv "$BACKUP_PATH" .tad
        log_info "Restored from backup: $BACKUP_PATH"
    fi

    # Clean up generated files
    for file in AGENTS.md GEMINI.md; do
        [ -f "$file" ] && rm -f "$file"
    done

    for dir in .codex .gemini; do
        [ -d "$dir" ] && rm -rf "$dir"
    done

    log_error "Rollback complete. Please check logs."
    exit 1
}

# Set trap for automatic rollback
trap 'rollback_on_failure' ERR

# ============================================
# Detect current state
# ============================================
detect_state() {
    if [ ! -d ".tad" ] && [ ! -d ".claude/commands" ]; then
        echo "fresh"
    elif [ -f ".tad/version.txt" ]; then
        local ver=$(cat .tad/version.txt)
        if [[ "$ver" == "$TARGET_VERSION" ]]; then
            echo "current"
        elif [[ "$ver" == "2.1"* ]] || [[ "$ver" == "2.2"* ]]; then
            echo "v2.0"
        elif [[ "$ver" == "2.0"* ]]; then
            echo "v2.0"
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
        echo "old"
    else
        echo "partial"
    fi
}

# ============================================
# Main Installation Flow
# ============================================
main() {
    echo ""
    echo -e "${CYAN}=====================================${NC}"
    echo -e "${CYAN}   TAD Framework v${TARGET_VERSION}${NC}"
    echo -e "${CYAN}   Multi-Platform Support${NC}"
    echo -e "${CYAN}=====================================${NC}"
    echo ""

    validate_environment
    backup_existing

    # Detect platforms
    log_info "Detecting installed AI CLI tools..."
    DETECTED_PLATFORMS=$(detect_installed_tools)
    echo ""

    STATE=$(detect_state)
    CURRENT_VERSION="none"
    if [ -f ".tad/version.txt" ]; then
        CURRENT_VERSION=$(cat .tad/version.txt)
    fi

    # Display current state
    echo -e "${BLUE}📍 Installation Status:${NC}"
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
        "v2.0")
            echo -e "   Status: ${YELLOW}Upgrade available${NC}"
            echo "   Current: v${CURRENT_VERSION} → Target: v${TARGET_VERSION}"
            echo "   (Will add multi-platform support)"
            ACTION="upgrade"
            ;;
        "v1.8")
            echo -e "   Status: ${YELLOW}Upgrade available${NC}"
            echo "   Current: v${CURRENT_VERSION} → Target: v${TARGET_VERSION}"
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
            ACTION="migrate"
            ;;
        "partial")
            echo -e "   Status: ${YELLOW}Partial installation${NC}"
            echo "   Will complete installation"
            ACTION="install"
            ;;
    esac

    echo ""
    echo -e "   Platforms: ${CYAN}$DETECTED_PLATFORMS${NC}"
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
            echo "  2. Create .tad/skills/ with 8 P0 skills (NEW)"
            echo "  3. Create .tad/adapters/ for multi-platform (NEW)"
            echo "  4. Create .claude/commands/ with TAD commands"
            echo "  5. Create CLAUDE.md project rules"
            for tool in $DETECTED_PLATFORMS; do
                case $tool in
                    codex)
                        echo "  6. Generate Codex CLI configs (AGENTS.md, prompts)"
                        ;;
                    gemini)
                        echo "  7. Generate Gemini CLI configs (GEMINI.md, commands)"
                        ;;
                esac
            done
            ;;
        "upgrade")
            echo "  1. Update .claude/commands/"
            echo "  2. Install .tad/skills/ (8 P0 skills) (NEW)"
            echo "  3. Install .tad/adapters/ for multi-platform (NEW)"
            echo "  4. Update .tad/config.yaml and templates/"
            for tool in $DETECTED_PLATFORMS; do
                case $tool in
                    codex)
                        echo "  5. Generate Codex CLI configs"
                        ;;
                    gemini)
                        echo "  6. Generate Gemini CLI configs"
                        ;;
                esac
            done
            echo ""
            echo -e "  ${GREEN}✓ Preserved:${NC} handoffs, evidence, project-knowledge"
            ;;
        "migrate")
            echo "  1. Backup existing .tad/ to .tad-backup/"
            echo "  2. Create new v2.1 directory structure"
            echo "  3. Migrate your handoffs and evidence"
            echo "  4. Install skills and adapters"
            for tool in $DETECTED_PLATFORMS; do
                case $tool in
                    codex)
                        echo "  5. Generate Codex CLI configs"
                        ;;
                    gemini)
                        echo "  6. Generate Gemini CLI configs"
                        ;;
                esac
            done
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
    log_info "Downloading TAD Framework v${TARGET_VERSION}..."

    # Download
    curl -sSL "$DOWNLOAD_URL" | tar -xz
    TAD_SRC="TAD-main"

    # Execute based on action
    case $ACTION in
        "install")
            log_info "Installing TAD Framework..."

            # Create project-specific directories (not in source repo)
            mkdir -p .tad/active/handoffs
            mkdir -p .tad/active/designs
            mkdir -p .tad/active/epics
            mkdir -p .tad/active/playground
            mkdir -p .tad/archive/handoffs
            mkdir -p .tad/archive/epics
            mkdir -p .tad/archive/playground
            mkdir -p .tad/evidence/reviews
            mkdir -p .tad/evidence/completions
            mkdir -p .tad/evidence/ralph-loops
            mkdir -p .tad/evidence/reviews/_iterations
            mkdir -p .tad/evidence/pair-tests
            mkdir -p .tad/evidence/acceptance-tests
            mkdir -p .tad/project-knowledge
            mkdir -p .tad/pair-testing
            mkdir -p .tad/reports
            mkdir -p .claude/skills

            # Copy ALL framework files (comprehensive sync)
            copy_framework_files "$TAD_SRC"

            # Copy project-knowledge README
            cp -r "$TAD_SRC"/.tad/project-knowledge/README.md .tad/project-knowledge/ 2>/dev/null || true

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
            log_info "Upgrading to v${TARGET_VERSION}..."

            # Ensure project-specific directories exist
            mkdir -p .tad/active/handoffs
            mkdir -p .tad/active/designs
            mkdir -p .tad/active/epics
            mkdir -p .tad/active/playground
            mkdir -p .tad/archive/handoffs
            mkdir -p .tad/archive/epics
            mkdir -p .tad/archive/playground
            mkdir -p .tad/evidence/reviews
            mkdir -p .tad/evidence/completions
            mkdir -p .tad/evidence/ralph-loops
            mkdir -p .tad/evidence/reviews/_iterations
            mkdir -p .tad/evidence/pair-tests
            mkdir -p .tad/evidence/acceptance-tests
            mkdir -p .tad/project-knowledge
            mkdir -p .tad/pair-testing
            mkdir -p .tad/reports

            # Archive old skills if needed
            if [ -d ".claude/skills" ] && [ ! -d ".claude/skills/_archived" ]; then
                mkdir -p .claude/skills/_archived
                for f in .claude/skills/*.md; do
                    if [ -f "$f" ] && [ "$(basename "$f")" != "doc-organization.md" ]; then
                        mv "$f" .claude/skills/_archived/ 2>/dev/null || true
                    fi
                done
            fi

            # Copy ALL framework files (comprehensive sync)
            copy_framework_files "$TAD_SRC"

            # Update CLAUDE.md
            log_info "  → Updating CLAUDE.md..."
            cp "$TAD_SRC"/CLAUDE.md ./

            # Update project-knowledge README
            cp "$TAD_SRC"/.tad/project-knowledge/README.md .tad/project-knowledge/ 2>/dev/null || true

            # Set version
            echo "$TARGET_VERSION" > .tad/version.txt
            ;;

        "migrate")
            log_info "Migrating and upgrading to v${TARGET_VERSION}..."

            # Backup
            log_info "  → Creating backup..."
            if [ -d ".tad-backup" ]; then
                rm -rf .tad-backup
            fi
            cp -r .tad .tad-backup

            # Create project-specific directories
            mkdir -p .tad/active/handoffs
            mkdir -p .tad/active/designs
            mkdir -p .tad/active/epics
            mkdir -p .tad/active/playground
            mkdir -p .tad/archive/handoffs
            mkdir -p .tad/archive/epics
            mkdir -p .tad/archive/playground
            mkdir -p .tad/evidence/reviews
            mkdir -p .tad/evidence/completions
            mkdir -p .tad/evidence/ralph-loops
            mkdir -p .tad/evidence/reviews/_iterations
            mkdir -p .tad/evidence/pair-tests
            mkdir -p .tad/evidence/acceptance-tests
            mkdir -p .tad/project-knowledge
            mkdir -p .tad/pair-testing
            mkdir -p .tad/reports
            mkdir -p .claude/skills/_archived

            # Migrate user data from backup (old directory layouts)
            log_info "  → Migrating user data..."
            if [ -d ".tad-backup/handoffs" ]; then
                cp -r .tad-backup/handoffs/* .tad/active/handoffs/ 2>/dev/null || true
            fi
            if [ -d ".tad-backup/active/handoffs" ]; then
                cp -r .tad-backup/active/handoffs/* .tad/active/handoffs/ 2>/dev/null || true
            fi
            if [ -d ".tad-backup/working" ]; then
                cp -r .tad-backup/working/* .tad/active/ 2>/dev/null || true
            fi
            if [ -d ".tad-backup/context" ]; then
                cp -r .tad-backup/context/* .tad/active/ 2>/dev/null || true
            fi

            # Archive old skills if needed
            if [ -d ".claude/skills" ]; then
                for f in .claude/skills/*.md; do
                    if [ -f "$f" ] && [ "$(basename "$f")" != "doc-organization.md" ]; then
                        mv "$f" .claude/skills/_archived/ 2>/dev/null || true
                    fi
                done
            fi

            # Copy ALL framework files (comprehensive sync)
            copy_framework_files "$TAD_SRC"

            # Copy root files
            cp "$TAD_SRC"/CLAUDE.md ./

            # Copy project-knowledge README
            cp "$TAD_SRC"/.tad/project-knowledge/README.md .tad/project-knowledge/ 2>/dev/null || true

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
            log_success "Backup saved to .tad-backup/"
            ;;
    esac

    # Generate platform-specific configs
    for tool in $DETECTED_PLATFORMS; do
        case $tool in
            codex)
                generate_codex_config
                ;;
            gemini)
                generate_gemini_config
                ;;
        esac
    done

    # Validate everything
    validate_generated_configs

    # Cleanup
    rm -rf "$TAD_SRC"

    echo ""
    echo -e "${GREEN}=====================================${NC}"
    echo -e "${GREEN}   ✅ TAD v${TARGET_VERSION} Ready!${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo ""
    echo "Directory structure:"
    echo "  .tad/"
    echo "  ├── active/handoffs/     # Current work"
    echo "  ├── agents/              # Agent definitions"
    echo "  ├── archive/handoffs/    # Completed work"
    echo "  ├── evidence/            # Gate & test evidence"
    echo "  ├── pair-testing/        # Pair test sessions"
    echo "  ├── project-knowledge/   # Project-specific knowledge"
    echo "  ├── ralph-config/        # Ralph Loop configuration"
    echo "  ├── skills/              # Platform-agnostic skills"
    echo "  ├── sub-agents/          # Sub-agent definitions"
    echo "  └── templates/           # Handoff & output templates"
    echo ""
    echo -e "Platforms configured: ${CYAN}$DETECTED_PLATFORMS${NC}"
    echo ""
    echo "Quick start:"
    echo "  1. Restart Claude Code (or open new terminal)"

    for tool in $DETECTED_PLATFORMS; do
        case $tool in
            claude)
                echo -e "  Claude: ${CYAN}/alex${NC}, ${CYAN}/blake${NC}, ${CYAN}/gate${NC}"
                ;;
            codex)
                echo -e "  Codex:  ${CYAN}/prompts:tad_alex${NC}, ${CYAN}/prompts:tad_blake${NC}"
                ;;
            gemini)
                echo -e "  Gemini: ${CYAN}/tad-alex${NC}, ${CYAN}/tad-blake${NC}"
                ;;
        esac
    done

    echo ""
    echo "Learn more: ${BLUE}${REPO_URL}${NC}"
    echo ""
}

# Run main function
main
