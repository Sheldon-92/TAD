# TAD Skills Directory

This directory contains platform-agnostic skill definitions for TAD v2.1+.

## Overview

Skills are quality check definitions that can be executed by any AI coding assistant (Claude Code, Codex CLI, Gemini CLI). Each skill provides:

- **Checklist**: Items to verify during quality checks
- **Pass Criteria**: Conditions for passing the skill check
- **Evidence Output**: Where to save review results
- **Platform Execution**: How to run on different platforms

## Skills Inventory

| Skill | ID | Claude Subagent | Gate Usage |
|-------|-----|-----------------|------------|
| [Testing](./testing/SKILL.md) | testing | test-runner | Gate 3 |
| [Code Review](./code-review/SKILL.md) | code-review | code-reviewer | Gate 2, 3 |
| [Security Audit](./security-audit/SKILL.md) | security-audit | security-auditor | Gate 3, 4 |
| [Performance](./performance/SKILL.md) | performance | performance-optimizer | Gate 3, 4 |
| [UX Review](./ux-review/SKILL.md) | ux-review | ux-expert-reviewer | Gate 2, 4 |
| [Architecture](./architecture/SKILL.md) | architecture | backend-architect | Gate 2 |
| [API Design](./api-design/SKILL.md) | api-design | api-designer | Gate 2 |
| [Debugging](./debugging/SKILL.md) | debugging | debugging-assistant | Gate 3 |

## SKILL.md Format

Each skill file follows this structure:

```markdown
---
name: "{Skill Name}"
id: "{skill-id}"
version: "1.0"
claude_subagent: "{subagent-name}"
fallback: "self-check"
min_tad_version: "2.1"
platforms: ["claude", "codex", "gemini"]
---

# {Skill Name} Skill

## Purpose
{What this skill checks}

## When to Use
- {Usage scenario 1}
- {Usage scenario 2}

## Checklist
### Critical (P0) - Must Pass
- [ ] {Check item 1}

### Important (P1) - Should Pass
- [ ] {Check item 2}

### Nice-to-have (P2) - Informational
- [ ] {Check item 3}

## Pass Criteria
| Level | Requirement |
|-------|-------------|
| P0 | All items pass |
| P1 | Max N failures |
| P2 | Informational |

## Evidence Output
Path: `.tad/evidence/reviews/{date}-{skill-id}-{task}.md`

## Execution Contract
- **Input**: {input parameters}
- **Output**: {output structure}
- **Timeout**: {seconds}
- **Parallelizable**: {true/false}

## Claude Enhancement
When running on Claude Code, call subagent `{subagent-name}` for deeper analysis.
```

## Platform Execution

### Claude Code
Skills are executed via specialized subagents using the Task tool:
```
Use Task tool with subagent_type: "{claude_subagent}"
```

### Codex CLI / Gemini CLI
Skills are executed via self-check:
1. Read the SKILL.md checklist
2. Execute each check item
3. Generate evidence file
4. Report pass/fail status

## Conditional Skills

Some skills are conditionally triggered based on code patterns:

| Skill | Trigger Pattern |
|-------|----------------|
| security-audit | `auth\|token\|password\|credential\|...` |
| performance | `database\|query\|cache\|loop\|...` |

## Adding New Skills

1. Create directory: `.tad/skills/{skill-id}/`
2. Create `SKILL.md` following the format above
3. Add to this README's inventory table
4. Update adapter configurations if needed

## Version History

- **v1.0** (2026-01-26): Initial 8 P0 skills for TAD v2.1
