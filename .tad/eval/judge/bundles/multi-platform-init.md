
# HANDOFF: multi-platform-init

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

---

