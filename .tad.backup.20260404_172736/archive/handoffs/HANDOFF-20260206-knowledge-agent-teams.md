# HANDOFF: Knowledge Auto-loading + Agent Teams Integration

**Date**: 2026-02-06
**Author**: Alex (Solution Lead)
**Status**: Expert Review Complete - Ready for Implementation
**Priority**: P1
**Complexity**: Large (Full TAD)
**TAD Version**: 2.2.1 → 2.3.0

---

## Expert Review Status

| Expert | Verdict | P0 Fixed | Key Concerns |
|--------|---------|----------|--------------|
| code-reviewer | CONDITIONAL PASS → PASS (after fixes) | 5/5 | Import syntax, trigger conditions, file ownership |
| backend-architect | CONDITIONAL PASS → PASS (after fixes) | 3/3 | Terminal isolation, context bloat, file conflicts |

### P0 Issues & Resolutions

| P0 | Issue | Resolution |
|----|-------|------------|
| Terminal Isolation | Agent Team may blur Alex/Blake boundary | Added explicit `terminal_scope_constraint` — Team stays within agent's own domain |
| File Ownership | No conflict detection | Added `dependency_analysis` pre-check — conflict → fallback to sequential |
| Context Window Growth | 9 knowledge files → 50KB+ in 3 months | Changed to selective import: only import existing files + size cap |
| Import Syntax | @path format unverified | Verified: `@.tad/path` is correct (relative to CLAUDE.md location) |
| Trigger Conditions | Env var detection unreliable | Simplified: Agent Team is a protocol option, Claude naturally attempts it or falls back |

---

## 1. Executive Summary

Enhance TAD framework with two capabilities:
1. **Knowledge Auto-loading**: Make project-knowledge visible to Claude via CLAUDE.md imports (selective, size-aware)
2. **Agent Teams Integration**: Enable parallel expert review (Alex) and parallel implementation (Blake) using Claude Code's experimental Agent Teams feature

**Problem**: Project-knowledge is accumulated but never read. Agent reviews are serial, not parallel.
**Solution**: CLAUDE.md selective imports + Agent Teams as optional enhancement with subagent fallback.

---

## 2. Socratic Inquiry Summary

**Complexity**: Large | **Rounds**: 3

| Dimension | Question | User Answer |
|-----------|----------|-------------|
| Knowledge scope | How to handle non-existent files? | Declare all, auto-skip missing |
| MVP scope | Which Agent Team first? | Both (Alex + Blake) |
| Coexistence | Agent Teams vs subagent? | Auto by complexity (Full→Team, other→subagent) |
| Fallback | Team failure handling? | Auto fallback to subagent |
| Trigger | When to trigger Team? | At specific command steps (*handoff review / *develop) |
| Cost | Token consumption increase? | Quality first, cost insensitive |
| Acceptance | Definition of done? | Knowledge loaded + Agent Team triggerable |

---

## 3. Task Breakdown

### Execution Order
```
1. Task 4 (Config) → Foundation, no dependencies
2. Task 1 (CLAUDE.md) → Independent, can parallel with Task 4
3. Task 2 (Alex) → Depends on Task 4
4. Task 3 (Blake) → Depends on Task 4
```

---

### Task 1: CLAUDE.md - Add Project Knowledge Imports
**Files**: `CLAUDE.md`
**Effort**: Small

Add Section 7 to CLAUDE.md with `@` import syntax for project-knowledge categories.

**Key design decisions (from expert review)**:
- Import ALL declared categories — Claude silently skips non-existent files
- Add size awareness note for future maintenance
- Imports are relative to CLAUDE.md location (project root)

**Code to add** (append after Section 6):

```markdown
---

## 7. Project Knowledge (Auto-loaded)

Project-specific learnings auto-loaded at startup via @import.
Non-existent files are silently skipped. See .tad/project-knowledge/README.md for format.

> Maintenance: If total knowledge exceeds ~30KB, consolidate per README.md guidelines.

@.tad/project-knowledge/architecture.md
@.tad/project-knowledge/code-quality.md
@.tad/project-knowledge/security.md
@.tad/project-knowledge/testing.md
@.tad/project-knowledge/ux.md
@.tad/project-knowledge/performance.md
@.tad/project-knowledge/api-integration.md
@.tad/project-knowledge/mobile-platform.md
@.tad/project-knowledge/frontend-design.md
```

---

### Task 2: tad-alex.md - Agent Team Expert Review Mode
**Files**: `.claude/commands/tad-alex.md`
**Effort**: Medium

Add `agent_team_review` section to `handoff_creation_protocol`, after the existing `step3`.

