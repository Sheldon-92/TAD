# Spike Report: NotebookLM Source Import Boundary Test

**Date:** 2026-05-09
**Notebook ID:** 8618dca0-b93f-49b3-8121-8cfdc505bde9
**CLI Version:** notebooklm-py 0.3.4+

## Test Matrix (14 sources tested)

### Actually Effective

| Source | Type | Import | Content | Verdict |
|--------|------|--------|---------|---------|
| arXiv PDF direct link | PDF | ✅ ready | ✅ Full paper text | **RELIABLE** |
| ACM paywall paper | WEB_PAGE | ✅ ready | ⚠️ Abstract + refs, no full text | **PARTIAL** |
| arXiv abstract page | WEB_PAGE | ✅ ready | ⚠️ Abstract + heavy nav noise | **MARGINAL** |

### False Successes (imported but useless content)

| Source | Type | Import | Actual Content | Root Cause |
|--------|------|--------|----------------|------------|
| Bilibili video | WEB_PAGE | ✅ ready | Navigation bar only | SPA dynamic rendering |
| AWS documentation | WEB_PAGE | ✅ ready | TOC navigation only | SPA dynamic rendering |
| GitHub repo | WEB_PAGE | ✅ ready | Mostly UI nav, partial README | SPA partial rendering |
| X/Twitter tweet ×2 | WEB_PAGE | ✅ ready | "Privacy extension warning" | Login wall |
| Semantic Scholar | WEB_PAGE | ✅ ready | CloudFront 403 error page | WAF block |
| Google Scholar | WEB_PAGE | ✅ ready | "System busy" error | Anti-crawl |

### Complete Failures (import error)

| Source | Error |
|--------|-------|
| YouTube ×2 | API returned no data |
| Substack | RPC ADD_SOURCE failed |
| Medium | RPC ADD_SOURCE failed |

## Key Findings

1. **PDF is the only reliable high-quality path** — arXiv PDF was the sole source with complete substantive content
2. **"False success" is the biggest risk** — 7/14 sources returned `status: ready` but content was useless (nav bars, error pages, login walls)
3. **SPA/JS-rendered sites all fail** — Bilibili, AWS, GitHub, X only captured HTML shell
4. **Academic platforms need workarounds** — Semantic Scholar WAF'd, Google Scholar anti-crawl, ACM paywall
5. **X/Twitter completely unusable** — login wall, only captured a privacy warning
6. **YouTube may be temporarily broken** — both videos failed, but YouTube worked in previous sessions (2026-05-05)

## Compensation Layer Priorities (from experiment)

| Priority | Scenario | Strategy Direction |
|----------|----------|-------------------|
| P0 | X/Twitter content | twitterapi.io API → .md → source add |
| P0 | Bilibili video | yt-dlp extract subtitles → .md → source add |
| P1 | Substack/Medium | Jina Reader / direct fetch → .md |
| P1 | Academic paper search | Semantic Scholar API → find PDF URL → source add PDF |
| P2 | SPA doc sites (AWS) | Playwright render → .md |
| P2 | YouTube no captions | Cloud Whisper API (future) |

## Available Tools

- **twitterapi.io**: API key at `~/.openclaw/workspace/data/twitterapi.key`, GET /twitter/article endpoint for long-form articles (100 credits/article)
- **yt-dlp**: Supports Bilibili subtitle extraction (`--write-sub`)
- **Jina Reader**: URL → Markdown conversion API
- **Semantic Scholar API**: Free, supports paper search + PDF URL extraction
