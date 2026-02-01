# Handoff: Epic/Roadmap 多阶段任务追踪机制

**Task ID**: TASK-20260201-001
**Created**: 2026-02-01
**Author**: Alex (Solution Lead)
**Priority**: P1
**Complexity**: Medium-Large (Standard TAD)
**Status**: Ready for Implementation

---

## Expert Review Status

| Expert | Verdict | P0 Issues | P1 Issues |
|--------|---------|-----------|-----------|
| code-reviewer | CONDITIONAL PASS → RESOLVED | 3 (fixed) | 4 (fixed) |
| backend-architect | CONDITIONAL PASS → RESOLVED | 2 (fixed) | 3 (fixed) |

All P0 issues have been integrated into this final version.

---

## Executive Summary

为 TAD 框架新增 Epic 层级，解决多阶段任务的上下文断裂问题。Epic 是 handoff 之上的容器，追踪一个大任务从拆分到全部完成的完整生命周期。Alex 在评估复杂度时建议创建 Epic，每次 *accept 时更新 Epic 进度，所有阶段完成后归档。

## Background

**痛点**: 当一个大任务需要拆分为多个 handoff 分阶段执行时：
1. 跨阶段上下文丢失 — 不知道整体进度和下一步
2. 重复设计浪费 — 每次新阶段需要重新解释背景
3. 缺少全局视图 — NEXT.md 是扁平列表，无法表达阶段依赖关系

**现状**: TAD 只有 handoff（原子级）和 NEXT.md（扁平列表），缺少中间层。

**目标**: 新增 Epic 文档类型，自然融入现有 TAD 流程，不增加额外仪式感。

---

## Design

### 核心概念

```
Epic (EPIC-{date}-{name}.md)
  ├── Phase 1 → HANDOFF-{date}-{name}.md  ✅ Completed
  ├── Phase 2 → HANDOFF-{date}-{name}.md  🔄 Active
  ├── Phase 3 → (not yet created)          ⬚ Planned
  └── Phase 4 → (not yet created)          ⬚ Planned
```

- **Epic** = 多阶段大任务的容器，追踪整体进度
- **Phase** = Epic 中的一个阶段，对应 1 个或多个 handoff
- **Handoff** = 不变，仍是 Blake 的执行单元

**关键约束**: 同一时间只能有 1 个 Phase 处于 🔄 Active 状态（顺序执行）。

### 文件位置

```
.tad/active/epics/EPIC-{date}-{name}.md    # 进行中
.tad/archive/epics/EPIC-{date}-{name}.md   # 已完成
```

### Epic 文档结构

```markdown
# Epic: {title}

**Epic ID**: EPIC-{YYYYMMDD}-{slug}
**Created**: {date}
**Owner**: Alex

---

## Objective
{1-3 sentences: what this epic delivers when all phases complete}

## Success Criteria
- [ ] {measurable outcome 1}
- [ ] {measurable outcome 2}

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | {phase_name} | ✅ Done | HANDOFF-{date}-{name}.md | {what it delivers} |
| 2 | {phase_name} | 🔄 Active | HANDOFF-{date}-{name}.md | {what it delivers} |
| 3 | {phase_name} | ⬚ Planned | — | {what it delivers} |
| 4 | {phase_name} | ⬚ Planned | — | {what it delivers} |

### Phase Dependencies
{optional: which phases depend on which, or "All phases are sequential"}

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Context for Next Phase
{Alex updates this section after each *accept, providing context
so the next phase can start without re-explaining everything}

### Completed Work Summary
- Phase 1: {1-line summary of what was done}
- Phase 2: {1-line summary}

### Decisions Made So Far
- {key decision 1 and rationale}
- {key decision 2 and rationale}

### Known Issues / Carry-forward
- {issue or learning from previous phases that affects upcoming work}

### Next Phase Scope
{brief description of what the next phase should cover}

---

## Notes
{any observations, pivots, or adjustments during the epic}
```

**注意**: Epic 文档中不再有独立的 `Status` 和 `Overall Progress` 头部字段。这两个值从 Phase Map 动态派生（P1 fix: 避免状态不一致）。

### 流程集成点

#### 1. 触发时机（Adaptive Complexity 扩展）

Alex 在评估任务复杂度时，如果判断任务需要**多个阶段**（>1 个 handoff），建议创建 Epic。

```
用户描述任务
     ↓
Alex 评估复杂度 (Adaptive Complexity)
     ↓
如果判断需要多阶段:
  → AskUserQuestion: "这个任务预计需要多个阶段，建议创建 Epic Roadmap"
  → 选项: "创建 Epic" / "直接用单个 Handoff"
     ↓
用户选 "创建 Epic":
  → Alex 先写 Epic（整体规划 + Phase Map）
  → 然后写第一个 Phase 的 Handoff（关联 Epic）
  → Handoff 中添加 `Epic: EPIC-{date}-{name}.md` 元数据
```