**Terminal Isolation Constraint** (P0 fix):
```yaml
terminal_scope_constraint:
  rule: "Alex's Agent Team MUST stay within Alex's domain"
  allowed: "Requirements analysis, design review, handoff quality check"
  forbidden: "Writing implementation code, running tests, deploying"
  principle: "Agent Team parallelizes Alex's work, does NOT replace Blake"
```

**Full section to insert after `handoff_creation_protocol.step3`**:

```yaml
# Agent Team Review Mode (TAD v2.3 - experimental)
# Insert between step3 and step4 of handoff_creation_protocol
step3_agent_team:
  name: "Agent Team Expert Review (Full TAD only)"
  description: "Alternative to step3 when process_depth == full and Agent Teams available"
  experimental: true

  activation: |
    This step REPLACES step3 when ALL conditions met:
    1. process_depth == "full" (user chose Full TAD in adaptive complexity)
    2. Agent Teams feature is available (env var set)
    If any condition not met → skip this step, use original step3.
    If Agent Team creation fails → fallback to original step3 automatically.

  terminal_scope_constraint:
    rule: "Review Team stays within Alex's domain — NO implementation code"
    allowed: ["design review", "type safety check", "architecture analysis", "risk assessment"]
    forbidden: ["writing code", "running builds", "executing tests", "file modifications"]

  team_structure:
    lead: "Alex (delegate mode — coordination only)"
    teammates:
      - role: "code-quality-reviewer"
        focus: "Type safety, code structure, test requirements, execution order"
      - role: "architecture-reviewer"
        focus: "Data flow, API design, state management, system architecture"
      - role: "domain-reviewer"
        focus: "Dynamic: frontend→UX, security→audit, performance→optimize"

  team_prompt_template: |
    Create an agent team to review this handoff draft:

    FILE: {handoff_path}

    Spawn three reviewers:
    - Code quality reviewer: type safety, interfaces, test requirements
    - Architecture reviewer: data flow, API contracts, state management
    - {domain_type} reviewer: {domain_focus}

    WORKFLOW:
    Phase 1 - Individual Review (parallel):
      Each reviewer independently reviews and produces a structured report.

    Phase 2 - Cross-Challenge:
      After all reviews complete, each reviewer challenges one other:
      - Code challenges Architecture findings
      - Architecture challenges Domain findings
      - Domain challenges Code findings
      Focus: "Is this really P0? Could it be downgraded?"

    Phase 3 - Consensus:
      Synthesize into single report:
      - P0 blocking issues (must fix)
      - P1 recommendations (should address)
      - P2 suggestions (nice to have)
      - Overall: PASS / CONDITIONAL PASS / FAIL

    CONSTRAINT: This is a REVIEW team. Do NOT write implementation code.

  fallback_protocol: |
    IF Agent Team creation fails OR errors during review:
      1. Log: "⚠️ Agent Team review failed, falling back to subagent mode"
      2. Execute original step3 (parallel Task tool calls with 2+ experts)
      3. Continue handoff_creation_protocol from step4 normally
    Fallback is automatic — no user intervention, no blocking.

  output_format: |
    Same as current Expert Review Status table, with added note:
    "Reviewed via Agent Team (3 reviewers with cross-challenge)"
    OR "Reviewed via subagent (fallback)" if fallback was used.
```

**Insertion point**: After line ~760 in tad-alex.md (after existing step3, before step4)

---

### Task 3: tad-blake.md - Agent Team Implementation Mode
**Files**: `.claude/commands/tad-blake.md`
**Effort**: Medium

Add `agent_team_develop` section to `ralph_loop_execution`.

**Terminal Isolation Constraint** (P0 fix):
```yaml
terminal_scope_constraint:
  rule: "Blake's Agent Team MUST stay within Blake's domain"
  allowed: "Code implementation, testing, building, deploying"
  forbidden: "Changing requirements, modifying handoff, design decisions"
  principle: "Agent Team parallelizes Blake's work, does NOT replace Alex"
```

**File Ownership with Conflict Detection** (P0 fix):
```yaml
dependency_analysis:
  description: "Pre-check before creating Agent Team"
  steps:
    step1: "Read handoff 'Files to Modify' section"
    step2: "For each task, identify all files it will touch"
    step3: "Check for overlap between task file sets"
    step4: |
      IF overlap detected:
        → Log: "File overlap detected, using sequential mode"
        → Fallback to standard Ralph Loop (single agent)
      IF no overlap AND tasks >= 3:
        → Proceed with Agent Team
      IF tasks < 3:
        → Use standard Ralph Loop (overhead not worth it)

  shared_files_strategy:
    config_files: ["package.json", "tsconfig.json", ".env*", "*.config.*"]
    rule: "Only the lead (Blake) modifies shared config files AFTER teammates finish"
```

