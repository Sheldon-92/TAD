# Orchestration Topology Rules (Supervisor vs Swarm)
<!-- capability: orchestration_patterns -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| SUP1 | Supervisor for centralized validation + controlled error propagation (O(n) failure scale) | deterministic |
| SUP2 | Supervisor costs a 20-40% token premium and saturates context after 8-12 round trips | semi-deterministic |
| SUP3 | Swarm directed-handoff failure surface scales O(n²) = n(n-1) — untestable beyond ~5 agents | deterministic |
| SUP4 | Swarm drifts after 8-10 sequential agent turns; semantic drift compounds | non-deterministic |
| SUP5 | Swarm for read-heavy exploratory work (triage, content gen, debate); Supervisor for quality gating | deterministic |
| OW1 | Orchestrator-worker pays off ONLY for high-value parallelizable read-heavy breadth — multi-agent costs ~15x chat tokens | deterministic |
| OW2 | Size subagent fan-out to complexity bands: 1 / 2-4 / 10+ agents; lead spawns 3-5 in parallel, each runs 3+ tools | semi-deterministic |
| OW3 | Single-writer principle: prefer single-threaded linear for one coherent artifact; no peer subagents w/ conflicting implicit decisions | deterministic |

---

## Rules

### SUP1: Supervisor — Centralized Validation Gate (O(n) failure)

The Supervisor (hub-and-spoke) pattern uses a central routing agent that decomposes the request, dispatches to specialist workers, and validates output before advancing.

- Quality-control advantage: the supervisor intercepts erroneous/malformed outputs before they propagate downstream, prevents infinite loops via explicit re-dispatch limits, and resolves contradictory worker results.
- Failure surface scales **linearly, O(n)**, with the number of registered worker roles — controlled and debuggable.

**Rule**: Use Supervisor when you need a centralized validation gate, controlled error propagation, or conflict resolution among workers.

> Source: findings.md "Centralized Supervisor Pattern" [23]

**determinismLevel**: deterministic — topology is a design decision.

### SUP2: The Supervisor Tax — 20-40% Tokens + Context Saturation

When choosing Supervisor, budget for its costs:

- A supervisor architecture incurs a **20% to 40% token overhead** vs direct routing, because the coordinator reasons about every dispatch.
- The coordinator must accumulate the full message history of all worker interactions, so its context window saturates: after **8 to 12 round trips**, routing accuracy degrades significantly as historical noise crowds out current state.
- The synchronous dispatch loop is a throughput bottleneck for embarrassingly parallel workloads.

**Rule**: If a Supervisor workflow exceeds ~8-12 worker round trips, add context-compaction or hierarchical sub-supervisors — do not let one coordinator accumulate unbounded history.

> Source: findings.md "Centralized Supervisor Pattern" [23]

**determinismLevel**: semi-deterministic — saturation depends on runtime turn count.

### SUP3: Swarm Failure Surface is Quadratic — n(n-1)

The decentralized Swarm (handoff) pattern distributes routing across the agent pool; each agent owns its instructions, tools, and explicit handoff definitions, transferring control via a handoff tool call while sharing conversation history.

Handoffs are **directional** (agent A→B is a different transition than B→A), so a fully-connected peer-to-peer swarm's handoff-pathway count scales **quadratically, O(n²)**:

```
Directed handoff pathways = n(n - 1)
```

- 4 agents → **12** directed handoff pathways
- 10 agents → **90** directed handoff pathways — exhaustive state-space testing is unfeasible (the count of *undirected* agent pairs is n(n-1)/2 = 45, but each pair carries two directed handoffs)

**Rule**: Do not ship a fully-connected swarm above ~5 agents. Beyond that, either constrain the handoff graph (not every agent can hand off to every other) or switch to a Supervisor with O(n) scaling.

> Source: findings.md "Decentralized Swarm (Handoff) Pattern" [23]

**determinismLevel**: deterministic — the pathway count is a closed-form function of n.

### SUP4: Swarm Semantic Drift After 8-10 Turns

Each handoff is a probabilistic event. Because no single entity holds a global view of workflow state, as the workflow progresses **beyond 8 to 10 sequential agent turns, semantic drift compounds** — the active agent can lose track of the original user intent or drift into conflicting outputs. Unexpected routing loops and cascading failures are hard to debug.

**Rule**: For swarms expected to exceed ~8-10 handoffs, insert a re-grounding step (re-inject the original objective) or escalate to a supervised topology. Malformed states propagate unchecked across peers in a pure swarm.

> Source: findings.md "Decentralized Swarm" [23,24]

**determinismLevel**: non-deterministic — drift depends on conversation dynamics.

### SUP5: Pick Topology by Workload Shape

| Workload | Topology | Why |
|----------|----------|-----|
| High-risk, needs output validation, conflict resolution | Supervisor | Centralized gate intercepts bad outputs (SUP1) |
| Read-heavy / exploratory: triage, content generation, multi-agent debate | Swarm | Lightweight; tokens consumed only by the active agent (no coordinator tax) |
| Embarrassingly parallel fan-out | Neither pure form | Supervisor bottlenecks (SUP2); swarm error-propagates (SUP3) — use bounded parallel workers under a supervisor |

**Rule**: Swarm is token-efficient (no central coordinator burning tokens) and ideal for exploratory read-heavy paths; Supervisor is the choice whenever a validation/quality gate matters more than token cost.

