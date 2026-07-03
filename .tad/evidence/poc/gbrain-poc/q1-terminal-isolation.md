# Q1: Terminal Isolation Design Decision

**Query**: "Why did TAD choose terminal isolation instead of shared state for Alex and Blake?"
**Command**: `$GBRAIN search "terminal isolation"`
**Expected**: Cites principles.md terminal isolation entry + references supporting handoffs/evidence

## Raw Results

```
[0.8628] evidence/reviews/blake/phase3-blake-e2e/backend-architect
[0.6991] active/handoffs/handoff-20260703-gbrain-poc
[0.6358] guides/anti-rationalization-tables
[0.6357] project-knowledge/patterns/pack-build-rules
[0.6357] evidence/reviews/2026-02-06-code-review-knowledge-agent-teams-final
[0.4924] evidence/acceptance-tests/research-engine-wire-phase4/dogfood-runbook
```

Also tried: `search "Two-Agent System terminal"` and `query "Why did TAD choose terminal isolation..."` — worse results.

## Evaluation

**Verdict: ❌ 无用**

**Reasoning**:
- Top result is a backend-architect review mentioning "terminal" in a different context (notebooklm_access)
- principles.md "Two-Agent System" entry (line 11) does NOT mention "terminal" or "isolation" — the design decision lives in CLAUDE.md §4 (outside .tad/, not indexed)
- principles.md line 101 ("Knowledge Is Forged at Distill") does contain the exact phrase "terminal isolation" but in an unrelated context (knowledge distillation asset, not architecture rationale)
- None of the 6 results reference the actual design decision for terminal isolation
- `grep -r "terminal isolation" .tad/project-knowledge/` would find the line 101 occurrence, but it's not the design rationale either — the actual decision is in CLAUDE.md §4, outside gbrain's index scope
- No cross-document synthesis: results are scattered fragments without connecting the design rationale to its implementation

**Root Cause**: The design rationale for terminal isolation lives in CLAUDE.md §4 (Terminal 隔離 rules), which is OUTSIDE .tad/ and was never indexed by gbrain. The only occurrence of "terminal isolation" inside .tad/ (principles.md line 101) is in an unrelated entry about knowledge distillation. BM25 found fragments matching "terminal" in wrong contexts. Even with embeddings, this query would fail because the answer simply isn't in the indexed corpus.
