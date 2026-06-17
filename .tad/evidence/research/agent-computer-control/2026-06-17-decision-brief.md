# 决策简报: Agent 计算机/浏览器控制工具 Landscape

**决策问题**: 关于 Agent 计算机/浏览器控制工具，目前有哪些主流方案，各自的适用场景和局限是什么？

---

## 关键发现

### 五层架构模型

2026 年的工具生态呈现清晰的五层结构：

| 层级 | 定位 | 代表工具 | 特征 |
|------|------|----------|------|
| L1 基础引擎 | 驱动浏览器内核 | Playwright, Puppeteer, Selenium | 确定性、ms 级、无 LLM 成本 |
| L2 数据/上下文 | 网页→LLM 可用格式 | Firecrawl (102k⭐), Crawl4AI (63k⭐) | 转换层，不做决策 |
| L3 AI 原语/混合框架 | 确定性代码 + AI 决策 | Stagehand v3 (Browserbase) | act/extract/observe + 开发者控制流 |
| L4 自主 Agent | 全自主 goal→plan→execute | Browser Use (~99k⭐), Skyvern | 完整 Agent 循环，成本高 |
| L5 消费者/桌面 | 面向终端用户 | Claude Computer Use, Perplexity Comet | GUI 级控制，安全风险大 |

### Claude Code 专属工具对比

| 维度 | Claude in Chrome | Playwright MCP | Chrome DevTools MCP |
|------|-----------------|----------------|---------------------|
| 配置难度 | 零配置 | 中等 | 高（需 debug flag 启动） |
| 登录态 | ✅ 继承浏览器 | ❌ 需重新登录 | ❌ 需重新登录 |
| Token 成本 | ~10k/页 | 2-5KB 快照（便宜 20-50x） | ~10k/页 |
| 上下文税 | 低 | ~13.6k token 工具定义 | 高（JSON 载荷笨重） |
| 稳定性 | Beta，断连频繁 | 稳定 | 稳定但慢 |
| 最佳场景 | 本地开发验证 | 自动化多步流程 | 深度性能/网络分析 |

### 工具选择决策树

```
任务需要浏览器操作？
├─ 稳定已知页面 + 高频 CI/CD → Playwright (L1, 确定性)
├─ 结构化数据提取 → Stagehand extract() + Zod 或 Firecrawl (L2-L3)
├─ 复杂跨站自主推理 → Browser Use (L4, 完整 Agent 循环)
├─ 本地开发验证 → Claude in Chrome 或 PinchTab (低延迟)
├─ 反爬/反检测网站 → Scrapling 或 Patchright (TLS 伪装)
└─ 超越浏览器的桌面操作 → Claude Computer Use (L5, Beta)
```

## 证据

- **Browser Use** 在 WebVoyager benchmark 达到 89.1% 成功率（586 个任务），GitHub ~99k stars [1][3]
- **Stagehand v3** 通过 CDP 直连架构比 v2 快 44%（iframe/shadow-root 交互），去除了 Playwright 依赖 [14][16]
- **Playwright MCP** 工具定义加载消耗 ~13.6k tokens；完整测试 114k tokens vs CLI 模式 27k tokens（4x 差距）[6][8]
- **Claude in Chrome** 零配置继承登录态，但 Beta 期断连频繁且有文本输入 Bug [1][4][5]
- **Firecrawl** 102k stars (AGPL-3.0)，**Crawl4AI** 63k stars (Apache-2.0)，后者支持本地模型 [40][47]
- Agentic browser 市场从 2024 年 $4.5B 预计增长到 2034 年 $76.8B [43]

## Claim 验证

