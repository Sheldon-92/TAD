---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex", ".claude/skills/blake", ".tad/templates"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Triple-Question KA — 知识 + Skill + Workflow 三问闭环

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-03
**Project:** TAD Framework
**Task ID:** TASK-20260603-TQK
**Handoff Version:** 3.1.0

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-06-03

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 三问流程 Q1→Q2→Q3 完整，触发点明确（Blake Gate3 + Alex *accept + optional workflow） |
| Components Specified | ✅ | 4 个文件的修改位置、内容、嵌套层级全部指定 |
| Functions Verified | ✅ | 目标代码段已 Read（Blake SKILL lines 1787-1895, templates, Alex SKILL in context） |
| Data Flow Mapped | ✅ | Q2→Q3 依赖关系、skip_KA 传播链、skillify→workflow_evaluation 交互已明确 |

**Gate 2 结果**: ✅ PASS

**Expert Review**: 2 experts (code-reviewer + backend-architect), 5 P0 + 8 P1 发现，全部已修复。见 §9.2-9.3。

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」章节中的历史经验
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
将 TAD 的 Knowledge Assessment（KA）从"两问"（新知识？新 skill？）扩展为"三问"（新知识？新 skill？新/改 workflow？），同时精简触发点（从 7→2-3），并在 Skillify 流程中增加第五步"判断型 vs 编排型"路由。

### 1.2 Why We're Building It
**业务价值**：TAD 每次执行 workflow 后的编排经验目前静默流失。三问闭环让 workflow 改进成为系统化流程，而非偶然想到才做。
**用户受益**：workflow 持续从实践中改进，减少重复的手动多 agent 编排。
**成功的样子**：当 Blake 完成 Gate 3 写 completion report 时，三问自然出现；Alex *accept 时也问三问；Skillify 能根据模式类型自动路由到 SKILL.md 或 .workflow.js。

### 1.3 Intent Statement

**真正要解决的问题**：TAD 有 5 个 production workflow 但没有系统化的"发现 → 记录 → 改进"闭环。KA 只问知识和 skill，不问 workflow 模式。

**不是要做的**：
- ❌ 不是重写 KA 系统——只在现有 KA 上加一问
- ❌ 不是给每个执行都加三问——只在 2-3 个精选触发点
- ❌ 不是自动生成 .workflow.js——三问只产出 candidate，人工审批后才生成

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别
- [x] architecture — Gate 设计、KA 流程
- [x] patterns/gate-design.md — Gate 责任矩阵、Workflow 内部 stop gate

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| patterns/gate-design.md | 2 条 | Gate 责任矩阵 + Workflow-Internal Stop Gates |
| principles.md | 1 条 | Mechanical Enforcement Rejected — 不做 hook |

**⚠️ Blake 必须注意的历史教训**：

1. **Gate Responsibility Matrix** (patterns/gate-design.md)
   - Blake 的 Gate 3 拥有 KA，Alex 的 Gate 4 拥有业务验收 KA。三问的 Blake 侧改动限于 Gate 3 KA section。

2. **Mechanical Enforcement Rejected** (principles.md)
   - 三问是 prompt-level enforcement，不做 hook。不在 settings.json 注册任何新检查。

3. **Workflow-Internal Stop Gates** (patterns/gate-design.md)
   - workflow_evaluation 是 non-blocking（同 skillify_evaluation）。不阻塞 Gate 3 completion。

---

## 2. Background Context

### 2.1 Previous Work
- KA 两问（知识 + skill）：Blake SKILL.md `knowledge_assessment` section (line ~1788)
- Skillify 评估：Blake SKILL.md `skillify_evaluation` (line ~1802)
- Alex KA：Alex SKILL.md `acceptance_protocol.step7` (C_alex_own_discoveries)
- 5 个 production workflows：epic-audit, gate-review, tournament-design, yolo-epic, loop-discover

### 2.2 Current State
- KA 问两问：是否有新发现 + 是否有新 skill candidate
- Skillify 产出固定为 SKILL.md，无 workflow 路由
- Alex 写 .workflow.js 被视为违规（feedback_alex-no-code-violation.md）
- Workflow 完成后无任何反思机制

