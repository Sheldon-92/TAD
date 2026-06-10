---
task_type: research
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
**Date:** 2026-06-09
**Project:** TAD Framework
**Task ID:** TASK-20260609-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260609-skill-body-reference-boundary.md (Phase 1/3)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-09 (pending expert review)

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Audit scope fully defined: 36 refs (Alex 31 + Blake 5) |
| Components Specified | ✅ | Single output artifact: classification table |
| Functions Verified | ✅ | No code functions involved — this is a read-only analysis task |
| Data Flow Mapped | ✅ | Input: reference files + SKILL stubs → Output: classification table |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building

A systematic audit of all 36 reference files across Alex (31) and Blake (5) SKILL protocols, classifying each as "must body" or "reference OK" based on a single criterion.

### 1.2 Why We're Building It

**业务价值**：修复 Codex（以及可能的 Claude Code compact 场景）上的质量链断裂——Blake 跳过 Layer 2 专家审查、Gate 3 checklist、completion report 格式，导致实现质量无保障。

**用户受益**：TAD 在任何平台上执行时，核心质量流程不再被静默跳过。

**成功的样子**：每个 reference 文件都有明确分类和理由，人类可以直接基于这份审计表决定 Phase 2 的 inline 范围。

### 1.3 Intent Statement

**真正要解决的问题**：判断 36 个 reference 文件中哪些包含"执行纪律"——即 agent 不主动读就会不知不觉违反流程的内容。

**不是要做的（避免误解）**：
- ❌ 不是重新设计 progressive loading 架构
- ❌ 不是修改任何 SKILL.md 或 reference 文件（Phase 1 是纯读分析）
- ❌ 不是评估 reference 的内容质量（只判断 body vs reference 归属）

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个功能解决什么问题？
2. 判断标准是什么？
3. 输出物是什么格式？

