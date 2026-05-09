# Mini-Handoff: Domain Pack End-to-End Functional Test

**From:** Alex | **To:** Blake | **Date:** 2026-04-01
**Type:** Automated E2E Test

---

## Task

用 Agent tool spawn 一个测试 agent，模拟真实用户使用 Product Definition Domain Pack 的完整流程。测试议题：**"AI 驱动的宠物健康监测项链"**。

## Test Scenario

测试 agent 扮演用户，按以下 prompt 序列执行。每个 step 验证 Domain Pack 的一个能力。

### Step 1: Domain Pack 识别

Spawn agent with prompt:
```
你是一个产品经理。你要做一个新产品："AI 驱动的宠物健康监测项链"。

先读取 .tad/domains/product-definition.yaml，了解可用的 capabilities。
然后告诉我：
1. 这个文件存在吗？
2. 有哪些 capabilities？
3. 每个 capability 的第一个 step 是什么？

然后读取 .tad/domains/tools-registry.yaml，报告：
4. 有哪些工具可用？
5. web_scraping 的 recommended 工具是什么？

PASS 条件：能读取并正确报告 domain pack 内容。
```

### Step 2: 用户研究（WebSearch + 数据收集）

Spawn agent with prompt:
```
你在做"AI 宠物健康监测项链"的用户研究。

按照 .tad/domains/product-definition.yaml 的 user_research capability 执行：

1. 执行 search_social step：用 WebSearch 搜索 "pet health monitoring wearable pain point" 和 "smart pet collar review complaint"，收集至少 3 条用户真实反馈
2. 执行 scrape_reviews step：搜索现有宠物智能设备的差评
3. 执行 market_data step：搜索宠物科技市场规模数据

将结果写入 .tad/active/research/pet-health-test/user-research.md，格式按 domain pack 的 quality_criteria 要求：
- 每条痛点有用户原话 + URL
- 市场数据有来源
- 标注置信度

PASS 条件：文件创建，包含真实搜索数据（不是编造的），有 URL 引用。
```

### Step 3: 竞品分析（WebSearch + D2 图表）

Spawn agent with prompt:
```
你在做"AI 宠物健康监测项链"的竞品分析。

按照 .tad/domains/product-definition.yaml 的 competitive_analysis capability 执行：

1. search_competitors：用 WebSearch 找 5+ 个竞品（智能宠物项圈/手环/监测设备）
2. scrape_details：获取每个竞品的功能和定价
3. generate_positioning_map：用 D2 (参考 tools-registry.yaml 的 diagram_generation) 生成竞品定位图 SVG
   - X 轴：价格（低→高）
   - Y 轴：功能丰富度（少→多）
4. generate_feature_chart：用 Python matplotlib 生成功能对比柱状图 PNG

将结果写入 .tad/active/research/pet-health-test/：
- competitive-analysis.md（竞品矩阵表格）
- competitive-matrix.svg（D2 定位图）
- feature-comparison.png（matplotlib 图表）

PASS 条件：3 个文件都创建成功，竞品数据来自真实搜索。
```

### Step 4: 验证材料生成（Typst PDF）

Spawn agent with prompt:
```
你在做"AI 宠物健康监测项链"的验证材料。

基于前面的研究（读取 .tad/active/research/pet-health-test/ 下的文件），生成一个 One-Pager PDF：

1. 用 Typst（参考 tools-registry.yaml 的 pdf_generation）创建 one-pager：
   - 问题描述（1 段）
   - 方案概述（1 段）
   - 竞品差异化（表格）
   - Call to Action

2. 编译为 PDF：typst compile one-pager.typ one-pager.pdf

将文件写入 .tad/active/research/pet-health-test/：
- one-pager.typ（源文件）
- one-pager.pdf（编译后）

PASS 条件：PDF 文件生成成功，> 0 bytes。
```

### Step 5: 汇总报告

最后一个 agent 汇总所有测试结果：
```
检查 .tad/active/research/pet-health-test/ 目录下的所有文件。

验证：
1. user-research.md 存在且包含 WebSearch URL 引用？
2. competitive-analysis.md 存在且包含 ≥5 个竞品？
3. competitive-matrix.svg 存在且 > 0 bytes？
4. feature-comparison.png 存在且 > 0 bytes？
5. one-pager.pdf 存在且 > 0 bytes？

输出汇总：

| # | 文件 | 存在 | 内容验证 | PASS/FAIL |
|---|------|------|---------|-----------|
| 1 | user-research.md | ✅/❌ | 有URL引用? | ... |
| 2 | competitive-analysis.md | ✅/❌ | ≥5竞品? | ... |
| 3 | competitive-matrix.svg | ✅/❌ | >0 bytes? | ... |
| 4 | feature-comparison.png | ✅/❌ | >0 bytes? | ... |
| 5 | one-pager.pdf | ✅/❌ | >0 bytes? | ... |

总结：X/5 PASS

测试完成后，删除 .tad/active/research/pet-health-test/ 目录（清理测试数据）。
```

---

## Implementation

Blake 按 Step 1-5 顺序 spawn agent 执行。每个 step 可以是独立的 agent（确保 fresh context）。

**关键**：Step 2 和 3 必须用 **真实的 WebSearch**（不是编造数据），Step 3 必须**真的运行 D2 和 matplotlib**，Step 4 必须**真的运行 typst compile**。

---

## Acceptance Criteria

- [ ] AC1: Step 1 — Domain Pack 识别 PASS
- [ ] AC2: Step 2 — user-research.md 包含真实搜索数据 + URL
- [ ] AC3: Step 3 — competitive-analysis.md + .svg + .png 三个文件生成
- [ ] AC4: Step 4 — one-pager.pdf 生成成功
- [ ] AC5: Step 5 — 汇总 ≥4/5 PASS
- [ ] AC6: 测试目录清理

---

## Notes

- ⚠️ 全程用 Agent tool spawn，不手动开 terminal
- ⚠️ WebSearch 必须真实执行（不是 mock）
- ⚠️ D2/matplotlib/Typst 必须真实运行
- ⚠️ 如果某个工具失败，记录原因，不要跳过
