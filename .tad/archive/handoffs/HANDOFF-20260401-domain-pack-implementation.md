# Handoff: Domain Pack Framework Implementation

**From:** Alex | **To:** Blake | **Date:** 2026-04-01
**Task ID:** TASK-20260401-002
**Epic:** EPIC-20260401-domain-pack-framework.md (Phase 1/2)

---

## 🔴 Gate 2: ✅ PASS

---

## 1. Task Overview

三个交付物：
1. **tools-registry.yaml** — 统一工具清单（所有 Domain Pack 共用）
2. **product-definition.yaml** — 重写，引用 registry，每个能力有真实工具执行链
3. **TAD 集成** — Alex 能加载 Domain Pack 并调整行为

## 1.1 Intent

**核心价值**: Domain Pack 让 Claude 直接做出东西（PDF、图表、原型、邮件），不是写建议文档。每个能力必须有从"输入→工具调用→产出物"的完整链路。

---

## 📚 必读材料

- `.tad/spike-v3/domain-pack-tools/SUMMARY.md` — 工具调研结果
- `.tad/spike-v3/domain-pack-tools/area-*.md` — 6 个详细报告
- `.tad/spike-v3/ARCHITECTURE-v3.md` — TAD v2.7 架构（hooks 怎么工作）
- `.tad/domains/product-definition.yaml` — 当前草稿（需重写）

---

## 2. Deliverable 1: tools-registry.yaml

**位置**: `.tad/domains/tools-registry.yaml`

基于 SUMMARY.md 的调研结果，创建统一工具清单。每个工具必须包含足够的信息让 Claude 即使从未见过也能使用。

### Schema