| Claim | 验证结果 | 来源 |
|-------|---------|------|
| Browser Use 95k stars | ✅ 已验证 — 实际 ~99.2k (2026-06) | GitHub |
| Stagehand v3 快 44% | ✅ 已验证 — 官方 blog 确认 | browserbase.com/blog/stagehand-v3 |
| Playwright MCP 15k token 上下文税 | ✅ 已验证 — 实测 ~13.6k token schema | getunblocked.com blog + morphllm.com |
| Playwright MCP 114k vs CLI 27k (4x) | ✅ 已验证 | Microsoft 官方推荐 + 多个独立测试 |

## 推荐

基于研究结果，**建议做宽版能力包（Agent-Computer Interface Pack）**，理由：

1. **五层架构是天然的知识组织方式** — 不同层级的工具解决不同问题，agent 需要理解"该用哪一层"
2. **最大痛点不在单工具，在选择** — 你分享的对话记录证明：agent 的核心问题是不知道自己有什么、该用什么
3. **Claude Code 三工具（Claude in Chrome / Playwright MCP / DevTools MCP）本身就跨层** — 只做"浏览器控制"包太窄
4. **桌面控制（Computer Use）是浏览器控制的自然延伸** — 很多任务需要浏览器 + 桌面联动

能力包核心判断规则应覆盖：
- **L0 能力检测**：先扫描当前可用工具（MCP servers、CLI、扩展）
- **L1-L5 层级选择**：根据任务性质选对层
- **同层工具选择**：同一层内按优先级选（已连接 > 已安装 > 需安装）
- **降级策略**：最优工具不可用时的 fallback 链
- **配置修复路径**：工具存在但没连上时的修复步骤

## 未知风险

- 这个领域变化极快（2026 上半年就出了 Stagehand v3、Browser Use Node SDK、多个新 MCP server），包的"工具清单"部分需要定期更新
- 安全维度（特别是 Computer Use 的提示注入风险）的深度评估未覆盖
- 商业 vs 开源工具的 licensing 合规（Firecrawl 是 AGPL-3.0）未深入
- 各工具的 Claude Code 实际兼容性未逐个实测验证

---

Sources:
- [I Tested Every Browser Automation Tool for Claude Code](https://dev.to/minatoplanb/i-tested-every-browser-automation-tool-for-claude-code-heres-my-final-verdict-3hb7)
- [Best 30+ Open Source Web Agents in 2026](https://aimultiple.com/open-source-web-agents)
- [Stagehand v3 Launch](https://www.browserbase.com/blog/stagehand-v3)
- [The Agentic Browser Landscape 2026](https://nohacks.co/blog/agentic-browser-landscape-2026)
- [Best Open Source Computer Use AI Agents 2026](https://fazm.ai/blog/best-open-source-computer-use-ai-agents-2026)
- [10 Best Agentic Browsers 2026](https://brightdata.com/blog/ai/best-agent-browsers)
- [Claude Code Chrome Docs](https://code.claude.com/docs/en/chrome)
- [Crawl4AI vs Firecrawl](https://brightdata.com/blog/ai/crawl4ai-vs-firecrawl)
- [Browser Use Review 2026](https://theaiagentindex.com/agents/browser-use)
- [11 Best AI Browser Agents](https://www.firecrawl.dev/blog/best-browser-agents)
- [Stagehand vs Browser Use vs Playwright](https://www.nxcode.io/resources/news/stagehand-vs-browser-use-vs-playwright-ai-browser-automation-2026)
- [Browser Tools for AI Agents Part 1](https://dev.to/stevengonsalvez/browser-tools-for-ai-agents-part-1-playwright-puppeteer-and-why-your-agent-picked-playwright-k71)
- [Agentic AI Browsers Market Landscape](https://velofill.com/articles/agentic-ai-browsers-2026-market-landscape/)
- [Playwright MCP Token Autopsy](https://getunblocked.com/blog/mcp-token-budget-autopsy/)
- [Playwright MCP Burns 114K Tokens](https://scrolltest.medium.com/playwright-mcp-burns-114k-tokens-per-test-the-new-cli-uses-27k-heres-when-to-use-each-65dabeaac7a0)
