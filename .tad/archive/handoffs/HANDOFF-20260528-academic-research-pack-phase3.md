---
task_type: mixed
e2e_required: no
research_required: yes
git_tracked_dirs: [".tad/capability-packs/academic-research", ".claude/skills/academic-research"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Academic Research Pack — Phase 3: Skill Library Migration

**From:** Alex | **To:** Blake | **Date:** 2026-05-28
**Epic:** EPIC-20260527-academic-research-pack.md (Phase 3/6)

---

## 🔴 Gate 2: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
Extract judgment rules from ScienceClaw's 60 P1 + 90 P2 skills into **10 consolidated cluster reference files**. Each file merges rules from 5-20 skills in one research domain. NOT 80 individual files — consolidated references per blueprint Decision 1. (Originally 8 clusters; expert review split 2 oversized clusters to stay within 400-line budget.)

### 1.2 Why
Phase 2 built the HOW (research protocol, zero-hallucination, quality rubric). Phase 3 adds the WHAT — domain-specific judgment rules for literature search, database querying, statistics, visualization, scientific writing, and domain sciences. After this, the pack has actionable content for real research tasks.

### 1.3 Intent Statement
**真正要解决的问题**: The pack currently teaches methodology but has no domain-specific content. A researcher asking "do a systematic review of CRISPR therapy" gets the protocol (how many phases, how to cite) but not the domain knowledge (which databases to query, what statistical methods to use, how to write a PRISMA report).

**不是要做的**:
- ❌ NOT database API integration / MCP servers (Phase 4)
- ❌ NOT multimodal image analysis (Phase 5)
- ❌ NOT the 135 P3 (nice-to-have) skills — only P1 + P2
- ❌ NOT rewriting skills verbatim — EXTRACT judgment rules with specific thresholds

---

## 📚 Project Knowledge

**⚠️ Blake 必须注意**:
1. **Anti-AI-Slop Quality Bar** (architecture.md) — Only extract rules with specific thresholds/numbers. Generic advice ("use appropriate statistical test") = skip.
2. **ScienceClaw Skill Decoupling** (architecture.md) — 0/285 skills have runtime deps. All content is portable.

---

## 2. Source Material (Blake MUST Read)

1. `.tad/evidence/research/scienceclaw/skill-taxonomy.md` — the 285-skill taxonomy with P1/P2/P3 priorities and anti-slop H/M/L scores. **Use this as your roadmap** — process P1 skills first, then P2.
2. Re-clone ScienceClaw: `git clone https://github.com/beita6969/ScienceClaw.git /tmp/scienceclaw-study` (if not present)
3. `.claude/skills/academic-research/SKILL.md` — the existing router (Phase 2). You will update its Quick Rule Index to point to new references.

---

## 3. Technical Design

### 3.1 Eight Cluster Reference Files

| # | Reference File | Source Skills (P1+P2 from taxonomy) | Expected Content |
|---|---------------|-------------------------------------|-----------------|
| 1 | `literature-search.md` | literature cluster (10 skills: literature-search, systematic-review, citation-analysis, literature-review, paper-analysis, academic-deep-research, citation-management, crossref-search, lit-synthesizer, biorxiv-search) | Multi-database search protocol, PRISMA pipeline steps, citation network analysis, bibliography management |
| 2a | `database-apis-general.md` | General academic databases (14 skills: semantic-scholar, openalex, pubmed, arxiv, crossref, dblp, ssrn, world-bank, wikipedia, wikidata, google-scholar fallback, etc.) | Search API endpoints, query syntax, rate limits, auth, citation metadata parsing |
| 2b | `database-apis-life-sciences.md` | Life science databases (14 skills: uniprot, chembl, ncbi, pdb, clinicaltrials, kegg, ensembl, gnomad, clinvar, reactome, geo, opentargets, pubchem, string) | Protein/gene/drug/pathway query templates, ID cross-reference patterns |
| 3 | `statistics.md` | statistics + analysis clusters (16 skills: statistical-testing, statsmodels, biostatistics, scipy, scikit-learn, meta-analysis, data-analysis, exploratory-data-analysis, polars, data-transform, etc.) | Statistical test selection rules, meta-analysis methodology (DerSimonian-Laird, I², FDR<0.05), effect size calculation, power analysis thresholds |
| 4 | `writing.md` | writing cluster P1+P2 (13 skills: paper-writing, latex-writing, grant-writing, scientific-writing, scientific-manuscript, article-writing, review-writing, protocol-writing, science-communication, patent-drafting, regulatory-drafting, patent-analysis, regulatory-submission) | Paper structure rules (IMRaD), grant writing (NIH Specific Aims format), LaTeX conventions, PRISMA reporting checklist |
| 5 | `visualization.md` | visualization cluster P1+P2 (9 skills: matplotlib, plotly, seaborn, data-visualization-expert, data-viz-plots, data-visualization-biomedical, scientific-visualization, infographics, scientific-schematics) | Publication-quality figure rules (300 DPI, journal color palettes), chart selection matrix, statistical plot conventions (forest plot, funnel plot, volcano plot) |
| 6a | `domain-biomedical.md` | Biomedical + life science domains (16 skills: bioinformatics, genomics, protein-structure, drug-discovery, epidemiology, clinical, neuroscience, food-science, scanpy, biopython, etc.) | Bioinformatics pipelines, gene/protein analysis protocols, clinical research methodology, epidemiological study design |
| 6b | `domain-physical.md` | Physical + computational sciences (15 skills: chemistry, materials-science, environmental-science, physics-solver, quantum-computing, molecular-dynamics, energy-systems, astronomy, pymatgen, rdkit, etc.) | Materials screening protocols, molecular dynamics setup, computational chemistry workflows, geospatial analysis |
| 7 | `domain-social.md` | domain-social P1+P2 (6 skills: economics-analysis, political-science, psychology-research, linguistics-analysis, education-research, social-science-research) | Social science methodology (surveys, experiments, econometrics), key data sources (World Bank, FRED, census), IRB considerations |
| 8 | `experiment-design.md` | research-workflow cluster P1+P2 (16 skills: experiment-design, experimental-design, reproducibility, research-ethics, hypothesis-generation, knowledge-discovery, creative-thinking-for-research, convergence-study, scientific-problem-selection, etc.) | RCT design rules, sample size calculation, blinding protocols, reproducibility checklist, hypothesis generation methodology |

### 3.2 Extraction Rules (MANDATORY)

For each source skill SKILL.md:
1. **Read the full file** (not just frontmatter)
2. **Extract rules with specific thresholds** (H-rated): numbers, formulas, checklist items with counts, specific tool names
3. **Cite source**: every rule must have `> Source: skills/{skill-name}/SKILL.md` attribution
4. **Skip generic advice** (L-rated): "use appropriate methods", "ensure quality", "follow best practices"
5. **Merge overlapping content**: if 3 skills say the same thing, keep the most specific version with all 3 cited
6. **Preserve domain-specific vocabulary**: don't paraphrase "DerSimonian-Laird random-effects model" as "statistical model"

### 3.3 Reference File Structure (each file follows this pattern)

```markdown
# {Cluster Name} — Academic Research Reference

> Consolidated judgment rules from {N} ScienceClaw skills.
> Source: /tmp/scienceclaw-study/skills/

## Quick Reference
| Rule | Threshold | Source Skill |
|------|-----------|-------------|
| {rule name} | {specific number} | {skill-name} |

## Detailed Rules

### {Rule Category 1}
{detailed judgment rules with specific thresholds}
> Source: skills/{skill-name}/SKILL.md

### {Rule Category 2}
...

## Anti-Patterns
- ❌ {common mistake from ScienceClaw anti-patterns}
```

---

## 4. Implementation Steps

### Task 1: Re-clone + Read Taxonomy (10 min)
1. `git clone https://github.com/beita6969/ScienceClaw.git /tmp/scienceclaw-study` (if not present)
2. Read skill-taxonomy.md — identify all P1 (60) and P2 (90) skills by cluster
3. Plan reading order: P1 H-rated first (35 skills), then P1 M-rated (25), then P2 H-rated, then P2 M-rated

### Task 2: Extract + Write Cluster References (80 min)
For each of the 8 reference files:
1. Read ALL P1 skills in that cluster (full SKILL.md content from clone)
2. Read P2 H-rated skills in that cluster
3. Skim P2 M-rated skills (first 20 lines — include if specific thresholds found)
4. Extract judgment rules per §3.2 extraction rules
5. Write reference file per §3.3 structure
6. Verify: each file has ≥3 specific numeric thresholds (anti-slop check)

### Task 3: Update SKILL.md Quick Rule Index (10 min)
1. Read current SKILL.md
2. Add Quick Rule Index section pointing to all 8 new reference files
3. Update Step 2 (load references) to include cluster references

### Task 4: Re-install + Verify (10 min)
1. `bash .tad/capability-packs/academic-research/install.sh --agent=claude-code`
2. Verify all 13 reference files present (5 protocol + 8 cluster)
3. Verify SKILL.md Quick Rule Index points to all references

---

## 5. Files to Create/Modify

| # | File | Action |
|---|------|--------|
| 1-10 | .tad/capability-packs/academic-research/references/{10 cluster files} | CREATE |
| 11 | .tad/capability-packs/academic-research/CAPABILITY.md | MODIFY (Quick Rule Index — this becomes SKILL.md on install) |
| 12 | .claude/skills/academic-research/ (via re-install) | MODIFY |

---

## 9. Acceptance Criteria

| # | Requirement | Verification |
|---|------------|-------------|
| AC1 | 10 cluster reference files created | `ls .tad/capability-packs/academic-research/references/*.md \| wc -l` = 15 (5 protocol + 10 cluster) |
| AC2 | Each cluster file cites source skills | `for f in literature-search database-apis-general database-apis-life-sciences statistics writing visualization domain-biomedical domain-physical domain-social experiment-design; do c=$(grep -c '> Source: skills/' .tad/capability-packs/academic-research/references/$f.md 2>/dev/null); echo "$f: $c"; done` — each ≥ 3 |
| AC3 | P1 skills covered ≥ 50 of 60 | `grep -rohE '> Source: skills/[a-z0-9_-]+' .tad/capability-packs/academic-research/references/ \| sed 's/> Source: //' \| sort -u \| wc -l` ≥ 50 |
| AC4 | Anti-slop: each cluster file has ≥ 3 numeric thresholds | Manual check: count lines with specific numbers per file |
| AC5 | SKILL.md Quick Rule Index lists all 15 refs | `grep -c 'references/' .claude/skills/academic-research/SKILL.md` ≥ 20 |
| AC6 | Install succeeds with all 15 refs | `bash .tad/capability-packs/academic-research/install.sh --agent=claude-code && ls .claude/skills/academic-research/references/*.md \| wc -l` = 15 |
| AC7 | Each reference ≤ 400 lines | `wc -l .tad/capability-packs/academic-research/references/*.md \| grep -v total \| awk '{if($1>400) print "FAIL: "$2}'` = empty |
| AC8 | Both database-apis files have API patterns | `grep -cE 'api\.|/v[0-9]|curl|endpoint|REST' .tad/capability-packs/academic-research/references/database-apis-general.md` ≥ 5 AND same for database-apis-life-sciences.md |
| AC9 | statistics.md has specific formulas/thresholds | `grep -cE 'FDR|p.value|0\.05|I²|DerSimonian|effect.size|power|sample.size' .tad/capability-packs/academic-research/references/statistics.md` ≥ 5 |
| AC10 | No P2/L-rated generic content | Manual: spot-check 3 random rules — each must have a specific threshold or checklist with item count |

---

## 10. Important Notes

### 10.1 Scope Control
This is the LARGEST phase by content volume. Focus on QUALITY over QUANTITY:
- 35 H-rated P1 skills are the core — extract everything
- 25 M-rated P1 skills — extract if they have domain-specific content
- 90 P2 skills — extract only H-rated or highly specific rules; skip generic content
- If a file exceeds 400 lines, split or trim the least-specific rules

### 10.2 Deduplication
The taxonomy notes 12 duplicate skill pairs (e.g., statsmodels vs statsmodels-stats). When encountering duplicates:
- Read both, keep the MORE SPECIFIC version
- Cite both in the source attribution

### 10.3 Sub-Agent Suggestions
- code-reviewer: verify reference file structure consistency + source citation completeness
- backend-architect: verify database-apis.md covers the right databases per blueprint Decision 3

---

## 11. Decision Summary

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | File organization | 10 consolidated files (split from 8 per expert review) | database-apis (28 skills) and domain-natural (31 skills) exceeded 400-line budget — split each into 2 |
| 2 | Extraction priority | P1 H-rated first, then P1 M, then P2 H | Anti-slop: specific thresholds are highest value |
| 3 | Line budget | ≤400 per file, trim least-specific if exceeded | NFR2 from Phase 2 (raised from 300 per expert review) |
| 4 | Source citation format | `> Source: skills/{name}/SKILL.md` (exact format, AC3 grep depends on it) | Expert review: AC3 pattern must match Blake's citation format exactly |

## 9.2 Expert Review Status

| Expert | Status | Key Findings |
|--------|--------|-------------|
| code-reviewer | ✅ CONDITIONAL PASS | P0: AC1 count wrong, AC3 grep fragile. P1: AC5 threshold low |
| backend-architect | ✅ CONDITIONAL PASS | P0: database-apis exceeds 400 lines (28 skills), AC3 grep. P1: domain-natural same risk, CAPABILITY vs SKILL naming, AC8 BRE/ERE |

**P0 Resolution:**
| # | Issue | Fix | Status |
|---|-------|-----|--------|
| 1 | AC1 wrong count | Changed to `= 15` (5 protocol + 10 cluster) | ✅ |
| 2 | AC3 grep fragile | Rewrote with `-rohE` + `sed` + explicit `> Source:` prefix | ✅ |
| 3 | database-apis too large | Split into general + life-sciences (14 skills each) | ✅ |
| 4 | domain-natural too large | Split into biomedical + physical (16+15 skills) | ✅ |