```yaml
# .tad/domains/tools-registry.yaml
registry_version: 1
last_updated: "2026-04-01"
maintainer: "Blake (periodic research)"

capabilities:

  pdf_generation:
    description: "生成专业 PDF 文档（报告、one-pager）"
    recommended:
      name: typst
      type: cli
      install: "brew install typst"  # 或已内置
      verify: "typst --version"
      usage: |
        1. Write .typ file with Typst markup
        2. Run: typst compile input.typ output.pdf
      example: |
        // report.typ
        #set page(paper: "a4", margin: 2cm)
        #set text(font: "New Computer Modern", size: 11pt)
        = Product Analysis Report
        == Executive Summary
        This report analyzes...
        
        #table(
          columns: (1fr, 1fr, 1fr),
          [Competitor], [Strength], [Weakness],
          [CompA], [Fast], [Expensive],
        )
      output_format: "PDF file"
      tested: true
      test_result: "39KB professional PDF with tables"
    alternatives:
      - name: pandoc
        type: cli
        install: "brew install pandoc"
        usage: "pandoc input.md --pdf-engine=typst -o output.pdf"
        note: "Uses Typst as PDF engine, accepts Markdown input"

  slideshow_generation:
    description: "Markdown → 可演示的幻灯片"
    recommended:
      name: pandoc-revealjs
      type: cli
      install: "已内置 (pandoc)"
      usage: "pandoc slides.md -t revealjs -s -o slides.html"
      example: |
        ---
        title: Product Pitch
        theme: white
        ---
        # Problem
        Users struggle with...
        ---
        # Solution
        Our product...
      output_format: "HTML file (open in browser)"
      tested: true
    alternatives:
      - name: slidev
        type: cli
        install: "npm init slidev"
        usage: "npx slidev build slides.md"

  diagram_generation:
    description: "生成架构图、流程图、定位图"
    recommended:
      name: d2
      type: cli
      install: "brew install d2"
      verify: "d2 --version"
      usage: "d2 input.d2 output.svg"
      example: |
        # competitive-positioning.d2
        direction: right
        high_price: {style.opacity: 0}
        low_price: {style.opacity: 0}
        simple: {style.opacity: 0}
        complex: {style.opacity: 0}
        
        CompA: Competitor A {
          style.fill: "#ff6b6b"
        }
        OurProduct: "★ Our Product" {
          style.fill: "#51cf66"
        }
      output_format: "SVG or PNG"
      tested: false
      note: "Replaces Mermaid CLI (which fails in sandbox due to Puppeteer)"
    alternatives:
      - name: python-matplotlib
        type: cli
        usage: "python3 chart.py (generates PNG/SVG)"
        note: "Best for data charts, not architecture diagrams"
        tested: true

  data_chart:
    description: "生成数据图表（柱状图、饼图、趋势图）"
    recommended:
      name: python-matplotlib
      type: cli
      install: "已内置 (python3 + matplotlib)"
      verify: "python3 -c 'import matplotlib; print(matplotlib.__version__)'"
      usage: |
        Write Python script using matplotlib, run with python3.
        Save to file: plt.savefig('output.png', dpi=150, bbox_inches='tight')
      example: |
        import matplotlib.pyplot as plt
        categories = ['CompA', 'CompB', 'Us']
        scores = [7, 5, 9]
        plt.bar(categories, scores, color=['#ff6b6b','#ffd93d','#51cf66'])
        plt.title('Feature Comparison')
        plt.savefig('comparison.png', dpi=150, bbox_inches='tight')
      output_format: "PNG or SVG"
      tested: true
      test_result: "34KB PNG + 27KB SVG"

  web_scraping:
    description: "结构化抓取网页内容"
    recommended:
      name: jina-reader
      type: api
      install: "无需安装"
      usage: "WebFetch https://r.jina.ai/{target_url}"
      example: "WebFetch https://r.jina.ai/https://competitor.com/pricing"
      output_format: "Markdown text"
      note: "免费，无需 API key，直接通过 URL 前缀使用"
    alternatives:
      - name: firecrawl-mcp
        type: mcp
        install: "claude mcp add firecrawl -- npx firecrawl-mcp"
        usage: "crawl({url, format: 'markdown'})"
        note: "更强大（全站爬取），但需 API key，500 credits/月免费"

  wireframe_generation:
    description: "生成线框图/UI 原型"
    recommended:
      name: figma-mcp
      type: mcp
      install: "claude plugin install figma@claude-plugins-official"
      usage: "Use Figma MCP tools to create frames, components, text, shapes"
      note: "免费版仅 6 次/月。备选：直接生成 HTML 原型"
      limitations: "Free tier: 6 tool calls/month"
    alternatives:
      - name: html-prototype
        type: builtin
        install: "无需安装"
        usage: "Write tool 生成 HTML+CSS 文件，浏览器打开预览"
        note: "最灵活，无限制，但不能在 Figma 中编辑"

  email_sending:
    description: "发送验证材料给目标用户"
    recommended:
      name: gmail-mcp
      type: mcp-cloud
      install: "Claude.ai 内置，需 OAuth 授权"
      usage: "mcp__claude_ai_Gmail__send_email({to, subject, body})"
      note: "需先 authenticate"

  calendar_scheduling:
    description: "安排验证访谈时间"
    recommended:
      name: google-calendar-mcp
      type: mcp-cloud
      install: "Claude.ai 内置，需 OAuth 授权"
      usage: "mcp__claude_ai_Google_Calendar__gcal_create_event({...})"

  presentation_generation:
    description: "生成精美演示文稿/pitch deck"
    recommended:
      name: gamma-mcp
      type: mcp-cloud
      install: "Claude.ai 内置，需 OAuth 授权"
      usage: "Gamma MCP tools for AI-generated presentations"
      note: "最美观的选择，但需要 Gamma 账号"
    alternatives:
      - name: pandoc-revealjs
        type: cli
        note: "见 slideshow_generation"

  poster_design:
    description: "生成海报、one-pager 设计"
    recommended:
      name: canva-mcp
      type: mcp-cloud
      install: "Claude.ai 内置，需 OAuth 授权"
      usage: "Canva MCP tools for design creation"
    alternatives:
      - name: typst
        type: cli
        note: "用 Typst 排版生成 PDF one-pager（不如 Canva 美观但无限制）"
```

