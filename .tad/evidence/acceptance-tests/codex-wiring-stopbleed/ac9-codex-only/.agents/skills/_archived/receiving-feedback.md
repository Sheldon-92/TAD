# Receiving Feedback Skill

---
title: "Receiving Feedback"
version: "3.0"
last_updated: "2026-01-07"
tags: [feedback, review, collaboration, decision-log]
domains: [engineering]
level: beginner-intermediate
estimated_time: "20min"
prerequisites: []
sources:
  - "obra/superpowers"
  - "Google Engineering Practices"
enforcement: recommended
tad_gates: [Gate3_Implementation_Quality, Gate4_Review]
---

> 来源: obra/superpowers，已适配 TAD 框架

## TL;DR Quick Checklist

```
1. [ ] 先复述理解；验证上下文完整
2. [ ] 基于技术价值评估（收益/成本/风险/替代）
3. [ ] 给出行动：实施/澄清/反驳（含理由与证据）
4. [ ] 变更后验证测试通过，无回归
5. [ ] 记录决策（Decision Log），便于追踪
```

**Red Flags:** 立刻迎合、无验证、无上下文、修改范围不明确、无回归验证

---

## 触发条件

当 Claude 收到代码审查反馈、用户建议或批评时，自动应用此 Skill。

---

## 核心原则

**"基于技术价值评估反馈，而非社交表演。"**

验证、质疑、然后实施——不要条件反射式地同意。

---

## 处理反馈流程

### Step 1: 理解反馈

```
收到反馈后:
□ 用自己的话复述需求
□ 检查建议是否会破坏现有功能
□ 验证审查者是否了解完整上下文
□ 单独测试每个修复
```

### Step 2: 评估技术价值

```
评估清单:
□ 这个反馈解决什么问题？
□ 实施成本是多少？
□ 是否有更好的替代方案？
□ 是否符合 YAGNI 原则？
```

### Step 3: 决定行动

| 反馈类型 | 行动 |
|----------|------|
| 明确正确 | 实施修复 |
| 需要更多信息 | 请求澄清 |
| 技术上不正确 | 礼貌反驳 |
| 违反架构决策 | 解释原因 |

---

## 禁止的回应

### ❌ 过度认同

```
❌ "你说得太对了！"
❌ "感谢指出这个！"
❌ "我完全同意！"
❌ "太棒了，立刻改！"
```

**为什么禁止**：
- 行动比言语更能证明理解
- 社交表演不等于技术理解
- 可能导致错误的修改

### ✅ 正确的回应

```
✅ "我理解你的建议是 [复述]"
✅ "让我验证这个改动..."
✅ "修改已完成，测试通过"
✅ "验证后确认你是对的"
```

---

## 技术反驳协议

### 何时应该反驳

```
可以反驳当:
□ 建议会破坏现有功能
□ 审查者缺少完整上下文
□ 建议违反 YAGNI 原则
□ 与已确定的架构决策冲突
```

### 如何反驳

```markdown
## 反驳模板

### 原始建议
[描述收到的建议]

### 我的理解
[复述建议的意图]

### 技术考量
[解释为什么不同意]

### 代码证据
[引用相关代码]

### 建议替代方案（可选）
[如果有更好的方案]
```

### 反驳示例

```markdown
### 原始建议
"应该给这个函数添加缓存"

### 我的理解
你希望提高这个函数的性能

### 技术考量
这个函数每次调用的参数都不同（用户 ID），
缓存命中率会很低，反而增加内存开销。

### 代码证据
\`\`\`javascript
// 调用分析显示 99% 的调用是不同的 userId
analytics.show({
  uniqueUserIds: 9900,
  totalCalls: 10000
});
\`\`\`

### 建议替代方案
可以在调用方做批量预取，减少调用次数。
```

---

## 反馈澄清协议

### 何时需要澄清

```
需要澄清当:
□ 反馈不够具体
□ 多个反馈项相互依赖
□ 不确定优先级
□ 实施方向不明确
```

### 澄清模板

```markdown
关于反馈 [X]，我需要澄清：

1. 你希望的具体行为是什么？
2. 这个改动的优先级是？
3. 是否有相关的代码参考？
```

---

## 承认错误

### 当你的反驳是错误的

```
❌ "哦对不起，我错了，你太对了！"
❌ "抱歉我没理解，让我解释一下..."

✅ "验证后确认你是对的"
✅ "检查了代码，确实如你所说"
```

**原则**: 简洁陈述事实，不需要过度解释或道歉。

---

## 与 TAD 框架的集成

在 TAD 的审查流程中：

```
Code Review → 收到反馈 → 处理反馈 → 更新代码
                 ↓
            [ 此 Skill ]
```

**TAD 集成点**：
1. Gate 审查后处理反馈
2. Alex 设计反馈处理
3. Blake 实现修改

---

## 反馈处理清单

### 收到反馈时

```
□ 理解反馈的技术意图
□ 评估技术价值
□ 验证上下文完整性
□ 决定行动方案
```

### 实施修改前

```
□ 明确修改范围
□ 考虑副作用
□ 准备测试验证
```

### 修改完成后

```
□ 运行相关测试
□ 验证问题已解决
□ 没有引入新问题
□ 简洁汇报结果
```

---

## 关键心态

> "技术正确性高于社交舒适度。"

**健康的反馈文化**：
- 反馈是关于代码，不是关于人
- 质疑是为了更好的结果
- 最终目标是更好的代码

---

*此 Skill 指导 Claude 以技术为导向处理反馈，避免无意义的社交表演。*

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type     | Description                     | Location                                 |
|-------------------|---------------------------------|------------------------------------------|
| `feedback_items`  | 反馈要点与理解复述              | `.tad/evidence/review/feedback.md`       |
| `decision_log`    | 处理决策与理由（实施/澄清/反驳）| `.tad/evidence/review/decisions.md`      |
| `before_after`    | 变更前后对比（代码/行为）       | `.tad/evidence/review/before-after.md`   |

### Acceptance Criteria

```
[ ] 反馈被准确理解；上下文完整
[ ] 决策有理由与证据支撑；必要时提供替代方案
[ ] 变更后测试通过，无新增问题
```

### Artifacts

| Artifact        | Path                                       |
|-----------------|--------------------------------------------|
| Feedback Items  | `.tad/evidence/review/feedback.md`         |
| Decision Log    | `.tad/evidence/review/decisions.md`        |
| Before/After    | `.tad/evidence/review/before-after.md`     |
