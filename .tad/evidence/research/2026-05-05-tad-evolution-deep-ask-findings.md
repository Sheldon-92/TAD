# TAD Evolution Research — Deep Ask Findings

> Notebook: TAD Evolution Research — AI Agent Framework Landscape 2025-2026
> Notebook ID: 37cfefa5-52b3-4a8a-a8e3-a83f32150759
> Sources: 45 (post-curate, deduplicated)
> Date: 2026-05-05
> Rounds: 3

---

## Round 1: Multi-Agent Architecture Comparison

**Question**: Compare multi-agent approaches across AI coding frameworks (role separation, quality assurance, human-in-the-loop).

### Key Findings

**Role Separation Patterns (3 types documented)**:
1. **Dual-Agent**: OpenCode (read-only plan + full-access build), Cline (Plan/Act mode separation) — closest to TAD's Alex/Blake
2. **Hierarchical Orchestrator-Worker**: Google ADK, Anthropic Agent SDK — central orchestrator delegates to specialized workers
3. **Role-Based Parallel Crews**: CrewAI (personas), Cursor (up to 8 parallel agents in worktrees), Codex (parallel execution)

**Quality Assurance Patterns (3 types)**:
1. **Self-Review (Evaluator-Optimizer Loop)**: One LLM generates, another evaluates in a loop — equivalent to TAD's Ralph Loop
2. **External/Peer Agent Review**: AutoGen conversational critique, Codegen line-by-line review — equivalent to TAD's Layer 2
3. **Parallel Voting / Multi-Model Consensus**: Multiple independent review agents aggregate findings with vote thresholds — TAD doesn't have this

**Human-in-the-Loop Mechanisms (4 types)**:
1. **Mandatory Approval Gates + Checkpointing**: LangGraph state machines with durable pause/resume — TAD has Gates but no checkpoint persistence for mid-gate recovery
2. **Time-Travel Debugging**: LangGraph persists full execution state, humans can rewind to any node — TAD doesn't have this
3. **Agent-Initiated Escalation**: Claude agents pause proactively on complex tasks — TAD has circuit breaker but not proactive uncertainty detection
4. **Asynchronous Review**: Devin/Copilot submit draft PRs for async human review — TAD is fully synchronous

---

## Round 2: Failure Modes, Evaluation, Memory, Cost

**Question**: Critical gaps and failure modes documented in 2025-2026.

### Key Findings

**Production Failure Modes**:
- **Compounding errors**: 10 agents × 98% accuracy = 81.7% system accuracy. 8 consecutive runs: 60% → 25% success
- **Rate limit exhaustion**: 60% of LLM call failures (Datadog Feb 2026), 8.4M errors in March 2026
- **Agent-to-Agent toxic combinations**: Compromised MCP server taints entire ecosystem
- **Contextual blindness**: Agents without enterprise context produce generic, surface-level output

**Evaluation Beyond SWE-bench**:
- **SWE-bench is hackable**: Berkeley researchers achieved near-100% scores by hacking eval environments (conftest.py hook trick)
- **CLEAR Framework**: Cost, Latency, Efficacy, Assurance, Reliability — 37% gap between lab and production performance, 50x cost variation
- **Trajectory metrics**: Evaluate every reasoning step, not just final outcome
- **Granular rubrics + LLM-as-Judge**: 7 dimensions, 25 sub-dimensions, 130 items; calibrated against human preference datasets, target 0.80 Spearman correlation

**Agent Memory Patterns**:
- **Graph-Enhanced Memory (Mem0g)**: 68.4% accuracy on LOCOMO (vs 66.9% vector), 90% fewer tokens than full-context, 1.09s latency
- **Actor-Aware Memory**: Tags facts with source actor — prevents planning agent from trusting hallucinated inference
- **Procedural Memory**: Stores how-to knowledge (CI/CD patterns, PR structures), distinct from factual knowledge

**Cost Optimization**:
- **Framework overhead**: CrewAI consumes 3x more tokens than LangGraph on simple tasks
- **Prompt caching**: 69% of input tokens are system prompts, but only 28% of calls use caching. Restructuring → 80-90% cost reduction
- **SLMs for evaluation**: Galileo Luna-2 at $0.01-0.02/M tokens, 3% cost of GPT-4, sub-200ms latency
- **Structural validation gates**: 90% validation success rate boosts 10-agent pipeline from 81.7% → 98.0% reliability

---

## Round 3: TAD-Specific Upgrade Recommendations

**Question**: Based on all sources, what are the top improvement directions for TAD?

### Quality Assurance Upgrades
1. **Trajectory Metrics**: Measure every reasoning step, not just outcome — diagnose WHY failures occur
2. **Evaluation Isolation**: Expert review must run OUTSIDE Blake's environment (prevent reward hacking / conftest.py trick)
3. **Calibrated LLM-as-Judge Ensembles**: Granular rubrics + multi-model consensus, target 0.80 Spearman correlation with human judgment
4. **Fix Rate for Partial Progress**: Soft metric measuring fraction of failing tests resolved, penalizing regressions