只有Human确认你的理解正确后，才能开始实现。
```

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

本次任务涉及的领域：
- [x] architecture - SKILL 文件架构决策

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| principles.md | 2 条 | Judgment-Only Skill Files + Coverage Gate Floor |
| patterns/handoff-design.md | 2 条 | SKILL Progressive Loading + Platform Capability Decay |

**⚠️ Blake 必须注意的历史教训**：

1. **Judgment-Only Skill Files: Constraint Rules Are NOT Mechanical** (principles.md)
   - 问题：v2.7 slim 移除了 constraint rules 导致质量链系统性失效
   - 教训：MUST/MANDATORY/VIOLATION 规则永远不能从 SKILL body 中移除。本次审计要特别关注 reference 中包含这类关键词的内容

2. **SKILL Progressive Loading: Activation Works But Deep Protocol References Don't Auto-Load on Codex** (patterns/handoff-design.md)
   - 问题：Codex dogfood 中 Blake 跳过了 Layer 2、Gate 3 checklist、completion report
   - 教训：`load_when` stub 在 Codex 上不可靠。这是本 Epic 的直接触发原因

3. **A Coverage Gate's Global-Count Floor Cannot Detect Must-Cover SAFETY Loss** (principles.md)
   - 教训：Phase 2 验证时不能用全局关键词计数——必须逐类别检查。本次审计为 Phase 2 的逐类别验证提供基础数据

---

## 2. 判断标准（核心）

**The Two-Part Criterion:**

> **Test 1 (Omission)**: "如果 agent 不主动去读这个 reference，会不会在不知不觉中**跳过**一个强制步骤？"
> **Test 2 (Mis-execution)**: "如果 agent 不主动去读这个 reference，会不会**执行了**某个步骤但**缺少关键约束/防护**？"
>
> - 任一 test 回答"会" → 分类为 **must-body**（Phase 2 将 inline 回 SKILL body）
> - 两个 test 都回答"不会" → 分类为 **reference-ok**（保持现状）
>
> Test 2 的典型例子：express-path-protocol 中的 `NOT_via_alex_suggestion` 约束——agent 不会跳过 intent routing，但会在没有这个约束的情况下不当推荐 *express。handoff-creation-protocol 中的 AC Conflict Matrix Self-Check——agent 不会跳过写 handoff，但会写出有 AC 矛盾的 handoff。

### 2.1 "Must Body" 的典型特征

- 内容是**每次执行都需要遵守**的规则（如 Gate 3 checklist、Layer 2 要求）
- 没有显式触发点——不通过 `*command` 或 intent router 进入
- 包含 MUST/MANDATORY/VIOLATION 等约束关键词，且这些约束不仅在触发时有效，而是**持续有效**
- Agent 不知道自己在跳过什么（没有"我应该读 X"的提示）

### 2.2 "Reference OK" 的典型特征

- 通过 `*command`（如 `*bug`、`*discuss`）或 intent router 显式进入
- SKILL body 中有 `load_when` stub 明确提示"进入此模式时读 X"
- Agent 知道自己在做什么（"我要执行 *bug，让我读 bug-path-protocol"）
- 即使不读，也只是不知道怎么做某个可选操作，而不是违反强制规则

### 2.3 灰色地带处理

有些 reference 可能混合了两类内容（部分是执行纪律，部分是触发协议）。对于这种情况：
- 在分类表中标记为 **partial-body**
- 使用结构化字段说明哪些 section 是 must-body，哪些是 reference-ok（见 §4.2 输出格式）
- Phase 2 将拆分处理（inline 纪律部分，保留触发部分）
- **partial-body 应是例外（预计 0-5 个），不是常态**——多数 reference 应能明确分为 must-body 或 reference-ok

⚠️ **已知例外**: completion-protocol.md、execution-checklist.md、ralph-loop.md 这 3 个 Blake reference **必须分类为 must-body**（不得为 partial-body）。Codex dogfood 证据表明它们被整体跳过，不是部分使用。

---

## 3. 审计范围

### 3.1 Alex References (31 files)

路径：`.claude/skills/alex/references/`

| # | File | Classification | Notes |
|---|------|---------------|-------|
| 1 | accept-command.md | TBD | Blake: form independent judgment |
| 2 | acceptance-protocol.md | TBD | |
| 3 | adaptive-complexity-protocol.md | TBD | ⚠️ MANDATORY in body stub — check if truly triggered |
| 4 | bug-path-protocol.md | TBD | |
| 5 | cancel-protocol.md | TBD | |
| 6 | design-protocol.md | TBD | |
| 7 | discuss-path-protocol.md | TBD | |
| 8 | dream-protocol.md | TBD | |
| 9 | evolve-protocol.md | TBD | |
| 10 | experiment-path-protocol.md | TBD | |
| 11 | express-path-protocol.md | TBD | Contains NOT_via_alex_suggestion constraint |
| 12 | handoff-creation-protocol.md | TBD | 850 lines — contains AC Conflict Matrix |
| 13 | idea-list-protocol.md | TBD | |
| 14 | idea-path-protocol.md | TBD | |
| 15 | idea-promote-protocol.md | TBD | |
| 16 | intent-router-protocol.md | TBD | Core routing logic |
| 17 | learn-path-protocol.md | TBD | |
| 18 | optimize-protocol.md | TBD | |
| 19 | publish-protocol.md | TBD | |
| 20 | research-decision-protocol.md | TBD | Cognitive firewall |
| 21 | research-plan-protocol.md | TBD | |
| 22 | research-review-protocol.md | TBD | |
| 23 | skillify-command-protocol.md | TBD | |
| 24 | socratic-inquiry-protocol.md | TBD | ⚠️ MANDATORY in body stub — check if truly triggered |
| 25 | status-panoramic-protocol.md | TBD | |
| 26 | sync-add-protocol.md | TBD | |
| 27 | sync-list-protocol.md | TBD | |
| 28 | sync-protocol.md | TBD | |
| 29 | update-roadmap-protocol.md | TBD | |
| 30 | workflow-completion-trigger.md | TBD | |
| 31 | yolo-execution-protocol.md | TBD | |

**⚠️ 注意**: 预分类已全部移除以避免锚定偏见。Blake 必须对每个 reference 独立判断。

### 3.2 Blake References (5 files)

路径：`.claude/skills/blake/references/`

| # | File | Classification | Notes |
|---|------|---------------|-------|
| 1 | completion-protocol.md | **must-body (locked)** | Codex dogfood evidence: Blake skipped completion report |
| 2 | cross-model-invocation.md | TBD | |
| 3 | execution-checklist.md | **must-body (locked)** | Codex dogfood evidence: Blake skipped Gate 3 checklist |
| 4 | notebooklm-access.md | TBD | |
| 5 | ralph-loop.md | **must-body (locked)** | Codex dogfood evidence: Blake skipped Layer 2 |

**⚠️ "locked" 表示有 Codex dogfood 硬证据，不可降级为 partial-body 或 reference-ok。**

---

## 4. 审计方法

### 4.1 Per-Reference Audit Steps

For each reference file:

1. **Read the full reference content** — understand what rules/protocols it contains
2. **Read the corresponding stub in SKILL.md** — check the `load_when` description
3. **Apply the criterion**: "If agent doesn't read this, will it unknowingly violate process?"
4. **Check for MUST/MANDATORY/VIOLATION keywords** — these are red flags for must-body content
5. **Check if content is triggered** — is there a `*command` or intent router path that leads here?
6. **Write classification** with rationale (2-3 sentences per file)

### 4.2 Output Format

Create `.tad/evidence/designs/skill-body-reference-audit.md` with this structure:

```markdown
# SKILL Body vs Reference Audit — Phase 1 Classification Table

