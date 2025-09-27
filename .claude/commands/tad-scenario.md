# TAD Scenario Execution Command

When user types `/tad-scenario [scenario_name]`, execute the corresponding workflow:

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
   - Create .tad/working/current-scenario.md with scenario details
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