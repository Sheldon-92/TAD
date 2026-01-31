# TAD 框架使用规则

此文件定义 Claude 在 TAD 项目中的强制执行规则。

## 1. Handoff 读取规则 ⚠️ CRITICAL

**当读取 `.tad/active/handoffs/` 目录下的任何文件时：**

```
检测到 handoff 文件读取
     ↓
必须立即调用 /blake 进入执行模式
     ↓
执行实现
     ↓
必须执行 /gate 3 (Implementation Quality)
     ↓
必须执行 /gate 4 (Integration Verification)
     ↓
完成交付
```

**禁止行为**:
- ❌ 读取 handoff 后直接开始实现（绕过 Blake 验证）
- ❌ 实现完成后跳过 Gate 3/4 验证
- ❌ 不通过 Blake 就修改代码

**原则**: 有 Handoff → 必须用 Blake → 必须过 Gates

---

## 2. TAD Framework 使用场景

### 必须使用 TAD 的场景

使用 `/alex` 当：
- 新功能开发（预计修改 >3 个文件）
- 架构变更或技术方案讨论
- 复杂的多步骤需求需要拆解
- 涉及多个模块的重构
- 用户说"帮我设计..."、"我想做一个..."、"如何实现..."

使用 `/blake` 当：
- 发现 `.tad/active/handoffs/` 中有待执行的 handoff
- Alex 已完成设计并创建了 handoff
- 用户说"开始实现..."、"执行这个设计..."
- 需要并行执行多个独立任务

使用 `/gate` 当：
- Gate 1: Alex 完成 3-5 轮需求挖掘后，进入设计前
- Gate 2: Alex 完成设计，创建 handoff 前
- Gate 3: Blake 完成实现，提交代码前
- Gate 4: Blake 完成集成，交付用户前

### 可以跳过 TAD 的场景

- 单文件 Bug 修复
- 配置调整（如修改 .env、更新依赖版本）
- 文档更新（README、注释）
- 紧急热修复（生产环境问题）
- 用户明确说"不用 TAD，直接帮我..."

---

## 3. Quality Gates 强制规则

```yaml
规则 0: Alex 写 handoff 前 → 必须先用 AskUserQuestion 苏格拉底式提问
规则 1: Alex 创建 handoff → 必须先经过专家审查 → 再执行 Gate 2
规则 2: Blake 完成实现 → 必须执行 Gate 3
规则 3: Blake 完成集成 → 必须执行 Gate 4
规则 4: Gate 不通过 → 阻塞下一步，必须修复
规则 5: Gate 3/4 通过 → 必须检查并记录 project-knowledge（如有新发现）
```

**Gate 是强制检查点，不可跳过。**

### Socratic Inquiry 规则 ⚠️ BLOCKING

```yaml
规则: Alex 写 handoff 之前必须用 AskUserQuestion 工具进行苏格拉底式提问
      帮助用户发现需求盲点、验证完整性、做出更好决策
      不调用 AskUserQuestion 直接写 handoff = VIOLATION

流程:
  1. 评估任务复杂度 (small/medium/large)
  2. 根据复杂度选择问题数量 (2-3/4-5/6-8 个问题)
  3. 使用 AskUserQuestion 工具提问
  4. 用户回答后可自由讨论补充
  5. 输出 Inquiry Summary 并进入 handoff 编写

问题维度:
  - 价值验证: "这个功能解决的核心痛点是什么？"
  - 边界澄清: "哪些场景明确不需要支持？"
  - 风险预见: "如果这个功能出问题，最坏情况是什么？"
  - 验收标准: "怎样算做完了？"
  - 用户场景: "典型用户会怎么使用这个功能？"
  - 技术约束: "有哪些现有系统的限制需要考虑？"

复杂度判断:
  small: 单文件修改、配置调整、简单 UI 变更 → 2-3 问题
  medium: 多文件修改、新功能、API 变更 → 4-5 问题
  large: 架构变更、复杂功能、跨模块重构 → 6-8 问题
```

**禁止行为**:
- ❌ 不用 AskUserQuestion 直接写 handoff
- ❌ 问完问题不等用户回答就开始写
- ❌ 跳过复杂度评估，问题数量与任务不匹配

### Handoff 专家审查规则 ⚠️ NEW

```yaml
规则: Alex 创建 handoff 初稿后，必须调用专家审查，然后才能标记为 Ready for Implementation

流程:
  1. Draft Creation: 创建 handoff 初稿（框架+核心内容）
  2. Expert Selection: 选择 2+ 专家（code-reviewer 必选）
  3. Parallel Review: 并行调用专家审查
  4. Feedback Integration: 整合反馈，处理 P0 问题
  5. Gate 2: 执行设计完整性检查
  6. Ready: 标记为 Ready for Implementation

专家选择规则:
  必选: code-reviewer（类型安全、测试、代码结构）
  后端相关: + backend-architect（数据流、API、架构）
  前端相关: + ux-expert-reviewer（UI/UX、可访问性）
  性能敏感: + performance-optimizer（性能、成本）
  安全相关: + security-auditor（安全、漏洞）

最低要求: 2 个专家
```

