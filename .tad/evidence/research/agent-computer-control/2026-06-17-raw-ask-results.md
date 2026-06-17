# Agent Computer & Browser Control Tools — Raw Ask Results
Date: 2026-06-17
Notebook: c0143736-a6f1-4ff3-aa61-95ebee84c812 (14 sources)
Conversation: fbeb9fb4

## Ask 1: 主流方案四维分类

### (1) 浏览器控制/自动化工具

| Tool | Type | Core | Use Case | Limitation |
|------|------|------|----------|------------|
| Browser Use | OSS MIT, 95k stars | LLM+DOM Agent loop, natural language, multi-tab | Complex cross-site reasoning, custom agent dev | High LLM cost per step, fails on heavy anti-bot |
| Stagehand v3 (Browserbase) | OSS SDK + commercial cloud | CDP-native, act/extract/observe/agent primitives, 44% faster | Hybrid deterministic+AI workflows, Zod schema extraction | TS/JS only, high token cost at scale |
| Vercel Agent Browser | OSS Rust CLI | Semantic snapshots (@e1 labels), extreme token efficiency | CLI-first coding assistants, token-constrained contexts | No built-in LLM, no anti-detect, poor UX for non-devs |
| Skyvern | OSS + commercial cloud | Vision+LLM, plan-execute-verify loop, no-code UI | Non-technical users, form-heavy legacy systems | 10x+ cost vs DOM, multi-second latency per action |
| PinchTab | OSS HTTP API | A11y tree at ~800 tokens/page | Quick page reads from Claude Code terminal | No autonomous agent loop, poor for complex forms |

### (2) 网页数据抓取工具

| Tool | Type | Core | Use Case | Limitation |
|------|------|------|----------|------------|
| Firecrawl | API billing + OSS core, 102k stars | LLM-ready markdown/JSON, sandbox | RAG corpus, clean web content for AI apps | Single-page only (needs automation framework for deep crawl) |
| Crawl4AI | OSS Apache-2.0, 63k stars | Local LLM support, transparent codebase | Custom data pipelines, privacy-focused prototyping | Hidden LLM costs, poor on anti-bot sites |
| Bright Data Agent Browser | Commercial | Anti-detect, millions of IPs, CAPTCHA bypass | Enterprise e-commerce monitoring, competitive intel | No free tier, $5-8/GB |

### (3) 桌面/GUI 控制工具

| Tool | Type | Core | Use Case | Limitation |
|------|------|------|----------|------------|
| Claude Computer Use | Commercial API (beta) | Multimodal vision, mouse/keyboard coordinate control | Cross-app desktop automation beyond browser | Beta stability, severe prompt injection risks |
| OpenInterpreter | OSS | NL→Python/Shell on terminal | Terminal power users, data processing pipelines | Terminal only (no GUI), unsafe unsandboxed code execution |
| Fazm | OSS | macOS desktop control + voice + DOM browser + memory | Full desktop automation on macOS | macOS only |
| UFO (Microsoft) | OSS | Windows desktop control | Windows desktop automation | Windows only |

### (4) MCP Servers

| Tool | Type | Core | Use Case | Limitation |
|------|------|------|----------|------------|
| Playwright MCP (Microsoft) | OSS | A11y tree snapshots (2-5KB), auto-wait | Standard AI assistant browser integration | 15k token "context tax" on load, cold start 2-5s, no login state |
| Chrome DevTools MCP (Google) | OSS, 29 tools | Full Chrome debugger access, Lighthouse, network, memory | Deep perf profiling, memory leak diagnosis | Requires debug-flag Chrome, no auto-wait, heavy JSON payloads |
| Claude in Chrome | Beta extension | Zero config, uses existing browser session/cookies | Dev workflow: test local apps, read console, verify rendering | Beta stability issues, random disconnects, text input bugs, 10k+ tokens/page |
| Browser MCP | OSS extension | Works with VS Code/Cursor/Claude, local execution | Multi-IDE browser automation | (Not fully detailed in sources) |

## Ask 2: Claude Code 三工具对比 + 决策树 + 层次关系

### Claude Code 环境三工具对比

| Dimension | Claude in Chrome | Playwright MCP | Chrome DevTools MCP |
|-----------|-----------------|----------------|---------------------|
| Setup | Zero config, uses existing session | Separate browser process | Requires debug-flag Chrome launch |
| Auth/Login | Inherits browser login state | Must re-login | Must re-login |
| Token cost | 10k+/page | 2-5KB snapshots (20-50x cheaper than screenshots) | 10k+/page |
| Context tax | Low | 15k token tool definition loading | High (heavy JSON) |
| Auto-wait | Yes | Yes (built-in) | No (manual polling) |
| Stability | Beta, random disconnects | Stable | Stable but slow |
| Best for | Dev loop: test/verify/debug local apps | Automated multi-step flows | Deep perf/network/memory analysis |

### 决策树

1. Stable known-page, high-frequency (CI/CD)? → **Playwright** (deterministic, ms-level, no LLM cost)
2. Structured data extraction? → **Stagehand extract() + Zod** or **Firecrawl** (RAG)
3. Complex autonomous multi-step cross-site reasoning? → **Browser Use** (full agent loop)
4. Local dev loop: verify code rendering? → **PinchTab / Claude in Chrome** (low latency, existing session)
5. Anti-bot/anti-detect sites? → **Scrapling / Patchright** (TLS fingerprint, CDP intercept)

### 五层架构

1. **Infrastructure & Engine** — Playwright, Puppeteer, Selenium; cloud: Browserbase, Steel, Cloudflare Browser Run
2. **Data/Context** — Firecrawl, Crawl4AI (web → LLM-ready markdown/JSON)
3. **AI Primitives/Hybrid Framework** — Stagehand (act/extract/observe + deterministic code)
4. **Autonomous Agent/Orchestration** — Browser Use, Skyvern (full goal→plan→execute→verify loop)
5. **Consumer/Desktop** — Perplexity Comet, ChatGPT Atlas, Claude Computer Use, agentic browsers
