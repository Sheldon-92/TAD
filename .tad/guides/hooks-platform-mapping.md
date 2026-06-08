# Hooks Platform Mapping: Claude Code → Codex

> TAD v2.26.0 — Cross-Platform Unification Phase 2
> This document defines the hook conversion rules between Claude Code (.claude/settings.json)
> and Codex (.codex/hooks.json). Used by tad.sh when generating hooks.json for --platform codex.

## Event Mapping

| Claude Code Event | Codex Event | Notes |
|-------------------|-------------|-------|
| `SessionStart` | `SessionStart` | Identical. Codex matcher adds `startup\|resume` |
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
| SessionStart → `startup-health.sh` | SessionStart → `startup-health.sh` | Converted (timeout: 30) |
| SessionStart → `notebook-dormant-sync.sh` | SessionStart → `notebook-dormant-sync.sh` | Converted (timeout: 30) |
| PostToolUse Write\|Edit → `post-write-sync.sh` | PostToolUse ^apply_patch$ → `post-write-sync.sh` | Converted (timeout: 10) |
| PostToolUse AskUserQuestion → `askuser-capture.sh` | PostToolUse ^ask_user_question$ → `askuser-capture.sh` | Converted (timeout: 10) |
| PreToolUse Write\|Edit → type:prompt (LLM check) | **Omitted** | Codex does not support type:prompt |
| PreToolUse Skill → `pre-accept-check.sh` | **Omitted** | No equivalent Codex matcher for skill invocation. Users must run `bash .tad/hooks/pre-accept-check.sh` manually before *accept |
| PreToolUse Skill → `pre-gate-check.sh` | **Omitted** | Same as above. Users must run `bash .tad/hooks/pre-gate-check.sh` manually before /gate |

## Field Mapping

| Claude Code Field | Codex Field | Notes |
|-------------------|-------------|-------|
| `model` | N/A | Codex command hooks do not support model specification |
| `timeout` | `timeout` | Identical semantics (seconds) |

## Known Limitations

1. **type:prompt hooks**: The PreToolUse Write|Edit safety check uses `type: prompt` (LLM inline judgment) in Claude Code. This has no Codex equivalent. Codex users do not get automatic write-safety checking.

2. **Skill matcher**: Claude Code fires PreToolUse hooks when the Skill tool is invoked. Codex skill system ($skill-name) has no equivalent pre-invocation hook point. The `pre-accept-check.sh` and `pre-gate-check.sh` scripts must be run manually.

3. **Timeout defaults**: Claude Code does not require explicit timeout on hooks. Codex hooks should specify timeout to avoid hanging the session. Default: 30s for SessionStart, 10s for PostToolUse.
