# Journal — Local Wiki Phase 2 Retrieval

## Findings

- At this corpus size, rebuilding an in-memory FTS5 index on each invocation avoids all
  cache invalidation state while remaining interactive (0.07 s median query).
- Path confinement needs a separate root check: checking leaf symlinks alone does not
  prevent a symlinked corpus root, and unguarded `Path.relative_to()` leaks a traceback.
- Retrieval and answer quality remain distinct. This phase measures Recall@5/MRR and
  returns inspectable evidence locations; it does not claim generated-answer accuracy.

## Knowledge Assessment

- Q1: Yes — findings recorded above.
- Q2: No new skill candidate; the pattern is already covered by the RAG retrieval pack
  and Local Wiki design records.
- Q3: No novel workflow pattern; the standard TAD review loop was used as designed.