### 要求
- 每个 recommended 必须有 install + verify + usage + example（或 note 解释为什么没有）
- tested 字段标注是否实测过
- alternatives 至少 1 个
- **d2 必须实测**（当前 tested: false，是首选图表工具）— 如果失败则降级为 alternative

### Pre-flight 验证协议
每次使用 Domain Pack 工具前，必须先验证工具可用：
```bash
# Blake 执行前必须运行
for tool in typst pandoc python3 d2; do
  which $tool && echo "$tool: OK" || echo "$tool: NOT FOUND"
done
```
如果 recommended 工具不可用 → 自动使用 alternatives 中的下一个

---

## 3. Deliverable 2: product-definition.yaml 重写

**位置**: `.tad/domains/product-definition.yaml`（覆盖现有草稿）

### 重写原则
1. 每个能力的执行步骤必须引用 tools-registry.yaml 中的工具
2. 产出物必须是**文件**（不是对话中的文字）
3. 每个步骤写清"用什么工具→产出什么文件→存在哪里"
4. 顶层加 `requires_registry: ">=1"` 字段（版本兼容性检查）

### product-definition.yaml 能力 YAML 示例（Blake 按此格式写所有能力）

```yaml
requires_registry: ">=1"

capabilities:
  competitive_analysis:
    description: "找到竞品、分析优劣、发现差异化机会"
    
    steps:
      - id: search_competitors
        action: "搜索 5+ 竞品（3 直接 + 2 间接）"
        tool_ref: web_scraping  # 引用 tools-registry.yaml 的 key
        queries:
          - '"{领域}" solution OR tool OR app'
          - '"site:producthunt.com {领域}"'
          - '"{领域}" workaround OR hack'
        output_file: "competitive-analysis.md"
        
      - id: scrape_details
        action: "抓取每个竞品的功能/定价页面"
        tool_ref: web_scraping
        output_file: "competitive-analysis.md (append)"
        
      - id: generate_positioning_map
        action: "生成 2x2 竞品定位图"
        tool_ref: diagram_generation
        input: "竞品数据 from step 1-2"
        output_file: "competitive-matrix.svg"
        
      - id: generate_feature_chart
        action: "生成功能对比柱状图"
        tool_ref: data_chart
        output_file: "feature-comparison.png"
        
      - id: compile_report
        action: "综合为结构化报告"
        tool_ref: pdf_generation  # 如果需要 PDF 版
        output_file: "competitive-analysis.pdf"

    output_dir: ".tad/active/research/{project}/"
    
    quality_criteria:
      - "≥5 个竞品（含替代方案）"
      - "定位图有两个有意义的维度"
      - "每个竞品有真实的功能/定价数据"
    
    reviewers:
      - persona: "市场分析师"
        checklist:
          - "竞品列表是否完整"
          - "差异化机会是否有依据"
```

### 产出物文件规范

```
.tad/active/research/
├── {project}/
│   ├── user-research.md          # 用户研究报告
│   ├── competitive-analysis.md   # 竞品分析
│   ├── competitive-matrix.svg    # 竞品定位图 (D2 生成)
│   ├── market-chart.png          # 市场数据图表 (matplotlib)
│   ├── PRD.md                    # 产品需求文档
│   ├── PRD.pdf                   # PDF 版 (Typst 生成)
│   ├── one-pager.typ             # One-pager 源文件
│   ├── one-pager.pdf             # One-pager PDF (可发送)
│   ├── pitch-slides.md           # 演示文稿源文件
│   ├── pitch-slides.html         # 幻灯片 (reveal.js)
│   └── validation-round-{N}.md   # 验证反馈记录
```

### 能力→工具映射（必须在重写中体现）

