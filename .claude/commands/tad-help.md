# TAD Help Command

When this command is used, provide comprehensive help for using TAD Framework.

## ⚠️ MANDATORY OUTPUT FORMAT

**This command MUST provide structured help with clear sections:**

### 📚 Help Output Template
```
TAD Framework Help Guide
Version: v2.8.0 | Generated: [timestamp]

🚀 QUICK START CHECKLIST
- [ ] Install: curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash
- [ ] Initialize: /tad-init
- [ ] Verify: /tad-status
- [ ] Choose scenario: /tad-scenario [name]
- [ ] Activate agents: Follow terminal commands

📋 COMMAND REFERENCE
Each command produces standardized output:
/tad-init     → Initialization checklist + file operations
/tad-status   → Status report + readiness verification
/tad-scenario → Scenario plan + agent assignments
/tad-help     → This structured help guide
/tad-maintain → Document health check, sync, and cleanup (3 modes: check/sync/full)

🎭 AGENT ACTIVATION PROTOCOL
Must follow exact format:
Terminal 1: Use /alex command to activate Agent A
Terminal 2: Use /blake command to activate Agent B

⚠️ CRITICAL SUCCESS FACTORS
1. Agents MUST read their definition files first
2. Use mandatory startup checklists before proceeding
3. Follow handoff templates for all exchanges
4. Verify function existence before implementation
5. Test end-to-end data flow
6. Use *develop command for implementation (triggers Ralph Loop)
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

## Available Commands
- `/tad-init` - Initialize TAD for your project
- `/tad-status` - Check TAD installation and configuration
- `/tad-scenario [name]` - Start a development scenario
- `/tad-help` - Show this help message
- `/tad-maintain` - Document health check, sync, and cleanup (3 modes: check/sync/full)

### Alex Framework Management
- `*publish` - GitHub publish workflow (version check → push → tag)
- `*sync` - Sync TAD to registered projects (framework files, cleanup, verify)
- `*sync-add` - Register a new project for TAD sync
- `*sync-list` - List registered projects and sync status

## Adaptive Complexity
When you describe a task to Alex, he'll assess complexity and suggest one of:
- **Full TAD**: 6-8 questions, expert review, detailed handoff (architecture/complex features)
- **Standard TAD**: 4-5 questions, handoff, gates (new features, API changes)
- **Light TAD**: 2-3 questions, quick handoff (small changes, configs)
- **Skip TAD**: Direct implementation (trivial fixes, user opts out)
Alex suggests, **you decide** the process depth.

## Available Scenarios
- `new_project` - Start a new project from scratch
- `add_feature` - Add new functionality to existing project
- `bug_fix` - Fix bugs and issues
- `performance` - Optimize performance
- `refactoring` - Clean up technical debt
- `deployment` - Deploy to production
- `release` - Execute version release (see Release Management below)

## Release Management

### Version Commands
- **Alex**: `*release plan` - Plan major release, create release handoff
- **Blake**: `*release patch` - Execute patch release
- **Blake**: `*release minor` - Execute minor release
- **Blake**: `*release ios` - Execute iOS-specific release

### Key Documents
- `RELEASE.md` - Complete release SOP
- `CHANGELOG.md` - Version history
- `docs/API-VERSIONING.md` - API contract rules
- `.tad/templates/release-handoff.md` - Major release template

### Quick Release (Blake)
```bash
# Patch release
npm test && npm run build && npm version patch && git push origin main

# iOS release
npm run release:ios && npx cap open ios
```

### Major Release Flow
1. Alex: Analyze breaking changes, create release handoff
2. Blake: Execute per handoff, pass Gate 3R & 4R
3. Blake: Deploy web, then iOS if needed

## Activating Agents

### Agent A (Solution Lead)
In Terminal 1:
```
/alex
```

### Agent B (Execution Master)
In Terminal 2:
```
/blake
```

## Triangle Collaboration Model
```
      Human
       /\
      /  \
     /    \
