# D3: Context and Memory Architecture

**Decision**: How should the agent store, retrieve, and invalidate memory?

This is the most nuanced architectural decision. The wrong pattern fails silently — agents with stale memory produce confidently wrong answers with no error signal.

---

## Selection Matrix: 5 Memory Patterns

| Pattern | Accuracy | Latency | Cost | When RIGHT | When WRONG |
|---------|----------|---------|------|------------|------------|
| 1. In-context only | 72.9% | 17.12s p95 | Low | Stateless tasks, prototypes, strict privacy requirements | Multi-session continuity, cost-sensitive at scale |
| 2. Flat vector store | ~90% token reduction vs in-context | 1.44s retrieval | Medium | Multi-session conversational, user personalization | Multi-hop reasoning, temporal queries, entity relationships |
| 3. Tiered (hot/warm/cold) | Session coherence | Medium | Medium-High | Session coherence + long-horizon continuity under token constraints | Simple prototypes, teams without infra skills |
| 4. Knowledge graph + vector | Multi-hop capable | Medium-High | High | Entity relationships, temporal validity, multi-agent attribution | Cold-start domains, rapidly evolving schemas |
| 5. Enterprise context layer | Governance-grade | High | Very High | Regulated industries, governed metadata already exists | No existing data catalog, teams <50 people |

**Rule**: Start with Pattern 1, upgrade only when you can name the specific failure mode Pattern 1 causes. [Claude Code #3]

---

## Pattern 1: In-Context Only

The agent receives all relevant context in the system prompt or conversation turn. No external storage.

**Selection criteria**:
- Single-session stateless tasks (no continuity needed across conversations)
- Privacy-sensitive environments where external storage is prohibited
- Prototypes where latency and cost are unknown
- Tasks where 72.9% accuracy is sufficient

**The failure mode this causes** → Production Disaster #4 (stale state propagation): if the context doesn't include recent state, the agent reasons on outdated information with no error signal.

**What Claude Code actually does** [Source: Claude Code #8]:
- Memory stored in flat files (CLAUDE.md, project-knowledge/)
- LLM scans headers, selects up to 5 relevant files per turn
- No vector DB — the model IS the retrieval system via header-guided selection
- Why: vector DBs add infrastructure complexity; file headers are sufficient for the codebase navigation problem

---

## Pattern 2: Flat Vector Store

Embed memory chunks into a vector store. Retrieve by semantic similarity at query time.

**Selection criteria**:
- Multi-session conversational agents (e.g., customer support, personal assistants)
- User personalization that must survive across sessions
- Search query is well-defined (single-hop)

**When it breaks** [Source: research finding #4]:
- Multi-hop queries ("Find projects where [user A] and [user B] both contributed after [date X]") require semantic similarity on all three constraints — flat vector stores retrieve the most similar single chunk, not the multi-condition intersection
- Temporal queries where facts have validity windows — expired facts return as confidently as fresh ones
- High staleness rate environments: if memory update rate > retrieval accuracy, stale retrieval is worse than no memory

**Critical rule**: If using vector store, implement JIT invalidation [Source: research finding #16]. Stale memory > no memory — an agent confidently acting on month-old information causes worse outcomes than an agent that says "I don't have context on that."

---

## Pattern 3: Tiered Memory (Hot / Warm / Cold)

Memory is stratified by recency and access frequency:
- **Hot** (in-context): current session state, active task variables
- **Warm** (fast retrieval): recent conversations, session summaries, recently used knowledge
- **Cold** (archived): historical context, infrequent knowledge, compressed summaries

**Selection criteria**:
- Session coherence is required (agent must remember what happened 10 turns ago)
- Long-horizon continuity (multi-day or multi-week task execution)
- Token budget is constrained (can't keep full history in context)

**Implementation pattern** [Source: research, mirrors human memory consolidation]:
1. Working memory (in-context): current turn, active tool results, last 5 exchanges
2. Episodic buffer (fast cache): last 50 turns, searchable by session ID
3. Semantic store (vector): distilled knowledge from closed sessions
4. Archival (cold): raw logs for audit, not retrieved during operation

---

## Pattern 4: Knowledge Graph + Vector

Entities (people, projects, events) as graph nodes with typed relationships. Vector store for semantic similarity. Graph traversal for multi-hop queries.

**Selection criteria**:
- Agent must reason about entity relationships (not just content similarity)
- Multi-hop queries are frequent ("users who worked on projects that depend on library X")
- Temporal validity matters (relationships have start/end dates)
- Multi-agent attribution needed (which agent recorded which fact)

**The infrastructure cost**: Graph schema design is load-bearing. Schema changes require migration. Cold-start domains (no existing entity model) require 2-4 weeks of schema design before the first useful query.

---

## Pattern 5: Enterprise Context Layer

Metadata governance layer on top of existing enterprise data catalogs (data lineage, access controls, organizational hierarchy).

**Selection criteria**:
- Regulated industries (finance, healthcare, legal) where data provenance must be auditable
- Organization already has a governed data catalog (Collibra, Alation, etc.)
- Agent decisions must be traceable to specific governed data assets

**Not applicable if**: no existing catalog exists. Building a catalog from scratch to serve an agent is a 6-18 month infrastructure project, not an agent architecture decision.

---

## Hermes Memory Routing Rules [Source: Hermes #2, #3]

Hermes enforces strict separation between memory types at the routing layer:

```
Facts (declarative) → memory backend
Procedures (how to do X) → skills/tools
Temporary state (current session only) → session history
```

**NEVER**: store temporary state in the memory backend. If an agent stores "current task step = 3" in permanent memory, every future session inherits corrupted state.

**Single-active memory backend** [Source: Hermes #2]: Hermes supports 8 swappable backends but enforces exactly 1 active at a time. Multiple active backends create conflicting truth sources — the agent receives different facts depending on which backend responds first.

---

## Critical Rule: JIT Invalidation [Source: research finding #16]

Before using any cross-session memory, the agent MUST check validity:
1. Is this memory older than the staleness threshold for this domain?
2. Has any dependent fact changed since this memory was stored?
3. Is there a more recent source for this information?

**Rule**: Stale memory > no memory is FALSE for high-change domains. In domains where facts change daily (stock prices, user preferences, system state), an agent acting on month-old memory causes worse outcomes than an agent with no memory. Implement domain-specific TTLs.

---

## Cross-Reference

- **What to do when context fills up**: see D6 (context-compression.md)
- **Tool output storage decisions**: see D4 (tool-management.md)
- **Permission scoping for memory backends**: see D5 (permissions-safety.md)
- **Cost of keeping memory in context vs external store**: see D7 (cost-token-economics.md)
- **Disasters this decision prevents**: see D10 (production-disasters.md), Incident #4 (stale state propagation)
