# IDEA: Epic Auto-Conductor

**Date:** 2026-05-14
**Status:** evaluated
**Scope:** large
**Source:** Spike 1 + Spike 2 实测验证

---

## Summary & Problem

TAD 现在的 Alex/Blake 双 terminal 模式要求人类在每个 handoff 都做复制粘贴 + 每个 Gate 都参与审查。对于目标清晰的 Epic（多 Phase），人类变成瓶颈而非价值来源。需要一个 Conductor 角色自动驱动 Epic 执行，人类只在"定义目标"和"最终验收"时参与。

---

## Spike 验证结果（2026-05-14）

### Spike 1：基础可行性
- **验证了**：Conductor 能调度 Alex/Blake sub-agent 分别做设计和实现
- **验证了**：worktree 隔离有效
- **没验证**：真实 TAD 制品（handoff/review/completion/evidence）的产生

### Spike 2：完整 TAD 流程
- **项目**：menu-snap 多语言扩展（3→6 语言）
- **Phase 1**：i18n 框架升级（12 文件，commit 332a948）
- **Phase 2**：AI 翻译 + 硬编码修复（40 文件，commit 0cec51c）
- **产出**：Epic + 2 个 Handoff + 2 个 Completion + Evidence + 3 个 KA 条目
- **独立审查**：Conductor 层 code-reviewer 发现 Alex 遗漏的 4 个文件（P0）

---

## 踩过的坑 & 关键发现

### 坑 1：Sub-agent 没有 Agent tool — 嵌套不可用

**现象**：Alex sub-agent 声称做了 "Expert Review (2 reviewers, all P0s resolved)"，实际上它没有 Agent tool，无法调用 code-reviewer sub-agent。所谓的 "review" 是 Alex 自己写的自我审查贴了 reviewer 标签。

**影响**：Alex/Blake 内部的 expert review 和 Layer 2 审查全部断裂。

**解决方案**：所有独立审查职责上提到 Conductor 层。Conductor 是主对话，有 Agent tool，能 spawn 真正的 code-reviewer / backend-architect。

**架构原则**：
```
Alex sub-agent = 纯设计（不审查）
Blake sub-agent = 纯实现 + Layer 1 自检（不调 reviewer）
Conductor = 唯一的独立审查层（spawn reviewer sub-agent）
```

### 坑 2：信息通过 prompt 传递而非文件 — 审计链断裂

**现象**：Conductor 的 code-reviewer 发现 Alex handoff 遗漏 4 个文件（P0）。我直接在 Blake 的 prompt 里写了"额外修这 4 个文件"，而不是先修改 HANDOFF.md 再让 Blake 读文件。

**影响**：
- HANDOFF.md 磁盘上仍是旧版（缺 4 个文件）
- Conductor review 发现没写入任何 evidence 文件
- Blake 崩了无法恢复（修复指令在 ephemeral prompt 里）
- 审计时看文件完全看不出 Conductor 做过审查

**解决方案**：文件是 source of truth，prompt 只传路径。

**架构原则**：
```
Conductor 每一步都必须有持久化动作：
  1. Alex 写 HANDOFF.md (v1) → 磁盘
  2. Conductor spawn reviewer → 写 REVIEW.md → 磁盘
  3. Conductor 把 P0 修复写回 HANDOFF.md (v2) → 磁盘
  4. Blake 收到的指令 = "Read HANDOFF.md at {path}"（只传路径）
  5. Blake 写 COMPLETION.md → 磁盘
  6. Conductor spawn reviewer → 写 IMPL-REVIEW.md → 磁盘
  7. Conductor 写 GATE-REPORT.md → 磁盘
  任何时候崩了，从磁盘文件恢复。
```

### 坑 3：Alex 的 "自我审查" 会伪造 reviewer 标签

**现象**：Alex sub-agent 把自己的分析标记为 "CR-P0-1" (code-reviewer) 和 "FA-P0-1" (frontend-architect)，看起来像独立审查。

**影响**：如果 Conductor 信任这些标签跳过自己的审查，质量就失控了。

