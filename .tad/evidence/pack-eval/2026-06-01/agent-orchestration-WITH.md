## Orchestration Review: Autonomous research agent (300 sequential steps, 10-agent fully-connected swarm, try/except retry loop)

### Complexity Cliff Audit
- Stated step count: **s = 300** | per-step p assumption: **p = 0.01** (a generous 99% per-step success rate) | P(fail) = 1 − (1−p)^s = **1 − 0.99³⁰⁰ ≈ 95.1%**
- For calibration against the pack's anchor figures: the same `1 − (1−p)^s` model gives 63.4% @ 100 steps and 99.3% @ 500 steps (findings.md "Exponential Failure Mechanics" [2]). Your 300 steps sit ~95% — deep above the cliff. Even at an optimistic p = 0.005, P(fail) = 1 − 0.995³⁰⁰ ≈ **77.7%**. There is no realistic per-step `p` at which 300 sequential steps on a bare retry loop survives.
- **Verdict: durable / event-sourced execution is MANDATORY.** A bare `try/except` retry loop is the explicitly-named anti-pattern for this exact case (durable-execution.md Anti-Patterns: "a 300-step agent on try/except + retry re-runs side effects on restart").

---

### P0 — Blocking (must fix before building)

**[P0] Rule SUP3 (orchestration-patterns): 10-agent fully-connected swarm = n(n−1)/2 = 10·9/2 = 45 distinct interactive failure pathways — exhaustive state-space testing is unfeasible.**
→ Do not ship a fully-connected swarm above ~5 agents. Either (a) switch to a **Supervisor** topology (failure surface drops to O(n) = linear in worker count, SUP1), or (b) constrain the handoff graph so not every agent can hand off to every other. Given this is autonomous research (long-running, must validate intermediate outputs before they propagate), Supervisor is the correct choice — see Framework / Topology Recommendation below.

**[P0] Rule DUR1 + DUR2 (durable-execution): 300-step workflow on a `try/except` retry loop, P(fail) ≈ 95.1%, and the retry RE-RUNS SIDE EFFECTS.** A `try/except` restart re-executes from the top: every web fetch, file write, API call, or email already performed at steps 1–N is repeated. Bare retry loops do not preserve the execution stack and do not deduplicate completed side-effecting steps. Over 60% of production agent incidents trace to exactly this class of state-management failure (Complexity Cliff cross-cutting rule).
→ Decouple the orchestration/state layer from the agent reasoning loop. Wrap every external call (LLM call, web fetch, file/tool exec) as a **Temporal Activity** (DUR2 event-sourcing replay). On crash, another worker replays from the append-only event log; already-completed activities return their cached result **without re-invoking the external API** — a crash at step 299 does NOT re-run steps 1–298. This is the difference between "restart from step 1" (your current design) and "resume from the exact point of failure with zero redundant API calls."

---

### P1 — Required (fix before production)

**[P1] Rule SUP4 (orchestration-patterns): swarm semantic drift compounds after 8–10 sequential agent turns.** A 300-step autonomous research task will vastly exceed 8–10 handoffs. In a pure swarm no single entity holds the global workflow state, so the active agent loses track of the original research objective and drifts into conflicting outputs; routing loops become hard to debug. (determinismLevel: non-deterministic — drift depends on conversation dynamics.)
→ This is a second, independent reason to abandon the pure swarm. If any swarm-like delegation is retained, insert a **re-grounding step** that re-injects the original objective periodically, or escalate to a supervised topology (the recommended path).

**[P1] Rule DUR7 (durable-execution): once you move to Temporal, the LLM client MUST NOT retry independently.** Your current design's defining feature is its retry loop — if that retry instinct survives the migration as client-level retries layered on top of Activity-level retries, you get double-retries → duplicate API calls and duplicate side effects.
→ Set the LLM client to `wrap_openai(AsyncOpenAI(max_retries=0))` (or equivalent) and let the Temporal Activity layer own ALL retry/backoff. (determinismLevel: deterministic.)

