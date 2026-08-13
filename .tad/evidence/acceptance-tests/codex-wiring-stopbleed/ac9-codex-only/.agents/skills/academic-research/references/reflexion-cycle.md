# Reflexion Cycle — Post-Task Self-Evaluation Protocol

> Extracted from ScienceClaw skills/skill-evolution/SKILL.md (VOYAGER-inspired pattern, Wang et al. 2023) and SCIENCE.md lines 517-528 "Reflexion Cycle". Adapted for TAD's Knowledge Assessment workflow.

---

## Purpose

> **Disambiguation**: This protocol evaluates the agent's *research process* (how well you searched, synthesized, etc.). For evaluating the quality of the *research output itself* (rigor, novelty, impact), see scholar-eval.md.

After completing a research task, the agent self-evaluates on 5 dimensions to:
1. Identify what worked and what didn't
2. Generate structured lessons for future tasks
3. Feed findings into TAD's Knowledge Assessment (project-knowledge entries)

This is NOT optional for literature surveys, comprehensive reviews, and systematic reviews. Quick factual lookups may skip it.

---

## The 5 Evaluation Dimensions

Score each dimension 1-5. A score of 3 is "adequate"; below 3 signals a problem worth investigating.

The 5 dimensions: completeness, accuracy, efficiency, depth, actionability.

| # | Dimension | Score 1 (Poor) | Score 3 (Adequate) | Score 5 (Excellent) |
|---|-----------|---------------|-------------------|-------------------|
| 1 | **completeness** | Searched 1 database, missed key papers | Searched 2+ databases, found most key papers | Exhaustive search across 3+ databases, citation chains traced, no known gaps |
| 2 | **accuracy** | Contains unverified claims or fabricated citations | All claims traceable to tool results, minor metadata gaps | Every claim verified against primary source, zero-hallucination check passed |
| 3 | **efficiency** | Excessive redundant searches, >50% wasted tool calls | Reasonable search strategy, <30% redundant calls | Targeted searches, minimal redundancy, efficient use of fallback chains |
| 4 | **depth** | Surface-level summary of abstracts only | Read 1-2 full papers, basic synthesis | Read 3+ full papers, citation chains both directions, cross-database verification |
| 5 | **actionability** | Vague findings, no concrete recommendations | Findings organized with some next steps | Clear findings with specific, prioritized recommendations and identified research gaps |

> Source: SCIENCE.md lines 518-521 (5 dimensions listed), skills/skill-evolution/SKILL.md lines 79-91 (analysis framework)

---

## When to Run the Reflexion Cycle

| Task Type | Reflexion Required? |
|-----------|-------------------|
| Quick factual (3-5 tool calls) | No — overhead not justified |
| Literature survey (20-40 tool calls) | Yes — after report is written |
| Comprehensive review (40-80 tool calls) | Yes — mandatory |
| Systematic review (80+ tool calls) | Yes — mandatory, per-phase + overall |

---

## Execution Protocol

### Step 1: Score Each Dimension

After saving the research report to a file, pause and score each dimension honestly:

```markdown
## Reflexion Cycle

| Dimension | Score (1-5) | Evidence |
|-----------|-------------|---------|
| Completeness | ? | Searched N databases, found N papers, traced N citation chains |
| Accuracy | ? | N citations verified, N unverifiable claims |
| Efficiency | ? | N total tool calls, ~N% were productive |
| Depth | ? | Read N full papers, reached Phase N of 6 |
| Actionability | ? | N specific recommendations, N research gaps identified |
```

### Step 2: Generate Structured Reflection

Answer these questions:

1. **What worked well?** Which search strategies, databases, or approaches were most productive?
2. **What failed?** Which searches returned nothing? Which databases were unreliable? Which strategies were dead ends?
3. **Key lessons**: What would you do differently next time for this type of research?
4. **Tool effectiveness**: Which APIs/databases were most useful? Any rate limits or access issues?
5. **Domain-specific insight**: Any domain-specific search tips discovered (e.g., "PubMed MeSH terms are more precise than free-text for biomedical queries")?

> Source: SCIENCE.md lines 522-525, skills/skill-evolution/SKILL.md lines 80-109

### Step 3: Assess Cross-Domain Transferability

Some research patterns work across disciplines. Check if your findings include:

| Pattern Type | Example | Transferable? |
|-------------|---------|--------------|
| Citation chain analysis | Forward + backward citations | Yes — works for any field with citation data |
| Database cross-verification | Verify claims against primary data | Yes — whenever primary databases exist |
| Effect size reporting | Report alongside p-values | Yes — all quantitative disciplines |
| PICO/SPIDER framework | Structured question formulation | Yes — adaptable beyond medicine |
| Fallback chain strategy | Alternative databases when primary fails | Yes — domain-specific chains transferable within domain |

If a pattern succeeded, note it for potential reuse in different research domains.

> Source: skills/skill-evolution/SKILL.md "Cross-Domain Knowledge Transfer" lines 126-140

---

## TAD Integration: Knowledge Assessment Feed

The Reflexion Cycle feeds directly into TAD's Knowledge Assessment:

### What to Capture in project-knowledge

After the Reflexion Cycle, if any dimension scored ≤ 2 OR if a new reusable pattern was discovered:

1. **Score ≤ 2 on any dimension**: Write a project-knowledge entry documenting:
   - What went wrong (specific, not generic)
   - Root cause analysis
   - Prevention strategy for next time

2. **New reusable pattern discovered**: Write a project-knowledge entry documenting:
   - The pattern (what, when, why)
   - Evidence of effectiveness (scores, outcomes)
   - Applicable domains/contexts

### Example Knowledge Entry

```markdown
### Biomedical Citation Chain Strategy — 2026-XX-XX
- **Discovery**: PubMed MeSH terms combined with Semantic Scholar citation chains
  find 3x more relevant papers than free-text search alone for biomedical topics.
  PubMed filters by controlled vocabulary; Semantic Scholar traces influence.
- **Action**: For biomedical literature surveys, always start with PubMed MeSH search,
  then trace citation chains via Semantic Scholar API.
```

> Source: skills/skill-evolution/SKILL.md lines 81-109 (analysis template), SCIENCE.md lines 526-528 (knowledge accumulation rules)

---

## Improvement Signals

Track these signals across research sessions to identify skill improvement opportunities:

| Signal | Indicates | Action |
|--------|-----------|--------|
| Repeated tool failures for same API | Endpoint changed or unreliable | Note in fallback-chains.md or project-knowledge |
| Consistently low depth scores (1-2) | Premature conclusion habit | Review anti-premature-conclusion rules |
| Low efficiency scores (1-2) | Redundant search strategies | Optimize search order and query design |
| User corrections on citations | Zero-hallucination violation | Review zero-hallucination.md self-check |
| New database discovered to be useful | Knowledge expansion | Note database + usage pattern for future tasks |

> Source: skills/skill-evolution/SKILL.md "Automated Improvement Detection" lines 118-125

---

## Anti-Premature Reflexion

The Reflexion Cycle itself must not be shallow. Before submitting the reflexion:

- Each dimension score must have a 1-sentence evidence justification (not just a number)
- "What failed" must list at least 1 specific failure (not "nothing failed")
- "Key lessons" must contain at least 1 actionable insight for future tasks
- If all scores are 5/5: double-check — perfect scores suggest insufficient self-criticism

> Source: skills/skill-evolution/SKILL.md line 163: "Don't optimize prematurely — wait for 5+ uses before proposing changes"
