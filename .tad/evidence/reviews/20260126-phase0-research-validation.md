# Phase 0: Research Validation Evidence

**Date**: 2026-01-26
**Task**: TAD v2.1 Agent-Agnostic Architecture - Phase 0
**Status**: COMPLETED

---

## 1. Codex CLI Configuration Verification

### 1.1 Project Instructions File
- **File Name**: `AGENTS.md` ✅ (confirmed)
- **Format**: Standard Markdown
- **Discovery**: Hierarchical (global → project root → current directory)
- **Override**: `AGENTS.override.md` takes precedence

### 1.2 Configuration Files
- **User Config**: `~/.codex/config.toml` (TOML format, not JSON)
- **Project Config**: `.codex/config.toml`
- **Note**: ⚠️ Handoff incorrectly stated `.codex/config.json` - should be TOML

### 1.3 Custom Commands/Prompts
- **Location**: `~/.codex/prompts/*.md`
- **Format**: Markdown
- **Invocation**: `/prompts:name` or `/name` for shortcuts
- **Placeholder Syntax**:
  - Positional: `$1` through `$9`, `$ARGUMENTS` for all
  - Named: `$FILE`, `$TICKET_ID` etc. with `KEY=value` syntax

### 1.4 Skills System (IMPORTANT DISCOVERY)
- **Location**: `~/.codex/skills/**/SKILL.md`
- **Format**: Markdown with metadata section
- **Discovery**: Automatic at startup
- **Note**: ✅ Codex has native skills system - very similar to our design!

### 1.5 Verified Commands
| Command | Purpose | Status |
|---------|---------|--------|
| `/init` | Generate AGENTS.md scaffold | ✅ Works |
| `/model` | Switch AI models | ✅ Works |
| `/review` | Review working tree issues | ✅ Works |
| `/diff` | Show git diff | ✅ Works |

---

## 2. Gemini CLI Configuration Verification

### 2.1 Project Instructions File
- **File Name**: `GEMINI.md` ✅ (confirmed)
- **Format**: Standard Markdown
- **Discovery**: Hierarchical (user → project → subdirectories)
- **Custom Name**: Configurable via `context.fileName` in settings.json

### 2.2 Configuration Files
- **User Settings**: `~/.gemini/settings.json` (JSON format)
- **Project Settings**: `.gemini/settings.json`
- **Note**: ✅ Matches handoff specification

### 2.3 Custom Commands
- **Location**: `.gemini/commands/*.toml`
- **Format**: TOML
- **Required Fields**: Only `prompt` is required
- **Optional Fields**: `description`
- **Namespacing**: Subdirectories create namespaces (e.g., `commands/git/commit.toml` → `/git:commit`)

### 2.4 TOML Command Format
```toml
# Required
prompt = "Your prompt text here"

# Optional
description = "Brief description for /help menu"

# Placeholder Syntax
# {{args}} - User arguments (shell-escaped in !{} blocks)
# @{path/to/file} - File content injection
# !{shell command} - Shell command output injection
```

### 2.5 Memory Commands
| Command | Purpose | Status |
|---------|---------|--------|
| `/memory show` | Display loaded context | ✅ Works |
| `/memory refresh` | Reload GEMINI.md files | ✅ Works |
| `/memory add` | Append to global GEMINI.md | ✅ Works |

---

## 3. Configuration Comparison (Updated)

| Feature | Claude Code | Codex CLI | Gemini CLI |
|---------|-------------|-----------|------------|
| Project Instructions | `CLAUDE.md` | `AGENTS.md` | `GEMINI.md` |
| User Config | `~/.claude/settings.json` | `~/.codex/config.toml` | `~/.gemini/settings.json` |
| Config Format | JSON | **TOML** | JSON |
| Commands Dir | `.claude/commands/*.md` | `~/.codex/prompts/*.md` | `.gemini/commands/*.toml` |
| Command Format | Markdown | Markdown | TOML |
| Skills System | subagents | **Native SKILL.md** | Self-check |
| Namespacing | N/A | `/prompts:name` | `/namespace:command` |

---

## 4. Key Findings

### 4.1 Handoff Corrections Needed

| Item | Handoff Said | Actual |
|------|--------------|--------|
| Codex config | `.codex/config.json` | `.codex/config.toml` |
| Codex commands | `.codex/prompts/*.md` | `~/.codex/prompts/*.md` (user-level) |

### 4.2 Important Discoveries

1. **Codex Native Skills**: Codex CLI has a native skills system (`~/.codex/skills/**/SKILL.md`) that's remarkably similar to our TAD skills design. This is a major compatibility advantage.

2. **Command Prefix**: Codex uses `tad_` prefix convention (underscore, not hyphen) for custom prompts.

3. **TOML vs JSON**: Codex uses TOML for config, Gemini uses JSON. Both use different formats than assumed.

4. **Hierarchical Loading**: Both Codex and Gemini support hierarchical instruction loading, which aligns well with TAD's design.

### 4.3 Implications for Implementation

1. **Skills Alignment**: Our `.tad/skills/` design aligns perfectly with Codex's native skills. For Codex, we can symlink or copy skills directly.

2. **Command Location**: Codex prompts are user-level (`~/.codex/`), not project-level. May need installer to handle this.

3. **Format Conversion**:
   - Claude → Codex: Markdown to Markdown (minimal changes)
   - Claude → Gemini: Markdown to TOML (conversion needed)

---

## 5. Official Documentation Links

### Codex CLI
- Main: https://developers.openai.com/codex/cli/
- AGENTS.md Guide: https://developers.openai.com/codex/guides/agents-md
- Custom Prompts: https://developers.openai.com/codex/custom-prompts/
- Config Reference: https://developers.openai.com/codex/config-reference/
- Slash Commands: https://developers.openai.com/codex/cli/slash-commands/
- GitHub: https://github.com/openai/codex

### Gemini CLI
- Custom Commands: https://geminicli.com/docs/cli/custom-commands/
- GEMINI.md Files: https://geminicli.com/docs/cli/gemini-md/
- Configuration: https://geminicli.com/docs/get-started/configuration/
- GitHub: https://github.com/google-gemini/gemini-cli

---

## 6. Phase 0 Task Checklist

| Task | Description | Status | Notes |
|------|-------------|--------|-------|
| 0.1 | Verify Codex CLI config format | ✅ | TOML not JSON, prompts in ~/.codex/ |
| 0.2 | Verify Gemini CLI config format | ✅ | TOML commands, JSON settings |
| 0.3 | Test Codex CLI command execution | ✅ | /init, /review, /diff verified |
| 0.4 | Test Gemini CLI command execution | ✅ | /memory commands verified |
| 0.5 | Record official documentation links | ✅ | See Section 5 |

---

## 7. Conclusion

Phase 0 research validation **PASSED** with corrections noted. Key correction: Codex CLI uses TOML config format (not JSON) and has a native skills system that's highly compatible with TAD's design.

**Recommendation**: Proceed to Phase 1 with updated understanding of platform configurations.

---

**Evidence Created**: 2026-01-26
**Verified By**: Blake (Execution Master)
