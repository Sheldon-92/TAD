---
task_type: code
e2e_required: no
research_required: no
---

# Handoff: 质量链修复 Phase 3 — Alex Prompt 层强化

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-04-03
**Project:** TAD
**Task ID:** TASK-20260403-011
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260403-quality-chain-full-repair.md (Phase 3/4)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-04-03 (pending expert review)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 嵌入现有流程，不创建新命令 |
| Components Specified | ✅ | 单文件修改，变更点明确 |
| Functions Verified | ✅ | tad-alex.md 路径已确认 |
| Data Flow Mapped | ✅ | Alex 填 frontmatter → Gate 4 逐条对照 AC |

**Expert Review**: code-reviewer CONDITIONAL PASS (2 P0 fixed: step4 type change clarified, knowledge_assessment replace-vs-append clarified)

**Gate 2 结果**: ✅ PASS

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
强化 Alex SKILL.md 的设计端（handoff 必填字段）和验收端（Gate 4 逐条对照 + Knowledge Assessment 强制）。

### 1.2 Why We're Building It
**根因**：质量链审计发现 Alex 两端都有缺口：
- **设计端**：handoff 没有强制填写 task_type/e2e_required/research_required，导致 Blake 和 Hook 无法判断该检查什么
- **验收端**：Gate 4 只看"Gate 3 Passed"就放过，不逐条对照 AC，不检查 evidence 是否存在

### 1.3 Intent Statement

**真正要解决的问题**：Alex 设计时不明确质量要求，验收时不认真检查，质量链首尾两端都失守。

**不是要做的**：
- ❌ 不是修改 Blake SKILL.md — 那是 Phase 2（并行进行中）
- ❌ 不是修改 Hook 脚本 — 那是 Phase 4
- ❌ 不是重写 Alex 的 Socratic Inquiry 或 Design 流程 — 只在现有流程中插入强制检查点

---

## 📚 Project Knowledge（Blake 必读）

| 文件 | 关键提醒 |
|------|----------|
| architecture.md | "Cognitive Firewall: Embed Into Existing Flows" — 新规则嵌入现有流程，不创建新命令 |
| architecture.md | "Gate Responsibility Matrix" — Gate 4 是业务验收，但必须检查 evidence 存在性 |

---

## 2. Background Context

### 2.1 Current Alex SKILL.md 缺口

**设计端（handoff_creation_protocol）**：
- step1 Draft Creation 没有提醒填写 YAML frontmatter
- 没有检查 task_type/e2e_required/research_required 是否已填

**验收端（acceptance_protocol + gate4_v2_checklist）**：
- step4 "验证实现是否符合 handoff 原始需求" — 只有一句话描述，没有具体步骤
- 没有要求逐条对照 AC
- 没有要求检查 Blake 的 Evidence Checklist 是否完整
- Knowledge Assessment 在 config-quality.yaml 标记 MANDATORY 但 Alex SKILL.md 没有强制执行步骤

---

## 3. Requirements

### 3.1 Functional Requirements

**FR1: handoff_creation_protocol step1 追加 frontmatter 强制**

在 `handoff_creation_protocol` 的 `step1` (Draft Creation) 的 `content:` 列表中追加：

```yaml
      - "YAML frontmatter (MANDATORY — task_type, e2e_required, research_required must be filled)"
```

并在 step1 之后、step2 之前新增 step1b：

```yaml
    step1b:
      name: "Frontmatter Validation"
      action: "验证 handoff 草稿的 YAML frontmatter 三个字段都已填写且值合法"
      validation:
        task_type: "must be one of: code, yaml, research, e2e, mixed"
        e2e_required: "must be yes or no"
        research_required: "must be yes or no"
      violation: "frontmatter 字段缺失或值非法 = VIOLATION — 不能继续 step2"
```

**FR2: acceptance_protocol 强化 — 逐条 AC 对照 + Evidence 检查**

替换现有 `acceptance_protocol` 的 step4（当前是一行字符串 `"【业务检查】验证实现是否符合 handoff 原始需求"`）为 mapping 格式。注意：acceptance_protocol 中 step1-step9 混用了字符串和 mapping 两种格式，这在现有文件中已有先例（如 accept_command 的 steps 就是 mapping）。只替换 step4，其余步骤格式不变：

```yaml
  step4:
    action: "【业务检查 — 逐条 AC 对照】"
    details: |
      1. 读取 handoff 的 Acceptance Criteria section
      2. 读取 Blake 的 completion report
      3. 逐条对照每个 AC：
         - AC 是否在 completion report 中标记完成？
         - AC 的验证方法是否有对应 evidence？
         - 如果 AC 标记未完成 → 记录为"未满足"
      4. 输出对照表：
         | AC# | 要求 | Blake 报告状态 | Evidence 存在 | Alex 判定 |
         |-----|------|---------------|--------------|----------|
      5. 如有任何 AC 未满足 → 不通过，退回 Blake
    # ⚠️ ANTI-RATIONALIZATION: "仔细审查了 completion report，功能看起来完全符合"
    # → "看起来符合"≠实际验证。必须输出逐条对照表。
```

