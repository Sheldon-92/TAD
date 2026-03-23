# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-03-23
**Project:** TAD Framework
**Task ID:** TASK-20260323-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260323-superpowers-tactical-upgrades.md (Phase 1/5)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-03-23

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Ralph Loop Group 0 insertion point clearly defined |
| Components Specified | ✅ | New subagent prompt, config entries, template section all specified |
| Functions Verified | ✅ | Existing Ralph Loop structure verified from tad-blake.md + config files |
| Data Flow Mapped | ✅ | Handoff AC → spec-compliance-reviewer → PASS/FAIL → Group 1 |

**Gate 2 结果**: ✅ PASS

**Alex确认**: Blake can independently implement this from the handoff. All insertion points are precisely identified with line references.

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解 Group 0 在 Group 1 之前执行，且是阻塞性的
- [ ] 理解 spec-compliance-reviewer 只检查"做对了吗"，不检查"做好了吗"
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building
A new **spec-compliance-reviewer** subagent that runs as **Group 0** in Ralph Loop Layer 2, BEFORE the existing code-reviewer (Group 1). It reads the handoff's Acceptance Criteria and compares them against actual implementation code, producing a line-by-line compliance matrix.

### 1.2 Why We're Building It
**业务价值**：Current Ralph Loop's code-reviewer mixes two concerns: "did we build the right thing?" (spec compliance) and "did we build it right?" (code quality). Separating them ensures Blake doesn't waste time polishing code that doesn't match the spec.
**用户受益**：Catches requirement mismatches early, before code quality review runs.
**成功的样子**：When Group 0 blocks a non-compliant implementation, and Group 1 only runs on spec-verified code.

### 1.3 Intent Statement

**真正要解决的问题**：Blake 的实现有时偏离 handoff 要求但通过了 code review（因为 code-reviewer 关注代码质量而非需求符合度）。

**不是要做的（避免误解）**：
- ❌ 不是要替换 code-reviewer（它仍然在 Group 1 负责代码质量）
- ❌ 不是要改变 Layer 1 的自检流程
- ❌ 不是要创建新的 Gate（这是 Ralph Loop 内的改进）

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ MANDATORY READ — Blake 在开始实现前，必须执行以下 Read 操作：**
1. Read `.tad/project-knowledge/architecture.md`

本次任务涉及的领域：
- [x] architecture - 架构决策

**⚠️ Blake 必须注意的历史教训**：

1. **YAML Structure Awareness** (来自 architecture.md)
   - 问题：Protocol files mix flat and nested YAML formats
   - 解决方案：New insertions must match surrounding context exactly. Check loop-config.yaml's existing group format before adding Group 0.

2. **Measure Before Optimizing** (来自 architecture.md, Phase 0 learning)
   - 问题：Assumptions about overhead can be wrong
   - 解决方案：The spec-compliance-reviewer should be lightweight — it reads files and compares, no heavy analysis.

### Blake 确认
- [ ] 我已阅读 architecture.md
- [ ] 我理解 YAML 格式需与现有结构一致

---

## 2. Background Context

### 2.1 Previous Work
- Ralph Loop Layer 2 currently has 2 groups: Group 1 (code-reviewer, blocking) → Group 2 (test-runner, security, performance, parallel)
- Superpowers' 2-stage review separates "spec compliance" from "code quality" — we're adopting this pattern

### 2.2 Current State
```
Layer 2 Expert Review:
  Group 1 (Sequential, Blocking): code-reviewer → checks both spec AND quality (mixed)
  Group 2 (Parallel, after Group 1): test-runner, security-auditor, performance-optimizer
```

### 2.3 Target State
```
Layer 2 Expert Review:
  Group 0 (Sequential, Blocking): spec-compliance-reviewer → "Did we build the right thing?"
  Group 1 (Sequential, Blocking, after Group 0): code-reviewer → "Did we build it right?"
  Group 2 (Parallel, after Group 1): test-runner, security-auditor, performance-optimizer
```

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: New `spec-compliance-reviewer` subagent with dedicated prompt
- FR2: Runs as Group 0 in Ralph Loop Layer 2, blocking — must pass before Group 1 starts
- FR3: Input = handoff Acceptance Criteria + actual code files
- FR4: Output = Task Completion Matrix (AC-by-AC compliance check)
- FR5: Core instruction in prompt: **"Critical: Do Not Trust the Report — read actual code, compare line-by-line against requirements"**
- FR6: Handoff template gains a `## Spec Compliance Checklist` section for structured AC
- FR7: expert-criteria.yaml gains a `spec-compliance-reviewer` entry

