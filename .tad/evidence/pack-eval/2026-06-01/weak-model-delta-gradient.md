# Capability Pack Value vs Model Capability — Measured Delta Gradient (2026-06-01)

**Question**: Does a weaker model (< Opus 4.8) get MORE value from a capability pack?
**Method**: Same fixture scenario + identical WITH-pack / CONTROL prompts (prompt symmetry), run with the agent forced to haiku / sonnet / opus-4.8. Score each output with `pack-eval-runner.sh` discriminative gate. Δ = WITH_disc − CONTROL_disc = pack-specific markers the pack added beyond a knowledgeable no-pack agent of the same tier.

## Results

| Pack | tier | WITH | CONTROL | Δ |
|------|------|------|---------|---|
| rag-retrieval (rich) | haiku | 9 | 1 | 8 |
| rag-retrieval | sonnet | 14 | 2 | **12** |
| rag-retrieval | opus-4.8 | 13 | 2 | 11 |
| ai-guardrails (rich) | haiku | 6 | 0 | 6 |
| ai-guardrails | sonnet | 9 | 0 | **9** |
| ai-guardrails | opus-4.8 | 8 | 2 | 6 |
| data-engineering (lean / mature-domain) | haiku | 10 | 2 | **8** |
| data-engineering | sonnet | 10 | 3 | 7 |
| data-engineering | opus-4.8 | 10 | 5 | 5 |

## Findings

1. **CONTROL falls monotonically as the model weakens** (every pack): weaker models produce fewer senior specifics unaided → larger room for the pack to add. (data-eng CONTROL 5→3→2; guardrails 2→0→0.)
2. **The "redundant-for-frontier" pack regains value for weaker models** — data-engineering Δ grows 5 (opus) → 7 (sonnet) → 8 (haiku) because WITH holds at 10 while CONTROL collapses. Redundancy is model-RELATIVE.
3. **Non-monotonic for RICH packs — sweet spot is mid-tier (sonnet), not weakest.** rag/guardrails WITH DROPS on haiku (rag 9 vs sonnet 14; guardrails 6 vs 9): haiku cannot fully read+apply a 50KB multi-reference pack (instruction-following / long-context gate). So Δ peaks at sonnet (rag 12 > opus 11 > haiku 8; guardrails 9 > opus 6 = haiku 6).

## Conclusion
Pack value is **non-monotonic in model strength**: rises frontier→mid, can fall at the bottom for content-rich packs the weak model can't operationalize. **Sonnet-tier is the best consumer** (strong enough to apply the full pack, weak enough to genuinely need the specifics). Lean packs in mature domains follow the simple "weaker = more value" rule; rich packs peak mid-tier. Caveat (reasoned, not measured here): a weaker model also faithfully emits pack ERRORS it can't catch — so correctness/maintenance matters MORE for weaker consumers.

**Evidence**: 12 weak-model outputs (rag-retrieval/ai-guardrails/data-engineering × haiku/sonnet × WITH/CONTROL) in this dir; Opus baseline = {slug}-WITH.md / {slug}-CONTROL.md.