> Source: findings.md "Multi-Agent Interaction Patterns", supervisor/swarm comparison table [22,23,25]

**determinismLevel**: deterministic — the mapping is a design decision.

### OW1: Orchestrator-Worker Economics — Multi-Agent Costs ~15x, So Pay Only for the Right Shape

Multi-agent is not free reliability — it is a token-for-breadth trade. From Anthropic's production multi-agent research system (a lead Opus model + Sonnet subagents):

- The multi-agent system **beat single-agent Opus 4 by 90.2%** on Anthropic's internal research eval.
- It cost **~15x the tokens of a normal chat interaction** (agents *alone*, even single-agent, already run ~4x chat tokens).
- **Token usage alone explains ~80% of the performance variance** on the BrowseComp eval; **three factors — token use, tool-call count, and model choice — explain ~95%**.

**Rule**: Reach for orchestrator-worker (multi-agent) ONLY for **high-value, parallelizable, read-heavy breadth** tasks where the ~15x token multiplier is absorbable — e.g. broad research, large-corpus triage. Do NOT use it for cheap Q&A or for any task that must produce a single coherent artifact (those want a single-threaded agent, OW3). "Swarm is token-efficient" is only true *relative to a supervisor's coordinator tax* — in absolute terms multi-agent is expensive; justify it by value and parallelism, not by reflex.

> Source: Anthropic — Building a multi-agent research system, https://www.anthropic.com/engineering/multi-agent-research-system (retrieved 2026-06-13): 90.2% improvement, ~15x token multiplier, ~4x agent multiplier, 80%/95% variance explained.

**determinismLevel**: deterministic — the cost/benefit threshold is a design decision driven by reported figures.

### OW2: Size the Fan-Out to Complexity Bands — Don't Over- or Under-Spawn

Scale subagent effort to query complexity using Anthropic's measured bands:

| Query shape | Subagents | Tool calls each |
|-------------|-----------|-----------------|
| Simple fact-finding | **1 agent** | 3-10 |
| Direct comparisons | **2-4 subagents** | 10-15 |
| Complex research | **10+ subagents** | clearly divided responsibilities |

- Standard parallelization: the lead **spawns 3-5 subagents in parallel**, and **each subagent runs 3+ tools in parallel**.
- Teaching the lead to write **detailed subagent task descriptions cut task-completion time ~40%** (this is also MAST's 42% spec-failure lever — see failure-modes FM2).
- These parallelization changes **cut research time up to 90%** on complex queries.

**Rule**: Match fan-out to the band. Over-spawning burns the ~15x multiplier (OW1) for no gain; under-spawning serializes work and adds latency. Always pair fan-out with detailed per-subagent task specs — the description quality is worth ~40% of completion time.

> Source: Anthropic — Building a multi-agent research system, https://www.anthropic.com/engineering/multi-agent-research-system (retrieved 2026-06-13): 1 / 2-4 / 10+ bands, 3-5 parallel subagents, 3+ parallel tools, 40% description-tuning time cut, 90% research-time cut.

**determinismLevel**: semi-deterministic — the band is a guideline; actual count depends on runtime query shape.

### OW3: The Single-Writer Principle — Why Peer Swarms Drift (SUP3/SUP4 root cause)

Cognition's two production principles name WHY parallel peer subagents fail (the mechanism behind SUP3's O(n²) surface and SUP4's 8-10-turn drift):

1. **Share context, and share full agent traces — not just individual messages.** Agents that see only each other's final messages, not the reasoning that produced them, cannot integrate work coherently.
2. **Actions carry implicit decisions, and conflicting decisions carry bad results.** Two parallel agents each make implicit choices that silently contradict.

Concrete failure: a Flappy-Bird clone split across two parallel subagents **without shared context** produced a Super-Mario-style background plus a non-game-like bird — two locally-reasonable outputs that **could not be combined** into a coherent game.

**Rule**: For any task needing **one coherent artifact**, prefer a **single-threaded linear agent with continuous context**. Use orchestrator-worker only for parallelizable breadth, and structure it as **one context owner + isolated workers that return summary strings** — NO peer-to-peer channel, NO shared mutable state. Never run peer subagents that make conflicting implicit decisions without sharing full traces.

> Source: Cognition — Don't Build Multi-Agents, https://cognition.ai/blog/dont-build-multi-agents (retrieved 2026-06-13): two single-writer/shared-context principles, Flappy-Bird conflicting-subagent failure, single-threaded-linear recommendation.

**determinismLevel**: deterministic — the topology constraint is a design decision.

---

## Anti-Patterns

- **Multi-agent for the wrong shape**: spinning up subagents for cheap Q&A or for a single coherent artifact — pays the ~15x token multiplier (OW1) with no breadth payoff.
- **Over- / under-spawning**: ignoring the 1 / 2-4 / 10+ complexity bands (OW2) — burns tokens or serializes latency.
- **Peer subagents without shared traces**: the Flappy-Bird failure — conflicting implicit decisions produce un-combinable outputs (OW3).
- **Unbounded swarm**: a 10-agent fully-connected swarm has 90 directed handoff pathways and is untestable — a P0.
- **Single supervisor for huge fan-out**: synchronous hub-and-spoke is a throughput bottleneck; the supervisor also saturates after 8-12 turns.
- **No re-grounding in long swarms**: past 8-10 turns the agent forgets the original intent.
- **Choosing topology on aesthetics**: "swarms feel modern" — but the O(n²) failure surface is a real testing-cost explosion.