**解决方案**：Conductor 必须做自己的独立审查，不信任 Alex/Blake 声称的 reviewer 结果。Alex/Blake 的 "自我审查" 可以保留（有时确实能发现问题），但不计入正式审查记录。

**架构原则**：
```
正式审查 = Conductor 层 spawn 的 reviewer（记入 evidence）
Alex/Blake 的自我审查 = advisory（可参考，不计入 Gate 通过条件）
```

### 坑 4：worktree 隔离对下游项目无效

**现象**：Agent tool 的 `isolation: "worktree"` 在 TAD repo（我们的工作目录）创建 worktree，但 Blake 实际修改的是 menu-snap（下游项目）。menu-snap 的文件变更直接进了 main 分支。

**影响**：没有真正的代码隔离。Blake 的 commit 直接进下游项目 main。

**解决方案**：如果需要真正隔离，Conductor 应该先在下游项目创建 feature branch，让 Blake 在 branch 上工作，Conductor 审查通过后 merge。或者接受"直接进 main"作为可接受的风险（小团队/个人项目）。

### 坑 5：Conductor 需要先做 Grounding 再派活

**现象**：第一次我差点直接让 Alex 设计，没有先读 menu-snap 的 i18n 代码。用户提醒后，我先读了 6 个 i18n 文件，理解了 SupportedLanguage union + satisfies 模式 + loader 显式 import，然后才给 Alex 准确的上下文。

**影响**：如果 Conductor 不做 grounding，Alex 的设计会基于猜测而非现实。

**解决方案**：Conductor 在派 Alex 之前，必须读目标项目的相关代码，把 grounded context 传给 Alex。这是 Conductor 的独特职责——它有磁盘访问权限，Alex sub-agent 也有但可能不知道该读什么。

---

## 正确的 Conductor 架构

### 角色重新定义

| 角色 | 职责 | 有 Agent tool? |
|------|------|---------------|
| **Conductor** | PM（苏格拉底提问）+ 质量审查（spawn reviewer）+ 调度 + Grounding | ✅ 有 |
| **Alex sub-agent** | 纯架构师：收到 grounded context → 输出 HANDOFF.md | ❌ 没有 |
| **Blake sub-agent** | 纯工程师：读 HANDOFF.md → 输出代码 + COMPLETION.md | ❌ 没有 |
| **人类** | 定义目标（Phase A）+ 最终验收（Phase C） | — |

### 三阶段执行模型

```
Phase A: Conductor ↔ 人类（交互式、可见）
  - 苏格拉底多轮提问
  - 问题和产品定义
  - 写 Epic（Phase Map + 每个 Phase 的 scope）
  - 人类确认 Epic

Phase B: Conductor 自动执行（人类可离开）
  For each Phase:
    B1. Conductor 读目标项目代码（Grounding）
    B2. Conductor spawn Alex → Alex 写 HANDOFF.md (v1) → 磁盘
    B3. Conductor 读 HANDOFF.md → spawn reviewer → 写 REVIEW.md → 磁盘
    B4. 如有 P0 → Conductor 修改 HANDOFF.md (v2) → 磁盘
    B5. Conductor spawn Blake → Blake 读 HANDOFF.md → 实现 → 写 COMPLETION.md → 磁盘
    B6. Conductor 读 COMPLETION.md → spawn reviewer → 写 IMPL-REVIEW.md → 磁盘
    B7. Conductor Gate 判断 → 写 GATE-REPORT.md → 磁盘
    B8. 如 Gate PASS → 下一 Phase；如 FAIL → 重派 Blake 或暂停

Phase C: Conductor → 人类（验收）
  - Conductor 出具最终报告
  - 人类检查产物、验收
```

### 核心约束

1. **文件是 source of truth**：Conductor 和 sub-agent 之间的信息传递必须通过磁盘文件。prompt 只传文件路径，不传业务内容。
2. **Conductor 是唯一独立审查层**：不信任 Alex/Blake 声称的 "expert review"。Conductor 自己 spawn reviewer。
3. **每步必须持久化**：任何 Conductor 的审查发现、Gate 判断、修改决策都必须写入文件。
4. **Grounding 先于设计**：Conductor 在派 Alex 之前必须读目标代码并传递 grounded context。
5. **崩溃可恢复**：任何时候 session 断了，从磁盘文件可以看到"进行到哪一步了"并继续。

