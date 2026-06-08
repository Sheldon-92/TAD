---
# ⚠️ DEPRECATED (TAD v3.1, 2026-06-07) — DO NOT USE THIS TEMPLATE.
# Use the universal template `.tad/templates/handoff-a-to-b.md` for ALL task_types,
# including task_type: deliverable. Rubric/judge ACs are now written in the universal
# §9.1 Spec Compliance Checklist (Verification Method: "spawn independent judge per
# Rubric Evaluation Protocol → verdict: PASS"). The gate's `## Rubric Evaluation Protocol`
# section activates automatically. This deprecated file is kept only for historical reference.
#
# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)
# (historical) DELIVERABLE TRACK — pack-produced content artifact judged by a rubric.
# Rule of thumb: if the artifact IS the product → task_type: deliverable.
#                if the artifact informs a downstream build → task_type: research.
task_type: deliverable   # code | yaml | research | e2e | mixed | deliverable

# Deliverable routing keys (Phase 2 non-dev execution track, 2026-05-31):
# rubric_ref / pass_threshold source-of-truth PRECEDENCE (contract §A.2):
#   1. If set here in frontmatter → these values WIN (per-handoff override).
#   2. Else fall back to the .tad/capability-packs/deliverable-rubrics.yaml row keyed by `pack`.
#   3. If BOTH absent (no frontmatter value AND no registry row/null) → Gate 3 BLOCKS.
pack:                    # capability pack name — key into deliverable-rubrics.yaml (e.g. academic-research)
rubric_ref:              # path to rubric file (e.g. .claude/skills/academic-research/references/scholar-eval.md). Blank → fall back to registry.
pass_threshold:          # numeric 0-1 (e.g. 0.75). Blank → fall back to registry.
deliverable_paths: []    # list of artifact paths the producer must create (the Deliverables to Produce)

e2e_required: no      # yes | no - N/A for deliverable track (kept for schema compat)
research_required: no # yes | no - producer pipeline is Conductor-side (contract §B.6)

# Optional: production directories that must have ≥1 git-tracked file at Gate 3
git_tracked_dirs: []  # e.g., ["docs/reports"]

# Optional: Skip Alex Gate 4 Knowledge Assessment ceremony for trivial handoffs.
# Default no for deliverable (rubric-graded artifacts usually surface findings).
skip_knowledge_assessment: no  # yes | no

# Optional: Capture "Alex 提议 vs Gate 4 reality" gaps surfaced during *accept.
gate4_delta: []
---

# Deliverable Handoff Document for the Producer
## TAD v3.1 - Rubric-Graded Delivery (Non-Dev Execution Track)

