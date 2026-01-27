# TAD v2.0 Migration Guide

## Overview

TAD v2.0 introduces the Ralph Loop quality mechanism, restructures quality gates, and separates technical/business responsibilities more clearly.

## Breaking Changes

### 1. Gate Restructure

| Gate | v1.x | v2.0 |
|------|------|------|
| Gate 1 | Requirements Clarity | Requirements Clarity (unchanged) |
| Gate 2 | Design Completeness | Design Completeness (unchanged) |
| Gate 3 | Implementation Quality | **Implementation & Integration** (expanded) |
| Gate 4 | Integration Verification | **Acceptance & Archive** (simplified) |

#### Gate 3 v2 (Expanded)
Now includes:
- All Layer 1 checks (build, test, lint, tsc)
- All Layer 2 expert reviews (code-reviewer, test-runner, security-auditor, performance-optimizer)
- Evidence file verification
- **Owned entirely by Blake**

#### Gate 4 v2 (Simplified)
Now includes:
- Business requirement verification
- Human approval
- Archive handoff
- **Owned by Alex** (no technical review - moved to Gate 3)

### 2. New Configuration Files

New files added:
```
.tad/ralph-config/
├── loop-config.yaml       # Ralph Loop configuration
└── expert-criteria.yaml   # Expert pass conditions

.tad/schemas/
├── loop-config.schema.json
└── expert-criteria.schema.json
```

### 3. New Evidence Directories

```
.tad/evidence/
├── ralph-loops/           # NEW - Ralph Loop state and summaries
│   └── .gitkeep
└── reviews/
    └── _iterations/       # NEW - Iteration-specific evidence
        └── .gitkeep
```

### 4. Blake Command Changes

New commands:
- `*develop [task-id]` - Start Ralph Loop (replaces manual implementation)
- `*ralph-status` - Show loop state
- `*ralph-resume` - Resume from checkpoint
- `*ralph-reset` - Reset loop state
- `*layer1` - Run Layer 1 only
- `*layer2` - Run Layer 2 only

### 5. Alex Gate 4 Changes

**Before (v1.x)**:
- Alex called technical experts (code-reviewer, test-runner, etc.)
- Alex performed both technical and business review

**After (v2.0)**:
- Technical review moved to Blake's Gate 3 v2
- Alex's Gate 4 v2 is business-only
- Alex verifies Gate 3 v2 passed before Gate 4 v2

## Migration Steps

### Step 1: Backup Current Config

```bash
cp .tad/config.yaml .tad/config.yaml.v1.backup
```

### Step 2: Install New Files

The following files should be created:

1. `.tad/ralph-config/loop-config.yaml`
2. `.tad/ralph-config/expert-criteria.yaml`
3. `.tad/schemas/loop-config.schema.json`
4. `.tad/schemas/expert-criteria.schema.json`
5. `.tad/evidence/ralph-loops/.gitkeep`
6. `.tad/evidence/reviews/_iterations/.gitkeep`

### Step 3: Update config.yaml

Add to `.tad/config.yaml`:

```yaml
# Add to top level
ralph_loop:
  enabled: true
  config_file: ".tad/ralph-config/loop-config.yaml"
  criteria_file: ".tad/ralph-config/expert-criteria.yaml"

# Update gates section
gates:
  gate3_v2_implementation_integration:
    name: "Implementation & Integration Quality"
    owner: "Blake"
    includes:
      - "Layer 1 self-check (build, test, lint, tsc)"
      - "Layer 2 expert review (all experts)"
      - "Evidence verification"
    type: "expanded"
    note: "Combines original Gate 3 + Gate 4 Part A (technical)"

  gate4_v2_acceptance_archive:
    name: "Acceptance & Archive"
    owner: "Alex"
    includes:
      - "Business requirement verification"
      - "Human approval"
      - "Archive handoff"
    type: "simplified"
    note: "Pure business acceptance, no technical review"

# Add responsibility matrix
gate_responsibility_matrix:
  technical_experts:
    - "code-reviewer"
    - "test-runner"
    - "security-auditor"
    - "performance-optimizer"
  owner: "Blake (Gate 3 v2)"
  timing: "During Ralph Loop Layer 2"

  business_acceptance:
    - "requirement verification"
    - "user approval"
    - "archive"
  owner: "Alex (Gate 4 v2)"
  timing: "After Gate 3 v2 passes"
```

