# Project Objectives

> OKR format: Objective (qualitative direction) + Key Results (quantifiable metrics)
> Alex reads this file to align research with business goals.

---

## O1: Understand TAD's position in the AI Agent framework competitive landscape

**Why:** TAD has evolved to v2.10.4 through 13 Epics and 185 handoffs, but has never systematically benchmarked itself against the broader ecosystem. Understanding where TAD stands — unique strengths and capability gaps — is essential for prioritizing the next wave of development.
**Timeline:** 2026 Q2

| # | Key Result | Current | Target | Status |
|---|-----------|---------|--------|--------|
| KR1 | Comparative analysis of mainstream AI coding agent frameworks | 8+ analyzed (Round 1) | ≥8 frameworks analyzed | 🔄 |
| KR2 | TAD's core differentiators identified and validated | 3 found (Round 1) | ≥3 evidence-backed differentiators | 🔄 |
| KR3 | Capability gaps identified with severity assessment | 5+ found (Round 2-3) | ≥5 gaps with impact rating | 🔄 |

**Research needed:** Competitive landscape (Devin, OpenHands, Cursor, Jules, Amazon Q, Windsurf); multi-agent frameworks (LangGraph, CrewAI, MetaGPT); Anthropic ecosystem (Agent SDK, Managed Agents, Agent Teams); academic research on multi-agent software dev.

---

## O2: Discover highest-value upgrade directions for TAD's next stage

**Why:** TAD has 16 pending ideas and 3 active epics. Without systematic research grounding, prioritization relies on intuition rather than evidence. Need to identify which directions deliver the most value relative to implementation cost.
**Timeline:** 2026 Q2

| # | Key Result | Current | Target | Status |
|---|-----------|---------|--------|--------|
| KR1 | Candidate upgrade directions extracted from research | 12 candidates (Round 3) | ≥10 candidates with evidence | 🔄 |
| KR2 | Feasibility × Impact prioritization matrix | Top 5 ranked (2026-05-14) | Top 5 ranked with rationale | ✅ |
| KR3 | Actionable Epic drafts for top directions | 3 Epic outlines (A/B/C) | ≥3 Epic outlines ready for *discuss | ✅ |

**Research needed:** Agent observability/tracing; agent memory systems (episodic, graph); async/background execution patterns; agent evaluation benchmarks beyond SWE-bench; incremental adoption/onboarding; cost optimization; MCP ecosystem trends; KPI-driven development.

---

## O3: Establish a persistent research knowledge base for TAD continuous evolution

**Why:** One-shot web searches produce shallow, non-reusable findings. A persistent NotebookLM notebook with curated sources (papers, reports, official docs, conference talks) enables iterative deepening — each question builds on accumulated context.
**Timeline:** Ongoing

| # | Key Result | Current | Target | Status |
|---|-----------|---------|--------|--------|
| KR1 | High-quality sources in NotebookLM notebook | 45 sources | ≥30 sources (papers + reports + docs + videos) | ✅ |
| KR2 | Persistent queryable asset, not one-shot report | notebook active (37cfefa5) | notebook active + REGISTRY tracked | ✅ |
| KR3 | Cross-source synthesis findings documented | 3 rounds saved | ≥5 deep-ask findings saved | 🔄 |

**Research needed:** This objective IS the research infrastructure — it supports O1 and O2 by providing a curated, queryable knowledge base.

---

<!-- Research notebook: tad-evolution-research (37cfefa5-52b3-4a8a-a8e3-a83f32150759) — CREATED 2026-05-05, 45 sources, 3 deep-ask rounds -->
<!-- Findings: .tad/evidence/research/2026-05-05-tad-evolution-deep-ask-findings.md -->
<!-- KR2/KR3: .tad/evidence/research/2026-05-14-kr2-kr3-ask-findings.md -->
<!-- 2026-06-09 repositioning stress-test (O1 KR2 differentiators CHALLENGED): .tad/evidence/research/repositioning-3-walls/2026-06-09-ask-findings.md -->
<!-- Verdict: all 3 repositioning walls falsified as stated; persistent doc-layer is 2026 baseline (9 tools); surviving positioning = "displaced-expert operating system" NOT "outsider learns insider"; differentiator stays rhetorical without code-enforced gates (re-open 2026-04-15 mechanical-enforcement decision). 2 new gaps: gate-ROI unproven, residue Staleness Trap. -->
