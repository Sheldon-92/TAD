---
name: tad-scenario
description: Execute TAD scenario workflows. Use with scenario name parameter.
---

# TAD Scenario Execution Command

When user types `/tad-scenario [scenario_name]`, execute the corresponding workflow:

## ⚠️ MANDATORY OUTPUT FORMAT

**This command MUST produce scenario-specific structured output:**

### 📋 Scenario Execution Template
```
TAD Scenario: [scenario_name]
Started: [timestamp]

🎯 SCENARIO OVERVIEW
- Type: [scenario_name]
- Complexity: [Low/Medium/High]
- Estimated Duration: [time estimate]
- Key Deliverables: [list]

📊 AGENT ROLE ASSIGNMENTS
Agent A (Architect) - Alex:
- [ ] [Specific task 1] using [sub-agent]
- [ ] [Specific task 2] using [sub-agent]
- [ ] [Handoff checkpoint]

Agent B (Executor) - Blake:
- [ ] [Specific task 1] using [sub-agent]
- [ ] [Specific task 2] using [sub-agent]
- [ ] [Delivery checkpoint]

🔄 HANDOFF POINTS
1. [Agent A] → [Agent B]: [What gets handed off]
2. [Agent B] → [Agent A]: [What gets reported back]
3. [Final] → [Human]: [Final deliverable]

📁 WORKING FILES CREATED
- .tad/active/handoffs/HANDOFF-[date]-[name].md
- [Other scenario-specific files]

⚡ ACTIVATION COMMANDS
Terminal 1: /alex
Terminal 2: /blake
```

---

## Available Scenarios

1. **new_project** - Starting from scratch
2. **add_feature** - Adding new functionality
3. **bug_fix** - Fixing problems
4. **performance** - Optimizing performance
5. **refactoring** - Code cleanup
6. **deployment** - Release preparation

## Execution Steps

When scenario is selected:

1. **Load scenario configuration** from .tad/config.yaml

2. **Display scenario workflow**:
   ```
   Executing [scenario_name] scenario...

   Agent A will:
   - [List agent A tasks]

   Agent B will:
   - [List agent B tasks]

   Expected outputs:
   - [List expected documents/results]
   ```

3. **Create working documents**:
   - Create handoff in `.tad/active/handoffs/` if needed
   - Initialize any needed templates

4. **Provide activation instructions**:
   ```
   Ready to start [scenario_name] workflow!

   Next steps:
   1. Activate Agent A in terminal 1
   2. Activate Agent B in terminal 2
   3. Agent A will begin with [first task]
   ```

## Example Usage

```
/tad-scenario add_feature

Starting "add_feature" scenario...
✅ Scenario loaded
✅ Working documents created
✅ Agents ready

Agent A tasks:
1. Analyze feature requirements (product-expert)
2. Design solution (api-designer, backend-architect)
3. Create implementation plan

Agent B tasks:
1. Assess code impact (code-reviewer)
2. Develop feature (fullstack-dev-expert)
3. Run tests (test-runner)

Activate agents to begin!
```