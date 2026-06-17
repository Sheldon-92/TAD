# L1: Browser Engine Rules
last_verified: 2026-06-17

## Tools in This Layer

| Tool | License | Stars/Status | Primary Use | Token Cost (type) |
|------|---------|-------------|-------------|-------------------|
| Playwright | Apache-2.0 | Microsoft-maintained, industry standard | E2E testing, CI/CD automation, deterministic flows | ~27k per-session (CLI); ~114k per-session (MCP) |
| Puppeteer | Apache-2.0 | Google-maintained | Chrome/Chromium-specific automation | ~20k per-session (CLI) |
| Selenium | Apache-2.0 | 32k+ stars | Legacy cross-browser testing | ~30k per-session (CLI) |
| Patchright | MIT (Playwright fork) | ~5k stars | Anti-detect automation (TLS fingerprint) | Same as Playwright |

## Decision Rules

### R1: Playwright CLI Over MCP for Automated Flows
> When running automated test suites or CI/CD pipelines, use Playwright CLI mode, not MCP mode. MCP burns 4x more tokens per test session.

Playwright MCP loads ~13.6k tokens of tool definitions as a one-time schema tax, then each page interaction adds snapshot overhead. A full test session via MCP costs ~114k tokens vs ~27k via CLI — a 4x difference. MCP mode is justified only when the agent needs interactive, ad-hoc browser control where tool definitions are already loaded (e.g., during a conversation where ToolSearch already loaded the MCP tools).

Source: getunblocked.com "MCP Token Budget Autopsy" + scrolltest.medium.com "Playwright MCP Burns 114K Tokens" (both retrieved 2026-06-17).

### R2: Playwright Over Puppeteer for New Projects
> Default to Playwright for new browser automation. Use Puppeteer only when Chrome-specific CDP features are required or when integrating with an existing Puppeteer codebase.

Playwright supports Chromium, Firefox, and WebKit out of the box. It has built-in auto-wait, trace viewer, and codegen. Puppeteer is Chrome/Chromium only. The only reason to choose Puppeteer today is an existing codebase or a Chrome-specific CDP feature that Playwright doesn't expose.

Source: dev.to/stevengonsalvez "Browser Tools for AI Agents Part 1" (retrieved 2026-06-17).

### R3: Selenium Only for Legacy or Cross-Browser Compliance
> Do not start new projects on Selenium. Use it only when the project already depends on Selenium, or when regulatory/compliance testing requires the Selenium Grid infrastructure.

Selenium's architecture (WebDriver protocol over HTTP) adds latency compared to Playwright's direct CDP/protocol connection. Its auto-wait is weaker, requiring explicit waits. Modern alternatives (Playwright) cover the same browsers with better DX.

Source: nxcode.io "Stagehand vs Browser Use vs Playwright" comparison (retrieved 2026-06-17).

### R4: Headless by Default, Headed for Debugging
> Run browser engines in headless mode for CI/CD and automated flows. Switch to headed mode only for interactive debugging or when visual verification is required.

Headless mode is faster (no GPU rendering), uses less memory, and works in containerized environments. Headed mode is useful during development to visually inspect page state. For Claude Code contexts, headed mode helps the agent verify visual rendering via screenshots.

Source: standard Playwright/Puppeteer documentation practice.

### R5: Anti-Detect When Target Has Bot Protection
> If the target site employs bot detection (Cloudflare, DataDome, PerimeterX), switch from standard Playwright to Patchright or use Scrapling for TLS fingerprint masking.

Standard Playwright/Puppeteer are fingerprinted by sophisticated anti-bot systems. Patchright (MIT, Playwright fork) patches the TLS fingerprint and navigator properties. Scrapling uses CDP intercept to mask automation signals. Do not waste time debugging "Access Denied" errors with standard engines — switch to anti-detect tools immediately.

Source: aimultiple.com "Best 30+ Open Source Web Agents in 2026" (retrieved 2026-06-17).

## Configuration Guide

### Playwright CLI Setup
```bash
# Install (project-level recommended)
npm init playwright@latest
# Or global
npm install -g playwright

# Run a test
npx playwright test

# Interactive codegen (generates test code from user actions)
npx playwright codegen https://example.com
```

### Playwright MCP Setup
```bash
# In Claude Code, Playwright MCP is typically pre-configured
# Verify availability:
# ToolSearch query: "select:mcp__playwright__*"
```
Note: API keys are NOT required for Playwright. If using a cloud browser service (Browserbase, Steel), set the endpoint in `.env`:
```
BROWSER_WS_ENDPOINT=YOUR_ENDPOINT_HERE  # .env — add to .gitignore
```

## Fallback Chain

1. **Playwright CLI** (preferred for automation)
2. → Puppeteer (if Playwright unavailable and Chrome-only is acceptable)
3. → Selenium (if both above unavailable and legacy infrastructure exists)
4. → **Report to user**: "No browser engine available. Install Playwright: `npm init playwright@latest`"

All L1 fallbacks are same-layer — no user confirmation required.
