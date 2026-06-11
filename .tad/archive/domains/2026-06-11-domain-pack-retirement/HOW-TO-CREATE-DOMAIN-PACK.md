# How to Create a Domain Pack

> 基于 Product Definition Domain Pack 的实际创建经验总结。
> 适用于任何新领域的 Domain Pack 创建。

---

## 什么是 Domain Pack

Domain Pack = 一个 YAML 配置文件，让 TAD 能在特定领域"做事"。

它不是知识库（Claude 已有领域知识），而是**行动配置**：
- 用什么**工具**做事
- 按什么**流程**做事
- 做到什么**标准**
- 怎么**验证**做对了

**核心原则**：
- 做事时不设域限制（Claude 用全部知识）
- 审查时设专家视角（Persona + Checklist）
- CLI 工具优先，MCP 只用于有状态/远程服务
- 工具描述要足够详细（Claude 可能不认识新工具）

---

## 创建流程（6 步）

### Step 1: 定义领域的 Capabilities

**目的**：这个领域需要做哪些事？

**做法**：
1. 列出这个领域从头到尾要完成的核心任务
2. 每个任务 = 一个 capability
3. 不按职位分（PM/Designer/Developer），按"要做什么事"分

**示例（Product Definition）**：
```
user_research        — 搜索和分析目标用户
competitive_analysis — 找到竞品并深度分析
product_definition   — 定义问题、价值主张、MVP 范围
quick_validation     — 生成验证材料、收集反馈
```

**检查**：每个 capability 是否有明确的输入→输出？

---

### Step 2: 研究现有 Skills

**目的**：不要从零写。找到市面上已有的同类 Skills，提取最佳实践。

**做法**：
1. WebSearch 搜索 GitHub 上的相关 skills:
   - `"GitHub claude skills {领域} SKILL.md"`
   - `"GitHub AI agent {领域} skill prompt"`
   - `"GitHub awesome claude skills {领域}"`
2. 找到 3-5 个最受欢迎的仓库
3. 对每个仓库，提取：
   - 它定义了哪些步骤？（步骤深度）
   - 它引用了哪些来源/工具？（来源清单）
   - 它用了什么框架？（分析框架）
   - 它的质量标准是什么？（质量门控）
   - 它列了哪些反模式？（常见错误）
4. 把最佳实践整理成参考文档

**产出**：`.tad/spike-v3/domain-pack-tools/{domain}-skills-best-practices.md`

**为什么重要**：这些研究成果会直接决定 domain.yaml 每个 step 的分析深度。
跳过这步 = 写出来的步骤很浅 = 产出物质量不够。

---

### Step 3: 研究可用工具

**目的**：找到这个领域可用的 CLI/MCP/API 工具。

**做法**：
1. 对每个 capability，搜索可用工具:
   - `"GitHub MCP server {领域工具}"`
   - `"{领域工具} CLI command line"`
   - `"Claude Code {领域} tool integration"`
2. 评估每个工具：
   - Claude Code 里能用吗？
   - 免费额度？
   - 安装复杂度？
   - 实际测试能跑通吗？
3. 选出推荐工具

**产出**：更新 `.tad/domains/tools-registry.yaml`

**工具描述必须包含**（Claude 可能不认识新工具）：
```yaml
name: tool-name
type: cli|mcp|api
install: "安装命令"
verify: "验证命令"
usage: "使用方法"
example: "具体调用示例"
output: "产出什么格式"
```

**检查**：是否每个 capability 都有至少一个可用工具？纯对话的 capability（如问题定义）不需要工具，标注 `tool_ref: null`。

---

### Step 4: 写 domain.yaml

**目的**：把 capabilities + 研究成果 + 工具 组合成 Domain Pack 配置。

**文件位置**：`.tad/domains/{domain-name}.yaml`

