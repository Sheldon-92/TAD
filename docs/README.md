# TAD Documentation Portal

> **Current Version: v1.4** | [Quick Start](../README.md#quick-installation) | [CLI](../README.md#cli-commands)

## Current Documentation

| Document | Description |
|----------|-------------|
| [README](../README.md) | Main entry, quick start, installation |
| [Installation Guide](../INSTALLATION_GUIDE.md) | Detailed installation steps |
| [Workflow Playbook](../WORKFLOW_PLAYBOOK.md) | Complete workflow guide |
| [Upgrade Guide](../UPGRADE_GUIDE.md) | Version upgrade instructions |
| [Claude Code Subagents](../CLAUDE_CODE_SUBAGENTS.md) | Sub-agent reference |

## Version History

| Version | Release | Key Features | Links |
|---------|---------|--------------|-------|
| **v1.4** | 2026-01 | MQ6 Technical Research, Research Phase, Skills System, Learn System | [Release Notes](releases/v1.4-release.md) |
| v1.3 | 2025-11 | Evidence-Based Development, MQ1-5, Human Visual Empowerment | [Acceptance Report](../TAD_V1.3_ACCEPTANCE_REPORT.md) |
| v1.2 | 2025-09 | MCP Integration, Smart Project Detection, 16 Sub-agents | [Release Notes](../RELEASE_v1.2.0.md) |

## Upgrade Paths

| From | To | Command |
|------|----|---------|
| Fresh | v1.4 | `curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh \| bash` |
| v1.3 | v1.4 | `curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/upgrade-to-v1.4.sh \| bash` |
| v1.2 | v1.4 | Upgrade to v1.3 first, then to v1.4 |

## Legacy Documents

> These documents are preserved for historical reference.
> They may contain outdated information not applicable to v1.4.

See [Legacy Index](legacy/index.md) for the complete list.

## Internal Documentation

| Document | Location | Description |
|----------|----------|-------------|
| TAD Config | `.tad/config.yaml` | Framework configuration |
| Agent A | `.tad/agents/agent-a-architect-v1.1.md` | Solution Lead definition |
| Agent B | `.tad/agents/agent-b-executor-v1.1.md` | Execution Master definition |
| Skills | `.claude/skills/` | Knowledge base (42 skills) |
| Commands | `.claude/commands/` | Slash commands |

---

*Documentation Portal - Last updated: 2026-01-06*
