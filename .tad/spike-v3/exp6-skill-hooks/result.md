# Experiment 6: Per-Skill Hooks in Frontmatter — Result

**Date**: 2026-03-31
**Claude Code Version**: 2.1.88

## Test Setup
- Skill path: `.claude/skills/spike-hooks/SKILL.md`
- Frontmatter included `hooks` field with PostToolUse hook definition
- Hook type: command (echo JSON with additionalContext "SKILL HOOK FIRED")
- Matcher: Read
- Context: fork

## Results

### PASS Criteria Checklist
- [ ] Skill-defined PostToolUse hook executes when Read is called inside the skill — ❌ FAIL
- [ ] additionalContext from skill hook is visible — ❌ FAIL (hook never fired)
- N/A: Hook fires outside skill (couldn't test — hook didn't fire at all)

### Detailed Findings

**1. Per-Skill Hook Execution**: ❌ FAIL — NOT IMPLEMENTED
- The `hooks` field in skill frontmatter is parsed but NOT executed
- When Read tool was called inside the forked skill, no "SKILL HOOK FIRED" system-reminder appeared
- Only standard Claude Code system-reminders appeared (deferred tools, skill list)

**2. What DID Work**:
- The skill itself loaded and executed correctly (fork mode)
- Read tool worked normally inside the skill
- The skill was discoverable and invokable

**3. Likely Explanation**:
- The `hooks` frontmatter field may exist in source code for future use but is not yet wired up to the hook execution engine
- Alternatively, the YAML format for hooks in frontmatter may differ from what we tested
- Current hook system only supports hooks defined in `settings.json` (global level)

## Discrepancy from Source Code Analysis

| Expected (from source) | Actual Behavior | Discrepancy? |
|------------------------|-----------------|--------------|
| Skills can define per-skill hooks via frontmatter | Hooks in frontmatter NOT executed | ⚠️ YES |

## Impact on TAD v3.0

- **CRITICAL**: Cannot use per-skill hooks for agent-specific quality gates
- **Alternative**: Use global hooks in settings.json with matcher patterns to distinguish agent contexts
- **Alternative**: Use prompt-based constraints (current TAD approach) augmented with global hooks
- Per-skill hooks would have been ideal for "alex-analyze skill registers its own gate hooks" — this pattern is NOT possible in v2.1.88

## Verdict: ❌ FAIL — Per-skill hooks not implemented in current version
