# Domain Pack Tool Research — Summary Report

**Date**: 2026-04-01
**Task**: TASK-20260401 Domain Pack Tool Research Spike

---

## Executive Summary

Researched 20+ tools across 6 capability areas. **Key finding**: CLI tools (Typst, Pandoc, matplotlib, D2) are production-ready today with zero or minimal setup. MCP tools (Figma, Canva, Gamma, Gmail, Calendar) offer cloud capabilities but require OAuth. The biggest gap is in design/prototyping (MCP ecosystem still early).

---

## Recommended Tool Stack

### Tier 1: Already Working (Zero Install)

| Tool | Area | Command | 实测 |
|------|------|---------|------|
| **Typst** | 文档/报告 | `typst compile doc.typ` | ✅ 39KB 专业报告 |
| **Pandoc** | 格式转换 | `pandoc doc.md --pdf-engine=typst -o doc.pdf` | ✅ DOCX + HTML |
| **Pandoc + reveal.js** | 幻灯片 | `pandoc doc.md -t revealjs -s -o slides.html` | ✅ 7KB 幻灯片 |
| **Python matplotlib** | 数据图表 | `python3 chart.py` | ✅ PNG + SVG |
| **Gmail MCP** | 邮件 | 已内置，需 OAuth | 🔑 |
| **Calendar MCP** | 日程 | 已内置，需 OAuth | 🔑 |
| **Jina Reader** | 网页→MD | `curl r.jina.ai/<url>` | 零安装 |

### Tier 2: One Install Away

| Tool | Area | Install | 价值 |
|------|------|---------|------|
| **D2** | 架构图 | `brew install d2` | 纯二进制，无浏览器依赖，现代图表 |
| **Firecrawl MCP** | 结构化抓取 | `npx firecrawl-mcp` | 全站爬取，JSON 提取，500 credits/月 |
| **Slidev** | 开发者演示 | `npm init slidev` | Vue 渲染幻灯片 |

### Tier 3: Cloud MCP (需 OAuth)

| Tool | Area | 价值 |
|------|------|------|
| **Figma MCP** | UI 设计 | 双向读写 Figma，但免费仅 6 次/月 |
| **Gamma MCP** | AI 演示 | AI 生成精美演示文稿 |
| **Canva MCP** | 品牌设计 | 海报、社交媒体图、品牌套件 |
| **Slack MCP** | 团队沟通 | 需 workspace 管理员权限 |

---

## 实测记录 (5 tests, AC requires ≥3)

| # | 工具 | 命令 | 结果 | 产出 |
|---|------|------|------|------|
| 1 | Typst | `typst compile report.typ` | ✅ | 29KB PDF 含表格 |
| 2 | Typst | `typst compile competitive-report.typ` | ✅ | 39KB 专业报告含样式 |
| 3 | Pandoc | `pandoc test.md -o test.docx` | ✅ | 11KB DOCX |
| 4 | Pandoc | `pandoc test.md -t revealjs -s -o slides.html` | ✅ | 7KB reveal.js 幻灯片 |
| 5 | matplotlib | `python3 chart.py` | ✅ | 34KB PNG + 27KB SVG |
| ❌ | Mermaid CLI | `npx mmdc -i test.mmd -o test.svg` | ❌ | Puppeteer spawn 失败 |

---

## Domain Pack 安装指南 (按优先级)

```bash
# Already installed (Tier 1 — just use)
typst --version          # v0.14.2
pandoc --version         # v3.8.2
python3 --version        # available

# Recommended installs (Tier 2)
brew install d2          # Declarative diagrams
# Firecrawl: claude mcp add firecrawl -- npx firecrawl-mcp

# MCP tools (Tier 3 — activate in Claude settings)
# Gamma: authenticate via mcp__claude_ai_Gamma__authenticate
# Canva: authenticate via mcp__claude_ai_Canva__authenticate
# Gmail: authenticate via mcp__claude_ai_Gmail__authenticate
```

---

## Key Insights for Domain Pack Design

1. **CLI-first is correct** — 7/10 recommended tools are CLI, zero external dependency
2. **MCP for cloud only** — Figma, Canva, Gamma, Gmail/Calendar are the right MCP use cases (stateful/remote)
3. **Mermaid CLI limitation** — Puppeteer dependency is a real problem in sandboxed environments; D2 or mermaid.ink API are better alternatives
4. **No existing "Domain Pack" project** — PAI Packs (danielmiessler) is closest but still prompt-only. TAD's tool-integrated approach is novel.
5. **Biggest gap: design tooling** — Figma MCP is the only real option, and free tier is very limited (6/month)

---

## Detailed Reports

- [Area 1: Design & Prototyping](area-1-design-prototyping.md)
- [Area 2: Data Research & Scraping](area-2-data-research.md)
- [Area 3: Document Generation](area-3-document-generation.md)
- [Area 4: Diagrams & Visualization](area-4-diagrams-visualization.md)
- [Area 5: Communication & Distribution](area-5-communication.md)
- [Area 6: GitHub Similar Projects](area-6-github-similar-projects.md)
