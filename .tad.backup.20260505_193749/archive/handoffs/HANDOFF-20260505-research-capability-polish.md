---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Research Capability Polish — Auto-activation + Session Continuity + Close the Loop

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-05
**Project:** TAD Framework
**Task ID:** TASK-20260505-001
**Epic:** TAD Depth-First Capability Building (Phase 1)

---

## 1. Task Overview

**One-sentence goal**: Make TAD's NotebookLM research pipeline reliably activate when users need deep research, persist across sessions, and connect findings to next actions.

**Problem observed this session (2026-05-05)**:
- User asked "帮我做研究" → agent used generic Agent + WebSearch (wrong)
- User corrected → agent used /deep-research skill (still wrong)
- User corrected AGAIN → agent finally used *research-notebook (correct)
- Root cause: research routing rules only exist inside Alex SKILL.md (loads only after `/alex`). The global `/deep-research` skill wins the routing race in non-Alex sessions.

---

## 2. Background & Research Evidence

From Knowledge Activation paper (arxiv 2603.14805):
- "Where retrieval returns content for reading, activation delivers guidance for acting"

From this session's architectural analysis:
- CLAUDE.md is a routing table ("什么时候做什么"), not execution logic
- Global `deep-research` skill has a broad `description` field that matches research intents
- Without suppression at CLAUDE.md level, it will always win over NotebookLM

---

## 3. Requirements

### R1: Auto-activation (suppress competing skill + add routing row)
- Suppress global `/deep-research` skill at CLAUDE.md level (always-loaded)
- Add routing row pointing deep research to `*research-notebook`
- Keep WebSearch available for quick lookups (not banned)

### R2: Session continuity (REGISTRY awareness in routing)
- Routing mentions checking REGISTRY.yaml for existing notebooks
- Execution details stay in SKILL.md (not in CLAUDE.md)

### R3: Close the loop (research → action bridge)
- After research findings saved, offer next-step options
- In Alex mode: AskUserQuestion with 5 options
- In standalone mode: soft text suggestion (non-blocking)

### R4: Fix SKILL.md contradiction
- Remove "Alex-domain only" declaration that conflicts with standalone usage
- Add "Standalone Usage" section for non-Alex research routing

---

## 4. Technical Design (v2 — post expert review, 3 P0 resolved)

### 4.1 CLAUDE.md changes (~6 lines, routing-table style)

**Design principle** (per backend-architect P0-1): CLAUDE.md only does dispatch (WHEN → WHERE). Execution logic (HOW) stays in SKILL.md.

**Addition A**: New row in §2 使用场景 table (insert before "跳过 TAD" line):

```
| 深度研究 | 需要持久积累的研究任务（研究/research/调研/landscape/对比/深入）→ 读 `.claude/skills/research-notebook/SKILL.md` 按步骤执行。快速查询（语法/API/单一事实）仍用 WebSearch |
```

**Addition B**: After the table, after "跳过 TAD" line, add a 2-line exclusion note:

```
深度研究排除：遇到研究型任务时，不要 invoke `/deep-research` skill 或 spawn generic Agent 做 web search。原因：NotebookLM 是持久知识库（反复查询），一次性搜索结果会丢失。
```

**Signal words** (per P0-3 fix — removed "帮我看看" which causes false positives):
研究, research, 调研, landscape, 对比, 深入

**NOT included** (per P0-3): 帮我看看 (too broad — triggers on code review requests), 了解 (borderline — triggers on API lookup questions)

### 4.2 research-notebook SKILL.md changes

**Change A**: Replace line 15-16 "Alex-domain only" declaration (per P0-2 fix)

Current:
```
**This skill is Alex-domain only** — research happens in design/discuss phase, not implementation.
```

Replace with:
```
**Primary use: Alex design/discuss phase.** Also usable standalone (without /alex) via CLAUDE.md §2 research routing — see "Standalone Usage" below.
```

