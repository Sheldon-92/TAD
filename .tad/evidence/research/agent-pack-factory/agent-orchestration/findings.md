# Research Findings: agent-orchestration
Notebook: 652134d1-d09f-4d3c-881f-b4b86ec4058b | Deep research: 38 sources | Report: 43256 chars | Date: 2026-05-31
Method: NotebookLM deep research. Report below = cited synthesis; [N] maps to Source List. Build agent MUST preserve provenance.

## Source List ([N] in report refers to these)
1. State-Machine Orchestration, Event-Driven Actor Models, and Durable Execution in Multi-Agent AI Architectures — 
2. Building AI agents that overcome the complexity cliff | Temporal — https://temporal.io/blog/building-ai-agents-that-overcome-the-complexity-cliff
3. What Is LangGraph? State, Agents & Production Use Cases 2026 - Atlan — https://atlan.com/know/ai-agent/ai-agent-memory/what-is-langgraph/
4. Human-in-the-loop - Docs by LangChain — https://docs.langchain.com/oss/python/langchain/human-in-the-loop
5. Flows - CrewAI — https://docs.crewai.com/en/concepts/flows
6. Agents SDK | OpenAI API — https://developers.openai.com/api/docs/guides/agents
7. LangGraph vs AutoGen State Tracking: Checkpoint Mechanisms, Timeout Recovery, and Framework Selection — https://eastondev.com/blog/en/posts/ai/20260526-langgraph-autogen-state-tracking-en/
8. Checkpointing - CrewAI — https://docs.crewai.com/en/concepts/checkpointing
9. AutoGen v0.4: Reimagining the foundation of agentic AI for scale, extensibility, and robustness - Microsoft Research — https://www.microsoft.com/en-us/research/blog/autogen-v0-4-reimagining-the-foundation-of-agentic-ai-for-scale-extensibility-and-robustness/
10. Introducing Temporal and agentic sandboxes: The OpenAI agents ... — https://temporal.io/blog/introducing-temporal-and-agentic-sandboxes-openai-agents-sdk
11. Durable Agent with Tools - OpenAI Agents SDK - Temporal Docs — https://docs.temporal.io/ai-cookbook/openai-agents-sdk-python
12. Agent SDK overview - Claude Code Docs — https://code.claude.com/docs/en/agent-sdk/overview
13. Swarm vs. Supervisor: Multi-Agent Architecture Guide | Augment Code — https://www.augmentcode.com/guides/swarm-vs-supervisor
14. openai/openai-agents-python: A lightweight, powerful framework for multi-agent workflows - GitHub — https://github.com/openai/openai-agents-python
15. Multi-Agent Orchestration: 5 Patterns That Work - Digital Applied — https://www.digitalapplied.com/blog/multi-agent-orchestration-5-patterns-that-work
16. Making it easier to build human-in-the-loop agents with interrupt - LangChain — https://www.langchain.com/blog/making-it-easier-to-build-human-in-the-loop-agents-with-interrupt
17. OpenAI Agents SDK (JavaScript/TypeScript) - GitHub — https://github.com/openai/openai-agents-js
18. Human Feedback in Flows - CrewAI Documentation — https://docs.crewai.com/en/learn/human-feedback-in-flows
19. Durable AI agent with Gemini and Temporal | Gemini API - Google AI for Developers — https://ai.google.dev/gemini-api/docs/temporal-example
20. anthropics/claude-agent-sdk-python - GitHub — https://github.com/anthropics/claude-agent-sdk-python
21. Tools - OpenAI Agents SDK — https://openai.github.io/openai-agents-python/tools/
22. Durable AI Agents Bundle - Temporal — https://temporal.io/pages/durable-ai-agent-bundle
23. Temporal: Durable Execution Solutions — https://temporal.io/
24. Built a durable AI agent orchestration layer on Temporal — sharing patterns - Reddit — https://www.reddit.com/r/Temporal/comments/1swatro/built_a_durable_ai_agent_orchestration_layer_on/
25. Building AI agents with the Claude Agent SDK - GitHub Gist — https://gist.github.com/dabit3/93a5afe8171753d0dbfd41c80033171d
26. Building Human-In-The-Loop Agentic Workflows | Towards Data Science — https://towardsdatascience.com/building-human-in-the-loop-agentic-workflows/
27. anthropics/claude-agent-sdk-typescript - GitHub — https://github.com/anthropics/claude-agent-sdk-typescript
28. AutoGen v0.4: Reimagining the foundation of agentic AI for scale, extensibility, and robustness - Microsoft Research — https://www.microsoft.com/en-us/research/articles/autogen-v0-4-reimagining-the-foundation-of-agentic-ai-for-scale-extensibility-and-robustness/
29. Swarm — AutoGen - Microsoft Open Source — https://microsoft.github.io/autogen/dev//user-guide/agentchat-user-guide/swarm.html
30. Handoffs — AutoGen - Microsoft Open Source — https://microsoft.github.io/autogen/dev//user-guide/core-user-guide/design-patterns/handoffs.html
31. AutoGen v0.4.4 released : r/AutoGenAI - Reddit — https://www.reddit.com/r/AutoGenAI/comments/1icubxj/autogen_v044_released/
32. Flow HITL Management - CrewAI Documentation — https://docs.crewai.com/en/enterprise/features/flow-hitl-management
33. Best Open-Source AI Agent Stack Tools in 2026 | Data Science Collective - Medium — https://medium.com/data-science-collective/the-open-source-agent-toolkit-in-2026-da66dda36c9b
34. Building observable AI agents with Temporal - Blog - Braintrust — https://www.braintrust.dev/blog/temporal-braintrust-integration
35. Announcing the OpenAI Agents SDK + Temporal Integration - YouTube — https://www.youtube.com/watch?v=fwh21RV6bRo
36. Building Agents with OpenAI SDK, Published by Packt · GitHub — https://github.com/PacktPublishing/Building-Agents-with-OpenAI-Agents-SDK
37. Anthropic Claude - GitHub Docs — https://docs.github.com/en/copilot/concepts/agents/anthropic-claude
38. Multi-Agent AI Patterns for Developers: Pick the Right Pattern for the Right Problem | by Suman Das | Apr, 2026 — https://dassum.medium.com/multi-agent-ai-patterns-for-developers-pick-the-right-pattern-for-the-right-problem-8f03ef476b45