### 3.2 Non-Functional Requirements
- NFR1: Lightweight — should complete in <3 minutes for typical handoffs
- NFR2: No changes to Layer 1 or Gate 3/4 logic
- NFR3: Backward compatible — handoffs without the new section still work (reviewer uses § Acceptance Criteria)

---

## 4. Technical Design

### 4.1 Architecture: Group 0 Insertion

**Files to modify:**
1. `.tad/ralph-config/loop-config.yaml` — Add `group0` before `group1` in `layer2.priority_groups` + update `summary_format` table header
2. `.tad/ralph-config/expert-criteria.yaml` — Add `spec-compliance-reviewer` full entry
3. `.claude/commands/tad-blake.md` — Update Ralph Loop diagrams + `3_layer2_loop` config
4. `.tad/templates/handoff-a-to-b.md` — Add optional `## Spec Compliance Checklist` section
5. `.tad/agents/agent-b-executor.md` — Add `spec-compliance-reviewer` subagent rule with prompt_template
6. `.tad/schemas/loop-config.schema.json` — Add `group0` to priority_groups definition
7. `.tad/schemas/expert-criteria.schema.json` — Add `spec-compliance-reviewer` type support

### 4.2 spec-compliance-reviewer Subagent Prompt

The reviewer is its own subagent type (`spec-compliance-reviewer`), called via `Agent` tool with a dedicated prompt. It is NOT a reuse of code-reviewer — it has its own identity, prompt, and pass criteria.

**prompt_template** (to be added in `agent-b-executor.md`):
```
You are a Spec Compliance Reviewer. Your ONLY job is to verify that the implementation
matches the handoff specification. You do NOT review code quality, style, performance,
or security — other experts handle those.

INPUTS:
1. Handoff file: {handoff_path}
   - FIRST look for "## 9.1 Spec Compliance Checklist" section
   - If not found, FALL BACK to "## 9. Acceptance Criteria" section
   - This fallback ensures backward compatibility with older handoffs
2. Changed files: {file_list} — read the actual implementation

PROCESS:
For each Acceptance Criterion:
1. Read the criterion carefully
2. Find the corresponding implementation in the code
3. Verify: Does the code actually satisfy this criterion?
4. Mark: ✅ SATISFIED / ❌ NOT SATISFIED / ⚠️ PARTIALLY SATISFIED

CRITICAL RULE: Do Not Trust the Report. Do not trust Blake's self-assessment
or completion report. Read the ACTUAL CODE and verify yourself.

OUTPUT FORMAT:
## Spec Compliance Report

### Task Completion Matrix
| # | Acceptance Criterion | Status | Evidence (file:line) | Notes |
|---|---------------------|--------|---------------------|-------|
| 1 | {AC text} | ✅/❌/⚠️ | {file:line} | {what you found} |

### Summary
- Total ACs: {N}
- Satisfied: {N}
- Not Satisfied: {N}
- Partially Satisfied: {N}

### Verdict: PASS / FAIL
PASS = zero NOT_SATISFIED items. Up to 3 PARTIALLY_SATISFIED items allowed.
FAIL = any NOT_SATISFIED item, regardless of justification.
```

### 4.3 Pass Criteria

Uses the existing `severity_count` type with mapped statuses (NOT_SATISFIED=P0, PARTIALLY_SATISFIED=P1, SATISFIED=P3):

```yaml
spec-compliance-reviewer:
  description: "Spec compliance check — verify implementation matches handoff AC"
  subagent_type: "spec-compliance-reviewer"
  conditional: false  # Always runs (not triggered by pattern)

  pass_condition:
    type: "severity_count"
    rules:
      - severity: "not_satisfied"
        max_count: 0
        blocking: true
        description: "All acceptance criteria must be satisfied or partially satisfied"
      - severity: "partially_satisfied"
        max_count: 3
        blocking: false
        description: "Up to 3 partially satisfied ACs allowed"
      - severity: "satisfied"
        max_count: -1
        blocking: false
        description: "Unlimited satisfied ACs"

  severity_definitions:
    not_satisfied:
      name: "Not Satisfied"
      description: "AC requirement not met in implementation"
      examples:
        - "Feature described in AC not implemented"
        - "File mentioned in AC not created or modified"
        - "Behavior does not match AC description"
    partially_satisfied:
      name: "Partially Satisfied"
      description: "AC partially met — implementation exists but incomplete or differs"
      examples:
        - "Feature implemented but missing edge case handling"
        - "File created but not all required changes present"
    satisfied:
      name: "Satisfied"
      description: "AC fully met — implementation matches requirement"

  output_format:
    required_sections:
      - "task_completion_matrix"
      - "summary"
      - "pass_status"
    evidence_template: ".tad/templates/output-formats/spec-compliance-format.md"
```

