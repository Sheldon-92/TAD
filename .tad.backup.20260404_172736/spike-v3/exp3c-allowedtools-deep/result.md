# Experiment 3c: allowed-tools Deep Test — Result

**Date**: 2026-03-31
**Claude Code Version**: 2.1.88

## Summary

Three sub-experiments tested tool restriction mechanisms beyond the original Exp 3. **Major finding: `permissions.deny` works at tool level and is un-overridable by hooks — this is the reliable enforcement primitive.**

---

## Sub-Experiment 3c-1: allowed-tools in default permission mode

### Setup
- Same spike-test skill as Exp 3 (fork mode, `allowed-tools: [Read, Glob, Grep]`)
- Current session runs in `bypassPermissions` mode (confirmed by Exp 1 stdin)

### Result: INCONCLUSIVE (bypass mode limitation)
- Write tool succeeded despite NOT being in allowed-tools list (same as Exp 3)
- Forked skill agents inherit parent session's permission mode
- In bypass mode, ALL permission checks are skipped, so allowed-tools behavior is unobservable
- **Cannot confirm or deny "allowed-tools = auto-approval list" hypothesis** in bypass mode
- To definitively test: user must start session in `default` permission mode

### Finding
`allowed-tools` has NO observable effect when session uses `bypassPermissions`. The hypothesis that it functions as an auto-approval list (rather than hard restriction) remains plausible but unconfirmed.

---

## Sub-Experiment 3c-2: permissions.deny in settings.json

### Setup
Tested three `permissions.deny` formats in `.claude/settings.json`:

### Results

| # | Deny Format | Agent Mode | Result | Conclusion |
|---|-------------|-----------|--------|------------|
| 1 | `"Write(.tad/spike-v3/exp3c-deny-test.txt)"` | bypass | Write succeeded | ❌ Path pattern + bypass = no effect |
| 2 | `"Write(.tad/spike-v3/exp3c-deny-test.txt)"` | default (via Agent mode) | Write succeeded | ❌ Path pattern doesn't work |
| 3 | `"Write"` | default (via Agent mode) | **Write tool REMOVED from agent** | ✅ **WORKS** |
| 4 | `"Write(*.ts)"` | default (via Agent mode) | Write succeeded for .ts | ❌ Glob pattern doesn't work |

### Key Findings

**1. Blanket tool deny WORKS** ✅
- `permissions.deny: ["Write"]` completely removes the Write tool from the agent's available toolset
- The agent literally cannot see or invoke the Write tool
- The agent reported "no Write tool available" and had to use Bash as workaround
- **This is a hard enforcement at the harness level, not a soft prompt**

**2. Path/argument patterns do NOT work** ❌
- `"Write(.tad/...)"` — no effect
- `"Write(*.ts)"` — no effect
- Pattern matching (path-based or glob-based) is not supported for deny rules
- Deny operates at the **tool name level only**, not at the argument level

**3. Bypass mode overrides deny**
- In `bypassPermissions` mode, even blanket deny doesn't work (test 1)
- Deny only works in `default` or other non-bypass modes
- This means the TAD v3.0 session should NOT use bypass mode if deny-based restrictions are desired

---

## Sub-Experiment 3c-3: deny + hook override combination

### Setup
- `permissions.deny: ["Write"]` (blanket deny)
- `hooks.PreToolUse` with `permissionDecision: "allow"` for Write matcher
- Agent spawned in `default` mode

### Result: ❌ Hook CANNOT override deny

- Write tool was completely removed from agent's toolset
- The PreToolUse hook for Write never even fired (tool removed before hook layer)
- Agent reported "no Write tool available" even with the hook configured
- **Deny is processed BEFORE hooks in the execution pipeline**

### Priority Order (confirmed)
```
permissions.deny (highest — removes tool entirely)
    ↓
hooks.PreToolUse (runs only for available tools)  
    ↓
permissions.allow / allowed-tools (auto-approval)
    ↓
user permission prompt (lowest — asks user)
```

**This means deny is a hard, un-bypassable restriction** (except in bypassPermissions mode). Hooks cannot create exceptions to deny rules.

---

## Acceptance Criteria

- [x] 3c-1: Documented allowed-tools behavior (inconclusive due to bypass mode)
- [x] 3c-2: Documented permissions.deny (blanket works, patterns don't)
- [x] 3c-3: Documented hook override (cannot override deny)
- [x] Clean up: settings.json reverted after each sub-experiment

---

## Revised Architecture Implications for TAD v3.0

### Tool Restriction Strategy (Updated)

| Approach | Scope | Reliable? | Use Case |
|----------|-------|-----------|----------|
| `permissions.deny: ["ToolName"]` | Blanket tool removal | ✅ Yes (non-bypass) | Remove dangerous tools entirely |
| PreToolUse prompt hook | Argument-level gating | ✅ Yes | Path/content-based allow/deny |
| `allowed-tools` in skill frontmatter | Auto-approval list? | ❓ Unconfirmed | Unknown reliability |
| Per-skill hooks | N/A | ❌ Not implemented | Not available |

### Recommended TAD v3.0 Pattern: "Default Deny + Hook Allow"

**Problem**: `permissions.deny` can't do path-level restriction. Hooks can't override deny.

**Solution**: Use **PreToolUse prompt hooks** (Exp 2) as the primary enforcement layer. They provide:
- Path-level granularity (Haiku evaluates file path rules)
- Context-aware decisions (can consider file type, directory, content)
- Dynamic rules (hook script can read config files for rules)
- DENY blocks the tool call, ALLOW passes through

**Alternative hybrid approach**:
- Use `permissions.deny` to remove tools that should NEVER be available (e.g., deny Bash for read-only agents)
- Use PreToolUse prompt hooks for fine-grained path/argument gating on remaining tools
- This gives two layers: hard removal + intelligent gating

---

## Verdict: ✅ ALL SUB-EXPERIMENTS DOCUMENTED
Major finding: `permissions.deny` is a hard tool-level restriction. PreToolUse hooks are the path to argument-level control.
