# Epic: YOLO Mode — Alex Auto-Execution

**Created:** 2026-05-14
**Created by:** Alex + 人类（通过 *discuss 深度讨论 + 2 次 spike 验证）
**Status:** In Progress

## Objective

让 Alex 在 Epic 场景下能自动驱动 Blake sub-agent 执行所有 Phase，消除人类机械传递，同时严格遵守 TAD 全流程（Handoff → Review → Gate → Evidence），所有过程文件持久化。

## Success Criteria

1. 用户在 Epic 写完后可以选择 "你跑完告诉我"，Alex 自动完成所有 Phase
2. 每个 Phase 产出真实的 HANDOFF.md → REVIEW.md → COMPLETION.md → GATE-REPORT.md
3. 审计脚本验证产物链完整性，全绿才能验收
4. 手动模式不受影响——没选 YOLO 的任务跟现在一模一样

## Phase Map

| Phase | Name | Status | Scope | Handoff |
|-------|------|--------|-------|---------|
| 1 | Epic 模板增强 | ✅ Done | 增强 Epic 模板让每个 Phase 有完整定义（scope/AC/input/output/files），两种模式都受益 | HANDOFF-20260514-epic-template-enhancement.md |
| 2 | YOLO 执行机制 | ✅ Done | Alex SKILL 加 YOLO 执行协议 + Blake sub-agent prompt 模板 + 文件传递协议 | HANDOFF-20260514-yolo-execution-mechanism.md |
| 3 | 审计脚本 + Dogfood | ✅ Done | audit-yolo.sh ✅ (commit 0d6b307) + Dogfood ✅ (menu-snap 过敏原检测, 39/39 audit PASS, commits 0f16297+7795c16) | HANDOFF-20260514-audit-yolo-script.md |

---

## Phase 1: Epic 模板增强

### 问题

现有 Epic 模板每个 Phase 只有一行表格。Alex 开始任何 Phase 时都要重新做 Socratic 提问搞清 scope。这在手动模式下浪费时间，在 YOLO 模式下更是不可行（没有人可以问）。

### 目标

增强 Epic 模板，让每个 Phase 有完整的定义。不管手动还是 YOLO，Alex 拿到一个 Phase 定义后就能直接开始设计，不需要额外苏格拉底提问。

### 要改什么

**epic-template.md 增强——每个 Phase 从一行表格变成一个完整 block：**

```markdown
## Phase {N}: {name}

**Status:** ⬚ Planned / 🔄 Active / ✅ Done
**Execution:** manual | yolo（Epic 确认时用户选）

### Scope
{2-3 句话描述这个 Phase 做什么，不做什么}

### Input
{这个 Phase 开始时已经存在的东西——前一个 Phase 的产出、现有代码}

### Output
{这个 Phase 完成后交付什么——新文件、改了什么、用户可见的变化}

### Acceptance Criteria
- [ ] {具体可验证的条件 1}
- [ ] {具体可验证的条件 2}

### Files Likely Affected
{预估要改/创建的文件列表——Alex 设计时可以调整}

### Dependencies
{依赖哪个 Phase 的产出，或"无"}
```

**Alex SKILL.md — Epic 创建流程增强：**
- adaptive_complexity_protocol step2b (Epic Assessment) 创建 Epic 时，必须按新模板填充每个 Phase block
- 苏格拉底提问阶段把 Phase 级别的 scope 和 AC 问清楚
- Epic 完成后的确认增加执行模式选择

**Alex SKILL.md — Phase 执行流程增强：**
- 开始一个 Phase 时，Alex 读 Epic Phase block 作为设计输入
- 如果 Phase block 足够详细 → 减少或跳过苏格拉底提问
- 如果 Phase block 不够详细 → 补充提问（手动模式正常；YOLO 模式用 Alex 自主判断）

### Acceptance Criteria（Phase 1 of Epic）
- [ ] AC1: epic-template.md 包含 Phase block 模板（Scope/Input/Output/AC/Files/Dependencies）
- [ ] AC2: Alex SKILL step2b Epic 创建流程引用新模板
- [ ] AC3: Alex SKILL 开始 Phase 时读取 Phase block 作为设计输入
- [ ] AC4: 手动模式不受影响——新模板向后兼容旧 Epic
- [ ] AC5: 现有 5 个 active Epic 不需要迁移（新模板只对新 Epic 生效）

### Files Likely Affected
- .tad/templates/epic-template.md (MODIFY — 增强)
- .claude/skills/alex/SKILL.md (MODIFY — step2b + Phase 执行逻辑)

---

## Phase 2: YOLO 执行机制

### 要改什么（原 Phase 1 内容）

**Alex SKILL.md — 3 处新增：**

1. **step7_execution_mode**（在现有 step7 "STOP - Human Handover" 之后）
   - Epic 场景下（handoff 有 Epic 字段），AskUserQuestion 让用户选执行模式
   - 非 Epic 单 handoff → 不出现 YOLO 选项（单 handoff 手动传递就行）

