# Literature & Academic Research — Extracted Judgment Rules

Consolidated from 9 ScienceClaw skills. Every rule has a specific threshold,
number, formula, or actionable checklist. Generic advice excluded.

---

## Quick Reference Table

| Rule | Threshold / Number | Source Skill(s) |
|------|-------------------|-----------------|
| Minimum databases per search | 3 complementary databases | literature-review, literature-search |
| Reporting-guideline selection | Systematic review (focused question + quality appraisal) → PRISMA 2020 = **27 items**; Scoping review (map breadth of evidence) → PRISMA-ScR = **20 essential + 2 optional items** (Tricco et al., Ann Intern Med 2018) | systematic-review |
| PRISMA 2020 checklist items | 27 items (Page et al., BMJ 2021;372:n71) — systematic reviews ONLY | systematic-review |
| Screening stages | 2-stage: title/abstract then full-text | systematic-review, literature-review |
| Inter-rater agreement (screening, rare-positive) | Report Cohen's kappa **+ Gwet's AC1** + raw % agreement + marginal prevalence (kappa paradox: kappa collapses when the include class is rare) | systematic-review |
| Evidence hierarchy levels | 7 tiers (systematic reviews highest) | academic-deep-research |
| Confidence annotations | 4 levels: HIGH / MEDIUM / LOW / SPECULATIVE | academic-deep-research |
| Research cycles per theme | Minimum 2 full cycles | academic-deep-research |
| web_search coverage | count=20 per cycle for comprehensive coverage | academic-deep-research |
| User checkpoints | 3 mandatory stop points | academic-deep-research |
| Citation density | 1-2 citations per paragraph | academic-deep-research |
| Report sections minimum | 6-8+ paragraphs per major section | academic-deep-research |
| Citation count: Noteworthy (0-3yr) | 20+ citations | literature-review, citation-management |
| Citation count: Highly Influential (0-3yr) | 100+ citations | literature-review, citation-management |
| Citation count: Significant (3-7yr) | 100+ citations | literature-review, citation-management |
| Citation count: Landmark (3-7yr) | 500+ citations | literature-review, citation-management |
| Citation count: Seminal (7+yr) | 500+ citations | literature-review, citation-management |
| Citation count: Foundational (7+yr) | 1000+ citations | literature-review, citation-management |
| Senior researcher h-index threshold | >40 | literature-review, citation-management |
| Journal Tier 1 IF threshold | Top multidisciplinary (Nature, Science, Cell, NEJM, Lancet, JAMA, PNAS) | literature-review, citation-management |
| Journal Tier 2 IF threshold | IF > 10 or top conferences (NeurIPS, ICML, ICLR) | literature-review, citation-management |
| Journal Tier 3 IF threshold | IF 5-10 | literature-review, citation-management |
| Impact Factor formula | Citations in year N to papers published in N-1 and N-2 | citation-analysis |
| CiteScore formula | Citations over 4 years / documents over 4 years | citation-analysis |
| h5-index window | h-index of articles published in last 5 years | citation-analysis |
| i10-index threshold | Papers with >= 10 citations | citation-analysis |
| g-index formula | Largest g where top g papers have >= g^2 total citations | citation-analysis |
| Semantic Scholar rate limit | No key = shared throttled pool; individual key = 1 req/s across all endpoints (no 10/s burst) | literature-search, citation-analysis |
| OpenAlex auth + quota (2026) | Free API key REQUIRED; credit budget ≈ 100k credits/day (≈$1/day), 100 req/s cap; list call = 10 credits (mailto polite-pool retired) | literature-search, citation-analysis |
| arXiv rate limit | ~1 request / 3 seconds | literature-search |
| CrossRef rate limit (no key) | 1 req/sec; 50 req/sec with mailto | literature-search, crossref-search |
| CrossRef deep paging threshold | Use cursor=* for > 10,000 results | crossref-search |
| CrossRef rows max | 1000 per request | crossref-search |
| Deduplication primary key | DOI (most reliable), then normalized title | literature-search, literature-review |
| RCT quality tool | RoB 2 (Cochrane Risk of Bias tool) | systematic-review, literature-review |
| Non-randomized quality tool | ROBINS-I | systematic-review |
| Observational quality tool | Newcastle-Ottawa Scale | systematic-review, literature-review |
| SR quality tool | AMSTAR 2 | literature-review |
| Certainty of evidence framework | GRADE (per outcome) | systematic-review |
| Heterogeneity statistics | I-squared, Cochran's Q, tau-squared | systematic-review |
| Effect size types | SMD, OR, RR, HR | systematic-review |
| Research question framework | PICO (Population, Intervention, Comparator, Outcome) | systematic-review, literature-review |
| Thematic grouping | 3-5 major themes per review | literature-review |
| BibTeX page range format | `--` (double dash), not single dash | citation-management |
| Citation key convention | FirstAuthor2024keyword | citation-management |

