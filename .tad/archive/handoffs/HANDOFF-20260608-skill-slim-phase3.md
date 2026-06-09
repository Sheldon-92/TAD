---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-08
**Project:** TAD Framework
**Task ID:** TASK-20260608-006
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260608-skill-progressive-loading.md (Phase 3/3)

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 同 Alex Phase 2 模式，Blake 无 references/ 从零创建 |
| Components Specified | ✅ | 5 个可提取部分已定位（行范围 + 行数） |
| Functions Verified | ✅ | Phase 1+2 已验证 22 次提取零丢失 |
| Data Flow Mapped | ✅ | body → stub + references/ |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

**目标**: 为 Blake SKILL.md 创建 references/ 目录，提取 5 个大协议，body 从 2113 行降到 ≤800 行。这是 SKILL Progressive Loading Epic 的最后一个 Phase。

**⚠️ 安全基线**: Blake body 安全关键词 = **114**，references = **0**，总计 **114**

---

## 2. Extraction List (从底到顶)

| # | Section | 行范围 | ~行数 | Reference 文件名 |
|---|---------|-------|------|-----------------|
| 1 | completion_protocol | ~1566-2113 | 547 | completion-protocol.md |
| 2 | domain_pack_trace_protocol + execution_checklist | ~1305-1565 | 261 | execution-checklist.md |
| 3 | notebooklm_access | ~1072-1130 | 58 | notebooklm-access.md |
| 4 | ralph_loop_execution_logic | ~356-1071 | 715 | ralph-loop.md |
| 5 | cross_model_invocation | ~297-355 | 58 | cross-model-invocation.md |

**总计**: ~1639 行提取 → body 2113 - 1639 + (5×4 stubs) = **~494 行**

---

## 3. Technical Design

### 3.1 操作方法

与 Alex Phase 2 完全一致：
1. `mkdir -p .claude/skills/blake/references/`
2. 从底到顶，用 grep 定位每个 section 起止行
3. 复制到 references/，加来源注释头
4. 原位替换为 4 行 reference stub
5. 完成后安全验证

### 3.2 load_when 触发条件

| Section | load_when |
|---------|----------|
| completion_protocol | "When Blake completes implementation and writes completion report" |
| execution_checklist | "When Blake starts executing a handoff task (after reading handoff)" |
| notebooklm_access | "When Blake needs to query or add sources to a NotebookLM notebook" |
| ralph_loop | "When Blake enters the Ralph Loop execution cycle for a task" |
| cross_model_invocation | "When cross-model CLI (Codex/Gemini) is needed for review or research" |

### 3.3 Body 保留内容

- YAML frontmatter
- 自动触发条件 (~40 行)
- Global Skill Exclusion (~15 行)
- Tool quick reference note (~5 行)
- Ralph Loop 概览（§62 的 ~95 行摘要 — 非完整执行逻辑）
- 4-Step Activation Protocol (~65 行)
- Commands 表 (~45 行)
- exit_protocol (~13 行)
- subagent_shortcuts (~10 行)
- my_tasks / my_gates / release_duties / templates / parallel_patterns (~160 行)
- mandatory_rules (~15 行)
- honest_partial_protocol (~24 行 — 小，保留)
- domain_pack_trace_protocol (~18 行 — 小，保留。注意：和 execution_checklist 相邻但独立)
- completion_knowledge_override (~55 行) — P1 fix: 小节，留 body
- next_md_rules (~28 行) — P1 fix: 小节，留 body
- forbidden actions / on_start / success_patterns / interaction rules / Quick Reference (~130 行)

### 3.4 特殊注意

**Ralph Loop 概览 vs 执行逻辑**：Blake SKILL 在行 62-155 有一段 Ralph Loop 概览（流程图、层级说明），这是每次激活都读的。行 356-1071 的 Ralph Loop Execution Logic 是详细的执行步骤，只在实际执行任务时需要。**概览留 body，执行逻辑提取。**

**domain_pack_trace_protocol (行 1547-1564)**：只有 18 行，与 execution_checklist (行 1305-1546) 相邻。提取 execution_checklist 时注意**不要把 domain_pack_trace_protocol 一起带走**——它留在 body。

---

## 5. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|--------------------|--------------------|
| AC1 | Body ≤800 行 | `wc -l < .claude/skills/blake/SKILL.md` | ≤800 |
| AC2 | 安全计数 ≥114 | `{ cat .claude/skills/blake/SKILL.md .claude/skills/blake/references/*.md; } \| grep -c 'MUST\|MANDATORY\|VIOLATION\|BLOCKING\|forbidden'` | ≥114 |
| AC3 | references/ 存在 | `ls .claude/skills/blake/references/*.md \| wc -l` | ≥5 |
| AC4 | honest_partial 在 body | `grep -c 'honest_partial' .claude/skills/blake/SKILL.md` | ≥1 |
| AC5 | Claude Code /blake 正常 | Gate 4 验证 | 激活成功 + *help |

---

## 6. Implementation Steps

1. `mkdir -p .claude/skills/blake/references/`
2. 提取 #1 completion_protocol (~547 行) → 安全检查
3. 提取 #2 execution_checklist (~261 行，**不含 domain_pack_trace_protocol**) → 安全检查
4. 提取 #3 notebooklm_access (~58 行)
5. 提取 #4 ralph_loop (~715 行)
6. 提取 #5 cross_model_invocation (~58 行)
7. 最终安全验证 + commit

**Grounded Against**:
- .claude/skills/blake/SKILL.md (grep 全文 section map, read at 2026-06-08)
- 安全基线: 114 (grep 计数, measured at 2026-06-08)

---

## 7. Files to Modify / Create

| File | Action |
|------|--------|
| `.claude/skills/blake/SKILL.md` | MODIFY — 5 个 section 替换为 stub |
| `.claude/skills/blake/references/` | CREATE — 目录 + 5 个 .md 文件 |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意
- Phase 1+2 已验证 22 次提取零丢失。**同一模式。**
- domain_pack_trace_protocol (18 行) 与 execution_checklist 相邻但**不提取**

---

## 9.2 Expert Review Status

| Expert | Focus | Result | Key Findings |
|--------|-------|--------|-------------|
| N/A — Phase 1+2 已验证模式 22 次 | — | — | Gate 3 spec-compliance |

---

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/skill-slim-phase3/spec-compliance.md
completion:
  - .tad/active/handoffs/COMPLETION-20260608-skill-slim-phase3.md
```
