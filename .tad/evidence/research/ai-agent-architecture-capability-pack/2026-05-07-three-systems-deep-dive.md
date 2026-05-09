# AI Agent Architecture — Three Systems Deep Dive
Date: 2026-05-07
Sources: 5 subagents + 4 NotebookLM notebooks (102+ total sources)

---

## OpenClaw: 10 Architecture Rules (from notebook 44a28f1c, 14 sources)

1. **Concurrent session serialization**: multiple messages to same session → write lock, never concurrent processing
2. **Model fallback chains**: primary LLM fails during background op → auto-route to fallback model
3. **Closed-by-default ingress**: unknown sender → block, require explicit operator pairing
4. **Context-aware sandboxing**: shared/untrusted environment → restrict to container sandbox
5. **Atomic approval consumption**: high-risk approval → one-time token, no replay window
6. **Stream context limits**: continuous multi-user channel → strict history cap to prevent overflow
7. **Graceful telemetry degradation**: token estimation error → fall back to safe defaults (0), don't crash loop
8. **Pending delivery persistence**: response generated but network fails → persist, deliver before processing new input
9. **Hierarchical routing fallback**: specific context miss → inherit parent context rules
10. **Plugin isolation from core**: new capability → discrete plugin, never modify core engine

**Unique insight**: OpenClaw's multi-channel gateway architecture means every rule is battle-tested across 23 messaging platforms simultaneously. The routing hierarchy (peer → guild+roles → team → account → channel) is a reusable pattern for any multi-tenant agent system.

---

## Hermes Agent: 10 Architecture Rules (from notebook 8ccf8d90, 16 sources)

1. **5-gate evolution safety**: self-mutation → 100% test pass + size limits + cache compatibility + semantic preservation + human PR review
2. **Single-active memory backend**: multiple backends available but only 1 active at a time — prevents conflicting truth sources
3. **Memory vs Skill routing**: facts → memory, procedures → skills, temp state → session history (never memory)
4. **Dual-layer compression triggers**: agent compressor at 50% tokens + gateway hygiene at 85% — two independent safety nets
5. **Anti-thrashing compression**: last 2 compressions each saved <10% → skip compression entirely (prevents infinite useless loops)
6. **Pre-LLM output pruning**: strip tool outputs >200 chars to 1-line metadata BEFORE calling summarizer LLM
7. **Atomic tool-call boundaries**: never split assistant tool_call from its tool_result during compression boundary calculation
8. **Active task protection**: always keep most recent user message in uncompressed tail — never summarize away the current request
9. **Iterative summary updates**: multiple compressions → pass previous summary back + new turns → update in-place, don't rewrite from scratch
10. **Tool-use enforcement**: agent says "I will do X" → must execute tool call in same response, never end turn with a promise

**Unique insight**: Hermes is the only system with self-evolution (GEPA). The 5-gate safety constraint is the most detailed answer to "how do you let an agent improve itself without breaking itself."

---

## Claude Code: 12+3 Architecture Rules (from notebook 1e86994e, 14 sources + subagent analysis)

### Core 12 (from subagent research):
1. **98.4% harness / 1.6% AI logic** — model reasons, harness enforces
2. **Deny-first with independent failure modes** — safety layers must fail independently
3. **Context scarcity shapes everything** — the binding constraint drives all design decisions
4. **Graduated over monolithic** — cheapest intervention first, expensive as last resort
5. **CLAUDE.md = user context (probabilistic), permissions = enforcement (deterministic)**
6. **Subagent isolation protects parent** — only summaries return, never full history (~7x cost)
7. **Permissions never cross session boundaries** — trust re-established each session
8. **Append-only favors auditability** — JSONL, nothing destructively edited
9. **Zero-cost extensions first** — Hooks → Skills → Plugins → MCP (graduated context cost)
10. **The loop is trivial, the harness is the moat** — ~30 lines of loop, 512K of harness
11. **Trust the model, constrain the environment** — don't pre-specify workflows, give tools + boundaries
12. **One loop for all surfaces** — CLI/headless/SDK/IDE all use same queryLoop

