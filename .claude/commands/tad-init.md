# TAD Initialize Command

When this command is triggered, execute the following:

## Initialize TAD Framework

1. **Check if TAD already exists**
   - Look for `.tad/` directory
   - If exists, warn user and ask for confirmation to reinitialize

2. **Create TAD structure**
   ```bash
   mkdir -p .tad/agents
   mkdir -p .tad/context
   mkdir -p .tad/working
   ```

3. **Copy core files from TAD repository**
   - Copy `.tad/config.yaml`
   - Copy `.tad/agents/agent-a-architect.md`
   - Copy `.tad/agents/agent-b-executor.md`
   - Copy `WORKFLOW_PLAYBOOK.md`
   - Copy `CLAUDE_CODE_SUBAGENTS.md`
   - Copy `README.md` as `.tad/README.md`

4. **Create initial project files**
   - Create `.tad/context/PROJECT.md` with project name
   - Create `.tad/context/REQUIREMENTS.md` (empty template)
   - Create `.tad/context/ARCHITECTURE.md` (empty template)

5. **Display success message**
   ```
   ✅ TAD Framework initialized successfully!

   Next steps:
   1. Terminal 1: Activate Agent A with "You are Agent A, read .tad/agents/agent-a-architect.md"
   2. Terminal 2: Activate Agent B with "You are Agent B, read .tad/agents/agent-b-executor.md"
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