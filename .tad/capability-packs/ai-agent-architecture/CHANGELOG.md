# Changelog

All notable changes to this capability pack are documented here.

## [1.0.0] — 2026-05-07

### Added
- Initial release of AI Agent Architecture Capability Pack
- 10 decision reference files (D1-D10) derived from Claude Code, OpenClaw, and Hermes source analysis
- CAPABILITY.md navigator with two modes: /design and /audit
- /design mode: 5-question scoping phase + sequential decision walk-through → Architecture Decision Document
- /audit mode: 10-decision check against existing system → Architecture Audit Report
- Anti-Skip Table with 5 entries mapping excuses to legitimate skip conditions
- D1 (need-an-agent.md): 5-level complexity selection matrix, Agent Everywhere anti-pattern
- D2 (coordination-and-state.md): 6-pattern coordination taxonomy, hub-spoke state ownership, idempotency
- D3 (context-memory.md): 5-pattern memory selection matrix with quantitative metrics (72.9% / 1.44s benchmarks)
- D4 (tool-management.md): deferred loading, ACI design principles, meta-tool pattern, 7x AgentTool cost
- D5 (permissions-safety.md): 7-mode permission spectrum, deny-first, MCP 7-item security checklist
- D6 (context-compression.md): Claude Code 5-layer pipeline, Hermes dual-layer + anti-thrashing, atomic boundaries
- D7 (cost-token-economics.md): model routing (40-60% savings), entropy-based lazy retrieval, budget caps
- D8 (observability.md): JSONL logging, trace correlation IDs, runaway loop detection, AI-assisted analysis
- D9 (testing-evaluation.md): stochastic behavior fingerprinting, per-transition tests, network isolation
- D10 (production-disasters.md): 7 full causal chains from real incidents with scope tags
- install.sh with --agent=claude-code (Phase 1) and Phase 3 stubs for codex, cursor, gemini
- LICENSE-ATTRIBUTION.md crediting Anthropic, OpenClaw, NousResearch, OWASP, Elastic, Invariant Labs

### Research Foundation
- 102+ unique sources across 4 NotebookLM notebooks
- 78 actionable rules extracted and clustered into 10 decisions
- 7 production disaster causal chains documented
