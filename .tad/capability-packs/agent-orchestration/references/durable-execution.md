# Durable Execution Rules (Temporal + Checkpointing)
<!-- capability: durable_execution -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| DUR1 | Above the complexity cliff (compute P(fail); materially high by the low tens of steps at p=0.01), event sourcing beats application-level checkpointing | deterministic |
| DUR2 | Temporal replay: wrap every external call as an Activity; crashes resume from the event log, not step 1 | deterministic |
| DUR3 | Temporal: do network/IO in Activities; only pass DETERMINISTIC imports through `workflow.unsafe.imports_passed_through()` | deterministic |
| DUR4 | OpenAI Agents SDK + Temporal: `SandboxRunConfig(client=temporal_sandbox_client(...))` + `OpenAIAgentsPlugin(sandbox_clients=[...])` + `activity_as_tool` | deterministic |
| DUR5 | Zero-cost idle: `workflow.wait_condition` consumes zero compute while awaiting human input | semi-deterministic |
| DUR6 | CrewAI checkpoint cadence: default `task_completed`; high-frequency triggers degrade perf + disk I/O | semi-deterministic |
| DUR7 | Observability: with Temporal set `wrap_openai(AsyncOpenAI(max_retries=0))` — delegate retries to the Activity layer | deterministic |

---

## Rules

### DUR1: Above the Cliff, Use Event Sourcing — Not Bare Checkpoints

Standard checkpointing and retry scripts are limited: they require manual integration, do not preserve thread execution stacks, and cannot safely manage complex distributed state transitions. As multi-agent workflows extend to hundreds of steps, infrastructure failure becomes a statistical certainty (see the Complexity Cliff cross-cutting rule: P(fail) = 1 - (1-p)^s; 63.4% at 100 steps, 99.3% at 500 steps).

**Rule**: When an agent must run for long periods, coordinate dozens of APIs, and manage critical external state transitions, decouple the orchestration/state layer from the volatile agent reasoning loop. Offload state tracking and crash recovery to a durable, event-sourced engine (Temporal). Don't wait for "hundreds of steps" — compute `P(fail)` for your own `s` and `p`: at `p=0.01` failure is already ~40% by ~50 steps (`1 - 0.99^50 ≈ 0.395`), so a workflow of a few tens of steps and up is already a durability candidate.

> Source: findings.md "Durable Execution and Temporal Integration" [2,3,29], "Complexity Cliff" [2,4] (formula + 63.4%@100 / 99.3%@500). The ~40%@50-steps figure and the "few tens of steps" durability trigger are DERIVED from the same `1 - (1-p)^s` model / authored heuristics — research reports "hundreds of steps", not a 50-step threshold.

**determinismLevel**: deterministic — the failure *figures* are driven by the closed-form model; the specific step count at which you mandate durability is an authored heuristic over your own `p`.

### DUR2: The Event-Sourcing Replay Model

Temporal replaces application-level checkpointing with event sourcing:

- Developer code is a standard procedural program inside a `Workflow`; every external interaction (LLM call, filesystem tool exec) is wrapped as a Temporal `Activity`.
- The Temporal Service logs every activity completion to an append-only event history.
- On worker crash, another worker picks up and **replays the workflow from the beginning** — but when it reaches an already-completed activity, Temporal returns the cached result from the event log **without re-executing the code or re-invoking the external API**.
- Result: the execution stack and local variables are reconstructed, and the agent resumes from the exact point of failure with **zero state loss and zero redundant API calls**.

**Rule**: This is why event sourcing is safe above the cliff — a crash at step 499 does NOT re-send the emails sent at steps 1-498. Bare retry loops re-run side effects.

> Source: findings.md "The Event Sourcing Replay Model" [2,29,30]

**determinismLevel**: deterministic.

### DUR3: Temporal Workflows Are Deterministic — Network/IO Goes in Activities, Not Pass-Through Imports

Temporal `Workflow` code must be deterministic and must NOT perform network/file/DB I/O. All HTTP calls, LLM calls, and other side effects belong in **Activities**, not in the workflow body. `workflow.unsafe.imports_passed_through()` is for importing **deterministic, side-effect-free** modules whose import-time code the sandbox would otherwise re-validate (e.g. Pydantic models, type/dataclass definitions, activity definitions) — it is NOT a license to run an HTTP client inside the workflow:

```python
from temporalio import workflow

with workflow.unsafe.imports_passed_through():
    import pydantic            # deterministic model/type definitions — OK to pass through
    from .activities import call_api   # activity definition import — OK
# An HTTP client (httpx/requests) is USED inside an Activity, not the Workflow.
```

**Rule**: Pass through deterministic third-party imports (Pydantic models, type/activity definitions). Put HTTP/network/file/DB calls in Activities — never perform I/O directly in workflow code, even if the import is passed through.

> Source: findings.md "Event Sourcing Replay Model" code block [30]; Temporal Python SDK workflow-sandbox / determinism docs (retrieved 2026-06-01)

**determinismLevel**: deterministic.

### DUR4: OpenAI Agents SDK + Temporal Wiring

To make the OpenAI Agents SDK durable, use Temporal's native integration:

