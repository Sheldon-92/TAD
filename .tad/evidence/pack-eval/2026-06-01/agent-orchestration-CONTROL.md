# Orchestration Design Review: Autonomous Research Agent

**Subject:** ~300-step sequential research agent, fully-connected 10-agent swarm, try/except retry-restart loop
**Reviewer perspective:** Senior agent-systems engineer
**Verdict:** Three load-bearing design choices are working against you. Each is individually fixable, but together they compound into a system that will be expensive, hard to debug, and unreliable at this step count. Recommendations below, prioritized.

---

## 1. The retry/restart loop is the most dangerous part of the design

A `try/except` that restarts the whole task on crash is the single biggest risk here, and it's worth fixing first.

**Why it's a problem at 300 steps:**
- **Cost and latency blow up.** If a crash probability per step is even 0.5%, the chance of completing 300 steps without a crash is ~22% (0.995^300). That means most runs crash at least once, and a full restart re-pays for all completed steps. With a naive restart you can easily 3-5x your token spend and wall-clock time. The expected number of restarts grows super-linearly because each restart re-exposes you to the same per-step failure rate.
- **Non-idempotent side effects.** A research agent almost certainly performs side-effecting actions: writing files, posting to APIs, sending notifications, incrementing counters, paying for searches. A blind restart re-executes all of those. You'll get duplicate writes, double-charged API calls, and corrupted state.
- **It masks the actual failure.** Catch-all `except` swallows the stack trace and error class. You lose the ability to distinguish a transient `429 rate limit` (retry-worthy) from a `KeyError`/schema bug (retrying forever is pointless) from an OOM (will recur immediately). A bare retry loop will spin on deterministic failures until you hit a budget cap.

