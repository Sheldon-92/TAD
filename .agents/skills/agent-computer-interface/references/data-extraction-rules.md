# L2: Data Extraction Rules
last_verified: 2026-06-17

## Tools in This Layer

| Tool | License | Stars/Status | Primary Use | Token Cost (type) |
|------|---------|-------------|-------------|-------------------|
| Firecrawl | AGPL-3.0 | ~102k stars | Web page → clean markdown/JSON, hosted API | Per-page: varies by plan (API billing) |
| Crawl4AI | Apache-2.0 | ~63k stars | Local-first web → markdown, local LLM support | Per-page: local compute only (no API cost) |
| Stagehand extract() | MIT | Part of Stagehand v3 | Structured data extraction with Zod schema | Per-page: LLM cost for extraction |
| Jina Reader | Apache-2.0 | API service | URL → markdown via API | Per-page: API billing |

## Decision Rules

### R1: Firecrawl for Hosted, Crawl4AI for Local
> When the task is "convert web page to LLM-ready format," choose based on deployment model: Firecrawl for hosted/API-first (no infra management), Crawl4AI for local/privacy-first (no data leaves your machine).

Firecrawl (~102k stars, AGPL-3.0) provides a hosted API that returns clean markdown or structured JSON from any URL. It handles JavaScript rendering, anti-bot bypass, and format cleaning. Crawl4AI (~63k stars, Apache-2.0) runs entirely locally, supports local LLM models for extraction, and offers transparent codebase inspection. Choose Firecrawl when you need reliability and don't want to manage infrastructure. Choose Crawl4AI when data privacy is critical or you need to avoid API costs.

Source: brightdata.com "Crawl4AI vs Firecrawl" comparison + firecrawl.dev "Best Browser Agents" (both retrieved 2026-06-17).

### R2: AGPL-3.0 License Awareness for Firecrawl
> If the project is commercial or proprietary, verify that Firecrawl's AGPL-3.0 license is compatible. AGPL requires derivative works to be open-sourced if served over a network.

Self-hosting Firecrawl in a commercial product triggers AGPL copyleft obligations. Using the hosted API avoids this (API usage is not derivative work). Crawl4AI (Apache-2.0) has no such restriction. Flag this to the user if they plan to self-host Firecrawl in a commercial context.

Source: Firecrawl GitHub repository license file.

### R3: Stagehand extract() for Schema-Validated Extraction
> When the output must conform to a specific TypeScript/Zod schema (e.g., product listings, pricing tables), use Stagehand v3's `extract()` with a Zod schema rather than Firecrawl + post-processing.

Stagehand v3's extract() takes a Zod schema and returns validated data matching that schema. This eliminates the need for a separate LLM call to parse Firecrawl's markdown output. The trade-off: Stagehand requires a running browser instance (higher overhead for single-page extractions), while Firecrawl is a simple API call.

Source: browserbase.com/blog/stagehand-v3 (retrieved 2026-06-17).

### R4: Batch Crawling Needs an Orchestration Layer
> Firecrawl and Crawl4AI extract single pages. For multi-page crawling (sitemaps, pagination, link following), add an orchestration layer on top — don't loop API calls naively.

Firecrawl's `/crawl` endpoint handles sitemap-based crawling, but for custom crawl patterns (login-gated content, infinite scroll), combine a browser engine (L1) for navigation with a data extraction tool (L2) for content. Naive loop-and-extract patterns hit rate limits and miss dynamic content.

Source: firecrawl.dev documentation + crawl4ai documentation.

### R5: Prefer Markdown Over Screenshots for LLM Consumption
> When feeding web content to an LLM, extract as markdown (not screenshots) unless the task specifically requires visual layout analysis. Markdown is 10-50x cheaper in tokens than screenshot-based vision.

A screenshot of a web page costs 1000+ tokens in vision input. The same page as markdown costs 100-500 tokens of text. Use screenshots only when: (a) the task requires visual verification ("does this look right?"), (b) the page layout itself is the subject ("where is the button?"), or (c) the page uses complex visual elements that markdown can't represent (charts, images).

Source: general token cost analysis from Playwright MCP vs CLI measurements; morphllm.com analysis (retrieved 2026-06-17).

## Configuration Guide

### Firecrawl Setup
```bash
# Install CLI
npm install -g firecrawl

# Set API key in .env (add .env to .gitignore!)
echo "FIRECRAWL_API_KEY=YOUR_API_KEY_HERE" >> .env
echo ".env" >> .gitignore

# Quick extract
firecrawl scrape https://example.com --format markdown
```

### Crawl4AI Setup
```bash
# Install (use virtual environment)
python -m venv .venv && source .venv/bin/activate
pip install crawl4ai

# Quick extract
python -c "from crawl4ai import WebCrawler; c=WebCrawler(); print(c.run('https://example.com').markdown)"
```

## Fallback Chain

1. **Firecrawl** (preferred for hosted/quick extraction)
2. → Crawl4AI (if Firecrawl API unavailable or local-only requirement)
3. → Stagehand extract() (if structured schema output needed and browser already running)
4. → **Degrade to L1**: Use Playwright to fetch page source + manual markdown conversion
5. → **Report to user**: "No data extraction tool available. Install: `npm install -g firecrawl` or `pip install crawl4ai`"

L2 → L1 degradation is same-direction (down), no confirmation needed.
