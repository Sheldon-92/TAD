# Experiment 1: PostToolUse Command Hook — Result

**Date**: 2026-03-31
**Claude Code Version**: 2.1.88
**Hook Event Key Format**: PascalCase (`PostToolUse`) ✅ Works

## Test Setup
- Hook script: `hook-script.sh` (reads stdin JSON, writes log, outputs additionalContext)
- Matcher: `Read` (only fires for Read tool)
- Configured in `.claude/settings.json` under `hooks.PostToolUse`

## Results

### PASS Criteria Checklist
- [x] hook-script.sh executes on Read tool call
- [x] tool-log.txt contains the logged entry
- [x] Model's response references or acknowledges the additionalContext
- [x] JSON stdin contains tool_name and tool_input fields

### Detailed Findings

**1. Hook Execution**: ✅ PASS
- Hook fired immediately after Read tool completed
- Shell script executed successfully via `bash` command

**2. Side Effect (File Write)**: ✅ PASS
- `tool-log.txt` created with entry: `[20260331_120216] Tool used: Read`
- Hook can write to arbitrary files on the filesystem

**3. additionalContext Injection**: ✅ PASS
- Output JSON with `hookSpecificOutput.additionalContext` field
- Model received it as a `<system-reminder>` tag:
  ```
  PostToolUse:Read hook additional context: Hook executed: logged Read to tool-log.txt
  ```
- Format: `{HookEventName}:{Matcher} hook additional context: {additionalContext value}`

**4. stdin JSON Structure**: ✅ PASS
- Rich JSON payload received via stdin. Fields available:
  | Field | Value | Useful for TAD? |
  |-------|-------|-----------------|
  | `session_id` | UUID | Session tracking |
  | `transcript_path` | Full path to .jsonl | Conversation log access |
  | `cwd` | Working directory | Context awareness |
  | `permission_mode` | `bypassPermissions` | Permission detection |
  | `hook_event_name` | `PostToolUse` | Event identification |
  | `tool_name` | `Read` | Tool filtering |
  | `tool_input` | `{file_path: "..."}` | What was requested |
  | `tool_response` | Full response object | What was returned |
  | `tool_use_id` | `toolu_...` | Correlation ID |

**5. Hook Event Key Format**: PascalCase confirmed working.
- Used `"PostToolUse"` as the key in settings.json → worked first try
- kebab-case NOT tested (PascalCase worked, no need to test fallback)

## Key Discoveries for TAD v3.0

1. **additionalContext becomes system-reminder**: The model sees it as a `<system-reminder>` tag, making it authoritative context injection
2. **Full tool I/O available**: Both `tool_input` and `tool_response` are in stdin — hooks can inspect what was read/written
3. **session_id + transcript_path**: Hooks can access the full conversation log for context
4. **permission_mode visible**: Hooks know whether the session is in bypass mode
5. **Matcher works for tool filtering**: `"Read"` correctly limited hook to Read tool only

## Verdict: ✅ ALL PASS
