# HANDOFF: Multi-Platform TAD Initialization

**Date**: 2026-01-26
**From**: Alex (Solution Lead)
**To**: Blake (Execution Master)
**Status**: Ready for Implementation

---

## Executive Summary

Update `/tad-init` to support multi-platform initialization. Goal: **One install, three platforms work** (Claude Code, Codex CLI, Gemini CLI).

## Core Requirements

When user runs `/tad-init` in any project:
1. Generate all platform configs so the project works with Claude, Codex, AND Gemini
2. Convert core TAD commands to each platform's format
3. Create platform-specific project instruction files

## Task Breakdown

### Task 1: Update /tad-init Command
**File**: `.claude/commands/tad-init.md`

Add section after step 4 (Create initial project files):

```markdown
5. **Multi-Platform Support** (NEW)

   Generate configurations for all supported platforms:

   a) **Codex CLI Support**
      - Create `AGENTS.md` from `CLAUDE.md` (replace Claude references)
      - Create `.codex/` directory with README
      - Copy core commands to `~/.codex/prompts/tad_*.md`

   b) **Gemini CLI Support**
      - Create `GEMINI.md` from `CLAUDE.md` (replace Claude references)
      - Create `.gemini/commands/` directory
      - Generate `.toml` files for core commands

   c) **Core Commands to Convert** (6 files only):
      - tad-alex.md
      - tad-blake.md
      - tad-gate.md
      - tad-init.md
      - tad-status.md
      - tad-help.md
```

### Task 2: Create AGENTS.md Template
**File**: `.tad/templates/AGENTS.md.template`

```markdown
# TAD Framework Rules (Codex CLI)

This file defines TAD rules for Codex CLI. Converted from CLAUDE.md.

## Platform Notes
- Skill execution: Self-check mode (read SKILL.md manually)
- Commands: Use `/prompts:tad_alex`, `/prompts:tad_blake`, etc.
- Evidence: Same location `.tad/evidence/reviews/`

---

{CORE_RULES_FROM_CLAUDE_MD}

---

## Codex-Specific Adjustments

### Skill Execution
Instead of calling subagents, read and follow skill checklists:
- Code review: `~/.codex/skills/tad/code-review/SKILL.md`
- Testing: `~/.codex/skills/tad/testing/SKILL.md`
- Security: `~/.codex/skills/tad/security-audit/SKILL.md`

### Command Reference
| TAD Command | Codex Equivalent |
|-------------|------------------|
| /alex | /prompts:tad_alex |
| /blake | /prompts:tad_blake |
| /gate | /prompts:tad_gate |
```

### Task 3: Create GEMINI.md Template
**File**: `.tad/templates/GEMINI.md.template`

```markdown
# TAD Framework Rules (Gemini CLI)

This file defines TAD rules for Gemini CLI. Converted from CLAUDE.md.

## Platform Notes
- Skill execution: Self-check mode (read SKILL.md manually)
- Commands: Use `/tad-alex`, `/tad-blake`, etc.
- Evidence: Same location `.tad/evidence/reviews/`
- Context: Use @{file} syntax for file references

---

{CORE_RULES_FROM_CLAUDE_MD}

---

## Gemini-Specific Adjustments

### Skill Execution
Instead of calling subagents, read and follow skill checklists:
- Code review: `.tad/skills/code-review/SKILL.md`
- Testing: `.tad/skills/testing/SKILL.md`
- Security: `.tad/skills/security-audit/SKILL.md`

### Context Injection
Use Gemini's file reference syntax:
- `@{GEMINI.md}` - Load project rules
- `@{.tad/skills/README.md}` - Load skill index
- `!{command}` - Execute shell command
```

### Task 4: Create Conversion Script Logic
**Add to**: `.claude/commands/tad-init.md`

```markdown
## Multi-Platform File Generation

### Step 5a: Generate AGENTS.md
1. Read CLAUDE.md
2. Replace:
   - "Claude Code" → "Codex CLI"
   - "/alex" → "/prompts:tad_alex"
   - "/blake" → "/prompts:tad_blake"
   - "call subagent" → "read skill from"
3. Add Codex platform notes header
4. Write to AGENTS.md

### Step 5b: Generate GEMINI.md
1. Read CLAUDE.md
2. Replace:
   - "Claude Code" → "Gemini CLI"
   - References to Task tool → "read skill manually"
3. Add Gemini platform notes header
4. Write to GEMINI.md

### Step 5c: Generate Codex Commands
For each core command (tad-alex, tad-blake, tad-gate, tad-init, tad-status, tad-help):
1. Read `.claude/commands/{name}.md`
2. Rename: `tad-alex.md` → `tad_alex.md`
3. Add header: "# TAD {name} Command (Codex)\n\nConverted for Codex CLI.\n\n---\n"
4. Append footer: "\n---\n## Codex Notes\n- Skills at ~/.codex/skills/tad/\n- Evidence at .tad/evidence/reviews/"
5. Write to `~/.codex/prompts/tad_{name}.md`

### Step 5d: Generate Gemini Commands
For each core command:
1. Read `.claude/commands/{name}.md`
2. Extract first heading as description
3. Convert to TOML format:
   ```toml
   description = "{first_heading}"

   prompt = """
   {original_content}

   ## Context
   @{GEMINI.md}
   @{.tad/skills/README.md}

   ## Arguments
   {{args}}
   """
   ```
4. Write to `.gemini/commands/{name}.toml`

### Step 5e: Create Project-Level README files
Create `.codex/README.md`:
```markdown
# TAD for Codex CLI

