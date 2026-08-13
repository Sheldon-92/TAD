# D2: Agent Coordination and State Management

**Decision**: How should agents coordinate with each other, and who owns canonical state?

This decision applies when you have more than one agent. A wrong topology (flat, no hierarchy) combined with shared mutable state is the single most common source of production disasters in multi-agent systems.

---

## Selection Matrix: 6 Coordination Patterns [Source: Anthropic Building Effective Agents]

| Pattern | Use When | Selection Criteria | Failure Mode If Wrong |
|---------|----------|-------------------|----------------------|
| Prompt Chaining | Fixed subtasks, linear pipeline | Subtasks are predictable and sequential | Inflexible when subtasks vary |
| Routing | Distinct categories needing different handling | Input categories are known upfront | Classifier errors cascade |
| Parallelization | Subtasks can run simultaneously | Subtasks are independent (no shared state) | Race conditions, stale state |
| Orchestrator-Workers | Subtasks are unpredictable | Subtask list emerges from execution | Orchestrator becomes bottleneck |
| Evaluator-Optimizer | Iterative quality improvement needed | Clear eval criteria exist | Infinite refinement loops |
| Autonomous | Fully open-ended tasks | Domain is too dynamic for fixed routing | Maximum failure probability |

**Rule**: choose the simplest pattern that handles your task. Each step up the list doubles failure probability. [Source: Claude Code #11]

---

## The Multi-Agent Economic Threshold [Source: research finding #25, https://www.anthropic.com/engineering/multi-agent-research-system retrieved 2026-06-13]

Before choosing ANY multi-agent topology, verify the work justifies the cost multiplier:

- Anthropic's orchestrator-worker Research system beat single-agent Opus 4 by **90.2%** — but burns **~15x the tokens** of normal chat.
- **Token usage explains ~80% of performance variance** (BrowseComp eval). Multi-agent wins largely *because* it spends more tokens, not because of topology magic.

**Decision rule**: multi-agent pays off ONLY for **high-value, breadth-first work whose information exceeds one context window** — legal due diligence, competitive intel, biomedical literature review. Consumer Q&A, chat, and narrow single-domain tasks **cannot absorb the 15x multiplier** → default to a single agent. If a single agent fits in one context window, the 15x spend buys nothing.

## Durable Execution: Checkpoint-Based Recovery [Source: research finding #29, https://github.com/langchain-ai/langgraph retrieved 2026-06-13]

Any multi-agent topology needs a recovery story when a worker crashes mid-task. The current framework primitive is **durable execution** — persist through failures and **resume from the exact checkpoint**, not from scratch.

- **LangGraph 1.0** (GA October 2025): unified Router / Supervisor / Subagent primitives + durable execution; **~33,900 GitHub stars, 34.5M monthly downloads**. Use its checkpointer to make orchestrator state recoverable.
- **CrewAI** (5K+ stars): role-based coordination, lighter-weight.

**Rule**: do not hand-roll orchestrator state recovery. Pick a framework whose checkpointer persists the orchestrator's canonical state (per the hub-spoke rule below) so a worker failure resumes from the last checkpoint instead of replaying the whole session.

---

## Pattern 1: Prompt Chaining

One agent's output becomes the next agent's input. Fixed sequence.

```
Input → Agent A → Agent B → Agent C → Output
```

**When RIGHT**: document pipeline (summarize → translate → format), data transformation, fixed multi-step generation.

**When WRONG**: if step 3's subtask depends on step 2's output in ways you can't predict upfront, chaining fails — step 3 will receive the wrong input and have no way to signal that.

**State management**: pass state as explicit structured output between steps. Never rely on implicit shared context.

---

## Pattern 2: Routing

A classifier routes input to the appropriate specialized agent.

```
Input → Classifier → [Agent A | Agent B | Agent C] → Output
```

**When RIGHT**: inputs fall into distinct categories (simple vs complex, technical vs emotional, domain A vs domain B).

**Classic implementation** [Source: Claude Code #3]: cheap model classifies, expensive model handles complex cases. 40-60% cost reduction when classification accuracy is high.

**When WRONG**: category boundaries are fuzzy, or classifier errors are expensive. A misrouted high-stakes input to the wrong agent produces confident wrong output.

---

## Pattern 3: Parallelization

Multiple agents run simultaneously, results aggregated.

```
Input → [Agent A ‖ Agent B ‖ Agent C] → Aggregator → Output
```

**Two sub-modes**:
- **Sectioning**: each agent handles a different section of the input (no overlap)
- **Voting**: each agent handles the full input, majority vote or best-of-N selection

**When RIGHT**: agents don't share mutable state, subtasks are truly independent, throughput matters.

**Safe shared-state patterns for parallelization** [Source: distributed systems fundamentals]:
Agents can share state under parallelization if writes use one of these safe patterns:
1. **Append-only writes** — each agent writes its own row/event; no agent overwrites another
2. **CRDT / commutative operations** — counter increments, set unions, last-writer-wins with vector clocks
3. **Per-agent partition keys** — agent A writes only to `partition[A]`, agent B only to `partition[B]`

**Unsafe case** [Source: Incident #5 — support ticket race condition]: overlapping writes to the same mutable record. If parallel agents both write to the same entity without coordination, one write overwrites the other or the entity enters a corrupt intermediate state.

**Rule**: overlapping mutable writes + parallelization = hub-spoke required (see Orchestrator-Workers). Append-only / CRDT / partitioned writes are safe with parallelization.

---

## Pattern 4: Orchestrator-Workers

A central orchestrator decomposes a task into subtasks, dispatches to workers, aggregates results.

```
Input → Orchestrator → [Worker A, Worker B, ...] → Orchestrator → Output
```

**When RIGHT**: subtasks are unpredictable (orchestrator decides dynamically), workers have specialized tools, result integration requires reasoning about outputs.

**Hub-spoke state rule** [Source: Incident #5 + #6]: the orchestrator MUST be the single canonical state owner. Workers read state from orchestrator, write results back to orchestrator — never directly to shared storage. This prevents:
- Race conditions (#5: support ticket assigned AND closed by parallel workers)
- Ordering failures (#6: financial trading execution before price update arrived)

**Polling Tax anti-pattern** [Source: research — Expert Mistake #2]: synchronous request-response loops between orchestrator and workers waste 95% of API calls. Workers signal completion; orchestrator does not poll. Use event-driven callbacks or message queue patterns.

---

## Pattern 5: Evaluator-Optimizer

One agent generates, another evaluates. Iterates until quality threshold met.

```
Input → Generator → [Evaluator: PASS?] → Output
                      ↓ FAIL
                    Generator (revised)
```

**When RIGHT**: clear quality criteria exist that can be applied programmatically, iterative refinement improves output, loops terminate (quality converges).

**When WRONG**: evaluator criteria are vague or circular. An evaluator that says "make it better" without a measurable threshold produces infinite loops with no convergence signal.

**Loop termination requirement**: the agent MUST have an explicit iteration budget (max N rounds). [Source: research finding #2 — 60% of early-2026 LLM errors = runaway loops].

---

## Pattern 6: Autonomous Agent

Agent has full tool access and decides its own next actions.

```
Input → Agent → [tools/decisions] → Agent → ... → Output
```

**When RIGHT**: problem is fully open-ended, domain is dynamic, human oversight is explicitly in the loop.

**Risk**: this is the highest-probability failure mode. 10-step chain at 98% per step = 81.7% total success. [Source: research finding #1]. Every additional autonomous step reduces total success probability.

**Mitigation if required**: sandboxing (container-isolated tools), guardrails at API gateway, explicit scope boundaries, HITL gates for destructive actions.

---

## State Synchronization: Event Sourcing [Source: Incident #4]

**Problem**: Agent A updates state → Agent B reads state during transition → Agent B sees partial state → cascading inconsistency.

**Solution: Event Sourcing**
- State is a sequence of immutable events, not a mutable record
- Agents append events; they NEVER read-modify-write state
- Current state is derived by replaying events to the current timestamp
- Agents that need state read a consistent snapshot as of a specific event sequence number

**When required**: any system where multiple agents can modify the same entity. E-commerce (inventory), finance (account balance), scheduling (calendar), support (ticket state).

**Optimistic concurrency alternative**: agents include the state version they read when writing. If version has changed since their read, the write fails → agent retries with fresh state. Simpler than full event sourcing for low-contention scenarios.

---

## OpenClaw: Hierarchical Routing Fallback [Source: OpenClaw #9]

For agents serving multiple contexts (tenants, channels, roles):

```
Lookup order: peer context → guild+roles context → team context → account context → channel context
```

If the most specific context (peer) has no rule for this input, inherit from the next level up. This prevents "null routing" failures where an agent has no applicable rule and either crashes or makes an arbitrary decision.

**Application**: any multi-tenant agent system. Build a routing hierarchy before going to production. Undefined contexts should fail loudly with "no matching rule" rather than silently falling back to global defaults.

---

## OpenClaw: Concurrent Session Serialization [Source: OpenClaw #1]

Multiple messages arriving simultaneously to the same session → write lock, process sequentially, never concurrent.

**Why**: concurrent session writes produce race conditions at the message-processing level even before state is touched. One message's tool call can overwrite another message's context mid-execution.

**Implementation**: session-level mutex or queue. Messages are enqueued; only one processes at a time per session. Throughput scales by adding sessions, not by allowing concurrent access per session.

---

## Anti-Pattern: Bag of Agents [Source: research — Expert Mistake #1]

Flat topology where all agents are equal peers with no coordination hierarchy.

```
Agent A ←→ Agent B ←→ Agent C ←→ Agent A (loop)
```

**What goes wrong**: without a hierarchy, agents have no authority to override each other. Hallucinations from one agent propagate to others as "confirmed facts." No agent has the authority to break the loop. The system reaches consensus on wrong answers.

**Fix**: always designate an orchestrator that owns task decomposition and result integration. Workers execute, orchestrator decides.

---

## Cross-Reference

- **When to use agents at all**: see D1 (need-an-agent.md)
- **State storage for coordinated agents**: see D3 (context-memory.md)
- **Permission scoping per agent in a topology**: see D5 (permissions-safety.md)
- **Token cost of orchestration overhead**: see D7 (cost-token-economics.md)
- **Tracing multi-agent transitions**: see D8 (observability.md)
- **Disasters this decision prevents**: see D10 (production-disasters.md), Incidents #4, #5, #6 (stale state, race condition, ordering failure)