**禁止行为**:
- ❌ 不经过专家审查直接发送 handoff 给 Blake
- ❌ 忽略专家发现的 P0 问题

### Project Knowledge 记录规则 ⚠️ BLOCKING

```yaml
规则: Knowledge Assessment 是 Gate 3/4 的阻塞性检查项
      Gate 结果表格中必须包含 Knowledge Assessment 部分
      否则 Gate 无效

触发点:
  Gate 3: Blake 必须在结果表格中回答 Knowledge Assessment
  Gate 4: Alex 必须在结果表格中回答 Knowledge Assessment

必须回答的问题（即使选 No 也要显式回答）:
  1. 是否有新发现？ (✅ Yes / ❌ No)
  2. 如果有，属于哪个类别？ ({category} 或 N/A)
  3. 一句话总结 (即使无新发现也要写明原因)

Gate 结果表格必须包含:
  #### Knowledge Assessment (MANDATORY)
  | Question | Answer | Action |
  |----------|--------|--------|
  | New discoveries? | ✅ Yes / ❌ No | ... |
  | Category | {category} or N/A | ... |
  | Brief summary | {1-line} | ... |

记录位置: .tad/project-knowledge/{category}.md
```

**禁止行为**:
- ❌ Gate 结果表格中没有 Knowledge Assessment 部分
- ❌ 用"常规实现"作为借口跳过不填写

### Knowledge Bootstrap 规则

**区分两种知识类型：**

| 类型 | 定义 | 何时写入 | 例子 |
|------|------|----------|------|
| **先验知识 (Foundational)** | 项目开始前就应确定的规范 | 项目初始化时 | 设计系统、代码规范、技术栈 |
| **经验知识 (Accumulated)** | 开发过程中学到的 | Gate 通过后 | 踩坑记录、最佳实践、workaround |

**Bootstrap 触发条件：**

```yaml
触发 1: /tad-init 初始化新项目
  → 使用 .tad/templates/knowledge-bootstrap.md 模板
  → 填充所有 knowledge 文件的 "Foundational" section

触发 2: 发现某个 knowledge 文件只有模板头（无实际内容）
  → 从代码中提取现有规范
  → 补充 "Foundational" section

触发 3: 用户明确要求 "补充项目知识" 或 "建立规范"
  → 执行完整 Bootstrap 流程
```

**Bootstrap 流程：**

```
1. 读取 .tad/templates/knowledge-bootstrap.md
2. 针对每个知识类别：
   a. 检查对应 .md 文件是否有 "Foundational" section
   b. 如果没有，从代码中提取信息填充
   c. 信息来源：tailwind.config, globals.css, package.json, 现有组件等
3. 先验知识只需写一次，后续只追加经验知识
```

**Knowledge 文件结构：**

```markdown
# {Category} Knowledge

Project-specific {category} learnings accumulated through TAD workflow.

---

## Foundational: {标题}        ← 先验知识（Bootstrap 时写入）

> Established at project inception.

### [子章节]
[从代码/配置中提取的规范]

---

## Accumulated Learnings       ← 经验知识（Gate 通过后追加）

<!-- Entries from development experience below -->

### [Short Title] - [YYYY-MM-DD]
- **Context**: ...
- **Discovery**: ...
- **Action**: ...
```

---

## 3.1 Alex 验收规则 ⚠️ CRITICAL

**当 Alex 收到 Blake 的完工报告进行验收时，必须调用 subagents 进行实际验证，禁止仅做纸面验收。**

### 强制调用的 Subagents

根据任务类型，Alex 必须至少调用以下 subagents：

| 验收维度 | 必须调用的 Subagent | 验收内容 |
|---------|---------------------|----------|
| 代码质量 | `code-reviewer` | 代码规范、可维护性、设计模式 |
| 用户体验 | `ux-expert-reviewer` | 交互流程、视觉一致性、可用性 |
| 安全性 | `security-auditor` | 漏洞扫描、数据安全、权限控制 |
| 性能 | `performance-optimizer` | 响应时间、资源占用、瓶颈分析 |

### 验收流程

```
Blake 提交完工报告
     ↓
Alex 读取报告，确定验收范围
     ↓
【强制】调用 code-reviewer 审查代码
     ↓
【按需】调用 ux-expert-reviewer（如涉及 UI）
     ↓
【按需】调用 security-auditor（如涉及认证/数据）
     ↓
【按需】调用 performance-optimizer（如涉及性能敏感功能）
     ↓
汇总所有 subagent 的反馈
     ↓
生成验收结论（通过/需修改/打回）
```