**评估信号**（Alex 内部判断是否需要多阶段）：
- 用户描述中包含"先...再...然后..."等分步语言
- 任务涉及 3+ 个独立的功能模块
- 预计需要中间测试/验证才能继续
- 涉及渐进式迁移或重构

#### 2. Handoff 关联

每个属于 Epic 的 handoff 在头部添加 `Epic` 字段：

```markdown
**Epic**: EPIC-20260201-auth-system.md (Phase 2/4)
```

Handoff 模板（handoff-a-to-b.md）需添加可选的 `Epic` 元数据字段。

#### 3. *accept 时更新 Epic（Alex 负责）

**⚠️ P0 fix: Epic 更新在 handoff 归档之后执行（step2b），而非之前。**
**这确保 handoff 和 completion report 已安全归档后，才修改 Epic 状态。**

```
Alex 执行 *accept（验收通过）
     ↓
step1: 归档 handoff → .tad/archive/handoffs/
step2: 归档 completion report → .tad/archive/handoffs/
     ↓
step2b: Epic 状态更新（新增）
  检查: 这个 handoff 是否关联了 Epic？（读取头部 Epic 字段）
     ↓
  如果关联了 Epic:
    1. 读取 Epic 文件
    2. 验证 Epic 文件存在且格式正确（错误处理：见下方）
    3. 更新 Phase Map: 当前阶段标记 ✅ Done，填入 handoff 链接
    4. 更新 "Context for Next Phase" section
    5. 验证: 同一时间最多 1 个 Active phase（并发控制）
    6. 如果所有阶段完成（从 Phase Map 派生）:
       → 标记 Epic 为 Complete（所有 Phase 为 ✅）
       → 移至 .tad/archive/epics/
    7. 如果还有后续阶段:
       → AskUserQuestion: "Phase {N} 完成。准备开始 Phase {N+1} 吗？"
       → 用户选"是" → Alex 开始下一阶段的设计
       → 用户选"稍后" → 提醒记录在 NEXT.md
     ↓
step3: 更新 PROJECT_CONTEXT.md
step4: 更新 NEXT.md
...（其余 *accept 步骤不变）
```

#### 4. 并发控制（P0 fix）

```yaml
sequential_constraint:
  rule: "同一 Epic 内，同一时间只能有 1 个 Phase 处于 🔄 Active 状态"
  enforcement:
    - "Alex 在 *accept 更新 Phase Map 时，先检查是否有其他 Active phase"
    - "如果有 → 报错，不允许激活新 phase"
    - "Alex 在创建新 phase 的 handoff 时，自动将新 phase 标记为 Active"
  exception: "用户可手动编辑 Epic 文件覆盖此约束（自行承担风险）"
```

#### 5. 错误处理与恢复（P0 fix）

```yaml
error_handling:
  epic_file_missing:
    trigger: "Handoff 引用的 Epic 文件不存在（active 或 archive 中都找不到）"
    action: "WARNING 日志，继续 *accept 流程（不阻塞归档），提醒用户手动检查"

  epic_format_invalid:
    trigger: "Epic 文件存在但 Phase Map 表格格式异常"
    action: "WARNING 日志，跳过自动更新，提醒用户手动修复 Epic"

  handoff_ref_mismatch:
    trigger: "Handoff 头部 Epic 字段引用的 phase 编号与 Epic Phase Map 不匹配"
    action: "WARNING 日志，提示用户确认正确的 phase 编号"

  concurrent_active_violation:
    trigger: "尝试激活新 phase 时发现已有另一个 Active phase"
    action: "BLOCK - 不允许激活新 phase，要求先完成当前 Active phase"

  recovery_principle: "Epic 更新失败不应阻塞 handoff 归档。Handoff 是原子操作，Epic 是后续更新。"
```

#### 6. 阶段动态调整（P1 fix）

```yaml
phase_adjustment:
  add_phase:
    trigger: "开发过程中发现需要额外阶段"
    action: "Alex 在 Epic Phase Map 末尾追加新行，Status 为 ⬚ Planned"
    note: "不需要用户确认，但 Alex 应在 Notes 中记录原因"

  remove_phase:
    trigger: "发现某个 Planned 阶段不再需要"
    action: "从 Phase Map 中删除该行（仅限 ⬚ Planned 状态），Notes 中记录原因"
    constraint: "不可删除 ✅ Done 或 🔄 Active 的阶段"

  reorder_phase:
    trigger: "需要调整 Planned 阶段的执行顺序"
    action: "重新排列 Phase Map 中 ⬚ Planned 行的编号"
    constraint: "不可移动 ✅ Done 或 🔄 Active 的阶段"
```

