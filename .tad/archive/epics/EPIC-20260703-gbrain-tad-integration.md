# Epic: TAD Knowledge Search (`tad-brain`)

**Epic ID**: EPIC-20260703-gbrain-tad-integration
**Created**: 2026-07-03
**Owner**: Alex

---

## Objective
Build a TAD-native semantic knowledge search capability enabling agents to query historical decisions, find reusable patterns, and discover cross-document connections on demand. Zero external dependencies — uses Claude's native semantic understanding as the search engine, with a lightweight index for file discovery.

## Success Criteria
- [x] Phase 1 POC: gbrain evaluated → NEGATIVE-RESULT (1/5, BM25 insufficient without embeddings) → PIVOT to TAD-native
- [ ] Phase 2 TAD-native: `tad-brain` search works, 5 queries ≥3 useful, integrated into Alex/Blake SKILL.md

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | POC — gbrain evaluation | ✅ Done (NEGATIVE-RESULT → pivot) | HANDOFF-20260703-gbrain-poc | gbrain 1/5 FAIL → evidence + pivot decision |
| 2 | TAD-native knowledge search (`tad-brain`) | ⬚ Planned | — | Index generator + Explore agent wrapper + SKILL integration |

### Phase Dependencies
Phase 2 is informed by Phase 1's findings (what works: file import was flawless; what fails: BM25 without embeddings, entity graph without wikilinks).

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: POC — gbrain evaluation

**Status:** ✅ Done (NEGATIVE-RESULT → pivot)
**Execution:** complete (2026-07-03)

#### Result
- gbrain v0.42.56.0 installed (project-local, ~/.gbrain-poc/)
- 2282/2286 files imported in 50.2s, 10255 chunks, 0 errors
- **Deviations**: no local embedding support (gbrain only supports API-based), entity graph 0 links (TAD no wikilinks)
- **Score: 1/5 FAIL** — only Q2 (keyword-matched "allow-list") passed; Q1/Q3/Q4/Q5 all failed
- **Root cause**: BM25 alone ≈ grep. TAD uses mixed CJK/English + domain markers that keyword matching can't bridge
- **Key insight**: gbrain's value is in LLM-powered features (embedding, think synthesis), not mechanical features. Since we already have an LLM (Claude), using Claude directly is more natural.
- Evidence: `.tad/evidence/poc/gbrain-poc/` (5 query results + gate-decision.md)

### Phase 2: TAD-native knowledge search (`tad-brain`)

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Build a lightweight TAD-native knowledge search using Claude's Explore agent as the semantic engine. Create an auto-generated index file (`.tad/brain-index.md`) listing all .tad/ + CLAUDE.md files with type/keywords/summary. Wrap in a `tad-brain` bash script callable by Alex/Blake via Bash. Integrate into Alex/Blake SKILL.md at design + implementation decision points. Add auto-rebuild hook. NOT in scope: external dependencies, embedding APIs, gbrain code, MCP, replacing NotebookLM or @import.

#### Input
- Phase 1 findings (what failed and why — informs index design)
- .tad/ directory (~2000+ markdown files)
- CLAUDE.md (contains TAD rules that .tad/ references but doesn't contain)
- Existing Explore agent type in Claude Code

#### Output
- `.tad/brain-index.md` — auto-generated file index (path + type + keywords + 1-line summary)
- `.tad/hooks/lib/brain-index-gen.sh` — index generator script
- `tad-brain` skill or bash wrapper for search invocation
- Updated Alex/Blake SKILL.md with integration points
- Updated tool-quick-reference-alex.md

#### Acceptance Criteria
- [ ] AC1: `brain-index-gen.sh` generates `.tad/brain-index.md` covering ≥500 files with type + keywords + summary
- [ ] AC2: `tad-brain search "<query>"` spawns Explore agent, returns cross-document answer with file citations
- [ ] AC3: Re-run Phase 1's 5 test queries — ≥3/5 produce useful answers (the threshold gbrain failed)
- [ ] AC4: Alex SKILL.md references `tad-brain` at ≥2 integration points
- [ ] AC5: Index auto-regenerates on .tad/project-knowledge/ changes (hook or *accept trigger)

#### Files Likely Affected
- .tad/brain-index.md (CREATE — auto-generated index)
- .tad/hooks/lib/brain-index-gen.sh (CREATE — index generator)
- .claude/skills/tad-brain/ or .claude/skills/alex/references/ (CREATE — search skill/wrapper)
- .claude/skills/alex/SKILL.md (MODIFY — integration points)
- .claude/skills/blake/SKILL.md (MODIFY — integration points)
- .tad/guides/tool-quick-reference-alex.md (MODIFY — tad-brain commands)

#### Dependencies
Phase 1 findings (informational, not blocking — Phase 1 is complete)

#### Notes
- Zero external dependencies — uses only Claude Code's native Agent tool + Explore agent type
- Index should be <1000 lines (fits in a single agent read)
- Explore agent does the semantic matching — no embedding needed
- Can search CLAUDE.md (not limited to .tad/ — fixes Q1's root cause)
- Mixed CJK/English + domain markers handled natively by Claude
- `tad-brain` complements @import + grep, doesn't replace them

---

## Context for Next Phase

### Completed Work Summary
- Phase 1: gbrain POC NEGATIVE-RESULT (1/5). BM25-only is ≈ grep. Import pipeline works (2282 files, 50s, 0 errors) but search value requires LLM layer.

### Decisions Made So Far
- gbrain chosen over Hindsight (philosophical alignment with TAD's explicit knowledge model)
- POC-first approach validated — caught gbrain's limitations before investing in fork
- gbrain fork ABANDONED after POC failure — pivot to TAD-native (Claude as search engine)
- No external API keys — constraint that exposed gbrain's dependency on LLM APIs as a fundamental limitation
- TAD-native approach: index file + Explore agent (zero external dependencies)

### Known Issues / Carry-forward
- Q1 answer lived in CLAUDE.md (outside .tad/) — Phase 2 index must include CLAUDE.md
- Q2 succeeded only with keyword-optimized query, not natural language — Phase 2 must handle natural language
- TAD uses mixed CJK/English + domain markers (⚠️ SAFETY, ANTI-RATIONALIZATION:) — index keywords must include these markers
- gbrain cleanup: `rm -rf ~/.gbrain-poc/ ~/.gbrain/` when convenient

### Next Phase Scope
Phase 2: Build brain-index.md generator + tad-brain search wrapper using Explore agents. Re-test the 5 queries.

---

## Notes
- Inspired by Matt Gunnin's 4-layer agent memory architecture (X article, 2026-07-03)
- gbrain research: 24.9k stars, MIT, TypeScript/Bun — technically solid but value is in LLM features
- Hindsight evaluated but rejected: auto-retain model conflicts with TAD's "Knowledge Is Forged at Distill" principle
- Key learning: the best "semantic search engine" for Claude Code is Claude itself. External tools add value only when they provide capabilities Claude lacks (persistent indexes, graph databases). For semantic understanding, Claude IS the tool.
