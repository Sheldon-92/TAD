# Epic: Academic Research Capability Pack — ScienceClaw Complete Port to TAD

**Epic ID**: EPIC-20260527-academic-research-pack
**Created**: 2026-05-27
**Owner**: Alex

---

## Objective

Build a universal `academic-research` capability pack that gives TAD agents the full research methodology and domain skills currently in ScienceClaw (285 skills, 25+ databases, persistent memory, zero-hallucination protocol, ScholarEval quality rubric). The pack must support text + image multimodal research and validate on a real research task (user's plant pattern or food science topic).

## Success Criteria

- [ ] Pack installed via `install.sh --agent=claude-code` on any TAD project
- [ ] SKILL.md + references cover ScienceClaw's 5 core innovations (depth enforcement, zero-hallucination, Reflexion, ScholarEval, self-evolving skills)
- [ ] ≥80 migrated academic skills usable through TAD workflow (Alex design → Blake execute → Gates verify)
- [ ] Academic database access working (Semantic Scholar + Google Scholar + arXiv + ≥2 domain-specific DBs)
- [ ] Image + text multimodal research methodology included
- [ ] Persistent research memory operational (LanceDB or TAD-native)
- [ ] Pilot test: one real research task produces a citable report with verified references
- [ ] Codex/Gemini cross-audit score ≥ 3.5/5 on anti-slop

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Source Study + Architecture Design | ✅ Done | HANDOFF-20260527-academic-research-pack-phase1.md | Architecture doc: skill taxonomy, TAD mapping strategy, pack structure blueprint |
| 2 | Core Pack Build (SKILL.md + Protocol References) | ✅ Done | HANDOFF-20260528-academic-research-pack-phase2.md | Installed SKILL.md with research depth, zero-hallucination, ScholarEval, Reflexion rules |
| 3 | Skill Library Migration (Priority 80 Skills) | ✅ Done | HANDOFF-20260528-academic-research-pack-phase3.md | 10 cluster reference files consolidating 87 skills' judgment rules |
| 4 | Database + Tool Integration | ✅ Done | HANDOFF-20260528-academic-research-pack-phase4.md | academic-search.sh (6 DBs) + Europeana + USDA FoodData + fallback chain tested |
| 5 | Multimodal + Memory System | ✅ Done | HANDOFF-20260528-academic-research-pack-phase5.md | multimodal-research.md + pattern-extraction.md + Memory Integration section |
| 6 | Python CV Quantitative Analysis Tools | ✅ Done | HANDOFF-20260528-academic-research-pack-phase6.md | image-analysis.py (5 subcommands) + setup-cv.sh + quantitative-analysis.md |
| 7 | Pilot Test + Validation | ✅ Done | HANDOFF-20260528-academic-research-pack-phase7.md | Soy sauce cross-cultural report (12 refs, ScholarEval 0.626) + pack README |

### Phase Dependencies
All phases are sequential: 1 → 2 → 3 → 4 → 5 → 6. Phase 1 output informs all subsequent phases.

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: Source Study + Architecture Design

**Status:** ✅ Done
**Execution:** completed

#### Scope
Clone ScienceClaw to local, deep-study the full source code architecture. Map all 285 skills into a taxonomy. Analyze the memory system internals (memory-core + memory-lancedb). Analyze database integration patterns (MCP servers + direct API). Design how each component maps to TAD's capability pack architecture (SKILL.md + references + install.sh). NOT in scope: writing any pack files yet — this Phase is pure research and design.

#### Input
- ScienceClaw repo: https://github.com/beita6969/ScienceClaw
- Existing notebook: 7779d639 (19 sources, 7 ask rounds)
- Existing findings: .tad/evidence/research/scienceclaw/2026-05-27-deep-research-findings.md
- TAD pack architecture patterns: architecture.md "Capability Pack" entries
- 13 existing capability packs as structural precedent

#### Output
- `.tad/evidence/research/scienceclaw/architecture-analysis.md` — full architecture doc
- `.tad/evidence/research/scienceclaw/skill-taxonomy.md` — all 285 skills categorized with migration priority
- `.tad/evidence/research/scienceclaw/tad-mapping-blueprint.md` — how each ScienceClaw component maps to TAD
- Decision: which skills become judgment rules vs which become executable references
- Decision: memory approach (LanceDB port vs TAD-native file-based vs hybrid)
- Decision: database access approach (MCP servers vs WebSearch+API wrappers vs hybrid)

#### Acceptance Criteria
- [ ] ScienceClaw cloned locally and all 285 skills enumerated with category + description
- [ ] Source code for memory-core, memory-lancedb, skill-creator, skill-evolution read and documented
- [ ] Architecture analysis covers: skill system, memory, databases, SCIENCE.md protocol, gateway, hooks
- [ ] Skill taxonomy prioritizes top 80 skills for Phase 3 migration with clear selection rationale
- [ ] TAD mapping blueprint approved by human before Phase 2 starts

#### Files Likely Affected
- .tad/evidence/research/scienceclaw/architecture-analysis.md (CREATE)
- .tad/evidence/research/scienceclaw/skill-taxonomy.md (CREATE)
- .tad/evidence/research/scienceclaw/tad-mapping-blueprint.md (CREATE)

#### Dependencies
None (first Phase)

#### Notes
- ScienceClaw is 5000+ files — Phase 1 must focus on architecture patterns, not read every file
- Key question: ScienceClaw's runtime skill generation (skill-creator writing SKILL.md at runtime) — can TAD do this? Or should self-evolution stay as *optimize/*evolve human-approved?
- Risk: ScienceClaw may have features deeply coupled to OpenClaw runtime that have no TAD equivalent

### Phase 2: Core Pack Build (SKILL.md + Protocol References)

**Status:** ✅ Done
**Execution:** completed

#### Scope
Build the core `academic-research` capability pack: main SKILL.md, research protocol references, quality rubric, and install.sh. The SKILL.md teaches TAD agents research methodology — it does NOT contain the 80+ individual skill references (that's Phase 3). NOT in scope: database integrations, memory system, multimodal, or individual skill files.

#### Input
- Phase 1 outputs (architecture analysis, TAD mapping blueprint)
- ScienceClaw SCIENCE.md (629-line master protocol)
- ScienceClaw scholar-evaluation skill (ScholarEval 8D rubric)
- Existing TAD pack structure patterns (.claude/skills/{name}/SKILL.md + references/)

#### Output
- `.claude/skills/academic-research/SKILL.md` — main skill file with YAML frontmatter
- `.claude/skills/academic-research/references/research-depth-protocol.md` — translated from SCIENCE.md
- `.claude/skills/academic-research/references/zero-hallucination-rules.md` — citation integrity rules
- `.claude/skills/academic-research/references/scholar-eval-rubric.md` — 8D quality scoring adaptation
- `.claude/skills/academic-research/references/reflexion-cycle.md` — post-task self-evaluation rules
- `.claude/skills/academic-research/references/fallback-chains.md` — database fallback paths
- `.claude/skills/academic-research/install.sh` — installer script
- Pack installed and activating in TAD

#### Acceptance Criteria
- [ ] `install.sh --agent=claude-code` succeeds with zero errors
- [ ] SKILL.md has YAML frontmatter (name + description) — mandatory for Claude Code activation
- [ ] Research depth protocol includes minimum-effort thresholds per task complexity
- [ ] Zero-hallucination rules require every citation to trace to a tool result
- [ ] ScholarEval rubric covers 8 weighted dimensions with Accept/Revision/Reject thresholds
- [ ] Reflexion Cycle defines 5-dimension scoring (completeness, accuracy, efficiency, depth, actionability)
- [ ] `/alex *analyze` with academic research keywords triggers pack loading

#### Files Likely Affected
- .claude/skills/academic-research/ (CREATE — full directory)
- .tad/capability-packs/pack-registry.yaml (MODIFY — add new entry)

#### Dependencies
Phase 1 (mapping blueprint needed to know what goes in SKILL.md vs references)

#### Notes
- SKILL.md is the judgment-rules hub — it tells agents HOW to think about research, not WHAT databases to use
- Reference files are the deep rules — loaded on-demand per capability
- Must work WITHOUT Phase 3-5 deliverables (agent can still do research using WebSearch only)

### Phase 3: Skill Library Migration (Priority 80 Skills)

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Translate top 80 ScienceClaw skills from their SKILL.md format into TAD-compatible reference files, organized by research capability cluster. Clusters: literature search, data analysis, statistics, visualization, writing, domain-specific (natural science + social science). NOT in scope: database API integration (Phase 4), memory system (Phase 5), skills ranked below priority 80.

#### Input
- Phase 1 skill taxonomy with priority ranking
- Phase 2 pack structure (references/ directory pattern)
- ScienceClaw skill source files (local clone)

#### Output
- 80+ reference files in `.claude/skills/academic-research/references/skills/`
- Organized by cluster subdirectories (literature/, analysis/, statistics/, visualization/, writing/, domain/)
- Each reference file: skill name, when to use, step-by-step workflow, quality criteria, integration points, anti-patterns
- Updated SKILL.md Quick Rule Index pointing to all skill references

#### Acceptance Criteria
- [ ] ≥80 skill reference files created with TAD-compatible format
- [ ] Each skill has: workflow steps, quality criteria, and at least 1 anti-pattern
- [ ] SKILL.md Quick Rule Index updated with all skill references
- [ ] Skills cover: literature (≥15), analysis (≥15), statistics (≥10), visualization (≥10), writing (≥10), domain (≥20)
- [ ] Skill content is research-grounded (from ScienceClaw source), not LLM-invented

#### Files Likely Affected
- .claude/skills/academic-research/references/skills/ (CREATE — ~80 files)
- .claude/skills/academic-research/SKILL.md (MODIFY — Quick Rule Index)

#### Dependencies
Phase 1 (skill taxonomy), Phase 2 (pack structure)

#### Notes
- 80 skills × ~50 lines avg = ~4000 lines — this is the largest Phase by file count
- May need to batch into 2 handoffs if scope is too large for single Blake execution
- Key quality bar: each skill must contain specific thresholds/numbers from ScienceClaw (not generic LLM knowledge)

### Phase 4: Database + Tool Integration

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Build academic database access layer: MCP servers or API wrapper scripts for Semantic Scholar, arXiv, Google Scholar, and ≥2 domain-specific databases (museum/cultural heritage + food science). Design and implement fallback chains. NOT in scope: memory system (Phase 5), multimodal image analysis (Phase 5).

#### Input
- Phase 1 database mapping decisions
- ScienceClaw MCP server source (arxiv-latex-mcp, chembl-mcp)
- TAD MCP integration patterns (.tad/config-platform.yaml)

#### Output
- Database access scripts or MCP servers for: Semantic Scholar API, arXiv API, Google Scholar (web scrape), ≥2 domain DBs
- Fallback chain configuration integrated into pack references
- Database query skill references updated with real API details

#### Acceptance Criteria
- [ ] Semantic Scholar API queries return structured paper metadata (title, authors, DOI, abstract, citation count)
- [ ] arXiv search returns papers with PDF links
- [ ] ≥2 domain databases accessible (e.g., Europeana for cultural artifacts, USDA FoodData Central)
- [ ] Fallback chains tested: primary fail → secondary succeeds
- [ ] All database skills work through TAD Blake execution (not just standalone)

#### Files Likely Affected
- .claude/skills/academic-research/tools/ (CREATE — API wrappers/MCP configs)
- .claude/skills/academic-research/references/fallback-chains.md (MODIFY)
- .claude/skills/academic-research/references/skills/literature/ (MODIFY — add real API patterns)

#### Dependencies
Phase 2 (pack structure), Phase 3 (skill references to update)

#### Notes
- Semantic Scholar has free API (no key required for basic access)
- Google Scholar has no official API — need web scraping approach (SerpAPI or scholar.py)
- Museum databases: Europeana, British Museum, Met Museum — all have free APIs
- USDA FoodData Central: free API with key

### Phase 5: Multimodal + Memory System

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Add image analysis research methodology to the pack (pattern extraction, visual comparison, artifact documentation). Implement persistent research memory using LanceDB or TAD-native approach (cross-session pattern retrieval, temporal decay). NOT in scope: new domain-specific databases beyond Phase 4 deliverables.

#### Input
- Phase 1 memory architecture analysis
- ScienceClaw memory-core + memory-lancedb source
- Claude's native multimodal capability (image understanding)
- User's research topics as design drivers (plant patterns, food presentation)

#### Output
- `.claude/skills/academic-research/references/multimodal-research.md` — image analysis methodology
- `.claude/skills/academic-research/references/pattern-extraction.md` — visual pattern comparison workflow
- Memory integration: LanceDB setup or TAD file-based memory with semantic search
- Reflexion Cycle storage backend operational

#### Acceptance Criteria
- [ ] Agent can analyze uploaded images and extract visual patterns (lines, motifs, colors)
- [ ] Agent can compare two images and produce structured similarity analysis
- [ ] Research memory persists across sessions (query: "what patterns did we find in session X?")
- [ ] Reflexion Cycle scores stored and retrievable for similar future tasks
- [ ] Memory includes temporal decay (older findings weighted less in retrieval)

#### Files Likely Affected
- .claude/skills/academic-research/references/multimodal-research.md (CREATE)
- .claude/skills/academic-research/references/pattern-extraction.md (CREATE)
- .claude/skills/academic-research/references/memory-integration.md (CREATE)
- Memory backend files (TBD based on Phase 1 decision)

#### Dependencies
Phase 2 (pack structure), Phase 4 (databases — memory may reference DB query results)

#### Notes
- Claude natively understands images — the pack teaches METHODOLOGY, not vision capability
- LanceDB requires Python environment — consider if this conflicts with TAD's shell-first approach
- Alternative: use TAD's existing .tad/project-knowledge/ + NotebookLM as the "memory" layer
- Risk: LanceDB setup complexity may be too high for general TAD users → need easy fallback

### Phase 6: Pilot Test + Validation

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Run the complete academic-research pack through a real research task from the user's topics (plant ornamental patterns OR food science). Validate end-to-end: Alex designs research → Blake executes with pack → Gates verify quality → output is a citable report. Cross-model audit (Codex + Gemini). NOT in scope: fixing issues found in pilot — those become separate follow-up handoffs.

#### Input
- Phase 2-5 deliverables (complete pack)
- User's research topic for pilot
- Cross-model audit tools (codex, gemini CLIs)

#### Output
- Research report: structured academic output with verified citations
- Cross-model audit results (target: ≥ 3.5/5)
- Gap analysis: what works, what doesn't, what needs follow-up
- Pack README with usage guide

#### Acceptance Criteria
- [ ] Real research task completed end-to-end through TAD workflow (Alex → Blake → Gate 3 → Gate 4)
- [ ] Output report contains ≥10 citations all traceable to tool results (zero hallucination verified)
- [ ] ScholarEval self-assessment score ≥ 0.60 (Minor Revision or better)
- [ ] Cross-model audit (Codex + Gemini) anti-slop score ≥ 3.5/5
- [ ] Pack README documents: installation, capabilities, usage examples, limitations

#### Files Likely Affected
- .tad/evidence/research/{pilot-topic}/ (CREATE — research output)
- .claude/skills/academic-research/README.md (CREATE)
- .tad/evidence/yolo/academic-research-pack/ (CREATE — if YOLO mode)

#### Dependencies
Phase 2-5 (all pack components needed for end-to-end test)

#### Notes
- Pilot topic selection: user decides at Phase 6 start (纹样 or 食物)
- If audit finds major gaps → creates follow-up handoffs, does NOT block Epic completion
- Pack README is the "shipping" document — must explain to a new user how to use the pack

---

## Context for Next Phase

### Completed Work Summary
- Phase 1: Deep source study complete. 8812 files analyzed (3-layer sampling). 3 analysis docs produced (architecture-analysis 18.9KB, skill-taxonomy 39.4KB with 285 skills × 9 columns, tad-mapping-blueprint 13.2KB with 7 decisions). Commit 064bb17.
- Phase 2: Core pack built and installed. SKILL.md router (4-tier task detection) + 5 reference files (41 ScienceClaw source citations) + install.sh. 15 unique non-colliding keywords. Pack active in Claude Code skill list. Commit 9bae438.
- Phase 3: Skill library migrated. 10 cluster reference files (3,233 lines total) consolidating 87 unique ScienceClaw skills. Anti-slop verified (DerSimonian-Laird, Ehull<25meV/atom, I² 4-level, Cohen's d). 86/150 skills extracted (64 P2 M-rated skipped as generic). Commit 0f6f07a.

### Decisions Made So Far
- User chose: 完整移植 ScienceClaw → TAD capability pack (not partial extraction)
- User chose: 通用设计 (universal, not just for their topics)
- User chose: 混合数据源 (academic search + domain-specific databases)
- User chose: 图像+文本双模态
- User chose: 验收标准 = 跑通真实研究任务
- **Phase 1 Decision 1**: Pack type = reference-based (thin router + judgment rules) — skills are decoupled, no cross-skill state
- **Phase 1 Decision 2**: Memory = TAD file-based default (project-knowledge + evidence) — NotebookLM as optional semantic upgrade
- **Phase 1 Decision 3**: Database = curl-based API wrappers in reference files — no MCP servers needed for most DBs
- **Phase 1 Decision 4**: Skill evolution = proposal-based via *optimize/*evolve — runtime generation incompatible with Claude Code
- **Phase 1 Decision 5**: Alex/Blake role mapping defined — Alex designs research questions + strategy, Blake executes searches + analysis + writing
- **Phase 1 Decision 6**: Session model = multi-session with handoff checkpoints for substantial research, single-session for quick lookups
- **Phase 1 Key Finding**: 0/285 skills import plugin-sdk or context-engine — skills are fully portable as standalone SKILL.md content

### Known Issues / Carry-forward
- Anti-slop inflation on database API wrapper skills (architect P1-2) — Alex re-evaluates H/M ratings during Phase 2/3
- Decision 5 boundary cases (search strategy pivots mid-execution) — Alex designs in Phase 2
- Clone at /tmp/scienceclaw-study is ephemeral — re-clone needed for Phase 2+
- 96% of taxonomy entries are low-confidence (metadata-only) — expected per NFR1, but Phase 3 migration will need spot-checks

### Phase 2 Decisions
- Keyword collision avoidance: academic-research uses 15 unique keywords (学术/academic/论文/paper/文献/literature/PRISMA/PubMed etc.), zero overlap with research-methodology pack
- Tool-call thresholds adapted from ScienceClaw exact numbers to ranges (3-5/20-40/40-80/80+) per blueprint Decision 6
- TAD Integration section added (not in original handoff — backend-architect P1)
- Source citation integrity: adapted values cite BOTH original source AND adaptation document

### Phase 3 Notes
- 86/150 skills extracted — 64 P2 M-rated skills skipped (no extractable thresholds = anti-slop correct behavior)
- zero-hallucination rule intentionally duplicated across 6 files (reinforcement of absolute rule)
- visualization.md has inherited source discrepancy (55mm vs 85mm column width) — noted, not blocking

### Phase 4 Notes
- 5/6 APIs tested live (Europeana requires key — graceful skip)
- P0 fixed: heredoc Python injection via unvalidated --limit arg → integer validation added
- arXiv XML parsed with grep/sed (Python pyexpat broken on Python 3.14)
- New code-quality entry: "Bash heredoc Python injection via unvalidated CLI args"

### Next Phase Scope
Phase 5: Multimodal + Memory — image analysis methodology for pattern research + persistent research memory integration. Light TAD (blueprint estimated 1 handoff).

---

## Notes
- This is the first non-software-development capability pack in TAD history
- If successful, proves TAD methodology is domain-agnostic (major validation for "TAD Universal Method")
- ScienceClaw research notebook (7779d639) serves as the persistent knowledge base for this Epic
