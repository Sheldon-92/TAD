# TAD Help Command

When this command is used, provide comprehensive help for using TAD Framework.

## Command Response

```markdown
# TAD Framework Help

## Quick Start
1. **Install TAD**: `curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash`
2. **Initialize project**: `/tad-init`
3. **Check status**: `/tad-status`
4. **Start scenario**: `/tad-scenario [name]`

## Available Commands
- `/tad-init` - Initialize TAD for your project
- `/tad-status` - Check TAD installation and configuration
- `/tad-scenario [name]` - Start a development scenario
- `/tad-help` - Show this help message

## Available Scenarios
- `new_project` - Start a new project from scratch
- `add_feature` - Add new functionality to existing project
- `bug_fix` - Fix bugs and issues
- `performance` - Optimize performance
- `refactoring` - Clean up technical debt
- `deployment` - Deploy to production

## Activating Agents

### Agent A (Strategic Architect)
In Terminal 1:
```
You are Agent A. Read .tad/agents/agent-a-architect.md
```

### Agent B (Execution Master)
In Terminal 2:
```
You are Agent B. Read .tad/agents/agent-b-executor.md
```

## Triangle Collaboration Model
```
      Human
       /\
      /  \
     /    \
Agent A -- Agent B
```

- **Human**: Defines value, validates delivery
- **Agent A**: Designs solutions, reviews quality
- **Agent B**: Implements code, runs tests

## Configuration Files
- `.tad/config.yaml` - Main configuration
- `.tad/agents/` - Agent definitions
- `.tad/context/` - Project context
- `.tad/working/` - Active work documents

## Sub-agents Available
TAD integrates with 16 Claude Code sub-agents:
- Strategic: product-expert, backend-architect, api-designer, etc.
- Execution: parallel-coordinator, fullstack-dev-expert, bug-hunter, etc.

## Documentation
- GitHub: https://github.com/Sheldon-92/TAD
- Workflow Guide: See WORKFLOW_PLAYBOOK.md
- Sub-agents: See CLAUDE_CODE_SUBAGENTS.md

## Support
Report issues at: https://github.com/Sheldon-92/TAD/issues
```