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
规则 1: Alex 创建 handoff → 必须先执行 Gate 2
规则 2: Blake 完成实现 → 必须执行 Gate 3
规则 3: Blake 完成集成 → 必须执行 Gate 4
规则 4: Gate 不通过 → 阻塞下一步，必须修复
规则 5: Gate 3/4 通过 → 必须检查并记录 project-knowledge（如有新发现）
```

**Gate 是强制检查点，不可跳过。**

### Project Knowledge 记录规则

```yaml
触发点 1: Gate 3 通过后 → Blake 记录实现发现（solutions, workarounds, gotchas）
触发点 2: Gate 4 通过后 → Alex 记录审查洞察（patterns, anti-patterns, architectural insights）

跳过条件:
- 所学内容是 AI 已知的通用知识
- 没有项目特定的新发现

记录位置: .tad/project-knowledge/{category}.md
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

### Alex (Solution Lead) - Terminal 1
- ✅ 需求分析、方案设计、架构规划
- ✅ 创建 handoff 文档
- ✅ 执行 Gate 1 & 2
- ❌ 不写实现代码
- ❌ 不执行 Blake 的任务

### Blake (Execution Master) - Terminal 2
- ✅ 代码实现、测试、部署
- ✅ 并行执行多任务
- ✅ 执行 Gate 3 & 4
- ❌ 不独立设计方案
- ❌ 必须基于 Alex 的 handoff

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

## 7. 学习记录规则

使用 `/tad-learn` 记录改进建议时：
- 必须选择正确的分类（workflow/design/quality/tooling/documentation）
- 必须提供清晰的发现和建议
- 完成后自动推送到 TAD GitHub 仓库的 `.tad/learnings/pushed/`

---

## 8. 违规处理

如果 Claude 违反以上规则（如绕过 Blake、跳过 Gates）：
1. 立即停止当前操作
2. 调用正确的 agent/command
3. 按规范流程重新执行

**这些规则确保 TAD 框架的质量保证体系有效运行。**