This project uses TAD Framework. Core commands installed at `~/.codex/prompts/tad_*.md`.

## Quick Start
- `/prompts:tad_alex` - Activate Alex (Solution Lead)
- `/prompts:tad_blake` - Activate Blake (Execution Master)
- `/prompts:tad_gate` - Run quality gate

See AGENTS.md for full rules.
```

Create `.gemini/README.md`:
```markdown
# TAD for Gemini CLI

This project uses TAD Framework.

## Quick Start
- `/tad-alex` - Activate Alex (Solution Lead)
- `/tad-blake` - Activate Blake (Execution Master)
- `/tad-gate` - Run quality gate

See GEMINI.md for full rules.
```
```

### Task 5: Update /tad-init Output Message
**File**: `.claude/commands/tad-init.md`

Update success message:

```markdown
7. **Display success message**
   ```
   ✅ TAD Framework initialized successfully!

   ## Platform Support
   ✅ Claude Code: CLAUDE.md + .claude/commands/
   ✅ Codex CLI: AGENTS.md + ~/.codex/prompts/tad_*
   ✅ Gemini CLI: GEMINI.md + .gemini/commands/

   ## Quick Start
   | Platform | Alex Command | Blake Command |
   |----------|--------------|---------------|
   | Claude | /alex | /blake |
   | Codex | /prompts:tad_alex | /prompts:tad_blake |
   | Gemini | /tad-alex | /tad-blake |

   Terminal 1: Activate Alex for design
   Terminal 2: Activate Blake for execution
   ```
```

### Task 6: Remove Adapters (Architecture Simplification)
**Action**: Delete unnecessary directories

```bash
# Remove from TAD source
rm -rf .tad/adapters/
rm -rf .tad/templates/command-converters/

# Remove from installed projects (after this update)
# These will be cleaned up when /tad-init is re-run
```

**Rationale**:
- Conversion logic is now directly in `/tad-init` command
- Templates (AGENTS.md.template, GEMINI.md.template) provide all needed info
- adapters/ was design docs, not executable config

### Task 7: Update config.yaml
**File**: `.tad/config.yaml`

Remove or comment out the `adapters` section:
```yaml
# REMOVED in v2.1.1 - Simplified architecture
# adapters:
#   directory: ".tad/adapters"
#   ...
```

Update multi_platform section:
```yaml
multi_platform:
  enabled: true
  version: "1.1"  # Updated
  description: |
    TAD v2.1.1 supports multiple AI coding assistants.
    All conversion logic is in /tad-init command.

  platforms:
    claude:
      config_dir: ".claude"
      project_instructions: "CLAUDE.md"
      commands_dir: ".claude/commands"

    codex:
      config_dir: ".codex"
      project_instructions: "AGENTS.md"
      commands_dir: "~/.codex/prompts"
      command_prefix: "tad_"

    gemini:
      config_dir: ".gemini"
      project_instructions: "GEMINI.md"
      commands_dir: ".gemini/commands"
      command_format: "toml"
```

## Files to Create/Modify

| Action | File |
|--------|------|
| MODIFY | `.claude/commands/tad-init.md` |
| CREATE | `.tad/templates/AGENTS.md.template` |
| CREATE | `.tad/templates/GEMINI.md.template` |
| DELETE | `.tad/adapters/` (entire directory) |
| DELETE | `.tad/templates/command-converters/` |
| MODIFY | `.tad/config.yaml` (remove adapters section) |

## Acceptance Criteria

- [ ] `/tad-init` generates `AGENTS.md` in project root
- [ ] `/tad-init` generates `GEMINI.md` in project root
- [ ] `/tad-init` creates `.codex/README.md`
- [ ] `/tad-init` creates `.gemini/commands/*.toml` (6 files)
- [ ] `/tad-init` copies commands to `~/.codex/prompts/tad_*.md` (6 files)
- [ ] Success message shows all three platforms
- [ ] `.tad/adapters/` directory removed
- [ ] `.tad/templates/command-converters/` directory removed
- [ ] `config.yaml` updated (adapters section removed)

## Testing Checklist

1. Run `/tad-init` in a test directory
2. Verify AGENTS.md exists and has correct content
3. Verify GEMINI.md exists and has correct content
4. Verify `.gemini/commands/` has 6 .toml files
5. Verify `~/.codex/prompts/` has 6 tad_*.md files
6. Open project in Codex CLI, run `/prompts:tad_alex`
7. Open project in Gemini CLI, run `/tad-alex`

---

## Expert Review Status

| Expert | Status | Notes |
|--------|--------|-------|
| code-reviewer | PENDING | |
| backend-architect | PENDING | |

---

**Next Step**: Blake executes in Terminal 2