## Deep Research Report

# State-Machine Orchestration, Event-Driven Actor Models, and Durable Execution in Multi-Agent AI Architectures

## The Agentic Infrastructure Landscape and the Complexity Cliff

The implementation of artificial intelligence within enterprise software architectures is undergoing a structural transition. Single-turn interfaces and stateless pipeline chains are being replaced by autonomous, stateful multi-agent systems designed to perform complex, multi-step operations over extended time horizons.[1, 2] This shift reveals critical limitations in traditional software engineering patterns. In a production environment, AI agents act as distributed systems, executing non-deterministic loops, invoking external application programming interfaces (APIs), managing filesystem states, and collaborating with other specialized agents.[3] 

As these workflows grow in duration, step count, and tool variety, they encounter what infrastructure engineers term the "complexity cliff".[2] Traditional software stacks struggle to manage the state of an agent that may run for hours, interact with dozens of tools, and handle unexpected network partitions, rate limits, or process crashes.[2, 3] Data from production environments indicates that over 60% of production agent incidents trace back directly to state management failures, including agents losing context mid-workflow, repeating expensive steps unnecessarily, or crashing without a recovery path.[4]

### The Exponential Failure Mechanics of Non-Deterministic Workflows
Unlike traditional, deterministic software programs where the failure rate is largely constant, the cumulative reliability of an autonomous agentic workflow degrades exponentially as a function of time and execution steps.[2] If the probability of any single tool execution, network request, or model call failing is represented as $p$, and the agent must perform $s$ discrete steps to resolve a given task, the overall probability of system failure, denoted as $P(\text{fail})$, is modeled as:

$$P(\text{fail}) = 1 - (1 - p)^s$$

In production deployments, the value of an agent increases superlinearly with the number of steps it can perform.[2] However, if an agent executes $100$ sequential tool and model interactions with a step success rate of $99\%$ ($p = 0.01$), the cumulative probability of failure is $63.4\%$ ($P(\text{fail}) = 1 - (0.99)^{100} \approx 0.634$).[2] When the execution path scales to $500$ steps (as seen in deep research or codebase refactoring tasks), the probability of system failure climbs to $99.3\%$ ($P(\text{fail}) = 1 - (0.99)^{500} \approx 0.993$).[2]

Under standard stateless execution models, a single infrastructure failure at step $499$ forces a complete restart from step $1$.[2] This is prohibitively expensive in terms of token costs and API latencies, and dangerous if steps $1$ through $498$ executed external side effects like sending client emails or modifying database records.[2] To prevent catastrophic failures, the orchestration layer must provide robust state tracking, fault-tolerant checkpointing, and structured human-in-the-loop interfaces.[4, 5]

---

## Comparative Architecture of State Management and Orchestration Engines

Modern agent orchestration frameworks differ in their core state models, concurrency handling, and system abstractions.[4, 5] Selecting an infrastructure stack requires matching the task complexity with the framework's structural ceiling.[5] High-overhead, deterministic state machines are structurally distinct from lightweight, conversational protocols.[5]

| Operational Parameter | LangGraph | CrewAI (Flows & Crews) | AutoGen (v0.4+) | OpenAI Agents SDK | Claude Agent SDK |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Core State Model** | Centralized, immutable state graph with shared state dictionaries.[4] | Hierarchical and sequential task state, with unstructured or structured state definitions.[6] | Event-driven Actor Model; decoupled, conversational message-passing state.[5, 7] | Session-based state tracker with sandbox environment file persistence.[8, 9] | Filesystem-based configuration state coupled with local runtime processes.[10] |
| **Execution Paradigm** | Cyclic graphs with conditional branching logic and direct execution edges.[4] | Event-driven flows coordinating multiple crews and code tasks.[6] | Asynchronous, reactive message exchanges across an open-ended actor pool.[7, 11] | Procedural agent execution loops with explicit handoff mechanics.[8, 9] | In-process execution loop backed directly by system-level CLI binaries.[10, 12] |
| **Default Persistence** | Postgres or Redis checkpointers for transaction-level recovery.[4, 13] | SQLite-based persistence with customizable JSON file serialization.[6, 14] | File-based state serialization and client-server session persistence.[5, 15] | Automatic conversation history sessions with optional Redis storage backing.[8] | Local system config directories with session-level checkpointing features.[10, 16] |
| **Concurrency Model** | Node-level execution locks and thread-isolated execution runs.[13, 17] | Serialized crew tasks with concurrent task executions inside flow routers.[6] | Full asynchronous event loops with multi-process and cross-language capabilities.[7, 11] | Sequential execution turns within a unified runtime context.[1, 18] | Asynchronous iterator streams executing within single-process contexts.[10, 12] |
| **Programming Languages** | Python, JavaScript / TypeScript.[4] | Python.[6] | Python,.NET.[11] | Python (3.10+), JavaScript / TypeScript.[8, 9] | Python (3.10+), JavaScript / TypeScript.[10, 12, 19] |
| **Primary Abstraction** | Lower-level system graph constructing explicit nodes and edges.[4, 17] | High-level role metaphors (Researchers, Writers) mapping to tasks.[20] | Conversational programming utilizing agents as autonomous communicators.[5] | Code-first, lightweight SDK with integrated sandbox environments.[1, 8] | Runtime extension of Claude Code with system-level command capabilities.[10, 16] |

