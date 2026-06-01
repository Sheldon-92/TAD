# Framework Selection Rules
<!-- capability: framework_selection -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| FS1 | Match the task's state ceiling to the framework's core state model — do not default to popularity | deterministic |
| FS2 | LangGraph for strict determinism + transaction safety; centralized immutable StateGraph | deterministic |
| FS3 | CrewAI for rapid prototyping, role metaphors, and human-revision Flows with checkpoint-fork | deterministic |
| FS4 | AutoGen v0.4+ for decoupled event-driven actors, horizontal/multi-process scale, Python+.NET | deterministic |
| FS5 | OpenAI Agents SDK for sandbox/workspace execution (containerized only with Docker/hosted) + filesystem persistence + hosted OpenAI tools | deterministic |
| FS6 | Claude Agent SDK for local in-process codebase work with system-level Read/Write/Edit/Monitor | deterministic |
| FS7 | Default-persistence trap: never SQLite under heavy parallel writes — locks and stalls | semi-deterministic |

---

## Rules

### FS1: Match the State Model, Not the Hype

When choosing an orchestration framework, select on the workflow's structural needs — state model, concurrency, persistence — not on framework popularity. The five researched frameworks differ at the core:

| Framework | Core State Model | Execution Paradigm | Primary Abstraction | Languages |
|-----------|------------------|--------------------|---------------------|-----------|
| LangGraph | Centralized, immutable state graph; shared state dict | Cyclic graphs + conditional edges | Low-level nodes/edges graph | Python, JS/TS |
| CrewAI | Hierarchical/sequential task state; structured or unstructured | Event-driven Flows over crews + code tasks | High-level role metaphors | Python |
| AutoGen v0.4+ | Event-driven Actor Model; conversational message-passing | Async reactive message exchange | Agents as autonomous communicators | Python, .NET |
| OpenAI Agents SDK | Session-based tracker + sandbox file persistence | Procedural loops + explicit handoffs | Code-first SDK + sandbox | Python 3.10+, JS/TS |
| Claude Agent SDK | Filesystem config state + local runtime processes | In-process loop over CLI binaries | Runtime extension of Claude Code | Python 3.10+, JS/TS |

**Rule**: Write down the workflow's determinism requirement, concurrency shape, and persistence durability FIRST. Then pick. If you cannot state why the chosen framework's state model fits, you are choosing on hype.

> Source: findings.md "Comparative Architecture" table [4,5,6,7,8,9,10,11,12]

**determinismLevel**: deterministic — selection is an architectural decision.

### FS2: LangGraph — Determinism and Transaction Safety

Choose LangGraph when the workflow demands strict determinism, transaction safety, and a highly structured centralized state machine — multi-step enterprise workflows where branching rules must be explicitly validated and cyclic loops tightly controlled.

- The core construct is a `StateGraph` initialized with a `TypedDict` schema; all nodes read/modify a shared state object.
- Nodes are plain Python functions; edges are direct sequences or conditional branches.
- The trade-off is rigid structure in exchange for absolute determinism.
- LangGraph is a stable ecosystem. Note the package split: `langgraph` is the framework (the 1.x release line) and `langgraph-sdk` is the separate API-client package (`langgraph-sdk==0.3.15` released **2026-05-22**) — do not treat the SDK client version as the framework version.

> Source: findings.md "LangGraph (by LangChain Inc.)" [4,5,17]; PyPI langgraph / langgraph-sdk (retrieved 2026-06-01)

**determinismLevel**: deterministic.

### FS3: CrewAI — Prototyping + Human-Revision Flows

Choose CrewAI for rapid prototyping, human-centric role metaphors (Researchers, Writers), document/creative generation, and systems needing dynamic human revision loops.

- Flows coordinate multiple crews and raw code tasks; state lives in the `state` attribute (unstructured) or a Pydantic `BaseModel` (structured).
- Default persistence: `SQLiteFlowPersistence` auto-records state and generates a preserved UUID per execution.
- Distinctive feature: the checkpoint-fork CLI (see DUR/checkpoint rules) and `@human_feedback` revision loops.

> Source: findings.md "CrewAI (Flows & Crews)" [6,14,20]

**determinismLevel**: deterministic.