**Auditor:** Blake
**Date:** 2026-06-09
**Epic:** EPIC-20260609-skill-body-reference-boundary (Phase 1/3)
**Criterion:** "If agent doesn't proactively read this, will it unknowingly violate process?"

## Summary
- Total references audited: 36
- Must-body: {N}
- Reference-ok: {M}
- Partial-body: {P} (if any)

## Alex References (31)

### {filename}
- **Classification:** must-body / reference-ok / partial-body
- **Line count:** {N lines}
- **Trigger mechanism:** {*command / intent router / none (always needed)}
- **load_when assessment:** always_needed / truly_conditional / unclear
- **Contains MUST/MANDATORY/VIOLATION:** yes/no ({count})
- **Contains forbidden_implementations:** yes/no
- **Rationale:** {2-3 sentences explaining the judgment — apply BOTH Test 1 (omission) and Test 2 (mis-execution)}
- **Key content summary:** {1 sentence — what this reference contains}

If partial-body:
- **Must-body sections:** {list specific section headers that must be inlined}
- **Reference-ok sections:** {list specific section headers that can stay}

[repeat for all 31]

## Blake References (5)

[same format]

## Cross-Reference: Known Failures
| Reference | Codex Dogfood Evidence | Classification |
|-----------|----------------------|----------------|
| completion-protocol.md | Blake skipped completion report | must-body |
| execution-checklist.md | Blake skipped Gate 3 checklist | must-body |
| ralph-loop.md | Blake skipped Layer 2 expert review | must-body |

## Size Impact Projection
- Total must-body lines: {N} (Alex: {A}, Blake: {B})
- Current body: Alex {1485}, Blake {737}
- Projected after Phase 2 inline: Alex {1485 + A}, Blake {737 + B}

## Machine-Parseable Summary (for Phase 2 automation)
```yaml
must_body:
  alex: []  # list of filenames
  blake: []
reference_ok:
  alex: []
  blake: []
partial_body: []  # [{file: name, must_body_sections: [...], reference_ok_sections: [...]}]
```

---

## 5. Files to Read (Input)

| File | Purpose |
|------|---------|
| `.claude/skills/alex/SKILL.md` | Alex body — check all `reference:` and `load_when:` stubs |
| `.claude/skills/blake/SKILL.md` | Blake body — check all `reference:` and `load_when:` stubs |
| `.claude/skills/alex/references/*.md` (31 files) | Full content of each Alex reference |
| `.claude/skills/blake/references/*.md` (5 files) | Full content of each Blake reference |

## 6. Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `.tad/evidence/designs/skill-body-reference-audit.md` | CREATE | Classification table — the Phase 1 deliverable |

---

## 7. Required Evidence Manifest

```yaml
evidence_manifest:
  expert_reviews:
    - .tad/evidence/reviews/phase1-audit-review-{expert}.md
  gate_verdicts:
    - Gate 3 Layer 1 checklist (in completion report)
  completion:
    - .tad/active/handoffs/COMPLETION-20260609-skill-body-reference-audit.md
  blake_reviews: []
  perf_evidence: []
  fixture_results: []
  dogfood: []
  knowledge_updates:
    - .tad/project-knowledge/ (if audit reveals new patterns)
```

---

## 8. Important Notes

### 8.1 This is READ-ONLY

