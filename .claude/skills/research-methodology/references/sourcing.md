# Research Sourcing Reference

## Purpose
Detailed protocols for CAPABILITY.md Phase 2 (SOURCE). Load this file when entering the SOURCE phase.

---

## 1. GitHub-First Strategy (Full Detail)

The GitHub-First strategy is TAD's unique competitive advantage — no competitor framework uses this approach. It finds high-signal, low-noise sources by starting from curated lists maintained by domain experts.

### Execution Order

**Step 1: Awesome-List Discovery**
```
Search: site:github.com awesome [topic]
Target: Find 2-3 awesome-list repos
Action: Add each awesome-list repo URL to notebook
```
Why: Awesome-lists are curated by practitioners, pre-filtered for relevance.

**Step 2: Tool/Framework Repository Sourcing**
```
From each awesome-list, identify the top 10 most-starred or most-mentioned tools
For each tool: add the tool's main GitHub repo README URL
Target: 15-30 tool repos
```

**Step 3: Company/Vendor Repositories**
```
If topic is vendor-specific: add official GitHub repos
Include: sample apps, reference implementations, official SDKs
```

**Step 4: Documentation Sites**
```
Add: official docs sites (docs.{tool}.com, {tool}.readthedocs.io)
Use GitHub tree endpoint if docs are in repo: gh api repos/{owner}/{repo}/git/trees/{branch}?recursive=1
```

**Step 5: Academic/Article Sources (last)**
```
Only after GitHub exhausted
Search: arxiv.org, semanticscholar.org, engineering blogs
Prioritize: papers with GitHub implementations (higher signal)
```

### NotebookLM Source Addition (FULL MODE)

> `notebooklm_bin` is defined once in CAPABILITY.md §0.1. All invocations below use this variable — do NOT redefine it here.

```bash
# notebooklm_bin is set in CAPABILITY.md §0.1 — use that value

# Single source
"$notebooklm_bin" source add -n {notebook_id} "{url}"

# Deep research import (use for initial batch — 60-100 sources)
"$notebooklm_bin" source add-research --mode fast --import-all -n {notebook_id} "{query}"
# Note: --mode deep takes ~3 minutes and imports 60-100 sources — AskUserQuestion before running

# Always use -n flag (stateless); NEVER use: notebooklm use {id} then notebooklm source add
```

**Source budget enforcement:**
- After each batch: update `source.total_added` in research-state.yaml
- If total_added ≥ 100: AskUserQuestion "已添加 {N} 个来源（上限 100）。是否继续添加？"

---

## 2. Source Type Priority Matrix

| Priority | Type | Examples | When to Use |
|----------|------|---------|-------------|
| T1 | Official documentation | Official repo README, spec PDF, API docs | Always add first |
| T1 | Academic papers | arXiv preprints, conference papers, journal articles | For methodology/theory questions |
| T1 | Authoritative blog | Anthropic, Google, OpenAI, Microsoft Research | When topic is their technology |
| T2 | Industry reports | a16z, Gartner summaries, Forrester | Market/adoption questions |
| T2 | Engineering blogs | Netflix Tech, Meta Engineering, AWS Builders | Implementation patterns |
| T2 | Conference talks | NeurIPS, ICML, ACL proceedings | Technical depth |
| T3 | Community tutorials | Medium, Dev.to, personal blogs | Fill gaps, use sparingly |
| T3 | Forum posts | Reddit, HN discussions | Sentiment, failure modes |
| SKIP | Marketing pages | Vendor landing pages without technical content | Never add |
| SKIP | Paywalled content | Academic journals without preprints | Skip unless free |

---

## 3. Source Quality Pre-Check

Before adding a source, quick validation:

**FULL MODE (NotebookLM handles URL validation on add):**
- Source add will fail if URL returns non-200 — check `notebooklm source list -n {id}` for errors after batch add

**DEGRADED MODE (manual validation required):**
```
For each URL:
1. WebFetch: confirm URL returns HTTP 200
2. Check content length: skip if page < 500 words (likely redirect or placeholder)
3. Note URL in context for citation in Phase 5
```

---

## 4. DEGRADED MODE — WebSearch Fallback

When NotebookLM is unavailable:

```
For each sub-question in problem tree:
1. Construct 3 search queries:
   - Query 1: "[topic] [technology] how to" (practical)
   - Query 2: "[topic] [technology] best practices comparison" (comparative)
   - Query 3: "[topic] [technology] failure modes problems" (failure modes)

2. Execute WebSearch for each query
3. Read top 3 results per query using WebFetch
4. Note source URL + key excerpt in context

Total target: ≥9 WebSearch results, ≥15 URL reads across all sub-questions
```

Anti-hallucination in DEGRADED MODE:
- Layer 1: WebFetch each URL — if 404/timeout, do NOT cite that source
- Do NOT cite a source based on search result snippet alone — must WebFetch and read

---

## 5. SOURCE Phase Checklist

Before updating state to `phase: curate`:
- [ ] ≥15 sources added (FULL MODE) or ≥9 WebSearch results (DEGRADED MODE)
- [ ] GitHub-First order followed (awesome-lists first, articles last)
- [ ] Source budget checked (under 100)
- [ ] State updated: `source.total_added`, `errors_cleaned` (FULL MODE)
- [ ] DEGRADED MODE: all source URLs logged in context for Phase 5 citation
