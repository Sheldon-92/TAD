# TAD Initialize Command

When this command is triggered, execute the following:

## ⚠️ MANDATORY OUTPUT FORMAT

**This command MUST produce standardized output in the following format:**

### 📋 Initialization Checklist
Use this checklist format to track progress:
- [ ] TAD directory structure verification
- [ ] Core agent files installation
- [ ] Template files setup
- [ ] Project context initialization
- [ ] Success confirmation and next steps

### 📝 Required Output Sections
1. **Status Report**: Current state and actions taken
2. **File Operations**: List all files created/modified with paths
3. **Verification**: Confirm all components installed correctly
4. **Next Steps**: Clear instructions for agent activation
5. **Error Handling**: Any issues encountered and resolutions

---

## Initialize TAD Framework

1. **Check if TAD already exists**
   - Look for `.tad/` directory
   - If exists, warn user and ask for confirmation to reinitialize

2. **Create TAD structure**
   ```bash
   mkdir -p .tad/active/handoffs
   mkdir -p .tad/archive/handoffs
   mkdir -p .tad/gates
   mkdir -p .tad/project-knowledge
   mkdir -p .tad/templates/output-formats
   mkdir -p .claude/commands
   mkdir -p .claude/skills
   ```

3. **Copy core files from TAD repository**

   ⚠️ **IMPORTANT**: Only copy TAD-specific files, NOT entire directories!

   **TAD config:**
   - Copy `.tad/config.yaml`
   - Copy `.tad/version.txt`
   - Copy `.tad/templates/` (recursive)
   - Copy `.tad/skills/` (recursive)
   - Copy `.tad/schemas/` (recursive)

   **TAD commands only** (DO NOT copy non-TAD files like BMad):
   - Copy `.claude/commands/tad-*.md` (all files matching this pattern)
   - Copy `.claude/commands/coordinator.md`
   - Copy `.claude/commands/product.md`
   - Copy `.claude/commands/research.md`
   - Copy `.claude/commands/knowledge-audit.md`
   - ❌ DO NOT copy any directories inside `.claude/commands/`
   - ❌ DO NOT copy files that don't belong to TAD

   **TAD skills:**
   - Copy `.claude/skills/code-review/` (recursive)

4. **Create initial project files**
   - Create `PROJECT_CONTEXT.md` in project root
   - Create `NEXT.md` for task tracking
   - Create `CLAUDE.md` with TAD rules

5. **Bootstrap Project Knowledge** ⚠️ NEW
   - Read `.tad/templates/knowledge-bootstrap.md` for guidance
   - For each knowledge category, extract foundational info from codebase:

   ```yaml
   UX Knowledge:
     sources:
       - tailwind.config.ts (colors, fonts, spacing)
       - app/globals.css (CSS variables, theme)
       - components/ui/ (component library)
     output: .tad/project-knowledge/ux.md → "Foundational" section

   Code Quality:
     sources:
       - package.json (tech stack)
       - tsconfig.json (TypeScript config)
       - src/ structure (file organization)
     output: .tad/project-knowledge/code-quality.md → "Foundational" section

   Testing:
     sources:
       - vitest.config.ts or jest.config.js
       - existing test files (patterns)
       - package.json scripts
     output: .tad/project-knowledge/testing.md → "Foundational" section
   ```

   - If sources don't exist (new project), prompt user for inputs
   - Write "Foundational" section to each knowledge file
   - Mark "Accumulated Learnings" section as empty (to be filled during development)

6. **Verify Knowledge Bootstrap**
   - Check each `.tad/project-knowledge/*.md` file has content beyond template header
   - Report any files that need manual completion:
   ```
   Knowledge Bootstrap Status:
   ✅ ux.md - Foundational section populated
   ✅ code-quality.md - Foundational section populated
   ⚠️ security.md - Needs manual input (no auth config found)
   ✅ testing.md - Foundational section populated
   ```

