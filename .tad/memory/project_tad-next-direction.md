---
name: TAD Next Direction — Depth-First Capability Building
description: 2026-05-05 strategic decision — freeze Domain Packs, deepen primitive capabilities starting with research, rebuild packs as SKILL.md one by one
type: project
originSessionId: 0b4e6322-8c02-4d02-8695-d46079b00f02
---
## Decision (2026-05-05)

Two-phase plan confirmed by user:

**Phase 1: Deepen NotebookLM Research Capability**
- Make it more polished, more reliable, more automatically activated
- Goal: every TAD session where research is needed should naturally trigger it (not require user correction)
- Known gaps from this session: agent defaulted to web search twice before using NotebookLM; needed manual correction
- Pipeline works (create → deep research → curate → ask loops → save findings) but activation is still fragile

**Phase 2: Freeze 20 Domain Packs → Rebuild One by One** (Decision refined 2026-05-07)
- From 20 → 8 active: web-frontend, web-backend, web-ui-design, mobile-development, mobile-release, ai-agent-architecture, ai-prompt-engineering, product-definition
- 10 frozen (remove from keyword router, keep YAML as reference): ai-evaluation, ai-tool-integration, web-testing, web-deployment, code-security, supply-chain-security, hw-circuit-design, hw-enclosure, hw-firmware, hw-testing
- 2 merged: mobile-testing → web-testing, mobile-ui-design → web-ui-design
- 1 archived: tools-registry → .tad/archive/domains/
- Freeze = remove from keywords.yaml + keep YAML in .tad/domains/ as reference material
- Rebuild strategy: on-demand when real project needs it → NotebookLM research → SKILL.md
- One at a time, based on real project need

**Why:** Core insight from Knowledge Activation paper (arxiv 2603.14805): "Where retrieval returns content for reading, activation delivers guidance for acting." Current YAML packs are informational text (food ingredient lists), not action-ready specifications (recipes). SKILL.md format is proven to work (*research-notebook = 19 commands, each with explicit steps + CLI bindings).

**How to apply:** When user wants to add a new domain capability, always start with research (NotebookLM notebook), then write SKILL.md with exact commands, never write YAML domain pack. For existing packs, only invest when a real project demands it.
