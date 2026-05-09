# Handoff: Product Definition Domain Pack — 深度升级

**From:** Alex | **To:** Blake | **Date:** 2026-04-01
**Type:** Quality Iteration (修改现有文件)

---

## Problem

E2E 测试证明工具链通了，但产出物质量不够。根因：domain.yaml 的 steps 只有"搜索→拼接→生成"，缺少**分析（So What）和推导（Therefore）**步骤。

三个核心缺陷：
1. 用户研究只搜不分析（没有用户细分、没有痛点深度排序）
2. 竞品分析只列不比（没有"为什么它能活"、"为什么用户会离开"的深度分析）
3. One-pager 数据是编的（定价、融资金额没有推导依据）

## ⚠️ 必读参考材料

**在修改 product-definition.yaml 之前，必须先读这个文件：**

📖 **`.tad/spike-v3/domain-pack-tools/pm-skills-best-practices.md`**

这是 Alex 研究了 5 个 GitHub PM Skills 仓库后提取的最佳实践汇总。每个 capability 的深化步骤必须**基于这些研究成果设计**，不是自己编。

具体参考映射：
- 用户细分 → product-on-purpose/foundation-persona 的 11 维度 + 证据置信度
- 痛点排序 → phuryn/sentiment-analysis 的量化方法 + deanpeters 饱和度检查
- 竞品深度分析 → product-on-purpose 的 7 步法 + Full/Partial/None/Unknown 矩阵
- 定位推导 → April Dunford 6 步法 + Geoffrey Moore 模板
- 假设验证 → phuryn 的 8 类风险 + XYZ 假设格式
- 定价推导 → 竞品锚点 + 支付意愿信号 + 成本倒推
- 验证材料 → deanpeters 的 Working Backwards + phuryn 的 pretotype

## Fix: 基于研究成果深化每个 capability

修改 `.tad/domains/product-definition.yaml`。对每个 capability，在现有 steps 之间插入分析和推导步骤。**每个新步骤的设计必须引用 pm-skills-best-practices.md 中的具体框架。**

### Capability 1: user_research — 加深

在现有的 search steps 之后，compile 之前，插入：

```yaml
      - id: segment_users
        action: |
          基于搜索数据，识别用户细分群体：
          1. 至少区分 3 个用户群体（按使用场景/人口特征/付费意愿）
          2. 每个群体：谁是他们、多大规模、核心痛点是什么
          3. 标注哪个群体的痛点最尖锐（频率 × 严重度）
          4. 如果搜索数据不足以区分 → 诚实标注"数据不足，需要访谈验证"
        quality: "每个群体描述必须有搜索证据支撑，不接受假设性分类"
        output_file: "user-research.md (append)"

      - id: prioritize_pains
        action: |
          对所有发现的痛点做优先级排序：
          | 痛点 | 提及频率 | 严重度 | 现有解决方案 | 机会大小 |
          每个痛点必须回答：
          - 有多少人提到这个问题？（频率）
          - 没有这个功能会怎样？（严重度）
          - 现在怎么解决的？解决得好吗？（竞争空白）
        quality: "排序必须基于数据，不是直觉。频率来自搜索命中数。"
        output_file: "user-research.md (append)"
```

同时升级 quality_criteria：
```yaml
    quality_criteria:
      - "用户画像基于 ≥5 个不同来源的真实数据"
      - "每条痛点有用户原话引用和 URL"
      - "市场数据有可信来源（不接受无来源估算）"
      - "市场数据矛盾时必须分析原因（不能只说'定义不同'）"  # 新增
      - "至少识别 3 个用户细分群体"  # 新增
      - "痛点按频率×严重度排序，有数据支撑"  # 新增
      - "置信度标注诚实（Low 不丢人，编造才丢人）"
```

### Capability 2: competitive_analysis — 加深

在 scrape_details 之后，generate_positioning_map 之前，插入：