**Full section to insert in `ralph_loop_execution`**:

```yaml
# Agent Team Implementation Mode (TAD v2.3 - experimental)
# Insert in ralph_loop_execution, before develop_command steps
agent_team_develop:
  name: "Agent Team Implementation (Full TAD only)"
  description: "Parallel implementation with file ownership when conditions allow"
  experimental: true

  activation: |
    This mode REPLACES the standard sequential implementation when ALL conditions met:
    1. process_depth == "full"
    2. Agent Teams feature available
    3. dependency_analysis confirms zero file overlap
    4. handoff has 3+ independent tasks
    If any condition not met → use standard Ralph Loop.
    If Team fails mid-execution → fallback to standard Ralph Loop.

  terminal_scope_constraint:
    rule: "Implementation Team stays within Blake's domain"
    allowed: ["code writing", "test writing", "building", "linting"]
    forbidden: ["requirement changes", "handoff modifications", "design decisions"]

  dependency_analysis:
    step1: "Parse handoff task list and 'Files to Modify' section"
    step2: "Map each task → set of files it will create/modify"
    step3: "Compute intersection of all file sets"
    step4_decision: |
      overlap_count == 0 AND task_count >= 3 → PROCEED with Agent Team
      overlap_count > 0 → FALLBACK to sequential Ralph Loop
      task_count < 3 → FALLBACK (overhead not justified)

  team_prompt_template: |
    Create an agent team to implement this handoff:

    HANDOFF: {handoff_path}

    FILE OWNERSHIP (strictly enforced):
    {file_ownership_map}

    Rules:
    1. Each teammate ONLY edits files in their ownership list
    2. Shared config files (package.json, etc.) are RESERVED for the lead
    3. After implementation, run: build check on your files + relevant tests
    4. Report to lead: files changed, tests added, issues found

    CONSTRAINT: This is an IMPLEMENTATION team. Do NOT change requirements or design.

  workflow:
    phase1_parallel_implementation:
      - "Blake spawns teammates based on handoff tasks"
      - "Each teammate implements their assigned tasks"
      - "Each teammate runs lightweight self-check (tsc on their files, relevant tests)"

    phase2_integration:
      - "Blake (lead) applies shared config changes if needed"
      - "Blake runs full Layer 1 (build + test + lint + tsc) on combined result"
      - "Fix integration issues (Blake does this, not teammates)"

    phase3_expert_review:
      - "Blake runs standard Layer 2 (code-reviewer → test-runner etc.)"
      - "Same quality gate as current Ralph Loop"
      - "Gate 3 v2 checks apply normally"

  fallback_protocol: |
    Scenario A - Team creation fails:
      → Automatic fallback to standard Ralph Loop
    Scenario B - Teammate fails mid-execution:
      → Checkpoint completed work (git stash)
      → Remaining tasks: standard Ralph Loop
    Scenario C - Integration issues after parallel work:
      → Blake (lead) fixes integration in phase2
    All fallbacks are automatic — no user intervention needed.
```

**Insertion point**: After line ~265 in tad-blake.md (in ralph_loop_execution section, before develop_command)

---

### Task 4: Config Update - Agent Teams Settings
**Files**: `.tad/config-agents.yaml`
**Effort**: Small

Append the following section at the end of config-agents.yaml:

```yaml
# ==================== Agent Teams Configuration (v2.3 - experimental) ====================
agent_teams:
  enabled: true
  version: "1.0"
  experimental: true
  description: "Agent Teams integration for parallel review and implementation"
  prerequisite: "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 in settings.json"

  # Terminal Isolation Preservation (P0 from expert review)
  terminal_isolation:
    rule: "Agent Teams MUST NOT cross terminal boundaries"
    alex_team_scope: "Requirements, design, review ONLY — NO implementation"
    blake_team_scope: "Implementation, testing ONLY — NO design changes"
    handoff_still_required: true
    human_still_bridge: true

  # Coexistence strategy
  coexistence:
    strategy: "auto_by_complexity"
    rules:
      full_tad: "agent_team"       # Full TAD → try Agent Team first
      standard_tad: "subagent"     # Standard TAD → subagent
      light_tad: "subagent"        # Light TAD → subagent
      skip_tad: "none"             # Skip → direct
    user_override: true            # User can always override

  # Fallback
  fallback:
    enabled: true
    strategy: "auto_fallback_to_subagent"
    log: true
    blocking: false
    state_recovery: "git_stash"    # Checkpoint work before fallback

  # Cost control
  cost:
    teammate_model: "sonnet"       # Teammates use Sonnet
    lead_model: "inherit"          # Lead uses active model
    max_teammates: 4

  # Alex Review Team settings
  alex_review_team:
    min_reviewers: 3
    debate_round: true
    delegate_mode: true

  # Blake Implementation Team settings
  blake_implementation_team:
    min_tasks_for_team: 3
    delegate_mode: true
    file_ownership_strict: true
    dependency_analysis_required: true   # Must check file overlap before team
    shared_config_reserved_for_lead: true
```

