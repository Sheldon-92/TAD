# TAD for Codex CLI

This project uses TAD Framework. Core commands at `~/.codex/prompts/tad_*.md`.

## Quick Start
- `/prompts:tad_alex` - Activate Alex (Solution Lead)
- `/prompts:tad_blake` - Activate Blake (Execution Master)
- `/prompts:tad_gate` - Run quality gate

See AGENTS.md for full rules.

## Command Reference

| TAD Command | Codex Equivalent |
|-------------|------------------|
| /alex | /prompts:tad_alex |
| /blake | /prompts:tad_blake |
| /gate | /prompts:tad_gate |
| /tad-init | /prompts:tad_init |
| /tad-status | /prompts:tad_status |
| /tad-help | /prompts:tad_help |

## Skill Execution

Codex uses self-check mode. Read skill definitions from `.tad/skills/{skill}/SKILL.md`.