### 最低验收要求

- ✅ **必须**：至少调用 1 个 subagent 进行实际代码/功能审查
- ✅ **必须**：subagent 的审查结果必须记录在验收报告中
- ❌ **禁止**：仅根据 Blake 的文档描述就判定通过
- ❌ **禁止**：跳过 subagent 直接完成 Gate 4

### 验收报告模板

```markdown
## Alex 验收报告

### 1. Subagent 审查结果

**code-reviewer 结果：**
- 审查范围：[文件列表]
- 发现问题：[问题数量]
- 关键反馈：[摘要]
- 结论：✅ 通过 / ⚠️ 需修改 / ❌ 打回

**ux-expert-reviewer 结果：**（如适用）
- 审查范围：[页面/组件]
- UX 评分：[分数/等级]
- 关键反馈：[摘要]
- 结论：✅ 通过 / ⚠️ 需修改 / ❌ 打回

### 2. 综合验收结论
- [ ] 代码质量符合标准
- [ ] 用户体验达到要求
- [ ] 安全性无明显漏洞
- [ ] 性能满足预期

**最终结论**：✅ 验收通过 / ⚠️ 条件通过（需修复 N 项）/ ❌ 打回重做
```

---

## 3.2 输出模板规则

**使用输出模板确保审查结果格式一致。**

### 可用的输出模板

| 场景 | 输出模板 | 路径 |
|------|----------|------|
| 代码审查 | code-review | `.claude/skills/code-review/SKILL.md` |
| API 设计审查 | api-review-format | `.tad/templates/output-formats/api-review-format.md` |
| 安全审查 | security-review-format | `.tad/templates/output-formats/security-review-format.md` |
| 性能审查 | performance-review-format | `.tad/templates/output-formats/performance-review-format.md` |

### 使用规则

```yaml
规则 1: 审查类任务 → 参考对应输出模板的 checklist
规则 2: 输出格式 → 遵循模板定义的表格/结构
规则 3: 项目经验 → 参考 .tad/project-knowledge/ 中的记录
```

---

## 4. Output Template Rules

### Subagent Output Requirements (MANDATORY)

When calling these subagents, they MUST output to `.tad/evidence/reviews/`:

| Gate | Subagent | Template | Evidence File |
|------|----------|----------|---------------|
| Gate 3 | test-runner | testing-review-format | `{date}-testing-review-{task}.md` |
| Gate 4 | security-auditor | security-review-format | `{date}-security-review-{task}.md` |
| Gate 4 | performance-optimizer | performance-review-format | `{date}-performance-review-{task}.md` |
| Gate 4 | code-reviewer | code-review | `{date}-code-review-{task}.md` |

**Enforcement**: Gate 3/4 will NOT pass without these evidence files.

### Evidence File Naming Convention

```
.tad/evidence/reviews/{YYYY-MM-DD}-{type}-{brief-description}.md

Examples:
- 2026-01-20-testing-review-user-flow.md
- 2026-01-20-security-review-auth-api.md
- 2026-01-20-performance-review-menu-load.md
```

### Recommended Templates (Non-blocking)

| Subagent | Template | When |
|----------|----------|------|
| code-reviewer | git-workflow-format | *review 命令 |
| refactor-specialist | refactoring-review-format | 重构任务 |

### Self-Use Templates (Alex/Blake Reference)

**Alex 在 *design 时可参考:**
- api-review-format
- architecture-review-format
- database-review-format
- ui-review-format
- ux-research-format

**Blake 在实现时可参考:**
- debugging-format
- error-handling-format

**Template location:** `.tad/templates/output-formats/`

---

## 5. Agent 分工边界

### Terminal 隔离规则 ⚠️ CRITICAL

**Alex 和 Blake 必须在不同的 Terminal 运行，禁止在同一个会话中切换角色。**

```yaml
规则: Alex 写完 handoff 后，必须停止并等待人类传递信息给 Blake
      不能在同一个 terminal 调用 /blake
      人类是 Alex 和 Blake 之间唯一的信息桥梁

流程:
  Terminal 1 (Alex):
    1. 需求分析 → 苏格拉底式提问 → 设计 → 写 handoff
    2. 输出: "Handoff 已创建，请在 Terminal 2 执行 /blake"
    3. 停止，等待人类反馈

  人类动作:
    - 打开 Terminal 2
    - 执行 /blake
    - 告诉 Blake handoff 位置

  Terminal 2 (Blake):
    1. 读取 handoff → 执行实现 → Gate 3/4
    2. 输出: "实现完成，请通知 Alex 进行验收"
    3. 停止，等待人类反馈
```

**禁止行为**:
- ❌ Alex 在同一个 terminal 调用 /blake
- ❌ Alex 直接执行实现代码
- ❌ Blake 在同一个 terminal 调用 /alex
- ❌ 任何 Agent 试图绕过人类直接与另一个 Agent 通信