```yaml
      - id: deep_analyze
        action: |
          对每个竞品回答 4 个深度问题：
          1. 它为什么能活下来？（核心不可替代优势是什么）
          2. 用户最不满意什么？（必须引用 1-2 星评论原文）
          3. 它没做什么？为什么没做？（刻意选择 vs 能力不足）
          4. 用户会因为什么原因离开它？（流失信号）
          
          每个问题的回答必须有证据（评论 URL、产品页截图描述）。
          推测标注为 [ASSUMPTION]。
        quality: "不接受'功能丰富'这种空话。必须具体到哪个功能、什么评价。"
        output_file: "competitive-analysis.md (append)"

      - id: derive_positioning
        action: |
          基于深度分析推导定位：
          1. 市场空白在哪？（所有竞品都没做好的事，且有用户在抱怨）
          2. 这个空白有多大？（抱怨的用户有多少？愿意付多少钱？）
          3. 我们凭什么能做好？（别人没做的原因是什么？我们能绕过吗？）
          4. 如果结论是"没有明确空白" → 诚实输出 "⚠️ 差异化风险高"
          
          最终输出一句话定位：
          "For [谁] who [痛点], [产品] is the [类别] that [差异化]."
          这句话的每个词必须有前面研究数据的支撑。
        quality: "定位声明中的每个 claim 必须可追溯到具体研究数据。编造 = FAIL。"
        output_file: "competitive-analysis.md (append)"
```

升级 quality_criteria：
```yaml
    quality_criteria:
      - "≥5 个竞品（含直接+间接+替代方案）"
      - "功能矩阵用 Full/Partial/None/Unknown — 有证据才标 Full"  # 强化
      - "每个竞品有 4 问深度分析（为何活/用户不满/没做什么/流失原因）"  # 新增
      - "定位图维度基于研究数据选择，不是随意画"  # 新增
      - "差异化定位有数据支撑，不是'我觉得'"  # 新增
      - "找不到差异化 → 诚实输出风险警告"  # 新增
```

### Capability 3: product_definition — 加深

在 mvp_scope 之后，generate_prd 之前，插入：

```yaml
      - id: validate_assumptions
        action: |
          列出 PRD 中所有关键假设，对每个回答：
          | 假设 | 证据 | 置信度 | 如果错了会怎样 | 验证方法 |
          
          关键假设至少包括：
          - 定价假设（为什么是这个价？基于什么数据？）
          - 用户量假设（市场有多大？我们能拿多少？依据？）
          - 差异化假设（用户真的在乎这个差异吗？证据？）
          
          没有证据的假设标注 [UNVALIDATED] — 这些是验证阶段必须测试的。
        quality: "定价必须有推导过程（竞品价格×系数、用户支付意愿调研），不接受凭空编号。"
        output_file: "PRD.md (append)"
```

升级 quality_criteria：
```yaml
    quality_criteria:
      - "问题可以一句话说清（≤50 字）"
      - "MVP ≤ 5 个功能，Out of Scope ≥ 3 条"
      - "成功指标可测量（有基线和目标）"
      - "定价有推导过程，不是编的"  # 新增
      - "每个关键假设标注证据和置信度"  # 新增
      - "无证据假设标注 [UNVALIDATED]"  # 新增
      - "PRD 15 分钟内可读完"
```

### Capability 4: quick_validation — 加深

在 generate_artifact 之后，send_to_targets 之前，插入：

```yaml
      - id: verify_artifact_claims
        action: |
          审查验证材料中的每一个 claim：
          | Claim | 数据来源 | 可追溯 | 需要修改 |
          
          检查：
          - 产品名/定价/融资金额是否有依据？
          - 市场数据是否来自研究阶段？
          - 用户痛点是否有原话支撑？
          
          编造的数据 → 删除或标注为"待验证"
          不确定的 claim → 改为问句（"您愿意为这个功能付 $X 吗？"）
        quality: "验证材料中零编造数据。不确定的转为验证问题。"
```

---

## Acceptance Criteria

- [ ] AC1: user_research 增加 segment_users + prioritize_pains 步骤
- [ ] AC2: competitive_analysis 增加 deep_analyze + derive_positioning 步骤
- [ ] AC3: product_definition 增加 validate_assumptions 步骤
- [ ] AC4: quick_validation 增加 verify_artifact_claims 步骤
- [ ] AC5: 每个 capability 的 quality_criteria 已强化
- [ ] AC6: 修改后的 yaml 语法正确
- [ ] AC7: validate_assumptions 使用 phuryn 的 8 类风险框架（不是只有 3 类）
- [ ] AC8: 用 self-test agent 重跑"宠物项链"测试，对比检查：
  - 用户研究：是否有用户细分（≥3 群体）+ 痛点排序？
  - 竞品分析：是否有 4 问深度分析 + 定位推导（有数据支撑）？
  - One-pager：定价是否有推导过程（不是编的）？
  - 如果以上 3 个都改善 → PASS

---

## Notes

- ⚠️ 只改 product-definition.yaml，不改 registry 或 hooks
- ⚠️ AC7 是关键：改完后必须重新跑 E2E 测试看质量是否提升
- ⚠️ 新增步骤不需要新工具 — 分析和推导靠 LLM 思考能力，不靠外部工具

**Handoff Created By**: Alex
