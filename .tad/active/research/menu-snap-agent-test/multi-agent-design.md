# Multi-Agent Design Analysis: Menu Snap AI

> Domain Pack: ai-agent-architecture | Capability: multi_agent_design
> Date: 2026-04-02
> Test Subject: Menu Snap AI — menu photo analysis + dish recommendation agent

---

## Step 1: Search Patterns (Research Summary)

### 1.1 Major Multi-Agent Frameworks (2026)

| Framework | Orchestration Model | Strength | Weakness |
|-----------|-------------------|----------|----------|
| LangGraph | Directed graph (DAG) with conditional edges | Fine-grained control, checkpointing, time-travel | Steep learning curve |
| CrewAI | Role-based crews with process types | Intuitive team metaphor, fast prototyping | Limited state management at scale |
| AutoGen/AG2 | Event-driven GroupChat with selector | Iterative refinement, code execution | Complex config for simple cases |

**Production pattern**: Model tiering — cheap/fast models (Haiku) for routing, capable models (Sonnet/Opus) for reasoning.

### 1.2 Claude Code Three-Level Execution

| Level | Mechanism | Communication | Use Case |
|-------|-----------|---------------|----------|
| Sub-agent (Agent tool) | Isolated context, no shared state | Return value only | Single focused task |
| Coordinator | Spawns multiple sub-agents | Aggregates results | Parallel independent tasks |
| Agent Teams | Persistent sessions with mailboxes | File-based peer-to-peer messaging | Complex multi-step collaboration |

Teams use filesystem as coordination substrate: `~/.claude/teams/{name}/` with per-agent inbox files and shared task lists.

### 1.3 Failure Cases and Anti-Patterns

| Incident | Root Cause | Cost | Lesson |
|----------|-----------|------|--------|
| $47,000 recursive loop (2025) | Two agents talking non-stop for 11 days, no circuit breaker | $47,000 API bill | Budget ceilings are mandatory |
| "Politeness loops" | Agents confirming each other without progress | Variable | Mechanical loop detection, not self-report |
| Database deletion incidents | Agents operating without governance or stop conditions | Data loss | Human approval for destructive operations |
| "17x error trap" | Bag-of-agents approach multiplies errors | Quality degradation | Coordination overhead > task complexity = net negative |

**Key 2026 consensus**: Never ask an agent "are you in a loop?" — use mechanical detection (counters, state hash comparison, timeouts).

### Sources