### 2.3 Dependencies
- Skillify candidate template 已存在 (.tad/templates/skillify-candidate-template.md)
- Completion report template 已存在 (.tad/templates/completion-report.md)

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**: Blake Gate 3 KA 扩展为三问（知识？skill？workflow 模式？）
- **FR2**: Alex Gate 4 KA 扩展为三问（对称）
- **FR3**: Alex 可选触发点：Workflow tool 返回 usage.agent_count ≥ 3 时触发轻量三问
- **FR4**: Skillify 增加第五步：4-gate 通过后路由"判断型 → SKILL.md"或"编排型 → .workflow.js"
- **FR5**: 正式 carve-out：Alex 可以直接写 .workflow.js（编排设计不是实现代码）
- **FR6**: Skillify candidate 模板增加 `type: judgment | orchestration` 字段

### 3.2 Non-Functional Requirements

- **NFR1**: 不增加任何 hook（mechanical enforcement rejected 原则）
- **NFR2**: 旧 completion report 无需兼容（三问字段缺失时正常处理）
- **NFR3**: 三问是 non-blocking（同 skillify_evaluation：blocking: false）

---

## 4. Technical Design

### 4.1 Blake SKILL.md 改动

**位置**: `knowledge_assessment.must_answer` (line ~1794)

现在：
```yaml
must_answer:
  - "是否有新发现？(Yes/No)"
  - "如果有，属于哪个类别？"
  - "一句话总结（即使无新发现也要写明原因）"
```

改为：
```yaml
must_answer:
  - "Q1: 是否有新发现？(Yes/No) — 如果有，属于哪个类别？一句话总结。"
  - "Q2: 是否有可复用的工作模式？(Yes/No) — Skillify 4-gate + Step 5 路由。"
  - "Q3: 是否发现 workflow 模式？(Yes/No) — 信号：执行中是否手动做了多 agent 编排（并行、竞争、循环），或现有 workflow 有缺陷？"
```

**新增 `workflow_evaluation`** (在 `skillify_evaluation` 之后):

⚠️ **YAML 嵌套层级** (CR-P0-2 fix): `workflow_evaluation:` 是 `knowledge_assessment:` 的子节点，与 `skillify_evaluation:` 同级（缩进与 skillify_evaluation 相同）。插入位置：`skillify_evaluation.forbidden_implementations` 结束（~line 1831）与上层 `violation:` key（~line 1833）之间。

```yaml
    workflow_evaluation:
      trigger: "After skillify_evaluation completes (regardless of skillify gate result)"
      action: |
        Q3 signal detection — scan the implementation process for:
        Signal words: "parallel agents", "fan-out", "tournament", "loop until",
        "competing approaches", "adversarial verify", "pairwise judge"
        
        Two sub-paths:
        a. "I manually orchestrated multi-agent coordination that worked well"
           → New workflow candidate: write SCAND-{date}-{slug}.md with type: orchestration
        b. "An existing workflow had a defect (bad prompt, too loose judgment, missing dimension)"
           → Record in completion report Q3 row: "Defect in {workflow_name}: {description}"
           → Alex creates bugfix handoff during *accept
        
        If no signal detected → Q3 row: "No: no workflow patterns observed"
      blocking: false
      interacts_with_skillify: |
        Skip ONLY if skillify_evaluation Step 5 explicitly routed a pattern to
        type: orchestration. If skillify gates 1-4 rejected the pattern (Step 5
        never ran), workflow_evaluation MUST still perform its own signal detection.
        Q3 serves as a safety net for orchestration patterns that don't pass
        skillify's quality gates.
      interacts_with_override: |
        Follows the same skip/override chain as skillify_evaluation:
        If skip_knowledge_assessment: yes AND no override marker → workflow_evaluation ALSO skips.
        If skip_knowledge_assessment: yes AND override marker present → workflow_evaluation runs.
```

**修改 `skillify_evaluation`** — 在现有 `action:` 多行字符串的 step 2 之后追加 step 2b（作为 action 的延续，不是 YAML 注释）：

