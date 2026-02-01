# TAD Multi-Platform Guide

**Version 2.2.1**

> TAD supports multiple AI coding assistants: Claude Code, Codex CLI, and Gemini CLI.

---

## Supported Platforms

| Platform | Skill Execution | Config Directory | Project Instructions |
|----------|-----------------|------------------|---------------------|
| **Claude Code** | subagent (native) | `.claude/` | `CLAUDE.md` |
| **Codex CLI** | self-check | `.codex/` | `AGENTS.md` |
| **Gemini CLI** | self-check | `.gemini/` | `GEMINI.md` |

---

## Installation

### Automatic (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash
```

The script automatically:
1. Detects installed AI CLI tools
2. Creates platform-specific configurations
3. Generates project instruction files
4. Installs 8 platform-agnostic skills

### Platform Detection

The installer checks for:
- **Claude Code**: `claude --version` or `~/.claude/` directory
- **Codex CLI**: `codex --version` or `~/.codex/` directory
- **Gemini CLI**: `gemini --version` or `~/.gemini/` directory

If no platform is detected, it defaults to Claude Code configuration.

---

## Platform-Specific Commands

### Claude Code

```
/alex       - Activate Alex (Solution Lead)
/blake      - Activate Blake (Execution Master)
/gate N     - Run quality gate N
/tad-init   - Initialize TAD
```

### Codex CLI

```
/prompts:tad_alex   - Activate Alex
/prompts:tad_blake  - Activate Blake
/prompts:tad_gate   - Run quality gate
/prompts:tad_init   - Initialize TAD
```

### Gemini CLI

```
/tad-alex   - Activate Alex
/tad-blake  - Activate Blake
/tad-gate   - Run quality gate
/tad-init   - Initialize TAD
```

---

## Skill Execution Modes

### Claude Code: Subagent Mode

Claude Code uses native subagents for deep analysis:

```
Skill Trigger → Task Tool → Subagent Execution → Evidence File
```

| Skill | Claude Subagent |
|-------|-----------------|
| testing | test-runner |
| code-review | code-reviewer |
| security-audit | security-auditor |
| performance | performance-optimizer |
| ux-review | ux-expert-reviewer |
| architecture | backend-architect |
| api-design | api-designer |
| debugging | debugging-assistant |

### Codex/Gemini: Self-Check Mode

Non-Claude platforms read skill definitions and execute checklists:

```
Skill Trigger → Read .tad/skills/{skill}/SKILL.md → Execute Checklist → Evidence File
```

Each SKILL.md contains:
- YAML frontmatter with metadata
- Checklist items by severity (P0-P3)
- Pass criteria
- Evidence output format

---

## Skill Files

### Location

```
.tad/skills/
├── README.md
├── testing/SKILL.md
├── code-review/SKILL.md
├── security-audit/SKILL.md
├── performance/SKILL.md
├── ux-review/SKILL.md
├── architecture/SKILL.md
├── api-design/SKILL.md
└── debugging/SKILL.md
```

### SKILL.md Format

```markdown
---
name: "Code Review"
id: "code-review"
version: "1.0"
claude_subagent: "code-reviewer"
fallback: "self-check"
min_tad_version: "2.1"
platforms: ["claude", "codex", "gemini"]
---

# Code Review Skill

## Purpose
Review code for quality, maintainability, security...

## Checklist

### Critical (P0) - Must Pass
- [ ] No security vulnerabilities
- [ ] No data loss risks

### Important (P1) - Should Pass
- [ ] No logic errors
- [ ] Features work as specified

### Nice-to-have (P2) - Informational
- [ ] Consistent naming conventions
- [ ] Minimal code duplication

## Pass Criteria
| Level | Requirement |
|-------|-------------|
| P0 | Zero issues allowed |
| P1 | Zero issues allowed |
| P2 | Max 10 issues |

## Evidence Output
Path: `.tad/evidence/reviews/{date}-code-review-{task}.md`
```

---

## Platform Adapters

### Configuration

Platform definitions are in `.tad/adapters/platform-codes.yaml`:

```yaml
platforms:
  claude-code:
    skill_execution: subagent
    config_dir: .claude
    project_instructions: CLAUDE.md

  codex-cli:
    skill_execution: self-check
    config_dir: .codex
    project_instructions: AGENTS.md

  gemini-cli:
    skill_execution: self-check
    config_dir: .gemini
    project_instructions: GEMINI.md
```

### Adapter Interface

Each adapter implements:
- `detect_installation` - Check if platform is installed
- `generate_config` - Create platform-specific files
- `convert_command` - Transform command format
- `execute_skill` - Run skill with appropriate mode

---

## Mixed Platform Usage

You can use different platforms for different roles:

| Scenario | Alex (Design) | Blake (Execution) |
|----------|---------------|-------------------|
| Claude Only | Claude Code | Claude Code |
| Mixed | Claude Code | Codex CLI |
| Mixed | Gemini CLI | Claude Code |
| Non-Claude | Codex CLI | Gemini CLI |

**Recommendation**: Use Claude Code for at least one agent to leverage subagent capabilities.

---

## Backward Compatibility

### For Existing Claude Code Users

**No changes required.** TAD v2.1 is 100% backward compatible:

- `.claude/` directory structure unchanged
- All existing commands work identically
- Subagent calls unchanged
- Evidence file format unchanged

### New Files (Non-breaking)

These files are **only created if platforms are detected**:

- `.codex/` - Codex CLI configuration
- `.gemini/` - Gemini CLI configuration
- `AGENTS.md` - Codex project instructions
- `GEMINI.md` - Gemini project instructions

---

## Troubleshooting

### "Platform not detected"

Check if the CLI tool is installed:
```bash
claude --version  # Claude Code
codex --version   # Codex CLI
gemini --version  # Gemini CLI
```

### "SKILL.md not found"

Verify skills directory exists:
```bash
ls .tad/skills/
```

If missing, re-run the installer:
```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash
```

### "Command not available in Codex/Gemini"

Check if commands were converted:
```bash
ls ~/.codex/prompts/tad_*   # Codex
ls .gemini/commands/tad-*   # Gemini
```

---

## Further Reading

- [Installation Guide](../INSTALLATION_GUIDE.md)
- [Ralph Loop Guide](RALPH-LOOP.md)
- [Skills Reference](../.tad/skills/README.md)
- [Changelog](../CHANGELOG.md)

---

*TAD v2.1 - Use your favorite AI coding assistant.*
