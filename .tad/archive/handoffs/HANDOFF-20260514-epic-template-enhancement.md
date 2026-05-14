# Handoff: Epic Template Enhancement

**From:** Alex | **To:** Blake | **Date:** 2026-05-14
**Priority:** P1
**Type:** Protocol Enhancement
**Epic:** EPIC-20260514-yolo-mode.md (Phase 1/3)

---
task_type: yaml
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs:
  - .tad/templates/
  - .claude/skills/alex/
---

## 1. Executive Summary

增强 Epic 模板，让每个 Phase 有完整定义（Scope / Input / Output / AC / Files / Dependencies），而不是现在的一行表格。同时更新 Alex SKILL.md 的 Epic 创建和 Phase 执行逻辑，使 Alex 在开始任何 Phase 时能直接从 Epic 获取足够信息开始设计，减少重复的苏格拉底提问。这是手动模式和未来 YOLO 模式共同的基础设施。

## 2. Background

### 现状问题

现有 epic-template.md 的 Phase 定义只有一行表格：

```
| 1 | {phase_name} | ⬚ Planned | — | {what it delivers} |
```

Alex 开始每个 Phase 时必须重新做完整苏格拉底提问来搞清 scope、AC、文件范围。在手动模式下浪费时间，在未来 YOLO 模式下更是不可行（没人可以问）。

### 目标

让 Epic 模板的每个 Phase 自包含——包含足够信息让 Alex 跳过或大幅减少 Phase 级别的苏格拉底提问。

## 3. Technical Design

### 3.1 epic-template.md 增强

**当前结构（保留）：**
- Objective, Success Criteria, Phase Map 表格, Derived Status, Context for Next Phase, Notes

**新增：Phase Map 表格下方的 Phase Detail Blocks**

每个 Phase 从一行表格变成表格行 + 详细 block。表格保留作为 overview（快速看全局进度），detail block 是设计输入。

新增的 Phase Detail Block 模板：

```markdown
### Phase {N}: {name}

**Status:** ⬚ Planned
**Execution:** pending（Epic 确认时填 manual / yolo）

#### Scope
{2-3 句话：这个 Phase 做什么。明确不做什么。}

#### Input
{这个 Phase 开始时可用的东西：前序 Phase 产出、现有代码/系统}

#### Output
{这个 Phase 完成后交付什么：新文件、新能力、用户可见变化}

#### Acceptance Criteria
- [ ] {具体、可验证的条件}

#### Files Likely Affected
- {path/to/file} (CREATE / MODIFY)
{这是预估——Alex 设计时可能增减}

#### Dependencies
{依赖哪个 Phase，或"无（可独立执行）"}

#### Notes
{任何需要注意的事项、已知风险、讨论中的决策}
```

**保留 Phase Map 表格**作为全局 overview（1 行/Phase），detail block 在表格下方展开。表格的 Key Deliverable 列保留，作为 detail block Output 的一句话摘要。

### 3.2 Alex SKILL.md — step2b Epic 创建增强

**现有逻辑（line 1991-1994）：**
```
If user chooses "创建 Epic":
  1. Create Epic file: .tad/active/epics/EPIC-{YYYYMMDD}-{slug}.md
     - Use .tad/templates/epic-template.md as base
     - Fill Objective, Success Criteria, Phase Map
  2. Then create first Phase's Handoff (linked to Epic)
```

**改为：**
```
If user chooses "创建 Epic":
  1. Create Epic file using enhanced template
  2. Fill Objective, Success Criteria, Phase Map TABLE (overview)
  3. For EACH Phase: fill the Phase Detail Block
     - Scope: from Socratic discussion context
     - Input/Output: derive from phase sequencing
     - AC: at least 3 per Phase, specific and verifiable
     - Files Likely Affected: derive from scope + codebase knowledge
     - Dependencies: derive from phase ordering
  4. AskUserQuestion: 确认 Epic + Phase 定义
     选项:
       - "确认，开始 Phase 1（我来传递）" → 手动模式，创建 Phase 1 handoff
       - "确认，开始 Phase 1（你自己跑）" → YOLO 模式（Phase 2 of this Epic 实现）
       - "需要调整" → 用户修改后重新确认
  5. After confirmation: create first Phase's Handoff (linked to Epic)
```

**关键变化：step2b 不再只填表格，而是填完整的 Phase Detail Block。苏格拉底提问的重心从"每个 Phase 开始时问"前移到"Epic 创建时一次性问清"。**

### 3.3 Alex SKILL.md — Phase 执行时读取 Phase Detail

**现有逻辑（epic_linkage, line 2738-2747）：**
```
If an active Epic exists:
  1. Read the Epic's Phase Map to find the next ⬚ Planned phase
  2. Add **Epic** metadata field to handoff header
  3. Update Phase Map: set to 🔄 Active
```

**增加一步（在第 1 步之后）：**
```
  1. Read the Epic's Phase Map to find the next ⬚ Planned phase
  1b. Read the Phase Detail Block for this Phase:
      - Extract Scope → use as task description for Socratic/design
      - Extract AC → pre-fill handoff AC section
      - Extract Files Likely Affected → pre-fill handoff §6
      - Extract Input/Output → inform design context
      Sufficiency check (ALL must pass to reduce Socratic):
        - Scope: ≥2 sentences (not placeholder like "TBD")
        - AC: ≥3 items, each contains a verification method or measurable condition
        - Files: ≥1 concrete path with CREATE/MODIFY annotation (not "TBD")
      If ALL pass:
        → Reduce Socratic to 1-2 confirmation questions (not full 3-5 rounds)
        → Announce: "Phase {N} 定义足够详细，跳过完整提问，直接开始设计。"
      If ANY fail:
        → Run normal Socratic inquiry for this Phase
        → Announce: "Phase {N} 定义不够详细（{which check failed}），需要补充提问。"
  2. Add **Epic** metadata field...
```