7. **Multi-Platform Support** (TAD v2.2.1)

   Generate configurations for all supported AI coding platforms so the project works with Claude Code, Codex CLI, AND Gemini CLI.

   ### 7a. Codex CLI Support

   **Create AGENTS.md** (project root):
   - Read CLAUDE.md content
   - Replace platform-specific references:
     - "Claude Code" → "Codex CLI"
     - "/alex" → "/prompts:tad_alex"
     - "/blake" → "/prompts:tad_blake"
     - "/gate" → "/prompts:tad_gate"
     - "Task tool with subagent" → "read skill from .tad/skills/{skill}/SKILL.md"
   - Add Codex header section:
     ```markdown
     # TAD Framework Rules (Codex CLI)

     This file defines TAD rules for Codex CLI.

     ## Platform Notes
     - Skill execution: Self-check mode (read SKILL.md manually)
     - Commands: Use `/prompts:tad_alex`, `/prompts:tad_blake`, etc.
     - Evidence: Same location `.tad/evidence/reviews/`

     ---
     ```
   - Write to `AGENTS.md`

   **Create .codex/README.md**:
   ```markdown
   # TAD for Codex CLI

   This project uses TAD Framework. Core commands at `~/.codex/prompts/tad_*.md`.

   ## Quick Start
   - `/prompts:tad_alex` - Activate Alex (Solution Lead)
   - `/prompts:tad_blake` - Activate Blake (Execution Master)
   - `/prompts:tad_gate` - Run quality gate

   See AGENTS.md for full rules.
   ```

   **Generate Codex Commands** (to ~/.codex/prompts/):
   For each core command (tad-alex, tad-blake, tad-gate, tad-init, tad-status, tad-help):
   1. Read `.claude/commands/{name}.md`
   2. Add Codex header and footer
   3. Rename hyphen to underscore: `tad-alex.md` → `tad_alex.md`
   4. Write to `~/.codex/prompts/tad_{name}.md`

   ### 7b. Gemini CLI Support

   **Create GEMINI.md** (project root):
   - Read CLAUDE.md content
   - Replace platform-specific references:
     - "Claude Code" → "Gemini CLI"
     - "Task tool with subagent" → "read skill from .tad/skills/{skill}/SKILL.md"
   - Add Gemini header section:
     ```markdown
     # TAD Framework Rules (Gemini CLI)

     This file defines TAD rules for Gemini CLI.

     ## Platform Notes
     - Skill execution: Self-check mode (read SKILL.md manually)
     - Commands: Use `/tad-alex`, `/tad-blake`, etc.
     - Evidence: Same location `.tad/evidence/reviews/`
     - Context: Use @{file} syntax for file references

     ---
     ```
   - Write to `GEMINI.md`

   **Create .gemini/commands/ directory**

   **Generate Gemini Commands** (to .gemini/commands/):
   For each core command (tad-alex, tad-blake, tad-gate, tad-init, tad-status, tad-help):
   1. Read `.claude/commands/{name}.md`
   2. Extract first heading as description
   3. Convert to TOML format:
      ```toml
      description = "{first_heading}"

      prompt = """
      {original_markdown_content}

      ## Context
      @{GEMINI.md}
      @{.tad/skills/README.md}

      ## Arguments
      {{args}}
      """
      ```
   4. Write to `.gemini/commands/{name}.toml`

   **Create .gemini/README.md**:
   ```markdown
   # TAD for Gemini CLI

   This project uses TAD Framework.

   ## Quick Start
   - `/tad-alex` - Activate Alex (Solution Lead)
   - `/tad-blake` - Activate Blake (Execution Master)
   - `/tad-gate` - Run quality gate

   See GEMINI.md for full rules.
   ```

   ### 7c. Multi-Platform Status Report
   ```
   Multi-Platform Support:
   ✅ Claude Code: CLAUDE.md + .claude/commands/
   ✅ Codex CLI: AGENTS.md + ~/.codex/prompts/tad_*
   ✅ Gemini CLI: GEMINI.md + .gemini/commands/
   ```

8. **Display success message**
   ```
   ✅ TAD Framework initialized successfully!

   ## Platform Support
   ✅ Claude Code: CLAUDE.md + .claude/commands/
   ✅ Codex CLI: AGENTS.md + ~/.codex/prompts/tad_*
   ✅ Gemini CLI: GEMINI.md + .gemini/commands/

   ## Quick Start
   | Platform | Alex Command | Blake Command |
   |----------|--------------|---------------|
   | Claude   | /alex        | /blake        |
   | Codex    | /prompts:tad_alex | /prompts:tad_blake |
   | Gemini   | /tad-alex    | /tad-blake    |

   ## Next Steps
   1. Terminal 1: Activate Alex for design
   2. Terminal 2: Activate Blake for execution
   3. State your project requirements
   4. Begin triangle collaboration

   Available scenarios:
   - new_project: Starting from scratch
   - add_feature: Adding new functionality
   - bug_fix: Fixing problems
   - performance: Optimizing performance
   - refactoring: Code cleanup
   - deployment: Release preparation
   ```