**What to do instead — durable execution / checkpointing:**
- Persist state after every step (or every N steps) so you can **resume from the last good checkpoint**, not restart from zero. This is the core idea behind durable-execution engines (Temporal, Restate, DBOS) and the checkpointer in graph-based agent frameworks (e.g. LangGraph's checkpointer + thread state). Even a hand-rolled version — serialize the agent's working state + step index to disk/DB after each step — recovers 95% of the value.
- **Make every step idempotent** or guard it with an idempotency key, so a re-run of a step that already partially executed doesn't double-apply side effects.
- **Classify errors before retrying.** Retry only transient/retryable classes (timeouts, 429, 5xx, transient network). Fail fast on deterministic errors (validation, schema, auth). Never catch bare `Exception` around the whole task.
- **Use bounded retry with exponential backoff + jitter** at the *step* level, plus a **circuit breaker**: if the same step fails N times with the same error signature, stop and escalate rather than loop. (3 identical failures → escalate is a reasonable default.)
- **Cap total budget** (tokens, wall-clock, dollar) and total restarts explicitly. An autonomous loop with no budget ceiling is an incident waiting to happen.

---

## 2. The fully-connected 10-agent swarm is over-engineered and will be unreliable

A fully-connected topology means any agent can hand off to any other agent: that's 10×9 = 90 directed handoff edges. This is almost always the wrong default.

**Problems:**
- **Routing is unconstrained → non-determinism and loops.** With 90 possible edges and LLM-decided handoffs, you get ping-pong (A→B→A→B), livelock, and agents passing work in circles. There is no structural guarantee the task makes forward progress. Debugging "why did it loop between the summarizer and the critic 14 times" is miserable.
- **Context fragmentation.** Each handoff is a context boundary. State, intermediate findings, and "why we're doing this" must be serialized across 90 possible edges. Information gets dropped or distorted at each hop (the "telephone game"). For a research task where evidence provenance matters, this is corrosive — citations and source context get lost in handoffs.
- **Error attribution is near-impossible.** When the final report is wrong, which of 10 agents and which of N handoffs introduced the error? Fully-connected swarms have the worst observability profile of any topology.
- **Coordination cost scales badly.** Multi-agent systems multiply token cost (each agent re-reads context) — Anthropic's own multi-agent reporting puts orchestrator-worker systems at roughly 4-15x the token cost of single-agent. A 10-way swarm with free-form handoffs is at the expensive end with little of the reliability benefit.

**Strongly prefer a supervisor/orchestrator-worker topology:**
- One **orchestrator** (planner/lead) decomposes the task and dispatches to specialist workers. Workers report back to the orchestrator, not to each other. This reduces the edge count from 90 to ~18 (10 down, ~8 up) and makes control flow a tree, not a mesh.
- This matches how the most successful production research-agent designs are built (lead agent spawns subagents, subagents return results, lead synthesizes). It gives you a single place to enforce budget, dedup, and progress checks.
- **Question whether you need 10 specialists at all.** Most research tasks need: a planner, a retriever/searcher, a reader/extractor, a verifier/fact-checker, and a synthesizer. That's ~5 roles. Adding agents adds coordination overhead and failure surface without proportional capability gain. Don't add a swarm where a single agent with good tools + a verification pass would do. Start with the simplest topology that works and add agents only when you've measured a specific gap.
- If you genuinely need peer-to-peer handoff for some flows, use a **constrained** handoff graph (an explicit state machine / allowed-transition set), not a fully-connected mesh. Define which agent can hand to which, and add loop guards (max revisits per node).

---

## 3. 300 sequential steps is a context- and reliability-management problem you haven't addressed

The design says nothing about context window management, and at 300 steps that's the silent killer.

- **Context overflow / "context rot."** 300 steps of tool outputs (search results, fetched pages, intermediate reasoning) will not fit in any context window if naively accumulated. Model quality also degrades as the context fills, even below the hard limit. You need an explicit **compaction / summarization strategy**: roll up older steps into summaries, offload raw artifacts to external storage (files, a vector store, a scratchpad) and retrieve on demand rather than keeping everything resident.
- **Error compounding.** With 300 sequential steps, even 99% per-step reliability yields only ~5% chance of a fully clean run (0.99^300 ≈ 0.05). You cannot rely on every step being correct. Build in **verification checkpoints** — periodic self-checks / a verifier agent that validates intermediate findings before the task proceeds, so errors are caught locally instead of propagating to step 300.
- **Observability is mandatory at this scale.** You need tracing (per-step input/output/cost/latency/error), structured logs, and the ability to replay a run from a checkpoint. Without distributed tracing you will not be able to debug a 300-step run. Instrument before you scale up, not after.
- **Forward-progress / termination guarantees.** What stops the agent? You need explicit termination conditions (goal satisfied, budget exhausted, max steps), a "no-progress" detector (N steps with no new information → stop or escalate), and a final acceptance check on the deliverable.

---

## Concrete priority list

1. **Replace restart-from-zero with checkpoint-and-resume.** Persist state per step; resume from last good checkpoint. (Biggest reliability + cost win.)
2. **Make side-effecting steps idempotent / guard with idempotency keys.** Required before any retry is safe.
3. **Replace catch-all retry with error classification + bounded backoff + circuit breaker + global budget cap.** Retry only transient errors.
4. **Collapse the fully-connected swarm into a supervisor/orchestrator-worker topology.** Reduce 90 edges to a tree. Reconsider whether 10 agents are needed (5 roles likely suffice).
5. **Add a context-compaction strategy** (summarize + offload to external store + retrieve on demand) so 300 steps don't overflow context.
6. **Add verification checkpoints + forward-progress/termination guards** so errors are caught locally and the loop can't run forever.
7. **Instrument with per-step tracing and run replay** before scaling step count.

## What's reasonable about the current design

- Wanting fault tolerance for a long-running task is the right instinct — the *mechanism* (blind restart) is the problem, not the goal.
- Decomposing into specialists is a sound idea in principle; it's the *topology* (mesh vs supervisor) and the *count* that need adjustment.

If you fix #1–#3 first, you'll get most of the reliability and cost improvement for the least work. #4 is the larger refactor but the one that most improves debuggability long-term.