---

## Technical Deep Dive into Individual Frameworks

### LangGraph (by LangChain Inc.)
LangGraph is a low-level orchestration framework designed to address the state management vulnerabilities that plague high-frequency production systems.[4] The central concept of the framework is the `StateGraph`, initialized with a `TypedDict` schema representing a shared state object that all graph nodes can read and modify.[4] Nodes are represented as standard Python functions executing discrete tasks, and edges define the routing rules—either direct sequences or conditional branches.[4]

```
LangGraph Deterministic State Machine Flow:
   ===> [Node A: call_llm] ===>
                                                    ||
                                           [Conditional Edge]
                                           /                \
                            
```

The primary engineering trade-off in LangGraph is its rigid structure in exchange for absolute determinism and transaction safety.[4, 5] To maintain persistence across interruptions, the runtime requires a checkpointer.[4] For local prototyping, an `InMemorySaver` is sufficient, but production workloads require an `AsyncPostgresSaver`.[4, 13] 

Relying on file-based SQLite engines (`SqliteSaver`) under heavy parallel write loads represents a performance trap, resulting in locked database connections and execution stalls.[4] LangGraph represents a highly stable ecosystem (e.g., `sdk==0.3.15` released on May 22, 2026) that serves as the execution engine for modern LangChain components.[4]

### CrewAI (Flows & Crews)
CrewAI prioritizes rapid prototyping and minimal setup overhead, wrapping agent definitions in high-level role metaphors.[20] With the introduction of CrewAI Flows, developers can construct structured, event-driven workflows that coordinate multiple crews and raw code tasks.[6] State management in Flows can be unstructured, storing attributes dynamically in the `state` attribute of the `Flow` class, or structured by defining a Pydantic `BaseModel` schema.[6, 14]

```
CrewAI Event-Driven Flow:
   ===> ===>
                                                                  ||
                                                      [task_completed Event]
                                                                  ||
   <=== <===
```

The framework implements default persistence through `SQLiteFlowPersistence`, which automatically records state updates to a local database, generating a unique, preserved UUID for each execution instance.[6] This is separate from the execution checkpointing layer used in `Crew` runs, which relies on event-driven triggers configured via `on_events`.[14] By default, the system writes a checkpoint to disk upon a `task_completed` event.[14] 

While developers can choose a fine-grained trigger like `llm_call_completed` or wildcard `["*"]` events, high-frequency writing degrades execution performance and increases disk I/O latency.[14] Checkpoints are written via the human-readable `JsonProvider` (saving `<timestamp>_<uuid>.json` files) or the multi-write-optimized `SqliteProvider`.[14] 

The CrewAI CLI provides commands to manage these runs [14]:
* `crewai checkpoint`: Launches an interactive terminal user interface (TUI) with auto-detected storage.[14]
* `crewai checkpoint --location <path>`: Targets a specific SQLite database or file path.[14]
* `crewai checkpoint list <path>`: Displays all available checkpoints without opening the interactive UI.[14]
* `crewai checkpoint info <path>`: Inspects metadata of a specific checkpoint run.[14]

Inside the TUI, developers can view a visual checkpoint tree showing execution branches and forks.[14] In the detail panel, the inputs and intermediate task outputs are exposed.[14] If a developer edits a completed task output and triggers a `fork`, the engine restores the checkpoint under a fresh lineage ID, automatically invalidates all downstream dependent tasks, and forces them to re-run against the newly modified state.[14]

### AutoGen (v0.4+)
The v0.4 release of AutoGen represents a complete architectural redesign, adopting an Actor Model to resolve previous limitations in observability, multi-process scaling, and API rigidity.[7, 11] In this event-driven architecture, agents are independent actors communicating exclusively via asynchronous message passing.[7, 11] This decoupling of message delivery from computation allows agents to execute on separate processes, scale horizontally, and be implemented across different programming languages, currently supporting Python and.NET.[7, 11]

```
AutoGen Actor Model Topology:
   [Agent Actor A] ---- Asynchronous Message ---->
         ||                                              ||
                                    
```

At the highest level sits the AgentChat API, providing declarative serializability.[7, 15] Developers can serialize entire agent team configurations (e.g., a `RoundRobinGroupChat`) and individual `FunctionTools` into standard JSON strings.[15] Concurrently, the live execution state of the team is persisted using the `save_state` and `load_state` APIs.[15] This allows engineers to manage persistent sessions across server-client boundaries, pause active runs, hot-swap team compositions, and resume execution dynamically.[11, 15] 

This capabilities layer is exposed visually in AutoGen Studio, which provides real-time agent execution updates, mid-execution control (pause, redirect actions, alter prompts), and interactive message flow visualizations mapping message paths and dependencies across the active actor network.[11]

### OpenAI Agents SDK
The OpenAI Agents SDK is a provider-agnostic, lightweight orchestration library designed to build multi-agent workflows across OpenAI models and over 100 other LLMs.[8, 9] The core capability of the SDK is the native execution of Sandbox Agents, first introduced in version 0.14.0.[8] A sandbox agent pairs the model with a managed file workspace and a container-based sandbox environment, allowing it to inspect files, execute shell commands, and persist filesystem state over long execution horizons.[1, 8, 9]

```
OpenAI Agents SDK Architecture:
   ===> Uses tools inside
                                                     ||
                                          
                                                     ||
                                           [inspect / griffe Parser]
```

