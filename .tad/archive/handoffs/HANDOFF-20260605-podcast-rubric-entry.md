---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: yes
gate4_delta: []
---

# Handoff Document for Agent B (Blake)

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-05
**Project:** TAD Framework
**Task ID:** TASK-20260605-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260605-nondev-experience-backport.md (Phase 2/3)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-06-05

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Single YAML entry addition |
| Components Specified | ✅ | Rubric dimensions + weights fully specified |
| Functions Verified | N/A | YAML edit only |
| Data Flow Mapped | N/A | YAML edit only |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

**Title:** Add ai-podcast-production rubric to deliverable-rubrics.yaml

**Summary:** Gate 3's Deliverable Branch already exists and works. Colin声音项目's 50% gate failure rate was caused by handoffs using task_type=code instead of task_type=deliverable, routing them through build/test/lint instead of the rubric-based judge path. This task adds a weighted rubric for ai-podcast-production based on the "85-to-95 Quality Delta" pattern from the pack.

**Priority:** P1

---

## 3. Requirements

### FR1: Add ai-podcast-production entry to deliverable-rubrics.yaml
Add a new entry under `packs:` with:
- A real rubric_ref pointing to a rubric file
- pass_threshold and partial_threshold
- verdict_shape: weighted
- status: active

### FR2: Create the rubric file
Create a rubric file at `.tad/capability-packs/ai-podcast-production/podcast-quality-rubric.md` with 5 weighted dimensions derived from the pack's "85-to-95 Quality Delta":
1. Original Text Quotation (weight 0.20)
2. Technique Analysis Depth (weight 0.20)
3. Personal Memory Specificity (weight 0.20)
4. Factual Precision (weight 0.20)
5. Non-Resolution Thesis (weight 0.20)

Each dimension scored 0.0–1.0 with anchor descriptions.

---

## 6. Implementation Steps

### Task 1: Create rubric file

**File:** `.tad/capability-packs/ai-podcast-production/podcast-quality-rubric.md`
**Action:** CREATE

```markdown
# Podcast Quality Rubric (ai-podcast-production)

> Weighted 5-dimension rubric derived from the "85-to-95 Point Gap" cross-cutting rule.
> Used by Gate 3 Deliverable Branch when task_type=deliverable and pack=ai-podcast-production.

## Scoring Guide

Each dimension scored 0.0–1.0:
- **1.0**: Exemplary — meets the "95-point" standard with concrete evidence
- **0.5**: Adequate — present but generic or lacking specificity
- **0.0**: Missing or fundamentally wrong

## Dimensions

| # | Dimension | Weight | 0.0 (Missing) | 0.5 (Adequate) | 1.0 (Exemplary) |
|---|-----------|--------|---------------|-----------------|------------------|
| 1 | Original Text Quotation | 0.20 | Paraphrases only, no direct quotes | Some quotes but without translator attribution | Direct quotes with translator name, page/chapter ref |
| 2 | Technique Analysis | 0.20 | Plot summary only | Identifies technique but doesn't explain WHY it works | Names technique + explains mechanism + compares to alternatives |
| 3 | Personal Memory Specificity | 0.20 | Generic reflection ("this moved me") | Personal anecdote but could apply to anyone | Specific sensory detail (time, place, smell, sound) unique to speaker |
| 4 | Factual Precision | 0.20 | Unchecked claims, dates/names wrong | Facts present but not adversarially verified | All claims Codex-reviewed, corrections documented |
| 5 | Non-Resolution Thesis | 0.20 | Picks a winner ("A is better than B") | Acknowledges tension but resolves it neatly | Holds contradictions in tension, refuses tidy resolution |

## Pass Criteria

- **PASS**: weighted_score >= 0.75
- **PARTIAL**: weighted_score >= 0.60
- **FAIL**: weighted_score < 0.60
```

### Task 2: Create the pack directory (if needed) and add rubric

Ensure `.tad/capability-packs/ai-podcast-production/` exists, then write the rubric file.

### Task 3: Add entry to deliverable-rubrics.yaml

**File:** `.tad/capability-packs/deliverable-rubrics.yaml`
**Action:** MODIFY — append new entry under `packs:`

Add after the `product-thinking:` block:

```yaml
  ai-podcast-production:
    rubric_ref: ".tad/capability-packs/ai-podcast-production/podcast-quality-rubric.md"
    pass_threshold: 0.75
    partial_threshold: 0.60
    verdict_shape: weighted
    dogfood_capable: no       # hardware (TTS compute on Colab)
    status: active
```

---

## 7. Files to Modify

| File | Action | Description |
|------|--------|-------------|
| .tad/capability-packs/ai-podcast-production/podcast-quality-rubric.md | CREATE | Weighted 5-dim rubric |
| .tad/capability-packs/deliverable-rubrics.yaml | MODIFY | Add ai-podcast-production entry |

---

## 9. Acceptance Criteria

- [ ] AC1: `.tad/capability-packs/ai-podcast-production/podcast-quality-rubric.md` exists and has 5 dimension rows
- [ ] AC2: `yq '.packs.ai-podcast-production.status' .tad/capability-packs/deliverable-rubrics.yaml` returns "active"
- [ ] AC3: `yq '.packs.ai-podcast-production.pass_threshold' .tad/capability-packs/deliverable-rubrics.yaml` returns 0.75
- [ ] AC4: `yq '.packs.ai-podcast-production.verdict_shape' .tad/capability-packs/deliverable-rubrics.yaml` returns "weighted"
- [ ] AC5: Rubric file has all 5 dimensions with 0.0/0.5/1.0 anchors

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训
✅ 无直接相关历史教训。

---

## Required Evidence Manifest

```yaml
evidence:
  expert_reviews: ".tad/evidence/reviews/blake/podcast-rubric-entry/"
  completion: ".tad/active/handoffs/COMPLETION-20260605-podcast-rubric-entry.md"
```