### 4.4 Handoff Template Addition

Add after `## 9. Acceptance Criteria`:

```markdown
## 9.1 Spec Compliance Checklist (for automated verification)

Blake的实现将由 spec-compliance-reviewer 自动核对以下条目：

| # | Acceptance Criterion | Verification Method | Expected Evidence |
|---|---------------------|--------------------|--------------------|
| 1 | {same as AC above} | {how to verify: file check, grep, test run} | {what the reviewer should find} |

> This section is OPTIONAL. If omitted, the spec-compliance-reviewer will use
> the § Acceptance Criteria section directly. This section adds verification
> guidance for more precise automated checking.
```

---

## 5. 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索
**回答**: ✅ 是 — Ralph Loop 的 Group 配置已存在
**搜索目标**: `loop-config.yaml` 中的 `priority_groups`、`expert-criteria.yaml` 中的 expert 定义
**位置**: `.tad/ralph-config/loop-config.yaml:60-123`, `.tad/ralph-config/expert-criteria.yaml:1-250`
**决定**: 在现有结构中插入 Group 0，保持格式一致

### MQ2: 函数存在性验证
**回答**: N/A — TAD 框架是 YAML/MD 配置，不涉及编程函数

### MQ3-MQ5: N/A (no data flow, no UI, no state sync)

---

## 6. Implementation Steps

### Phase 1: Config + Schema Files (预计 40 分钟)

#### 交付物
- [ ] `loop-config.yaml` updated with Group 0 + summary_format updated
- [ ] `expert-criteria.yaml` updated with full spec-compliance-reviewer entry
- [ ] `agent-b-executor.md` updated with spec-compliance-reviewer subagent rule + prompt_template
- [ ] Schema files updated to accept new group0 and expert type

#### 实施步骤
1. In `loop-config.yaml`, add `group0` section BEFORE existing `group1` in `layer2.priority_groups`:
   ```yaml
   group0:
     name: "Spec Compliance Gate"
     description: "Verify implementation matches handoff specification before quality review"
     parallel: false
     experts:
       - name: "spec-compliance-reviewer"
         subagent_type: "spec-compliance-reviewer"
         timeout:
           default: 180000      # 3 minutes
           small_change: 120000 # 2 minutes
           large_change: 300000 # 5 minutes
         timeout_selection: "auto"
         pass_criteria:
           severity_threshold: "partially_satisfied"
           max_issues:
             not_satisfied: 0
             partially_satisfied: 3
             satisfied: -1
         evidence_file: "{date}-spec-compliance-{task}-iter{n}.md"
   ```
   **Do NOT rename or renumber existing group1/group2 keys.** Group 0 is a new key inserted before group1.
   **YAML ordering note**: Group execution order is determined by key name sorting (group0 < group1 < group2). Verify this assumption by checking how tad-blake.md processes priority_groups.

2. In `loop-config.yaml`, update the `summary_format` template (search for `## Layer 2 Results`):
   Change the table header from:
   `| Round | code-reviewer | test-runner | security | performance | Result |`
   To:
   `| Round | spec-compliance | code-reviewer | test-runner | security | performance | Result |`
   Also add `{spec_compliance_link}` to the Evidence Files section.

3. In `expert-criteria.yaml`, add the full `spec-compliance-reviewer` entry from Section 4.3 of this handoff, positioned BEFORE the `code-reviewer` entry.

4. In `agent-b-executor.md`, add a `spec-compliance-reviewer` subagent rule with the full `prompt_template` from Section 4.2. Follow the existing pattern of other subagent rules in that file.

