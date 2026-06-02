# Knowledge Layering Research — Deep Findings for TAD Project-Knowledge Redesign
> Date: 2026-06-02
> Notebook: tad-evolution-research (37cfefa5)
> Method: 2 rounds NotebookLM cross-source ask + 4 WebSearch queries
> Purpose: Pre-research for TAD project-knowledge layering Epic

---

## Research Question
How should TAD separate permanent methodology rules, reusable patterns, and one-time incident evidence — so that the knowledge system stays coherent as a "-ology" instead of decaying into a historical dump?

---

## Key Finding 1: Three-Layer Physical Separation Is the Industry Consensus

Every framework studied (CoALA, GitAgent, DiffMem, Mem0, Anthropic Dreaming) physically separates knowledge layers into different files/directories, NOT different sections of the same file.

| Framework | Layer 1 (Principles) | Layer 2 (Patterns) | Layer 3 (Incidents) |
|-----------|---------------------|--------------------|--------------------|
| **CoALA** | Semantic memory (facts/rules) | Procedural memory (skills/how-to) | Episodic memory (what happened) |
| **GitAgent** | `RULES.md` + `SOUL.md` (root files) | `skills/` directory | `memory/runtime/` + runtime branches |
| **DiffMem** | Current state files (surface) | Current state files (surface) | Git commit graph (depth) |
| **Mem0** | `org_id` scope | `agent_id` scope | `session_id` scope |
| **Anthropic Dreaming** | Organization store (read-only) | Project store (human-approved) | Working store (session logs, mutable) |

**TAD current state**: ALL three layers mixed in `.tad/project-knowledge/architecture.md` as `### Title - Date` entries under `## Accumulated Learnings`. No physical separation.

---

## Key Finding 2: Knowledge Graduation Needs a Human Gate

All production systems that promote knowledge (incident → pattern → principle) require a human-in-the-loop gate at the promotion boundary:

- **Anthropic Dreaming**: Dream job extracts candidates → human reviews before promoting to project/org store
- **GitAgent**: Agent opens a branch + PR → human merges into mainline skills
- **TAD's existing `*dream`**: Already does this (candidates → human review → promote). But only for dedup/merge, not for layer classification.

**Key insight**: TAD's `*dream` is already the right mechanism — it just needs to classify entries INTO layers during the review step, not just merge them within the same flat file.

---

## Key Finding 3: Token Efficiency Requires Layer-Specific Loading Strategy

| Layer | Loading Strategy | Token Budget |
|-------|-----------------|-------------|
| **Principles** | Always loaded (system prompt / CLAUDE.md @import) | ~2-3KB (small, stable set) |
| **Patterns** | Progressive disclosure: index at startup, full content on-demand via tool | ~50 tokens per pattern title; full load only when matched |
| **Incidents** | Never pre-loaded. Retrieved on-demand via knowledge-blame.sh / git tools | 0 tokens at startup; ~200 tokens per blame query |

**TAD current**: All 60+ entries loaded at every session via `@import .tad/project-knowledge/architecture.md`. Conservative estimate: 30-50KB of knowledge loaded into every Blake session, of which ~5KB is relevant.

**Projected savings**: With layering, a typical Blake session would load ~3KB principles + ~1KB matched patterns + 0KB incidents (blame on demand) = **~4KB instead of ~40KB = 90% reduction**.

---

## Key Finding 4: Prediction-Error-Driven Consolidation Is the Frontier

Mem0's 2026 approach (and the D-MEM "Dopamine-Gated" paper) uses **prediction error** as the consolidation trigger: only SURPRISING information gets written to memory. Three consolidation routes:

1. **New Insert**: No overlap with existing knowledge → add as new entry
2. **Merge**: Complements existing entry → merge/strengthen
3. **Conflict**: Contradicts existing knowledge → trigger active purge of outdated fact

**TAD mapping**: Gate 4 Knowledge Assessment currently writes EVERYTHING discovered. If it used prediction-error filtering, only genuinely surprising discoveries would be written. "tsc --noEmit should pass" is NOT surprising (standard practice) — only the FAILURE of that expectation is worth recording.

---

## Key Finding 5: Staleness Detection Needs Temporal Versioning, Not Just Path Checking

