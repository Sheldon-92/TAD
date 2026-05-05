# Experiment 2: PreToolUse Prompt Hook (Haiku Gating) — Result

**Date**: 2026-03-31
**Claude Code Version**: 2.1.88
**Hook Event Key Format**: PascalCase (`PreToolUse`) ✅ Works

## Test Setup
- Hook type: `prompt` (Haiku model evaluates allow/deny)
- Matcher: `Write|Edit` (fires for both Write and Edit tools)
- Model: `claude-haiku-4-5-20251001`
- Timeout: 15 seconds
- Rules: Allow spike dir + .md files, Deny .ts/.py source files

## Results

### PASS Criteria Checklist
- [x] Haiku correctly allows writes to spike directory
- [x] Haiku correctly denies writes to .ts files
- [x] Deny reason is shown to the model/user
- [x] Response time < 15 seconds

### Scenario Results

| Scenario | Action | Expected | Actual | Result |
|----------|--------|----------|--------|--------|
| A: Write to spike dir (.md) | Write test-allow.md | ALLOW | ALLOWED | ✅ PASS |
| B: Write .ts source file | Write test-deny.ts | DENY | DENIED | ✅ PASS |
| C: Edit existing .md file | Edit test-allow.md | ALLOW | ALLOWED | ✅ PASS |

### Detailed Findings

**1. Prompt Hook Execution**: ✅ PASS
- Hook fires before Write/Edit tool executes
- Haiku evaluates the prompt and returns JSON decision
- `$ARGUMENTS` substitution works — Haiku received the tool arguments

**2. DENY Behavior**: ✅ PASS
- Error message format: `PreToolUse:Write hook error: Prompt hook condition was not met: {reason}`
- The deny reason from Haiku's response is included in the error
- The Write/Edit operation is BLOCKED — file is NOT created
- Error is visible to the model as a tool error response

**3. ALLOW Behavior**: ✅ PASS
- When Haiku returns `{"ok": true}`, the tool proceeds normally
- No visible system-reminder for allowed operations (silent pass-through)
- Both Write and Edit tools work correctly when allowed

**4. Matcher Pipe Syntax**: ✅ Works
- `"Write|Edit"` correctly matches BOTH Write and Edit tools
- Pipe `|` acts as OR operator in matcher

**5. `$ARGUMENTS` Substitution**: ✅ Confirmed Working
- Haiku received actual tool arguments (not literal `$ARGUMENTS`)
- Haiku made context-aware decisions based on file path and type

## Key Discoveries for TAD v3.0

1. **Prompt hooks = intelligent gates**: Haiku can make nuanced allow/deny decisions based on file type, path, and content rules
2. **Cost-effective**: Uses Haiku (cheap, fast) for gatekeeping decisions
3. **Error message propagation**: Deny reasons flow back to the model, enabling self-correction
4. **Silent allow**: Allowed operations have no overhead visible to the model
5. **Pipe matcher**: Multiple tools can share one hook definition
6. **$ARGUMENTS works**: Full argument substitution in prompt text confirmed

## Verdict: ✅ ALL PASS
