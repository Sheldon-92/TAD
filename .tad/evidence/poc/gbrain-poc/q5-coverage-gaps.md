# Q5: Methodology Coverage Gaps

**Query**: "What areas of TAD methodology lack principle or pattern coverage?"
**Commands**:
- `$GBRAIN search "methodology gaps uncovered areas missing principle"` → No results
- `$GBRAIN think "What areas of TAD methodology lack principle or pattern coverage?"` → Requires API key

## Raw Results

### Search: No results
```
No results.
```

### Think:
```
# What areas of TAD methodology lack principle or pattern coverage?

(no LLM available — set ANTHROPIC_API_KEY or pass `client`)

## Gaps
- no LLM available; gather succeeded but synthesis skipped

---
Model: anthropic:claude-opus-4-7 | Pages: 4 | Takes: 0 | Graph: 0 | Citations: 0
Warnings: NO_ANTHROPIC_API_KEY
```

## Evaluation

**Verdict: ❌ 无用**

**Reasoning**:
- The 6-word query "methodology gaps uncovered areas missing principle" returned ZERO results
- Investigation (P1-4 fix): simpler queries DO return results:
  - `search "methodology gaps missing"` → 4 results (e.g., research-methodology analysis, workflow measurement)
  - `search "principle coverage"` → 3 results (e.g., handoff, blake review, google-skills research)
  - `search "TAD"` → still works (index alive)
- The zero-result was NOT a tool bug — it's BM25 behavior with too many low-frequency terms combined. Each additional word narrows the tsvector intersection, and "uncovered" + "areas" have near-zero frequency in TAD's corpus
- `think` command attempted to use Anthropic API (Claude Opus 4.7) for synthesis but failed due to missing API key
- `think` DID gather 4 pages of context but could not synthesize an answer
- This query is inherently semantic/analytical — it asks "what's NOT there" which is impossible for keyword search to answer

**Root Cause**:
1. BM25 with many search terms creates overly narrow intersections → zero results for complex natural-language queries
2. Gap analysis requires reasoning about absence — fundamentally impossible for any retrieval (whether BM25 or vector)
3. `think` could potentially answer this but requires Anthropic API key (additional cost dependency)
4. This query would need LLM synthesis on top of retrieval, regardless of embedding availability

**Note for Alex**: The `think` feature shows gbrain DOES have a synthesis pipeline (gather → synthesize), but it requires an LLM API key. If Phase 2 proceeds, this could use the Anthropic API key that Claude Code agents already have access to (via MCP server integration), but that brings us back to the API cost question.
