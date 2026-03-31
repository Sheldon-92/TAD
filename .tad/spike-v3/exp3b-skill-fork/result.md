# Experiment 3b: Skill Frontmatter — inline vs fork comparison — Result

**Date**: 2026-03-31
**Claude Code Version**: 2.1.88

## Test Setup
- Skill path: `.claude/skills/spike-inline/SKILL.md`
- Frontmatter:
  - `allowed-tools: [Read]`
  - `context: inline`
- Invoked via: `Skill tool` (equivalent to `/spike-inline`)

## Results

### PASS Criteria Checklist
- [x] Documented whether `allowed-tools` restricts tools in `inline` mode — YES, documented: NOT restricted
- [x] Clear comparison: fork mode behavior vs inline mode behavior — YES, comparison table below

### Detailed Findings

**1. Inline Mode Behavior**: 
- Skill prompt injected directly into current conversation (no sub-agent)
- All tools available — Write tool succeeded despite `allowed-tools: [Read]`
- No model override possible in inline mode (inherits parent model)

**2. Comparison: Fork vs Inline**

| Attribute | `context: fork` (Exp 3) | `context: inline` (Exp 3b) |
|-----------|------------------------|---------------------------|
| Execution | Separate sub-agent | Injected into current conversation |
| allowed-tools | ❌ NOT enforced | ❌ NOT enforced |
| model override | ✅ Works (Haiku confirmed) | N/A (inherits parent model) |
| Tool isolation | None | None |
| Context isolation | Partial (separate prompt) | None (shares conversation) |

**3. Key Finding**: `allowed-tools` is NOT enforced in EITHER mode in Claude Code v2.1.88.

## Discrepancy from Source Code Analysis

The source code (`src/skills/loadSkillsDir.ts`) parses `allowed-tools` from frontmatter, but the enforcement layer appears to not actually filter available tools at runtime. This is consistent across both context modes.

## Impact on TAD v3.0

- `allowed-tools` CANNOT be relied upon for tool restrictions
- Alternative approach: Use PreToolUse prompt hooks (Exp 2) for intelligent tool gating
- `context: fork` is still valuable for model override + isolated execution context

## Verdict: ✅ PASS (documentation goal met — both outcomes documented)
