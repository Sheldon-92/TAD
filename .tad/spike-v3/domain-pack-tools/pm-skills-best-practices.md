# PM Skills Best Practices — 研究摘要

**来源**: 5 个 GitHub 仓库的 PM Skills 研究（2026-04-01 Alex 调研）
**用途**: product-definition.yaml 深化的参考依据

---

## 研究了哪些仓库

| 仓库 | Stars | Skills 数 | 特点 |
|------|-------|----------|------|
| deanpeters/Product-Manager-Skills | 高 | 46 | 最深 — 每个 skill 有具体来源清单、反模式、质量标准 |
| product-on-purpose/pm-skills | 中 | 27 | 最严谨 — 证据置信度追踪、TEMPLATE.md + EXAMPLE.md |
| phuryn/pm-skills | 高 | 65 | 最实用 — WebSearch 驱动、$ARGUMENTS 即时执行 |
| Digidai/product-manager-skills | 中 | 1 集成 | 单一路由器、周循环工作流 |
| aakashg/pm-claude-skills | 低 | 5 | 反模式文档、触发式激活 |

---

## 按能力提取的最佳实践

### 用户研究 — 最佳来源: deanpeters + product-on-purpose

**1. 用户细分（segment_users）**
- product-on-purpose/foundation-persona 的 11 维度模板:
  - Demographics & Identity, Technology & Environment, JTBD (functional/emotional/social)
  - Behavioral Patterns, Decision-Making & Trust, Workflow, Current Alternatives
  - Pain Points (3-6 个，每个有 persistence reason + cost), Success Definition
  - Design Principles ("X over Y" 权衡式)
- 关键: 每个维度标注 **Evidence Confidence** (High/Medium/Low) + 来源类型 (interview/survey/analytics/support)

**2. 痛点排序（prioritize_pains）**
- phuryn/sentiment-analysis 的量化方法:
  - 每个痛点打分: severity (-1 to +1), frequency, business impact
  - 按 frequency × impact 排序
- deanpeters/discovery-process 的饱和度检查:
  - "当 3+ 个不同来源出现相同痛点时 → 高置信度"
  - "只有 1 个来源 → 标注 [SINGLE SOURCE - VALIDATE]"

**3. 反模式（anti-patterns）**
- deanpeters: "Don't ask 'Would you use this?' → Ask 'What have you tried? Why did it work/fail?'"
- deanpeters: "Demographics without behavior = useless persona"
- product-on-purpose: "Treating proto-persona as validated fact = dangerous"

---

### 竞品分析 — 最佳来源: product-on-purpose + phuryn + alirezarezvani

**1. 竞品分类**
- alirezarezvani/marketing-strategy-pmm 的 3 层分类:
  - Tier 1 直接竞品: 做同样的事
  - Tier 2 间接竞品: 做相关的事，可能扩展过来
  - Tier 3 替代方案: 用户现在的解决方式（Excel/手工/忍着）

**2. 深度分析（deep_analyze）**
- product-on-purpose/discover-competitive-analysis 的 7 步:
  1. Define scope (features/positioning/pricing)
  2. Gather intelligence (websites, G2/Capterra, press, job postings)
  3. Build feature matrix (Full/Partial/None/Unknown — NOT Yes/No)
  4. Analyze positioning (2x2 matrix with meaningful dimensions)
  5. Assess strengths/weaknesses ("respect drives better strategy")
  6. Identify strategic implications (specific, actionable)
  7. Note confidence levels (verified vs inferred)
- 关键质量标准:
  - "Strengths acknowledge genuine competitor advantages"（不能只写对手的缺点）
  - "Sources and confidence levels documented"
  - "Recommendations are specific/actionable"

**3. 定位推导（derive_positioning）**
- alirezarezvani: April Dunford 6 步法:
  1. Competitive alternatives (用户不用你会用什么)
  2. Unique attributes (你有什么别人没有的)
  3. Value (这些属性给用户带来什么价值)
  4. Best-fit customers (谁最在乎这个价值)
  5. Category (你属于什么类别)
  6. Trends (什么趋势在帮你)
- deanpeters/positioning-statement: Geoffrey Moore 模板:
  "For [target] who [need], [product] is a [category] that [benefit]. Unlike [competitor], [product] [differentiator]."
- 关键: 定位声明中的每个词必须有研究数据支撑，不能编

**4. 功能矩阵格式**
- product-on-purpose: Full/Partial/None/Unknown 四级（不是 Yes/No）
- 每个标注必须有来源（官网/评测/推测）
- 推测标注 [INFERRED]

---

### 产品定义/PRD — 最佳来源: deanpeters + phuryn

**1. 假设验证（validate_assumptions）**
- phuryn/identify-assumptions 的 8 类风险:
  1. Desirability (用户想要吗)
  2. Viability (商业可行吗)
  3. Feasibility (技术做得到吗)
  4. Usability (用户会用吗)
  5. Ethics (有伦理问题吗)
  6. GTM (能推出去吗)
  7. Strategy (符合战略吗)
  8. Team (团队能做吗)
- phuryn 的 XYZ 假设格式:
  "至少 X% 的 Y 会 Z" — 可量化、可验证
- Alberto Savoia 的 "skin-in-the-game" 原则:
  用户说"我会用"不算验证，用户实际注册/付费才算

**2. 定价推导**
- 不接受凭空编价格。推导方式：
  - 竞品定价参考（价格锚点）
  - 用户支付意愿信号（评论中提到"太贵"/"划算"的频率）
  - 成本结构倒推（如果有硬件成本）
  - 价值感知定价（解决这个问题值多少钱）
- 每种推导方式标注置信度

**3. PRD 质量标准**
- product-on-purpose 7 项检查:
  1. 问题和"为什么现在做"清晰
  2. 成功指标有基线和目标
  3. 范围边界明确 (In/Out/Future)
  4. 需求可测试且无歧义
  5. 技术约束已说明
  6. 风险和依赖有 owner
  7. 文档 15 分钟可读完
- phuryn: "Write for primary school graduate"（可读性最高要求）

---

### 验证材料 — 最佳来源: deanpeters + phuryn

**1. Amazon Working Backwards（press release）**
- deanpeters/press-release 格式:
  1. 标题（用户视角利益）
  2. 副标题（一句话总结）
  3. 问题段落
  4. 方案段落
  5. 用户引言（基于研究，不是纯编）
  6. 如何开始

**2. 验证材料审查**
- 所有 claim 必须可追溯到研究数据
- 编造的数据 → 删除或改为验证问题
- 定价/融资金额必须有推导依据
- 不确定的转为假设待验证

**3. 验证方法（pretotype）**
- phuryn: Landing page, Concierge MVP, Pre-order, Fake door test
- 关键: 验证的是行为（注册/付费），不是态度（"我会用"）

---

## 这些最佳实践怎么用

Blake 在深化 product-definition.yaml 时，每个新增的分析步骤应该：
1. 基于上述研究成果设计（不是自己编）
2. 在 step 的 action 描述中嵌入具体的分析框架（如 April Dunford 6 步、8 类风险）
3. quality_criteria 参考上述质量标准
4. anti_patterns 参考上述反模式
