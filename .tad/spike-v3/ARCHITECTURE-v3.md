# TAD v3.0 Architecture Blueprint

**Date**: 2026-03-31
**Epic**: EPIC-20260331-tad-v3-hook-native-rebuild (Phase 1)
**Status**: Approved

---

## Design Philosophy

1. **Declarative > Imperative**: Rules in hooks/settings, not prompt instructions
2. **Framework-first**: Mechanical work in shell scripts, judgment work in LLM
3. **Composable**: Hooks + skills as independent layers, not monolithic files
4. **CLI-first tools**: Shell commands default, MCP only for stateful/remote

## Architecture Layers

```
Layer 1: CLAUDE.md (<50 lines) — Pure router, role declaration
Layer 2: settings.json — Claude Code native: hooks + permissions
Layer 3: .tad/hooks/*.sh — Shell scripts for automation
Layer 4: Skills (alex/, blake/) — Judgment-only prompt logic (~800 lines each max)
Layer 5: Config (.tad/*.yaml) — Static configuration extracted from skills
```

## Spike-Validated Mechanisms

| Mechanism | Status | Role in v3.0 |
|-----------|--------|-------------|
| PostToolUse command hook | ✅ | Primary: workflow automation |
| PreToolUse prompt hook (Haiku) | ✅ | Primary: intelligent tool gating |
| SessionStart hook | ✅ | Primary: startup bootstrapping |
| Hook `if` condition | ✅ | Primary: targeted hook execution |
| permissions.deny (tool-level) | ✅ | Optional: hard tool removal |
| Parallel Agent spawning | ✅ | Enhancement: concurrent reviews |
| Skill fork + model override | ✅ | Enhancement: cost-effective sub-agents |

## Enforcement Priority (Confirmed by Spike)

```
permissions.deny (highest — removes tool entirely, unoverridable)
  ↓
hooks.PreToolUse (runs for available tools, can deny/allow/modify)
  ↓
permissions.allow / allowed-tools (auto-approval, unreliable)
  ↓
user permission prompt (lowest)
```

## Hook Architecture

### settings.json hooks section:

| Event | Matcher | Type | Script/Config | Purpose |
|-------|---------|------|--------------|---------|
| SessionStart | (all) | command | startup-health.sh | Health check + Linear sync + state injection |
| PostToolUse | Write\|Edit | command (async) | post-write-sync.sh | Detect key file changes → auto side effects |
| PreToolUse | Write\|Edit | prompt (Haiku) | inline | Intelligent gating for source files during design phase |
| PreToolUse | Bash | command | — | if: "Bash(rm -rf *)" → hard block destructive commands |

### Hook Scripts (.tad/hooks/):

**startup-health.sh** (SessionStart):
- Count active handoffs, epics, ideas
- Check NEXT.md for blocked items
- Output additionalContext with health summary
- Zero LLM cost, <100ms execution

**post-write-sync.sh** (PostToolUse, async):
- Reads tool_input from stdin (JSON)
- Detects file path patterns:
  - HANDOFF-*.md created → inject "Gate 2 reminder" via additionalContext
  - COMPLETION-*.md created → inject "Gate 4 reminder"
  - NEXT.md modified → trigger Linear sync (if configured)
  - EPIC-*.md modified → inject phase status update
- Async execution: doesn't block model

## Skill Reduction Plan

### Alex: 2528 → ~800 lines

| What Stays (~800) | What Moves | Where It Goes |
|---|---|---|
| Intent Router (150 lines) | Activation steps 3.4-3.7 | startup-health.sh |
| Socratic Inquiry (167) | *accept file operations | post-write-sync.sh + archive-helper.sh |
| Adaptive Complexity (140) | NEXT.md update rules | post-write-sync.sh |
| Bug/Discuss/Idea/Learn paths (~260) | Gate checklists | .tad/gates/*.yaml |
| Research & Decision protocol (97) | Expert selection rules | .tad/config-quality.yaml (existing) |
| Design protocol (41) | Command list, signal words | Already in config-workflow.yaml |
| Handoff: expert review + feedback (100) | Sync/Publish protocols | Separate scripts or simplified |

### Blake: 1052 → ~600 lines

| What Stays (~600) | What Moves | Where It Goes |
|---|---|---|
| Ralph Loop (core) | Startup health check | startup-health.sh |
| *develop workflow | Git check in *accept | Hook or script |
| Gate 3 execution | Mechanical file operations | archive-helper.sh |

## settings.json Full Schema (v3.0)

```json
{
  "permissions": {
    "deny": []
  },
  "hooks": {
    "SessionStart": [...],
    "PostToolUse": [...],
    "PreToolUse": [...]
  }
}
```

Note: Current settings.json metadata (agents, commands, prompts) will be REMOVED — they are not Claude Code native fields and have no effect.

## Migration Strategy

Phase 2 → Phase 5, each phase leaves TAD functional:
- Phase 2: Add hooks + rewrite settings.json (additive, no breaks)
- Phase 3: Slim skill files (move logic out, keep judgment in)
- Phase 4: Quality hooks + parallelization (enhancement)
- Phase 5: Integration test + sync to 8 projects + version bump

## Key Constraints

- TAD v3.0 must NOT use bypassPermissions mode (deny doesn't work in bypass)
- Hook event keys MUST be PascalCase
- additionalContext appears as `<system-reminder>` (system-level authority)
- permissions.deny only works at tool-name level (no path patterns)
- Per-skill hooks not available — all hooks in global settings.json
