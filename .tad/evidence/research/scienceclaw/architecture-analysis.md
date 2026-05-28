# ScienceClaw Architecture Analysis

> Phase 1 of Academic Research Pack Epic
> Source: https://github.com/beita6969/ScienceClaw (cloned to /tmp/scienceclaw-study)
> Total files: 8,812 | Skill directories: 285 | Analysis date: 2026-05-28

---

## 1. Skills System

### 1.1 SKILL.md Structure

Every skill is a directory under `skills/` containing a required `SKILL.md` file:

```
skills/{skill-name}/
├── SKILL.md          (required — YAML frontmatter + markdown body)
├── scripts/          (optional — executable Python/Bash)
├── references/       (optional — reference docs loaded on demand)
└── assets/           (optional — templates, images used in output)
```

**Frontmatter contract** (from `skills/skill-creator/SKILL.md` lines 56-68):
- `name:` (required) — skill identifier
- `description:` (required) — triggering mechanism; determines when the skill activates
- `metadata:` (optional) — e.g., `{ "openclaw": { "emoji": "🔬" } }`

**Progressive disclosure** (3-level loading from `skills/skill-creator/SKILL.md` lines 115-120):
1. **Metadata** (~100 words) — always in context
2. **SKILL.md body** (<5k words) — loaded when skill triggers
3. **Bundled resources** — loaded on demand by the agent

This is **identical** to Claude Code's SKILL.md format (name + description frontmatter, markdown body).

### 1.2 Skill Generation — skill-creator

Source: `skills/skill-creator/SKILL.md` (374 lines)

The skill-creator is itself a skill that guides the agent through a 6-step creation process:
1. **Understand** — gather concrete usage examples from user
2. **Plan** — identify scripts, references, assets needed
3. **Initialize** — run `scripts/init_skill.py` to generate template
4. **Edit** — implement resources and write SKILL.md
5. **Package** — run `scripts/package_skill.py` (validates + creates .skill zip)
6. **Iterate** — refine based on real usage

Key insight: skill creation is **agent-guided, human-confirmed** — the agent proposes, the human validates. This maps naturally to TAD's Alex→Blake pattern.

### 1.3 Skill Discovery — find-skills

Source: `skills/find-skills/SKILL.md` (134 lines)

Uses `npx skills` CLI to search an open ecosystem:
- `npx skills find [query]` — search by keyword
- `npx skills add <owner/repo@skill>` — install from GitHub
- Browse at: https://skills.sh/

This is a **package manager** model — skills are installable from external repositories. TAD does not have an equivalent (skills are project-local).

### 1.4 Skill Evolution — VOYAGER Pattern

Source: `skills/skill-evolution/SKILL.md` (178 lines)

Tracks skill effectiveness using patterns inspired by VOYAGER (Wang et al., 2023):
- Stores reusable research patterns as JSON with success_rate, quality_score, times_used
- Patterns are stored/queried via HTTP API on the `science-evolution` extension (`~/.openclaw/science-evolution.db`)
- Post-session analysis: after 5+ uses, proposes improvements
- Cross-domain knowledge transfer: patterns that work in domain A evaluated for domain B

**Runtime dependency**: Requires `science-evolution` extension running on port 18789. This is **tightly coupled** to the OpenClaw runtime.

### 1.5 Skills Runtime Loading

Source: `src/agents/skills/` (18 files)

Key files:
- `frontmatter.ts` — parses YAML frontmatter from SKILL.md
- `filter.ts` — filters skills by configuration
- `plugin-skills.ts` — loads skills registered by plugins
- `refresh.ts` — refreshes skill metadata
- `bundled-context.ts` — manages bundled skill content
- `serialize.ts` — serializes skill data for model context

Skills are loaded into agent context via the `src/context-engine/` pipeline. The loading process:
1. Agent config declares skill sources (directories, plugins)
2. `filter.ts` applies user-configured skill filters
3. `frontmatter.ts` extracts name + description for metadata layer
4. Context engine assembles skill metadata into system prompt
5. On skill trigger, full SKILL.md body is loaded

