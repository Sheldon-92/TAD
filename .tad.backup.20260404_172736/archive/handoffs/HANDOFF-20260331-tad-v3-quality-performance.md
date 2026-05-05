# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-03-31
**Project:** TAD Framework
**Task ID:** TASK-20260331-004
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260331-tad-v3-hook-native-rebuild.md (Phase 4/5)
**Linear:** N/A

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 |
|--------|------|
| Architecture Complete | ✅ |
| Components Specified | ✅ |
| Functions Verified | ✅ |
| Data Flow Mapped | N/A |

**Gate 2 结果**: ✅ PASS

---

## 📋 Handoff Checklist (Blake必读)

- [ ] Read complete handoff
- [ ] Read `.tad/spike-v3/ARCHITECTURE-v3.md` (blueprint)
- [ ] Read `.tad/project-knowledge/architecture.md` (last 3 entries)
- [ ] Understand: Phase 2 hooks + Phase 3 slimmed skills are the foundation

---

## 1. Task Overview

### 1.1 What We're Building
Three deliverables:
1. **CLAUDE.md simplification** — 155 → <80 lines (remove verbosity, hooks handle enforcement)
2. **PreToolUse prompt hook** — Haiku-based intelligent gating for context-aware decisions
3. **Context footprint measurement** — Before/after token comparison to quantify v3.0 improvement

### 1.2 Why
- CLAUDE.md is loaded on EVERY session (cost: ~1445 tokens per the earlier spike). Trimming it saves context on every turn.
- PreToolUse hook is the last missing enforcement mechanism from the architecture blueprint.
- Context measurement proves the value of the v3.0 rebuild quantitatively.

### 1.3 Intent

