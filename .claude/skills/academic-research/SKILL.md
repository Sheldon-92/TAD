---
name: academic-research
description: "Academic research methodology pack — systematic literature review, citation integrity, quality evaluation. Activates on: 学术, academic, 论文, paper, 文献, literature, meta-analysis, 元分析, PRISMA, systematic review, 系统性综述, PubMed, 文献综述, 学术研究, 科研"
version: 0.1.0
type: reference-based
keywords: ["学术", "academic", "论文", "paper", "文献", "literature", "meta-analysis", "元分析", "PRISMA", "systematic review", "系统性综述", "PubMed", "文献综述", "学术研究", "科研"]
---

# Academic Research Capability Pack

> Teaches AI agents HOW to do academic research — depth enforcement, citation integrity, quality scoring, and self-evaluation. Derived from ScienceClaw's 629-line SCIENCE.md protocol + ScholarEval rubric + VOYAGER-inspired Reflexion Cycle.
>
> **CONSUMES**: Research question + optional domain constraints (field, date range, databases).
> **PRODUCES**: Evidence-grounded research report + methodology section + citation audit trail + Reflexion Cycle self-evaluation (for non-trivial tasks).

---

## Scope Disambiguation

This pack covers **academic and scientific research methodology**.

**This pack — use when:**
- User asks about 学术/academic/论文/paper/文献/literature tasks
- Systematic or literature reviews, meta-analyses
- Tasks mentioning PRISMA, PubMed, citation analysis, ScholarEval
- Evaluating research quality or scholarly writing

**NOT this pack — defer to `research-methodology` when:**
- Market analysis, technology trend analysis, competitive analysis
- General non-academic "research X" tasks without scientific context
- Business strategy investigation, product analysis

If ambiguous, ask the user: "Is this academic/scientific research or general market/technology research?"

---

## Step 1: Detect Research Task Type

Classify the user's request into one of four tiers. Each tier has a mandatory minimum depth derived from ScienceClaw SCIENCE.md lines 111-121.

| Tier | Signal Keywords | Min Phases | Min Tool Calls | Session Model |
|------|----------------|-----------|---------------|---------------|
| **Quick factual** | "what is", "define", "quick question", single-fact lookup | 1-2 | 3-5 | Single session, no handoff |
| **Literature survey** | "review literature", "survey papers", "what does the research say", "文献综述" | 1-5 | 20-40 | 1-2 sessions with handoff |
| **Comprehensive review** | "comprehensive review", "analyze the field", "综合分析", "学术综合分析" | 1-6 | 40-80 | Epic: 2-3 phases |
| **Systematic review** | "systematic review", "meta-analysis", "PRISMA", "系统性综述", "元分析" | 1-6 (iterated) | 80+ | Epic: 4-6 phases (PRISMA pipeline) |

**Example inputs per tier:**

Quick factual:
- "What is the current impact factor of Nature Medicine?"
- "Who first described CRISPR-Cas9 gene editing?"
- "What is the sample size formula for a two-arm RCT?"

Literature survey:
- "Survey recent papers on transformer architectures for protein folding"
- "What does the literature say about remote work productivity?"
- "Review papers on CRISPR cancer therapy from 2023-2025"

Comprehensive review:
- "Analyze the field of large language models for drug discovery"
- "Comprehensive review of causal inference methods in economics"
- "Review all approaches to federated learning in healthcare"

Systematic review:
- "Conduct a systematic review of CBT interventions for anxiety"
- "PRISMA-compliant meta-analysis of statin efficacy in primary prevention"
- "Systematic review of AI diagnostic accuracy in radiology"

> Source: Adapted from SCIENCE.md lines 111-121, adjusted per tad-mapping-blueprint.md Decision 6

---

## Step 2: Load References by Task Type

### Protocol References (always applicable)

| Tier | Protocol References |
|------|----------------------|
| Quick factual | zero-hallucination.md only |
| Literature survey | research-protocol.md + zero-hallucination.md + fallback-chains.md |
| Comprehensive review | ALL protocol references + relevant cluster references |
| Systematic review | ALL protocol + ALL cluster references |

### Cluster References (load by research domain)

Load the cluster references that match the research topic. Multiple clusters may apply.

| Research Domain Signal | Load These Cluster References |
|----------------------|------------------------------|
| Literature search, citation analysis | references/literature-search.md |
| Academic database queries (general) | references/database-apis-general.md |
| Life science databases (protein, gene, drug) | references/database-apis-life-sciences.md |
| Statistical analysis, meta-analysis | references/statistics.md |
| Paper/grant/report writing | references/writing.md |
| Figures, plots, charts | references/visualization.md |
| Biomedical / life science domain | references/domain-biomedical.md |
| Physical / computational science | references/domain-physical.md |
| Social science / economics | references/domain-social.md |
| Experiment design, ethics, reproducibility | references/experiment-design.md |

Read the loaded reference files and apply their rules during research execution.

---