**Change B**: Add "Standalone Usage" section after Overview, before Preflight Check:

```markdown
## Standalone Usage (without /alex)

When invoked via CLAUDE.md research routing (without /alex active):
- Run preflight check (same as below)
- Use the same CLI commands (create / ask / source add-research)
- Skip Alex-specific protocols (Socratic, handoff, Gate, domain_pack_awareness)
- After research completes → soft suggestion of next steps (see below)
- When /alex IS active, Alex's own research protocols (research_notebook_awareness, research_plan_protocol) take precedence

### After Research Completes (Standalone)

Inform user: "研究完成。Findings saved to {path}."
Then suggest (non-blocking text, NOT AskUserQuestion):
"接下来你可以：用 /alex *analyze 进入设计 / 添加到 NEXT.md / 继续深入研究 / 保存到 project-knowledge。"
```

**Change C**: step6 "Research → Action Bridge" (in Alex SKILL.md `research_plan_protocol`, after step5)

NOTE: This goes in `.claude/skills/alex/SKILL.md` under `research_plan_protocol`, NOT in research-notebook SKILL.md (per P1-2 fix — step5 lives in Alex's protocol).

```yaml
    step6:
      name: "Research → Action Bridge"
      trigger: "After step5 completes (OBJECTIVES updated)"
      action: |
        AskUserQuestion:
        question: "研究完成，发现已保存。基于这些发现，下一步是什么？"
        Options:
          - "这些发现需要实现 — 进入 *analyze 设计" → transition to adaptive_complexity_protocol
          - "添加到 NEXT.md 作为待办" → append summary to NEXT.md In Progress
          - "继续研究 — 还需要更多信息" → return to step4 (another ask round)
          - "保存到 project-knowledge" → write to .tad/project-knowledge/ appropriate category
          - "只保存，不做行动" → standby
      enters_standby: "After user picks option 5"
      note: "OBJECTIVES.md update already done in step5 — not offered as option here"
```

### 4.3 Priority/precedence rules

When /alex IS active:
- Alex's `research_notebook_awareness` and `research_plan_protocol` take full precedence
- CLAUDE.md §2 routing row is subsumed (Alex has richer multi-step protocol)

When /alex is NOT active:
- CLAUDE.md §2 routing row + exclusion note govern behavior
- Agent reads research-notebook SKILL.md for execution steps
- Standalone mode applies (soft suggestions, no AskUserQuestion)

---

## 5. Files to Modify

| # | File | Action | Lines affected |
|---|------|--------|----------------|
| 1 | `CLAUDE.md` | Add routing row to §2 table + exclusion note after table | +3 lines (1 table row + 2 line note) |
| 2 | `.claude/skills/research-notebook/SKILL.md` | Replace "Alex-domain only" + add "Standalone Usage" section | ~+12 lines net |
| 3 | `.claude/skills/alex/SKILL.md` | Add step6 to research_plan_protocol (after step5) | +12 lines |

---

## 6. Acceptance Criteria

| AC# | Criterion | Verification |
|-----|-----------|-------------|
| AC1 | CLAUDE.md §2 table contains deep research routing row | `grep -c "深度研究" CLAUDE.md` = 1 |
| AC2 | CLAUDE.md contains exclusion note suppressing /deep-research | `grep -c "deep-research" CLAUDE.md` ≥ 1 |
| AC3 | Signal words do NOT include "帮我看看" or "了解" | `grep "帮我看看" CLAUDE.md` returns empty |
| AC4 | research-notebook SKILL.md no longer says "Alex-domain only" | `grep -c "Alex-domain only" .claude/skills/research-notebook/SKILL.md` = 0 |
| AC5 | research-notebook SKILL.md has "Standalone Usage" section | `grep -c "Standalone Usage" .claude/skills/research-notebook/SKILL.md` ≥ 1 |
| AC6 | Alex SKILL.md has step6 "Action Bridge" in research_plan_protocol | `grep -c "Action Bridge" .claude/skills/alex/SKILL.md` ≥ 1 |
| AC7 | step6 offers 5 options | Content check in alex/SKILL.md step6 |
| AC8 | Standalone mode uses soft text suggestion, NOT AskUserQuestion | research-notebook SKILL.md "Standalone" section says "non-blocking text" |
| AC9 | CLAUDE.md total addition is ≤6 lines | Count new lines manually |
| AC10 | Precedence rule documented: /alex active → Alex protocols take over | "Standalone Usage" section mentions precedence |

---

## 7. Important Notes

- **No hooks, no settings.json** — prompt-level routing only (per architecture.md "Mechanical Enforcement Rejected")
- **No WebSearch ban** — quick queries still use WebSearch. Routing only affects "deep research" tasks.
- **CLAUDE.md stays minimal** — ~6 lines added to a ~83 line file. Token cost: ~100-150 tokens/session.
- **Real-project validation (R4 from NEXT.md)** — NOT part of implementation. User tests after deployment.
- **step6 placement** — belongs in Alex SKILL.md (research_plan_protocol), NOT research-notebook SKILL.md. The research-notebook SKILL has standalone soft suggestions instead.

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Mechanical Enforcement Rejected (2026-04-15)** — architecture.md: 单用户 CLI 环境下，机械强制（hook 拦截）成本 > 收益。这次改动用 prompt-level routing（CLAUDE.md 文字），不用 hook。方向一致。
- **CLAUDE.md 路由架构 (v2.2)** — CLAUDE.md 是路由层（什么时候做什么），执行协议在各 SKILL.md。不要在 CLAUDE.md 里写执行逻辑。

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-05

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 3 files, routing-table pattern preserved |
| Components Specified | ✅ | §4 gives exact text for each change |
| Functions Verified | ✅ | No new functions — text config only |
| Data Flow Mapped | ✅ | CLAUDE.md dispatches → SKILL.md executes |

**Gate 2 结果**: ✅ PASS

---

## 9. Expert Review Status

| Reviewer | Verdict | P0 Found | P0 Resolved |
|----------|---------|----------|-------------|
| code-reviewer | CONDITIONAL PASS | 3 | 3 ✅ |
| backend-architect | CONDITIONAL PASS | 3 | 3 ✅ |

### P0 Resolution Summary

| P0# | Issue | Source | Resolution |
|-----|-------|--------|------------|
| P0-1 (BA) | Layering violation — CLAUDE.md embeds execution logic | backend-architect | §4.1 redesigned: routing-table row + exclusion note only (~6 lines). Execution stays in SKILL.md |
| P0-2 (both) | SKILL.md "Alex-domain only" contradicts "Standalone Usage" | both reviewers | §4.2 Change A: replaced with "Primary use: Alex. Also usable standalone." |
| P0-3 (both) | "帮我看看" signal word causes false positives on code review requests | both reviewers | §4.1: removed from signal word list. Also removed "了解" (borderline per P1-3) |

### P1 Integrated

| P1# | Issue | Resolution |
|-----|-------|------------|
| P1-1 (CR) | Conflict when both CLAUDE.md routing and Alex protocols active | §4.3 precedence rules: /alex active → Alex takes over |
| P1-2 (CR) | step6 placement ambiguous (Alex SKILL vs research-notebook SKILL) | §4.2 Change C explicitly placed in Alex SKILL.md research_plan_protocol |
| P1-3 (CR) | "了解" borderline broad | Removed from signal words |
| P1-4 (CR) | Inline CLI path in CLAUDE.md wastes tokens | Removed — SKILL.md handles paths |
| P1-3 (BA) | step6 needs "继续研究" loop-back option | Added as option 3 |

### P2 Noted (not blocking)
- P2-4 (CR): Added "保存到 project-knowledge" as option 4 in step6
- P2-1 (CR): R4 validation → add to NEXT.md after deployment (already tracked)
