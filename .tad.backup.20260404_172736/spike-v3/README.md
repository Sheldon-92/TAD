# TAD v3.0 Mechanism Validation Spike — Report

**Date**: 2026-03-31
**Claude Code Version**: 2.1.88
**Epic**: EPIC-20260331-tad-v3-hook-native-rebuild (Phase 0/5)
**Task ID**: TASK-20260331-001

---

## Executive Summary

7 experiments + 3 supplemental sub-experiments validated Claude Code's native mechanisms for the TAD v3.0 rebuild. **5 mechanisms confirmed working, 2 found non-functional, 1 partially functional**. The core architecture (hooks + skills + agents) is viable. **Major supplemental finding: `permissions.deny` provides hard tool-level restriction, and hooks cannot override it — establishing a clear enforcement priority order.**

---

## Mechanism Capability Matrix

| # | Mechanism | Status | Key Finding |
|---|-----------|--------|-------------|
| 1 | PostToolUse command hook | ✅ **PASS** | Full tool I/O in stdin, additionalContext as system-reminder |
| 2 | PreToolUse prompt hook (Haiku) | ✅ **PASS** | Intelligent gating works, $ARGUMENTS substitution confirmed |
| 3 | Skill frontmatter: allowed-tools | ❌ **FAIL** | NOT enforced in fork or inline mode |
| 3b | Skill: fork vs inline context | ✅ **PASS** | fork creates isolated agent, model override works |
| 4 | SessionStart hook | ✅ **PASS** | Startup context injection viable, zero latency |
| 5 | Parallel Agent spawning | ✅ **PASS** | True concurrent execution with model override per agent |
| 6 | Per-skill hooks in frontmatter | ❌ **FAIL** | Not implemented in v2.1.88 |
| 7 | Hook `if` condition filter | ✅ **PASS** | Glob-style argument filtering works |
| 3c | permissions.deny (supplemental) | ⚠️ **PARTIAL** | Blanket tool deny works; path patterns don't; hooks can't override |

### Supplemental: Experiment 3c — permissions.deny Deep Test

| Sub-Exp | Test | Result |
|---------|------|--------|
| 3c-1 | allowed-tools in bypass mode | Inconclusive (bypass overrides all) |
| 3c-2 | `permissions.deny: ["Write"]` (blanket) | ✅ Tool completely removed |
| 3c-2 | `permissions.deny: ["Write(*.ts)"]` (pattern) | ❌ Pattern not supported |
| 3c-3 | deny + hook override | ❌ Hook cannot override deny |

**Enforcement Priority Order (confirmed)**:
```
permissions.deny  →  hooks.PreToolUse  →  permissions.allow  →  user prompt
(highest: removes tool)   (runs on available tools)   (auto-approval)   (asks user)
```

---

## Detailed Findings

### Hook System (Experiments 1, 2, 4, 7)

**Verdict: Fully functional and production-ready**

| Feature | Works? | Details |
|---------|--------|---------|
| Event key format | PascalCase | `PostToolUse`, `PreToolUse`, `SessionStart` |
| Command hooks | ✅ | Shell script execution with stdin JSON |
| Prompt hooks | ✅ | Haiku/other model evaluates allow/deny |
| `matcher` field | ✅ | Tool name filtering (supports `\|` OR) |
| `if` field | ✅ | Glob-style argument filtering: `Bash(git *)` |
| `additionalContext` | ✅ | Injected as `<system-reminder>` to model |
| Side effects | ✅ | Hooks can write files, call APIs, etc. |
| stdin JSON fields | ✅ | session_id, cwd, permission_mode, tool_name, tool_input, tool_response, tool_use_id |
| DENY behavior | ✅ | Blocks tool execution, reason returned to model |

**Key insight**: `additionalContext` appears as `<system-reminder>` — this is **authoritative context injection** that the model treats as system-level information.

### Skill System (Experiments 3, 3b, 6)

**Verdict: Partially functional — invocation and model override work, tool restriction does not**

| Feature | Works? | Details |
|---------|--------|---------|
| Skill discovery | ✅ | Auto-discovered from `.claude/skills/{name}/SKILL.md` |
| Skill invocation | ✅ | Via Skill tool or `/skill-name` |
| `context: fork` | ✅ | Creates separate sub-agent execution |
| `context: inline` | ✅ | Injects prompt into current conversation |
| `model` override | ✅ | Works in fork mode (confirmed Haiku) |
| `allowed-tools` | ❌ | NOT enforced in either fork or inline mode |
| `hooks` in frontmatter | ❌ | Per-skill hooks not implemented |

