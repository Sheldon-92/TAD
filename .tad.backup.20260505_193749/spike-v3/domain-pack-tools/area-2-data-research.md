# Area 2: 数据研究与抓取工具

## 工具评估矩阵

| 工具 | 类型 | Claude Code 兼容 | 输出质量 | 免费额度 | 安装难度 | 推荐度 |
|------|------|-----------------|---------|---------|---------|--------|
| Firecrawl MCP | MCP | ✅ 原生 MCP | 高 (结构化 JSON/MD) | 500 credits/月 | 低 (npx 1 行) | ⭐⭐⭐ |
| Jina Reader | HTTP API | ✅ via WebFetch | 高 (URL→Markdown) | 10M tokens 免费 | 零 (无需安装) | ⭐⭐⭐ |
| Tavily MCP | MCP | ✅ 原生 MCP | 好 (AI 排序摘要) | 1,000 credits/月 | 低 (npx + API key) | ⭐⭐ |
| Brave Search MCP | MCP | ✅ 官方认证 | 中 (搜索结果) | 2,000 queries/月 | 低 (官方包) | ⭐⭐ |
| ScrapeGraphAI | MCP | ✅ MCP 可用 | 好 (AI 提取) | 未明确 | 中 (需 API key) | ⭐ |

## 推荐工具

- **首选**: **Firecrawl MCP** — 最全面的抓取能力：全站爬取、JSON schema 提取、批量抓取、JS 渲染、代理轮换。500 credits/月覆盖典型研究。
- **备选**: **Jina Reader** — 零安装，`r.jina.ai/<url>` 即用。适合单页面 URL→Markdown 转换，与内置 WebFetch 互补。

## 与内置工具的对比

| 能力 | 内置 WebFetch/WebSearch | 外部工具新增 |
|------|------------------------|------------|
| 全站爬取 | ❌ | Firecrawl ✅ |
| 结构化 JSON 提取 | ❌ | Firecrawl, ScrapeGraph ✅ |
| 批量 URL 抓取 | ❌ | Firecrawl, Tavily ✅ |
| 反爬绕过 | 基础 | Firecrawl (最佳) ✅ |
| AI 排序搜索 | WebSearch (Brave) | Tavily (更好排序) |
