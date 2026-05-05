# Experiment 7: Hook `if` Condition Filter — Result

**Date**: 2026-03-31
**Claude Code Version**: 2.1.88

## Test Setup
- Hook event: `PreToolUse` (PascalCase)
- Matcher: `Bash`
- Type: `command` (echo JSON with additionalContext)
- `if` field: `"Bash(git *)"`

## Results

### PASS Criteria Checklist
- [x] Hook fires for `git status` (additionalContext visible)
- [x] Hook does NOT fire for `ls`
- [x] `if` field correctly filters based on tool argument pattern

### Scenario Results

| Scenario | Command | Expected | Actual | Result |
|----------|---------|----------|--------|--------|
| A: git command | `git status --short` | Hook FIRES | Hook FIRED (system-reminder appeared) | ✅ PASS |
| B: non-git command | `ls .tad/spike-v3/` | Hook SILENT | No system-reminder | ✅ PASS |

### Detailed Findings

**1. `if` Field Syntax**: ✅ Works
- Format: `"Bash(git *)"` — `ToolName(glob pattern on arguments)`
- Glob `*` matches any arguments after `git`
- The pattern matches against the command string passed to Bash tool

**2. Selective Filtering**: ✅ Works
- Hook ONLY fires when the Bash command matches the `if` pattern
- Non-matching commands pass through without hook execution
- This enables precise, argument-aware hook targeting

**3. Combined with Matcher**: Works as expected
- `matcher: "Bash"` filters by tool name first
- `if: "Bash(git *)"` further filters by argument pattern
- Both conditions must be met for hook to fire

## Key Discoveries for TAD v3.0

1. **Fine-grained hook targeting**: `if` enables hooks that fire only for specific argument patterns (e.g., only `git push`, not all Bash commands)
2. **Glob syntax**: Uses glob-style pattern matching (not regex)
3. **Format**: `ToolName(argument_pattern)` — tool name + parenthesized glob
4. **Use case for TAD**: Could gate destructive operations like `git push --force` or `rm -rf` while allowing safe commands

## Verdict: ✅ ALL PASS