Phase 1 does NOT modify any SKILL files or references. The only output is the classification table. If Blake discovers issues during the audit (e.g., a reference has outdated content), note them in the audit artifact but do NOT fix them.

Before writing the deliverable, Blake must record the pre-existing dirty worktree state in the completion report. This repository already has unrelated pending changes, so scope verification must use task-scoped paths rather than whole-repo `git diff --stat`.

### 8.2 Don't Over-Simplify the Rationale

Each classification needs a real 2-3 sentence rationale. "Triggered by *command so reference-ok" is acceptable for clearly triggered protocols. But for borderline cases (e.g., handoff-creation-protocol.md which is triggered by *handoff but contains must-follow expert review rules), the rationale must explain WHY the trigger mechanism is sufficient.

### 8.3 Blake's Own Perspective

Blake should especially pay attention to Blake references — Blake knows firsthand which rules are needed during execution. The Codex dogfood evidence (Layer 2 / Gate 3 / completion report skipped) is the strongest signal for "must-body."

### 8.4 Sub-Agent Usage

This task does not require sub-agents. It's a systematic read-and-classify task that Blake executes directly.

### 8.5 Agent Assignment Clarification

Blake executes this audit (standard TAD: Alex designs, Blake implements). The Socratic discussion established that "Alex audits, human confirms must-body list" — this means Alex provided the methodology and judgment criteria (this handoff), Blake produces the artifact. Blake's perspective is especially valuable for Blake references (Blake knows firsthand which rules are needed during execution). For Alex references, Blake should apply the two-part criterion objectively without deference to any pre-existing assumptions about what "should" be reference-ok.

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|--------------------|--------------------|
| AC1 | All 36 references individually assessed | `grep -c '^### ' .tad/evidence/designs/skill-body-reference-audit.md` | ≥ 36 (one heading per file) |
| AC2 | Each assessment has classification + rationale | `grep -c 'Classification:' .tad/evidence/designs/skill-body-reference-audit.md` | = 36 |
| AC3 | Known-broken refs classified as must-body | `grep -A5 'completion-protocol\|execution-checklist\|ralph-loop' .tad/evidence/designs/skill-body-reference-audit.md \| grep -c 'must-body'` | = 3 |
| AC4 | MUST/MANDATORY/VIOLATION keyword counts recorded | `grep -c 'Contains MUST/MANDATORY/VIOLATION:' .tad/evidence/designs/skill-body-reference-audit.md` | = 36 |
| AC5 | Summary section with total counts | `grep -c 'Must-body:\|Reference-ok:\|Partial-body:' .tad/evidence/designs/skill-body-reference-audit.md` | ≥ 2 |
| AC6 | No SKILL files or reference files modified | `git diff --name-only .claude/skills/` | empty (no changes) |
| AC7 | Change scope as planned despite dirty worktree | `git status --short -- .tad/evidence/designs/skill-body-reference-audit.md .claude/skills/alex .claude/skills/blake` | only `.tad/evidence/designs/skill-body-reference-audit.md` is new/modified; no `.claude/skills/` changes |
| AC8 | Audit covers every file on disk | `diff <(grep '^### ' .tad/evidence/designs/skill-body-reference-audit.md \| sed 's/### //' \| sort) <(find .claude/skills/alex/references .claude/skills/blake/references -maxdepth 1 -type f -name '*.md' -exec basename {} \\; \| sort)` | empty (no diff) |
| AC9 | Borderline refs have substantive rationale | Manual: verify adaptive-complexity, socratic-inquiry, express-path, handoff-creation, intent-router, research-decision, workflow-completion each have >= 2 sentences in Rationale | Human review at Gate 4 |
| AC10 | Size impact projection populated | `grep -c 'Total must-body lines:' .tad/evidence/designs/skill-body-reference-audit.md` | = 1 |
| AC11 | YAML summary block populated | `grep -c 'must_body:' .tad/evidence/designs/skill-body-reference-audit.md` | >= 1 |

