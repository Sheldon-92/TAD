---
task_type: research
e2e_required: no
research_required: yes
git_tracked_dirs: [".tad/capability-packs/academic-research"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Academic Research Pack — Phase 7: Pilot Test (Food Science)

**From:** Alex | **To:** Blake | **Date:** 2026-05-28
**Epic:** EPIC-20260527-academic-research-pack.md (Phase 7/7)

---

## 🔴 Gate 2: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
A real academic research report on **cross-cultural soy sauce usage patterns** (Chinese, Japanese, Thai cuisines) — produced end-to-end using the `academic-research` capability pack. This is the pack's validation test: if the pack works, Blake follows its protocols and produces a citable research report. Plus a pack README documenting installation and usage.

### 1.2 Research Question
**"How do soy sauce usage patterns (type, quantity, timing, function) differ across Chinese, Japanese, and Thai cuisines, and what chemical/nutritional differences underlie these distinct culinary roles?"**

Sub-questions:
- Q1: What types of soy sauce are used in each cuisine (light/dark/sweet/fermented)?
- Q2: What are the typical usage quantities per serving in each tradition?
- Q3: At what cooking stages is soy sauce added (marinade/stir-fry/finishing/dipping)?
- Q4: How do sodium, amino acid, and sugar profiles differ across types (USDA data)?
- Q5: What does food science literature say about the Maillard reaction differences?

### 1.3 Intent Statement
**真正要解决的问题**: Validate that the academic-research pack can guide a TAD agent through a real research task end-to-end — from literature search to structured report with verified citations.

**不是要做的**:
- ❌ NOT modifying any pack files (the pack is frozen — test it as-is)
- ❌ NOT a comprehensive food science review — this is a focused pilot with defined scope
- ❌ NOT inventing data — every claim must trace to a tool result (zero-hallucination rule)

---

## 📚 Project Knowledge

**⚠️ Blake MUST read the academic-research pack BEFORE starting:**
1. Read `.claude/skills/academic-research/SKILL.md` — follow its research protocol
2. Read `.claude/skills/academic-research/references/research-protocol.md` — follow the 6 phases
3. Read `.claude/skills/academic-research/references/zero-hallucination.md` — every citation from tool results only
4. Read `.claude/skills/academic-research/references/scholar-eval.md` — self-assess quality at the end
5. Read `.claude/skills/academic-research/references/database-apis-general.md` — for Semantic Scholar/OpenAlex queries
6. Read `.claude/skills/academic-research/references/database-apis-life-sciences.md` — for USDA FoodData queries

**This is the whole point of the pilot**: Blake follows the PACK, not this handoff's instructions. The handoff defines WHAT to research; the pack defines HOW.

---

## 2. Technical Design

### 2.1 Research Execution (Blake follows pack protocol)

Blake must execute the pack's 6-phase research protocol:

| Phase | Pack Protocol | Applied to This Topic |
|-------|--------------|----------------------|
| 1. Discovery | Search ≥2 academic databases | Semantic Scholar + OpenAlex: "soy sauce culinary usage" |
| 2. Deep Reading | Read 2-3 full-text papers | Top-cited papers on soy sauce chemistry/culinary science |
| 3. Citation Chain | Forward + backward citations | Trace from key papers to find comparative studies |
| 4. Database Cross-Verification | Query domain databases | USDA FoodData: sodium, amino acids, sugars for each soy sauce type |
| 5. Synthesis | Cross-source findings | Combine literature + USDA data into comparative analysis |
| 6. Report | Structured output with methodology | Final report with all citations verified |

### 2.2 Tools to Use

| Tool | Purpose | Command |
|------|---------|---------|
| `academic-search.sh semantic-scholar` | Find papers on soy sauce food science | `bash .claude/skills/academic-research/scripts/academic-search.sh semantic-scholar "soy sauce culinary usage fermentation" --limit 10` |
| `academic-search.sh openalex` | Complementary search | `bash ... openalex "soy sauce Chinese Japanese Thai cuisine" --limit 10` |
| `academic-search.sh usda-food` | Nutritional composition data | `bash ... usda-food "soy sauce" --limit 10` |
| WebSearch | Fill gaps not covered by APIs | Google Scholar for Chinese-language food science papers |
| Pack references | Methodology guidance | Follow research-protocol.md phases + zero-hallucination.md rules |

### 2.3 Report Structure

```markdown
# Cross-Cultural Soy Sauce Usage: Chinese, Japanese, and Thai Cuisines

## Abstract (150-200 words)

## 1. Introduction
- Research question and sub-questions
- Significance and scope

## 2. Methodology
- Databases searched (with query terms and result counts)
- Inclusion/exclusion criteria
- Data extraction method (USDA FoodData queries)

## 3. Results
### 3.1 Soy Sauce Typology by Cuisine
(Q1: types per culture — table format)
### 3.2 Usage Quantities
(Q2: quantities per serving — table with source citations)
### 3.3 Cooking Stage Integration
(Q3: when soy sauce is added — comparative table)
### 3.4 Nutritional Composition Comparison
(Q4: USDA data — sodium, amino acids, sugar per type)
### 3.5 Maillard Reaction and Flavor Chemistry
(Q5: literature findings on chemical differences)

## 4. Discussion
- Cross-cultural patterns and differences
- Chemical explanations for culinary practices
- Limitations of this review

## 5. References
(Every reference traceable to a tool result in this session)

## Appendix: ScholarEval Self-Assessment
(8-dimension quality scoring from scholar-eval.md)
```

---

## 3. Implementation Steps

### Task 1: Read Pack + Plan Research (10 min)
1. Read SKILL.md + all relevant references (listed in §Project Knowledge above)
2. Classify this as "Literature survey" tier (20-40 tool calls expected)
3. Plan search strategy: which databases, which queries

### Task 2: Execute 6-Phase Research Protocol (60 min)
Follow the pack's research-protocol.md phases sequentially:
1. **Discovery**: Run academic-search.sh for Semantic Scholar + OpenAlex queries
2. **Deep Reading**: Use WebFetch/Jina to read 2-3 top papers
3. **Citation Chain**: Trace forward/backward citations from key papers
4. **Database Cross-Verification**: Run USDA FoodData queries for each soy sauce type
5. **Synthesis**: Combine findings across all sources
6. **Report Writing**: Write structured report following §2.3 template

### Task 3: Self-Assessment (5 min)
1. Apply ScholarEval rubric (scholar-eval.md) — score on 8 dimensions
2. Apply Reflexion Cycle (reflexion-cycle.md) — score on 5 dimensions
3. Include both assessments in report appendix

### Task 4: Write Pack README (15 min)
1. Create `.tad/capability-packs/academic-research/README.md`
2. Sections: Overview, Installation, Capabilities, Usage Examples, Limitations
3. Include this pilot test as the primary usage example

---

## 4. Files to Create

| # | File | Action |
|---|------|--------|
| 1 | `.tad/evidence/research/food-science-pilot/soy-sauce-cross-cultural-report.md` | CREATE — research report |
| 2 | `.tad/evidence/research/food-science-pilot/methodology-log.md` | CREATE — search queries, result counts, tool calls |
| 3 | `.tad/capability-packs/academic-research/README.md` | CREATE — pack documentation |

---

## 9. Acceptance Criteria

| # | Requirement | Verification |
|---|------------|-------------|
| AC1 | Research report exists | `test -f .tad/evidence/research/food-science-pilot/soy-sauce-cross-cultural-report.md` |
| AC2 | ≥10 citations in References section | `sed -n '/^## .*[Rr]eferences/,/^## /p' .tad/evidence/research/food-science-pilot/soy-sauce-cross-cultural-report.md \| grep -cE '^\[?[0-9]+\]'` ≥ 10 |
| AC3 | Nutritional composition data included (USDA or equivalent) | `grep -ciE 'USDA\|FoodData\|Thai FDA\|food composition\|sodium.*mg\|amino acid' .tad/evidence/research/food-science-pilot/soy-sauce-cross-cultural-report.md` ≥ 5 |
| AC4 | 3 cuisines compared | `grep -ciE 'Chinese\|Japanese\|Thai' .tad/evidence/research/food-science-pilot/soy-sauce-cross-cultural-report.md` ≥ 9 (≥3 each) |
| AC5 | Methodology section documents search strategy | `grep -c 'Semantic Scholar\|OpenAlex\|USDA\|searched\|query' .tad/evidence/research/food-science-pilot/soy-sauce-cross-cultural-report.md` ≥ 3 |
| AC6 | ScholarEval self-assessment included | `grep -cE 'Rigor\|Impact\|Novelty\|Reproducibility' .tad/evidence/research/food-science-pilot/soy-sauce-cross-cultural-report.md` ≥ 4 |
| AC7 | ScholarEval score ≥ 0.60 | Manual: check the weighted average in appendix |
| AC8 | Zero-hallucination: no training-data citations | Manual: spot-check 3 random references — each must have tool-result provenance in methodology-log.md |
| AC9 | Pack README created | `test -f .tad/capability-packs/academic-research/README.md` |
| AC10 | README has installation + usage sections | `grep -cE 'Install\|Usage\|Example\|Limitation' .tad/capability-packs/academic-research/README.md` ≥ 4 |
| AC11 | Methodology log records all tool calls | `test -f .tad/evidence/research/food-science-pilot/methodology-log.md` AND file has ≥20 lines |
| AC12 | Pack protocol phases documented in log | `grep -c 'Phase [1-6]' .tad/evidence/research/food-science-pilot/methodology-log.md` ≥ 6 |

---

## 10. Important Notes

### 10.1 This Phase Tests the PACK, Not Blake's Research Skills
Blake's job is to follow the academic-research pack's protocols exactly. If the pack's guidance is unclear or insufficient, that's a pack quality issue to note in the README's "Limitations" section — NOT a reason to improvise outside the pack.

### 10.2 Anti-Slop for the Report
The report must contain SPECIFIC data from tool results:
- ✅ "Japanese koikuchi soy sauce contains 5,493mg sodium per 100ml (USDA FoodData #172440)"
- ❌ "Soy sauce is high in sodium"

### 10.3 USDA Coverage Gap — Thai Soy Sauce
USDA FoodData indexes US-market products. It will have generic soy sauce + Japanese koikuchi/usukuchi. Thai-specific types (see ew dam, nam pla wan) are unlikely to appear as distinct entries. When USDA lacks entries for a cuisine's soy sauce types:
- Fallback: WebSearch for Thai FDA food composition data or academic food chemistry papers
- Note the data source gap explicitly in report Limitations section
- Do NOT fabricate nutritional data to fill the gap (zero-hallucination rule applies)

### 10.4 Sub-Agent Suggestions
- No sub-agents needed — Blake does the research directly using pack tools
- Exception: if USDA API is unavailable, use WebSearch as fallback per fallback-chains.md

---

## 11. Decision Summary

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | Pilot topic | Cross-cultural soy sauce usage (Chinese/Japanese/Thai) | Exercises all pack capabilities: literature search, database query, cross-cultural comparison, nutritional data |
| 2 | Research tier | Literature survey (20-40 tool calls) | Sufficient depth for pilot validation without being a full systematic review |
| 3 | Pack modification | Frozen — test as-is | Any issues found become README limitations, not mid-test fixes |
