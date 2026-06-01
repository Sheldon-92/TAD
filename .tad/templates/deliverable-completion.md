---
# gate3_verdict: filled by the CONDUCTOR (the Gate 3 judge-orchestrator for the deliverable
#   lane) as a Gate 3 POST-STEP (value ∈ pass|fail|partial). NOT Blake — Blake is excluded from
#   the deliverable lane (blake task_type_branching.deliverable). After the judge verdict is
#   computed, the Conductor Edits this to the judge verdict lowercased.
# ⚠️ Do NOT fill at creation — the verdict does not exist until /gate 3 (deliverable) runs.
# Empty / placeholder / any other value → post-write-sync.sh skips emission (FR2b timing).
# See gate SKILL "Gate 3 — Deliverable Branch" Gate3_Verdict_Marker (mirrors blake step4b, Conductor-performed).
gate3_verdict:
---

# Deliverable Completion Report

**From:** Producer (Conductor-spawned producer sub-agent / Conductor — NOT Blake)
**To:** Alex & Human
**Date:** [YYYY-MM-DD]
**Project:** [Project Name]
**Task ID:** TASK-[YYYYMMDD]-[###]
**Handoff ID:** [对应的 deliverable handoff 文件名]

> ⚠️ This is the DELIVERABLE-track completion report. Gate 3 acceptance = an independent
> judge's rubric weighted score ≥ pass_threshold (NOT build/test/lint). The Rubric Scores
> table below is populated FROM the judge's `{date}-rubric-eval-{task}.md` — the producer
> does NOT score its own output (contract §C).

---

## 🔴 Gate 3 v2: Deliverable Quality (Producer/Conductor 填写)

**执行时间**: [YYYY-MM-DD HH:MM]

### Rubric Scores (from the independent judge)

> Source: `.tad/evidence/reviews/{date}-rubric-eval-{task}.md`. One row per rubric dimension.
> `weighted_score = Σ(score_i × weight_i)`. Verdict per contract §B.5:
> ≥ pass_threshold → PASS; ≥ partial_threshold (default 0.60) → PARTIAL; else FAIL.

| # | Dimension | Weight | Score (0-1) | Notes |
|---|-----------|--------|-------------|-------|
| 1 | [dimension] | [w1] | [s1] | [...] |
| 2 | [dimension] | [w2] | [s2] | [...] |

- **Weighted score**: Σ(score × weight) = [value] (show the arithmetic)
- **Pass threshold**: [pass_threshold] · **Partial threshold**: [partial_threshold or 0.60]
- **Verdict**: ✅ PASS / ⚠️ PARTIAL / ❌ FAIL

<!-- Machine-readable verdict (own line, lowercase key, uppercase value, NO bold/emoji) — mirrors
     the rubric-eval file's token. Replace with exactly ONE of the three forms below. -->
verdict: PASS

### Judge (independent)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Judge (independent) | ✅/⚠️/❌ | rubric-eval evidence: {date}-rubric-eval-{task}.md — Judge: independent sub-agent; producer identity not provided |

### Top strengths / weaknesses (from the judge, actionable)

> ⚠️ FORMAT CONSTRAINT (contract §B.4): weaknesses MUST NOT use the `^#+ *P[0-9]-` heading
> form (e.g. NOT `### P0-1`, `## P1-2`). The post-write-sync.sh expert_review_finding parser
> counts heading-form `P<n>-` labels; a P-label heading here would self-trigger false P0/P1
> telemetry. Use plain prose ("Strength 1: …", "Weakness 1: …") or a severity table cell only.

**Strengths**
- Strength 1: [...]
- Strength 2: [...]
- Strength 3: [...]

**Weaknesses**
- Weakness 1: [...]
- Weakness 2: [...]
- Weakness 3: [...]

### Evidence

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Rubric-eval Evidence | ✅/⚠️/❌ | [.tad/evidence/reviews/{date}-rubric-eval-{task}.md 存在] |
| Acceptance Verification | ✅/⚠️/❌ | [关于工件的 AC 验证通过] |

### Knowledge Assessment

| 检查项 | 状态 | 说明 |
|--------|------|------|
| ⚠️ New Discoveries Documented | ✅/❌ | [Yes/No + 类别 — 留空 = Gate 无效] |

### Git

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Changes Committed | ✅/❌ | [Commit hash — 工件路径必须出现在 git] |

**Gate 3 v2 结果**: ✅ PASS / ⚠️ PARTIAL PASS / ❌ FAIL

**如果 PARTIAL PASS 或 FAIL，说明**:
- [未完成项1 — producer 修订后由 fresh judge 重新评分]

---

## 📦 Artifacts Produced

> Every path here MUST match `deliverable_paths` in the handoff frontmatter.

| # | Deliverable Path | Present? | Format | Note |
|---|------------------|----------|--------|------|
| 1 | {path/to/artifact} | ✅/❌ | {md/mp3/mp4} | [...] |

---

## 📋 实施总结

### 完成的工作
- [完成项1]
- [完成项2]

### 产出的交付物
```
path/to/artifact1  # [用途说明]
path/to/artifact2  # [用途说明]
```

---

## 📖 Knowledge Assessment (MANDATORY — Gate 3 BLOCKING)

**是否有新发现？** ✅ Yes / ❌ No

**如果 Yes：**
- **类别**: [architecture / code-quality / security / testing / performance / ux / api-integration / mobile-platform / frontend-design / other]
- **标题**: [简短描述]
- **内容摘要**: [1-2 句话]
- **已写入**: .tad/project-knowledge/{category}.md ✅/❌

**如果 No：**
- **原因**: [常规产出无特殊发现 / 已有类似记录 / etc.]

⚠️ 此节留空 = Gate 3 无效 = VIOLATION

---

## 📂 Evidence Checklist (MANDATORY)

### Rubric-Eval Evidence
- [ ] Judge rubric-eval: .tad/evidence/reviews/{date}-rubric-eval-{task}.md (verdict: PASS)

### Acceptance Verification Evidence
- [ ] Report: .tad/evidence/acceptance-tests/{task_id}/acceptance-verification-report.md (如适用)

### Git Commit
- **Commit Hash**: [hash]
- **Verified**: `git log --oneline -1` output matches ✅/❌

⚠️ Required evidence 未勾选 = Gate 3 不可通过

---

## 🎯 验收检查清单

确认以下所有项：
- [ ] 所有 `deliverable_paths` 工件已产出
- [ ] Gate 3 v2 通过（独立 judge rubric 评分 ≥ pass_threshold）
- [ ] Rubric-eval evidence 存在（verdict PASS）
- [ ] Knowledge Assessment 已完成（非空）
- [ ] 无已知阻塞问题

**声明**: 此交付物已完成并可交付用户验收。

---

## 📝 Human 验收区

**验收时间**: [YYYY-MM-DD HH:MM]

**验收结果**: ✅ 通过 / ⚠️ 需调整 / ❌ 不通过

**验收意见**:
- [意见1]

**后续行动**:
- [ ] [行动1]

---

**Report Created By**: Producer (Conductor-side)
**Date**: [Date]
**Version**: 2.0