**AC Dry-Run Log** (Alex step1d at 2026-06-09, updated after expert review):
- AC1: ✅ post-impl-verifiable, syntax-validated (`grep -c` parses OK)
- AC2: ✅ post-impl-verifiable, syntax-validated
- AC3: ✅ post-impl-verifiable, syntax-validated (`grep -A5 | grep -c` pipeline parses OK — widened from -A1 per CR-P0-1)
- AC4: ✅ post-impl-verifiable, syntax-validated
- AC5: ✅ post-impl-verifiable, syntax-validated
- AC6: ✅ pre-impl-verifiable, raw cmd: `git diff --name-only .claude/skills/`, output: empty (no changes) — matched expected
- AC7: ✅ post-impl-verifiable, scoped to task paths to avoid pre-existing dirty worktree noise
- AC8: ✅ post-impl-verifiable, syntax-validated (`diff <(grep | sed | sort) <(find ... -exec basename | sort)` parses OK — avoids `ls` multi-directory headings)
- AC9: ✅ post-impl-verifiable, manual check at Gate 4 (rationale quality — added per CR-P1-1)
- AC10: ✅ post-impl-verifiable, syntax-validated
- AC11: ✅ post-impl-verifiable, syntax-validated

### 9.2 Expert Review Status

| Expert | Focus | Status | Findings |
|--------|-------|--------|----------|
| code-reviewer | AC verifiability, methodology, output format | ✅ Complete | 2 P0 (AC3 grep fragility, known-broken partial-body gap), 4 P1, 4 P2. CONDITIONAL PASS |
| backend-architect | Criterion completeness, bias, architecture | ✅ Complete | 2 P0 (criterion gap: mis-execution class, agent assignment contradiction), 4 P1, 4 P2. CONDITIONAL PASS |

### 9.3 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| CR | P0-1: AC3 grep -A1 fragile to blank lines | §9.1 AC3: widened to `-A5` | Resolved |
| CR | P0-2: Known-broken refs must be must-body, not partial-body | §2.3: added locked constraint + §3.2 table | Resolved |
| Arch | P0-1: Criterion misses "unknowing mis-execution" class | §2: expanded to two-part test (omission + mis-execution) | Resolved |
| Arch | P0-2: Epic says Alex audits, handoff says Blake | §8.5 added (see below) + Epic Notes corrected | Resolved |
| CR | P1-1: No AC for rationale quality | §9.1 AC9 added (manual check at Gate 4) | Resolved |
| CR | P1-2: Output format missing partial-body structured fields | §4.2: added Must-body/Reference-ok sections fields | Resolved |
| CR | P1-3: No completeness AC | §9.1 AC8 added (diff against disk) | Resolved |
| Arch | P1-1: Pre-classification anchoring bias | §3.1 + §3.2: all pre-classifications removed | Resolved |
| Arch | P1-2: Missing line count data | §4.2: added line_count field + Size Impact Projection section | Resolved |
| Arch | P1-3: load_when accuracy not captured | §4.2: added load_when_assessment field | Resolved |
| Arch | P1-4: AC3 grep brittle (same as CR P0-1) | §9.1 AC3: widened to `-A5` | Resolved |
| Arch | P2-1: Machine-parseable YAML summary | §4.2: added YAML summary block template | Resolved |
| Arch | P2-2: Audit forbidden_implementations blocks | §4.2: added contains forbidden_implementations field | Resolved |

---

## 10. Decision Summary

| # | Decision | Options Considered | Choice | Rationale |
|---|----------|--------------------|--------|-----------|
| D1 | Classification model | Binary / Ternary / Severity-based | Binary + partial-body escape | User chose to abandon delayed loading; binary is clearest |
| D2 | Audit scope | Selective (Blake-only) / Full (36) | Full (36) | User wants complete audit, not just known failures |
| D3 | Body size limit | 50% of original / 2x current / No limit | No limit | Quality chain completeness > file size |

---

## 11. Micro-Tasks

| # | Task | Est. Time | Files |
|---|------|-----------|-------|
| M1 | Read Alex SKILL.md body, catalog all reference stubs | 10 min | alex/SKILL.md |
| M2 | Read Blake SKILL.md body, catalog all reference stubs | 5 min | blake/SKILL.md |
| M3 | Audit Alex references 1-10 | 20 min | alex/references/ |
| M4 | Audit Alex references 11-20 | 20 min | alex/references/ |
| M5 | Audit Alex references 21-31 | 20 min | alex/references/ |
| M6 | Audit Blake references 1-5 | 10 min | blake/references/ |
| M7 | Write summary + cross-reference table | 10 min | evidence/designs/ |
| M8 | Self-review for completeness | 5 min | — |