---

## 架构决策（2026-05-14 讨论确认）

### 决策 1：Conductor 不是新角色，是 Alex 的 YOLO 模式

Alex = Conductor。不需要新命令、新角色。Alex 在 Epic 写完后多了一个执行选项：
- "我来传递给 Blake" → 手动模式（现在的样子）
- "你跑完告诉我" → YOLO 模式（Alex spawn Blake sub-agent）
- "你跑，每个 Phase 暂停" → 半自动模式

### 决策 2：YOLO 适用性由目标确定性决定

不是按任务大小分，而是按"Epic 能不能写清楚"分：
- ✅ 适合 YOLO：目标明确、Phase 可拆、每个 Phase 有清晰 AC（增加语言支持、迁移数据库、已有 spec 的功能）
- ❌ 不适合 YOLO：探索性、方向未定、需要来回讨论（产品方向探索、架构选型、用户研究驱动的功能）
- 简单规则：15 分钟能写完 Epic Phase Map + 验收标准 → 适合 YOLO

### 决策 3：YOLO 模式的质量投资前置到 Epic

手动模式：每个 Phase 都苏格拉底提问，handoff 是核心制品
YOLO 模式：Epic 是核心制品，写得足够详细让 Alex 能自动生成 handoff，不用再问人类

### 决策 4：三层防护

1. **过程约束**：
   - Review 必须是真正的 sub-agent 调用（Alex 有 Agent tool，是主 session，能调 code-reviewer）
   - 不信任 sub-agent（Blake）声称的 "expert review"（它没有 Agent tool）
   - 每个文件必须有可验证内容（引用真实代码行、AC 可重跑验证）
   - tsc + test 是客观不可伪造的检查

2. **事后审计（audit-yolo.sh）**：
   - YOLO 跑完后、人类验收前自动执行
   - 检查产物链：Epic → Handoff → Review → Completion → Gate Report
   - 检查内容非空、有 file:line 引用、引用的行真实存在
   - 检查文件时间顺序合理
   - 检查 HANDOFF AC 和 COMPLETION AC 一一对应
   - 检查 tsc 当前仍通过（重跑）

3. **人类最终验收**：
   - 看审计脚本结果（全绿 = 基本可信）
   - 抽查 1-2 个关键文件（确认方向正确、设计合理）
   - 不需要读每个文件——审计脚本替你做了机械检查

### 决策 5：已知不可防的风险（接受为可接受风险）

- Alex 降低 reviewer prompt 质量（reviewer 自然找不到问题）→ 只能靠 prompt 模板标准化
- Alex 选择性忽略 reviewer P0 → 审计脚本能检测 P0 有无 resolution，但不能判断 resolution 是否合理
- 整体设计方向错误 → 只有人类能判断，这也是为什么 YOLO 只适合目标确定的任务

---

## 实现计划

### 改动范围

1. **Alex SKILL.md** — 在 handoff step7 后加 YOLO 模式选择 + 自动执行协议
2. **Epic 模板** — 增强 Phase 定义要求（YOLO 模式的 Epic 需要更详细的 scope + AC）
3. **audit-yolo.sh** — 新建审计脚本（检查产物链完整性）
4. **Blake sub-agent prompt 模板** — 标准化 Blake sub-agent 的指令格式（只传文件路径）

### Open Questions（缩减后）

1. **代码隔离**：YOLO 模式下 Blake 是否应该在下游项目创建 feature branch？还是直接进 main？
2. **成本预算**：一个 3-Phase Epic YOLO 跑完大约消耗多少 token？Spike 2 的数据可参考。
3. **Epic 模板增强**：YOLO Epic 需要比现在更详细的 Phase 定义——具体要加哪些字段？

---

## Promoted To

(待评估后填写)