| 能力 | 步骤 | 工具 (registry 引用) | 产出文件 |
|------|------|---------------------|---------|
| 用户研究 | 搜索用户反馈 | WebSearch + jina-reader | user-research.md |
| 用户研究 | 市场数据图表 | python-matplotlib | market-chart.png |
| 竞品分析 | 抓取竞品页面 | jina-reader / firecrawl | competitive-analysis.md |
| 竞品分析 | 生成定位图 | d2 | competitive-matrix.svg |
| 竞品分析 | 功能对比图表 | python-matplotlib | feature-comparison.png |
| PRD | 生成文档 | Write | PRD.md |
| PRD | 转 PDF | typst | PRD.pdf |
| 验证-one pager | 生成 one-pager | typst | one-pager.pdf |
| 验证-pitch | 生成幻灯片 | pandoc-revealjs | pitch-slides.html |
| 验证-原型 | 线框图 | figma-mcp / html | prototype.html |
| 验证-发送 | 邮件发送 | gmail-mcp | (sent) |
| 验证-约谈 | 安排时间 | google-calendar-mcp | (scheduled) |

---

## 4. Deliverable 3: TAD 集成

### 4.1 Alex 如何加载 Domain Pack

在 Alex SKILL.md 的 Intent Router 中加入 domain detection：

```
用户描述任务 → Intent Router
  ↓
检测是否有 .tad/domains/*.yaml
  ↓ 有
AskUserQuestion: "检测到 Domain Pack。这个任务属于哪个领域？"
  选项: [列出所有 .tad/domains/*.yaml]
  ↓ 用户选择
加载对应 domain.yaml → 读取 capabilities + socratic + gates + reviewers
  ↓
苏格拉底提问使用 domain.yaml 中的维度
Gate 检查使用 domain.yaml 中的标准
```

### 4.2 实现方式

**不修改 Alex SKILL.md 主体**。用 SessionStart hook 检测 domains/ 目录并注入 context：

在 `.tad/hooks/startup-health.sh` 中添加 domain detection：
```bash
# Domain Pack detection
DOMAIN_COUNT=$(ls .tad/domains/*.yaml 2>/dev/null | grep -v tools-registry | wc -l | tr -d ' ')
if [ "$DOMAIN_COUNT" -gt 0 ]; then
  DOMAINS=$(ls .tad/domains/*.yaml 2>/dev/null | grep -v tools-registry | xargs -I{} basename {} .yaml | tr '\n' ', ')
  DOMAIN_INFO="Domain Packs available: ${DOMAINS}"
fi
```

这样 Alex 启动时就知道有哪些 Domain Pack 可用，在 Intent Router 中可以建议用户选择。

### 4.3 Blake 如何使用工具

Blake 在执行 Domain Pack 相关的 handoff 时：
1. 读 `tools-registry.yaml` 获取工具使用方法
2. 按 `product-definition.yaml` 的执行步骤依次调用工具
3. 产出文件存入 `.tad/active/research/{project}/`

---

## 5. Acceptance Criteria

- [ ] AC1: `tools-registry.yaml` 创建，≥10 个能力，每个有 recommended + alternatives
- [ ] AC2: 每个 recommended 工具有 install + usage + example
- [ ] AC3: `product-definition.yaml` 重写完成，所有能力引用 registry 工具
- [ ] AC4: 每个能力有完整的"工具→产出文件→存储路径"链路
- [ ] AC5: `startup-health.sh` 更新，检测 Domain Pack 可用性
- [ ] AC6: 产出物目录结构定义清晰 (`.tad/active/research/{project}/`)
- [ ] AC7: d2 工具实测通过（生成 SVG/PNG 图表）
- [ ] AC8: 至少 1 个完整能力端到端测试（如竞品分析：WebSearch → Jina 抓取 → D2 定位图 → Typst PDF）
- [ ] AC9: 现有 TAD 功能不受影响（hooks、skills、gates 正常）
- [ ] AC10: Pre-flight 验证脚本能检测工具可用性

---

## 6. Important Notes

- ⚠️ 不要修改 Alex/Blake SKILL.md 主体（只改 startup-health.sh hook）
- ⚠️ `product-definition.yaml` 草稿已存在，直接覆盖重写
- ⚠️ 端到端测试选一个 Tier 1 工具能力（如 Typst 生成 PDF），不要选需要 OAuth 的
- ⚠️ 参考 `.tad/spike-v3/domain-pack-tools/SUMMARY.md` 的实测结果

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-01