**Key insight**: Tool restriction must be done via hooks (PreToolUse prompt hook), not via skill frontmatter.

### Agent System (Experiment 5)

**Verdict: Fully functional**

| Feature | Works? | Details |
|---------|--------|---------|
| Parallel spawning | ✅ | Multiple Agent calls in one message run concurrently |
| Model override | ✅ | Per-agent model selection (haiku/sonnet/opus) |
| Agent types | ✅ | Explore, general-purpose, Plan available |
| Result collection | ✅ | All results returned together |

---

## Discrepancies: Source Code vs Actual Behavior

| # | Source Code Says | Actual Behavior | Impact |
|---|-----------------|-----------------|--------|
| 1 | `allowed-tools` filters available tools | Tools NOT restricted | Must use hooks for tool gating |
| 2 | Skills can define hooks via frontmatter | Hooks in frontmatter ignored | Must use global hooks in settings.json |

---

## Hook Event Key Format

**Confirmed: PascalCase**

- `PostToolUse` ✅ (tested in Exp 1)
- `PreToolUse` ✅ (tested in Exp 2, 7)
- `SessionStart` ✅ (tested in Exp 4)

kebab-case was NOT tested (PascalCase worked on all attempts — no need for fallback).

---

## Impact on TAD v3.0 Architecture

### What Works (Build On This)
1. **Global hooks in settings.json** — Reliable, full-featured, production-ready
2. **Prompt hooks with Haiku** — Intelligent gating at near-zero cost
3. **additionalContext injection** — System-reminder-level context authority
4. **SessionStart for bootstrapping** — Zero-overhead startup context
5. **Hook `if` filtering** — Precise, argument-aware hook targeting
6. **Skill fork + model override** — Cost-effective sub-agents
7. **Parallel Agent execution** — True concurrency for expert reviews

### What Doesn't Work (Design Around This)
1. **allowed-tools** — Cannot restrict tools via frontmatter → Use PreToolUse prompt hooks instead
2. **Per-skill hooks** — Cannot register hooks per skill → Use global hooks with matcher/if patterns to distinguish contexts

### Architectural Implications
- TAD v3.0 should use **settings.json hooks as the primary enforcement layer** (not skill frontmatter)
- Agent persona constraints should remain **prompt-based** (skills as prompt injection)
- Tool restrictions should use **PreToolUse prompt hooks** (Haiku-gated)
- Quality gates can be implemented as **PostToolUse hooks** (file write side effects + additionalContext)
- Startup context should use **SessionStart hook** (project state injection)

---

## Recommendation

**Recommendation: PROCEED with TAD v3.0 — with adjusted architecture**

The core mechanisms are solid:
- ✅ Hook system is production-ready with rich features
- ✅ Skill system works for prompt injection and model override
- ✅ Agent parallelism works for concurrent expert reviews

Adjustments needed from original design:
1. Replace `allowed-tools` reliance → Two-layer approach: `permissions.deny` for blanket tool removal + PreToolUse prompt hooks for path-level gating (Exp 3c)
2. Replace per-skill hooks → Global hooks with contextual matcher/if patterns (Exp 7)
3. **New pattern discovered**: "Default Deny + Hook Allow" — use `permissions.deny` for hard tool removal, PreToolUse hooks for intelligent gating on remaining tools

**Phase 1 (Architecture Blueprint) can proceed with confidence.** The hook system is more capable than expected (full tool I/O in stdin, system-reminder-level context injection), compensating for the two non-functional features.

---

## Evidence Files

| Experiment | Result File |
|------------|-------------|
| Exp 1: PostToolUse command hook | `exp1-command-hook/result.md` |
| Exp 2: PreToolUse prompt hook | `exp2-prompt-hook/result.md` |
| Exp 3: Skill fork + allowedTools | `exp3-skill-frontmatter/result.md` |
| Exp 3b: Skill inline vs fork | `exp3b-skill-fork/result.md` |
| Exp 4: SessionStart hook | `exp4-session-hook/result.md` |
| Exp 5: Parallel agents | `exp5-parallel-agents/result.md` |
| Exp 6: Per-skill hooks | `exp6-skill-hooks/result.md` |
| Exp 7: Hook if condition | `exp7-hook-if-condition/result.md` |
| Exp 3c: permissions.deny deep | `exp3c-allowedtools-deep/result.md` |

## Cleanup Verification

- [x] settings.json reverted to original state (backup restored after each experiment)
- [x] `.claude/skills/spike-test/` removed
- [x] `.claude/skills/spike-inline/` removed
- [x] `.claude/skills/spike-hooks/` removed
- [x] `.tad/spike-v3/` retained as evidence
