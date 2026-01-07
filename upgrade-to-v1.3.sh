#!/bin/bash

# TAD Framework v1.2.2 → v1.3.0 Upgrade Script
# Evidence-Based Development Enhancement

set -e

echo "========================================"
echo "TAD Framework v1.2.2 → v1.3.0 Upgrade"
echo "Evidence-Based Development"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if .tad directory exists (already installed)
if [ ! -d ".tad" ]; then
    echo -e "${RED}Error: .tad directory not found${NC}"
    echo "This script is for upgrading existing TAD installations."
    echo "For new installation, please run: bash install.sh"
    exit 1
fi

# Check current version
if [ -f ".tad/version.txt" ]; then
    CURRENT_VERSION=$(cat .tad/version.txt)
    echo -e "Current version: ${YELLOW}v${CURRENT_VERSION}${NC}"
else
    echo -e "${YELLOW}Warning: version.txt not found${NC}"
    # Try to detect from config.yaml
    if [ -f ".tad/config.yaml" ]; then
        CURRENT_VERSION=$(grep "^version:" .tad/config.yaml | head -1 | awk '{print $2}')
        echo -e "Detected version from config: ${YELLOW}v${CURRENT_VERSION}${NC}"
    else
        echo -e "${RED}Error: Cannot determine current version${NC}"
        exit 1
    fi
fi

# Verify version (accept 1.2, 1.2.0, 1.2.1, 1.2.2)
if [[ ! "$CURRENT_VERSION" =~ ^1\.2(\.[0-2])?$ ]]; then
    echo -e "${RED}Error: This upgrade script is for v1.2.x only${NC}"
    echo "Current version: v${CURRENT_VERSION}"
    echo ""
    echo "Please use the appropriate upgrade script:"
    echo "  • From v1.0: bash upgrade-to-v1.2.sh first"
    echo "  • From v1.1: bash upgrade-to-v1.2.sh first"
    exit 1
fi

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  TAD v1.3: Evidence-Based Development   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "This upgrade introduces THREE major enhancements:"
echo ""
echo "  ${GREEN}1. Evidence-Based Quality Assurance${NC}"
echo "     • 6 types of evidence (search, code location, data flow...)"
echo "     • 5 mandatory questions (MQ1-5) to prevent common failures"
echo "     • Human-verifiable checkpoints"
echo ""
echo "  ${GREEN}2. Human Visual Empowerment${NC}"
echo "     • New role: Checkpoint Validator"
echo "     • 3 participation points (Gate 2, Phases, Gate 3)"
echo "     • 30-60 min investment → 3-6 hours saved (ROI: 1:5 to 1:10)"
echo ""
echo "  ${GREEN}3. Continuous Learning Mechanism${NC}"
echo "     • 5 learning mechanisms (Decision Rationale, Interactive...)"
echo "     • 4 learning dimensions (Tech, System, UX, Quality)"
echo "     • Failure learning loop (auto-update from mistakes)"
echo ""
echo "Expected Results:"
echo "  ✓ 95%+ problem detection rate (from 0-30%)"
echo "  ✓ 70-85% rework time saved"
echo "  ✓ System gets smarter with each project"
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
BACKUP_DIR=".tad_backup_v1.2.2_$(date +%Y%m%d_%H%M%S)"
echo "Creating backup at ${BACKUP_DIR}..."
cp -r .tad "$BACKUP_DIR"
echo -e "${GREEN}✓ Backup created${NC}"

# Step 1: Backup current config as v1.2.2
echo ""
echo "[1/8] Backing up config to archive..."
mkdir -p .tad/archive/configs
if [ -f ".tad/config.yaml" ]; then
    cp .tad/config.yaml .tad/archive/configs/config-v1.2.2.yaml
    echo -e "${GREEN}✓ config.yaml backed up as config-v1.2.2.yaml${NC}"
else
    echo -e "${RED}✗ config.yaml not found${NC}"
    exit 1
fi

# Step 2: Update config.yaml header
echo ""
echo "[2/8] Updating config.yaml version..."
# Update header version
sed -i.bak 's/^# TAD Configuration v[0-9.]* .*/# TAD Configuration v1.3 - Evidence-Based Development/' .tad/config.yaml
sed -i.bak 's/^version: [0-9.]*/version: 1.3.0/' .tad/config.yaml
sed -i.bak 's/^description: .*/description: Triangle Agent Development - 证据式开发系统/' .tad/config.yaml
sed -i.bak 's/^last_updated: .*/last_updated: 2025-11-25/' .tad/config.yaml

