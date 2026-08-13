# L3: Hybrid Framework Rules
last_verified: 2026-06-17

## Tools in This Layer

| Tool | License | Stars/Status | Primary Use | Token Cost (type) |
|------|---------|-------------|-------------|-------------------|
| Stagehand v3 | MIT | Browserbase SDK | Deterministic code + AI act/extract/observe primitives | Per-action: LLM cost for AI steps only |
| Browser MCP | MIT | OSS extension | Multi-IDE browser control (VS Code, Cursor, Claude) | Per-page: ~10k tokens |
| AgentQL | Commercial | Cloud SDK | Natural language selectors for web elements | Per-query: API billing |

## Decision Rules

### R1: Stagehand v3 for Developer-Controlled Hybrid Workflows
> When the task mixes deterministic steps (navigate to URL, fill form field X with value Y) and AI-flexible steps (find the "submit" button that might have different text), use Stagehand v3's three primitives: `act()`, `extract()`, `observe()`.

Stagehand v3 uses CDP (Chrome DevTools Protocol) direct connection, removing the Playwright dependency from v2. This makes it 44% faster for iframe and shadow-root interactions. The developer writes deterministic code for known steps and delegates ambiguous UI interactions to `act()`. Token cost is incurred only on AI-assisted steps, not deterministic ones.

Source: browserbase.com/blog/stagehand-v3 (retrieved 2026-06-17).

### R2: Three Primitives — act(), extract(), observe()
> Map each sub-task to the correct Stagehand primitive:
> - `act(instruction)`: click, type, navigate — natural language action on the page
> - `extract(schema)`: pull structured data matching a Zod schema from visible page content
> - `observe()`: return a list of possible actions on the current page (useful for exploration)

Do not use `act()` for data extraction — it's designed for actions, not reading. Do not use `extract()` without a Zod schema — unstructured extraction should use L2 tools (Firecrawl/Crawl4AI). `observe()` is the reconnaissance primitive: call it when you don't know what actions are available.

Source: Stagehand v3 SDK documentation, browserbase.com (retrieved 2026-06-17).

### R3: CDP Direct Over Playwright Dependency
> Stagehand v3 connects directly to Chrome via CDP, bypassing Playwright. Do not install Playwright as a Stagehand dependency — it's no longer required.

Stagehand v2 depended on Playwright for browser connection. v3 removed this dependency and connects directly via CDP. If you see code importing both `@browserbase/stagehand` and `playwright`, it's using v2 patterns. Update to v3's direct CDP connection for lower overhead and better iframe/shadow-root support.

Source: browserbase.com/blog/stagehand-v3 — "去除了 Playwright 依赖" (retrieved 2026-06-17).

### R4: Deterministic First, AI Second
> In a hybrid workflow, write deterministic code for every step where the page structure is known. Use AI primitives only for steps where the UI is ambiguous or dynamically generated.

Each `act()` call incurs LLM token cost. A hardcoded `page.goto(url)` + `page.fill('#email', value)` costs zero LLM tokens. Reserve `act('click the submit button')` for cases where the button's selector varies across pages or locales. This minimizes per-action cost while maintaining flexibility.

Source: general principle derived from Stagehand v3 architecture design (browserbase.com).

### R5: Browserbase Cloud for Anti-Bot and Scale
> When browser automation needs to bypass anti-bot detection or run at scale (10+ concurrent sessions), use Browserbase's cloud browser infrastructure rather than local Playwright/CDP.

Browserbase provides managed browser instances with anti-fingerprinting, CAPTCHA solving, and proxy rotation built in. Local browsers are fingerprinted by sophisticated anti-bot systems. The trade-off: Browserbase adds network latency and API cost. Use local browsers for development; switch to Browserbase for production scraping at scale.

Source: browserbase.com documentation + nxcode.io comparison (retrieved 2026-06-17).

### R6: Token Cost Awareness for Mixed Workflows
> In a Stagehand workflow mixing deterministic and AI steps, estimate total token cost before execution. Each `act()` call costs roughly 1-3k tokens (LLM prompt + response). A workflow with 20 AI steps costs 20-60k tokens — comparable to a full L4 agent session.

If the workflow has >15 AI steps and few deterministic steps, consider whether L4 (full autonomous agent) would be simpler and similarly priced. Stagehand's value is in the mix — mostly deterministic with a few AI-flexible spots. If it's mostly AI, use Browser Use (L4) instead.

Source: estimated from Stagehand v3 action token overhead patterns, cross-referenced with Browser Use session costs.

## Configuration Guide

### Stagehand v3 Setup
```bash
# Install
npm install @browserbase/stagehand

# Basic usage (TypeScript)
# import { Stagehand } from '@browserbase/stagehand';
# const stagehand = new Stagehand({ env: 'LOCAL' });
# await stagehand.init();
# await stagehand.page.goto('https://example.com');
# await stagehand.act('click the login button');
# const data = await stagehand.extract({ schema: myZodSchema });
```

For cloud execution, set in `.env` (add to `.gitignore`!):
```
BROWSERBASE_API_KEY=YOUR_API_KEY_HERE
BROWSERBASE_PROJECT_ID=YOUR_PROJECT_ID_HERE
```

## Example Usage

```typescript
// Hybrid workflow: deterministic navigation + AI extraction
import { Stagehand } from '@browserbase/stagehand';
import { z } from 'zod';

const stagehand = new Stagehand({ env: 'LOCAL' });
await stagehand.init();

// Deterministic: navigate to known URL (zero LLM cost)
await stagehand.page.goto('https://news.ycombinator.com');

// AI: extract structured data from dynamic page layout
const stories = await stagehand.extract({
  schema: z.object({
    items: z.array(z.object({
      title: z.string(),
      url: z.string(),
      points: z.number()
    }))
  })
});
```

## Fallback Chain

1. **Stagehand v3** (preferred for hybrid deterministic+AI)
2. → Browser MCP (if Stagehand unavailable and IDE-integrated browser needed)
3. → **Degrade to L1**: Playwright for deterministic-only version (lose AI flexibility)
4. → **Escalate to L4**: Browser Use for fully autonomous version (cross-layer UP — requires user confirmation per Cross-Cutting Rule 3)