The SDK provides five primary categories of tools [21]:
* **Hosted OpenAI Tools**: Code interpreter, file search, and web search running directly on OpenAI servers.[21]
* **Local/Runtime Execution Tools**: `ComputerTool` and `ApplyPatchTool` executing in the local runtime environment, and `ShellTool` running within local or hosted container environments.[21]
* **Function Calling**: Python functions wrapped dynamically as tools.[21]
* **Agents as Tools**: Exposing a specialist agent as a callable function without executing a full handoff.[21]
* **Hosted MCP Tools**: Connecting the agent to remote Model Context Protocol (MCP) servers.[21]

To construct tool schemas, the SDK uses the Python `inspect` module to parse function signatures, dynamically building Pydantic models to represent the JSON Schema arguments.[21] Docstring parsing is handled via the `griffe` package, supporting Google, Sphinx, and NumPy docstring formats.[21] 

Tool outputs are returned in structured formats [21]:
* Images: `ToolOutputImage` (or `ToolOutputImageDict`).[21]
* Files: `ToolOutputFileContent` (or `ToolOutputFileContentDict`).[21]
* Text: `ToolOutputText` (or standard stringable types).[21]

Engineers can configure tool execution timeouts via `timeout_behavior`.[21] Setting this to `"error_as_result"` (the default) catches the timeout and returns a recoverable error message to the model.[21] Setting it to `"raise_exception"` triggers a `ToolTimeoutError` and terminates the run.[21]

### Claude Agent SDK
The Claude Agent SDK enables developers to programmatically build autonomous agents leveraging the same core agent loop, tool execution engine, and context management that powers the Claude Code command-line interface (CLI).[10, 16, 19] Unlike cloud-managed agent platforms, the Claude Agent SDK executes in-process on the developer's infrastructure, spawning local execution loops that communicate with Claude models.[10, 12] 

The SDK has access to a built-in toolset [10, 16]:
* `Read`: Reads files within the designated working directory.[10, 16]
* `Write` and `Edit`: Autonomously creates files and applies target modifications.[10, 16]
* `Bash`: Executes terminal commands, git operations, and local shell scripts.[10]
* `Monitor`: Watches a background script and reacts dynamically to each output line as a distinct execution event.[10]
* `Glob` and `Grep`: Locates files and searches file contents using regular expressions.[10]
* `WebSearch` and `WebFetch`: Searches the web and parses raw web page content.[10]
* `AskUserQuestion`: Asks the user clarifying questions with multiple-choice options.[10]

```
Claude Agent SDK Permission Evaluation:
   ===>
                                        ||
                                [permissionMode]
                                        ||
                              
```

Security and tool execution permissions are managed via `ClaudeAgentOptions`.[12] The system evaluates proposed tool calls against three distinct layers [12]:
1. **Allowed Tools (`allowedTools` / `allowed_tools`)**: An auto-approval allowlist; listed tools are executed without prompting the user.[12]
2. **Disallowed Tools (`disallowedTools` / `disallowed_tools`)**: A blocklist; listed tools are completely blocked from execution.[12]
3. **Permission Mode (`permissionMode` / `permission_mode`)**: Defines the fallback behavior for tools not listed in the allowlist.[12] For example, setting this to `'acceptEdits'` auto-approves filesystem changes but prompts the user for arbitrary shell commands.[12]

Developers can hook into the agent lifecycle by registering callback functions.[10] Available hooks include `PreToolUse`, `PostToolUse`, `Stop`, `SessionStart`, `SessionEnd`, and `UserPromptSubmit`.[10] For example, a developer can register a `PostToolUse` callback to write file modification details to an external audit file (`./audit.log`) whenever the model invokes the `Edit` or `Write` tools.[10]

For complex engineering tasks, a parent agent can spawn subagents by adding `"Agent"` to its `allowedTools` list.[10] The main agent invokes subagents via the built-in `Agent` tool, providing specialized instructions.[10] To ensure debugging traceability across nested hierarchies, all execution messages generated within a subagent context include a `parent_tool_use_id` field, allowing logging systems to map the nested execution graph back to the parent coordinator.[10]

---

## Multi-Agent Interaction Patterns: Supervisor, Swarm, and Handoff

The spatial layout and communication pathways of a multi-agent system define its scalability, token consumption, and failure profile.[22, 23] There are two primary topological models used in enterprise orchestrations: the centralized Supervisor pattern and the decentralized Swarm pattern.[23]

| Architectural Dimension | Centralized Supervisor | Decentralized Swarm (Handoff) |
| :--- | :--- | :--- |
| **Routing Authority** | Central coordinator agent with dynamic dispatch logic.[23] | Distributed across specialist agents via embedded handoff tools.[23, 24] |
| **Token Overhead** | High ($20\% - 40\%$ premium per run for coordinator reasoning).[23] | Minimal; tokens are consumed only by the active executing agent.[23] |
| **Concurrency Model** | Serialized hub-and-spoke dispatch; throughput bottleneck risks.[23] | Sequential active execution turns; highly optimized for single-stream paths.[23, 25] |
| **Context Management** | Centralized accumulator; prone to window saturation after $8-12$ turns.[23] | Context is preserved and passed dynamically to the newly activated agent.[23, 24] |
| **Error Propagation** | Controlled; supervisor intercepts errors and initiates recovery loops.[23] | High risk; malformed states propagate unchecked across downstream peers.[23] |
| **Failure Surface Scale** | Linear ($O(n)$) scaling based on the number of registered worker roles.[23] | Quadratic ($O(n^2)$) scaling, presenting testing and debugging bottlenecks.[23] |

### Centralized Supervisor Pattern
The Supervisor pattern utilizes a hub-and-spoke topology.[23] A central routing agent accepts the initial user request, decomposes it into subtasks, dynamically selects the appropriate specialist worker agent, and validates the output before advancing the execution flow.[23]

