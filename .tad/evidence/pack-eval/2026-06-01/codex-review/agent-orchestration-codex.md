[P0] “LangGraph | `pip install langgraph` (`sdk==0.3.15`, 2026-05-22)”
Why wrong: `langgraph` current release is `1.2.x`; `langgraph==0.3.15` was Mar 18, 2025. The May 22, 2026 `0.3.15` version is `langgraph-sdk`, a different package. PyPI: https://pypi.org/project/langgraph/ and https://pypi.org/project/langgraph-sdk/
Fix: Split `langgraph` and `langgraph-sdk`; do not present `sdk==0.3.15` as the LangGraph install/version.

[P0] “LangGraph is a stable ecosystem: `sdk==0.3.15` released **2026-05-22**.”
Why wrong: Same package confusion. This line claims a LangGraph framework version but cites the SDK client package.
Fix: Say “`langgraph-sdk==0.3.15` was released May 22, 2026; `langgraph` itself is separately versioned.”

[P0] “configure the `SandboxAgent`'s `RunConfig` with `client=temporal_sandbox_client(self._backend.value)`”
Why wrong: Current OpenAI sandbox docs use `RunConfig(sandbox=SandboxRunConfig(client=...))`; Temporal sandbox support is via `OpenAIAgentsPlugin(sandbox_clients=...)`, not a documented `temporal_sandbox_client(...)` helper. Docs: https://openai.github.io/openai-agents-python/sandbox/clients/ and Temporal release notes: https://github.com/temporalio/sdk-python/releases
Fix: Replace with the documented `SandboxRunConfig(client=...)` plus Temporal `OpenAIAgentsPlugin(sandbox_clients=[...])` pattern.

[P0] “Any external library used inside a Temporal `Workflow` (HTTP clients, validators) must be imported via `workflow.unsafe.imports_passed_through()`.”
Why wrong: Temporal workflows must be deterministic and must not do network I/O; HTTP clients belong in Activities, not inside Workflow code. `imports_passed_through()` is for deterministic, side-effect-free modules or activity/type imports. Temporal docs: https://github.com/temporalio/sdk-python#workflow-sandbox
Fix: Say “Pass through deterministic third-party imports such as Pydantic models/activity definitions; put HTTP/network/file/DB calls in Activities.”

[P0] “The reviewer chooses one of four built-in decision types: `approve` / `edit` / `reject` / `respond`”
Why wrong: LangChain Python `HumanInTheLoopMiddleware` documents three built-in decisions: `approve`, `edit`, `reject`; `respond` appears in frontend/JS-style HITL docs, not as a universal Python middleware API. Docs: https://docs.langchain.com/oss/python/langchain/human-in-the-loop
Fix: Scope this by API surface: Python middleware = three decisions; frontend/JS review cards may support `respond`.

[P0] “`reject` | Execution is blocked; the reviewer's feedback is appended to message history as a system message”
Why wrong: LangChain docs say rejected calls synthesize tool messages / add rejection feedback to the conversation, not a system message. Treating it as system-level instruction overstates authority and can break implementation assumptions.
Fix: Replace “system message” with “tool/rejection message visible to the agent.”

[P0] “Use a restrictive mode like `'acceptEdits'` (auto-approve file edits, prompt for shell)”
Why wrong: Claude docs explicitly say locked-down agents should pair `allowedTools` with `permissionMode: "dontAsk"`; `acceptEdits` auto-approves file edits and filesystem operations including `rm`/`mv`, so it is not restrictive for write-capable agents. Docs: https://code.claude.com/docs/en/agent-sdk/permissions
Fix: Recommend `dontAsk` for allowlist-as-boundary; use `acceptEdits` only when filesystem mutation is intentionally trusted.

[P0] “any tool not on the allowlist falls through to whatever the default mode permits — potentially auto-running arbitrary commands”
Why wrong: Claude’s default mode does not auto-run arbitrary unmatched commands; unmatched tools trigger `canUseTool`/approval behavior. The real risk is using permissive modes like `bypassPermissions` or `acceptEdits`, not the mere absence of an explicit mode.
Fix: State the actual evaluation behavior and require explicit `permissionMode` to avoid accidental permissive defaults/config drift.

[P1] “Over 60% of production agent incidents trace to state-management failures”
Why wrong: Suspicious specific number with no primary citation in the pack body. It reads like invented quantitative authority.
Fix: Either cite the exact study/dataset and definition of “incident,” or remove the percentage.

[P1] “Cumulative agent reliability is `P(fail) = 1 - (1 - p)^s`”
Why wrong: Missing the critical assumption: independent, identical per-step failure probability. Agent failures are often correlated by bad state, bad prompt, bad tool schema, or upstream outage.
Fix: Add “under an iid per-step approximation”; warn that correlated failures can make this an underestimate.

[P1] “A fully-connected peer-to-peer swarm's failure surface scales quadratically, O(n²): `n(n - 1) / 2`”
Why wrong: Handoffs are directional in most agent systems. A fully connected directed handoff graph has `n(n-1)` directed edges, not `n(n-1)/2`, unless the pack explicitly models undirected pair relationships.
Fix: Use `n(n-1)` for directed handoff transitions, or say the formula counts undirected agent pairs only.

[P1] “10 agents → **45** distinct interactive states”
Why wrong: `45` is an undirected edge count, not “distinct interactive states.” States include active agent, conversation state, tool state, and history, so this under-describes the actual state space.
Fix: Rename to “45 undirected pairwise handoff relationships” or compute a real state-space model.

[P1] “Core capability is the **Sandbox Agent**… Provider-agnostic: works across OpenAI models and 100+ other LLMs.”
Why wrong: SandboxAgent docs say it is only usable with OpenAI models via the Responses API; non-OpenAI model support through LiteLLM does not imply sandbox-agent parity. Docs: https://openai.github.io/openai-agents-python/ref/sandbox/sandbox_agent/
Fix: Separate general Agents SDK model-provider support from SandboxAgent constraints.

[P1] “OpenAI Agents SDK | … Containerized sandbox”
Why wrong: OpenAI sandbox agents are not inherently containerized. Supported clients include Unix-local, Docker, and hosted providers; Unix-local is not container isolation. Docs: https://openai.github.io/openai-agents-python/sandbox/clients/
Fix: Say “sandbox/workspace execution; containerized only when using Docker or a hosted container backend.”

[P1] “An agent that writes files with no `PostToolUse` audit hook has no tamper-evident record.”
Why wrong: A `PostToolUse` hook writing `./audit.log` is not tamper-evident; the same agent/process may be able to edit or delete it.
Fix: Say “no audit record,” or require append-only external logging, signatures, or write-once storage for tamper evidence.

[P1] “`max_retries=0` is a **required** design pattern here”
Why wrong: Too absolute. Disabling client retries can be correct when Temporal owns retries, but the real requirement is idempotency and a single retry owner for non-idempotent operations. LLM calls may duplicate cost/latency, while side-effecting Activities need idempotency keys.
Fix: Rephrase to “Prefer one retry layer; set client retries to zero when Activity retry policy is authoritative, and make side effects idempotent.”

VERDICT: FIX-FIRST
