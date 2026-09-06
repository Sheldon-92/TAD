# Layer 1 — Local Wiki Phase 2

**Iterations:** 2 (second full run after Layer-2 path-containment repair)
**Verdict:** PASS (zero Layer-1 failures)

| Check | Result |
|---|---|
| `python3 -m unittest research.tests.test_search` | PASS — 14/14 |
| usable human query | PASS — traceable wiki/canon result present |
| raw JSON query | PASS — non-empty typed result contract |
| checked-in evaluation | PASS — Recall@5 1.0, MRR 0.9375 |
| `bash research/canon/lint.sh` | PASS — 5/5 governed pages |
| generator run-1 vs run-2 | PASS — byte-identical stdout |

No provider, network, cache, source mutation, or vector extension was used.

Layer-2 round 1 found a research-root symlink traceback. The implementation now rejects
both root and leaf symlinks with `SearchError`; the complete Layer-1 set passed again.