TAD's `stale-knowledge-check.sh` checks if "Grounded in" file paths still exist. But **content staleness** (the rule was true 3 months ago but architecture changed) is the harder problem.

Approaches from the literature:
- **DiffMem**: "Smart forgetting" — lower retrieval weight of old entries, archive to git branches
- **Mem0**: Temporal reasoning — prefer newest record when conflict detected
- **A-MEM**: Retroactive update — when new observation contradicts old memory, LLM rewrites the old entry
- **All**: Explicit versioning with `last_verified` dates

**TAD's existing partial solution**: architecture.md entries have `Revalidated: YYYY-MM-DD` dates (added for stale-knowledge-check.sh). This is the right primitive but needs to be enforced (most entries lack this field).

---

## Proposed TAD Architecture (Research-Grounded)

### File Structure
```
.tad/project-knowledge/
├── principles.md              # Layer 1: 10-15 permanent methodology rules
│                               # Always loaded via @import
│                               # Only changed by explicit Epic-level redesign
│                               # Human-gated: *dream cannot auto-modify
│
├── patterns/                   # Layer 2: Reusable patterns (by category)
│   ├── _index.md               # Title + 1-line summary per pattern (~50 tokens each)
│   ├── shell-portability.md    # Loaded on-demand when task matches
│   ├── ac-verification.md
│   ├── gate-design.md
│   └── pack-architecture.md
│
├── incidents/                  # Layer 3: One-time evidence (supports L1/L2)
│   ├── _index.md               # Title + date + linked principle/pattern
│   └── 2026-05/                # Monthly subdirectories, auto-archived after 90 days
│       ├── dream-scanner-value-loss.md
│       └── express-handoff-4-p0.md
│
└── README.md                   # Decision rules for classification + lifecycle
```

### Lifecycle Rules
1. **New entry from Gate 4 KA**: Always enters as Layer 3 incident
2. **`*dream` scan (weekly/manual)**: Detects entries appearing in ≥2 incidents → proposes graduation to Layer 2 pattern
3. **Human review**: Decides promote to L2, keep as L3, or archive
4. **L2 → L1 promotion**: Only via explicit *analyze handoff (requires Socratic Inquiry — principles are methodology changes)
5. **L3 expiration**: Incidents >90 days whose linked L2 pattern is stable → auto-archive to `.tad/archive/knowledge/`
6. **L1 review**: Principles reviewed every major version bump (semver minor+)

### Loading Strategy
- **CLAUDE.md @import**: Only `principles.md` (always loaded, ~3KB)
- **Blake 1_5_context_refresh**: Reads `patterns/_index.md`, loads only matched pattern files
- **knowledge-blame.sh**: Queries incidents on-demand (Layer 3 never pre-loaded)

### *dream Upgrade
Current *dream: dedup + merge + prune stale refs (within same flat file)
New *dream: classify each entry → route to correct layer → propose graduations → human review

---

## Sources

### NotebookLM (tad-evolution-research, 53 sources)
- Round 1: Knowledge layering patterns across GitAgent, DiffMem, Mem0
- Round 2: Practical architecture synthesis (CoALA + Anthropic Dreaming + A-MEM)

### WebSearch
- [Mem0: AI Memory Layer Guide](https://mem0.ai/blog/ai-memory-layer-guide)
- [Mem0: State of AI Agent Memory 2026](https://mem0.ai/blog/state-of-ai-agent-memory-2026)
- [CoALA: Cognitive Architectures for Language Agents (arxiv)](https://arxiv.org/html/2309.02427v3)
- [7-Layer Memory Architecture Behind Modern AI Agents](https://dev.to/mahmoudz/the-7-layer-memory-architecture-behind-modern-ai-agents-5060)
- [Memory for Autonomous LLM Agents (arxiv 2026)](https://arxiv.org/html/2603.07670v1)
- [D-MEM: Dopamine-Gated Agentic Memory (arxiv)](https://arxiv.org/pdf/2603.14597)
- [SECI Model (Wikipedia)](https://en.wikipedia.org/wiki/SECI_model_of_knowledge_dimensions)
- [When Memory Became the Attack Surface (LLMS3)](https://llms3.com/blog/when-memory-became-the-attack-surface-may-2026)