- [Best Multi-Agent Frameworks in 2026](https://gurusup.com/blog/best-multi-agent-frameworks-2026)
- [CrewAI vs LangGraph vs AutoGen (DataCamp)](https://www.datacamp.com/tutorial/crewai-vs-langgraph-vs-autogen)
- [Claude Code Agent Teams Docs](https://code.claude.com/docs/en/agent-teams)
- [Reverse-Engineering Claude Code Agent Teams](https://dev.to/nwyin/reverse-engineering-claude-code-agent-teams-architecture-and-protocol-o49)
- [$47,000 AI Agent Failure (Tech Startups)](https://techstartups.com/2025/11/14/ai-agents-horror-stories-how-a-47000-failure-exposed-the-hype-and-hidden-risks-of-multi-agent-systems/)
- [Multi-Agent Orchestration Failure Playbook 2026](https://cogentinfo.com/resources/when-ai-agents-collide-multi-agent-orchestration-failure-playbook-for-2026)
- [From 12 Agents to 1: Decision Guide](https://www.decodingai.com/p/from-12-agents-to-1-ai-agent-architecture-decision-guide)
- [Single vs Multi-Agent Systems (Galileo)](https://galileo.ai/blog/choosing-the-right-ai-agent-architecture-single-vs-multi-agent-systems)
- [Choosing Multi-Agent Architecture (LangChain)](https://blog.langchain.com/choosing-the-right-multi-agent-architecture/)

---

## Step 2: Analyze Collaboration

### 2.1 Does Menu Snap Actually NEED Multiple Agents?

**Answer: NO. A single agent with multiple tools is the correct architecture.**

Rationale:

| Capability | Can Single Agent Handle? | Why |
|-----------|------------------------|-----|
| Menu photo analysis (Vision API) | YES | Single tool call to vision model, returns structured data |
| Dish recommendation | YES | LLM reasoning over extracted menu + preferences — core LLM capability |
| Allergy checking | YES | Rule-based lookup against known allergen database — a tool, not an agent |
| Past order memory | YES | RAG/database query — a tool, not an agent |

**The critical test**: Do any two capabilities need to *negotiate*, *disagree*, or *independently explore* to produce a result? **No.** The data flows in a clear pipeline:

```
Photo → [Vision Tool] → Menu Items → [Preference + Allergy Filter] → Recommendations → [Memory Tool] → Personalized Output
```

This is a **sequential pipeline of tool calls**, not a collaboration between autonomous entities.

### 2.2 Why Multi-Agent Would Be WRONG Here

| Multi-Agent Cost | Impact on Menu Snap |
|-----------------|-------------------|
| Communication overhead | Agents serializing/deserializing menu data to talk to each other — pointless when one agent already has it in context |
| Coordination complexity | Need orchestrator to manage vision-agent → recommender-agent handoff for a simple pipeline |
| Debugging difficulty | "Why did it recommend peanut dish to allergic user?" — now you have to trace across agent boundaries |
| Cost multiplication | 3-4x token usage for passing context between agents vs single agent with tools |
| Latency | Inter-agent communication adds 2-5s per hop |

**Industry consensus confirms this**: "Start simple. Build with a single agent first, validate your use case, and only introduce multi-agent complexity when you have clear evidence that specialization will improve your outcomes." (Dataiku, LangChain, Galileo all agree)

### 2.3 When WOULD Menu Snap Need Multi-Agent?

Multi-agent becomes justified only if Menu Snap scales to:
- **Multi-restaurant concurrent ordering** (parallel fan-out to different restaurant APIs)
- **Real-time inventory checking** with restaurant POS systems (separate agent per restaurant integration)
- **Group ordering coordination** (each person's agent negotiates shared dishes)

Current scope (single user, single menu photo) does not justify this.

### 2.4 Chosen Architecture: Single Agent + Tool Suite

| Component | Implementation | Model Tier |
|-----------|---------------|------------|
| **Core Agent** | Single LLM agent with tool-use | Tier 1 (Sonnet 4.6 / GPT-5.4.5) |
| **Vision Tool** | API call to vision model for menu OCR | Tier 1 (vision-capable model) |
| **Allergy Checker Tool** | Deterministic lookup against allergen DB | No LLM (rule-based) |
| **Preference Matcher Tool** | Scoring function: menu items × user preferences | Tier 3 (Haiku) or rule-based |
| **Memory Tool** | Vector DB query for past orders + preferences | No LLM (retrieval only) |
| **Output Formatter** | Structured response with recommendations | Part of Core Agent |

---

## Step 3: Derive Isolation (Single-Agent Tool Architecture)

Since multi-agent is NOT recommended, this section defines the tool isolation and budget controls for the single-agent architecture.

### 3.1 Tool Isolation Boundaries

| Tool | File Access | Network Access | Can Modify State? |
|------|------------|---------------|------------------|
| Vision Tool | Read: uploaded photo only | Vision API endpoint | No |
| Allergy Checker | Read: allergen database | None | No |
| Preference Matcher | Read: user profile, menu items | None | No |
| Memory Tool | Read/Write: user order history | Vector DB | Yes (append-only) |
| Output Formatter | None | None | No |

**Principle**: Only Memory Tool can write state. All others are pure functions (read-only, no side effects).

### 3.2 Budget Ceilings (Specific Numbers)

| Resource | Ceiling | Circuit Breaker |
|----------|---------|----------------|
| Vision API calls per request | 2 (original + retry) | Hard stop after 2 |
| LLM tokens per recommendation session | 8,000 input + 2,000 output | Truncate menu if input > 8K |
| Total API cost per request | $0.05 USD | Abort if cost tracking exceeds |
| Memory queries per session | 5 | Return "no history" after 5 |
| End-to-end latency | 10 seconds | Timeout → return partial results |
| Monthly per-user budget | $5.00 USD | Disable agent, notify user |

**Total budget formula**:
```
Cost per request = Vision($0.01) + LLM($0.03) + Memory($0.005) + Buffer(20%) = ~$0.054
Monthly estimate (100 requests/user) = $5.40/user
```

### 3.3 Lifecycle Management

| Phase | Behavior |
|-------|---------|
| **Startup** | On-demand per user request (no always-on agent) |
| **Execution** | Sequential tool pipeline: Vision → Filter → Recommend → Memory |
| **Shutdown** | After response delivered, session ends. No persistent agent process. |
| **Crash Recovery** | Stateless pipeline — retry from beginning. Only risk: duplicate Memory write (idempotent append with request ID) |

### 3.4 Loop Detection (Mechanical)

Even in single-agent, the LLM could loop on tool calls:

| Mechanism | Implementation |
|-----------|---------------|
| **Tool call counter** | Max 8 tool calls per session. Hard stop at 8. |
| **Same-tool repeat detector** | If same tool called 3x with same parameters → abort |
| **State hash comparison** | Hash agent's working memory after each tool call. 2 identical hashes → loop detected |
| **Wall-clock timeout** | 30 second total session timeout |

**Detection → Action**: Loop detected → immediately return best partial result + log incident for review. Never ask the agent "are you stuck?"

---

## Step 4: Architecture Diagram

See: `architecture.d2` → compiled to `architecture.svg`

## Step 5: Final Report

See: `report.typ` → compiled to `report.pdf`