2. **yolo_execution_protocol**（新 section）
   - 核心循环：For each Phase in Epic →
     a. Grounding（Alex 读目标项目代码）
     b. Alex 自己设计 → 写 HANDOFF.md 到磁盘
     c. Alex spawn code-reviewer → 写 REVIEW.md 到磁盘
     d. 如有 P0 → Alex 修改 HANDOFF.md
     e. Alex spawn Blake sub-agent → Blake 读 HANDOFF.md → 实现 → 写 COMPLETION.md
     f. Alex spawn code-reviewer 审查实现 → 写 IMPL-REVIEW.md 到磁盘
     g. Alex 做 Gate 3 + Gate 4 → 写 GATE-REPORT.md
     h. 如 PASS → 下一 Phase
   - 文件传递协议：prompt 只传路径，不传内容
   - Blake sub-agent 指令模板

3. **yolo_evidence_structure**（新 section）
   - 定义 YOLO 模式下每个 Phase 必须产出的文件列表和路径规范
   - 目录结构：`.tad/active/yolo/{epic-slug}/phase-{N}/`

**Blake sub-agent prompt 模板：**
- 标准化指令：读 HANDOFF.md → 实现 → tsc + test → 写 COMPLETION.md → 报告
- Blake 不调 reviewer（明确声明）
- Blake 不做 Gate（明确声明）

### 不改什么

- 手动模式完全不动
- *express / *bug / *discuss / *learn 路径不受影响
- 非 Epic 单 handoff 不出现 YOLO 选项
- Blake 的完整 SKILL.md 不改（YOLO Blake 是简化版 sub-agent，不是完整 Blake）

### Spike 验证数据

- Spike 2 在 menu-snap 上完整跑了 2 Phase（i18n 扩展）
- Phase 1: 12 文件，commit 332a948
- Phase 2: 40 文件，commit 0cec51c
- 产出了真实的 Handoff + Completion + Evidence + KA
- 发现 5 个架构约束（全部记录在 architecture.md）

### 关键约束

1. 文件是 source of truth — prompt 只传路径
2. Review 必须是真正的 sub-agent — Alex 有 Agent tool，直接调
3. 每步持久化 — 崩溃可恢复
4. Alex 不信任 Blake 声称的 review — Alex 自己做
5. Grounding 先于设计 — Alex 读代码再派活

## Context for Phase 2

- audit-yolo.sh：检查产物链完整性（文件存在 + 非空 + 内容交叉引用 + tsc 重跑）
- Epic 模板增强：YOLO Epic 需要更详细的 Phase 定义（scope + AC + 输入/输出）
- *accept 集成：YOLO 完成后 → 跑 audit-yolo.sh → 人类验收 → 归档

## Phase 3: 审计脚本 + Dogfood

**Status:** ⬚ Planned
**Execution:** pending

### Scope

两部分：（A）创建 audit-yolo.sh 审计脚本，（B）在 menu-snap 上用 YOLO 模式跑一个真实的 2-Phase 功能（如菜品收藏），然后用审计脚本验证。A 是工具，B 是验证。

不做：不修改 YOLO 协议本身（那是 Phase 2 scope）。dogfood 中发现的问题如果是协议层的，记为 follow-up 而不是在 Phase 3 里改。

### Input

- Phase 2 完成后的 Alex SKILL.md（含 yolo_execution_protocol）
- 现有审计脚本模式（layer2-audit.sh, drift-check.sh 等）
- menu-snap 项目（dogfood 目标）

### Output

- `.tad/hooks/lib/audit-yolo.sh` — 审计脚本
- menu-snap 上一个真实的 YOLO Epic 完整执行记录
- 审计报告（全绿/有红 + 修复记录）

### Acceptance Criteria

- [ ] AC1: audit-yolo.sh 接受 epic-slug 参数，输出 4 维度检查结果（产物链 / 内容真实性 / 代码验证 / 时序）
- [ ] AC2: audit-yolo.sh exit 0 = 全部通过，exit 1 = 有失败项
- [ ] AC3: audit-yolo.sh 检查每个 Phase 的 9 类文件（grounding + handoff + 2 design reviews + completion + 2 impl reviews + gate report + git commit）
- [ ] AC4: audit-yolo.sh 检查 review 文件引用了具体 file:line（内容真实性）
- [ ] AC5: audit-yolo.sh 重跑 tsc --noEmit（代码验证）
- [ ] AC6: Dogfood: menu-snap 上一个 2-Phase Epic 用 YOLO 模式完整执行
- [ ] AC7: Dogfood: audit-yolo.sh 对 dogfood Epic 输出全绿
- [ ] AC8: Dogfood: 产出的代码 tsc 通过 + 功能可用

### Files Likely Affected

- `.tad/hooks/lib/audit-yolo.sh` (CREATE)
- `.claude/skills/alex/SKILL.md` (MODIFY — epic_completion 里加 audit-yolo.sh 调用)
- menu-snap 项目文件（dogfood 产出，取决于选什么功能）

### Dependencies

- Phase 2 必须完成（audit-yolo.sh 检查的是 YOLO 的产出结构，Phase 2 定义了这个结构）

### Notes

- audit-yolo.sh 遵循现有审计脚本模式：纯 bash、exit 0/1、无 hook 注册、无 jq 依赖
- Dogfood 任务在 Phase 3 开始时由 Conductor (Alex YOLO 模式) 和用户一起定义 Epic
- 如果 dogfood 中发现 YOLO 协议问题，记入 architecture.md 作为 follow-up，不在 Phase 3 中修 SKILL.md