5. Update schema files:
   - `loop-config.schema.json`: ensure `group0` is accepted in `priority_groups`
   - `expert-criteria.schema.json`: ensure `spec-compliance-reviewer` type is accepted

### Phase 2: Blake Protocol (预计 45 分钟)

#### 交付物
- [ ] `tad-blake.md` updated with Group 0 in all Ralph Loop references

#### 实施步骤
Search for each section by header name (do NOT use line numbers):

1. Search for the `*develop 命令流程` ASCII art block → add Group 0 before Group 1 in the diagram
2. Search for `3_layer2_loop` section → add `group0` entry before `group1` in `priority_groups`
3. Search for `layer2_verification` section → add `"spec-compliance-reviewer: all ACs satisfied"` entry
4. Search for `Expert Priority Groups` in Quick Reference → add Group 0 before Group 1
5. Search broadly for references to update:
   ```bash
   grep -n "code-reviewer.*first\|code-reviewer.*→.*parallel\|Group 1.*first\|Expert Review.*code-reviewer\|code-reviewer → test-runner\|code-reviewer.*blocking" .claude/commands/tad-blake.md
   ```
   Every match must be updated to mention spec-compliance-reviewer before code-reviewer.

### Phase 3: Handoff Template (预计 15 分钟)

#### 交付物
- [ ] `handoff-a-to-b.md` updated with optional Spec Compliance Checklist section

#### 实施步骤
1. Search for `## 9. Acceptance Criteria` → add `## 9.1 Spec Compliance Checklist` section after it
2. Include the template from Section 4.4 of this handoff
3. Add a note: "OPTIONAL — if omitted, spec-compliance-reviewer falls back to § 9. Acceptance Criteria directly"

---

## 7. File Structure

### 7.1 Files to Modify
```
.tad/ralph-config/loop-config.yaml        # Add group0 + update summary_format table header
.tad/ralph-config/expert-criteria.yaml    # Add full spec-compliance-reviewer entry
.tad/agents/agent-b-executor.md           # Add subagent rule with prompt_template
.claude/commands/tad-blake.md             # Update all Ralph Loop diagrams + config references
.tad/templates/handoff-a-to-b.md          # Add Spec Compliance Checklist section
.tad/schemas/loop-config.schema.json      # Accept group0 in priority_groups
.tad/schemas/expert-criteria.schema.json  # Accept spec-compliance-reviewer type
```

### 7.2 No Files to Create
All changes are modifications to existing files.

---

## 8. Testing Requirements

### 8.1 Structural Validation
- Verify loop-config.yaml is valid YAML after changes
- Verify expert-criteria.yaml is valid YAML after changes
- Verify all Blake protocol references to Group numbers are consistent

### 8.2 Logical Validation
- Group 0 appears before Group 1 in all diagrams and configs
- Group 0 is marked as `blocking: true` / `parallel: false`
- The spec-compliance-reviewer prompt focuses ONLY on spec compliance, not code quality
- The handoff template's new section is marked as optional

