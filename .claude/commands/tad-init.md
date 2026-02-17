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

7. **Display success message**
   ```
   ✅ TAD Framework initialized successfully!

   ## Quick Start
   | Command | Description |
   |---------|-------------|
   | /alex   | Start Alex (Solution Lead) |
   | /blake  | Start Blake (Execution Master) |
   | /gate   | Run quality gate |

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