```yaml
    # Inside skillify_evaluation.action: |, append after "2. If all 4 pass → write SCAND-...":
    #
    # The following text goes INTO the action: | multi-line string, NOT as YAML comments:
    
        2b. Step 5 — Pattern Type Routing (after 4-gate pass):
            Classify the pattern: does executing it require >1 agent coordinating?
            Yes → set `type: orchestration` in SCAND frontmatter → targets .workflow.js
            No  → set `type: judgment` in SCAND frontmatter → targets SKILL.md (existing path)
            Signal table:
            | Signal | Type | Target |
            | "Evaluating X requires checking Y and Z" | judgment | SKILL.md |
            | "Per-AC verifier + skeptic each time" | orchestration | .workflow.js |
            | "N agents compete, judge selects, merge" | orchestration | .workflow.js |
            | "When rubric score is abnormal, check inter-rater reliability" | judgment | SKILL.md |
            | "Loop finding bugs until K dry rounds" | orchestration | .workflow.js |
            If type: orchestration, also note in "Proposed Skill Outline":
              "Target: .workflow.js (orchestration pattern, not SKILL.md)"
```

### 4.2 Alex SKILL.md 改动

**位置 1**: `acceptance_protocol.step7.C_alex_own_discoveries`

扩展现有 prediction-error heuristic 分类，增加：
```yaml
e. "Is this an orchestration pattern that recurred?" → WORKFLOW-CANDIDATE
   → Same Skillify 4-gate + Step 5 as Blake side
   → If type: orchestration → Alex writes .workflow.js directly (per carve-out)
   → If type: judgment → write SCAND candidate (existing path)
```

**位置 2**: `forbidden` section (near end of SKILL.md)

Add exception block AFTER the main `forbidden:` list (~line 5907, the "Forbidden actions (will trigger VIOLATION)" section), NOT inside any `forbidden_implementations:` blocks:

```yaml
# Workflow Authoring Carve-Out (Triple-Question KA, 2026-06-03)
# Similar to the existing *publish exception for git push/tag (~line 5412).
workflow_authoring_exception:
  description: |
    EXCEPTION TO "Writing implementation code":
    Workflow scripts (.workflow.js) are orchestration design artifacts,
    not implementation code. Alex may author workflow scripts directly.
  forbidden_implementations:
    - "MUST NOT extend .workflow.js exception to .sh files (shell scripts are implementation, not orchestration design)"
    - "MUST NOT extend .workflow.js exception to .json/.yaml config files"
    - "MUST NOT write .workflow.js without human confirmation via AskUserQuestion"
    - "MUST NOT auto-invoke the carve-out — user must explicitly trigger via *skillify or *accept"
    - "MUST NOT use this exception to write application code, build scripts, hook implementations, or test scripts"
```

**位置 3**: New section `workflow_completion_trigger` (after `acceptance_protocol`):

```yaml
workflow_completion_trigger:
  description: "Lightweight three-question assessment after significant workflow execution"
  trigger: "Workflow tool returns result with usage.agent_count >= 3"
  blocking: false
  action: |
    After a Workflow tool call completes with agent_count >= 3:
    1. Q1 (knowledge): "Did this workflow execution reveal something new?"
       → If yes: record to .tad/project-knowledge/ (same as Gate 4 C)
    2. Q2 (skill): "Did the workflow expose a reusable judgment pattern?"
       → If yes: Skillify 4-gate + Step 5 (same path)
    3. Q3 (workflow): "Should this workflow be improved based on what just happened?"
       → If yes (defect): record for future bugfix handoff
       → If yes (new pattern): write SCAND candidate with type: orchestration
    
    Lightweight = 1 AskUserQuestion with 3 sub-questions, not 3 separate interactions.
    Skip if workflow was a TAD framework management task (*publish, *sync).
  threshold_rationale: |
    agent_count >= 3 filters out trivial 2-agent workflows (e.g., simple parallel search).
    All 5 current production workflows use >= 3 agents — threshold validated against existing corpus.
  agent_count_source: |
    agent_count comes from the Workflow tool's TASK-NOTIFICATION envelope
    (<usage><agent_count>N</agent_count></usage>), NOT from the workflow
    script's return value. The runtime provides this automatically for every
    workflow run. Alex reads it from the notification, not from the .workflow.js.
```

