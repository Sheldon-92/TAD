---
name: agent-orchestration
description: Agent orchestration capability pack. Gives AI agents the judgment rules for building reliable multi-agent systems — framework selection (LangGraph / CrewAI / AutoGen v0.4+ / OpenAI Agents SDK / Claude Agent SDK), Supervisor vs Swarm topology, durable execution with Temporal event sourcing, human-in-the-loop interrupt/resume patterns, and tool-permission models. Research-grounded rules from framework docs, Temporal durable-execution patterns, and production complexity-cliff analysis. Use for any multi-agent architecture, orchestration framework choice, checkpoint/recovery design, HITL gating, or agent tool-permission task.
keywords: ["agent orchestration", "智能体编排", "multi-agent", "多智能体", "LangGraph", "CrewAI", "AutoGen", "Microsoft Agent Framework", "OpenAI Agents SDK", "Claude Agent SDK", "Temporal", "durable execution", "持久化执行", "supervisor", "swarm", "orchestrator-worker", "fan-out", "checkpoint", "检查点", "human-in-the-loop", "failure mode", "MAST", "失败模式", "状态机", "agent 框架"]
type: reference-based
---

**CONSUMES**: User multi-agent / orchestration task + target workflow description + step count / duration estimate + optional existing framework choice
**PRODUCES**: Applied orchestration judgment rules + framework selection rationale + topology decision (supervisor/swarm) + durability/checkpoint plan + HITL interrupt design + tool-permission audit

# Agent Orchestration Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0

---

## What This Pack Does

AI agents wire up multi-agent systems by copying a framework's quickstart. They pick LangGraph because it is popular, not because the workflow needs deterministic state. They build swarms with 8 peer agents and never reason about the O(n²) failure surface. They run 300-step agents on bare retry loops, then are surprised when step 280 crashes and restarts from step 1 — re-sending the emails it already sent. They auto-approve every tool call because adding a human gate "later" never happens.

This pack embeds the judgment rules that orchestration engineers apply automatically — rules from framework documentation, Temporal durable-execution patterns, and production reliability data.

**Pack = orchestration judgment. Your workflow system = process constraints. No overlap.**

---

## Cross-Cutting Rule: The Complexity Cliff — Reliability Decays Exponentially with Step Count

> **Cumulative agent reliability is `P(fail) = 1 - (1 - p)^s`, where `p` is per-step failure probability and `s` is the number of sequential steps.** A 99% per-step success rate (`p = 0.01`) gives a **63.4% cumulative failure probability at 100 steps** and **99.3% at 500 steps**. State-management failures (lost context, repeated expensive steps, crash with no recovery path) are a leading, often-dominant source of production agent incidents.
> **Therefore: once cumulative failure becomes material, decouple the orchestration/state layer from the agent reasoning loop** — via durable checkpointing or event-sourced execution. As a derived heuristic from the cited figures (NOT a research-reported threshold): at `p = 0.01`, `P(fail)` crosses ~40% by ~50 steps (`1 - 0.99^50 ≈ 0.395`), ~63% at 100 steps, and ~99% at 500 steps — so treat workflows of a few tens of sequential steps and up as candidates for durable execution, and compute `P(fail)` against your own per-step `p`. Bare retry scripts are a fragile pattern above the cliff: they do not preserve the execution stack and re-run side-effecting steps on restart.

This rule applies to: framework selection, topology choice, durability design, and every "we'll just add retries" decision. It is surfaced here because burying it in one reference file causes agents to under-build durability and then ship agents that fail statistically.

> Source: findings.md "Exponential Failure Mechanics" [2] (formula + 63.4%@100 / 99.3%@500), "Complexity Cliff" [2,4]. The ~40%@50-steps figure is DERIVED from the same `1 - (1-p)^s` model at `p=0.01`, not separately reported by research; the "few tens of steps" durability trigger is an authored heuristic, not a research-stated threshold.

---

## Step 0: Context Detection

When the user mentions orchestration / multi-agent work, detect the context and load the right reference:

| User Signal | Reference to Load |
|-------------|-------------------|
| "which framework", "LangGraph vs", "CrewAI", "AutoGen", "OpenAI Agents SDK", "Claude Agent SDK", "state model", "选框架" | `references/framework-selection.md` |
| "supervisor", "swarm", "handoff", "topology", "routing", "how many agents", "token overhead", "orchestrator-worker", "fan-out", "编排模式" | `references/orchestration-patterns.md` |
| "why do agents fail", "failure mode", "MAST", "context collapse", "task misinterpretation", "coordination breakdown", "失败模式" | `references/failure-modes.md` |
| "durable", "Temporal", "crash recovery", "long-running", "checkpoint", "event sourcing", "resume", "持久化" | `references/durable-execution.md` |
| "human in the loop", "HITL", "approval", "interrupt", "review gate", "human feedback", "人工审核" | `references/human-in-the-loop.md` |
| "tool permission", "allowed tools", "subagent", "sandbox", "permission mode", "tool schema", "工具权限" | `references/tool-permissions.md` |
| "full architecture", "design the whole system", "complete orchestration" | Load **all references** sequentially |

---

