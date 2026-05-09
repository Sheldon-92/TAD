# TAD v3.0 Context Footprint Measurement

**Date**: 2026-03-31
**Epic**: EPIC-20260331-tad-v3-hook-native-rebuild (Phase 4/5)
**Task ID**: TASK-20260331-004

---

## Method

Token estimation: 1 token ≈ 4 characters (rough standard).
"Before" values: v2.6.0 original files (from git history and handoff records).
"After" values: measured after Phase 2 (hooks), Phase 3 (skill reduction), Phase 4 (CLAUDE.md trim + PreToolUse hook).

Note: Skill files load on-demand via Skill tool (not at session start). CLAUDE.md + @imports load at session start.

---

## Session Start Context (always loaded)

| File | Before (chars) | Before (tokens) | After (chars) | After (tokens) | Reduction |
|------|---------------|-----------------|--------------|----------------|-----------|
| CLAUDE.md | 5,964 | ~1,491 | 2,628 | ~657 | **56%** |
| @imports (architecture.md only — others don't exist) | ~14,468 | ~3,617 | ~14,468 | ~3,617 | 0% |
| **Session Start Total** | **~20,432** | **~5,108** | **~17,096** | **~4,274** | **16%** |

Note: @import files are project-specific accumulated knowledge. Only architecture.md exists (others are zero-cost placeholders). Their size is independent of the v3.0 rebuild.

---

## On-Demand Context (loaded when agent activated)

| File | Before (chars) | Before (tokens) | After (chars) | After (tokens) | Reduction |
|------|---------------|-----------------|--------------|----------------|-----------|
| Alex SKILL.md | ~151,680 | ~37,920 | 25,264 | ~6,316 | **83%** |
| Blake SKILL.md | ~63,120 | ~15,780 | 11,046 | ~2,762 | **82%** |
| settings.json | 1,163 | ~291 | 1,261 | ~315 | -8% (grew, added hooks) |
| **On-Demand Total** | **~215,963** | **~53,991** | **~37,571** | **~9,393** | **83%** |

---

## External (zero context cost)

| File | Lines | Notes |
|------|-------|-------|
| .tad/hooks/lib/common.sh | 71 | Runs as shell script, not loaded into LLM context |
| .tad/hooks/startup-health.sh | 54 | Output injected as ~50 char additionalContext |
| .tad/hooks/post-write-sync.sh | 47 | Output injected as ~80 char additionalContext |
| **Hook Total** | **172** | Zero token cost (shell execution) |

---

## Combined Summary

| Metric | Before (v2.6) | After (v3.0) | Change |
|--------|--------------|-------------|--------|
| Session start tokens | ~5,108 | ~4,274 | -16% |
| Agent activation tokens (Alex) | ~39,411 | ~6,973 | -82% |
| Agent activation tokens (Blake) | ~16,071 | ~3,077 | -81% |
| Total potential context | ~59,127 | ~14,009 | **-76%** |
| Hook scripts (external) | 0 lines | 172 lines | New capability, zero context cost |

---

## Key Findings

1. **76% total context reduction** — from ~59K tokens to ~14K tokens
2. **Session start cost barely changed** — CLAUDE.md trimmed 56%, but @imports dominate (3,617 tokens). Net session start reduction is only 16%.
3. **Agent activation is where the big wins are** — Alex 82% reduction, Blake 82% reduction. This is the real payload.
4. **Hooks add capability at zero context cost** — 172 lines of shell scripts that fire automatically, never entering the LLM's context window.
5. **The v3.0 architecture works as designed**: hooks for automation, config YAML for definitions, skills for judgment only.

---

## Verdict

AC9 requires ≥ 50% reduction. **Measured: 76%** ✅

The architecture shift from "everything in prompt" to "hooks + config + judgment-only skills" delivers exactly the efficiency gains predicted in the blueprint.
