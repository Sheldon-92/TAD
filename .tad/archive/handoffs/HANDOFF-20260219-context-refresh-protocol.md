# Handoff: Context Refresh Protocol — Long Session Knowledge Retention

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-02-19
**Project:** TAD Framework
**Priority:** P1
**Scope:** Add 2 mandatory Re-read steps at the most critical workflow nodes + 1 template enhancement

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-02-19

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 2 core nodes identified: handoff creation (Alex) + develop start (Blake) |
| Components Specified | ✅ | Insertion points verified against actual YAML structure |
| Functions Verified | ✅ | All referenced sections exist in current files |
| Data Flow Mapped | ✅ | Read targets matched to task types |

**Gate 2 结果**: ✅ PASS

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」章节
- [ ] 每个修改点的位置和内容都清楚
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
在 TAD 工作流的 **2 个最关键节点** 添加强制 Re-read 步骤，确保长 session 中不会因 context compression 而丢失 project knowledge。

### 1.2 Why We're Building It
**问题**：Claude Code 在长 session 中会压缩早期加载的内容，导致 project-knowledge（踩坑记录）和协议规则被摘要化。
**解决**：在信息最关键的 2 个时刻强制重新 Read。

### 1.3 为什么只做 2 个节点

| 节点 | 为什么关键 |
|------|-----------|
| Alex 写 handoff 前 | Handoff 是 Blake 的唯一信息来源，如果 Alex 忘了历史教训，Blake 永远不会知道 |
| Blake 开始实现前 | 即使 handoff 里有 project knowledge，长 session 中 Blake 读 handoff 的内容也会被压缩 |

其他节点（design、gate 3、completion 等）有帮助但不致命，后续可按需添加。

---

## 📚 Project Knowledge

| 文件 | 关键提醒 |
|------|----------|
| architecture.md | "Embed Into Existing Flows, Don't Create New Ones" |

---

## 2. Technical Design

### Node Map (Minimal Viable)

```
Alex 侧 (tad-alex.md):
└── handoff_creation_protocol step0_5 (NEW)
    → Read ALL .tad/project-knowledge/*.md
    → Read handoff protocol key rules + template

Blake 侧 (tad-blake.md):
└── develop_command 1_5_context_refresh (NEW)
    → Re-read handoff document
    → Read matched .tad/project-knowledge/*.md

Handoff 模板 (handoff-a-to-b.md):
└── 📚 Project Knowledge section (STRENGTHEN)
    → Add MANDATORY READ instruction for Blake
```

### Design Principle

**"Refresh, not Reload"** — 只读相关内容，不重新加载整个协议文件。

---

## 3. Implementation Steps

### Task 1: Alex — handoff_creation_protocol 添加 step0_5

**File**: `.claude/commands/tad-alex.md`
**Location**: `handoff_creation_protocol.workflow` section, AFTER `step0` (Prerequisite Check, line ~1306) and BEFORE `step1` (Draft Creation, line ~1308)

**⚠️ YAML structure**: This section uses NESTED format (`step0: { name, action }`). Match exactly.

**Insert new step**:

```yaml
    step0_5:
      name: "Context Refresh — Full Knowledge Reload"
      action: |
        Before writing handoff draft, reload ALL project knowledge to ensure
        no historical lessons are missed in the handoff.

        1. Read ALL files in .tad/project-knowledge/*.md (excluding README.md)
        2. Read handoff_creation_protocol key rules from THIS file:
           - expert_selection_rules (which experts to call)
           - minimum_experts: 2
           - step7 STOP rule (must generate Blake message, must not call /blake)
        3. Read the handoff template: .tad/templates/handoff-a-to-b.md
           (to ensure template structure is fresh in context)
        4. Brief output: "📖 Full knowledge refreshed: {N} knowledge files + handoff protocol + template"
      blocking: false
      purpose: "Last line of defense — all known pitfalls must be in context when writing handoff"
```

### Task 2: Blake — *develop 开始前添加 Context Refresh

**File**: `.claude/commands/tad-blake.md`
**Location**: `ralph_loop_execution.develop_command.steps` section, AFTER `1_init` (ends ~line 401) and BEFORE `2_layer1_loop` (line ~403)