### Async/Background Execution
1. **Agent-Initiated Escalation**: Blake proactively pauses on uncertainty (don't wait for human to notice)
2. **Durable Checkpointing + Mandatory Approval Gates**: Background execution with pause-points only at high-impact actions
3. **Asynchronous PR Workflow**: Blake operates in sandbox → submits draft PR → human reviews async
4. **Background Subagents**: Isolate noisy tasks (log grep, test suites) into background agents, return summary only

### Knowledge/Memory Evolution
1. **Actor-Aware Memory**: Tag every fact with source (Alex vs Blake vs Human) — prevent cross-contamination
2. **Graph-Enhanced Memory**: Entities + relationships instead of flat semantic vectors — better for multi-hop coding queries, 90% fewer tokens
3. **Procedural Memory**: Dedicated memory for HOW-TO (CI/CD patterns, deployment workflows) separate from factual knowledge
4. **Multi-Scope Memory**: User-level + project-level + local-level — accumulate across sessions without cross-contamination

### Observability (Table-Stakes)
1. **Distributed Tracing**: Follow requests across every tool call, sub-agent handoff, and retry loop between Alex and Blake
2. **Time-Travel Debugging**: Persist full execution state, rewind to error node, resume without restart
3. **Identity-Aware Audit Trails**: Every Blake action tied to authenticated user via OAuth 2.0
4. **Capacity/Rate Limit Monitoring**: Track concurrency and retry spikes, implement backpressure

---

## Round 4: Primitive Capabilities Taxonomy (added 2026-05-05)

[Summarized in conversation — covers 4 capability quadrants: Orchestration, Memory/State, Tool Integration, Observability/Governance. Key finding: Anthropic's plugin architecture = Skills (domain) + MCP (tools) + Plugins (bundles). Most transferable primitives: ReAct loops, modular tool routing, MCP protocol-level interop.]

---

## Round 5: Domain Pack Activation Problem (THE CORE FINDING)

**Question**: Why do 20 domain packs exist in context but agent doesn't use them?

### Root Cause: Institutional Impedance Mismatch

The Knowledge Activation paper identifies the core problem: **injecting knowledge into context ≠ activating behavior**. The agent falls back on generic training heuristics because standard retrieval provides "informational text" rather than "action-ready specifications."

Key concept: "Where retrieval returns content for reading, activation delivers guidance for acting."

If YAML packs don't explicitly link procedural steps to exact tool bindings and continuation paths, the LLM is forced to INFER how to use the knowledge → skipped steps, hallucinations, trial-and-error ("context rot").

### MCP Context Overload Problem

- LLMs are stateless — evaluate ALL available tools on EVERY request
- 20 domain packs + tools = massive token consumption before reasoning starts (55,000+ tokens)
- When LLM sees 40 tool definitions → picks wrong one more often
- When LLM sees 3 relevant tools → 20-30% accuracy gain

### Solutions That Work

1. **Progressive Disclosure / Deferred Loading**: Agent only sees metadata (30-50 tokens per pack). Full workflow loads ONLY when agent determines relevance. This is what Claude Code's ToolSearch already does.

2. **Atomic Knowledge Units (AKUs)**: Restructure packs from descriptions → specifications with:
   - Specific intent declarations
   - Numbered procedural steps
   - Explicit tool bindings (exact CLI commands)
   - Continuation paths (what to do if step succeeds/fails)

3. **Interleaved ReAct**: Force agent to "think out loud" — outline planned workflow steps BEFORE executing. This forces attention onto provided knowledge.

4. **Deterministic Validators**: Don't rely on LLM compliance. Embed validation scripts that physically block proceeding until step is complete.

### Fewer vs Many Packs

- Each pack should encode EXACTLY ONE coherent action (not broad multi-step)
- Overly broad packs waste tokens with irrelevant data
- Overly narrow packs fail to trigger accurately
- For tools: fewer, well-designed, highly capable functions > many narrow ones

### Event-Driven Skill Invocation

Key distinction from sources: **"Hooks are for actions that MUST happen. Skills are for guidance that SHOULD be followed."**

If quality criteria or workflow gates MUST be satisfied → move them from passive YAML to event-driven Hooks/Validators that physically block agent from proceeding.

### Implication for TAD

TAD's current Domain Packs are "informational text" (descriptions of tools and criteria), not "action-ready specifications" (step-by-step with tool bindings and continuation paths). This is WHY they don't activate behavior despite being loaded.

The fix is NOT more hooks or better detection — it's restructuring the packs themselves from "what to know" to "what to DO, with exactly which command, in what order, and what to check after each step."
