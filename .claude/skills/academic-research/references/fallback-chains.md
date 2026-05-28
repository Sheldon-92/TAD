# Fallback Chains — Source Failure Recovery Protocol

> Extracted from ScienceClaw SCIENCE.md lines 137-168 "Stuck Recovery Protocol" and "Fallback Chains by Data Source" table. Ensures research does not halt when a primary source fails.

---

## The 3-Strike Rule

**If the same error occurs 3 consecutive times with the same approach, that approach will not work. Change strategy immediately.**

This is a hard rule — not a suggestion. After 3 identical failures:

1. Stop retrying the same approach
2. Diagnose: What exactly is failing? (API down? Wrong query? Rate limited? Auth required?)
3. Switch to the next item in the fallback chain
4. If the entire phase is blocked after all fallbacks: document what failed and advance to the next research phase — do NOT restart from Phase 1

> Source: SCIENCE.md lines 137-141: "Stuck Recovery Protocol"

---

## Fallback Chain Tables

### Academic Literature Sources

| Primary | Fallback 1 | Fallback 2 | Last Resort |
|---------|-----------|-----------|-------------|
| OpenAlex | Semantic Scholar | Google Scholar (via web_search) | arXiv search |
| Europe PMC | OpenAlex (biomedical filter) | Semantic Scholar | CrossRef DOI lookup |
| Semantic Scholar | OpenAlex | Europe PMC | Google Scholar |
| arXiv | Semantic Scholar (arXiv filter) | Google Scholar | — |
| SSRN | Semantic Scholar | Google Scholar | RePEC/IDEAS |

> Source: SCIENCE.md "Fallback Chains by Data Source" lines 143-152

### Scientific Database Sources

| Primary | Fallback 1 | Fallback 2 | Last Resort |
|---------|-----------|-----------|-------------|
| UniProt | NCBI Gene/Protein | Ensembl | STRING protein search |
| ChEMBL | PubChem | DrugBank (web) | Open Targets |
| World Bank | FRED | IMF | OECD |
| ClinicalTrials.gov | WHO ICTRP (web) | PubMed clinical trial filter | — |
| Materials Project | AFLOW | NOMAD | — |

> Source: SCIENCE.md "Fallback Chains by Data Source" lines 143-152

### Full Text Access

| Primary | Fallback 1 | Fallback 2 | Last Resort |
|---------|-----------|-----------|-------------|
| Jina Reader (via DOI) | Semantic Scholar PDF link | arXiv PDF (if open access) | Abstract only + note limitation |

> Source: SCIENCE.md line 152

---

## Error Classification and Response

Different error types require different responses:

| Error Type | Signature | Response | Example |
|-----------|-----------|----------|---------|
| **Network / API error** | HTTP 5xx, timeout, connection refused | Auto-retry once, then use fallback chain | "PubMed API unresponsive, switching to Europe PMC..." |
| **Rate limit** | HTTP 429, "Too Many Requests" | Wait 30s, retry once. If persistent: note quota exhaustion | "API rate-limited (429), waiting 30s before retry..." |
| **Authentication required** | HTTP 401/403 | Switch to free alternative | "API requires authentication, switching to free tier..." |
| **No results** | HTTP 200 with empty results | Try alternative query terms first, then use fallback database | "Semantic Scholar returned 0 results, broadening search terms..." |
| **Data format changed** | Unexpected JSON structure | Try alternative API endpoint | "API returned unexpected format, trying alternative..." |

> Source: SCIENCE.md "Error recovery" lines 218-228

---

## Forced Advancement Rule

If a research phase is completely blocked (all fallback chains exhausted):

1. **Document exactly what failed**: which databases, what errors, what queries
2. **Advance to the next phase**: do NOT restart from Phase 1
3. **Note the gap**: in the final report, explicitly state which phase was incomplete and why
4. **Never loop**: returning to a failed phase without a new strategy is prohibited

This prevents infinite retry loops while ensuring the research makes forward progress.

> Source: SCIENCE.md lines 140-141: "If a phase is truly blocked after all fallbacks, document what failed and move to the next phase. Do NOT restart from Phase 1."

---

## Practical Decision Tree

```
Search fails
  ├── First failure?
  │     → Retry with same source (maybe transient)
  ├── Second failure (same error)?
  │     → Try alternative query terms on same source
  ├── Third failure (same error)?
  │     → STOP. Switch to Fallback 1 in chain table above
  │
  ├── Fallback 1 also fails?
  │     → Switch to Fallback 2
  ├── Fallback 2 also fails?
  │     → Switch to Last Resort
  ├── Last Resort also fails?
  │     → Document the gap. Advance to next research phase.
  │       DO NOT restart from Phase 1.
  └── All phases blocked?
        → Report: "Unable to find sources for [topic].
          Searched: [list databases]. All returned: [error type].
          Recommendation: [manual search / different angle / domain expert consultation]"
```

---

## Integration with TAD Workflow

### In Ralph Loop
Blake's Layer 1 self-check should verify: "Did I exhaust the fallback chain before declaring a search failed?"

### In Reflexion Cycle
The efficiency dimension (reflexion-cycle.md) captures fallback chain usage:
- Efficient: used fallback chain and found results quickly
- Inefficient: retried same failing source >3 times before switching

### In Knowledge Assessment
When a primary source consistently fails across sessions, record it in project-knowledge:
- Which API/database is unreliable
- What error pattern occurs
- Which fallback works best as replacement