**位置 4**: `skillify_command_protocol` — 在现有 gate 检查之后加 Step 5：

```yaml
# After step 4 (quality gates all pass), add:
step5:
  name: "Pattern Type Routing"
  action: |
    Classify the detected pattern:
    - Does executing this pattern require >1 agent coordinating?
      Yes → type: orchestration → candidate targets .workflow.js
      No  → type: judgment → candidate targets SKILL.md (existing path)
    
    Signal table:
    | Signal | Type | Target |
    |--------|------|--------|
    | "Evaluating X requires checking Y and Z" | judgment | SKILL.md |
    | "Per-AC verifier + skeptic each time" | orchestration | .workflow.js |
    | "N agents compete, judge selects, merge" | orchestration | .workflow.js |
    | "When rubric score is abnormal, check inter-rater reliability" | judgment | SKILL.md |
    | "Loop finding bugs until K dry rounds" | orchestration | .workflow.js |
    
    Write `type` field in SCAND frontmatter. Announce:
    "Pattern classified as {type}. Target: {SKILL.md | .workflow.js}"
```

### 4.3 Template 改动

**.tad/templates/skillify-candidate-template.md** — 在 frontmatter 加字段：

```yaml
type: judgment  # judgment | orchestration — Step 5 routing result
# judgment → generates .claude/skills/{slug}/SKILL.md
# orchestration → generates .claude/workflows/{slug}.workflow.js
```

**.tad/templates/completion-report.md** — Knowledge Assessment 表格加一行：

```markdown
| ⚠️ Workflow Pattern Discovered | ✅/❌ | [Yes: new pattern / defect in {name} / No: none observed] |
```

位于现有 `Skillify Candidate` 行之后。

---

## 5. Files to Modify / Create

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `.claude/skills/blake/SKILL.md` | MODIFY | Expand knowledge_assessment.must_answer to 3Q; add workflow_evaluation; modify skillify_evaluation for Step 5 |
| 2 | `.claude/skills/alex/SKILL.md` | MODIFY | Expand acceptance_protocol.step7.C; add carve-out to forbidden; add workflow_completion_trigger; add Step 5 to skillify_command_protocol |
| 3 | `.tad/templates/skillify-candidate-template.md` | MODIFY | Add `type: judgment \| orchestration` field |
| 4 | `.tad/templates/completion-report.md` | MODIFY | Add Q3 row to Knowledge Assessment table |

**Grounded Against** (Alex step1c):
- .claude/skills/blake/SKILL.md (lines 1787-1895, read at 2026-06-03)
- .claude/skills/alex/SKILL.md (full file in context from activation)
- .tad/templates/skillify-candidate-template.md (full file, read at 2026-06-03)
- .tad/templates/completion-report.md (head 60, read at 2026-06-03)

---

## 6. Implementation Steps

### P1: Blake SKILL.md — Expand KA to Three Questions
1. In `knowledge_assessment.must_answer` (~line 1794): replace 3-item list with reformulated 3-question list (Q1/Q2/Q3)
2. In `skillify_evaluation` (~line 1802): after the existing "2. If all 4 pass" step, insert Step 5 (Pattern Type Routing) with signal table
3. After `skillify_evaluation` block (~line 1831): insert new `workflow_evaluation` block
4. Verify `interacts_with_override` still correctly references the skip_knowledge_assessment chain

### P2: Alex SKILL.md — Expand Gate 4 KA + Carve-out + Triggers
1. In `acceptance_protocol.step7.C_alex_own_discoveries`: add item (e) for workflow pattern classification
2. In `forbidden` list (near end): add .workflow.js carve-out exception
3. After `acceptance_protocol`: insert new `workflow_completion_trigger` section
4. In `skillify_command_protocol`: after step 4, add step5 (Pattern Type Routing)

### P3: Templates
1. In `skillify-candidate-template.md`: add `type: judgment` field to frontmatter (with comment)
2. In `completion-report.md`: add `⚠️ Workflow Pattern Discovered` row after `Skillify Candidate` row