## Step 1: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** — do not skim
2. **Apply each rule as a judgment check** against the user's architecture, framework choice, or workflow description
3. **For each violated rule**: state the violation clearly, then give the specific fix
4. **Enforce the Complexity Cliff cross-cutting rule** — compute `P(fail)` for the user's stated step count and decide whether durable execution is mandatory. Delegate the arithmetic to the validation script instead of doing it by hand: `bash scripts/pfail-calc.sh pfail <steps> [p]` (cumulative failure), `bash scripts/pfail-calc.sh swarm <agents>` (n(n-1) directed-handoff surface, SUP3), `bash scripts/pfail-calc.sh trigger <steps> [p]` (durability-band verdict). Run `bash scripts/pfail-calc.sh selftest` to confirm the anchor numbers (63.4%@100, 99.3%@500, swarm 10 = 90)
5. **Check determinismLevel annotations** — they tell you how reproducible the decision is:
   - `deterministic`: architectural decision, byte-stable (framework choice, topology, permission policy)
   - `semi-deterministic`: config is fixed but runtime behavior varies (checkpoint cadence, interrupt placement)
   - `non-deterministic`: outcome depends on agent reasoning / conversation dynamics (swarm drift, multi-turn routing)

Output format per finding:
```
[P0] Rule SUP3 (orchestration-patterns): 10-agent fully-connected swarm = 90 directed handoff pathways (n(n-1)), untestable.
→ Switch to a Supervisor topology or constrain handoff edges; do not ship a peer-to-peer swarm above ~5 agents.

[P1] Rule DUR1 (durable-execution): 300-step workflow on a bare retry loop — P(fail) ≈ 95% at p=0.01.
→ Wrap LLM/tool calls as Temporal Activities so a crash resumes from the event log, not from step 1.
```

---

## Step 2: Output

Produce a structured orchestration review:

```
## Orchestration Review: [system reviewed]

### Complexity Cliff Audit
- Stated step count: [s] | per-step p assumption: [p] | P(fail) = 1 - (1-p)^s = [%]
- Verdict: [bare retry OK / durable execution MANDATORY]

### P0 — Blocking (must fix before building)
- [finding + specific fix]

### P1 — Required (fix before production)
- [finding + specific fix]

### P2 — Advisory (improves robustness)
- [finding + specific fix]

### Framework / Topology Recommendation
[LangGraph / CrewAI / AutoGen / OpenAI Agents SDK / Claude Agent SDK + Supervisor/Swarm, with rationale tied to a rule]
```

---

## Anti-Skip Table

| Excuse | Counter |
|--------|---------|
| "It's only a few steps, retries are fine" | Compute P(fail) = 1 - (1-p)^s. At 100 steps and p=0.01 that is 63.4% failure. "A few steps" is rarely a few in agent loops. |
| "Swarm is simpler — no coordinator" | A fully-connected swarm's directed handoff surface scales O(n²): n(n-1) directed pathways — 4 agents = 12, 10 agents = 90. Beyond ~5 agents it is untestable and drifts after 8-10 turns. |
| "Supervisor handles everything cleanly" | Supervisors cost a 20-40% token premium and saturate context after 8-12 round trips — routing accuracy degrades from historical noise. |
| "We'll add a human approval step later" | High-risk tools (DB writes, outbound email, shell) need an interrupt BEFORE execution. Retrofitting HITL after side effects ship is too late. |
| "Checkpointing to SQLite is good enough" | LangGraph SqliteSaver under parallel writes locks connections and stalls. Production needs AsyncPostgresSaver, or event sourcing (Temporal). |
| "Auto-approve all tools, it's faster" | Claude Agent SDK has 3 permission layers (allow/disallow/mode) for a reason. An allowlist with no explicit `permissionMode` lets the mode decide unmatched tools and invites drift to a permissive mode — set `dontAsk` for a locked-down boundary; never `bypassPermissions`. |

---

## Tool / Framework Quick Reference

| Framework | Install / Entry | Primary Use |
|-----------|-----------------|-------------|
| LangGraph | `pip install langgraph` (framework, 1.x line); `langgraph-sdk==0.3.15` (2026-05-22) is the separate API-client package | Deterministic StateGraph, transaction-safe checkpointing, native interrupt HITL |
| CrewAI | `pip install crewai` | Role-metaphor crews + event-driven Flows, checkpoint-fork CLI (`crewai checkpoint`) |
| Microsoft Agent Framework | `pip install agent-framework` (Python) / `dotnet add package Microsoft.Agents.AI.Foundry` (.NET) — **1.0 GA 2026-04-03**, successor to AutoGen+Semantic Kernel | Graph workflows + type-safe routing + checkpointing + HITL; **default for new .NET/cross-stack builds** |
| AutoGen v0.4+ (legacy) | `pip install autogen-agentchat` | Actor-model async message passing, cross-language (Python/.NET), AutoGen Studio — superseded by Agent Framework for new builds (FS4) |
| OpenAI Agents SDK | `pip install openai-agents` (Sandbox Agents v0.14.0) | Sandbox/workspace execution (Unix-local, Docker, or hosted backend — containerized only with Docker/hosted) + filesystem persistence, 5 tool categories, handoffs |
| Claude Agent SDK | `pip install claude-agent-sdk` | In-process local agent loop, 3-layer permissions, subagent spawning |
| Temporal | `pip install temporalio` | Durable execution via event-sourced replay, zero-cost idle, crash recovery |
