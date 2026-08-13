# Research Protocol — 6-Phase Mandatory Methodology

> Extracted from ScienceClaw SCIENCE.md lines 70-168. Every substantial research task MUST follow these phases sequentially. Skipping phases is a quality violation.

---

## Core Principle: Depth Over Speed

"The #1 failure mode is concluding too early. A real researcher does not stop after one search."

> Source: SCIENCE.md line 72

---

## The 6 Mandatory Phases

### Phase 1: Discovery (minimum for any task)

- Search at least 2 academic databases (e.g., Semantic Scholar + OpenAlex minimum)
- For social science topics, also search SSRN/RePEc/NBER
- Read abstracts of top 10-20 results
- Identify 3-5 key papers by citation count and relevance

> Source: SCIENCE.md lines 78-82

### Phase 2: Deep Reading (required for any non-trivial task)

- Read full text of 2-3 most important papers (via Jina Reader or PDF)
- Extract: methodology, key findings, limitations, open questions
- Identify contradictions or debates between papers

> Source: SCIENCE.md lines 84-87

### Phase 3: Citation Chain Analysis (required)

- For the 2-3 most important papers, trace **forward citations** (who cited them?)
- For the 2-3 most important papers, trace **backward references** (what did they cite?)
- This reveals: recent developments, foundational works, and research trends

> Source: SCIENCE.md lines 89-92

### Phase 4: Database Cross-Verification (required when applicable)

Apply domain-specific database verification:

| Domain | Verify Against |
|--------|---------------|
| Genes/proteins | UniProt, NCBI, STRING |
| Drugs/molecules | ChEMBL, PubChem, ClinicalTrials.gov |
| Economic data | World Bank, FRED, IMF |
| Materials | Materials Project |
| Clinical claims | ClinicalTrials.gov, ClinVar |
| Social science data | Census, WHO GHO, Eurostat |

Cross-verify claims from papers against these primary databases.

> Source: SCIENCE.md lines 94-100

### Phase 5: Synthesis and Gap Analysis (required)

- Synthesize findings across all sources
- Identify: consensus findings, contradictions, open questions, research gaps
- Quantify: how many papers support each claim, effect sizes, confidence levels
- For quantitative claims: report source, sample size, effect size, CI

> Source: SCIENCE.md lines 102-105

### Phase 6: Report Writing (required)

- Write a structured report with sections, citations, and data tables
- Include a **methodology section** describing exactly what was searched and found:
  - Which databases were queried
  - What search terms were used
  - How many results were returned
  - What filtering criteria were applied
- List all output files with full paths
- Before finalizing citations, run the **4-point self-check** from zero-hallucination.md

> Source: SCIENCE.md lines 107-110

---

## Depth Calibration Table

The minimum depth varies by task complexity. These thresholds are mandatory.

| Task Type | Min Phases Required | Min Tool Calls | Expected Duration |
|-----------|-------------------|---------------|-------------------|
| Quick factual question | 1-2 | 3-5 | 2-5 min |
| Literature survey | 1-5 (all through Synthesis) | 20-40 | 15-30 min |
| Comprehensive review | 1-6 (all phases) | 40-80 | 30-60 min |
| Systematic review | 1-6 (iterated, PRISMA) | 80+ | 60+ min |
| Data analysis project | 1-6 + code execution | 30-60 | 30-60 min |
| Multi-database investigation | 1-6 | 40-80 | 30-60 min |

**Router tier mapping**: "Data analysis project" and "Multi-database investigation" route as **Comprehensive review** tier in the SKILL.md router, with adjusted tool-call minimums per this table.

Before concluding, **count your tool calls**. If below the minimum for the task type, keep working.

> Source: Adapted from SCIENCE.md lines 111-121, adjusted per tad-mapping-blueprint.md Decision 6

---

## Anti-Premature-Conclusion Rules

These 10 rules prevent the most common research quality failures:

1. **NEVER conclude after a single search.** One search is just the beginning. Always search at least 2 databases.
2. **NEVER present results without reading at least 1 full-text paper.** Abstracts are not enough for non-trivial tasks.
3. **NEVER skip citation chains.** Forward/backward citations are how real researchers discover the best papers.
4. **NEVER write a report without a "Methods" section** describing search strategy, databases queried, number of results, and filtering criteria.
5. **Before writing your final response, ask: "Would a senior postdoc consider this thorough?"** If not, go deeper.
6. **If you find contradictory evidence, investigate it.** Do not paper over disagreements.
7. **If a database query fails, try an alternative.** Do not give up after one failure (see fallback-chains.md).
8. **NEVER end your turn with a text-only response until the final report is saved to a file.**
9. **Before concluding, count your tool calls.** If below the minimum for your task type, keep working.
10. **Track your current phase explicitly.** Start each turn by noting which phase you are on. If you haven't reached at least Phase 5 for a non-trivial task, keep going.

> Source: SCIENCE.md "Anti-Premature-Conclusion Rules" lines 123-133

---

## Mandatory Search Protocol

For any research query, follow this order:

### Step 1: Broad academic search (always first)

Use at least 2 academic APIs. Preferred order:
1. **OpenAlex** — most reliable, no rate limits, `mailto=` for polite pool
2. **Semantic Scholar** — complementary, includes TLDR and influential citation counts
3. **Europe PMC** — for biomedical/life science queries (same content as PubMed, fewer access issues)

### Step 2: Citation chain tracking (for top 2-3 papers)

- Forward citations: who cited this paper?
- Backward references: what did this paper cite?

### Step 3: Full text reading (2-3 most relevant papers)

Use Jina Reader, direct PDF links, or arXiv PDF for open-access papers.

### Step 4: Domain-specific database verification

Apply the Phase 4 domain-database mapping table above.

> Source: SCIENCE.md "Mandatory Search Protocol" lines 240-298

---

## Search Quality Checklist

Before presenting results, verify:

- [ ] At least 2 academic databases were searched with real API calls
- [ ] Results contain real DOIs/paper IDs (not fabricated)
- [ ] Citation counts are from the API response (not estimated)
- [ ] Each paper has a verifiable identifier (DOI, arXiv ID, PMID, or S2 URL)
- [ ] For social science: SSRN or domain-specific database also searched

> Source: SCIENCE.md "Search Quality Checklist" lines 301-307

---

## Systematic Review: PRISMA 2020 Protocol

For systematic reviews and meta-analyses, follow PRISMA 2020 (27 mandatory items):

1. **PICO Framework**: Population, Intervention, Comparator, Outcome
   - For qualitative research: use SPIDER framework instead
2. **Search Strategy**: Minimum 3 databases. Document exact queries, dates, result counts. Supplement with citation chaining.
3. **Quality Assessment**: Apply appropriate tool per study type:
   - RoB 2 for randomized controlled trials
   - ROBINS-I for non-randomized studies
   - Newcastle-Ottawa Scale for observational studies
   - GRADE for overall evidence certainty
4. **Meta-Analysis** (if applicable): forest plots, funnel plots, heterogeneity (I²/Q statistic), publication bias (Egger/Begg test)

> Source: SCIENCE.md "Systematic Review Protocol" lines 489-502

---

## Statistical Reporting Standards

When reporting quantitative findings:

- Report **effect sizes alongside p-values** — a significant p-value with tiny effect size is not meaningful
- Report **confidence intervals** for all estimates
- State assumptions of every statistical test and verify them
- Distinguish correlation from causation explicitly
- For any p-value claim, provide: test name, test statistic, p-value, effect size, CI, sample size
- When running multiple comparisons, apply appropriate correction (Bonferroni or FDR/Benjamini-Hochberg with FDR < 0.05 threshold)

> Source: SCIENCE.md "Statistical Rigor Standards" lines 532-540