---

## 2. Memory System

### 2.1 Architecture Overview

Three layers:

| Layer | Location | Role |
|-------|----------|------|
| memory-core plugin | `extensions/memory-core/index.ts` (38 lines) | Registers memory_search + memory_get tools; registers `memory` CLI |
| Memory Manager | `src/memory/manager.ts` (100+ lines) + 96 TypeScript files in `src/memory/` | SQLite-backed indexing with hybrid search (BM25 + vector) |
| memory-lancedb plugin | `extensions/memory-lancedb/index.ts` (580+ lines) | LanceDB vector store for long-term semantic search |

### 2.2 Core Memory (File-backed)

Source: `src/memory/manager.ts`, `src/memory/memory-schema.ts`

**Storage**: SQLite database with three main tables (from `src/memory/memory-schema.ts` lines 9-50):
- `files` — tracked file paths with hash, mtime, size, source
- `chunks` — text chunks with embeddings: id, path, start_line, end_line, text, embedding, model
- `embedding_cache` — cached embeddings by provider/model/hash

**Search**: Hybrid approach (from `src/memory/manager.ts` lines 20-22):
- `chunks_vec` — vector similarity search
- `chunks_fts` — FTS5 full-text search (BM25 ranking)
- `mergeHybridResults()` — combines BM25 + vector scores

**Embedding providers** (from `src/memory/manager.ts` lines 68-76):
- OpenAI, Gemini, Voyage, Mistral, Ollama, "auto" (fallback chain)
- Batch processing with concurrency control and failure limits

### 2.3 LanceDB Extension (Vector Store)

Source: `extensions/memory-lancedb/index.ts`

- Uses `@lancedb/lancedb` for vector storage
- OpenAI embeddings by default (configurable model + dimensions)
- Memory entries: id, text, vector, importance, category, createdAt
- Categories: defined in `extensions/memory-lancedb/config.ts` (MEMORY_CATEGORIES constant)
- Auto-recall + auto-capture via lifecycle hooks

**Tight coupling**: LanceDB requires the OpenClaw plugin API (`openclaw/plugin-sdk/memory-lancedb`), OpenAI API key, and the plugin lifecycle. This cannot be trivially extracted.

### 2.4 Memory Flow

```
User message → Agent processes → Memory auto-capture (importance scoring)
                                      ↓
                              memory-lancedb stores entry
                                      ↓
Next session → Agent query → memory_search tool
                                      ↓
                              Hybrid search: BM25 + vector → ranked results
```

---

## 3. Database Integration

### 3.1 MCP Servers

Two MCP servers found in `mcp-servers/`:

**arxiv-latex-mcp** (`mcp-servers/arxiv-latex-mcp/`):
- Python-based (pyproject.toml + uv.lock)
- Provides arXiv search and LaTeX processing tools

**chembl-mcp** (`mcp-servers/chembl-mcp/`):
- `chembl_search.py` + `chembl_server.py`
- Queries ChEMBL API for drug-target interactions
- Pure Python with requirements.txt

### 3.2 API-based Database Access (Primary Pattern)

Most database access is done through **curl-based API calls within skill SKILL.md files** — NOT through MCP servers. This is the dominant pattern.

Examples from skills:
- `skills/semantic-scholar/SKILL.md`: `curl` to Semantic Scholar Graph API
- `skills/openalex-database/SKILL.md`: `curl` to OpenAlex REST API
- `skills/pubmed-search/SKILL.md`: `curl` to NCBI E-utilities
- `skills/uniprot-protein/SKILL.md`: `curl` to UniProt REST API
- `skills/chembl-drug/SKILL.md`: `curl` to ChEMBL REST API
- `skills/world-bank-data/SKILL.md`: `curl` to World Bank Indicators API