# Update internal tad_version (around line 744)
sed -i.bak 's/^tad_version: .*/tad_version: 1.3.0/' .tad/config.yaml

# Clean up backup files
rm -f .tad/config.yaml.bak

echo -e "${GREEN}✓ config.yaml updated to v1.3.0${NC}"

# Step 3: Update manifest.yaml
echo ""
echo "[3/8] Updating manifest.yaml..."
if [ -f ".tad/manifest.yaml" ]; then
    sed -i.bak 's/^version: [0-9.]*/version: 1.3/' .tad/manifest.yaml
    sed -i.bak "s/last_updated: .*/last_updated: '$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'/" .tad/manifest.yaml

    # Update config path reference
    sed -i.bak 's|path: \.tad/config-v3\.yaml|path: .tad/config.yaml|' .tad/manifest.yaml
    sed -i.bak 's|version: "3\.0"|version: "1.3.0"|' .tad/manifest.yaml
    sed -i.bak 's|主配置文件 - 融合BMAD强制机制|主配置文件 - Evidence-Based Development|' .tad/manifest.yaml

    rm -f .tad/manifest.yaml.bak
    echo -e "${GREEN}✓ manifest.yaml updated to v1.3${NC}"
else
    echo -e "${YELLOW}⚠ manifest.yaml not found, skipping${NC}"
fi

# Step 4: Setup evidence directory structure
echo ""
echo "[4/8] Setting up evidence collection system..."
mkdir -p .tad/evidence/patterns
mkdir -p .tad/evidence/metrics
mkdir -p .tad/evidence/project-logs

# Verify or create evidence README
if [ ! -f ".tad/evidence/README.md" ]; then
    echo -e "${YELLOW}⚠ evidence/README.md not found${NC}"
    echo "  Please run 'git pull' to get the latest evidence system files"
fi

# Verify failure-patterns.md exists
if [ -f ".tad/evidence/patterns/failure-patterns.md" ]; then
    echo -e "${GREEN}✓ Failure patterns documented${NC}"
else
    echo -e "${YELLOW}⚠ failure-patterns.md not found${NC}"
fi

# Initialize metrics file if not exists
if [ ! -f ".tad/evidence/metrics/tad-v1.3-metrics.yaml" ]; then
    echo -e "${YELLOW}⚠ tad-v1.3-metrics.yaml not found${NC}"
    echo "  Please run 'git pull' to get the metrics tracking file"
fi

echo -e "${GREEN}✓ Evidence system directories ready${NC}"

# Step 5: Verify handoff template updates
echo ""
echo "[5/8] Checking handoff templates..."
if [ -f ".tad/templates/handoff-a-to-b.md" ]; then
    if grep -q "MQ1: 历史代码搜索" .tad/templates/handoff-a-to-b.md; then
        echo -e "${GREEN}✓ handoff-a-to-b.md has v1.3 enhancements (MQ1-5)${NC}"
    else
        echo -e "${YELLOW}⚠ handoff template needs v1.3 updates${NC}"
        echo "  Please run 'git pull' to get the updated template"
    fi
else
    echo -e "${YELLOW}⚠ handoff-a-to-b.md not found${NC}"
fi

# Step 6: Verify quality gates
echo ""
echo "[6/8] Checking quality gates..."
if [ -f ".tad/gates/quality-gate-checklist.md" ]; then
    echo -e "${GREEN}✓ Quality gate checklists present${NC}"
else
    echo -e "${YELLOW}⚠ quality-gate-checklist.md not found${NC}"
    echo "  Please run 'git pull' to get quality gate files"
fi

# Step 7: Create CHANGELOG if not exists
echo ""
echo "[7/8] Checking CHANGELOG..."
if [ ! -f "CHANGELOG.md" ]; then
    echo -e "${YELLOW}⚠ CHANGELOG.md not found${NC}"
    echo "  Please run 'git pull' to get the version history"
else
    echo -e "${GREEN}✓ CHANGELOG.md present${NC}"
fi

