---
name: agent-computer-interface
description: "Agent computer & browser control capability pack. Gives AI agents the judgment rules for detecting available tools, selecting the right automation layer (engine/data/hybrid/agent/desktop), configuring browser and computer control tools, and handling fallback chains. Covers Playwright, Browser Use, Stagehand, Firecrawl, Claude in Chrome, Computer Use, and 15+ tools across 5 layers. Use for any browser automation, web scraping, desktop control, or tool selection task."
keywords: ["browser", "automation", "浏览器", "自动化", "scraping", "抓取", "computer use", "desktop", "GUI", "Playwright", "Puppeteer", "Browser Use", "Stagehand", "Firecrawl", "Crawl4AI", "Chrome", "MCP", "控制", "操控"]
type: reference-based
---

**CONSUMES**: User browser/computer/scraping task description + current environment context
**PRODUCES**: Tool selection decision + applied judgment rules + capability detection results + configuration guidance

# Agent Computer Interface Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0

---

## What This Pack Does

AI agents encounter a browser or desktop task and immediately start installing Playwright, even when Claude in Chrome is already connected. They pick Computer Use for a simple page scrape. They use screenshot-based vision for a table that Firecrawl would extract as clean JSON in one call. They spend 10+ minutes trying tools that aren't installed while the right tool is already available in their MCP server list.

The root problem is not that agents can't use individual tools — it's that they lack systematic awareness of what's available and which layer fits the task. This pack embeds the judgment rules that a browser automation engineer applies automatically: detect first, match the task to the right layer, then select the best available tool within that layer.

Five layers organize the landscape. Each solves a different class of problem:

| Layer | Purpose | Representative Tools |
|-------|---------|---------------------|
| L1 Engine | Deterministic browser control | Playwright, Puppeteer, Selenium |
| L2 Data | Web content → LLM-ready formats | Firecrawl, Crawl4AI, Stagehand extract |
| L3 Hybrid | Deterministic code + AI flexibility | Stagehand v3 SDK, Browser MCP |
| L4 Agent | Full autonomous browsing | Browser Use, Skyvern, Open Operator |
| L5 Desktop | Cross-app GUI automation | Claude Computer Use, Fazm, UFO |

**Pack = tool selection judgment. Your automation code = implementation detail. No overlap.**

---

## Cross-Cutting Rules

### Rule 1: Capability Detection First (Two-Tier)

> Before any browser/computer task, detect available tools via TWO independent mechanisms. NEVER start installing a new tool before checking what's already available.

**Tier 1 — MCP (agent-side)**: Use `ToolSearch` to scan for `mcp__claude-in-chrome__*`, `mcp__playwright__*`, `mcp__chrome-devtools__*`, and other browser MCP tools. This runs in the agent's own runtime and cannot be delegated to a shell script.

**Tier 2+3 — CLI + Process (shell-side)**: Run `bash scripts/capability-detect.sh` which checks CLI tools (`command -v playwright` etc.) and browser extension state via `pgrep` (current user only, never `ps aux`).

Combine both tiers' results before selecting a tool. The MCP tier often reveals tools the shell script cannot see (e.g., Claude in Chrome is an MCP extension, not a CLI binary).

Source: architecture derived from TAD research notebook c0143736-a6f1-4ff3-aa61-95ebee84c812; MCP/CLI split validated by expert review P0-1.

### Rule 2: Layer Match — Five-Layer Selection

> Match task characteristics to the correct layer, then select a tool within that layer. Never jump to a higher layer when a lower one suffices — each layer up adds cost, latency, and security surface.

| Task Signal | Layer | First Choice | Why |
|-------------|-------|-------------|-----|
| Deterministic known pages, CI/CD, testing | L1 Engine | Playwright CLI (not MCP — 4x cheaper per session) | No LLM cost, ms-level, reproducible |
| Web page → clean markdown/JSON for LLM | L2 Data | Firecrawl (hosted) / Crawl4AI (local, Apache-2.0) | Purpose-built conversion, no automation overhead |
| Deterministic code + AI flexibility mixed | L3 Hybrid | Stagehand v3 act/extract/observe | Developer controls flow, AI handles ambiguity |
| Open-ended multi-step autonomous browsing | L4 Agent | Browser Use (89.1% WebVoyager, ~99k stars) | Full agent loop: goal→plan→execute→verify |
| Cross-app desktop GUI automation | L5 Desktop | Claude Computer Use (beta) | Only option for non-browser apps |