---

## 1. Multi-Database Search

### Database Priority and Selection

Execute searches in this order. Never rely on a single database.

1. **Semantic Scholar** (PRIMARY) -- best relevance ranking, AI TLDR summaries, citation graph, 200M+ papers
2. **OpenAlex** (PRIMARY) -- 250M+ works, powerful filtering, open access URLs
3. **arXiv** -- preprints in physics, math, CS, biology, finance, statistics
4. **PubMed/MEDLINE** -- biomedical and life sciences, 35M+ citations, MeSH controlled vocabulary
5. **CrossRef** -- DOI resolution and metadata enrichment ONLY

> Source: skills/literature-search/SKILL.md, skills/literature-review/SKILL.md

**CrossRef search relevance is poor.** Never use CrossRef `/works?query=` as primary discovery engine. Use only for DOI-based lookups and metadata enrichment.

> Source: skills/literature-search/SKILL.md, skills/crossref-search/SKILL.md

### Mandatory Search Protocol

1. Search Semantic Scholar first (always, real API call)
2. Search OpenAlex for broader coverage + OA links
3. Add discipline-specific database (PubMed for biomedicine, arXiv for physics/CS/math)
4. Deduplicate by DOI (primary), then normalized title (fallback)
5. Rank: S2 relevance > citation count > influential citations > recency
6. Citation chain top 3-5 seed papers (forward + backward)

> Source: skills/literature-search/SKILL.md

### Rate Limits

| Database | Without Key | With Key / Polite |
|----------|------------|-------------------|
| Semantic Scholar | 100 req / 5 min | 1/sec sustained |
| OpenAlex | 10 req/sec (with mailto) | Same |
| arXiv | ~1 req / 3 sec | Same |
| CrossRef | 1 req/sec | 50 req/sec (with mailto) |

CrossRef: `cursor=*` for > 10,000 results. Max `rows=1000` per request.

> Source: skills/literature-search/SKILL.md, skills/crossref-search/SKILL.md

---

## 2. PRISMA Pipeline (Systematic Review)

### Reporting-Guideline Decision Rule (pick the RIGHT instrument first)

PRISMA is a family, not one checklist. Choose by review TYPE before drafting:

- **Systematic review** (answers a focused question, appraises study quality, often pools effects) → **PRISMA 2020 = 27-item checklist** (Page et al., BMJ 2021;372:n71).
- **Scoping review** (maps the breadth/extent of evidence, no quality appraisal or pooling) → **PRISMA-ScR = 20 essential items + 2 optional items** (Tricco et al., Ann Intern Med 2018; https://www.equator-network.org/reporting-guidelines/prisma-scr/, retrieved 2026-06-13). Do NOT force the 27-item PRISMA 2020 onto a scoping review.

> Source: PRISMA 2020 (Page et al.) + PRISMA-ScR extension (Tricco et al. 2018), retrieved 2026-06-13.

### Protocol Development

- Research question: **PICO** framework (Population, Intervention, Comparator, Outcome)
- Pre-register (PROSPERO or OSF). Define inclusion/exclusion criteria BEFORE searching.
- Never modify criteria after seeing results without documented justification.

> Source: skills/systematic-review/SKILL.md, skills/literature-review/SKILL.md

### Two-Stage Screening

1. **Title/abstract**: Apply criteria, flag uncertain cases
2. **Full-text**: Evaluate all criteria, document exclusion reasons
3. Track inter-rater agreement (multiple reviewers). **For screening, do NOT report Cohen's kappa alone:** the include (positive) class is RARE, which triggers the **kappa paradox** — kappa becomes artificially low/unstable when one class is rare even at high raw agreement. Report **Cohen's kappa + Gwet's AC1** (AC1 is designed for the rare-class case) **+ raw percent agreement + marginal prevalence**. (Gwet's AC1 vs kappa for screening retrieved 2026-06-13, https://mappedresearch.com/blog/inter-rater-reliability-screening.)

> Source: skills/systematic-review/SKILL.md; kappa-paradox / Gwet's AC1 correction retrieved 2026-06-13

### Risk of Bias Assessment (Step 5)

| Study Type | Assessment Tool |
|-----------|----------------|
| RCTs | RoB 2 (Cochrane Risk of Bias) |
| Non-randomized studies | ROBINS-I |
| Observational studies | Newcastle-Ottawa Scale |
| Systematic reviews (quality of) | AMSTAR 2 |

Assess each domain: selection, performance, detection, attrition, reporting. Evaluate overall certainty using **GRADE** framework per outcome separately.

> Source: skills/systematic-review/SKILL.md, skills/literature-review/SKILL.md

### Meta-Analysis

- Effect sizes: **SMD, OR, RR, HR** as appropriate
- Models: random-effects or fixed-effects
- Heterogeneity: **I-squared**, **Cochran's Q**, **tau-squared**
- Sensitivity: leave-one-out, trim-and-fill, funnel plots

> Source: skills/systematic-review/SKILL.md

### PRISMA 2020 Reporting

Complete **27-item checklist** (Page et al., BMJ 2021;372:n71). Required outputs: PRISMA flow diagram (counts at each stage), characteristics table, risk-of-bias summary (traffic light), forest/funnel plots, GRADE summary of findings table.

> Source: skills/systematic-review/SKILL.md

### Review Quality Checklist

- [ ] All DOIs verified via CrossRef
- [ ] Citations in one consistent style
- [ ] PRISMA flow diagram included (systematic reviews)
- [ ] Search methodology documented (queries, dates, counts per database)
- [ ] Inclusion/exclusion criteria stated
- [ ] Results organized thematically (NOT study-by-study)
- [ ] Quality assessment with named tool (RoB 2 / Newcastle-Ottawa / AMSTAR 2)
- [ ] Minimum 3 databases searched
- [ ] At least 2 independent reviewers (systematic reviews)

> Source: skills/literature-review/SKILL.md, skills/systematic-review/SKILL.md

---

## 3. Citation Analysis

### Bibliometric Formulas

**h-index**: Largest h such that h papers have >= h citations each.

**g-index**: Largest g such that the top g papers have >= g^2 total citations.

**i10-index**: Count of papers with >= 10 citations.

**Field-Weighted Citation Impact (FWCI)**: Citations / expected citations in field.

**Citation velocity**: Citations per year since publication.

**Impact Factor**: Citations in year N to papers published in years N-1 and N-2.

**CiteScore**: Citations over 4 years / documents over 4 years.

**h5-index**: h-index of articles published in the last 5 complete calendar years.

> Source: skills/citation-analysis/SKILL.md

### Citation Count Classification

| Paper Age | Citation Count | Classification |
|-----------|---------------|----------------|
| 0-3 years | 20+ | Noteworthy |
| 0-3 years | 100+ | Highly Influential |
| 3-7 years | 100+ | Significant |
| 3-7 years | 500+ | Landmark Paper |
| 7+ years | 500+ | Seminal Work |
| 7+ years | 1000+ | Foundational |

> Source: skills/literature-review/SKILL.md, skills/citation-management/SKILL.md

### Journal / Venue Tier System

| Tier | Criteria | Examples |
|------|----------|---------|
| Tier 1 (Always Prefer) | Top multidisciplinary | Nature, Science, Cell, NEJM, Lancet, JAMA, PNAS, Nature Medicine, Nature Biotechnology |
| Tier 2 (High Priority) | IF > 10, top conferences | NeurIPS, ICML, ICLR, high-impact specialized journals |
| Tier 3 (Include When Relevant) | IF 5-10 | Respected specialized journals |
| Tier 4 (Use Sparingly) | IF < 5 | Lower-impact peer-reviewed venues |

> Source: skills/literature-review/SKILL.md, skills/citation-management/SKILL.md

### Author Reputation Indicators

- Senior researchers: **h-index > 40** in established fields
- Multiple Tier-1 publications in the relevant field
- Leadership at recognized institutions
- Awards, editorial positions, society fellowships

> Source: skills/literature-review/SKILL.md, skills/citation-management/SKILL.md

### Network Analysis Methods

- **Co-citation clustering**: cluster highly co-cited pairs into research fronts
- **Citation burst detection** (Kleinberg): sudden per-year citation increases = active fronts
- **Bibliographic coupling**: shared references = parallel research streams
- **Key metrics**: PageRank (influence), betweenness centrality (bridge papers), Louvain communities (resolution=1.0)

> Source: skills/citation-analysis/SKILL.md

### Bibliometric Best Practices

- Canonical IDs: Semantic Scholar paperId or DOI
- **Filter self-citations** for impact metrics
- **FWCI** (field-normalized) for cross-discipline comparisons
- Report data collection date (counts change daily)

> Source: skills/citation-analysis/SKILL.md

---

## 4. Bibliography Management

### BibTeX Required Fields

| Entry Type | Required Fields |
|-----------|----------------|
| `@article` | author, title, journal, year, volume, number, pages, doi |
| `@inproceedings` | author, title, booktitle, year, pages |
| `@book` | author, title, publisher, year |
| `@misc` | author, title, year, howpublished/url |

> Source: skills/citation-management/SKILL.md

### BibTeX Formatting Rules

- Key convention: `FirstAuthor2024keyword`
- Page ranges: `--` (double dash). Author format: `{Last1, First1 and Last2, First2}`
- Protect caps in titles with `{}`. Include DOI for all modern publications.
- Dedup: DOI primary, normalized title fallback. Prefer published over preprint.

> Source: skills/citation-management/SKILL.md, skills/literature-search/SKILL.md

### Citation Validation (10-Point)

1. DOI resolves via doi.org  2. Metadata matches CrossRef  3. Required fields present
4. Year is 4-digit  5. Volume/number numeric  6. Pages use `--`
7. No duplicate DOIs  8. Valid BibTeX syntax  9. Keys unique  10. Special chars escaped

> Source: skills/citation-management/SKILL.md

### Metadata Source Priority

1. **CrossRef** (DOI articles, free) 2. **PubMed E-utilities** (biomedical, free) 3. **arXiv API** (preprints, free) 4. **DataCite** (datasets/software, free)

> Source: skills/citation-management/SKILL.md

---

## 5. Evidence Hierarchy and Confidence

### 7-Tier Evidence Hierarchy

1. Systematic reviews & meta-analyses -- Highest confidence
2. Randomized controlled trials -- High confidence
3. Cohort / longitudinal studies -- Medium-high confidence
4. Expert consensus / guidelines -- Medium confidence
5. Cross-sectional / observational -- Medium confidence
6. Expert opinion / editorials -- Lower confidence (flag as such)
7. Media reports / blogs -- Lowest confidence (verify against primary sources)

> Source: skills/academic-deep-research/SKILL.md

### Confidence Annotations

- **[HIGH]**: Multiple high-quality sources agree
- **[MEDIUM]**: Limited or mixed evidence
- **[LOW]**: Single source, preliminary, or needs verification
- **[SPECULATIVE]**: Hypothesis or emerging area with no strong evidence

> Source: skills/academic-deep-research/SKILL.md

### Minimum Research Cycles

- **2 cycles per theme** (mandatory). Cycle 1: broad (count=20) -> synthesize -> gaps. Cycle 2: targeted on gaps -> deep fetch -> cross-reference.
- Every conclusion: **multiple sources**. All contradictions: documented + analyzed.
- **3 user stop points**: engagement, plan approval, final report.

> Source: skills/academic-deep-research/SKILL.md

---

## 6. Domain-Specific Paper Assessment Checklists

| Study Type | Checklist / Tool | Key Items |
|-----------|-----------------|-----------|
| RCT | CONSORT | Randomization, allocation concealment, blinding (single/double/triple), ITT vs per-protocol, dropout rates |
| Observational | STROBE + Newcastle-Ottawa | Confounding control, selection bias |
| ML Papers | (no standard) | Train/val/test split, baselines, ablation, significance, compute cost, code/data availability |
| Qualitative | (varies) | Sampling strategy, data saturation, coding method, reflexivity, triangulation |

> Source: skills/paper-analysis/SKILL.md

---

## 7. Anti-Patterns

### Zero-Hallucination Rule (ABSOLUTE -- appears in 4/9 skills)

Every citation detail MUST come from a tool result in the current session. Before presenting any paper: "Did a tool in THIS conversation return this?" Forbidden: fabricating titles/authors/DOIs/counts, substituting training knowledge for 0-result searches, presenting S2 TLDRs as own analysis.

> Source: skills/literature-search/SKILL.md, skills/citation-analysis/SKILL.md, skills/crossref-search/SKILL.md, skills/paper-analysis/SKILL.md

### Other Anti-Patterns

| Anti-Pattern | Rule | Source |
|-------------|------|--------|
| CrossRef as search engine | Use only for DOI resolution, never `/works?query=` for discovery | literature-search, crossref-search |
| Study-by-study summaries | Group by 3-5 themes; papers may appear in multiple themes | literature-review |
| Single-database search | Minimum 3 complementary databases | literature-review |
| Unverified citations | Every DOI must resolve via doi.org + metadata match | literature-review, citation-management |
| Post-search criteria change | Never modify inclusion criteria after seeing results without justification | systematic-review, literature-review |
| Lists/tables in final report | Final output = flowing prose only; structured OK in planning phase | academic-deep-research |
| Citing preprints over published | Check if published version exists; prefer peer-reviewed | literature-review, citation-management |
