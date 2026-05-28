# Extracted Academic Writing Rules

Judgment rules with specific thresholds from ScienceClaw writing skills.
Every rule traced to source. Generic advice excluded.

---

## 1. Paper Structure (IMRaD)

**Title**: 10-15 words ideal. No abbreviations, no jargon.
> Source: skills/paper-writing/SKILL.md

**Abstract** (150-300 words): Background (1-2 sentences), Objective (1 sentence), Methods (2-3 sentences), Results (2-3 sentences with numbers), Conclusions (1-2 sentences).
> Source: skills/paper-writing/SKILL.md

**Introduction funnel**: broad context, thematic literature review, research gap, objective/hypothesis, approach overview, significance statement.
> Source: skills/paper-writing/SKILL.md

**Methods**: study design, participants (inclusion/exclusion), materials/instruments, procedure (reproducible detail), data analysis plan, ethical approvals.
> Source: skills/paper-writing/SKILL.md

**Results**: present in order of research questions. Text + tables + figures (no redundancy). Report exact p-values (not "p < 0.05" unless p < .001). Report effect sizes.
> Source: skills/paper-writing/SKILL.md

**Discussion**: key findings, comparison with literature, mechanistic explanation, strengths, limitations, future directions, conclusions.
> Source: skills/paper-writing/SKILL.md

Include CRediT author contributions, data availability, and COI statement.
> Source: skills/paper-writing/SKILL.md

---

## 2. Review Writing (Section-by-Section)

Full review: 12,000-15,000 words, 100-130 references. Cannot be written in one pass.
> Source: skills/review-writing/SKILL.md

### Per-Section Targets

- Section length: 1,500-2,500 characters.
- Biomedical sections: 15-25 candidates, select 10-15, cite 12-18.
- CS/AI sections: 20-30 candidates, select 15-20, cite 15-20.
> Source: skills/review-writing/SKILL.md

### Section Internal Structure

1. Opening thesis (1-2 sentences): topic and importance.
2. Development (2-3 paragraphs): timeline or logic.
3. Current state (1-2 paragraphs): consensus/controversy.
4. Critical evaluation (1 paragraph): limitations and gaps.
5. Closing bridge (1-2 sentences): leads to next section.
> Source: skills/review-writing/SKILL.md

### Citation Density

- Every substantive paragraph: at least 2-3 citations.
- Key data/numbers MUST have citation.
- More than 3 consecutive uncited sentences: flag.
- Max uncited paragraph: < 500 characters.
> Source: skills/review-writing/SKILL.md

### Forbidden Patterns

- Listing: "A studied X[1]. B studied Y[2]. C studied Z[3]."
- Vague: "achieved important progress", "has broad prospects."
- Abbreviated journal names anywhere (use "Nature Medicine" not "Nat Med").
- arXiv-only papers labeled as [J] (use [Z/OL]; conference-published use [C]).
> Source: skills/review-writing/SKILL.md

### Quality Metrics (Assembly Phase)

Average 12-18 citations/section. Track: citation coverage per paragraph, year distribution (2024-2026 / 2021-2023 / older), source type (journal/preprint/conference), cross-section reuse.
> Source: skills/review-writing/SKILL.md

---

## 3. Grant Writing

### NIH R01

Specific Aims (1 page): opening paragraph (problem/gap), what is known/missing, 2-3 independent aims with hypotheses, impact statement. Each aim independent (failure of one does not sink project).
> Source: skills/grant-writing/SKILL.md

**Approach per aim**: rationale, methods, preliminary data, expected outcomes, pitfalls + alternatives, timeline. Include rigor/reproducibility (biological variables, key resource authentication).
> Source: skills/grant-writing/SKILL.md

**Review criteria**: Significance, Investigators, Innovation, Approach, Environment. Each must be explicitly addressed.
> Source: skills/grant-writing/SKILL.md

### Page Limits

| Mechanism | Limit |
|-----------|-------|
| NIH R01 Research Strategy | 12 pages |
| NIH Specific Aims | 1 page |
| NIH Biographical Sketch | 5 pages |
| NSF Project Description | 15 pages |
| NSF Project Summary | 1 page (Overview + Intellectual Merit + Broader Impacts) |
| NSF Biographical Sketch | 3 pages |

NSF: font min 10pt, Times Roman, 1-inch margins.
> Source: skills/grant-writing/SKILL.md, skills/venue-templates/SKILL.md

---

## 4. Citation Styles

| Style | Format | Field |
|-------|--------|-------|
| APA 7th | (Author, Year); 3+ authors: et al. | Social sciences |
| IEEE | [1] numbered brackets | Engineering, CS |
| Vancouver | (1) numbered parentheses | Biomedical |
| Chicago | (Author Year, page) | Humanities |
| Nature | Superscript numbered | Natural sciences |

**By venue**: Nature/Science = superscript numbered; PLOS = Vancouver brackets; Cell = author-year; ACM/IEEE = numbered brackets; APA journals = APA 7th.
> Source: skills/paper-writing/SKILL.md, skills/venue-templates/SKILL.md

---

## 5. LaTeX Rules

### Required Packages

`booktabs` (tables), `natbib`/`biblatex` (citations), `siunitx` (units), `hyperref` (links), `graphicx` (figures), `amsmath` (equations), `cleveref` (cross-refs), `subcaption` (subfigures).
> Source: skills/scientific-writing/SKILL.md, skills/latex-writing/SKILL.md

### Journal Templates