**Playwright CLI vs MCP cost**: Playwright MCP loads ~13.6k tokens of tool definitions (one-time schema tax) + per-page snapshot cost. Playwright CLI mode uses ~27k tokens per test session vs MCP's ~114k (4x cheaper). Use CLI for automated flows; reserve MCP for interactive agent sessions where tool definitions are already loaded. Source: getunblocked.com blog + scrolltest.medium.com (retrieved 2026-06-17).

### Rule 3: Fallback Chain + Token Cost Awareness + Security Escalation Gate

> If the first-choice tool is unavailable, degrade within the same layer first. Cross-layer upward fallback (lower → higher) is a PERMISSION ESCALATION that requires explicit user confirmation.

**Same-layer fallback** (silent, automatic):
Format: "⚠️ {preferred_tool} unavailable ({reason}). Falling back to {fallback_tool}."

**Cross-layer upward fallback** (requires confirmation):
Format: "⚠️ {preferred_tool} unavailable. Alternative {fallback_tool} requires higher permissions ({reason}) — confirm use?"
Must use `AskUserQuestion` before proceeding. Silent cross-layer escalation (e.g., L1 Playwright → L5 Computer Use) is forbidden.

**Token cost types** — always distinguish in comparisons:
- **One-time schema**: tool definition loading cost (e.g., Playwright MCP ~13.6k tokens)
- **Per-page**: cost per page interaction (e.g., Claude in Chrome ~10k tokens/page)
- **Per-session**: total session cost (e.g., Playwright CLI ~27k vs MCP ~114k per test)

Source: token measurements from Microsoft Playwright MCP docs, getunblocked.com autopsy, morphllm.com analysis (all retrieved 2026-06-17).

---

## Step 0: Capability Detection

1. **Tier 1 (MCP)**: Run `ToolSearch` with query `"browser chrome playwright devtools"` to discover available MCP browser tools
2. **Tier 2+3 (CLI/Process)**: Run `bash scripts/capability-detect.sh` → parse JSON output
3. Announce combined results: "Available tools: {list with source tier}"
4. If zero tools detected → inform user and suggest installation paths

---

## Step 1: Context Detection → Route to Reference

| User Signal | Reference to Load |
|-------------|-------------------|
| "browser", "navigate", "click", "automate page", "test page" | `claude-code-tools-rules.md` (in Claude Code) or `browser-engine-rules.md` (general) |
| "scrape", "crawl", "extract data", "抓取", "markdown", "RAG" | `data-extraction-rules.md` |
| "Stagehand", "hybrid", "act/extract", "deterministic + AI" | `hybrid-framework-rules.md` |
| "autonomous browse", "multi-step", "自主浏览", "agent browse" | `autonomous-agent-rules.md` |
| "desktop", "GUI", "Computer Use", "桌面", "non-browser app" | `desktop-control-rules.md` |
| "Claude in Chrome", "Playwright MCP", "DevTools MCP" | `claude-code-tools-rules.md` |
| "download from website", "login required", "需要登录" | `claude-code-tools-rules.md` (if Claude in Chrome detected) or `autonomous-agent-rules.md` |

If the user signal is ambiguous, load `claude-code-tools-rules.md` first (most common Claude Code context), then route deeper based on the specific task.

---

## Step 2: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** — do not skim
2. **Apply each decision rule** against the user's task, environment, and detected tools
3. **Enforce all three cross-cutting rules** on every task (detect → match layer → check fallback chain)
4. **Security check**: if the task involves credentials, destructive actions, or autonomous browsing, apply the reference's Security Considerations section before proceeding
5. **Announce the decision**: state which tool was selected, which layer it belongs to, and why alternatives were rejected

---

## Quick Rule Index

Rules are distributed across reference files. Use this index to find specific guidance:

| Topic | Reference | Key Rules |
|-------|-----------|-----------|
| Playwright vs Puppeteer vs Selenium | `browser-engine-rules.md` | R1-R5 |
| Firecrawl vs Crawl4AI selection | `data-extraction-rules.md` | R1-R5 |
| Stagehand v3 act/extract/observe | `hybrid-framework-rules.md` | R1-R6 |
| Browser Use configuration | `autonomous-agent-rules.md` | R1-R6 |
| Computer Use safety gates | `desktop-control-rules.md` | R1-R6 (Security: R4-R6) |
| Claude in Chrome vs Playwright MCP | `claude-code-tools-rules.md` | R1-R7 |
| Anti-detect / anti-bot | `browser-engine-rules.md` | R5 |
| Token cost optimization | `claude-code-tools-rules.md` | R3, R6 |
| Credential handling | `autonomous-agent-rules.md` | R4 (Security) |
| Fallback chains | Each reference | Fallback Chain section |