# Step 8: Update version
echo ""
echo "[8/8] Updating version marker..."
echo "1.3.0" > .tad/version.txt
echo -e "${GREEN}✓ Version updated to 1.3.0${NC}"

# Success message
echo ""
echo "========================================"
echo -e "${GREEN}✓ Upgrade Complete!${NC}"
echo "========================================"
echo ""
echo -e "${BLUE}TAD Framework is now at v1.3.0${NC}"
echo "Evidence-Based Development System"
echo ""
echo "What's New in v1.3:"
echo ""
echo "  ${GREEN}📋 Evidence-Based Quality Assurance${NC}"
echo "     • 6 evidence types: search results, code location, data flow,"
echo "       state flow, UI screenshots, test results"
echo "     • MQ1: Historical code search (prevent duplicate creation)"
echo "     • MQ2: Function existence verification (prevent crashes)"
echo "     • MQ3: Data flow completeness (ensure UI displays all data)"
echo "     • MQ4: Visual hierarchy (different states clearly visible)"
echo "     • MQ5: State synchronization (prevent data inconsistency)"
echo ""
echo "  ${GREEN}👤 Human Role Enhancement${NC}"
echo "     • Gate 2 Review: 10-15 min (verify design evidence)"
echo "     • Phase Checkpoints: 5-10 min each (progressive validation)"
echo "     • Gate 3 Verification: 10-15 min (final validation)"
echo "     • Total: 30-60 min investment → Save 3-6 hours rework"
echo ""
echo "  ${GREEN}📚 Learning Mechanisms${NC}"
echo "     • Decision Rationale: Understand tradeoffs"
echo "     • Interactive Challenge: Think before answers"
echo "     • Impact Visualization: See ripple effects"
echo "     • What-If Scenarios: Compare alternatives"
echo "     • Failure Learning: Auto-improve from mistakes"
echo ""
echo "  ${GREEN}🔄 Continuous Improvement${NC}"
echo "     • Failure learning loop captures errors"
echo "     • Auto-generates new MQ from failures"
echo "     • System gets smarter with each project"
echo ""
echo "Expected Results:"
echo "  • 95%+ problem detection rate (vs 0-30% in v1.2)"
echo "  • 70-85% reduction in rework time"
echo "  • ROI: 1:5 to 1:10 (invest 1 hour, save 5-10 hours)"
echo ""
echo "Next Steps:"
echo ""
echo "  ${YELLOW}1. Review Documentation${NC}"
echo "     • Upgrade Plan: TAD_V1.3_COMPREHENSIVE_UPGRADE_PLAN.md"
echo "     • Acceptance Report: TAD_V1.3_ACCEPTANCE_REPORT.md"
echo "     • Version History: CHANGELOG.md"
echo ""
echo "  ${YELLOW}2. Start with a Pilot Project${NC}"
echo "     • Choose a medium-complexity feature"
echo "     • Use the new handoff-a-to-b.md template"
echo "     • Practice filling MQ1-5 with evidence"
echo "     • Track time: Gate 2 (10-15min), Phases (5-10min each)"
echo ""
echo "  ${YELLOW}3. Collect Data${NC}"
echo "     • Record metrics in: .tad/evidence/metrics/tad-v1.3-metrics.yaml"
echo "     • Note which MQs caught issues"
echo "     • Track time invested vs saved"
echo ""
echo "  ${YELLOW}4. Learn and Iterate${NC}"
echo "     • After 3-5 projects, analyze effectiveness"
echo "     • Adjust MQ triggers if needed"
echo "     • Share learnings with team"
echo ""
echo "Important Files:"
echo "  • Config: .tad/config.yaml (v1.3.0)"
echo "  • Handoff: .tad/templates/handoff-a-to-b.md (with MQ1-5)"
echo "  • Evidence: .tad/evidence/ (new directory structure)"
echo "  • Metrics: .tad/evidence/metrics/tad-v1.3-metrics.yaml"
echo "  • Backup: ${BACKUP_DIR} (your v1.2.2 backup)"
echo ""
echo "If you encounter issues, restore with:"
echo "  rm -rf .tad && mv ${BACKUP_DIR} .tad"
echo ""
echo -e "${GREEN}From declarative to evidence-based,${NC}"
echo -e "${GREEN}From passive to proactive,${NC}"
echo -e "${GREEN}From one-time to continuous learning! 🚀${NC}"
echo ""