**From:** Alex (Agent A - Solution Lead)
**To:** Producer (Conductor-spawned producer sub-agent or the Conductor — NOT Blake; see §6)
**Date:** [Current Date]
**Project:** [Project Name]
**Task ID:** TASK-[YYYYMMDD]-[###]
**Handoff Version:** 3.1.0
**Epic:** N/A <!-- Optional: EPIC-{YYYYMMDD}-{slug}.md (Phase {N}/{M}) -->
**Supersedes:** N/A <!-- Optional: HANDOFF-YYYYMMDD-{slug}.md -->

> ⚠️ **Producer ≠ Judge (contract §C).** The deliverable is produced by ONE agent
> (a Conductor-spawned producer sub-agent, or the Conductor itself). The rubric score
> is computed at Gate 3 by a SEPARATE, fresh judge sub-agent whose prompt references
> ONLY `{deliverable_paths} + {rubric_ref} + {pass_threshold}`. A producer scoring its
> own output = VIOLATION (self-enhancement bias ~10-15%).

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: [YYYY-MM-DD HH:MM]

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Brief Complete | ✅/⚠️/❌ | [交付物的目标和受众是否明确] |
| Rubric Resolvable | ✅/⚠️/❌ | [rubric_ref + pass_threshold 可解析（frontmatter 或 registry）] |
| Deliverable Paths Specified | ✅/⚠️/❌ | [deliverable_paths 列出了所有要产出的工件] |
| Acceptance Mapped | ✅/⚠️/❌ | [ACs 是关于工件本身的可验证条件] |

**Gate 2 结果**: ✅ PASS / ⚠️ PARTIAL PASS / ❌ FAIL

**如果 PARTIAL PASS 或 FAIL，说明**:
- [遗留问题1]
- [遗留问题2]

**Alex确认**: 我已验证交付物的 brief、rubric 和验收标准完整，producer 可以独立产出。

---

## 📋 Handoff Checklist (Producer 必读)

Producer 在开始产出前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（交付物 IS the product，不是 feeder）
- [ ] rubric_ref + pass_threshold 已解析（知道用什么标准评分）
- [ ] 每个 deliverable_path 的产出和质量要求都清楚
- [ ] 确认可以独立使用本文档完成产出

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始产出。

---

## 1. Task Overview

### 1.1 What We're Producing
[清晰、简洁地描述要产出的交付物：类型、范围、受众]

### 1.2 Why We're Producing It
**业务价值**：[...]
**受众受益**：[...]
**成功的样子**：[当交付物达到 rubric pass_threshold 且 meets-brief 时，就成功了]

### 1.3 🆕 Intent Statement（意图声明）

**真正要解决的问题**：[...]

**不是要做的（避免误解）**：
- ❌ 不是[常见误解1]
- ❌ 不是[常见误解2]

**Producer请确认理解**：
```
在开始产出前，请用你自己的话回答：
1. 这个交付物要解决什么问题？
2. 受众会如何使用它？
3. 成功的标准（rubric + 阈值）是什么？

只有Human确认理解正确后，才能开始产出。
```

---

## 📚 Project Knowledge（Producer 必读）

**⚠️ MANDATORY READ — 在开始产出前，必须执行以下 Read 操作：**
1. Read ALL `.tad/project-knowledge/*.md` files listed in 步骤 2 below
2. Read the "⚠️ 必须注意的历史教训" entries carefully
3. This is NOT optional — project knowledge prevents repeated mistakes

> **Why this matters**: In long sessions, project knowledge loaded at startup gets compressed.
> Reading it again here ensures full awareness before producing any artifact.

### 步骤 1：识别相关类别

本次任务涉及的领域（勾选所有适用项）：
- [ ] code-quality
- [ ] security
- [ ] ux
- [ ] architecture
- [ ] performance
- [ ] testing
- [ ] api-integration
- [ ] [其他类别]

### 步骤 2：历史经验摘录

**已读取的 project-knowledge 文件**：

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| [category].md | X 条 | [最重要的 1-2 点摘要] |
| [category].md | 0 条 | 无相关历史记录 |

**⚠️ 必须注意的历史教训**：

1. **[标题]** (来自 [category].md)
   - 问题：[...]
   - 解决方案：[...]

（如果无相关记录，写：✅ 已检查，无相关历史记录）

### Producer 确认

- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题

---

## 2. Background Context

### 2.1 Previous Work
[已有相关交付物或素材]

### 2.2 Current State
[现状 vs 目标]

### 2.3 Dependencies
[外部依赖：素材、来源、研究工具]

---

## 3. Requirements

### 3.1 Functional Requirements (about the artifact)
- FR1: [交付物必须包含/达到 ...，例如 "报告含 ≥12 条可验证引用"]
- FR2: [...]

### 3.2 Non-Functional Requirements
- NFR1: [篇幅、格式、风格等]
- NFR2: [...]

---

## 4. Deliverable Design

### 4.1 Structure / Outline
[交付物的结构、章节、镜头表或分轨等]

### 4.2 Quality Rubric (the grading contract)
> The rubric at `rubric_ref` (frontmatter or `deliverable-rubrics.yaml` row for `pack`)
> is the grading contract. The independent judge will score the artifact against THIS rubric.
> Producer should self-review against the rubric dimensions BEFORE submitting — but the
> producer's own score is NOT credited (judge scores independently, contract §C).

- **Rubric**: [rubric_ref path]
- **Pass threshold**: [pass_threshold] (PASS); partial_threshold default 0.60 (PARTIAL); below = FAIL
- **Dimensions** (from the rubric): [list the rubric's weighted dimensions]

### 4.3 Source / Evidence Requirements
[引用、来源、provenance 要求 — 例如 zero-hallucination, source quality tier]

---

## 5. Deliverables to Produce

> Replaces the code template's "Files to Create/Modify". List every artifact path
> the producer must create; these MUST match `deliverable_paths` in the frontmatter.

| # | Deliverable Path | Description | Format |
|---|------------------|-------------|--------|
| 1 | {path/to/artifact} | {what it is} | {md / mp3 / mp4 / pdf} |

### 5.1 Grounded Against (source files / briefs Alex actually read)
- _(brief / source path, head 50 lines, read at YYYY-MM-DD HH:MM)_
- _(or "(new — will be produced)")_

---

## 6. Production Pipeline (contract §B.6 — who produces, NOT Blake)

> **Blake's generic code "implement" lane does NOT apply to research/content deliverables.**
> Research tools (NotebookLM is stateful/sequential and Conductor-side; WebSearch) cannot
> run inside a Blake sub-agent. The producer is:

1. **Producer** = a Conductor-spawned PRODUCER sub-agent (or the Conductor itself) that holds
   the research/content tools. The producer writes the artifact(s) to `deliverable_paths`.
2. **Judge** = a SEPARATE fresh sub-agent spawned by the gate/Conductor at Gate 3. judge ≠ producer
   is defined relative to THIS producer (if the Conductor produced, the judge MUST be a distinct sub-agent).
3. Pipeline: producer → artifact at `deliverable_paths` → deliverable-completion report →
   Gate 3 spawns judge → `{date}-rubric-eval-{task}.md` → verdict → Gate 4 (business acceptance).

---

## 7. Acceptance Criteria

交付物被认为完成，当且仅当：
- [ ] 所有 `deliverable_paths` 工件已产出（present）
- [ ] 独立 judge 评分：rubric weighted score ≥ `pass_threshold`（verdict: PASS）
- [ ] Rubric-eval evidence 存在：`.tad/evidence/reviews/{date}-rubric-eval-{task}.md`
- [ ] 交付物 meets-brief（关于工件的 ACs 满足 — Alex judgment）
- [ ] Human 验证"这是我期望的"

---

## 7.1 Spec Compliance Checklist (for automated verification)

> **Pipe-escape note**: Markdown tables require `|` inside regex to be written `\|`.
> When extracting to run in bash, un-escape: `grep -cE 'a\|b\|c'` → `grep -cE 'a|b|c'`.

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| 1 | {artifact present at path} | pre-impl-verifiable / post-impl-verifiable | {file check, grep} | {what to find} | {Alex paste raw output OR "(post-impl)"} |

> This section is OPTIONAL but recommended for deliverables (makes "artifact present" + rubric-eval checks precise).

---

## 7.2 Expert Review Status (Alex 必填)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| {reviewer-name} | _(concise: severity + one-line symptom)_ | _(cite section / AC)_ | Resolved / Open / Deferred |

**Status legend:** Resolved / Open / Deferred (cite rationale in Notes).

### Experts Selected

1. **{reviewer-name}** — {why chosen for this deliverable's risk profile}

### Overall Assessment (post-integration)

- {reviewer-name}: {CONDITIONAL PASS / PASS / FAIL} ({N} P0 resolved, {N} P1 resolved)

---

## 8. Important Notes

### 8.1 Critical Warnings
- ⚠️ [警告1]

### 8.2 Known Constraints
- [约束1]

---

## 9. 🆕 Learning Content（可选）

### 9.1 Decision Rationale: [决策主题]

**选择的方案**：[...]

**💡 Human学习点**：
[提炼的通用原则]

---

**Handoff Created By**: Alex (Agent A)
**Date**: [Date]
**Version**: 3.1.0