## Step 3: Alex/Blake Role Mapping for Research Tasks

| Research Activity | Alex (Design) | Blake (Execute) |
|-------------------|---------------|-----------------|
| Research question formulation | Elicits via Socratic Inquiry | — |
| Search strategy + database selection | Specifies in handoff | — |
| Search execution | — | Runs curl/API commands |
| Paper reading + extraction | — | Reads and extracts findings |
| Quality assessment | Defines criteria in handoff ACs | Applies ScholarEval from scholar-eval.md |
| Synthesis across sources | — | Synthesizes with citation audit |
| Report writing | — | Writes report with methodology section |
| Depth enforcement | Sets minimum tier in handoff | Follows research-protocol.md thresholds |
| Citation integrity | AC: "every citation traces to tool result" | Self-checks per zero-hallucination.md |

> Source: tad-mapping-blueprint.md Decision 5

---

## Step 4: Anti-Premature-Conclusion Checklist

Before concluding ANY research task (except quick factual), apply the **10 Anti-Premature-Conclusion Rules** from [research-protocol.md](references/research-protocol.md) and the **Completeness Checklist** from the same file.

If any item is unchecked, **continue working instead of concluding**.

---

## Step 5: TAD Integration

| TAD Mechanism | Academic Research Role |
|--------------|----------------------|
| **Gate 3** | Verifies citation integrity (zero-hallucination 4-point check) + ScholarEval score ≥ 0.75 for Accept |
| **Gate 4** | Verifies research completeness per tier (did Blake reach the minimum phase and tool-call threshold?) |
| **Knowledge Assessment** | Runs after Reflexion Cycle for non-trivial tasks — captures reusable research patterns in project-knowledge |
| **Ralph Loop Layer 1** | Checks fallback chain exhaustion (did Blake try alternatives before declaring a source failed?) |

---

## Quick Rule Index

### Protocol References (Phase 2)

| Reference | What It Covers | When to Read |
|-----------|---------------|-------------|
| [research-protocol.md](references/research-protocol.md) | 6 mandatory phases, depth enforcement, mandatory search protocol | Every non-trivial research task |
| [zero-hallucination.md](references/zero-hallucination.md) | Citation integrity, 4-point self-check, empty-result handling | Every task — this is absolute |
| [scholar-eval.md](references/scholar-eval.md) | 8-dimension weighted quality rubric (0-1 scale) | When evaluating research quality |
| [reflexion-cycle.md](references/reflexion-cycle.md) | 5-dimension post-task self-evaluation | After completing a research task |
| [fallback-chains.md](references/fallback-chains.md) | Source failure recovery, 3-strike rule, fallback tables | When a search/API fails |

### Cluster References (Phase 3) — Domain-Specific Judgment Rules

| Reference | What It Covers | When to Read |
|-----------|---------------|-------------|
| [literature-search.md](references/literature-search.md) | Multi-database search, PRISMA pipeline, citation networks, bibliography management | Literature reviews, systematic reviews |
| [database-apis-general.md](references/database-apis-general.md) | Semantic Scholar, OpenAlex, PubMed, arXiv, World Bank, CrossRef API templates | Any database query task |
| [database-apis-life-sciences.md](references/database-apis-life-sciences.md) | UniProt, ChEMBL, NCBI, PDB, ClinicalTrials, KEGG, STRING API templates | Life science research |
| [statistics.md](references/statistics.md) | Test selection, meta-analysis (DerSimonian-Laird, I²), effect sizes, power analysis, APA reporting | Any quantitative analysis |
| [writing.md](references/writing.md) | IMRaD structure, grant writing (NIH/NSF), LaTeX, citation styles, journal page limits | Writing research outputs |
| [visualization.md](references/visualization.md) | Publication figures (300+ DPI), journal palettes, chart selection, statistical plots | Creating figures |
| [domain-biomedical.md](references/domain-biomedical.md) | Bioinformatics (FDR<0.05), clinical trials, CONSORT, drug discovery, protein analysis | Biomedical research |
| [domain-physical.md](references/domain-physical.md) | Molecular dynamics, materials screening, signal processing, computational chemistry | Physical/computational science |
| [domain-social.md](references/domain-social.md) | Econometrics (DiD, RDD, IV), survey methods, psychometrics, education research | Social science research |
| [experiment-design.md](references/experiment-design.md) | RCT design, sample size, GRADE, Cochrane RoB, reproducibility, IRB, peer review | Experiment planning |

---

## Notes

- **Phase 4 will add**: MCP server integrations for complex database queries, multimodal image analysis (Phase 5)
- **Skill evolution**: This pack improves via TAD's existing *optimize → proposal → human approval → handoff cycle (not runtime generation). See tad-mapping-blueprint.md Decision 4
- **Memory**: Uses TAD's file-based project-knowledge + optional NotebookLM notebooks. No additional memory infrastructure needed
- **Source coverage**: 86 unique ScienceClaw skills cited across 15 reference files (consolidated from 150 P1+P2 skills)