This architecture provides quality control advantages in production.[23] Because the supervisor agent acts as a centralized validation gate, it can intercept erroneous or malformed outputs before they propagate to downstream systems.[23] It also prevents infinite execution loops by enforcing explicit re-dispatch limits and resolving conflicts when multiple workers return contradictory results.[23] 

However, this centralization introduces steep operational costs.[23] A supervisor architecture typically incurs a $20\%$ to $40\%$ token overhead compared to direct routing models.[23] Because the central coordinator must accumulate the full message history of all worker interactions to maintain context, its context window rapidly saturates.[23] After $8$ to $12$ round trips, routing accuracy can degrade significantly due to historical noise crowding out the current state.[23] Furthermore, the supervisor's synchronous dispatch loop makes it a throughput bottleneck for embarrassingly parallel workloads.[23]

### Decentralized Swarm (Handoff) Pattern
The Swarm pattern distributes routing intelligence across the agent pool.[23] Each specialist agent encapsulates its own system instructions, local tools, and a set of explicit handoff definitions.[23, 24] When an agent completes its narrow task, it evaluates whether to transfer control by executing a special handoff tool call, which shifts the active execution pointer to a peer agent while maintaining a shared conversation history.[23, 24] 

This decentralized approach is lightweight and optimizes token efficiency.[23] There is no central routing coordinator to consume tokens, making it ideal for exploratory, read-heavy workloads like triage, content generation, and multi-agent debate.[22, 23] 

The primary trade-off is structural fragility and behavioral drift.[23] Because no single entity has a global view of the workflow state, unexpected routing loops and cascading failures are challenging to debug.[23] Each handoff is a probabilistic event; as a workflow progresses beyond $8$ to $10$ sequential agent turns, semantic drift compounds.[23] This can cause the active agent to lose track of the original user intent, or drift into conflicting outputs.[23] 

Crucially, the failure surface of a fully connected peer-to-peer swarm scales quadratically ($O(n^2)$) with the number of agent nodes.[23] The potential communication and failure pathways are calculated as:

$$\text{Failure Pathways} = \frac{n(n - 1)}{2}$$

where $n$ represents the number of autonomous agents in the swarm.[23] For a swarm of $4$ agents, there are $6$ potential failure pathways; for $10$ agents, the failure surface expands to $45$ distinct interactive states, rendering exhaustive testing of the state space unfeasible.[23]

---

## Human-in-the-Loop Integrations and Revision Loops

Production-grade agentic workflows require robust guardrails and human review points.[1, 4] Inserting human checkpoints into execution flows ensures safety for high-risk operations, such as executing database writes, sending outbound communications, or running terminal commands.[13, 26]

### LangGraph Interruption and the Command Interface
LangGraph implements human-in-the-loop (HITL) mechanics natively through its persistence layer.[4, 13] Developers configure interrupts on target nodes or tools by defining policies in the `interrupt_on` parameter.[13] During its `after_model` execution hook, the LangGraph middleware checks if any proposed tool call matches the interrupt criteria.[13] If a match is detected, the runtime immediately halts execution, marks the thread as interrupted, and persists the current state snapshot to the checkpointer.[13, 26]

To resume the paused thread, the application re-invokes the graph with a `Command` object and the corresponding `thread_id`.[13, 17] The human reviewer provides input through four built-in decision types [13]:
* **`approve`**: The proposed tool call is executed exactly as generated by the model.[13]
* **`edit`**: The proposed tool arguments are programmatically modified by the human before execution (e.g., changing a database update payload).[13] When editing tool arguments, changes should be made conservatively, as significant modifications may cause the model to re-evaluate its approach and execute tools multiple times.[13]
* **`reject`**: Tool execution is blocked, and the reviewer's feedback is appended to the message history as a system message, guiding the model to self-correct.[13]
* **`respond`**: Tool execution is skipped entirely, and the reviewer's text is returned to the model as the direct tool result (useful for mock or placeholder interfaces).[13]

### CrewAI Feedback Loops and Enterprise Delivery
CrewAI manages human feedback through its `@human_feedback` decorator, which pauses flow execution and displays intermediate results to the user.[27, 28] To handle revision workflows, CrewAI leverages asynchronous listener routing.[27] Rather than relying on a static graph edge, developers build dynamic self-loops using the `@listen(or_("trigger_event", "revision_outcome"))` syntax.[27] 

When a human reviews a draft and requests edits, the model parses the unstructured feedback and maps it to a structured feedback output (e.g., `needs_revision`).[27] This triggers the listener method to execute again, creating an automated revision loop that continues until the output matches the human's criteria.[27] Crucially, the model extracts generalized lessons from the human's feedback and stores them in memory with a `source="hitl"` attribute.[27] On subsequent execution turns, these lessons are retrieved and automatically appended to the model's system instructions to prevent it from repeating the same mistakes.[27]

For enterprise deployments, CrewAI Enterprise shifts this capability from a terminal-bound interface to an email-first and webhook-driven architecture.[28] When execution hits a review point, the platform generates a unique reply-to email address containing a cryptographically signed authentication token.[28] The assigned human reviewer receives a formatted notification email, and can reply directly to the email with their feedback.[28] The platform validates the signed token, maps the sender's address, injects the feedback payload into the running flow state, and resumes execution—all without requiring the reviewer to log into a specialized dashboard UI.[28]

---

## Durable Execution and Temporal Integration

As multi-agent workflows extend to hundreds of steps and incorporate long-lived loops, they face a statistical certainty of infrastructure failure.[2] Standard checkpointing and retry scripts are limited: they require manual integration, do not preserve thread execution stacks, and cannot safely manage complex, distributed state transitions.[2] This baseline fragility is why enterprise AI teams are shifting to Temporal durable execution.[3, 29]

