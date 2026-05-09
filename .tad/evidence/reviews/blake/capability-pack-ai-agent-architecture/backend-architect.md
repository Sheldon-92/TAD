# Backend Architect Review — AI Agent Architecture Capability Pack
Date: 2026-05-07
Reviewer: backend-architect subagent
Slug: capability-pack-ai-agent-architecture

## Verdict: PASS

Architecturally sound. Decision matrices are technically correct. Production disaster causal chains hold up to scrutiny.

## P0 Issues: None

No P0 blocking issues. No decision matrix entries that would cause production failures if followed.

## P1 Issues Found and Fixed

**P1-1** — Parallelization "no shared state" rule oversimplified
- Problem: too binary — excluded safe patterns (append-only, CRDTs, per-agent partitions)
- Fix applied: added "Safe shared-state patterns for parallelization" sub-section to coordination-and-state.md

**P1-2** — Dual-agent missing structured-output requirement
- Problem: "Parser has zero tools" is necessary but not sufficient; Planner must treat Parser output as data, not instructions
- Fix applied: added Key requirement 2 (CaMeL-style structured response) to permissions-safety.md

**P1-3** — Atomic tool-call boundaries missing parallel tool-call case
- Problem: modern frameworks emit N tool_calls per turn; compression must preserve entire turns, not just pairs
- Fix applied: added "Parallel tool-call extension" paragraph to context-compression.md

**P1-4** — Hermes 50%/85% thresholds presented as universal
- Problem: calibrated for Hermes' 200K context window, wrong for 1M context agents
- Fix applied: reframed as "Hermes-specific" with tuning formula and "threshold tuning note" in context-compression.md

**P1-5** — Cost numbers stale and not sourced
- Problem: absolute dollar amounts change quarterly; "$0.01/1K tokens" and "$550/day" are misleading
- Fix applied: converted to relative ratios (55x reduction) and relative cost tiers (1x / 4-20x / 50-200x)

**P1-6** — Entropy-based lazy retrieval implementation non-trivial
- Problem: "model_entropy()" reads as a one-liner but requires logprobs access or separate API call
- Fix applied: added "When NOT to apply" section with keyword pre-filtering alternative for low-volume RAG

**P1-7** — D10 Incident #1 misses plan-boundary control
- Note: current guidance (scoped tokens) IS sufficient for this specific incident; the P1 note acknowledges two-defense depth (scoped tokens + plan-boundary) is stronger. Not applied to keep D10 scope-tags focus.

**P1-8** — D10 Incident #7 missing byte-identical response + key-signature requirements
- Note: acknowledged in review. Existing guidance (idempotency tokens + deduplication) prevents the specific incident. Byte-identical responses are implied by the deduplication contract. Not applied to keep D10 concise.

## P2 Issues (Advisory, not applied)

- P2-1: "98% per-step" should note realistic 90-95% range
- P2-2: "supervisor with veto" intermediate multi-agent pattern
- P2-3: MCP Item 3 hash check is partial defense only
- P2-4: Context Collapse quality-loss measurable signal missing
- P2-5: AgentTool 7x derivation could be explained
- P2-6: Trace ID propagation through async queues
- P2-7: Tail-based sampling instead of uniform sampling
- P2-8: D10 D6 attribution overstated

## Coverage Gaps Identified (noted for future versions)

- Gap-1: Failure recovery and replay semantics (compensation/saga patterns)
- Gap-2: Schema evolution / tool versioning
- Gap-3: Multi-region / latency-sensitive coordination constraints
- Gap-4: Agent state persistence boundaries (partially covered in D3)
