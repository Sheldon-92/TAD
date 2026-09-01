# EPIC-20260901 — Local Wiki Retrieval

**Status:** Complete — Phase 2 Gate 4 PASS on 2026-09-01
**Previous phase:** Local Wiki framework, Gate 4 PASS at `f967276f`
**Decision:** `.tad/decisions/DR-20260901-local-wiki-retrieval-before-multimedia.md`

## Outcome

A user or agent can ask the Local Wiki for relevant local evidence and receive ranked,
human-inspectable Markdown locations without loading the whole corpus or relying on a
cloud service.

## Revised roadmap

1. Phase 1 — canon → raw → wiki framework: complete and archived.
2. Phase 2 — retrieval foundations: this Epic.
3. Phase 3 — video/audio ingest: future, separately scoped.
4. Phase 4 — semantic/vector enhancement: conditional on measured retrieval gaps;
   it may be folded into Phase 2 maintenance if no new product boundary is needed.

## Phase 2 boundaries

In scope: local Markdown indexing, ranked lexical search, traceable results, layer
filtering, machine-readable output, deterministic evaluation, documentation.

Out of scope: media transcription, web fetching, hosted search, paid embeddings,
mandatory vector extensions, answer generation, mutation of canon/raw/wiki content.