### The Event Sourcing Replay Model
Temporal's durable execution model replaces application-level checkpointing with event sourcing.[29, 30] In Temporal, developer code is written as a standard procedural program inside a `Workflow`.[29, 30] Every external interaction—such as an LLM call or a filesystem tool execution—is wrapped as a Temporal `Activity`.[29, 30] 

The Temporal Service interceptively logs every activity completion to an append-only event history.[29, 30] If the worker process executing the agent crashes mid-workflow, another worker immediately picks up the execution.[2, 29] Temporal replays the workflow code from the beginning.[2, 30] However, when the code reaches an activity that has already been executed successfully, Temporal intercepts the call, retrieves the cached result from the event log, and immediately returns it without re-executing the actual code or invoking the external API.[2, 30] This reconstructs the execution stack and local variable states, allowing the agent to resume execution from the exact point of failure with zero state loss and zero redundant API calls.[2, 30]

In the case of a custom tool-calling ReAct agent, every reasoning turn is managed dynamically.[30] For example, in a weather lookup workflow fanning out to geolocate an IP and query weather alerts, the workflow registers tools as Temporal activities.[30] To run safely within the Temporal sandbox, the execution code uses an explicit block to pass through system libraries [30]:

```python
from temporalio import workflow

with workflow.unsafe.imports_passed_through():
    import httpx
    import pydantic
```

This prevents the sandboxed workflow loop from throwing import violations when calling external HTTP wrappers.[30]

Developers can also leverage community extensions to inject durability into pre-existing agent frameworks.[31] For instance, the open-source `DuraLang` library provides a simple `@dura` decorator that wraps standard LangChain tool executions, LLM calls, and MCP invocations directly in Temporal activities.[31] This allows developers to run legacy LangChain agents with Temporal’s fault-tolerant event sourcing without rewriting the core orchestration logic.[31]

### OpenAI Agents SDK Temporal Integration
To bring production durability to the OpenAI Agents SDK, Temporal provides a native integration plugin (`OpenAIAgentsPlugin`) and a sandbox client wrapper (`temporal_sandbox_client()`).[18, 32]

```
OpenAI Agents SDK + Temporal Integration:
  
         || (OpenAIAgentsPlugin)
   ===> Executes SandboxAgent turns
                                                   ||
                                        (temporal_sandbox_client)
                                                   ||
                                     
                                         (Bash, Read, Write, LLM)
```

The connection between the OpenAI SDK and Temporal is established through a single function call: `temporal_sandbox_client()`.[18] By configuring the `SandboxAgent`'s `RunConfig` with `client=temporal_sandbox_client(self._backend.value)`, the sandbox client is wrapped.[18] This wrapper ensures that all core sandbox operations—including LLM model API calls, running shell commands, manipulating files, and managing the overall sandbox lifecycle—are executed as **Temporal activities**.[18] This makes them fully durable, retryable, and resilient to infrastructure failures without requiring changes to how the agent's logic is written.[18]

The SDK includes the `activity_as_tool` helper function.[32] This function automatically generates OpenAI-compatible tool schemas from Temporal activity function signatures, wraps the activities as agent tools, and provides them directly to the `Agent`.[32] 

The integration orchestrates agents through three core architectural components [18]:
1. **AgentWorkflow**: A long-lived, durable workflow wrapping the OpenAI agent.[18] It processes incoming user messages, executes the agent turns, and manages sandbox environment modifications.[18]
2. **SessionManagerWorkflow**: Instead of relying on a traditional server backed by an external database to track and manage agent sessions, this workflow orchestrates the lifecycle of agent sessions durably using Temporal workflow abstractions.[18] It handles starting, stopping, listing, renaming, and forking sessions.[18]
3. **Terminal User Interface (TUI)**: A reference client that communicates with the workflows via Temporal signals (for sending asynchronous messages), queries (for real-time status polling), and updates (for transactional operations).[18]

#### Zero-Cost Idle Mechanics
Inside the `AgentWorkflow`, the core execution relies on a loop that utilizes `workflow.wait_condition` to halt computation when the agent is waiting for human input [18]:

```python
await workflow.wait_condition(
    lambda: (len(self._pending_messages) > 0 or self._pause_requested or self._done),
)
```

When there are no pending messages from the user, the workflow enters an idle state.[18] During this time, it consumes **zero compute resources**.[18] The agent's idle state is persisted on the Temporal server rather than remaining active in a running process or keeping an active sandbox container alive.[18] 

The workflow can remain idle for seconds, days, or weeks.[18] If the worker hosting the process restarts during this idle period, the workflow resumes exactly where it left off without losing context history, rebuilding the workspace, or rerunning setup commands.[18] This allows platforms to scale to thousands of concurrent sessions without paying for thousands of idle sandboxes.[18]

#### Multi-Sandbox Forking and Sessions
Because session management is orchestrated by the `SessionManagerWorkflow`, sessions can be seamlessly forked across completely different sandbox backends (such as moving from a local Docker environment to Daytona or E2B).[18] The workflow executes this transition through a sequence [18]:
1. The source `AgentWorkflow` is signaled to pause, ensuring its current session state is successfully checkpointed and halted.[18]
2. An activity is triggered to query the active workspace and generate a portable filesystem snapshot.[18]
3. A new child `AgentWorkflow` is initialized on the target sandbox provider, using the exact conversation history and filesystem snapshot from the source session.[18]