Agent A -- Agent B
```

- **Human**: Defines value, validates delivery, relays messages between agents
- **Agent A**: Designs solutions, reviews quality
- **Agent B**: Implements code, runs tests

### Bidirectional Message Protocol
Agents auto-generate structured, copy-pasteable messages for the human to relay:
- **Alex → Blake**: After handoff creation, Alex generates a "Message from Alex" with task, files, priority
- **Blake → Alex**: After implementation, Blake generates a "Message from Blake" with status, changes, evidence
- **Blake auto-detect**: On startup, Blake scans for active handoffs and offers to execute them

## Configuration Files
- `.tad/config.yaml` - Main configuration
- `.claude/commands/tad-alex.md` - Agent A definition
- `.claude/commands/tad-blake.md` - Agent B definition
- `.tad/active/handoffs/` - Active handoff documents
- `.tad/project-knowledge/` - Project-specific learnings

## Epic/Roadmap (Multi-Phase Task Tracking)

Epics track large tasks that span multiple handoffs/phases.

### When to Use
- Task requires multiple sequential phases (>1 handoff)
- Alex suggests Epic during Adaptive Complexity assessment
- User can always choose single handoff instead

### How It Works
```
1. Alex assesses task → suggests Epic (user decides)
2. Alex creates Epic file with Phase Map
3. Alex creates Phase 1 Handoff (linked to Epic)
4. Blake implements Phase 1 → Gate 3 → *accept
5. *accept updates Epic: Phase 1 ✅, asks about Phase 2
6. Repeat until all phases complete → Epic archived
```

### Key Concepts
- **Phase Map**: Table tracking all phases with status (⬚ Planned / 🔄 Active / ✅ Done)
- **Derived Status**: Epic status computed from Phase Map (no independent Status field)
- **Sequential Constraint**: Only 1 Active phase per Epic at a time
- **Error Resilience**: Epic update failure doesn't block handoff archiving

### File Locations
- Active: `.tad/active/epics/EPIC-{YYYYMMDD}-{slug}.md`
- Archive: `.tad/archive/epics/`
- Template: `.tad/templates/epic-template.md`

### Health Checks (/tad-maintain)
6 check types: STALE, ORPHAN, DANGLING_REF, BACK_REF_MISMATCH, STUCK, OVER_ACTIVE

## Pair Testing (E2E 配对测试)

TAD 支持跨工具的配对 E2E 测试：

| 阶段 | 触发 | 产出 |
|------|------|------|
| Gate 4 后 | Alex 评估建议，人类决定 | `.tad/pair-testing/{session_id}/TEST_BRIEF.md` |
| 配对测试 | 用户 + Claude Code + Playwright (4D Protocol) | `.tad/pair-testing/{session_id}/PAIR_TEST_REPORT.md` |
| 报告回流 | Alex 检测报告 | 新 Handoff（修复任务）|

- Alex 在 Gate 4 后评估是否需要配对测试（UI/用户流变更时建议）
- 人类决定是否生成 TEST_BRIEF.md
- 后端/配置/文档等非 UI 变更自动跳过

手动命令：`/tad-test-brief` - 独立生成测试简报
Alex 命令：`*test-review` - 审阅测试报告并生成修复 Handoff

## Sub-agents Available
TAD integrates with 16 Claude Code sub-agents:
- Strategic: product-expert, backend-architect, api-designer, etc.
- Execution: parallel-coordinator, fullstack-dev-expert, bug-hunter, etc.

## Documentation
- GitHub: https://github.com/Sheldon-92/TAD
- Workflow Guide: See WORKFLOW_PLAYBOOK.md
- Sub-agents: See CLAUDE_CODE_SUBAGENTS.md
 - Skills: `.tad/skills/` (8 platform-agnostic skills)
 - Config: `.tad/config.yaml` + modular config files (`config-agents`, `config-quality`, `config-execution`, `config-platform`)

## TAD v2.8.0 Highlights
- **Beneficial Friction**: AI executes, humans guard value at 3 critical friction points
- **Pair Testing Protocol**: E2E pair testing with Claude Code + Playwright (4D Protocol)
- **Adaptive Complexity**: Auto-suggest process depth based on task size
- **Ralph Loop**: Iterative quality cycles with expert exit conditions

## Support
Report issues at: https://github.com/Sheldon-92/TAD/issues
```