---

## 4. Files to Modify

| # | File | Action | Scope |
|---|------|--------|-------|
| 1 | `CLAUDE.md` | Edit | Add Section 7: project-knowledge imports (~15 lines) |
| 2 | `.claude/commands/tad-alex.md` | Edit | Add `step3_agent_team` to handoff_creation_protocol (~60 lines) |
| 3 | `.claude/commands/tad-blake.md` | Edit | Add `agent_team_develop` to ralph_loop_execution (~70 lines) |
| 4 | `.tad/config-agents.yaml` | Edit | Append `agent_teams` section (~45 lines) |

**Total changes**: ~190 lines added across 4 files. All ADDITIVE — no deletions.

---

## 5. Acceptance Criteria

- [ ] AC1: CLAUDE.md Section 7 contains @import statements for all 9 knowledge categories
- [ ] AC2: Claude Code loads architecture.md content at startup (test: ask Claude "what do you know about TAD architecture?")
- [ ] AC3: Non-existent knowledge files (e.g., security.md) do NOT cause startup errors
- [ ] AC4: tad-alex.md contains `step3_agent_team` with terminal_scope_constraint
- [ ] AC5: tad-blake.md contains `agent_team_develop` with dependency_analysis
- [ ] AC6: config-agents.yaml contains `agent_teams` section with terminal_isolation rules
- [ ] AC7: Standard TAD workflow unchanged — subagent flow still works when process_depth != full
- [ ] AC8: Fallback protocol documented for both Alex and Blake Agent Team modes

---

## 6. Testing Checklist

### Knowledge Loading
- [ ] Start Claude Code in TAD project → ask about project architecture → confirm knowledge accessible
- [ ] Delete a knowledge file temporarily → confirm no startup error
- [ ] Check CLAUDE.md with `/memory` → verify imports listed

### Agent Teams - Alex
- [ ] Read tad-alex.md → verify step3_agent_team section present and parseable
- [ ] Verify terminal_scope_constraint forbids implementation code
- [ ] Verify fallback_protocol defined

### Agent Teams - Blake
- [ ] Read tad-blake.md → verify agent_team_develop section present and parseable
- [ ] Verify dependency_analysis step defined with overlap detection
- [ ] Verify shared_config_reserved_for_lead rule present
- [ ] Verify fallback_protocol handles partial failure scenario

### Config
- [ ] Read config-agents.yaml → verify agent_teams section loads without YAML errors
- [ ] Verify terminal_isolation rules present
- [ ] Verify coexistence strategy matches spec

### Failure Scenarios
- [ ] Agent Teams env var NOT set → verify subagent mode used (no Agent Team)
- [ ] File overlap detected → verify fallback to sequential mode
- [ ] tasks < 3 → verify fallback to sequential mode

---

## 7. Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Agent Teams unstable | Medium | Low | Auto fallback to subagent |
| Terminal isolation breach | Low | High | Explicit scope constraints in config + agent files |
| File conflicts in Blake team | Low (with dependency analysis) | Medium | Pre-check overlap → fallback if found |
| Context window growth | Medium (long-term) | Medium | 30KB cap + consolidation per README guidelines |
| Import syntax incorrect | Low | Medium | Verified: @relative/path is correct per Claude docs |

---

## 8. Implementation Notes

### Import Syntax (Verified)
Per Claude Code docs: `@path/to/file` in CLAUDE.md uses relative paths from the file's location. `@.tad/project-knowledge/architecture.md` resolves correctly from project root where CLAUDE.md lives. Non-existent files show an approval dialog on first encounter, then silently skip.

### Agent Teams Prerequisites
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` already in `~/.claude/settings.json`
- Known limitations: no session resume, one team per session, split panes need tmux
- Teammates inherit CLAUDE.md (so they'll also get project-knowledge imports)

### Terminal Isolation — Unchanged
- Alex Agent Team: review experts in Terminal 1 — review only, no code
- Blake Agent Team: implementation workers in Terminal 2 — code only, no design
- Handoff is STILL the only bridge between Alex and Blake
- Human is STILL the information bridge between terminals

### Backward Compatibility
- All changes are ADDITIVE
- Agent Team mode only activates under 3+ conditions simultaneously
- Fallback ensures zero regression
- Existing TAD workflows completely unchanged for Light/Standard depth