### 8.3 Grep-Based Completeness Check
After all changes, run TWO passes:
```bash
# Pass 1: Explicit Group 1 "first" references
grep -rn "Group 1.*Blocking\|Group 1.*Sequential\|Group 1.*first" .tad/ .claude/commands/tad-blake.md

# Pass 2: Narrative references to code-reviewer as first/only blocking expert
grep -rn "code-reviewer.*first\|code-reviewer.*→.*parallel\|Expert Review.*code-reviewer\|code-reviewer → test-runner" .tad/ .claude/commands/tad-blake.md
```
Every match from either pass must now mention spec-compliance-reviewer before code-reviewer, OR be updated to reflect the new Group 0 → Group 1 → Group 2 flow.

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] AC1: `loop-config.yaml` has `group0` entry with `subagent_type: "spec-compliance-reviewer"`, positioned before `group1`
- [ ] AC2: `loop-config.yaml` `summary_format` table header includes `spec-compliance` column
- [ ] AC3: `expert-criteria.yaml` has full `spec-compliance-reviewer` entry (pass_condition, severity_definitions, output_format)
- [ ] AC4: `agent-b-executor.md` has `spec-compliance-reviewer` subagent rule with prompt_template
- [ ] AC5: `tad-blake.md` ASCII diagram shows Group 0 → Group 1 → Group 2 flow
- [ ] AC6: `tad-blake.md` `3_layer2_loop` section includes `group0` with correct config
- [ ] AC7: `tad-blake.md` Quick Reference shows updated Expert Priority Groups
- [ ] AC8: `tad-blake.md` all textual references updated (no stale "code-reviewer first" without spec-compliance)
- [ ] AC9: `tad-blake.md` `layer2_verification` section includes spec-compliance pass criteria
- [ ] AC10: `handoff-a-to-b.md` has optional `## 9.1 Spec Compliance Checklist` section
- [ ] AC11: Schema files updated to accept group0 and spec-compliance-reviewer
- [ ] AC12: Spec compliance prompt includes "Do Not Trust the Report" + fallback logic (§9.1 → §9)
- [ ] AC13: Group 0 is blocking — Group 1 cannot start until Group 0 passes
- [ ] AC14: All modified YAML files are valid (parseable without errors)
- [ ] AC15: Grep completeness check passes (both passes — no stale references)
- [ ] AC16: Backward compatible — handoffs without Spec Compliance Checklist section still work (prompt falls back to §9)

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ Do NOT rename or renumber existing group1/group2 keys. Group 0 is a NEW key inserted before group1.
- ⚠️ `spec-compliance-reviewer` is its OWN subagent type — do NOT reuse `code-reviewer` type. Each expert has its own identity.
- ⚠️ Match the YAML format of existing group entries exactly (check indentation, field names, timeout structure).
- ⚠️ The prompt MUST include fallback logic: check for §9.1 first, fall back to §9 if missing (backward compat).

### 10.2 Known Constraints
- The spec-compliance-reviewer cannot run tests — it only reads code and compares against AC
- For handoffs without a Spec Compliance Checklist, the reviewer falls back to § Acceptance Criteria

### 10.3 Sub-Agent使用建议
- [ ] **code-reviewer** — standard Layer 2 review of Blake's own changes to TAD config files

---

## 11. Decision Context

### Why Group 0 (not embedded in code-reviewer)?

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| Group 0 独立 (选中) | 明确分离关注点；spec 失败时不浪费 code review 时间 | 增加一个 review 步骤 | ✅ Separation of concerns is the core innovation |
| 嵌入 code-reviewer prompt | 不增加步骤数 | 两种关注点混合；无法独立阻塞 | 违背了 Superpowers 的核心洞察 |
| Blake 自检 (Layer 1) | 最快 | 自检不可信（这正是要解决的问题）| 自己审自己 = 无效 |

---

---

## Expert Review Status

| Expert | Verdict | P0 Found | P0 Fixed | P1 Integrated | Overall |
|--------|---------|----------|----------|---------------|---------|
| code-reviewer | CONDITIONAL PASS | 4 | 4 ✅ | 4/5 key items | PASS (after fixes) |
| backend-architect | CONDITIONAL PASS | 3 | 3 ✅ | 4/5 key items | PASS (after fixes) |

### P0 Issues Fixed
1. **`prompt_override: true` fabricated** → Removed. spec-compliance-reviewer gets its own `subagent_type` + `prompt_template` in agent-b-executor.md (both experts)
2. **`completion_matrix` type undefined** → Changed to `severity_count` with mapped statuses (NOT_SATISFIED=P0, PARTIALLY_SATISFIED=P1) (both experts)
3. **Missing `agent-b-executor.md`** → Added to files list with prompt_template instructions (architect)
4. **Missing schema files** → Added `.tad/schemas/` to files list (code-reviewer)
5. **Missing `summary_format` update** → Added to Phase 1 step 2 + AC2 (both experts)

### P1 Items Integrated
- PASS/FAIL verdict ambiguity → Replaced with absolute rule: "zero NOT_SATISFIED = PASS, any NOT_SATISFIED = FAIL" (architect)
- File Coverage table removed from prompt (noise without clear pass criteria) (architect)
- "Rename group1" ambiguity removed → Definitive "Do NOT rename" (both)
- Line numbers removed from Phase 2 → Section header search only (architect)
- Grep pattern broadened to 2 passes (code-reviewer)
- Backward compat fallback explicit in prompt (§9.1 → §9) (code-reviewer)
- Full expert-criteria.yaml entry with output_format specified (code-reviewer)
- layer2_verification AC added (code-reviewer P2-4 → promoted to AC9)

**Expert Review Complete — Ready for Implementation**

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-03-23
**Version**: 3.1.0 (post-expert-review)
