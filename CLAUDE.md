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
```

**Gate 是强制检查点，不可跳过。**

---

## 4. Agent 分工边界

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

## 5. 学习记录规则

使用 `/tad-learn` 记录改进建议时：
- 必须选择正确的分类（workflow/design/quality/tooling/documentation）
- 必须提供清晰的发现和建议
- 完成后自动推送到 TAD GitHub 仓库的 `.tad/learnings/pushed/`

---

## 6. 违规处理

如果 Claude 违反以上规则（如绕过 Blake、跳过 Gates）：
1. 立即停止当前操作
2. 调用正确的 agent/command
3. 按规范流程重新执行

**这些规则确保 TAD 框架的质量保证体系有效运行。**
