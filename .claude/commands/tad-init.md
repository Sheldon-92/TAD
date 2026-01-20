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
   mkdir -p .tad/learnings/pending
   mkdir -p .tad/learnings/pushed
   mkdir -p .tad/project-knowledge
   mkdir -p .tad/templates/output-formats
   mkdir -p .claude/commands
   mkdir -p .claude/skills
   ```

3. **Copy core files from TAD repository**
   - Copy `.tad/config.yaml`
   - Copy `.claude/commands/tad-alex.md`
   - Copy `.claude/commands/tad-blake.md`
   - Copy other TAD commands to `.claude/commands/`

4. **Create initial project files**
   - Create `PROJECT_CONTEXT.md` in project root
   - Create `NEXT.md` for task tracking
   - Create `CLAUDE.md` with TAD rules

5. **Display success message**
   ```
   ✅ TAD Framework initialized successfully!

   Next steps:
   1. Terminal 1: Use /alex to activate Agent A
   2. Terminal 2: Use /blake to activate Agent B
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