#### 7. 健康检查集成（/tad-maintain）

```yaml
# CHECK mode 新增 - 6 种检查类型
epics_check:
  STALE:
    description: "所有关联 handoff 已完成但 Epic 未归档"
    detection: "Phase Map 中所有 phase 为 ✅ Done，但文件仍在 active/epics/"
    action: "SYNC/FULL 模式下自动归档"

  ORPHAN:
    description: "无关联 handoff 且超过 stale_age_days"
    detection: "Epic 创建超过 stale_age_days 天，Phase Map 中无任何 handoff 链接"
    action: "FULL 模式下通过 AskUserQuestion 让用户决定"

  DANGLING_REF:
    description: "Phase Map 引用了不存在的 handoff 文件"
    detection: "Phase Map 中的 handoff 路径在 active/ 和 archive/ 中都不存在"
    action: "报告 WARNING，不自动修复"

  BACK_REF_MISMATCH:
    description: "Handoff 引用了 Epic，但 Epic Phase Map 中无对应条目"
    detection: "Handoff 头部有 Epic 字段，但 Epic Phase Map 中该 handoff 未列出"
    action: "报告 WARNING，不自动修复"

  STUCK:
    description: "某个 Phase 处于 Active 状态超过 stale_age_days"
    detection: "Phase Map 中有 🔄 Active phase，且关联 handoff 创建超过 stale_age_days"
    action: "报告 WARNING，提醒用户关注"

  OVER_ACTIVE:
    description: "同一 Epic 中有多个 Active phase（违反并发控制）"
    detection: "Phase Map 中 🔄 Active 计数 > 1"
    action: "报告 ERROR，提醒用户修复"
```

---

## Task Breakdown

### Task 1: Create Epic template
**File to CREATE**: `.tad/templates/epic-template.md`
**Description**: 基于上方设计的 Epic 文档结构创建模板。注意：不包含独立的 Status/Overall Progress 头部字段（这两个值从 Phase Map 派生）。
**Verification**: 模板包含所有必要 section（Objective, Success Criteria, Phase Map with Derived Status, Context for Next Phase, Notes）

### Task 2: Create directory structure
**Files to CREATE**:
- `.tad/active/epics/` (directory, with `.gitkeep`)
- `.tad/archive/epics/` (directory, with `.gitkeep`)
**Verification**: 目录存在且有 .gitkeep

### Task 3: Update Alex - Adaptive Complexity with Epic assessment
**File to MODIFY**: `.claude/commands/tad-alex.md`
**Section**: `adaptive_complexity_protocol`
**Changes**:
- 在 step2 (Suggest) 和 step3 (Proceed) 之间添加 step2b: Epic Assessment
- 添加 `epic_assessment_signals` 配置
- 当用户选择 Standard/Full TAD 且 Alex 判断需要多阶段时，额外问是否创建 Epic
**Verification**: Alex 在评估时能建议创建 Epic

### Task 4: Update Alex - *accept flow with Epic update
**File to MODIFY**: `.claude/commands/tad-alex.md`
**Section**: `accept_command.steps`
**Changes**:
- 在 step2（归档 completion report）**之后**添加 step2b_epic_update:
  - 读取 handoff 头部的 `Epic` 字段
  - 如果有关联 Epic → 验证文件存在 → 更新 Phase Map → 更新 Context
  - 并发检查: 确保最多 1 个 Active phase
  - 如果所有阶段完成 → 归档 Epic
  - 如果还有后续 → 提示开始下一阶段
  - 错误处理: Epic 更新失败不阻塞 handoff 归档
- 更新 acceptance_protocol 列表添加 Epic 检查步骤
**Verification**: *accept 时正确更新 Epic 进度，且在 handoff 归档之后执行

### Task 5: Update Alex - Handoff creation with Epic linkage
**File to MODIFY**: `.claude/commands/tad-alex.md`
**Section**: `handoff_creation_protocol.workflow.step1`
**Changes**:
- 如果当前存在 active Epic，handoff 头部自动添加 `Epic` 元数据字段
- 添加 Phase 编号
- 自动将对应 Phase 标记为 🔄 Active（并验证无其他 Active phase）
**Verification**: 新 handoff 自动关联 Epic

### Task 6: Update handoff template with optional Epic field
**File to MODIFY**: `.tad/templates/handoff-a-to-b.md`
**Changes**:
- 在头部元数据区域（`**Handoff Version**` 行之后）添加可选的 `**Epic**` 字段
- 格式: `**Epic**: EPIC-{date}-{name}.md (Phase {N}/{M})` 或 `N/A`
**Verification**: Handoff 模板包含 Epic 字段

