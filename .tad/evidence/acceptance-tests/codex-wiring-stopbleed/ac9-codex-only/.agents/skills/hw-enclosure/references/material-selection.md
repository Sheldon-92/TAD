# Material Selection（材料选型 + 制造工艺 + 成本分析）

基于真实供应商数据，不是凭感觉。研究型能力：search → analyze → derive → generate。

## Step 1: Search Materials（搜索候选材料，≥3 种）

1. 3D 打印材料：PLA, PETG, ABS, ASA, Nylon, Resin
2. 注塑材料：ABS, PC, PC/ABS, PP, Nylon66
3. 搜索每种材料的：
   - 拉伸强度 (MPa)、弯曲模量 (GPa)、热变形温度 (°C)
   - 耐紫外线、耐化学品、吸湿率
   - 颜色选项、表面处理可能性
4. 搜索供应商价格（Hatchbox, eSUN, Polymaker for FDM; JLCPCB, PCBWay for SLA/注塑）

参考搜索词：
- `"PLA vs PETG vs ABS" enclosure "mechanical properties" comparison`
- `"3D printing material selection" IoT enclosure outdoor`
- `"{制造方式}" material cost per unit volume 2026`
- `"JLCPCB" OR "PCBWay" injection molding minimum order price`

## Step 2: Analyze Requirements（决策矩阵）

基于产品需求筛选材料，每个标准有权重：

| 标准 | 权重 | PLA | PETG | ABS | ASA | Nylon |
|------|------|-----|------|-----|-----|-------|
| 强度 (MPa) | W1 | 实际值 | ... | ... | ... | ... |
| 耐温 (°C) | W2 | ... | ... | ... | ... | ... |
| 耐紫外 | W3 | ... | ... | ... | ... | ... |
| 打印难度 | W4 | ... | ... | ... | ... | ... |
| 成本 ($/kg) | W5 | ... | ... | ... | ... | ... |
| 总分 | | Σ | Σ | Σ | Σ | Σ |

权重基于产品约束（户外→耐紫外权重高，消费级→成本权重高）。
每个数值必须有搜索来源。无数据 → 标注 `[DATA NEEDED]`。
质量要求：决策矩阵中的每个数值必须有来源；权重选择必须有理由。

## Step 3: Derive Recommendation（材料推荐 + 工艺匹配）

1. 首选材料 + 备选材料（含切换条件）
2. 配套制造工艺：

   | 制造方式 | 单件成本 | 模具成本 | 最小起订 | 交期 | 适合阶段 |
   |---------|---------|---------|---------|------|---------|
   | FDM 自制 | $2-8 | $0 | 1 | 1天 | 原型 |
   | SLA 外发 | $5-20 | $0 | 1 | 3-5天 | 小批量 |
   | SLS | $15-40 | $0 | 1 | 5-7天 | 功能验证 |
   | 注塑 | $0.5-3 | $2K-15K | 500+ | 3-6周 | 量产 |

3. 阶段建议：原型用 X → 小批量用 Y → 量产用 Z
4. 总成本估算：单件×数量 + 模具分摊 + 后处理

如果预算不支持注塑 → 诚实说明 3D 打印的量产限制。
质量要求：成本数据必须来自搜索结果；推测标注 `[ESTIMATED]`。

## Step 4: Generate Report

综合为材料选型报告 PDF（含决策矩阵、成本分析、阶段建议），可用 Typst 编译。

## Pass/Fail Criteria

- ≥3 种候选材料，每种有 ≥5 项工程参数
- 决策矩阵权重有明确理由
- 成本数据来自真实供应商（有 URL 或搜索来源）
- 阶段建议覆盖原型→小批量→量产
- 材料-环境兼容性矩阵为必选检查项：ABS 不用于长期 UV 暴露、PLA 不用于 >50°C 环境、PC 优先用于需透明/抗冲击场景 — 来源: 多源研究共识
- 防护等级标注（如需要）：NEMA 1-4X / IP54-IP67 — 参考: IEC 60529 IP 等级标准 + Cadence guidelines
- 编造材料参数 = FAIL。数据手册数值 vs 供应商声称要分开标注