**[P1] Rule TP2 + TP4 (tool-permissions): an autonomous 300-step research agent that runs tools needs a permission/audit layer, not unconditional execution.** An autonomous agent firing tool calls in a loop with no gating is an arbitrary-command/side-effect hole (TP2), and with no audit trail there is no tamper-evident record of what 300 steps actually did (TP4).
→ Define an explicit `permissionMode` fallback (not just an allowlist), gate any high-risk side-effecting tools (writes, shell, outbound network) behind a `PreToolUse` check, and register a `PostToolUse` hook to write an audit trail. For a *research* agent the bulk of steps should be read-only (web/search/file-read); confine write/exec to an explicitly allow-listed, audited subset.

---

### P2 — Advisory (improves robustness)

**[P2] Rule DUR3 (durable-execution): if you adopt Temporal, custom tool-calling loops must pass system libs through `workflow.unsafe.imports_passed_through()`** (e.g. `httpx`, `pydantic`) or the sandboxed workflow throws import violations on your HTTP/validation wrappers.

**[P2] Rule DUR5 (durable-execution): if the research agent ever waits on a human** (approval of a finding, mid-run review), use a durable `workflow.wait_condition` zero-cost idle rather than a polling loop or kept-alive container — it persists idle state on the Temporal server and resumes exactly where it left off.

**[P2] Rule TP6 (tool-permissions): set tool-timeout behavior deliberately.** For a research agent, a single slow web fetch should NOT kill a 300-step run — keep the default `error_as_result` (recoverable, run continues) for routeable tools, and reserve `raise_exception` only for a tool whose timeout truly invalidates the whole run.

**[P2] Rule SUP2 (orchestration-patterns): budget for the Supervisor tax.** Moving to Supervisor costs a 20–40% token premium, and a single coordinator's context saturates after 8–12 worker round trips, degrading routing accuracy. At 300 steps you WILL exceed that.
→ Add context-compaction or hierarchical sub-supervisors so one coordinator never accumulates unbounded history across the full 300-step run.

---

### Framework / Topology Recommendation

**Topology: Supervisor, not fully-connected swarm (SUP1, SUP3, SUP5).** Autonomous research is long-running and benefits from a centralized validation gate that intercepts malformed/hallucinated intermediate outputs before they propagate, resolves contradictory worker findings, and enforces re-dispatch limits to prevent infinite loops. A 10-agent fully-connected swarm (45 pathways, drift past 8–10 turns) is the wrong shape for a 300-step workflow that needs quality gating. If most steps are genuinely read-heavy exploration, a swarm-flavored sub-pattern is acceptable ONLY under a supervisor with a bounded handoff graph and periodic re-grounding — never as a flat 10-peer mesh.

**Durability: Temporal event-sourced execution (DUR1, DUR2).** Mandatory at P(fail) ≈ 95%. Wrap every LLM/tool/web call as an Activity so crashes resume from the event log, not step 1. This replaces the `try/except` retry loop entirely. If you instead stay in an application-checkpoint framework, note that LangGraph's `SqliteSaver` locks under parallel writes — production needs `AsyncPostgresSaver` (Anti-Skip table) — but for a 300-step side-effecting research agent, event sourcing (Temporal) is the correct floor, not application-level checkpointing.

**Concrete shape:** Supervisor coordinator (with compaction/sub-supervisors per SUP2) dispatching bounded specialist workers, the whole agent loop wrapped as a Temporal `AgentWorkflow` with each external call as an `Activity` (`max_retries=0` on the client, retries owned by the Activity layer), `permissionMode` + `PreToolUse`/`PostToolUse` gating on side-effecting tools, and `workflow.wait_condition` for any human checkpoint.

**Net:** your three stated design choices — 10-agent fully-connected swarm, 300 sequential steps, try/except retry loop — are each independently a P0/anti-pattern in this pack. Reframe as Supervisor + Temporal event sourcing + gated/audited tools before building.