**不是要做的**:
- ❌ Not changing hooks from Phase 2 (only ADDING a new PreToolUse hook)
- ❌ Not modifying skill files from Phase 3
- ❌ Not bumping version to v3.0 yet (that's Phase 5)

---

## 2. Deliverable 1: CLAUDE.md Simplification (155 → <80 lines)

### What to trim

| Section | Current | Action | Target |
|---------|---------|--------|--------|
| §1 Handoff rules | 12 lines | 📐 SLIM | 6 lines (remove bullet list, keep one-liner rule) |
| §2 Usage scenarios | 24 lines | 📐 SLIM | 12 lines (keep table, trim notes) |
| §3 Quality Gates | 12 lines | 📐 SLIM | 6 lines (keep 6 rules as one-liners) |
| §4 Terminal isolation | 24 lines | 📐 SLIM | 10 lines (remove anti-rationalization block, keep rules) |
| §5 Plan Mode | 12 lines | ❌ REMOVE | 0 lines (enforcement can be a comment: "TAD agents must not use EnterPlanMode") |
| §6 Violation handling | 5 lines | 📐 SLIM | 2 lines |
| §7 Protocol locations | 9 lines | ✅ KEEP | 9 lines (useful reference) |
| §8 @imports | 15 lines | ✅ KEEP | 15 lines (must stay) |
| Header/dividers | ~42 lines | 📐 SLIM | ~20 lines |

### Key principle
CLAUDE.md is the **first thing loaded** into every session. Every line costs tokens on every turn. Now that hooks enforce rules and skills are slim, CLAUDE.md only needs to:
1. Declare when to use TAD (routing table)
2. State the critical rules (terminal isolation, Gate enforcement)
3. Point to @import knowledge files

### ⚠️ Section 5 (Plan Mode) removal rationale
The anti-rationalization text about Plan Mode is verbose (12 lines) and can be replaced with a single comment in the skill files themselves. The hook system + skill files already guide behavior.

---

## 3. Deliverable 2: PreToolUse Prompt Hook

### Purpose
Context-aware intelligent gating. Instead of blanket allow/deny, Haiku evaluates each Write/Edit call based on the current file path.

### settings.json addition (MERGE into existing hooks)

```json
"PreToolUse": [
  {
    "matcher": "Write|Edit",
    "hooks": [
      {
        "type": "prompt",
        "prompt": "A tool is about to modify a file. Here are the full details:\n\n$ARGUMENTS\n\nExtract the file path from the JSON above. Then apply these rules:\n- Files in .tad/ directory → ALLOW\n- Files in .claude/ directory → ALLOW\n- Markdown files (*.md) → ALLOW\n- YAML/JSON config files → ALLOW\n- Shell scripts (*.sh) → ALLOW\n- All other files → ALLOW (default permissive for framework project)\n\nRespond with JSON only: {\"ok\": true} or {\"ok\": false, \"reason\": \"...\"}",
        "model": "claude-haiku-4-5-20251001",
        "timeout": 10
      }
    ]
  }
]
```

### Design notes
- **Only $ARGUMENTS is validated** (Spike Exp 2). Do NOT use $TOOL_NAME or $FILE_PATH — these are not confirmed substitution variables.
- **No `if` filter**: `if` field syntax was validated for command hooks (Exp 7: `Bash(git *)`) but NOT for prompt hooks. Omit `if` to avoid silent failure. Path filtering is done inside the prompt itself.
- **Default permissive**: For a framework project like TAD, most writes should be allowed. The hook is a safety net, not a blocker.
- **Haiku model**: Fastest/cheapest model for quick yes/no decisions.
- **Timeout 10s**: If Haiku is slow, auto-allow (fail-open).
- **Latency trade-off**: Without `if` filter, hook fires on ALL Write/Edit. This adds ~2-5s per write (Haiku round trip). If too slow, consider adding `if` filter after verifying syntax, or make hook async.

### ⚠️ For downstream projects
When this TAD version is synced to other projects (e.g., menu-snap), the PreToolUse rules should be customized per project. For now, the rules are TAD-specific.

---

## 4. Deliverable 3: Context Footprint Measurement

### Method
1. Count tokens in CLAUDE.md (before and after)
2. Count tokens in Alex SKILL.md + Blake SKILL.md (before vs after)
3. Count tokens in settings.json hooks
4. Calculate net change

### Token estimation
Use rough formula: 1 token ≈ 4 characters.

### Before (v2.6):
```
CLAUDE.md:          155 lines × ~80 chars = ~12,400 chars ≈ 3,100 tokens
Alex SKILL.md:      2,528 lines × ~60 chars = ~151,680 chars ≈ 37,920 tokens
Blake SKILL.md:     1,052 lines × ~60 chars = ~63,120 chars ≈ 15,780 tokens
settings.json:      38 lines × ~40 chars = ~1,520 chars ≈ 380 tokens
Hooks:              0
─────────────────────────────────────────────
Total:              ~57,180 tokens (loaded on demand via Skill tool)
```

### After (v3.0):
```
CLAUDE.md:          ~80 lines × ~80 chars = ~6,400 chars ≈ 1,600 tokens
Alex SKILL.md:      570 lines × ~60 chars = ~34,200 chars ≈ 8,550 tokens
Blake SKILL.md:     283 lines × ~60 chars = ~16,980 chars ≈ 4,245 tokens
settings.json:      ~45 lines × ~40 chars = ~1,800 chars ≈ 450 tokens
Hooks (shell):      174 lines (NOT in context — runs externally)
─────────────────────────────────────────────
Total:              ~14,845 tokens
```

### Expected reduction: ~74% (57K → 15K tokens)

### Output
Create `.tad/spike-v3/CONTEXT-MEASUREMENT.md` with actual measured values.

---

## 5. Implementation Steps

### Phase 1: CLAUDE.md Simplification

1. Read current CLAUDE.md (155 lines)
2. Apply trimming per table in Section 2
3. Verify @import directives still present and unchanged
4. Count lines — target <80
5. Verify no critical rules lost (terminal isolation, Gate enforcement, handoff rule)

### Phase 2: PreToolUse Hook

1. Read current `.claude/settings.json`
2. Add `PreToolUse` section per Section 3 spec
3. Validate JSON: `cat .claude/settings.json | jq .`
4. Test: Write to a .tad/ file → should NOT trigger hook (no `src/*` match)
5. Note: Full testing of PreToolUse requires source files — log behavior for Phase 5 validation

### Phase 3: Context Measurement

1. Run `wc -c` on all relevant files (before values from git history, after from current)
2. Calculate token estimates
3. Write `.tad/spike-v3/CONTEXT-MEASUREMENT.md`

---

## 6. Files

### 6.1 Files to Modify
```
CLAUDE.md                       # 155 → <80 lines
.claude/settings.json           # Add PreToolUse hook section
```

### 6.2 Files to Create
```
.tad/spike-v3/CONTEXT-MEASUREMENT.md   # Token footprint comparison
```

---

## 7. Acceptance Criteria

- [ ] AC1: CLAUDE.md ≤ 80 lines
- [ ] AC2: All @import directives preserved unchanged
- [ ] AC3: Terminal isolation rule still present in CLAUDE.md
- [ ] AC4: Gate enforcement rule still present in CLAUDE.md
- [ ] AC5: Handoff reading rule still present in CLAUDE.md
- [ ] AC6: PreToolUse hook added to settings.json with valid JSON
- [ ] AC7: PreToolUse hook uses only `$ARGUMENTS` substitution (not $TOOL_NAME/$FILE_PATH)
- [ ] AC8: Context measurement document created with before/after numbers
- [ ] AC9: Measured context reduction ≥ 50% (conservative target)
- [ ] AC10: settings.json validates with `jq .`

---

## 8. Important Notes

- ⚠️ **@imports in CLAUDE.md are SACRED** — these load project knowledge. Never modify.
- ⚠️ **PreToolUse hook is default-permissive** — it's a safety net, not a gate. Fail-open on timeout.
- ⚠️ **Do NOT run *sync** — Phase 5 handles downstream distribution.
- ⚠️ **Verify CLAUDE.md still reads coherently** — it's loaded raw into every session.

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-03-31
**Version**: 3.1.0
