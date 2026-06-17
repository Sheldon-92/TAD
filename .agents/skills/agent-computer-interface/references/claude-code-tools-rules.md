# Claude Code Tools Rules
last_verified: 2026-06-17

## Tools in This Context

| Tool | Type | Setup Difficulty | Login State | Token Cost (type) | Stability |
|------|------|-----------------|-------------|-------------------|-----------|
| Claude in Chrome | MCP extension (beta) | Zero config | Inherits browser session | ~10k per-page | Beta, random disconnects |
| Playwright MCP | MCP server | Medium | Must re-login | ~13.6k one-time schema + 2-5KB per-page snapshot | Stable |
| Chrome DevTools MCP | MCP server | High (debug flag) | Must re-login | ~10k per-page (heavy JSON) | Stable but slow |
| PinchTab | MCP extension | Low | Uses existing session | ~800 tokens per-page (a11y tree) | Stable |

## Decision Rules

### R1: Claude in Chrome First for Dev Loop Tasks
> When a user in Claude Code needs to interact with a web page they already have open in their browser (verify rendering, read console, check network requests), try Claude in Chrome FIRST.

Claude in Chrome inherits the browser's login state — no re-authentication needed. For dev loop tasks (test local apps, verify UI changes, read error messages), this eliminates the #1 friction point: re-logging into services. Zero configuration required.

The trade-off: beta stability. Random disconnects happen. If Claude in Chrome fails or disconnects, fall back to Playwright MCP.

Source: code.claude.com/docs/en/chrome + dev.to/minatoplanb "I Tested Every Browser Automation Tool" (retrieved 2026-06-17).

### R2: Playwright MCP for Multi-Step Automated Flows
> When the task involves automated multi-step flows (fill form → submit → verify result → navigate → repeat), use Playwright MCP. Its auto-wait and structured snapshots are more reliable than Claude in Chrome for sequential automation.

Playwright MCP provides structured accessibility tree snapshots (2-5KB each, 20-50x cheaper than full screenshots). It has built-in auto-wait that handles page transitions automatically. The one-time schema loading cost (~13.6k tokens) is amortized over the session.

Source: getunblocked.com "MCP Token Budget Autopsy" + Microsoft Playwright MCP documentation (retrieved 2026-06-17).

### R3: Token Cost Comparison — Choose by Budget
> When token budget is a concern, use this cost hierarchy to select the right tool:

| Tool | Per-Page Cost | Session Overhead | Best For |
|------|--------------|-----------------|----------|
| PinchTab | ~800 tokens (a11y tree) | Minimal | Quick page reads, content extraction |
| Playwright MCP | 2-5KB per snapshot | ~13.6k one-time schema | Automated flows, testing |
| Claude in Chrome | ~10k per page | Low | Dev loop, login-required pages |
| Chrome DevTools MCP | ~10k+ per page | High (JSON payloads) | Performance profiling only |
| Playwright CLI (non-MCP) | ~27k per session | None | CI/CD, batch testing |

For a single page read: PinchTab (~800 tokens) beats Claude in Chrome (~10k) by 12x.
For a 10-page automated flow: Playwright MCP (~63.6k total) beats Claude in Chrome (~100k) by 37%.
For CI/CD: Playwright CLI (~27k per session) beats Playwright MCP (~114k) by 4x.

Source: morphllm.com analysis + getunblocked.com autopsy + scrolltest.medium.com measurements (all retrieved 2026-06-17).

### R4: Chrome DevTools MCP for Deep Profiling Only
> Use Chrome DevTools MCP ONLY for deep performance profiling, memory leak diagnosis, or network waterfall analysis. For all other browser tasks, prefer Claude in Chrome or Playwright MCP.

Chrome DevTools MCP requires launching Chrome with a debug flag (`--remote-debugging-port`), doesn't have auto-wait, and produces heavy JSON payloads. It exposes 29 tools including Lighthouse, network analysis, and memory profiling. These are powerful but expensive. Do not use DevTools MCP for simple navigation or form filling.

Source: Google Chrome DevTools MCP documentation, dev.to comparison (retrieved 2026-06-17).

### R5: Detection Before Selection
> In a Claude Code session, always run the two-tier detection (ToolSearch + capability-detect.sh) before choosing a tool. The most common mistake is assuming what's available.

```
Step 1: ToolSearch query: "browser chrome playwright devtools"
Step 2: bash scripts/capability-detect.sh (if available)
Step 3: Announce findings: "Available: Claude in Chrome (MCP), Playwright (CLI)"
Step 4: Select based on task type + cost + availability
```

Many Claude Code environments have Claude in Chrome pre-installed but not Playwright MCP. Others have Playwright CLI but not the MCP server. Detection eliminates guesswork.

Source: architecture derived from expert review of this pack (P0-1: MCP cannot be detected from shell).

### R6: Fallback with Notification
> When the primary tool fails mid-task (Claude in Chrome disconnects, Playwright times out), fall back within the same layer and ALWAYS notify the user.

Same-layer fallback chain:
1. Claude in Chrome → Playwright MCP (both are MCP-based browser tools)
2. Playwright MCP → Playwright CLI (same engine, different interface)
3. Any MCP tool → CLI equivalent (no cross-layer escalation)

Format: "⚠️ Claude in Chrome disconnected. Switching to Playwright MCP for remaining steps."

Never silently switch tools. The user needs to know which tool is active, especially when login state changes (Claude in Chrome inherits login; Playwright MCP does not).

### R7: Login-Required Tasks — Tool Selection by Auth State
> When the task requires authentication (download from a logged-in service, access private repo UI):

| Auth Situation | Best Tool | Why |
|---------------|-----------|-----|
| User already logged in via browser | Claude in Chrome | Inherits session cookies |
| Fresh session, credentials in .env | Playwright MCP with programmatic login | Reliable, scriptable |
| OAuth/SSO required | Claude in Chrome | Complex redirect flows work better with real browser |
| 2FA/MFA required | Claude in Chrome + user manual step | Agent can't handle hardware tokens |

If the user says "I need to download from Kaggle" and they're logged into Kaggle in their browser, Claude in Chrome is the clear choice. If they're setting up a new automation that runs unattended, Playwright MCP with stored credentials is better.

## Configuration Guide

### Claude in Chrome
- Install the "Claude in Chrome" browser extension from Chrome Web Store
- No additional configuration needed — it connects to Claude Code automatically
- Verify: `ToolSearch query: "select:mcp__claude-in-chrome__tabs_context_mcp"`

### Playwright MCP
```bash
# Typically pre-configured in Claude Code
# To add manually, configure in .claude/settings.json:
# "mcp_servers": { "playwright": { "command": "npx", "args": ["@anthropic-ai/playwright-mcp"] } }
```

### Chrome DevTools MCP
```bash
# Launch Chrome with debug flag
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222

# Configure MCP server to connect to debug port
# Requires manual setup — consult Chrome DevTools MCP documentation
```

### PinchTab
- Install the PinchTab browser extension
- Provides lightweight a11y tree snapshots (~800 tokens/page)
- Best for quick reads where full page interaction isn't needed

## Fallback Chain

1. **Claude in Chrome** (preferred for dev loop + login-required)
2. → Playwright MCP (for automated flows or when Chrome disconnects)
3. → Playwright CLI (if MCP unavailable, loses interactive control)
4. → PinchTab (for read-only page inspection, minimal cost)
5. → Chrome DevTools MCP (only for profiling tasks)
6. → **Report to user**: "No browser tools available in this Claude Code session."

All tools in this reference are within the Claude Code context — same environment, no cross-layer escalation needed.
