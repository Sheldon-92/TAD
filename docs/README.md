# TAD Documentation Portal

> **Current Version: v2.1** | [Quick Start](../README.md#-installation--upgrade) | [Multi-Platform](MULTI-PLATFORM.md)

## Current Documentation

| Document | Description |
|----------|-------------|
| [README](../README.md) | Main entry, quick start, installation |
| [Installation Guide](../INSTALLATION_GUIDE.md) | Detailed installation steps |
| [Multi-Platform Guide](MULTI-PLATFORM.md) | Claude/Codex/Gemini support (v2.1) |
| [Ralph Loop Guide](RALPH-LOOP.md) | Autonomous quality cycles (v2.0) |
| [Migration Guide](MIGRATION-v2.md) | Upgrade from older versions |

## Version History

| Version | Release | Key Features | Links |
|---------|---------|--------------|-------|
| **v2.1** | 2026-01-26 | Agent-Agnostic Architecture, Multi-Platform Support, 8 P0 Skills | [Changelog](../CHANGELOG.md) |
| v2.0 | 2026-01-26 | Ralph Loop Fusion, Gate 3/4 Restructure | [Ralph Loop](RALPH-LOOP.md) |
| v1.8 | 2026-01-25 | Human-in-the-Loop, Terminal Isolation | - |
| v1.6 | 2026-01-24 | Unified Install Script | [Release Notes](releases/v1.6-release.md) |
| v1.4 | 2026-01-15 | Research Phase, Skills System | [Release Notes](releases/v1.4-release.md) |

## Upgrade Paths

| From | To | Command |
|------|----|---------|
| Fresh | v2.1 | `curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh \| bash` |
| v2.0 | v2.1 | `curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh \| bash` |
| v1.x | v2.1 | `curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh \| bash` |

All upgrades preserve your data (handoffs, learnings, evidence).

## Platform Support (v2.1)

| Platform | Config | Commands | Skills |
|----------|--------|----------|--------|
| Claude Code | `.claude/` | `/alex`, `/blake` | subagent |
| Codex CLI | `.codex/` | `/prompts:tad_alex` | self-check |
| Gemini CLI | `.gemini/` | `/tad-alex` | self-check |

See [Multi-Platform Guide](MULTI-PLATFORM.md) for details.

## Internal Documentation

| Document | Location | Description |
|----------|----------|-------------|
| TAD Config | `.tad/config.yaml` | Framework configuration |
| Skills | `.tad/skills/` | Platform-agnostic skills (8) |
| Adapters | `.tad/adapters/` | Platform configurations |
| Commands | `.claude/commands/` | Slash commands |
| Ralph Config | `.tad/ralph-config/` | Ralph Loop settings |

## Legacy Documents

> These documents are preserved for historical reference.

See [Legacy Index](legacy/index.md) for the complete list.

## Archived Documents

> Development reports, setup guides, and design documents from early TAD development.

See [Archive Index](archive/index.md) for the complete list.

---

*Documentation Portal - Last updated: 2026-01-26*