**⚠️ YAML structure**: This section uses NESTED format matching `1_init`, `2_layer1_loop`. Use 6-space indentation for the step key, 8-space for sub-keys.

**Insert new step**:

```yaml
      1_5_context_refresh:
        description: "Context Refresh before implementation start"
        action: |
          Before starting implementation, re-read critical context:

          1. Re-read the selected handoff document (full content)
          2. Read the handoff's "📚 Project Knowledge" section to identify relevant files
          3. Read matched .tad/project-knowledge/*.md files
          4. If handoff has no Project Knowledge section, read architecture.md + code-quality.md as defaults
          5. Brief output: "📖 Implementation context refreshed: {files read}"
        purpose: "Ensure handoff context and project knowledge are fresh before coding"
```

### Task 3: Handoff Template — Strengthen Blake Read Reminder

**File**: `.tad/templates/handoff-a-to-b.md`
**Location**: `📚 Project Knowledge（Blake 必读）` section, insert AFTER line 83 (`**Alex 在创建 handoff 时必须完成以下步骤：**`) and BEFORE `### 步骤 1` (line 85)

**Insert**:

```markdown

**⚠️ MANDATORY READ — Blake 在开始实现前，必须执行以下 Read 操作：**
1. Read ALL `.tad/project-knowledge/*.md` files listed in 步骤 2 below
2. Read the handoff's "⚠️ Blake 必须注意的历史教训" entries carefully
3. This is NOT optional — project knowledge prevents repeated mistakes

> **Why**: In long sessions, project knowledge loaded at startup gets compressed.
> Reading it again here ensures Blake has full awareness before coding.

```

---

## 4. Files to Modify

| File | Action | Insertion Point |
|------|--------|----------------|
| `.claude/commands/tad-alex.md` | Insert 1 new step (step0_5) | handoff_creation_protocol, after step0 (~line 1306) |
| `.claude/commands/tad-blake.md` | Insert 1 new step (1_5_context_refresh) | develop_command.steps, after 1_init (~line 401) |
| `.tad/templates/handoff-a-to-b.md` | Add MANDATORY READ text | Project Knowledge section (~line 83) |

**Total**: 3 files, 3 changes

---

## 5. Acceptance Criteria

- [ ] AC1: tad-alex.md handoff_creation_protocol has step0_5 that reads ALL knowledge files + protocol rules + template
- [ ] AC2: tad-blake.md has 1_5_context_refresh between 1_init and 2_layer1_loop that reads handoff + knowledge
- [ ] AC3: handoff-a-to-b.md has MANDATORY READ instruction in Project Knowledge section
- [ ] AC4: New steps match surrounding YAML indentation and structure exactly
- [ ] AC5: No existing steps are modified or reordered — only pure insertions
- [ ] AC6: Both new steps have `purpose` field

---

## 6. Testing Checklist

- [ ] YAML syntax valid after insertions (no indentation errors)
- [ ] No existing step numbers or names changed
- [ ] Grep for "Context Refresh\|step0_5\|1_5_context_refresh\|MANDATORY READ" confirms all 3 changes
- [ ] Handoff template still renders correctly (markdown preview)

---

## 7. Important Notes

- ⚠️ tad-alex.md handoff_creation_protocol uses NESTED YAML (`step0: { name, action }`)
- ⚠️ tad-blake.md develop_command.steps uses NESTED YAML (`1_init: [list]`, `2_layer1_loop: { description, ... }`)
- ⚠️ Do NOT renumber existing steps — use fractional names (step0_5, 1_5)
- 💡 Future expansion: if needed, add refresh at *design (Alex), Layer 2 (Blake), Gate 3 (Blake)

---

## Expert Review Status

| Expert | Status | Key Findings |
|--------|--------|-------------|
| code-reviewer | ✅ CONDITIONAL PASS → P0 Fixed | YAML structure verification, flat vs nested format distinction |
| backend-architect | ✅ CONDITIONAL PASS → P0 Fixed | Added *develop START refresh, multi-category mapping |

*Expert review was conducted on the full 9-node version. This trimmed version retains the 2 nodes that both experts agreed were most critical, with all P0 fixes applied.*

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-02-19
**Status**: Expert Review Complete — Ready for Implementation
