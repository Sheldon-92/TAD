# O2-KR2/KR3 Research Findings — Prioritization Matrix + Epic Outlines

> Notebook: TAD Evolution Research (37cfefa5)
> Date: 2026-05-14
> Seeds: 5 (S1: effort, S2: impact, S3: failures, S4: structure, S5: migration)
> Based on: 45 curated sources + 5 prior rounds of deep-ask

---

## Phase 4 Raw Findings Summary

### S1: Implementation Effort
- Sources lack specific engineer-weeks/LOC data for individual directions
- Key signals: "rolling your own checkpointing = multi-week project" (LangGraph)
- LangGraph ramp-up: 1-2 weeks; CrewAI: 2-4 hours; Claude Agent SDK: minutes
- Simple agent LOC: Smolagents ~40 LOC, LangGraph ~120 LOC

### S2: User-Visible Impact (Hard Metrics)
**Tier 1 — Proven via benchmarks:**
- Deferred tool loading: 85% token savings, accuracy 49%→74% (Anthropic), 62%→91% (ToolRet)
- Graph memory (Mem0g): 91% latency reduction, 90% token savings, 68.4% accuracy
- Structural validation gates: system accuracy 81.7%→98.0% (10-agent pipeline)
- Stateful orchestration: 40-50% token savings vs role-based (CrewAI 3x overhead)

**Tier 2 — Proven via telemetry:**
- SLM trajectory evaluation: 98% cost reduction, sub-200ms, 0.87-0.88 accuracy
- Capability pack restructuring: 206% quality improvement, 28% runtime reduction, 6-7x knowledge density
- Prompt caching: 80-90% cost reduction (only 28% of calls currently use it)

### S3: Failure Cases & Anti-Patterns
1. AutoGen deprecated (conversation-based multi-agent = expensive, hard to constrain)
2. Tool overload: 5 MCP servers × 58 tools = 55K tokens BEFORE reasoning; accuracy collapses
3. Context rot: poorly structured AGENTS.md REDUCES success rate + inflates costs 20%
4. Memory poisoning: hallucinated/injected facts consolidated into long-term memory
5. Claude Code quality drop (April 2026): prompt update broke reasoning, had to rollback

### S4: Implementation Structure
- LangGraph checkpointing: graph-native (nodes + edges + state), built-in pause/resume/rewind
- Anthropic Agent SDK: YAML frontmatter Markdown files, Agent tool invocation, 1-level depth limit
- Async infrastructure: Anthropic = brain/hands/event-log separation; mcp-agent = Temporal; Copilot = GitHub Actions; Devin = isolated cloud VMs

### S5: Migration Strategy
- **Incremental** (pack-by-pack), NOT big-bang — "prohibitively expensive" to do all at once
- AKU schema (7 fields): Intent, Procedural, Tool Bindings, Metadata, Governance, Continuation, Validators
- Token budget: <5,000 tokens per skill; 2,000→300 token compression achievable (6-7x density)
- Progressive disclosure: metadata registry (30-50 tokens/skill) → relevance match → full load
- "Degrades gracefully" — agents fall back to baseline reasoning for tasks without packs

---

## Phase 5 — Feasibility × Impact Prioritization Matrix (O2-KR2)

| Rank | Direction | Impact Score | Impact Evidence | Feasibility | Risk | TAD Current State |
|------|-----------|-------------|-----------------|-------------|------|-------------------|
| 1 | **Capability Pack Completion** (Domain Pack→AKU + deferred loading) | ★★★★★ | 206% quality↑, 85% token↓, 6-7x density, accuracy 62→91% | HIGH — incremental, 8/20 done, Claude Code has ToolSearch | LOW — degrades gracefully | 8 packs built, 12 remaining |
| 2 | **Agent Escalation Enhancement** (uncertainty detection + proactive pause) | ★★★☆☆ | Behavioral (not quantified), but prevents compounding errors | HIGH — honest_partial + circuit breaker exist | LOW — incremental | Primitives exist, needs refinement |
| 3 | **Trajectory Evaluation Harness** (SLM-as-Judge for Gate quality) | ★★★★☆ | 98% cost↓, 0.87 accuracy, sub-200ms | MEDIUM — need rubric + harness | LOW — offline eval, no prod risk | *optimize traces exist, no judge |
| 4 | **Graph Memory** (entity-relationship knowledge store) | ★★★★☆ | 91% latency↓, 90% token↓ | LOW — needs entity extraction + graph DB | HIGH — memory poisoning risk | project-knowledge/ is flat files |
| 5 | **Durable Checkpointing** (session crash recovery + YOLO resume) | ★★★☆☆ | Enables time-travel debug, crash recovery | LOW — "multi-week project" | MEDIUM — event log architecture | session-state.md is primitive |