---

## 7. Testing Checklist

- [ ] T1: Read modified Blake SKILL.md — verify must_answer has exactly 3 items (Q1/Q2/Q3)
- [ ] T2: Read modified Blake SKILL.md — verify workflow_evaluation section exists after skillify_evaluation
- [ ] T3: Read modified Blake SKILL.md — verify skillify_evaluation has Step 5 routing
- [ ] T4: Read modified Alex SKILL.md — verify C_alex_own_discoveries has item (e)
- [ ] T5: Read modified Alex SKILL.md — verify forbidden section has .workflow.js carve-out
- [ ] T6: Read modified Alex SKILL.md — verify workflow_completion_trigger section exists
- [ ] T7: Read modified Alex SKILL.md — verify skillify_command_protocol has step5
- [ ] T8: Read skillify-candidate-template.md — verify `type` field in frontmatter
- [ ] T9: Read completion-report.md — verify Q3 row in Knowledge Assessment table
- [ ] T10: Verify workflow_evaluation.blocking == false
- [ ] T11: Verify no new hooks registered in .claude/settings.json

---

## 8. Important Notes

### 8.1 What NOT To Do
- ❌ Do NOT register hooks for three-question enforcement (principles.md: mechanical enforcement rejected)
- ❌ Do NOT make workflow_evaluation blocking (NFR3)
- ❌ Do NOT change the existing KA skip_knowledge_assessment mechanism (orthogonal)
- ❌ Do NOT modify any existing .workflow.js files **in this handoff's implementation scope**. The carve-out enables Alex to write .workflow.js in *future* sessions when a workflow candidate is accepted via *accept or *skillify.

### 8.2 Sub-Agent Recommendations
- code-reviewer: verify YAML structure integrity in SKILL.md edits (indentation, field nesting)
- No security-auditor needed (no auth/token/encrypt changes)
- No performance-optimizer needed (prompt-only changes)

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Requirement | Verification Method | Expected Evidence |
|-----|------------|--------------------|--------------------|
| AC1 | Blake KA has 3 questions | `grep -c '"Q[123]:' .claude/skills/blake/SKILL.md` | 3 |
| AC2 | workflow_evaluation exists in Blake SKILL | `grep -c 'workflow_evaluation:' .claude/skills/blake/SKILL.md` | ≥1 |
| AC3 | workflow_evaluation.blocking == false | `awk '/workflow_evaluation:/,/^[a-zA-Z]/' .claude/skills/blake/SKILL.md \| grep -c 'blocking: false'` | 1 |
| AC4 | Step 5 in skillify_evaluation | `grep -c 'Pattern Type Routing' .claude/skills/blake/SKILL.md` | ≥1 |
| AC5 | Alex C_alex_own_discoveries has workflow item | `grep -c 'WORKFLOW-CANDIDATE' .claude/skills/alex/SKILL.md` | ≥1 |
| AC6 | Alex forbidden has .workflow.js carve-out | `grep -ci 'workflow scripts.*orchestration design' .claude/skills/alex/SKILL.md` | ≥1 |
| AC7 | workflow_completion_trigger in Alex SKILL | `grep -c 'workflow_completion_trigger:' .claude/skills/alex/SKILL.md` | ≥1 |
| AC8 | agent_count >= 3 threshold | `grep -c 'agent_count.*3' .claude/skills/alex/SKILL.md` | ≥1 |
| AC9 | Skillify template has type field | `grep -c '^type:' .tad/templates/skillify-candidate-template.md` | 1 |
| AC10 | Completion template has Q3 row | `grep -c 'Workflow Pattern Discovered' .tad/templates/completion-report.md` | 1 |
| AC11 | No new hooks in settings.json | `git diff .claude/settings.json` | Empty (no changes) |

### 9.2 Expert Review Status

