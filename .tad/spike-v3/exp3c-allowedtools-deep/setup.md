# Experiment 3c: allowed-tools Deep Test

## Goal
Understand EXACTLY what `allowed-tools` does under different conditions, and test if `permissions.deny` can achieve tool restriction.

## Sub-Experiment 3c-1: allowed-tools in "default" permission mode

The original Exp 3 may have run in a permission mode that auto-approves everything.
Test: What happens if the skill's fork agent runs with "default" (ask) permission mode?

### Setup
Use the same spike-test skill from Exp 3 (`context: fork`, `allowed-tools: [Read, Glob, Grep]`).
BUT ensure the permission mode is "default" (not auto/bypass).

### Expected behavior if allowed-tools is an auto-approval list:
- Read/Glob/Grep → execute without permission prompt
- Write/Edit → trigger permission prompt (not auto-approved)
- If user denies → tool blocked
- If user approves → tool works

### What to document:
- Does Write trigger a permission prompt? (YES = allowed-tools IS working as auto-approval)
- Does Write execute without prompt? (YES = allowed-tools has no effect at all)

## Sub-Experiment 3c-2: permissions.deny in settings.json

Test if `permissions.deny` can hard-block tools.

### Setup
Add to `.claude/settings.json`:
```json
{
  "permissions": {
    "deny": [
      "Write(.tad/spike-v3/exp3c-deny-test.txt)"
    ]
  }
}
```

### Test:
1. Try to write to `.tad/spike-v3/exp3c-deny-test.txt` → should be DENIED
2. Try to write to `.tad/spike-v3/exp3c-allow-test.txt` → should be ALLOWED (different path)

### What to document:
- Does permissions.deny block the specific Write operation?
- Is the deny rule pattern-based (path matching)?
- What error/message does the model see?

## Sub-Experiment 3c-3: Combined — deny + hook override

Can a PreToolUse hook OVERRIDE a deny rule? (Hook has higher priority than settings per source code)

### Setup
1. Keep the deny rule from 3c-2
2. Add a PreToolUse hook that allows the denied path:
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Write",
      "hooks": [{
        "type": "command",
        "command": "echo '{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"allow\"}}'"
      }]
    }]
  }
}
```

### Test:
- Try to write to the denied path → does the hook override the deny?

### What to document:
- Priority order: hook vs settings deny rules
- Can hooks provide dynamic exceptions to static deny rules?

## Acceptance Criteria
- [ ] 3c-1: Document whether allowed-tools triggers permission prompts for non-listed tools
- [ ] 3c-2: Document whether permissions.deny blocks specific tool operations
- [ ] 3c-3: Document whether hooks can override deny rules
- [ ] Clean up: revert settings.json after each sub-experiment