**Not ranked (deprioritized):**
- Structural Validation Gates: TAD ALREADY HAS (Gate 3/4 + Ralph Loop) — maintain, don't invest
- Async PR Workflow: requires cloud infrastructure, over-engineering for single-user CLI
- Distributed Tracing: useful but not urgent; simple JSONL sufficient for now
- Prompt Caching: Anthropic handles this; TAD just needs to restructure context loading (bundled with #1)

---

## Epic Outlines (O2-KR3)

### Epic A: Capability Pack Completion (Rank #1)
**Objective:** Convert remaining 12 high-frequency Domain Packs to Capability Packs (AKU format), then deprecate YAML packs.
**Phase Map:**
| Phase | Name | Scope | Depends On |
|-------|------|-------|------------|
| 1 | Priority Triage | Identify top 5 packs by usage frequency (from *optimize traces). Freeze pack list. | — |
| 2 | Batch Conversion (5 packs) | Convert top 5 using /capability-upgrade workflow. AKU format: Intent + Procedural + Tool Bindings + Continuation + Validators. <5K tokens each. | Phase 1 |
| 3 | Deferred Loading Integration | Ensure all converted packs use ToolSearch progressive disclosure pattern. Metadata registry <50 tokens/pack. | Phase 2 |
| 4 | Deprecation + Cleanup | Freeze Domain Pack YAML directory. Update CLAUDE.md routing. Run *sync to all projects. | Phase 3 |
| 5 | Validation | Dogfood on 2 real projects. Measure: token savings, pack activation rate, quality improvement. | Phase 4 |

### Epic B: Agent Escalation Enhancement (Rank #2)
**Objective:** Enhance Blake's uncertainty detection — proactive pause instead of waiting for human to notice failures.
**Phase Map:**
| Phase | Name | Scope | Depends On |
|-------|------|-------|------------|
| 1 | Uncertainty Signal Catalog | Identify all current escalation points (honest_partial, circuit breaker, Ralph Loop failures). Map gaps: where does Blake silently proceed instead of escalating? | — |
| 2 | Proactive Pause Protocol | Design uncertainty detection triggers (consecutive same errors, confidence drop, scope creep beyond handoff). Add to Blake SKILL.md. | Phase 1 |
| 3 | YOLO Mode Integration | Wire escalation into yolo_execution_protocol — pause on uncertainty instead of circuit-breaking to human. | Phase 2 |

### Epic C: Trajectory Evaluation Harness (Rank #3)
**Objective:** Build lightweight eval harness that measures agent reasoning quality per-step (not just final outcome), using SLM-as-Judge.
**Phase Map:**
| Phase | Name | Scope | Depends On |
|-------|------|-------|------------|
| 1 | Rubric Design | Define 7-dimension eval rubric for TAD (adapted from CLEAR framework: Cost, Latency, Efficacy, Assurance, Reliability + TAD-specific: Knowledge Activation, Gate Compliance). | — |
| 2 | Judge Harness Spike | Build minimal judge using Haiku (cheapest Claude) or local SLM. Input: trace JSONL. Output: per-step scores. Target: 0.80 Spearman with human judgment. | Phase 1 |
| 3 | Integration | Wire judge into *optimize pipeline. Replace manual JSONL parsing with structured eval scores. | Phase 2 |
