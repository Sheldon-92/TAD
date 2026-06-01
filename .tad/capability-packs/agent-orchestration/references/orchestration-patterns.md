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

---

## Anti-Patterns

- **Unbounded swarm**: a 10-agent fully-connected swarm has 90 directed handoff pathways and is untestable — a P0.
- **Single supervisor for huge fan-out**: synchronous hub-and-spoke is a throughput bottleneck; the supervisor also saturates after 8-12 turns.
- **No re-grounding in long swarms**: past 8-10 turns the agent forgets the original intent.
- **Choosing topology on aesthetics**: "swarms feel modern" — but the O(n²) failure surface is a real testing-cost explosion.