- Establish the connection by setting the sandbox client in `SandboxRunConfig`: `SandboxRunConfig(client=temporal_sandbox_client(self._backend.value))` (the sandbox client lives in `SandboxRunConfig`, not the generic `RunConfig`). This wraps all core sandbox operations (LLM API calls, shell commands, file ops, sandbox lifecycle) as **Temporal activities** — fully durable and retryable, with no change to agent logic.
- Register the backends with `OpenAIAgentsPlugin(sandbox_clients=[SandboxClientProvider(...)])` on the Temporal Client (one provider per backend: local/docker/daytona/e2b), and use the `activity_as_tool` helper, which auto-generates OpenAI-compatible tool schemas from Temporal activity signatures and provides them to the `Agent`.
- Three architectural components: **AgentWorkflow** (long-lived durable workflow wrapping the agent), **SessionManagerWorkflow** (durably orchestrates session start/stop/list/rename/fork instead of a DB-backed server), and a **TUI** that talks to the workflows via Temporal signals/queries/updates.

> Source: findings.md "OpenAI Agents SDK Temporal Integration" [18,32]; OpenAI Agents SDK sandbox-clients docs + Temporal `temporalio.contrib.openai_agents` (retrieved 2026-06-01)

**determinismLevel**: deterministic.

### DUR5: Zero-Cost Idle for Human Waits

Inside the `AgentWorkflow`, halt computation while awaiting human input with `workflow.wait_condition`:

```python
await workflow.wait_condition(
    lambda: (len(self._pending_messages) > 0 or self._pause_requested or self._done),
)
```

- While there are no pending messages, the workflow is idle and consumes **zero compute resources** — the idle state is persisted on the Temporal server, not in a running process or live sandbox container.
- It can stay idle for seconds, days, or weeks; if the worker restarts during idle, it resumes exactly where it left off without losing context, rebuilding the workspace, or rerunning setup.
- This lets platforms scale to **thousands of concurrent sessions without paying for thousands of idle sandboxes**.

**Rule**: For long human-wait gaps (approval queues, multi-day reviews), use a durable wait-condition idle, not a polling loop or a kept-alive container.

> Source: findings.md "Zero-Cost Idle Mechanics" [18]

**determinismLevel**: semi-deterministic — idle duration depends on human response time.

### DUR6: CrewAI Checkpoint Cadence Trade-off

CrewAI's `Crew` checkpointing is event-driven via `on_events`. By default the system writes a checkpoint on a `task_completed` event.

- You can pick a fine-grained trigger (`llm_call_completed`) or a wildcard `["*"]`, but **high-frequency writing degrades execution performance and increases disk I/O latency**.
- Checkpoints write via the human-readable `JsonProvider` (`<timestamp>_<uuid>.json` files) or the multi-write-optimized `SqliteProvider`.
- CrewAI CLI: `crewai checkpoint` (interactive TUI, auto-detected storage), `crewai checkpoint --location <path>`, `crewai checkpoint list <path>`, `crewai checkpoint info <path>`.
- Editing a completed task output and triggering a **fork** restores the checkpoint under a fresh lineage ID, auto-invalidates all downstream dependent tasks, and forces them to re-run against the modified state.

**Rule**: Default to `task_completed` checkpoint cadence; only go finer (`llm_call_completed` / `["*"]`) when recovery granularity justifies the I/O cost. Use `SqliteProvider` for write-heavy runs.

> Source: findings.md "CrewAI (Flows & Crews)" checkpointing [6,14]

**determinismLevel**: semi-deterministic — I/O degradation depends on write frequency at runtime.

### DUR7: Delegate Retries to the Activity Layer (max_retries=0)

When wrapping LLM calls under Temporal for observability (e.g. Braintrust tracing), set the LLM client to do no retries of its own:

```python
from braintrust import wrap_openai
from openai import AsyncOpenAI

client = wrap_openai(AsyncOpenAI(max_retries=0))
```

- `max_retries=0` is a **required** design pattern here: it delegates all retries and backoff to the Temporal Activity layer, preventing duplicate execution attempts at the LLM client level.
- Every Temporal Workflow run becomes a root trace span; individual activities map to child spans with token counts, latency, and dynamically-loaded prompt versions.

**Rule**: With durable execution, the client must NOT retry independently — double-retry causes duplicate side effects. Let the Activity layer own retry/backoff.

> Source: findings.md "Production Observability with Braintrust" [33]

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **Bare retry loop above the cliff**: a 300-step agent on `try/except + retry` re-runs side effects (emails, DB writes) on restart. Use event sourcing.
- **I/O inside a workflow**: running an HTTP client / DB call directly in workflow code (even with the import passed through) breaks determinism — move it to an Activity.
- **Forgetting import pass-through**: deterministic libs imported normally inside a Temporal Workflow throw sandbox import violations — pass them through.
- **Double retries**: client-level `max_retries > 0` plus Activity-level retry = duplicate API calls and duplicate side effects.
- **Keeping containers alive for human waits**: paying for thousands of idle sandboxes instead of using `workflow.wait_condition` zero-cost idle.
- **Checkpointing on every event**: wildcard `["*"]` cadence degrades performance with disk I/O.