### Task 7: Update config-workflow.yaml
**File to MODIFY**: `.tad/config-workflow.yaml`
**Changes**:
- 在 `document_management.structure.active` 中添加 `epics`
- 在 `document_management.structure.archive` 中添加 `epics`
- 添加 `epic_lifecycle` 配置节（类似 `handoff_lifecycle`）
- 配置: stale_age_days, max_active_epics, sequential_constraint
**Verification**: Epic 在配置中有完整的生命周期定义

### Task 8: Update config.yaml master index
**File to MODIFY**: `.tad/config.yaml`
**Changes**:
- 在 `config_modules.contains` 列表中确认 config-workflow 已列出
- 如需在 master index 中体现 Epic 存在，添加适当说明
**Verification**: 主配置索引反映 Epic 功能的存在

### Task 9: Update CLAUDE.md
**File to MODIFY**: `CLAUDE.md`
**Changes**:
- 在 Section 2 "TAD Framework 使用场景" 的 "Adaptive Complexity Assessment" 表格后添加 Epic 触发说明
- 在 Section 7 "文档维护规则" 中添加 Epic 相关维护条目
- 添加新的 Section 2.1 "Epic/Roadmap 规则" 描述 Epic 生命周期、并发控制、错误处理
**Verification**: CLAUDE.md 包含 Epic 使用规则，位置合理

### Task 10: Update tad-maintain for Epic health check
**File to MODIFY**: `.claude/commands/tad-maintain.md`
**Changes**:
- 在 CHECK mode 中添加 Epic 扫描（6 种检查类型）
- 在 SYNC mode 中添加 STALE Epic 自动归档
- 在 FULL mode 中添加 ORPHAN Epic 用户确认
- 健康报告中添加 EPICS section
**Verification**: /tad-maintain 能检测和报告 Epic 状态（6 种检查类型）

### Task 11: Update tad-help
**File to MODIFY**: `.claude/commands/tad-help.md`
**Changes**: 在帮助文档中添加 Epic 相关说明（概念、触发方式、命令）
**Verification**: /tad-help 展示 Epic 功能

---

## Files Summary

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `.tad/templates/epic-template.md` | CREATE | Epic 文档模板（派生状态） |
| 2 | `.tad/active/epics/` | CREATE DIR | Active epics 目录 |
| 3 | `.tad/archive/epics/` | CREATE DIR | Archived epics 目录 |
| 4 | `.claude/commands/tad-alex.md` | MODIFY | Epic 评估 + *accept step2b + handoff 关联 |
| 5 | `.tad/templates/handoff-a-to-b.md` | MODIFY | 添加可选 Epic 字段 |
| 6 | `.tad/config-workflow.yaml` | MODIFY | Epic 生命周期配置 |
| 7 | `.tad/config.yaml` | MODIFY | 主配置索引更新 |
| 8 | `CLAUDE.md` | MODIFY | Epic 使用规则（Section 2.1 + Section 7） |
| 9 | `.claude/commands/tad-maintain.md` | MODIFY | Epic 健康检查（6 种类型） |
| 10 | `.claude/commands/tad-help.md` | MODIFY | Epic 帮助文档 |

---

## Acceptance Criteria

- [ ] Epic 模板存在且结构完整（无独立 Status 字段，使用派生状态）
- [ ] Alex 在评估复杂度时能建议创建 Epic
- [ ] Handoff 能关联到 Epic（handoff 模板有 Epic 字段）
- [ ] *accept 时能正确更新 Epic 进度（在 handoff 归档之后，step2b）
- [ ] 并发控制: 同一 Epic 同时只能有 1 个 Active phase
- [ ] 错误处理: Epic 更新失败不阻塞 handoff 归档
- [ ] 所有阶段完成后 Epic 能归档
- [ ] /tad-maintain 能检测 Epic 状态（6 种检查类型）
- [ ] /tad-help 包含 Epic 说明
- [ ] CLAUDE.md 包含 Epic 规则

---

## Testing Checklist

- [ ] 场景 1: 大任务 → Alex 建议 Epic → 创建 Epic + Phase 1 Handoff（with Epic field）
- [ ] 场景 2: *accept Phase 1 → handoff 先归档 → Epic 更新（step2b）→ 提示 Phase 2
- [ ] 场景 3: 所有 Phase 完成 → Epic 归档至 .tad/archive/epics/
- [ ] 场景 4: 小任务 → 不触发 Epic（正常 handoff 流程不受影响）
- [ ] 场景 5: /tad-maintain 检测到 stale Epic → 自动归档
- [ ] 场景 6: /tad-maintain 检测到 DANGLING_REF → 报告 WARNING
- [ ] 场景 7: 尝试同时激活 2 个 phase → 被 BLOCK
- [ ] 场景 8: Epic 文件丢失 → WARNING，*accept 继续执行不阻塞
- [ ] 场景 9: 中途添加新 phase → Phase Map 追加，Notes 记录原因