### Additional 3 (from notebook deep ask):
13. **SkillTool vs AgentTool**: need instructions in current context → SkillTool (cheap). Subtask is exploratory/verbose/risks context pollution → AgentTool (expensive, ~7x tokens, summary-only return)
14. **Auto-mode classifier**: separate LLM call, internal/external permission templates, two-stage (fast-filter → chain-of-thought), races against timeout
15. **5-layer compaction activation**: Budget Reduction (always) → Snip (feature-flagged) → Microcompact (always, time-based) → Context Collapse (feature-flagged or overflow) → Auto-Compact (last resort)

**Unique insight**: "The model IS the agent, the code is the harness" philosophy. The 98.4%/1.6% split is not a random statistic — it's the core design principle. Don't build elaborate decision trees; give the model tools and boundaries and let it reason.

---

## Cross-System Comparison: Shared Patterns

| Pattern | OpenClaw | Hermes | Claude Code |
|---------|----------|--------|-------------|
| Agent loop | Pi-agent in persistent gateway | While-loop with per-turn budgets | AsyncGenerator while(tool_use) |
| Context compression | Compaction with fallback model | Dual-layer (50% + 85%) with anti-thrashing | 5-layer graduated pipeline |
| Permission model | Operator pairing + per-agent allow/deny | Config-based, human PR for evolution | 7 modes + deny-first + ML classifier |
| Memory | File-based (MEMORY.md) + vector+keyword hybrid | 8 swappable backends (1 active) | File-based (CLAUDE.md hierarchy), no vector DB |
| Tool execution | Approval manager with atomic tokens | 61 tools, self-registration, dispatch routing | 42 tools, handler dict, path sandboxing |
| Self-improvement | No built-in | GEPA (DSPy + genetic evolution) | No built-in (hooks are extension point) |
| Multi-agent | Gateway routes to isolated workspaces | AGENTS.md profiles, spawn depth limits | AgentTool with 3 isolation modes |

## Cross-System: Unique Contributions to Capability Pack

| System | What only IT teaches | Rule for pack |
|--------|---------------------|---------------|
| OpenClaw | Multi-channel routing hierarchy | "If agent serves multiple interfaces, implement hierarchical routing with parent-context fallback" |
| OpenClaw | Atomic approval consumption | "If approving destructive actions, use one-time tokens with expiration — never replayable approvals" |
| Hermes | Self-evolution safety gates | "If agent improves itself, require 5 gates: test pass + size limit + cache compat + semantic preservation + human review" |
| Hermes | Anti-thrashing compression | "If last 2 compressions saved <10% each, skip — prevents infinite useless summarization loops" |
| Hermes | Memory vs Skill routing | "Facts → memory, procedures → skills, temp state → session history only" |
| Claude Code | 98.4% harness principle | "Invest in the harness, not the training wheels. Model capability improves faster than scaffolding" |
| Claude Code | SkillTool vs AgentTool | "In-context instructions (cheap) vs isolated context (7x expensive, context-safe)" |
| Claude Code | Permissions never persist | "Trust is re-established per session. Never restore permissions from previous sessions" |

---

## Total Research Corpus

| Source Type | Count | Key Items |
|------------|-------|-----------|
| Main notebook (broad) | 58 sources | Frameworks, failure modes, tools, anti-patterns |
| OpenClaw notebook | 14 sources | Core agent files, routing, sandbox, plugins |
| Hermes notebook | 16 sources | Runtime, GEPA, memory, MCP, compression |
| Claude Code notebook | 14 sources | Architecture analysis, 12-session course, philosophy |
| tad-evolution (cross-query) | 45 sources | Competitive landscape, production failures |
| **Total unique sources** | **~102** | |

| Judgment Rules | Count |
|---------------|-------|
| General agent architecture | 24 |
| Production failure causal chains | 7 incidents |
| OpenClaw-specific | 10 |
| Hermes-specific | 10 |
| Claude Code-specific | 15 |
| Memory architecture selection | 5 patterns |
| MCP security checklist | 7 items |
| **Total actionable rules** | **~78** |