### Step 4: Update Command Files

Update `.claude/commands/tad-blake.md`:
- Add Ralph Loop section
- Add new commands (*develop, *ralph-status, etc.)
- Update gate references

Update `.claude/commands/tad-alex.md`:
- Update Gate 4 v2 description
- Remove mandatory technical review (now optional)
- Update acceptance protocol

### Step 5: Verify Installation

Run these checks:
1. Validate YAML syntax: `npx yaml-lint .tad/ralph-config/*.yaml`
2. Check schema files exist: `ls .tad/schemas/*.schema.json`
3. Check evidence directories: `ls .tad/evidence/ralph-loops/`

## Backward Compatibility

### Using `*gate 3` and `*gate 4`

Old commands still work:
- `*gate 3` → Now runs Gate 3 v2 (expanded)
- `*gate 4` → Now runs Gate 4 v2 (simplified)

### Existing Handoffs

Handoffs created before v2.0:
- Can still be processed
- Blake will use Ralph Loop for implementation
- Gate sequence remains the same (just expanded/simplified)

### Expert Review Timing

| Expert | v1.x Timing | v2.0 Timing |
|--------|-------------|-------------|
| code-reviewer | Gate 3 + Gate 4 | Gate 3 v2 (Layer 2) |
| test-runner | Gate 3 + Gate 4 | Gate 3 v2 (Layer 2) |
| security-auditor | Gate 4 | Gate 3 v2 (Layer 2, conditional) |
| performance-optimizer | Gate 4 | Gate 3 v2 (Layer 2, conditional) |

## Configuration Reference

### loop-config.yaml Key Settings

```yaml
ralph_loop:
  layer1:
    limits:
      max_retries: 15  # Max Layer 1 retry attempts
    circuit_breaker:
      consecutive_same_error: 3  # Trigger after 3 same errors

  layer2:
    limits:
      max_rounds: 5  # Max Layer 2 rounds
    escalation:
      threshold: 3  # Escalate after 3 same-category failures

  limits:
    total_iterations: 30  # Overall limit
    timeout_minutes: 120  # 2 hour max
```

### expert-criteria.yaml Key Settings

```yaml
expert_criteria:
  code-reviewer:
    pass_condition:
      rules:
        - severity: "P0"
          max_count: 0
          blocking: true
        - severity: "P1"
          max_count: 0
          blocking: true

  test-runner:
    pass_condition:
      rules:
        - metric: "test_pass_rate"
          operator: "=="
          value: 100
        - metric: "coverage"
          operator: ">="
          value: 70
```

## Rollback

To rollback to v1.x:

```bash
# Restore backup
cp .tad/config.yaml.v1.backup .tad/config.yaml

# Remove new files (optional - they won't affect v1.x)
rm -rf .tad/ralph-config/
rm -rf .tad/schemas/
rm -rf .tad/evidence/ralph-loops/
rm -rf .tad/evidence/reviews/_iterations/

# Restore old command files from git
git checkout HEAD~1 -- .claude/commands/tad-blake.md
git checkout HEAD~1 -- .claude/commands/tad-alex.md
```

## FAQ

### Q: Do I need to change my workflow?

**For Alex**: Minor change. Gate 4 v2 is now business-only, no technical review needed.

**For Blake**: Significant change. Use `*develop` instead of manual implementation. Ralph Loop handles quality iterations automatically.

### Q: What if I don't want Ralph Loop?

Set `ralph_loop.enabled: false` in config.yaml. Blake will fall back to manual implementation.

### Q: Are my existing evidence files affected?

No. Existing files in `.tad/evidence/reviews/` remain unchanged. New Ralph Loop evidence goes to `.tad/evidence/ralph-loops/`.

### Q: Can I customize expert criteria?

Yes. Edit `.tad/ralph-config/expert-criteria.yaml` to change pass conditions, severity thresholds, and trigger patterns.

### Q: What happens to in-progress work during migration?

Complete current work with v1.x workflow, then migrate. Or:
1. Checkpoint your state manually
2. Migrate
3. Resume with `*ralph-resume` if state file exists

## Support

- Documentation: `docs/RALPH-LOOP.md`
- Configuration: `.tad/ralph-config/`
- Schemas: `.tad/schemas/`
