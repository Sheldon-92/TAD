# Experiment 3: Skill Frontmatter — fork + allowedTools + model Override — Result

**Date**: 2026-03-31
**Claude Code Version**: 2.1.88

## Test Setup
- Skill path: `.claude/skills/spike-test/SKILL.md`
- Frontmatter:
  - `allowed-tools: [Read, Glob, Grep]`
  - `model: claude-haiku-4-5-20251001`
  - `context: fork`
- Invoked via: `Skill tool` (equivalent to `/spike-test`)

## Results

### PASS Criteria Checklist
- [x] Skill invokable via `/spike-test` — ✅ PASS
- [ ] Write tool is NOT available (blocked by allowedTools in fork mode) — ❌ FAIL
- [x] Read, Glob, Grep ARE available — ✅ PASS
- [x] Model override takes effect (response pattern suggests Haiku, not Opus) — ✅ PASS

### Detailed Findings

**1. Skill Discovery & Invocation**: ✅ PASS
- Skill auto-discovered from `.claude/skills/spike-test/SKILL.md`
- Name derived from directory name: `spike-test`
- Invokable via Skill tool with `skill: "spike-test"`
- Also appeared in the available skills list in system-reminder

**2. allowed-tools Restriction**: ❌ FAIL — NOT ENFORCED
- Despite `allowed-tools: [Read, Glob, Grep]`, the forked agent had access to ALL tools
- Write tool succeeded — file was created at expected path
- The forked agent reported seeing 20+ tools including Bash, Write, Edit, WebFetch, etc.
- **Conclusion**: `allowed-tools` frontmatter does NOT restrict tool availability, even in `context: fork` mode

**3. Model Override**: ✅ PASS
- `model: claude-haiku-4-5-20251001` was applied
- The forked agent self-identified as "Claude Haiku 4.5"
- Response pattern consistent with Haiku (concise, structured)
- **Conclusion**: `model` frontmatter DOES override the active model in fork mode

**4. Context Fork**: ✅ PASS
- `context: fork` creates a separate execution context
- The skill ran independently and returned results
- The forked agent had its own system prompt context

## Discrepancy from Source Code Analysis

| Expected (from source) | Actual Behavior | Discrepancy? |
|------------------------|-----------------|--------------|
| `allowed-tools` restricts available tools in fork mode | Tools NOT restricted — all tools available | ⚠️ YES |
| `model` overrides active model | Model correctly overridden to Haiku | No |
| `context: fork` creates isolated context | Fork mode works, creates separate execution | No |

**Key Discrepancy**: Source code (`src/skills/loadSkillsDir.ts`) suggests `allowed-tools` should filter tools. In practice, the restriction is NOT enforced in Claude Code v2.1.88. This may be:
- A bug in current version
- A feature not yet fully implemented
- Only enforced at a different layer than expected

## Impact on TAD v3.0

- **Cannot rely on `allowed-tools` for security boundaries** — tool access must be controlled through other mechanisms (e.g., prompt hooks for gatekeeping)
- **`model` override IS reliable** — can use Haiku for lightweight sub-agents
- **`context: fork` IS reliable** — can create isolated agent contexts

## Verdict: PARTIAL PASS (3/4 criteria met)
- ✅ Skill invocation works
- ❌ allowed-tools NOT enforced
- ✅ Model override works
- ✅ Fork context works
