# Research Report: datawhalechina/hello-agents

**Date:** 2026-05-27
**Notebook:** `037c8e7d-df51-4c63-93a6-12bf44015fee` ("AI Agent Tutorials & Educational Resources")
**Source:** GitHub README + Table of Contents (URL-level import; chapter bodies not yet loaded)
**Ask rounds:** 2

---

## 1. Project Identity

- **Repo:** `datawhalechina/hello-agents` ⭐ 54,084
- **Full title (zh):** 《从零开始构建智能体》— 从零开始的智能体原理与实践教程
- **English title:** "Building Agents from Scratch"
- **Publisher:** Datawhale (Chinese open-source learning community)
- **License:** NOASSERTION (custom — needs review before any code reuse)
- **Created:** 2025-09-07 · **Last push:** 2026-05-26 (highly active)
- **Size:** 218 MB · **Language:** Python (primary), Chinese (docs)
- **Topics:** `agent`, `llm`, `rag`, `tutorial`

**Stated purpose:** Bridge the gap between agent theory and hands-on practice. Specifically targets **"AI Native Agents"** (driven truly by LLMs) over workflow-driven software. End goal: transition learners from **users** of LLMs to **builders** of agent systems.

**Target audience:** AI developers, software engineers, students with basic Python + LLM API familiarity. NO requirement for ML/training background.

---

## 2. Structure: 5 Parts / 16 Chapters

| Part | Chapters | Focus |
|------|----------|-------|
| 1. Foundations | 1-3 | Agent definition/history; LLM basics (Transformers, prompting, limitations) |
| 2. Building LLM Agents | 4-7 | Classic paradigms · low-code platforms · mainstream frameworks · build-from-scratch |
| 3. Advanced Capabilities | 8-12 | Memory · RAG · Context engineering · Communication protocols · Agentic-RL · Evaluation |
| 4. Comprehensive Cases | 13-15 | Travel assistant · automated deep-research agent · cyber-town simulation |
| 5. Capstone | 16 | Student-built multi-agent application |

**Plus**: `Extra-Chapter/` (community contributions, e.g. Extra-09 "Code Agent dev pitfalls"), `Co-creation-projects/`, `Additional-Chapter/`.

---

## 3. Topic Coverage (cross-checked from ToC)

| Theme | Where covered |
|-------|---------------|
| Classic paradigms: **ReAct, Plan-and-Solve, Reflection** | Ch. 4 (hands-on implementation) |
| **Memory** systems | Ch. 8 |
| **RAG** (Retrieval-Augmented Generation) | Ch. 9 |
| **Context Engineering** | Part 3 (chapter TBD from ToC) |
| **Agent Communication Protocols: MCP, A2A, ANP** | Ch. 10 (deep parsing + comparative analysis in Extra-05 "Agent Skills vs MCP") |
| **Agentic-RL** (SFT → GRPO full pipeline) | Part 3 |
| **Agent Performance Evaluation** (metrics, benchmarks, frameworks) | Ch. 12 — explicit methodology, not just running tests |
| Specialized: Web Agents, GUI Agents, Self-Evolution | Community modules |
| Failure modes / pitfalls | Ch. 3 (LLM limitations) + Extra-09 (Code Agent 踩坑经验) |

---

## 4. Frameworks & Tools Used

| Category | Specifics |
|----------|-----------|
| **Custom (their own):** | `HelloAgents` framework — built from scratch on native OpenAI API |
| **Mainstream frameworks:** | LangGraph, AutoGen, AgentScope |
| **Low-code platforms:** | Coze, Dify, n8n |

Notably: **does NOT center on a single framework**. The pedagogy is "implement classic paradigms in multiple frameworks + understand by building from scratch."

---

## 5. TAD Relevance Assessment

### What hello-agents is NOT
- ❌ Not a competitor to TAD (it's a tutorial, not a methodology/runtime)
- ❌ Not a framework like LangGraph (it teaches multiple, doesn't push one)
- ❌ Not a knowledge base for ongoing research (it's a learning curriculum)

### What hello-agents IS (relevant to TAD)
1. **A reference curriculum for "what AI agent builders should know in 2026"** — useful as a benchmark for TAD's capability pack coverage (do TAD's `ai-agent-architecture` / `ai-prompt-engineering` packs match topics taught here?).
2. **An authoritative Chinese-language reference** for agent design terminology (54K stars = high adoption in CN dev community).
3. **A source of pedagogy patterns** — how to structure progressive teaching about agents.

### Specific borrowable concepts (worth deeper investigation if user wants)
- **Ch. 4's "implement-and-compare" pedagogy** for ReAct vs Plan-and-Solve vs Reflection → could inform a TAD `*learn` mode lesson plan template.
- **Ch. 10's MCP/A2A/ANP comparison** → directly relevant to TAD's `ai-tool-integration` capability pack (which currently focuses on MCP only).
- **Ch. 12's eval methodology** → cross-check with TAD's `ai-evaluation` capability pack.
- **Extra-09 "Code Agent pitfalls"** → could be a source for `project-knowledge/code-quality.md` and `architecture.md` cross-pollination.

### What is NOT in scope of this project
- No CLI tool / no agent runtime / no MCP server
- Not a methodology for human+AI software development (TAD's niche)
- No quality gate / acceptance protocol concepts

---

## 6. Source Quality Note

- README is comprehensive (19.8 KB) — sufficient for project identity + ToC level questions.
- **Chapter bodies NOT loaded** — for specific "judgment rule" questions (e.g., "WHEN to use ReAct vs Plan-and-Solve") NotebookLM correctly reports gap.
- **To deepen**: add Ch. 4, Ch. 10, Ch. 12 markdown files from `docs/` directory as additional sources.

---

## 7. Recommendations

| Action | Rationale | Cost |
|--------|-----------|------|
| **Keep notebook for future tutorials** | User intent: build "AI Agent Tutorials" notebook over time | Low |
| Add 2-3 specific chapter `.md` files if a TAD pack upgrade targets the same topic | Surgical deepening, avoids 218 MB import | ~5 min per chapter |
| Cross-check `ai-tool-integration` pack against Ch. 10 (MCP/A2A/ANP) | Existing pack only covers MCP; A2A + ANP gap probably exists | Medium |
| Skip wholesale chapter import | Notebook already has 11 active; bloat risk | — |

---

## 8. Open Questions (for future ask rounds, if user pursues)

1. What are the *specific judgment rules* in Ch. 4 for selecting ReAct vs Plan-and-Solve vs Reflection? (requires loading Ch. 4 docs)
2. How does Ch. 10 compare A2A vs ANP vs MCP on use-case fit? (requires loading Ch. 10 docs)
3. What evaluation rubrics does Ch. 12 actually prescribe — Core metrics? Benchmark choices? (requires loading Ch. 12 docs)
4. What are the top 5 pitfalls in Extra-09? (requires loading Extra-Chapter/Extra-09)

---

**Saturation status:** SATURATED at the README+ToC level. Further depth requires more sources, not more questions.