**Key insight**: Database access is **skill-level, not infrastructure-level**. Each skill contains its own API call templates. This makes skills highly portable — they just need `curl` and `python3`.

### 3.3 Database-Specific Details

| Database | API | Auth | Rate Limit | Skill(s) |
|----------|-----|------|-----------|----------|
| Semantic Scholar | REST (api.semanticscholar.org) | Free (API key optional for higher limits) | 100 req/5min free | semantic-scholar |
| OpenAlex | REST (api.openalex.org) | Free (mailto for polite pool) | No strict limit | openalex-database, openalex-search |
| PubMed/NCBI | E-utilities | Free (API key for higher limits) | 3 req/s without key, 10/s with key | pubmed-search, pubmed-database, ncbi-entrez |
| arXiv | Atom API | Free | 1 req/3s | arxiv-search, arxiv-database |
| Google Scholar | NO official API | SerpAPI ($50/mo) or WebSearch | — | via web_search fallback |
| ChEMBL | REST | Free | Not documented | chembl-drug, chembl-database |
| UniProt | REST | Free | Polite usage | uniprot-protein, uniprot-database |
| ClinicalTrials.gov | API v2 | Free | Not documented | clinicaltrials-database |
| PDB/RCSB | REST | Free | Not documented | pdb-database, pdb-structure |
| World Bank | REST (Indicators API) | Free | Not documented | world-bank-data |

---

## 4. SCIENCE.md Protocol

Source: `SCIENCE.md` (300+ lines at root)

### 4.1 Identity and Scope

SCIENCE.md is ScienceClaw's **master identity document** — equivalent to CLAUDE.md in Claude Code or AGENTS.md in Codex. It defines:

- **Identity**: "You are ScienceCLAW, an AI research colleague built for scientific discovery across all academic disciplines"
- **Scope**: Natural sciences, social sciences, and humanities — NOT general-purpose assistance
- **Capabilities list**: Search 1000+ databases, execute analysis code, generate publication figures, write reports with real citations

### 4.2 Zero-Hallucination Rule

From `SCIENCE.md` lines 51-68 — the **highest priority rule**:
- NEVER fabricate citations, DOIs, PMIDs, author names, journal names, years, impact factors
- ALL citations must come from tool results in the CURRENT conversation
- Self-check before every response: does every title/DOI/author/citation count come from a tool result?

This maps to TAD's "evidence-based verification" principle.

### 4.3 Research Depth Enforcement

From `SCIENCE.md` lines 70-132 — mandatory 6-phase research protocol:

| Phase | Required For | Key Actions |
|-------|-------------|-------------|
| 1. Discovery | All tasks | Search ≥2 databases, read abstracts of top 10-20 |
| 2. Deep Reading | Non-trivial | Full text of 2-3 key papers via Jina Reader |
| 3. Citation Chain | Required | Forward + backward citations for 2-3 papers |
| 4. Cross-Verification | When applicable | Database-specific queries (UniProt, ChEMBL, etc.) |
| 5. Synthesis | Required | Consensus, contradictions, gaps, quantification |
| 6. Report Writing | Required | Structured report with methodology section |

**Minimum tool call thresholds** (from depth calibration table):
- Quick question: 3-5 tool calls
- Literature survey: 20-40
- Comprehensive review: 40-80
- Systematic review: 80+

### 4.4 Anti-Premature-Conclusion Rules

10 explicit rules (from lines 124-133) including:
- Never conclude after single search
- Never present results without reading ≥1 full-text paper
- Never skip citation chains
- Before concluding, count tool calls against threshold

### 4.5 Error Recovery

Fallback chains per data source (from lines 143-153):
| Primary | Fallback 1 | Fallback 2 | Last Resort |
|---------|-----------|-----------|-------------|
| OpenAlex | Semantic Scholar | Google Scholar | arXiv |
| Europe PMC | OpenAlex (bio filter) | Semantic Scholar | CrossRef DOI |
| UniProt | NCBI Gene/Protein | Ensembl | STRING |

---