### Production Observability with Braintrust
To manage prompt drift, evaluate output quality, and track execution costs across multi-model setups, production Temporal workers integrate directly with the Braintrust observability platform.[33] In a multi-agent workflow (e.g., fanning out from planning and query-generation agents to parallel search and synthesis agents), a single wrapper on the AsyncOpenAI client routes all executions through the Braintrust trace logging system [33]:

```python
from braintrust import wrap_openai
from openai import AsyncOpenAI

client = wrap_openai(AsyncOpenAI(max_retries=0))
```

Setting `max_retries=0` is a required design pattern in this architecture, as it delegates all retries and backoff logic to the underlying Temporal Activity layer, preventing duplicate execution attempts at the LLM client level.[33] 

The integration maps the execution history [33]:
* Every Temporal Workflow run becomes a root Braintrust span, capturing the parent workflow context and tracing all downstream child actions.[33]
* Individual activities map to child spans, displaying token counts, model latency, and prompt versions loaded dynamically via `load_prompt()`.[33]
* Prompt optimization is decoupled from code deployments, letting engineers refine templates in the Braintrust UI while Temporal handles state persistence and fault-tolerant execution.[33]

---

## Strategic Engineering Conclusions and Architectural Recommendations

Selecting the appropriate agent orchestration framework requires a careful evaluation of the system's operational constraints.[5, 7] Frameworks should be matched to specific production scenarios based on their structural strengths and architectural limitations [5]:

* **LangGraph**: Should be selected when the workflow demands strict determinism, transaction safety, and a highly structured, centralized state machine.[4, 5] It is the optimal choice for multi-step enterprise workflows where branching rules must be explicitly validated and cyclic loops must be tightly controlled.[4, 5, 17]
* **CrewAI**: Is best suited for rapid prototyping and workflows that leverage human-centric role metaphors.[20] The framework’s structured flows and interactive checkpoint-forking CLI make it ideal for document generation, creative workflows, and systems requiring dynamic human revision loops.[6, 14]
* **AutoGen (v0.4+)**: Is the recommended choice for highly decoupled, event-driven multi-agent systems that need to scale horizontally across processes or maintain cross-language interoperability (Python and.NET).[7, 11] It is well-suited for autonomous negotiation, open-ended conversational routing, and setups requiring visual execution controls like those in AutoGen Studio.[5, 11]
* **OpenAI Agents SDK**: Should be deployed when agents require containerized workspaces, deep filesystem access, and direct integration with hosted OpenAI tools.[1, 8, 9] It is highly effective for building autonomous workspace assistants, automated code patchers, and developer tools.[8, 21]
* **Claude Agent SDK**: Is the ideal framework for local, in-process codebase analysis, refactoring, and security auditing.[10, 16] By executing on the developer's infrastructure and providing native access to system-level tools like Read, Write, Edit, and Monitor, it offers a secure path for building developer agents.[10, 16]

For systems operating above the complexity cliff, standard checkpointing layers represent a fragile engineering pattern.[2] When an agent must run for long periods, coordinate with dozens of APIs, and manage critical external state transitions, the orchestration layer must be decoupled from the volatile agent reasoning loop.[2] Integrating Temporal durable execution with frameworks like the OpenAI Agents SDK or custom tool-calling loops provides a robust architecture.[18, 30] By offloading state tracking and crash recovery to Temporal’s event-sourced engine, developers can build multi-agent systems with guaranteed reliability, ensuring that execution resumes exactly where it left off, regardless of infrastructure failures.[2, 29, 30, 34]

---

