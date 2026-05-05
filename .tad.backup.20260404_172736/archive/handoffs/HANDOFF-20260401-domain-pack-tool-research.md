# Handoff: Domain Pack Tool Research

**From:** Alex | **To:** Blake | **Date:** 2026-04-01
**Type:** Research Spike (no code implementation)
**Epic:** Domain Pack Framework (pre-Epic research)

---

## Task

Research and evaluate available CLI/MCP/API tools for each capability in the Product Definition Domain Pack. For each capability area, find the best tools that Claude Code can actually use to PRODUCE DELIVERABLES (not just write text).

**Core principle**: Domain Pack's value = 让 AI 直接做出东西（原型、图表、PDF、邮件），不是写建议文档。

---

## Research Areas

### Area 1: 设计与原型工具

**需求**: 能在 Claude Code 里直接生成线框图、原型、UI 概念图

**候选工具（需评估）**:
- Figma MCP (官方) — 创建/修改 Figma 设计
- Frame0 MCP — 自然语言生成线框图
- MockFlow WireframePro MCP — HTML→线框图
- Excalidraw — 手绘风格图
- 其他你搜索到的

**评估维度**:
- 在 Claude Code 里能否直接调用？
- 输出质量如何？（截图或描述）
- 速度和可靠性？
- 免费/付费？限额？
- 安装复杂度？

### Area 2: 数据研究与抓取工具

**需求**: 能结构化抓取竞品页面、市场数据、用户评论

**候选工具**:
- Firecrawl MCP — 结构化网页抓取
- Brave Search API — 结构化搜索结果
- Tavily Search API — AI 搜索
- Jina Reader — URL→Markdown
- ScrapeGraph — AI 驱动抓取
- 其他

**评估维度**: 同上 + 抓取准确性、反爬能力

### Area 3: 文档生成与转换工具

**需求**: 能把 Markdown/HTML 转为可分享的 PDF/演示文稿/海报

**候选工具**:
- Pandoc CLI — Markdown→PDF/DOCX/PPT
- wkhtmltopdf — HTML→PDF
- reveal.js / Slidev — Markdown→幻灯片
- Canva MCP (云) — 生成海报/设计
- Gamma MCP (云) — AI 生成演示文稿
- Typst CLI — 现代排版
- 其他

**评估维度**: 同上 + 输出美观度、模板丰富度

### Area 4: 图表与可视化工具

**需求**: 能生成竞品定位图、用户旅程图、流程图、数据图表

**候选工具**:
- Mermaid CLI — 流程图/序列图/旅程图
- PlantUML — UML 图
- D2 — 声明式图表
- Vega-Lite CLI — 数据可视化
- Python matplotlib/seaborn — 图表
- ASCII 图表（内置能力）
- 其他

### Area 5: 沟通与分发工具

**需求**: 能直接发送验证材料给目标用户、安排访谈

**候选工具**:
- Gmail MCP (云) — 发邮件
- Google Calendar MCP (云) — 安排时间
- Slack MCP — 发消息
- 其他

### Area 6: 搜索 GitHub 上其他 Domain Pack 类似项目

**额外研究**: 搜索是否有人已经做了类似 Domain Pack 的东西 — 不只是 PM skills，而是带真实工具集成的领域能力包。

---

## 输出要求

### 核心产出：`.tad/domains/tools-registry.yaml`

这是一个**统一工具清单**，所有 Domain Pack 共用。格式：

```yaml
# .tad/domains/tools-registry.yaml
# 统一工具清单 — 所有 Domain Pack 引用此文件
# 维护者: Blake (定期调研更新)
# 最后更新: {date}

registry_version: 1
last_updated: "2026-04-01"

tools:

  # ── 设计与原型 ──
  wireframe_generation:
    description: "生成可编辑的线框图/原型"
    recommended:
      name: "{best tool}"
      type: "mcp|cli|api"
      install: "{安装命令}"
      usage: "{调用方式}"
      example: |
        {具体调用示例，Claude 能直接复制使用}
      output: "{产出什么格式的文件}"
      limitations: "{限制/额度}"
    alternatives:
      - name: "{备选1}"
        type: "..."
        install: "..."
        usage: "..."
      - name: "{备选2}"
        # ...

  # ── 数据研究 ──
  web_scraping:
    description: "结构化抓取网页内容"
    recommended: { ... }
    alternatives: [ ... ]

  # ── 文档生成 ──
  document_to_pdf:
    description: "Markdown/HTML → 可分享的 PDF"
    recommended: { ... }
    alternatives: [ ... ]

  # ... 更多工具能力
```

**关键要求**：每个 recommended 工具必须包含足够的 usage + example 信息，让 Claude 即使从未见过这个工具也能使用它。

### 辅助产出：评估报告

每个 Area 的调研过程记录到 `.tad/spike-v3/domain-pack-tools/area-{N}-{name}.md`（评估矩阵 + 实测记录）。

---

## Acceptance Criteria

- [ ] `.tad/domains/tools-registry.yaml` 已创建
- [ ] 包含 ≥6 个能力类别的工具推荐
- [ ] 每个 recommended 有完整的 install + usage + example
- [ ] 至少 3 个工具有实际测试记录
- [ ] 6 个 Area 各有评估报告（`.tad/spike-v3/domain-pack-tools/`）

---

## Important Notes

- ⚠️ 这是研究任务，**不要修改任何 TAD 文件**
- ⚠️ 如果需要安装工具测试，用临时目录，不要装到全局
- ⚠️ 重点评估 **MCP 工具**（Claude Code 原生集成）和 **CLI 工具**（Bash 调用）
- ⚠️ 注意区分"看起来能用"和"实际在 Claude Code 里能用"
