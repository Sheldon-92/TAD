# Hooks Platform Mapping: Claude Code → Codex

> TAD v2.26.0 — Cross-Platform Unification Phase 2
> This document defines the hook conversion rules between Claude Code (.claude/settings.json)
> and Codex (.codex/hooks.json). Used by tad.sh when generating hooks.json for --platform codex.

## Codex hooks.json schema

Verified with codex-cli 0.146.0 on 2026-08-03. Codex requires a descriptive top-level
object whose lifecycle event map is nested under `hooks`:

```json
{
  "description": "TAD lifecycle hooks",
  "hooks": {
    "SessionStart": [],
    "PostToolUse": []
  }
}
```

The event names and matcher/command entries below remain the semantic mapping. A
legacy top-level `SessionStart` or `PostToolUse` key is rejected by current Codex
parsing and must not be regenerated.

## Event Mapping

| Claude Code Event | Codex Event | Notes |
|-------------------|-------------|-------|
| `SessionStart` | `SessionStart` | Identical. Codex matcher uses `startup\|resume\|compact` |
| `PreToolUse` | `PreToolUse` | Identical event name |
| `PostToolUse` | `PostToolUse` | Identical event name |

## Tool/Matcher Mapping

| Claude Code Matcher | Codex Matcher | Notes |
|---------------------|---------------|-------|
| `Write\|Edit` | `^apply_patch$` | Codex uses `apply_patch` for file modifications |
| `AskUserQuestion` | `^ask_user_question$` | Different tool names |
| `Skill` | N/A (no equivalent) | Codex skill invocation has no PreToolUse matcher |

## Hook Type Mapping

| Claude Code Type | Codex Type | Notes |
|------------------|------------|-------|
| `type: command` | `type: command` | Identical |
| `type: prompt` | **Not convertible** | Codex hooks do not support LLM inline judgment |

## Handler Conversion Table

| Source (settings.json) | Target (hooks.json) | Status |
|------------------------|---------------------|--------|
| SessionStart → `startup-health.sh` | SessionStart → `startup-health.sh` | Converted (timeout: 30; matcher includes compact) |
| SessionStart → `notebook-dormant-sync.sh` | SessionStart → `notebook-dormant-sync.sh` | Converted (timeout: 30) |
| PostToolUse Write\|Edit → `post-write-sync.sh` | PostToolUse ^apply_patch$ → `post-write-sync.sh` | Converted (timeout: 10) |
| PostToolUse AskUserQuestion → `askuser-capture.sh` | PostToolUse ^ask_user_question$ → `askuser-capture.sh` | Converted (timeout: 10) |
| PreToolUse Write\|Edit → type:prompt (LLM check) | **Omitted** | Codex does not support type:prompt |
| PreToolUse Skill → `pre-accept-check.sh` | **Omitted** | No equivalent Codex matcher for skill invocation. Manual mode: `bash .tad/hooks/pre-accept-check.sh 4` |
| PreToolUse Skill → `pre-gate-check.sh` | **Omitted** | Same as above. Manual mode: `bash .tad/hooks/pre-gate-check.sh 3` |

## Field Mapping

| Claude Code Field | Codex Field | Notes |
|-------------------|-------------|-------|
| `model` | N/A | Codex command hooks do not support model specification |
| `timeout` | `timeout` | Identical semantics (seconds) |
| `.source` | `HOOK_SOURCE` | Normalized by `hook-envelope.sh`; absent/unsupported Codex field stays empty |
| `.tool_name` | `HOOK_TOOL_NAME` | Top-level tool name, with conservative Codex aliases |
| `.tool_input.file_path` | `HOOK_FILE_PATH` | Normalized flat path for post-write consumers |
| `.tool_input.skill` / `.tool_input.args` | `HOOK_SKILL` / `HOOK_SKILL_ARGS` | Flat gate fields; question arrays remain local to askuser capture |
| `.session_id` / `.cwd` | `HOOK_SESSION_ID` / `HOOK_CWD` | Normalized flat context fields |

## Known Limitations

1. **type:prompt hooks**: The PreToolUse Write|Edit safety check uses `type: prompt` (LLM inline judgment) in Claude Code. This has no Codex equivalent. Codex users do not get automatic write-safety checking.

2. **Skill matcher**: Claude Code fires PreToolUse hooks when the Skill tool is invoked. Codex skill system ($skill-name) has no equivalent pre-invocation hook point. The `pre-accept-check.sh 4` and `pre-gate-check.sh 3` manual modes require an explicit argument and block on missing evidence.

3. **Timeout defaults**: Claude Code does not require explicit timeout on hooks. Codex hooks should specify timeout to avoid hanging the session. Default: 30s for SessionStart, 10s for PostToolUse.

4. **Codex envelope and compaction**: Spike C/D used an isolated CODEX_HOME and
   workspace-write scratch repository, but authentication stopped both real sessions
   before any hook event was delivered. `HOOK_SOURCE` is therefore empty for the
   measured Codex path, and no PreCompact consumer is wired. SessionStart's `compact`
   matcher is retained so a future delivered discriminator can be consumed; the
   current limitation is explicit and is not a docs-only verified claim.
   If Codex supplies no compact discriminator, the Layer-1 self-check in
   `AGENTS.md` Critical Rules is the only detection layer.
