# TAD Help Command

When this command is used, provide comprehensive help for using TAD Framework.

## ⚠️ MANDATORY OUTPUT FORMAT

**This command MUST provide structured help with clear sections:**

### 📚 Help Output Template
```
TAD Framework Help Guide
Version: v1.4 | Generated: [timestamp]

🚀 QUICK START CHECKLIST
- [ ] Install: curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash
- [ ] Initialize: /tad-init
- [ ] Verify: /tad-status
- [ ] Choose scenario: /tad-scenario [name]
- [ ] Activate agents: Follow terminal commands
 - [ ] Record learnings (optional): /tad-learn

📋 COMMAND REFERENCE
Each command produces standardized output:
/tad-init     → Initialization checklist + file operations
/tad-status   → Status report + readiness verification
/tad-scenario → Scenario plan + agent assignments
/tad-help     → This structured help guide
/tad-learn    → Framework-level learning recorder (v1.4)

🎭 AGENT ACTIVATION PROTOCOL
Must follow exact format:
Terminal 1: "You are Agent A. Read .tad/agents/agent-a-architect.md"
Terminal 2: "You are Agent B. Read .tad/agents/agent-b-executor.md"

⚠️ CRITICAL SUCCESS FACTORS
1. Agents MUST read their definition files first
2. Use mandatory startup checklists before proceeding
3. Follow handoff templates for all exchanges
4. Verify function existence before implementation
5. Test end-to-end data flow
6. v1.4: For technical decisions, run MQ6 research and provide sources
```

---

## Command Response

```markdown
# TAD Framework Help

## Quick Start
1. **Install TAD**: `curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash`
2. **Initialize project**: `/tad-init`
3. **Check status**: `/tad-status`
4. **Start scenario**: `/tad-scenario [name]`
5. **Record learnings (optional)**: `/tad-learn`

## Available Commands
- `/tad-init` - Initialize TAD for your project
- `/tad-status` - Check TAD installation and configuration
- `/tad-scenario [name]` - Start a development scenario
- `/tad-help` - Show this help message
- `/tad-learn` - Record framework-level learning and suggestions (v1.4)

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
- `tad-work/context/` - Project context
- `tad-work/working/` - Active work documents

## Sub-agents Available
TAD integrates with 16 Claude Code sub-agents:
- Strategic: product-expert, backend-architect, api-designer, etc.
- Execution: parallel-coordinator, fullstack-dev-expert, bug-hunter, etc.

## Documentation
- GitHub: https://github.com/Sheldon-92/TAD
- Workflow Guide: See WORKFLOW_PLAYBOOK.md
- Sub-agents: See CLAUDE_CODE_SUBAGENTS.md
 - Skills: `.claude/skills/` (auto-discovered knowledge base, v1.4)
 - v1.4 Features in config: `.tad/config.yaml` → `mandatory_questions`, `requirement_elicitation.research_phase`, `skills_system`, `learn_system`

## TAD v1.4 Highlights
- **MQ6 Technical Research**: Technical decisions require lightweight research with sources and a final tech stack confirmation report
- **Research Phase**: Inline research during elicitation + pre-design final review
- **Skills System**: Auto-load knowledge from `.claude/skills/` to support decisions
- **Learn System**: Use `/tad-learn` to capture framework-level improvements

## Support
Report issues at: https://github.com/Sheldon-92/TAD/issues
```