## 5. Hook System

Source: `src/hooks/` (15+ files)

### 5.1 Hook Types

- `frontmatter.ts` / `frontmatter.test.ts` — YAML frontmatter parsing for skills
- `config.ts` — hook configuration
- `fire-and-forget.ts` — non-blocking hook execution
- `bundled-dir.ts` — bundled resource directory management
- `gmail-*.ts` — Gmail-specific hooks (watcher, lifecycle, ops, setup)

### 5.2 Architecture

Hooks are event-driven lifecycle callbacks in the OpenClaw runtime. They operate at the **infrastructure level**, not at the skill level. Skills don't define their own hooks — they interact through the SKILL.md interface.

The hook system is **tightly coupled** to the OpenClaw runtime (imports from `../channels/`, `../config/`, etc.).

---

## 6. Plugin/Extension System

Source: `src/plugin-sdk/index.ts` (80+ lines of exports), `extensions/` (40+ directories)

### 6.1 Plugin SDK Contract

The plugin SDK (`src/plugin-sdk/`) exports a massive interface focused on **channel/messaging integration**:
- Channel adapters: auth, messaging, threading, gateway, pairing, setup, status
- Channel types: direct, group, channel (Discord/Slack/Telegram/etc.)
- ACP (Agent Communication Protocol) for subagent management
- Memory tool factories: createMemorySearchTool, createMemoryGetTool

The plugin SDK is **NOT relevant to skills** — it's the infrastructure layer for multi-platform deployment.

### 6.2 Extensions

40+ extensions in `extensions/`:
- **Memory**: memory-core, memory-lancedb
- **Messaging channels**: discord, slack, bluebubbles (iMessage), imessage, line, matrix, mattermost, feishu, googlechat, irc, telegram (not in listing but likely), wechat (not in listing)
- **AI integrations**: copilot-proxy, google-gemini-cli-auth
- **Utilities**: diffs, diagnostics-otel, device-pair

### 6.3 Extension Registration

From `extensions/memory-core/index.ts` — a plugin registers via `api.registerTool()` and `api.registerCli()`:
```typescript
const memoryCorePlugin = {
  id: "memory-core",
  name: "Memory (Core)",
  register(api: OpenClawPluginApi) {
    api.registerTool(/* tool factory */);
    api.registerCli(/* CLI handler */);
  },
};
```

---

## 7. Agent Runtime + Context Engine

### 7.1 Context Engine

Source: `src/context-engine/` (6 files)

**Pluggable architecture** (from `src/context-engine/registry.ts`):
- Factory pattern: `registerContextEngine(id, factory)` → `resolveContextEngine(config)`
- Resolution: config slot override → default ("legacy")
- Process-global registry via Symbol.for (handles duplicate dist chunks)

**ContextEngine interface** (from `src/context-engine/types.ts` lines 68-168):
- `bootstrap(sessionId)` — initialize session state
- `ingest(sessionId, message)` — ingest single message
- `assemble(sessionId, messages, tokenBudget)` — build model context
- `compact(sessionId, tokenBudget)` — reduce token usage
- `prepareSubagentSpawn()` — prepare child agent context
- `dispose()` — cleanup

**Legacy engine** (from `src/context-engine/legacy.ts`):
- Default fallback — pass-through for ingest/assemble, delegates compact to `compactEmbeddedPiSessionDirect`
- Preserves 100% backward compatibility with existing compaction behavior

### 7.2 Routing System

Source: `src/routing/resolve-route.ts` (805 lines), `src/routing/session-key.ts` (254 lines)

**Multi-tier binding resolution** (from resolve-route.ts lines 723-781):
1. binding.peer (exact peer match)
2. binding.peer.parent (thread parent inheritance)
3. binding.guild+roles (Discord guild with role-based routing)
4. binding.guild (Discord guild without roles)
5. binding.team (Slack team)
6. binding.account (account-scoped)
7. binding.channel (channel-wide)
8. default (fallback)