| Expert | Status | P0 Issues | P1 Issues |
|--------|--------|-----------|-----------|
| code-reviewer | ✅ CONDITIONAL PASS → P0 fixed | 3 (AC1 indent, YAML nesting, AC3 scope) | 4 (skip_KA chain, Step5 format, carve-out location, AC6 flag) |
| backend-architect | ✅ CONDITIONAL PASS → P0 fixed | 2 (agent_count source, §8.1 scope) | 4 (forbidden_implementations, Q2/Q3 interaction, override chain, AC fragility) |

### 9.3 Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P0-1: AC1 grep indentation mismatch (2-space vs 6-space) | §9.1 AC1 — removed indentation anchor | Resolved |
| code-reviewer | P0-2: workflow_evaluation YAML nesting level unspecified | §4.1 workflow_evaluation — added explicit nesting note | Resolved |
| code-reviewer | P0-3: AC3 grep -A1 too narrow | §9.1 AC3 — changed to awk section-scoped extraction | Resolved |
| code-reviewer | P1-1: skip_KA chain undefined for workflow_evaluation | §4.1 workflow_evaluation — added interacts_with_override | Resolved |
| code-reviewer | P1-2: Step 5 as YAML comments not action string | §4.1 skillify_evaluation — rewrote as action step 2b | Resolved |
| code-reviewer | P1-3: Carve-out location ambiguous | §4.2 position 2 — specified exact line ~5907 + section name | Resolved |
| code-reviewer | P2-4→P1: AC6 missing -i flag | §9.1 AC6 — added -i flag | Resolved |
| backend-architect | P0-1: usage.agent_count doesn't exist | §4.2 workflow_completion_trigger — clarified source is task-notification envelope | Resolved |
| backend-architect | P0-2: §8.1 scope ambiguity re .workflow.js | §8.1 — clarified "in this handoff's implementation scope" | Resolved |
| backend-architect | P1-1: Carve-out needs forbidden_implementations | §4.2 position 2 — added 5-item forbidden_implementations block | Resolved |
| backend-architect | P1-2: Q2/Q3 interaction when gates fail | §4.1 workflow_evaluation interacts_with_skillify — clarified Step 5 skip condition | Resolved |
| backend-architect | P1-3: Q3 needs override chain | §4.1 workflow_evaluation — added interacts_with_override | Resolved |

---

## 10. Required Evidence Manifest

```yaml
evidence:
  expert_reviews:
    - .tad/evidence/reviews/blake/triple-question-ka/cr-review.md
  gate_verdicts:
    - completion report Gate 3 section
  completion:
    - .tad/active/handoffs/COMPLETION-20260603-triple-question-ka.md
  blake_reviews:
    - .tad/evidence/reviews/blake/triple-question-ka/
  knowledge_updates:
    - project-knowledge entry if new patterns discovered
```

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Trigger points | 7 points (original idea) vs 2-3 (精简) | 2-3 | Blake Gate 3 + Alex *accept + optional workflow ≥3 agent. 7 points = too noisy |
| 2 | Step 5 position | Inside 4-gate vs after 4-gate | After 4-gate | 4-gate = quality threshold, Step 5 = routing decision. Separate concerns |
| 3 | Q3 format | Open reflection vs signal-word trigger vs two-layer | Signal-word trigger | Concrete behavioral signals easier to detect than abstract reflection |
| 4 | Workflow execution | Alex drafts + Blake writes vs Alex writes directly | Alex writes .workflow.js | Formal carve-out: workflow = orchestration design, not implementation code |
| 5 | Existing workflow defects | Knowledge entry vs bugfix handoff vs NEXT.md | Bugfix handoff | Defects deserve dedicated fix, not buried in knowledge |
| 6 | Backward compat | Fallback logic vs no compat | No compat | New fields missing in old completion reports = normal processing |
| 7 | Workflow candidate format | New WCAND-*.md vs reuse SCAND-*.md + type field | Reuse SCAND + type field | Less new infrastructure, same review flow (Alex STEP 3.57) |

**Research source**: Anthropic workflow ecosystem research (workflow run 2026-06-03). Finding: Anthropic has 0 open-source .workflow.js templates. TAD's 5 workflows are ahead of official ecosystem. Community best resource: ray-amjad/claude-code-workflow-creator (linter + 3 templates).