### FS4: AutoGen v0.4+ — Decoupled Event-Driven Actors

Choose AutoGen v0.4+ for highly decoupled, event-driven multi-agent systems that scale horizontally across processes or need cross-language interoperability (Python and .NET).

- v0.4 is a full redesign onto an Actor Model: agents are independent actors communicating only via async message passing, decoupling delivery from computation.
- AgentChat API gives declarative serializability — serialize an entire team (e.g. `RoundRobinGroupChat`) and `FunctionTools` to JSON; persist live state with `save_state` / `load_state` to pause, hot-swap team composition, and resume.
- AutoGen Studio adds real-time updates, mid-execution control (pause, redirect, alter prompts), and message-flow visualization.

> Source: findings.md "AutoGen (v0.4+)" [7,11,15]

**determinismLevel**: deterministic.

### FS5: OpenAI Agents SDK — Sandbox + Filesystem Persistence

Choose the OpenAI Agents SDK when agents need sandboxed workspaces (Unix-local, Docker, or hosted backend), deep filesystem access, and direct integration with hosted OpenAI tools — autonomous workspace assistants, automated code patchers, developer tools.

- The Agents SDK in general is provider-flexible (OpenAI models plus 100+ others via LiteLLM), but the **Sandbox Agent specifically targets OpenAI models via the Responses API** — do not assume sandbox-agent parity for non-OpenAI providers.
- Core capability is the **Sandbox Agent**, first introduced in **version 0.14.0**: pairs the model with a managed file workspace + sandbox client (Unix-local, Docker, or a hosted provider such as E2B/Cloudflare) to inspect files, run shell commands, and persist filesystem state over long horizons. It is containerized only when using the Docker or a hosted-container backend — Unix-local is workspace isolation, not a container.
- Tool schemas are built by parsing function signatures with Python `inspect` (dynamic Pydantic models); docstrings parsed via `griffe` (Google/Sphinx/NumPy formats).

> Source: findings.md "OpenAI Agents SDK" [1,8,9,21]

**determinismLevel**: deterministic.

### FS6: Claude Agent SDK — Local In-Process System Work

Choose the Claude Agent SDK for local, in-process codebase analysis, refactoring, and security auditing. It runs the same agent loop, tool engine, and context management as the Claude Code CLI, executing in-process on the developer's infrastructure.

- Built-in toolset: `Read`, `Write`, `Edit`, `Bash`, `Monitor` (watches a background script, reacts per output line), `Glob`, `Grep`, `WebSearch`, `WebFetch`, `AskUserQuestion`.
- Distinctive for secure local developer agents with native system-level access — no cloud-managed platform.

> Source: findings.md "Claude Agent SDK" [10,12,16,19]

**determinismLevel**: deterministic.

### FS7: The SQLite-Under-Parallel-Writes Trap

When configuring default persistence, do NOT rely on file-based SQLite under heavy parallel write loads.

- LangGraph's `SqliteSaver` (and `InMemorySaver`) are fine for local prototyping, but production workloads require `AsyncPostgresSaver`. Heavy parallel writes against SQLite lock database connections and stall execution.
- CrewAI similarly offers a human-readable `JsonProvider` (writes `<timestamp>_<uuid>.json`) vs a multi-write-optimized `SqliteProvider` — pick the SQLite provider only when write contention is low.

**Rule**: If the workflow has concurrent node/task writes, choose Postgres/Redis (LangGraph) or an event-sourced layer (Temporal) over file-SQLite checkpointing.

> Source: findings.md "LangGraph" [4,13], "CrewAI Checkpointing" [14]

**determinismLevel**: semi-deterministic — the lock manifests under runtime concurrency.

---

## Anti-Patterns

- **Popularity-driven selection**: picking LangGraph for a loosely-coupled conversational workload, or AutoGen for a workflow that needs strict deterministic branching.
- **Ignoring language constraints**: AutoGen is the only researched framework with .NET; CrewAI is Python-only. Do not promise cross-language on a Python-only stack.
- **SQLite in production**: file-SQLite checkpointing under parallel writes is a known stall.
- **One framework for everything**: sandbox/filesystem work → OpenAI Agents SDK; local system work → Claude Agent SDK; deterministic state machine → LangGraph. They are not interchangeable.
