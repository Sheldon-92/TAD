---
name: agent-computer-interface
description: "Agent computer & browser control capability pack. Gives AI agents the judgment rules for detecting available tools, selecting the right automation layer (engine/data/hybrid/agent/desktop), configuring browser and computer control tools, and handling fallback chains. Covers Playwright, Browser Use, Stagehand, Firecrawl, Claude in Chrome, Computer Use, and 15+ tools across 5 layers. Use for any browser automation, web scraping, desktop control, or tool selection task."
keywords: ["browser", "automation", "浏览器", "自动化", "scraping", "抓取", "computer use", "desktop", "GUI", "Playwright", "Puppeteer", "Browser Use", "Stagehand", "Firecrawl", "Crawl4AI", "Chrome", "MCP", "控制", "操控"]
type: reference-based
status: active
---

**CONSUMES**: User browser/computer/scraping task description + current environment context
**PRODUCES**: Tool selection decision + applied judgment rules + capability detection results + configuration guidance

# Agent Computer Interface Capability Pack

**Registration note (2026-10-06, self-review batch R2, group 1)**: This pack's source
directory and installed skill projection (`.agents/skills/agent-computer-interface/`)
pre-date this file; the pack was routed from the AGENTS.md pack pointer table while
its CAPABILITY.md — the registration source scan-packs.sh derives the registry from —
was missing, so the pack never entered pack-registry.yaml. This file restores the
registration from the projection's own declared metadata (name / description /
keywords / type / CONSUMES / PRODUCES are the SKILL.md frontmatter values verbatim);
it introduces no new capability content.