**结构**：
```yaml
domain: {domain-name}
version: 1.0.0
requires_registry: ">=1"
description: "{一句话描述}"

output_dir: ".tad/active/research/{project}/"

capabilities:

  {capability_name}:
    description: "{做什么}"

    steps:
      # 搜索/收集步骤
      - id: {action_id}
        action: "{具体做什么}"
        tool_ref: {tools-registry 中的 key}
        queries: ["{搜索词模板}"]  # 如果是搜索类
        output_file: "{产出文件名}"

      # ⚠️ 分析步骤（不能只有搜索，必须有分析）
      - id: analyze_{what}
        action: |
          基于搜索数据回答：
          1. {分析问题 1}
          2. {分析问题 2}
          3. {分析问题 3}
          每个回答必须有证据支撑。
        quality: "{证据标准}"
        output_file: "{文件名}"

      # ⚠️ 推导步骤（从分析到结论）
      - id: derive_{what}
        action: |
          基于分析推导：
          1. {推导什么结论}
          2. {如果没有明确结论 → 诚实输出}
        quality: "{结论必须基于数据}"
        output_file: "{文件名}"

      # 生成步骤（用工具产出文件）
      - id: generate_{what}
        action: "{生成什么}"
        tool_ref: {工具}
        output_file: "{文件名}"

    quality_criteria:
      - "{可量化的标准 1}"
      - "{可量化的标准 2}"
      - "{诚实标准：找不到就说找不到}"

    anti_patterns:
      - "❌ {常见错误 1}"
      - "❌ {常见错误 2}"

    reviewers:
      - persona: "{审查视角}"
        checklist:
          - "{检查项 1}"
          - "{检查项 2}"

output_structure: |
  .tad/active/research/{project}/
  ├── {文件 1}
  ├── {文件 2}
  └── ...

gates:
  gate2_design:
    checklist: [...]
  gate4_acceptance:
    checklist: [...]
```

**关键规则**：

Domain Pack 分两类，step 模型不同：

| 类型 | 适用 | Step 模型 | 防止什么 |
|------|------|----------|---------|
| **文档/研究类** | product-definition, 竞品分析, 法律, 金融 | 搜索→分析→推导→生成 | 搜索拼接、编造数据、分析太浅 |
| **代码/工具类** | frontend, backend, testing, 部署 | 选型→执行→验证→优化 | 选错方案、代码跑不通、质量缺检查 |

**每个 capability 单独判断用哪种模型。** 同一个 pack 内可以混合。
- 文档类 capability 的核心是分析+推导（防"写空话"）
- 代码类 capability 的核心是验证+优化（防"跑不通"）
- 如果某个 capability 天然简单（如 scaffold = 跑一个命令），不需要硬套四层

其他规则不变：
- 分析步骤的 action 必须基于 Step 2 的研究成果（不能自己编）
- quality_criteria 必须可量化（"≥5 个"而不是"足够多"）
- 编造数据 = FAIL（必须在标准中明确）

---

### Step 5: 测试和验证

**目的**：验证 Domain Pack 能产出有质量的交付物。

**做法**：
1. 选一个测试议题（虚拟但具体的项目）
2. 用 self-test agent 跑完整流程：
   - 每个 capability 执行一遍
   - 检查产出文件是否存在
   - 检查内容质量（有真实数据？有分析深度？有推导？）
3. 对比"有 Domain Pack" vs "没有 Domain Pack"的产出差异

**验证标准**：
- 工具链通了？（文件生成成功）
- 搜索做了？（有 URL 引用）
- 分析深了？（有"So What"和"Therefore"）
- 数据真了？（没有编造的数字）

**如果质量不够** → 回到 Step 4 深化分析步骤（这就是我们的 Product Definition 经历）

---

### Step 6: 同步和发布

**目的**：让其他项目也能用这个 Domain Pack。

**做法**：
1. 确保 tools-registry.yaml 包含新 pack 需要的所有工具
2. 用 `*sync` 同步到注册的项目
3. 在其他项目的新 session 中验证 hook 输出包含新 domain

---

## 常见错误

| 错误 | 后果 | 避免方法 |
|------|------|---------|
| 跳过 Step 2（不研究现有 Skills） | 步骤太浅，产出质量不够 | 至少研究 3 个同类仓库 |
| 只有搜索步骤没有分析步骤 | 搜索→拼接→产出 = 表面文章 | 每个 capability 必须有 analyze + derive |
| 工具描述不够详细 | Claude 不知道怎么用新工具 | 每个工具必须有 install + usage + example |
| quality_criteria 太模糊 | "足够好"没有判断标准 | 用数字（≥5 个、≤50 字、15 分钟可读完） |
| 域知识当 persona 约束 | 限制 Claude 的思维广度 | 做事时提供 context 不加 persona，审查时才加 |
| 不做 E2E 测试 | 不知道产出质量是否达标 | 每个新 pack 必须跑一次完整测试 |

---

## 文件结构总结

```
.tad/domains/
├── HOW-TO-CREATE-DOMAIN-PACK.md    # 本文件
├── tools-registry.yaml              # 统一工具清单（所有 pack 共用）
├── product-definition.yaml          # 第一个 Domain Pack
├── {new-domain}.yaml                # 未来新增的 pack
└── ...

.tad/spike-v3/domain-pack-tools/
├── pm-skills-best-practices.md      # Product Definition 的研究参考
├── {domain}-skills-best-practices.md # 未来新 pack 的研究参考
└── SUMMARY.md                       # 工具调研汇总
```