**原则**: Human-in-the-Loop，人类掌控信息流动

---

### Alex (Solution Lead) - Terminal 1
- ✅ 需求分析、方案设计、架构规划
- ✅ 创建 handoff 文档
- ✅ 执行 Gate 1 & 2
- ✅ 验收 Blake 的实现（在 Terminal 1）
- ❌ 不写实现代码
- ❌ 不执行 Blake 的任务
- ❌ 不在同一 terminal 调用 /blake

### Blake (Execution Master) - Terminal 2
- ✅ 代码实现、测试、部署
- ✅ 并行执行多任务
- ✅ 执行 Gate 3 & 4
- ❌ 不独立设计方案
- ❌ 必须基于 Alex 的 handoff
- ❌ 不在同一 terminal 调用 /alex

---

## 6. 版本发布规则

### 发布工作分配

| 任务类型 | 负责人 | 说明 |
|---------|--------|------|
| 版本策略制定 | Alex | SemVer 规则、API 契约、发布流程设计 |
| 重大发布决策 | Alex | Major 版本、破坏性变更分析 |
| 日常版本发布 | Blake | 按 RELEASE.md SOP 执行 |
| CHANGELOG 更新 | Blake | 记录变更内容 |
| 构建和部署 | Blake | npm run build, npm run release:ios |

### 发布流程

```
常规发布 (patch/minor):
  用户说"发布新版本" → Blake 按 RELEASE.md 执行 → Gate 3/4

重大发布 (major/breaking):
  用户说"有破坏性变更" → Alex 创建 release-handoff → Blake 执行 → Gate 3/4
```

### 关键文档

| 文档 | 用途 |
|------|------|
| `CHANGELOG.md` | 版本历史记录 |
| `RELEASE.md` | 发布 SOP |
| `docs/API-VERSIONING.md` | API 契约规则 |
| `.tad/templates/release-handoff.md` | 发布 Handoff 模板 |

### 快速命令

```bash
npm run version:sync    # 同步版本到 iOS
npm run release:ios     # 完整 iOS 发布流程
npm version patch       # 版本号 +0.0.1
npm version minor       # 版本号 +0.1.0
npm version major       # 版本号 +1.0.0
```

---

## 7. 文档维护规则 (/tad-maintain)

`/tad-maintain` 是独立于 Alex/Blake 的维护命令，可在任何 Terminal 运行（Terminal 隔离规则的显式例外）。

### 三种模式
| 模式 | 触发时机 | 操作范围 |
|------|----------|----------|
| CHECK | Agent 激活时、`*exit` 时 | 只读扫描，终端报告 |
| SYNC | `*accept` 完成后 | 归档当前 handoff + NEXT.md 清理 |
| FULL | 手动 `/tad-maintain` | 全面检查 + 全面同步 |

### Handoff 自动清理条件（仅 SYNC/FULL 模式）
满足以下条件的 active handoff 将被自动处理:
1. **COMPLETED** (归档): archive 中已有对应的 COMPLETION 报告（slug 匹配）→ 移动到 archive
2. **STALE** (删除): archive 中已有更高版本的同名文件（slug + version 匹配）→ 从 active 删除（archive 已有更新版本，无需再次归档）

STALE 删除前必须验证 archive 中确实存在更新版本。

以下条件需要用户确认（仅 FULL 模式，通过 AskUserQuestion 交互）:
3. **POTENTIALLY_STALE** (超龄): active handoff 超过 `stale_age_days`（默认 7 天）未完成 → 提示用户确认归档/保留/删除
4. **POTENTIALLY_SUPERSEDED** (主题替代): archive 中近期 handoff 的标题/摘要与 active handoff 主题重叠 → 提示用户确认

**禁止**: 不得基于文件修改时间推测 handoff 是否完成。
**禁止**: Criterion C/D 不得自动归档，必须经过用户确认。

### NEXT.md 清理规则（阈值来自 config.yaml）
- 超过 `warning_threshold`（默认 400 行）→ 报告 WARNING
- 超过 `max_lines`（默认 500 行）→ 触发自动归档到 `docs/HISTORY.md`
- 归档对象: 完成超过 7 天的 `## 已完成` 段落
- 保留: In Progress / Today / This Week / Blocked / 近 7 天完成

### 写操作安全规则
- 先写目标文件，确认成功后再删除源文件
- 文件名冲突时添加 `-dup-{timestamp}` 后缀
- 操作前检查源文件是否仍存在（幂等性）

---

## 8. 违规处理

如果 Claude 违反以上规则（如绕过 Blake、跳过 Gates）：
1. 立即停止当前操作
2. 调用正确的 agent/command
3. 按规范流程重新执行

**这些规则确保 TAD 框架的质量保证体系有效运行。**
