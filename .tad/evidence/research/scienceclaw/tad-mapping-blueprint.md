# TAD Mapping Blueprint — ScienceClaw to Academic Research Pack

> Phase 1 of Academic Research Pack Epic
> Based on: architecture-analysis.md + skill-taxonomy.md
> Analysis date: 2026-05-28

---

## Terminology Glossary

| ScienceClaw Term | TAD Equivalent | Notes |
|------------------|---------------|-------|
| SKILL.md | SKILL.md (identical format) | Both use name + description frontmatter |
| SCIENCE.md | CLAUDE.md + SKILL.md routing | Master protocol → split between project-level and pack-level |
| Reflexion Cycle | *optimize / Auto-Evolve | Skill improvement over time |
| skill-evolution | Knowledge Assessment + *dream | Pattern tracking → project-knowledge entries |
| memory-core | project-knowledge/ + evidence/ | File-based research memory |
| memory-lancedb | NotebookLM notebooks | Vector-based semantic recall |
| OpenClaw plugin | Claude Code MCP server | Different extension model |
| find-skills / clawhub | GitHub skill repos | Skill discovery ecosystem |
| skill-creator | /alex *idea → handoff → /blake | Agent-guided skill creation |
| Zero-Hallucination Rule | evidence_based_verification | Both: tool results only, no training data fabrication |
| Research Depth Enforcement | Gate quality criteria | Both: mandatory phases before "done" |
| heartbeat (3600s) | context compaction | Session persistence strategy |

---

### Decision 1: Pack Architecture Type

**Recommendation: Reference-based (thin router + judgment rules)**

**Rationale**: ScienceClaw's 285 skills are self-contained SKILL.md files with zero runtime coupling (0 skills import plugin-sdk or context-engine). The knowledge value is in the judgment rules (research phases, quality checklists, specific thresholds) — NOT in complex inter-skill state management.

**Evaluation**:

| Pattern | Fit | Why |
|---------|-----|-----|
| Reference-based | ✅ **Best fit** | Skills are independent judgment rules; references/*.md files map directly to skill content; thin router selects by research task type |
| Deep-skill (3 SKILLs + session.json) | ❌ Poor fit | No cross-skill state needed; ScienceClaw skills don't share session state |
| Orchestration-router | ❌ Over-engineered | No phase transitions between skills; each skill is independently triggered |

**Implementation sketch**:
```
academic-research/
├── SKILL.md                    (router: detect research task → load appropriate references)
├── references/
│   ├── research-protocol.md    (from SCIENCE.md: phases, zero-hallucination, depth enforcement)
│   ├── literature-search.md    (from skills/literature-search: API templates, search protocol)
│   ├── systematic-review.md    (from skills/systematic-review: PRISMA pipeline)
│   ├── database-apis.md        (from 12 P1 database skills: API endpoints, auth, rate limits)
│   ├── statistics.md           (from P1 stats skills: meta-analysis, biostatistics)
│   ├── writing.md              (from P1 writing skills: paper structure, grant aims, LaTeX)
│   ├── domain-natural.md       (from P1 domain skills: bioinformatics, chemistry, food-science)
│   ├── quality-frameworks.md   (from scholar-evaluation, peer-review: ScholarEval, GRADE)
│   └── experiment-design.md    (from P1 workflow skills: sample size, RCT, protocols)
├── scripts/
│   └── (optional: API query helpers if needed)
└── install.sh
```

---

### Decision 2: Memory Strategy

**Recommendation: TAD file-based as default (project-knowledge + evidence)**

**Evaluation on 5 axes**:

| Axis | TAD file-based | LanceDB upgrade | NotebookLM | Hybrid |
|------|---------------|----------------|------------|--------|
| Setup complexity | ✅ Zero (exists) | ❌ LanceDB install + config | ⚠️ Account needed | ❌ Both systems |
| Retrieval quality | ⚠️ Grep/keyword only | ✅ Semantic vector search | ✅ Cross-source synthesis | ✅ Best of both |
| Cross-session persistence | ✅ Git-tracked files | ✅ LanceDB on disk | ✅ Cloud-persistent | ✅ Both |
| TAD philosophy alignment | ✅ Evidence files + gates | ❌ Opaque vector store | ⚠️ External dependency | ⚠️ Complexity |
| Maintenance burden | ✅ Zero (existing infra) | ❌ DB management + API keys | ⚠️ API latency (23-43s) | ❌ Two systems to maintain |

**Decision**: TAD file-based is default. NotebookLM is already available as optional upgrade via `*research-notebook` for users who need semantic recall across sessions. No need to add a third memory system.

**Why not LanceDB**: TAD is a single-user CLI framework. LanceDB's value (multi-user, high-volume semantic search) doesn't justify the setup cost. NotebookLM already provides semantic search with zero infrastructure.

---

### Decision 3: Database Strategy

**Recommendation: curl-based API wrappers in skill references (ScienceClaw's own pattern)**

ScienceClaw's database access pattern is already the right one for Claude Code: skills contain curl templates that the agent executes. No MCP server needed for most databases.

| Database | Strategy | Auth | Rate Limit | Reference File |
|----------|----------|------|-----------|---------------|
| Semantic Scholar | curl API (primary search) | Free; API key for 100 req/s | 100 req/5min free | database-apis.md |
| OpenAlex | curl API (complementary search) | Free; mailto for polite pool | Unlimited | database-apis.md |
| PubMed/NCBI | curl E-utilities | Free; API key for 10 req/s | 3 req/s without key | database-apis.md |
| arXiv | curl Atom API | Free | 1 req/3s | database-apis.md |
| Google Scholar | WebSearch fallback | N/A | N/A | Note: no API |
| ChEMBL | curl REST or MCP server | Free | Undocumented | database-apis.md + optional mcp-servers/chembl-mcp/ |
| UniProt | curl REST | Free | Polite usage | database-apis.md |
| ClinicalTrials.gov | curl API v2 | Free | Undocumented | database-apis.md |
| RCSB PDB | curl REST | Free | Undocumented | database-apis.md |
| World Bank | curl Indicators API | Free | Undocumented | database-apis.md |
| KEGG | curl REST | Free (academic) | Undocumented | database-apis.md |
| NCBI Gene | curl E-utilities | Same as PubMed | Same as PubMed | database-apis.md |

**MCP servers**: Only arxiv-latex-mcp and chembl-mcp exist in ScienceClaw. Both are standalone Python services. Port only if complex query patterns justify the overhead; otherwise, curl templates in references/ are simpler and more portable.

---

### Decision 4: Skill Evolution Strategy

**Recommendation: (b) Proposal-based via *optimize/*evolve with research-domain adapter + human gate approval**

**Why runtime generation is incompatible**: ScienceClaw's skill-creator writes SKILL.md files at runtime. Claude Code requires SKILL.md registration in settings.json — skills must be pre-installed, not generated mid-session. Stateless sessions mean generated skills would be lost after session end.

**Options evaluated**:

| Option | Description | Feasibility | Value |
|--------|-------------|-------------|-------|
| (a) Session-scoped generation | Temporary skill for current session | ✅ Works | ⚠️ Low (lost after session) |
| **(b) Proposal-based** | *optimize detects improvement → proposes → human approves → Alex writes handoff | ✅ Works | ✅ High (TAD-aligned, persistent) |
| (c) Fixed skill library | Only Phase 3 skills, no evolution | ✅ Works | ⚠️ Medium (no improvement) |

**How (b) works in TAD**:
1. During research session, Blake notices a pattern works well (e.g., "PubMed + citation chain finds better papers than Semantic Scholar alone for biomedical topics")
2. Knowledge Assessment captures the finding in project-knowledge
3. *dream scanner detects recurring pattern across sessions
4. Alex proposes pack reference update via handoff
5. Blake implements, Gate 3/4 verify

This is exactly ScienceClaw's skill-evolution concept mapped to TAD's existing mechanisms — no new infrastructure needed.

---

### Decision 5: Alex/Blake Role Mapping

| ScienceClaw Concept | Alex (Design) | Blake (Execute) |
|---------------------|---------------|-----------------|
| Research question formulation | Alex elicits via Socratic Inquiry | — |
| Search strategy design | Alex specifies databases + queries in handoff | — |
| Search execution | — | Blake runs curl commands from database-apis.md |
| Paper analysis | — | Blake reads and extracts findings |
| Quality assessment | Alex defines criteria in handoff ACs | Blake applies ScholarEval / GRADE from quality-frameworks.md |
| Synthesis | — | Blake synthesizes across sources |
| Report writing | — | Blake writes report following writing.md rules |
| Research depth enforcement | Alex sets minimum phases + tool calls in handoff | Blake follows; Layer 1 verifies completeness |
| Zero-hallucination | AC: "every citation must trace to a tool result" | Blake self-checks; Layer 2 spec-compliance verifies |
| Quality gate | Alex defines Gate 4 business acceptance | Blake passes Gate 3 (document completeness, source grounding) |

---

### Decision 6: Session Duration & Persistence Model

**Recommendation: Multi-session with handoff checkpoints (Epic sub-phases for extended research)**

**Context**: ScienceClaw uses 3600s heartbeat timeout. Claude Code has no heartbeat — context compaction is the persistence mechanism.

**Options evaluated**:

| Option | Pros | Cons |
|--------|------|------|
| Single long session | Simple; full context at discovery time | Context overflow for comprehensive reviews (40-80 tool calls) |
| **Multi-session with checkpoints** | TAD-native (Epic phases); each phase produces persistent file | Requires handoff design per phase |
| Epic sub-phases | Best for systematic reviews (protocol→search→screen→synthesize) | More overhead for quick factual lookups |

**Decision**: Multi-session with handoff checkpoints is the default for substantial research (literature surveys, systematic reviews). Quick factual questions use single-session (no handoff needed).

**Mapping to research task types**:

| Task Type | ScienceClaw Min Tool Calls | TAD Session Model |
|-----------|---------------------------|-------------------|
| Quick factual | 3-5 | Single session, no handoff |
| Literature survey | 20-40 | 1-2 Blake sessions with handoff |
| Comprehensive review | 40-80 | Epic: 2-3 phases |
| Systematic review | 80+ | Epic: 4-6 phases (PRISMA pipeline) |

---

### Decision 7: Estimated Effort — Phase 2-5

Based on actual source code analysis (not README claims):

| Phase | Description | Estimated Handoffs | Complexity | Rationale |
|-------|-------------|-------------------|-----------|-----------|
| **Phase 2** | Pack architecture design | 1-2 (Standard TAD) | Medium | Design reference-based pack with 8-10 reference files. Key design decision: how to organize 60 P1 skills into ~8 reference files. |
| **Phase 3** | Skill content migration | 3-5 (Full TAD + parallel) | High | Extract judgment rules from 60 P1 + 90 P2 skills into reference files. Need to: (a) deduplicate overlapping skills (e.g., statsmodels vs statsmodels-stats), (b) merge database API templates, (c) preserve specific thresholds (anti-slop H content). |
| **Phase 4** | Integration + quality verification | 1-2 (Standard TAD) | Medium | Install pack, behavioral evaluation (3-5 before/after comparisons), anti-slop score verification. |
| **Phase 5** | Memory + evolution integration | 1 (Light TAD) | Low | TAD already has project-knowledge + NotebookLM. Just need to verify research-domain adapter for Knowledge Assessment works with the new pack. |

**Total estimated effort**: 6-10 handoffs across 4 phases. Phase 3 is the highest effort (bulk content migration).

---

## Runtime Coupling Assessment Summary

### Portable (can migrate to TAD)

| Component | Migration Effort | Notes |
|-----------|-----------------|-------|
| 285 SKILL.md files (content) | Medium | Extract judgment rules; deduplicate; organize by reference file |
| SCIENCE.md protocol | Low | Direct port as SKILL.md routing + references/research-protocol.md |
| Database API templates (curl) | Low | Copy curl templates from 38 database skills into references/database-apis.md |
| Quality frameworks (ScholarEval, GRADE, PRISMA) | Low | Already text-based judgment rules |
| Research phases (6-phase enforcement) | Low | Map to Gate quality criteria + handoff ACs |

### Not portable (skip or adapt)

| Component | Reason | Alternative |
|-----------|--------|-------------|
| Context engine (pluggable) | Tightly coupled to OpenClaw runtime | Claude Code has native compaction |
| Memory system (96 files, SQLite, embeddings) | Tightly coupled; 5 embedding providers | TAD project-knowledge + NotebookLM |
| Routing (multi-channel bindings) | Not applicable (TAD is single-user CLI) | None needed |
| Plugin SDK (channel adapters) | Not applicable | None needed |
| Hook system | Tightly coupled to OpenClaw | TAD has own hook system |
| skill-evolution (runtime tracking) | Requires science-evolution extension | TAD *optimize + Knowledge Assessment |
| find-skills / clawhub | External ecosystem | GitHub-based skill repos |