1. Agents SDK | OpenAI API, [https://developers.openai.com/api/docs/guides/agents](https://developers.openai.com/api/docs/guides/agents)
2. Building AI agents that overcome the complexity cliff | Temporal, [https://temporal.io/blog/building-ai-agents-that-overcome-the-complexity-cliff](https://temporal.io/blog/building-ai-agents-that-overcome-the-complexity-cliff)
3. Durable AI Agents Bundle - Temporal, [https://temporal.io/pages/durable-ai-agent-bundle](https://temporal.io/pages/durable-ai-agent-bundle)
4. What Is LangGraph? State, Agents & Production Use Cases 2026 - Atlan, [https://atlan.com/know/ai-agent/ai-agent-memory/what-is-langgraph/](https://atlan.com/know/ai-agent/ai-agent-memory/what-is-langgraph/)
5. LangGraph vs AutoGen State Tracking: Checkpoint Mechanisms, Timeout Recovery, and Framework Selection, [https://eastondev.com/blog/en/posts/ai/20260526-langgraph-autogen-state-tracking-en/](https://eastondev.com/blog/en/posts/ai/20260526-langgraph-autogen-state-tracking-en/)
6. Flows - CrewAI, [https://docs.crewai.com/en/concepts/flows](https://docs.crewai.com/en/concepts/flows)
7. AutoGen v0.4: Reimagining the foundation of agentic AI for scale, extensibility, and robustness - Microsoft Research, [https://www.microsoft.com/en-us/research/articles/autogen-v0-4-reimagining-the-foundation-of-agentic-ai-for-scale-extensibility-and-robustness/](https://www.microsoft.com/en-us/research/articles/autogen-v0-4-reimagining-the-foundation-of-agentic-ai-for-scale-extensibility-and-robustness/)
8. openai/openai-agents-python: A lightweight, powerful framework for multi-agent workflows - GitHub, [https://github.com/openai/openai-agents-python](https://github.com/openai/openai-agents-python)
9. OpenAI Agents SDK (JavaScript/TypeScript) - GitHub, [https://github.com/openai/openai-agents-js](https://github.com/openai/openai-agents-js)
10. Agent SDK overview - Claude Code Docs, [https://code.claude.com/docs/en/agent-sdk/overview](https://code.claude.com/docs/en/agent-sdk/overview)
11. AutoGen v0.4: Reimagining the foundation of agentic AI for scale, extensibility, and robustness - Microsoft Research, [https://www.microsoft.com/en-us/research/blog/autogen-v0-4-reimagining-the-foundation-of-agentic-ai-for-scale-extensibility-and-robustness/](https://www.microsoft.com/en-us/research/blog/autogen-v0-4-reimagining-the-foundation-of-agentic-ai-for-scale-extensibility-and-robustness/)
12. anthropics/claude-agent-sdk-python - GitHub, [https://github.com/anthropics/claude-agent-sdk-python](https://github.com/anthropics/claude-agent-sdk-python)
13. Human-in-the-loop - Docs by LangChain, [https://docs.langchain.com/oss/python/langchain/human-in-the-loop](https://docs.langchain.com/oss/python/langchain/human-in-the-loop)
14. Checkpointing - CrewAI, [https://docs.crewai.com/en/concepts/checkpointing](https://docs.crewai.com/en/concepts/checkpointing)
15. AutoGen v0.4.4 released : r/AutoGenAI - Reddit, [https://www.reddit.com/r/AutoGenAI/comments/1icubxj/autogen_v044_released/](https://www.reddit.com/r/AutoGenAI/comments/1icubxj/autogen_v044_released/)
16. Building AI agents with the Claude Agent SDK - GitHub Gist, [https://gist.github.com/dabit3/93a5afe8171753d0dbfd41c80033171d](https://gist.github.com/dabit3/93a5afe8171753d0dbfd41c80033171d)
17. Building Human-In-The-Loop Agentic Workflows | Towards Data Science, [https://towardsdatascience.com/building-human-in-the-loop-agentic-workflows/](https://towardsdatascience.com/building-human-in-the-loop-agentic-workflows/)
18. Introducing Temporal and agentic sandboxes: The OpenAI agents ..., [https://temporal.io/blog/introducing-temporal-and-agentic-sandboxes-openai-agents-sdk](https://temporal.io/blog/introducing-temporal-and-agentic-sandboxes-openai-agents-sdk)
19. anthropics/claude-agent-sdk-typescript - GitHub, [https://github.com/anthropics/claude-agent-sdk-typescript](https://github.com/anthropics/claude-agent-sdk-typescript)
20. Best Open-Source AI Agent Stack Tools in 2026 | Data Science Collective - Medium, [https://medium.com/data-science-collective/the-open-source-agent-toolkit-in-2026-da66dda36c9b](https://medium.com/data-science-collective/the-open-source-agent-toolkit-in-2026-da66dda36c9b)
21. Tools - OpenAI Agents SDK, [https://openai.github.io/openai-agents-python/tools/](https://openai.github.io/openai-agents-python/tools/)
22. Multi-Agent Orchestration: 5 Patterns That Work - Digital Applied, [https://www.digitalapplied.com/blog/multi-agent-orchestration-5-patterns-that-work](https://www.digitalapplied.com/blog/multi-agent-orchestration-5-patterns-that-work)
23. Swarm vs. Supervisor: Multi-Agent Architecture Guide | Augment Code, [https://www.augmentcode.com/guides/swarm-vs-supervisor](https://www.augmentcode.com/guides/swarm-vs-supervisor)
24. Swarm — AutoGen - Microsoft Open Source, [https://microsoft.github.io/autogen/dev//user-guide/agentchat-user-guide/swarm.html](https://microsoft.github.io/autogen/dev//user-guide/agentchat-user-guide/swarm.html)
25. Handoffs — AutoGen - Microsoft Open Source, [https://microsoft.github.io/autogen/dev//user-guide/core-user-guide/design-patterns/handoffs.html](https://microsoft.github.io/autogen/dev//user-guide/core-user-guide/design-patterns/handoffs.html)
26. Making it easier to build human-in-the-loop agents with interrupt - LangChain, [https://www.langchain.com/blog/making-it-easier-to-build-human-in-the-loop-agents-with-interrupt](https://www.langchain.com/blog/making-it-easier-to-build-human-in-the-loop-agents-with-interrupt)
27. Human Feedback in Flows - CrewAI Documentation, [https://docs.crewai.com/en/learn/human-feedback-in-flows](https://docs.crewai.com/en/learn/human-feedback-in-flows)
28. Flow HITL Management - CrewAI Documentation, [https://docs.crewai.com/en/enterprise/features/flow-hitl-management](https://docs.crewai.com/en/enterprise/features/flow-hitl-management)
29. Temporal: Durable Execution Solutions, [https://temporal.io/](https://temporal.io/)
30. Durable AI agent with Gemini and Temporal | Gemini API - Google AI for Developers, [https://ai.google.dev/gemini-api/docs/temporal-example](https://ai.google.dev/gemini-api/docs/temporal-example)
31. Built a durable AI agent orchestration layer on Temporal — sharing patterns - Reddit, [https://www.reddit.com/r/Temporal/comments/1swatro/built_a_durable_ai_agent_orchestration_layer_on/](https://www.reddit.com/r/Temporal/comments/1swatro/built_a_durable_ai_agent_orchestration_layer_on/)
32. Durable Agent with Tools - OpenAI Agents SDK - Temporal Docs, [https://docs.temporal.io/ai-cookbook/openai-agents-sdk-python](https://docs.temporal.io/ai-cookbook/openai-agents-sdk-python)
33. Building observable AI agents with Temporal - Blog - Braintrust, [https://www.braintrust.dev/blog/temporal-braintrust-integration](https://www.braintrust.dev/blog/temporal-braintrust-integration)
34. Announcing the OpenAI Agents SDK + Temporal Integration - YouTube, [https://www.youtube.com/watch?v=fwh21RV6bRo](https://www.youtube.com/watch?v=fwh21RV6bRo)