| Journal | Document Class | Key Constraints |
|---------|---------------|-----------------|
| Nature | `article`, 12pt, times, 2.5cm margins | Title max 90 chars, abstract 150 words, text 2500 words, 30 refs, 6 figs |
| IEEE Conf | `IEEEtran` conference | Abstract 150-200 words |
| ACM | `acmart` sigconf,review | CCS concepts required |
| PNAS | `pnas-new` 9pt twocolumn | 6 pages, abstract 250 words, significance 120 words |
| APA 7 | `apa7` man,12pt | biblatex style=apa, backend=biber |

> Source: skills/latex-writing/SKILL.md

### Tables

Use `booktabs` (`\toprule`, `\midrule`, `\bottomrule`). No vertical lines. Caption ABOVE table.
> Source: skills/latex-writing/SKILL.md

### Figures

All venues: minimum 300 dpi. Vector (PDF/EPS) preferred. Nature accepts TIFF/EPS/PDF (RGB or CMYK). PLOS requires 300-600 dpi.
> Source: skills/venue-templates/SKILL.md, skills/latex-writing/SKILL.md

### BibTeX Commands

natbib: `\citet{}` = "Smith et al. (2024)", `\citep{}` = "(Smith et al., 2024)".
biblatex-apa: `\textcite{}`, `\parencite{}`.
> Source: skills/latex-writing/SKILL.md

### Pre-Submission Checklist

1. Page limits, font, margins per journal.
2. Abstract within word limit, no undefined abbreviations.
3. Figures >= 300 DPI.
4. Tables use `booktabs`, caption above.
5. All `\ref{}` and `\eqref{}` resolve.
6. All cited works in bibliography, no orphans.
7. Clean compilation with no warnings.
> Source: skills/latex-writing/SKILL.md

---

## 6. Page Limits by Venue

| Venue | Limit | Notes |
|-------|-------|-------|
| Nature Article | 5 pages | ~3000 words excl refs |
| Science Report | 5 pages | Figures count toward limit |
| PLOS ONE | No limit | — |
| NeurIPS | 8 pages | + unlimited refs/appendix |
| ICML | 8 pages | + unlimited refs/appendix |

> Source: skills/venue-templates/SKILL.md

---

## 7. Reviewer Response

Format: quote each comment, respond, list specific changes with page/line numbers. Address every point. Distinguish changes from rebuttals. Provide evidence for disagreements.
> Source: skills/scientific-writing/SKILL.md

---

## 8. Science Communication

**Press release**: active-voice headline, plain-language lead (who/what/when/where/why), PI quote, accessible background, implications, contact info.
> Source: skills/science-communication/SKILL.md

**Plain-language summary**: 8th-grade reading level. Replace jargon ("gene expression" = "how active a gene is"). Use analogies. One finding per paragraph. End with "Why it matters."
> Source: skills/science-communication/SKILL.md

**Twitter/X thread**: hook < 280 chars, 3-5 explanation tweets, include figure.
> Source: skills/science-communication/SKILL.md

---

## 9. Protocol Writing

Structure: title/version, purpose, safety/PPE, materials (with catalog numbers + lot numbers), preparation, procedure (numbered steps with exact quantities/temperatures/times/speeds), QC (acceptance criteria + troubleshooting table), data recording, references.

Precision: "Add 2.5 mL" not "add some." Every reagent: manufacturer + catalog number. "Incubate 30 min at 37C" not "incubate for a while." Mark critical steps. Version control.
> Source: skills/protocol-writing/SKILL.md

---

## 10. Patent Application

**Abstract**: 150 words max (problem, solution, advantage).

**Structure**: title (descriptive, not limiting), background (prior art limitations), summary (matches broadest claims), detailed description (enable reproduction), claims (independent=broadest + dependent=specific), drawings.

**Patentability**: enablement (skilled person can reproduce), novelty (element not in prior art), non-obviousness, written description (possessed at filing).

**Prior art search**: Google Patents, USPTO, WIPO, EPO, CNIPA; PubMed, Google Scholar; conference proceedings; product catalogs.
> Source: skills/patent-drafting/SKILL.md

---

## 11. Writing Quality

**Precision**: quantify ("increased 15%" not "significantly increased"). Distinguish correlation from causation. Hedge appropriately ("suggests" vs "proves"). Every claim needs citation.
> Source: skills/scientific-writing/SKILL.md, skills/paper-writing/SKILL.md

**Clarity**: one idea per paragraph, topic sentence first. Active voice preferred. Define abbreviations on first use.
> Source: skills/scientific-writing/SKILL.md

**Common issues**: dangling modifiers, pronoun ambiguity ("this" without referent), nominalization overuse, redundancy ("past history"), weak openings ("It is well known that...").
> Source: skills/scientific-writing/SKILL.md

**Venue-specific tone**: Nature/Science = accessible, story-driven; Cell = mechanistic depth, graphical abstract; NEJM/Lancet/JAMA = patient-centered, structured abstracts; NeurIPS/ICML = contribution bullets, ablation studies.
> Source: skills/venue-templates/SKILL.md

---

## 12. Zero-Hallucination Rules

- NEVER generate fake DOIs, journal names, PMIDs, or author names.
- BibTeX: only include fields verified through tool results.
- Unsure of LaTeX class: say so, suggest checking journal website.
- No source for a fact: write "reportedly" without citation, never fabricate.
> Source: skills/latex-writing/SKILL.md, skills/review-writing/SKILL.md