**Session key format**: `agent:{agentId}:{channel}:{peerKind}:{peerId}`

This is entirely an **infrastructure concern** for multi-platform deployment. Not relevant to skill content.

### 7.3 Agent Scope

Source: `src/agents/agent-scope.ts` (80+ lines)

- Multi-agent: config declares agent list with id, model, skills, workspace
- Agent resolution: `resolveDefaultAgentId(cfg)` → first default=true agent or first entry
- Skills are loaded per-agent via `agents/skills/filter.ts`

**537 files in `src/agents/`** — covers:
- ACP (Agent Communication Protocol) for subagent spawning
- Skill installation (download, extract, fallback)
- Agent paths, workspace, configuration
- Embedded runner (pi-embedded-runner) for model execution

---

## 8. Runtime Coupling Assessment

### 8.1 Coupling Matrix

| Subsystem | Coupling to OpenClaw Runtime | Migration Feasibility |
|-----------|------------------------------|----------------------|
| **Skills (SKILL.md files)** | **LOOSELY coupled** — 0 skills reference plugin-sdk or context-engine; 37/285 mention "memory" (text reference, not import) | **HIGH** — can be extracted as standalone SKILL.md files |
| **SCIENCE.md protocol** | **LOOSELY coupled** — plain markdown, no runtime imports | **HIGH** — direct port as CLAUDE.md / SKILL.md content |
| **Skill-creator** | **LOOSELY coupled** — creation process is agent-guided text | **HIGH** — adapt to TAD's alex→handoff→blake pattern |
| **Database APIs (curl-based)** | **LOOSELY coupled** — skills use `curl` + `python3`, no runtime deps | **HIGH** — copy skill content as-is into TAD pack |
| **Context Engine** | **TIGHTLY coupled** — pluggable but deeply integrated into agent runtime | **LOW** — TAD uses Claude Code's native compaction |
| **Memory System** | **TIGHTLY coupled** — 96 TypeScript files, SQLite schema, embedding providers | **LOW** — TAD uses project-knowledge + evidence files |
| **Routing** | **TIGHTLY coupled** — multi-channel binding system | **NOT APPLICABLE** — TAD is single-user CLI |
| **Plugin SDK** | **TIGHTLY coupled** — channel adapters for messaging platforms | **NOT APPLICABLE** — TAD has no messaging channels |
| **Hook System** | **TIGHTLY coupled** — OpenClaw runtime lifecycle hooks | **LOW** — TAD has its own hook system |
| **Skill Evolution** | **MEDIUM coupled** — requires science-evolution extension + HTTP API | **MEDIUM** — concept maps to TAD's *optimize/*evolve, but implementation requires adaptation |
| **MCP Servers** | **LOOSELY coupled** — standalone Python services | **HIGH** — can run independently of OpenClaw |

### 8.2 Key Architectural Insight

ScienceClaw's architecture has a **clean separation** between:
1. **Skill content** (285 SKILL.md files) — PORTABLE; these are the value
2. **Runtime infrastructure** (context engine, routing, plugins, memory) — NOT PORTABLE; these are OpenClaw-specific

The migration strategy should focus on extracting skill content and SCIENCE.md protocols, NOT on porting runtime infrastructure. TAD already has equivalent infrastructure (Claude Code runtime, project-knowledge for memory, gates for quality).

### 8.3 Cross-Skill Coupling Analysis

From runtime dependency scan across all 285 skills:
- **0 skills** reference `plugin-sdk` or `context-engine`
- **37 skills** mention `memory` (text references to memory concepts, not code imports)
- **3 skills** reference `mcp` (cite MCP server names in documentation)
- **2 skills** reference `skill-evolution` (research-reflection, skill-evolution itself)
- **8 skills** reference `skills/` paths (cross-skill citations in documentation)

**Conclusion**: Skills are **self-contained knowledge units**. Cross-skill coupling is documentation-level (citations), not code-level (imports). This is the best-case scenario for migration.
