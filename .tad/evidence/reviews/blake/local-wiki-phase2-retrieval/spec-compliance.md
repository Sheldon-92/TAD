Model: harness=codex | model=gpt-5.6-terra | route=native

# Spec Compliance — Local Wiki Phase 2

**Verdict:** PASS — NOT_SATISFIED=0, PARTIALLY_SATISFIED=0

| AC | Verdict | Evidence |
|---|---|---|
| AC1 | SATISFIED | exact query returned traceable wiki/canon locations |
| AC2 | SATISFIED | non-empty raw JSON with seven typed fields and finite scores |
| AC3 | SATISFIED | 13/13 focused unit tests |
| AC4 | SATISFIED | 8 cases; Recall@5=1.0; MRR=0.9375 |
| AC5 | SATISFIED | 5/5 lint; generator stdout byte-identical across two runs |

The implementation is stdlib-only, uses in-memory SQLite FTS5, and did not modify
raw/canon/wiki evidence pages to game evaluation.