**FR3: acceptance_protocol 新增 Evidence 完整性检查步骤**

在 step4 之后新增 step4b：

```yaml
  step4b:
    action: "【Evidence 完整性检查】"
    details: |
      1. 读取 completion report 的 Evidence Checklist 节
      2. 检查 required 项是否全部勾选
      3. 读取 handoff YAML frontmatter:
         - 如果 e2e_required: yes → 确认 E2E evidence 路径存在
         - 如果 research_required: yes → 确认研究文件路径存在
      4. 如有 required evidence 缺失 → 不通过，退回 Blake
    blocking: true
```

**FR4: gate4_v2_checklist 强化 Knowledge Assessment**

**替换**现有 `gate4_v2_checklist` 的 `knowledge_assessment` 列表（当前 2 条：`"是否有新发现？(Yes/No)"` 和 `"如果有，记录到 .tad/project-knowledge/"`）为以下 3 条：

```yaml
    knowledge_assessment:
      - "是否有新发现？(Yes/No) — 必须明确回答"
      - "如果有，确认已写入 .tad/project-knowledge/{category}.md"
      - "如果没有，确认原因合理（不能只写 N/A）"
      # ⚠️ ANTI-RATIONALIZATION: "常规 CRUD，没有新发现，Knowledge Assessment 是浪费"
      # → 即使无新发现也必须显式写 "No" + 原因。跳过 = 表格不完整 = Gate 无效。
```

**FR5: accept_command step0_git_check 之后追加 Evidence 检查**

在 `accept_command` 的 `step0_git_check` 之后、`step1` 之前新增：

```yaml
    step0b_evidence_check:
      action: "Evidence 完整性 — 确认 Gate 4 step4b 已执行"
      details: |
        This is a safety net — step4b should have already caught missing evidence.
        Quick re-check: read completion report Evidence Checklist, confirm all required items checked.
        If any required unchecked → BLOCK with "Evidence incomplete, cannot archive."
      blocking: true
```

### 3.2 Non-Functional Requirements
- NFR1: 插入位置使用内容锚点（节名/步骤名），不用行号
- NFR2: 新增的 anti-rationalization 注释与现有格式一致
- NFR3: 不修改 Socratic Inquiry 或 Design 流程 — 只在 handoff creation 和 acceptance 中插入

---

## 7. File Structure

### 7.1 Files to Modify
```
.claude/commands/tad-alex.md  # handoff_creation_protocol + acceptance_protocol + gate4_v2_checklist + accept_command
```

---

## 9. Acceptance Criteria

- [ ] **AC1**: handoff_creation_protocol step1 content 列表含 YAML frontmatter 条目
- [ ] **AC2**: handoff_creation_protocol 有 step1b Frontmatter Validation（三字段验证）
- [ ] **AC3**: acceptance_protocol step4 有逐条 AC 对照表输出要求
- [ ] **AC4**: acceptance_protocol 有 step4b Evidence 完整性检查
- [ ] **AC5**: gate4_v2_checklist knowledge_assessment 有具体执行步骤 + anti-rationalization 注释
- [ ] **AC6**: accept_command 有 step0b_evidence_check
- [ ] **AC7**: 现有 YAML 结构不被破坏（新增步骤不影响已有步骤编号和内容）
- [ ] **AC8 (BLOCKING)**: 必须走 Ralph Loop + Gate 3

### 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Method | Expected Evidence |
|---|---------------------|--------------------|--------------------|
| 1 | frontmatter 在 step1 | `grep 'frontmatter' .claude/commands/tad-alex.md` | 3+ matches (step1 + step1b + step4b) |
| 2 | step1b 存在 | `grep 'step1b' .claude/commands/tad-alex.md` | 1+ matches in handoff_creation_protocol |
| 3 | 逐条 AC 对照 | `grep '逐条.*AC' .claude/commands/tad-alex.md` | 1+ matches |
| 4 | step4b Evidence | `grep 'step4b' .claude/commands/tad-alex.md` | 1+ matches in acceptance_protocol |
| 5 | Knowledge Assessment 强化 | `grep 'ANTI-RATIONALIZATION.*Knowledge' .claude/commands/tad-alex.md` | 1+ matches |
| 6 | step0b_evidence_check | `grep 'step0b' .claude/commands/tad-alex.md` | 1+ matches |

---

## 10. Important Notes

- ⚠️ 与 Phase 2 (Blake SKILL.md) 并行开发 — 无文件冲突（Phase 2 改 tad-blake.md，Phase 3 改 tad-alex.md）
- ⚠️ tad-alex.md 文件较大，Blake 需分段读取确认插入位置
- ⚠️ FR2 的 step4 是**替换**现有 step4 内容，不是追加。现有 step4 只有一句话，新版有完整流程
- ⚠️ FR5 的 step0b 是 safety net — 与 step4b 有冗余，这是有意的（冗余=安全）

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-03
**Version**: 3.1.0