### 3.4 *accept step2b_epic_update 增强

**现有逻辑（line 3971-3996）更新 Phase Map 和 Context for Next Phase。**

**增加：** 更新当前 Phase Detail Block status 为 ✅ Done，并填充实际产出信息。

```
  After updating Phase Map table:
  Also update the Phase Detail Block:
    - Status: ⬚ Planned → ✅ Done
    - Append under Notes: "Completed: {date}, Handoff: {filename}, Commit: {hash}"
```

## 4. Decision Summary

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | Phase Map 表格保留 | 表格是快速 overview，detail block 是设计输入。两者共存。 |
| 2 | Phase Detail Block 放在表格下方 | 不放在表格内（表格行太窄），也不放在独立文件（一个 Epic 一个文件更好管理） |
| 3 | Execution 字段用 pending | 创建时不决定执行模式。Epic 确认时用户选。Phase 2 of this Epic 实现 YOLO 选项。 |
| 4 | 向后兼容 | 旧 Epic 没有 detail block → Alex 正常做苏格拉底提问（和现在一样） |

## 5. Files to Modify / Create

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `.tad/templates/epic-template.md` | MODIFY | 增加 Phase Detail Block 模板 |
| 2 | `.claude/skills/alex/SKILL.md` | MODIFY | step2b Epic 创建 + epic_linkage Phase 读取 + *accept 更新逻辑 |

**Grounded Against** (Alex step1c):
- `.tad/templates/epic-template.md` (全文 56 行, read at 2026-05-14)
- `.claude/skills/alex/SKILL.md` lines 1965-2004 (step2b Epic Assessment, read at 2026-05-14)
- `.claude/skills/alex/SKILL.md` lines 2738-2747 (epic_linkage, read at 2026-05-14)
- `.claude/skills/alex/SKILL.md` lines 3971-3996 (step2b_epic_update in *accept, read at 2026-05-14)

## 6. Acceptance Criteria

- [ ] AC1: epic-template.md 包含 Phase Detail Block 模板（Scope / Input / Output / AC / Files / Dependencies / Notes）
- [ ] AC2: epic-template.md 保留 Phase Map 表格（向后兼容）
- [ ] AC3: Alex SKILL step2b 在创建 Epic 时填充 Phase Detail Block（不只是表格行）
- [ ] AC4: Alex SKILL epic_linkage 在开始 Phase 时读取 Detail Block 并用作设计输入
- [ ] AC5: Alex SKILL epic_linkage 当 Detail Block 足够详细时减少苏格拉底提问
- [ ] AC6: Alex SKILL *accept step2b_epic_update 更新 Phase Detail Block status
- [ ] AC7: Phase Detail Block 包含 Execution 字段（值为 pending / manual / yolo）
- [ ] AC8: 旧 Epic 无 detail block 时 Alex 行为与现在完全一致（向后兼容）

## 7. Implementation Notes for Blake

### P1: epic-template.md
- 现有模板 56 行。在 Phase Map 表格和 "Context for Next Phase" 之间插入 Phase Detail Block 模板
- 保留所有现有内容不变
- Phase Detail Block 用 `### Phase {N}: {name}` heading（三级标题，比 Phase Map 的二级低一级）
- Execution 字段默认值 `pending`
- 模板里放 2 个 Phase 作为示例（Phase 1 和 Phase 2）

### P2: Alex SKILL.md — step2b
- 位置：line 1991-1996，在 "If user chooses 创建 Epic" 块内
- 现在只有 "Fill Objective, Success Criteria, Phase Map"
- 改为：填 Phase Map 表格 + 为每个 Phase 填 Detail Block
- AskUserQuestion 确认 Epic 时加 "执行模式" 选项（但 YOLO 选项在 Phase 2 实现前标记为 coming soon 或不显示）

### P3: Alex SKILL.md — epic_linkage
- 位置：line 2738-2747，在 handoff_creation_protocol step1 的 epic_linkage 块内
- 在 "Read the Epic's Phase Map to find the next ⬚ Planned phase" 之后加一步
- 读 Phase Detail Block → 提取 Scope/AC/Files → pre-fill handoff
- 条件判断：if block has Scope + ≥3 ACs + Files → 减少 Socratic

### P4: Alex SKILL.md — *accept step2b_epic_update
- 位置：line 3971-3996，在 accept_command 的 step2b_epic_update 块内
- Phase Map 更新逻辑不变
- 增加：更新 Phase Detail Block 的 Status + 在 Notes 下追加完成信息

## 8. Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/epic-template-enhancement/code-reviewer.md
completion:
  - .tad/active/handoffs/COMPLETION-20260514-epic-template-enhancement.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md (if new discovery)
```

## 9. Important Notes

### 9.1 Phase 2 的 YOLO 选项暂不实现
step2b 的 AskUserQuestion 加执行模式选项时，YOLO 选项要么不显示，要么显示为 "(coming soon — Phase 2)"。Phase 1 只是模板 + 读取基础设施。

### 9.2 不改现有 Epic 文件
5 个 active Epic 用旧格式不需要迁移。向后兼容通过"如果没有 detail block → 正常苏格拉底提问"实现。
