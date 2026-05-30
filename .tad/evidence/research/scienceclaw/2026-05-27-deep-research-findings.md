# ScienceClaw Deep Research Findings

**Date:** 2026-05-27
**Notebook:** 7779d639-9813-48cf-89b8-1055da040bb9 (19 sources)
**Repo:** https://github.com/beita6969/ScienceClaw (823 stars, MIT, TypeScript)
**Description:** Self-evolving AI research colleague for scientists. 285 skills, zero hallucination, persistent memory.

---

## 1. Project Overview

ScienceClaw is built on the [OpenClaw](https://github.com/openclaw/openclaw) engine, redesigned for academic research. Key differences from base OpenClaw:

| Feature | OpenClaw | ScienceClaw |
|---------|----------|-------------|
| Skills | ~54 fixed | 285+ self-evolving |
| Memory | Basic plugin | 4-layer: temporal decay + LanceDB vector + cross-session patterns |
| Timeout | 600s (10 min) | 3600s (1 hour+) with heartbeat |
| Context mgmt | Basic truncation | Smart compaction (preserves stats, effect sizes, citations) |
| Hallucination | No controls | Zero-hallucination protocol (SCIENCE.md) |
| Research depth | Single-pass | Multi-phase mandatory depth with tool-call minimums |
| Databases | None | 25+ academic databases across all disciplines |

**Scale:** 285+ skills, 28+ disciplines, 847 agent files, 96 memory files, 2 MCP servers.

---

## 2. Five Core Innovations

### Core 1: Self-Evolving Skill System

**Mechanism:**
1. User completes research task
2. System runs **Reflexion Cycle** — self-evaluates on 5 dimensions (1-5 scale):
   - Completeness, Accuracy, Efficiency, Depth, Actionability
3. Reflections stored in LanceDB with domain + task-type tags
4. `skill-creator` tool generates new `SKILL.md` files at runtime (no redeployment)
5. `skill-evolution` tool refines existing skills based on accumulated patterns
6. `find-skills` routes user requests to the right skill from 285+ options

**SKILL.md Structure:**
- Metadata header (name, description, metadata)
- Workflow (step-by-step execution protocol)
- Integration Points (which other skills/tools to invoke)
- Output Formats (specific deliverables)
- Best Practices / Rules (mandatory guidelines)

**TAD Comparison:** TAD's `*optimize` + `*evolve` serve a similar purpose but operate at the project-knowledge and framework level, not individual skill files. ScienceClaw's runtime SKILL.md generation is more granular — TAD proposes changes via PROPOSAL YAML for human approval, ScienceClaw auto-generates.

### Core 2: Persistent Research Memory

**Architecture:**
- **LanceDB vector storage** for cross-session pattern retrieval
- **Temporal decay weighting** (exact algorithm not documented)
- **Smart context pruning** — preserves statistical results, effect sizes, key citations; compacts intermediate steps
- **Cross-session retrieval** driven by Reflexion Cycle reflections tagged by domain

**Extensions:**
- `memory-core`: Base memory plugin (TypeScript, openclaw.plugin.json)
- `memory-lancedb`: Vector storage extension for semantic search over past research

**TAD Comparison:** TAD uses file-based `.tad/project-knowledge/` with manual Knowledge Assessment at Gates. ScienceClaw's approach is more automated (continuous learning) but less auditable (no human gate approval).

### Core 3: Long-Duration Research Sessions

- 3600s (1 hour+) timeout vs standard 600s
- Heartbeat keeps sessions alive across interruptions
- Multi-phase research protocol with mandatory depth thresholds
- Anti-premature-conclusion checklist (7 items, all must pass)

### Core 4: Zero-Hallucination Protocol

**Enforcement:** Prompt-level via SCIENCE.md (629 lines). Not hook-level or code-level.

**Rules:**
- Every citation must come from a tool result in CURRENT conversation
- If tool didn't return it → can't cite it
- If search returns nothing → say "no results", don't fall back to training data
- Mandatory self-check before every response: verify title, DOI, PMID, author list all from tool results

**TAD Comparison:** TAD's anti-rationalization registry (5 AR patterns) and Cognitive Firewall serve a similar purpose — preventing agent self-deception. ScienceClaw's approach is domain-specific (citations), TAD's is process-specific (skipping steps). Both are prompt-level enforcement.

### Core 5: All-Science Coverage

- Natural sciences: PubMed, UniProt, KEGG, PDB, ClinicalTrials, gnomAD, arXiv
- Social sciences: World Bank, SSRN, census data, econometrics
- Cross-disciplinary: SciPy, matplotlib, LaTeX, PRISMA, SymPy
- MCP servers: arxiv-latex-mcp (LaTeX source extraction), chembl-mcp (drug/molecule data)

---

## 3. Unique Design Patterns Worth Studying

### 3.1 Anti-Premature-Conclusion (Minimum Tool-Call Enforcement)

| Task Type | Minimum Tool Calls |
|-----------|-------------------|
| Quick factual | 5 |
| Literature survey | 30 |
| Comprehensive review | 60 |
| Systematic review | 100+ |

Agent self-counts tool calls. Below threshold → blocked from concluding. Must keep working.

**TAD applicability:** TAD's Ralph Loop has Layer 1/Layer 2 quality checks but no explicit minimum iteration count. Could adopt a "minimum evidence files" threshold per handoff complexity tier.

### 3.2 Reflexion Cycle (5-Dimension Self-Evaluation)

After every task:
- Completeness (1-5)
- Accuracy (1-5)
- Efficiency (1-5)
- Depth (1-5)
- Actionability (1-5)

Generates structured reflection → stored in LanceDB → retrieved for similar future tasks.

**TAD applicability:** TAD's `*optimize` reads execution traces but doesn't have per-task self-evaluation. Could add a "Blake Reflexion" step after Gate 3 that scores implementation quality on similar dimensions.

### 3.3 Stuck Recovery Protocol (Fallback Chains)

Instead of retrying same endpoint:
1. Same error 3x → forced strategy change
2. Explicit fallback chains per data source (e.g., OpenAlex → Semantic Scholar → Google Scholar → arXiv)
3. If entire phase blocked → document failure, advance to next phase (don't restart)

**TAD applicability:** TAD's research-plan Phase 4b has similar gap-detection + enrichment, but ScienceClaw's fallback chains are more explicit and domain-specific.

### 3.4 ScholarEval (8-Dimension Quality Rubric)

Weighted rubric for evaluating research quality:
| Dimension | Weight |
|-----------|--------|
| Rigor | 25% |
| Impact | 20% |
| Novelty | 15% |
| Reproducibility | 15% |
| Clarity | 10% |
| Coherence | 10% |
| Limitations | 3% |
| Ethics | 2% |

Score 0-1 → Accept (≥0.75), Minor Revision (≥0.60), Major Revision (≥0.40), Reject (<0.40).

**TAD applicability:** TAD has no structured rubric for evaluating research output quality. ScholarEval could inform a "research-quality gate" for *research-plan outputs.

### 3.5 Task Persistence Protocol

"You are a tireless research agent. You keep working until ALL phases are complete."
- NEVER end turn with text-only response until final report saved to file
- Track progress: note current phase at start of each turn
- 7-phase mandatory workflow (Discovery → Deep Reading → Citation Chain → DB Cross-Verification → Synthesis → Report)

---

## 4. Architecture Summary

```
ScienceClaw Architecture
├── SCIENCE.md (629-line master protocol — zero hallucination + depth enforcement)
├── skills/ (285+ SKILL.md files — self-evolving)
│   ├── skill-evolution/ (runtime skill refinement)
│   ├── skill-creator/ (runtime new skill generation)
│   ├── find-skills/ (skill discovery/routing)
│   ├── academic-deep-research/ (multi-phase research)
│   ├── systematic-review/ (PRISMA-compliant)
│   ├── scholar-evaluation/ (ScholarEval 8D rubric)
│   └── ... (280+ domain-specific skills)
├── extensions/
│   ├── memory-core/ (base persistent memory)
│   └── memory-lancedb/ (vector storage for pattern retrieval)
├── mcp-servers/
│   ├── arxiv-latex-mcp/ (arXiv LaTeX source access)
│   └── chembl-mcp/ (drug/molecule database)
├── src/
│   ├── agents/ (847 files — core agent runtime)
│   ├── memory/ (96 files — memory subsystem)
│   ├── gateway/ (359 files — network gateway)
│   ├── hooks/ (48 files — lifecycle hooks)
│   └── plugins/ (85 files — extension system)
└── apps/ (Android, iOS, macOS, web)
```

---

## 5. Key Takeaways for TAD

### Patterns TAD Could Borrow:
1. **Minimum-effort thresholds** — explicit tool-call minimums per task complexity tier
2. **Reflexion Cycle** — per-task self-evaluation scoring (5 dimensions) stored for future retrieval
3. **ScholarEval rubric** — weighted quality rubric for research outputs
4. **Fallback chains** — explicit alternative paths when primary tools fail
5. **Runtime SKILL.md generation** — currently TAD's *optimize proposes changes; ScienceClaw auto-generates

### Where TAD is Stronger:
1. **Human-in-the-loop governance** — TAD's 4-Gate system with mandatory human approval; ScienceClaw's quality is self-evaluated (no human gate)
2. **Anti-rationalization defense** — TAD's 5-pattern AR registry catches specific agent self-deception patterns; ScienceClaw has no equivalent
3. **Two-agent terminal isolation** — TAD's Alex/Blake separation prevents implementation bias in design; ScienceClaw is single-agent
4. **Auditable decision trail** — TAD's handoff → completion → evidence chain; ScienceClaw's memory is opaque
5. **Cross-project evolution** — TAD's *evolve aggregates across projects; ScienceClaw evolves per-user only

### Fundamental Difference:
- **ScienceClaw:** Single-agent, domain-specific (science), automated self-evolution, prompt-level enforcement
- **TAD:** Two-agent, domain-agnostic, human-approved evolution, multi-layer enforcement (prompt + hooks + gates)
