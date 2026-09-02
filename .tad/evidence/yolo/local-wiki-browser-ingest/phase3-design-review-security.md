# Design Review — Security / Architecture

**Reviewer:** independent security/architecture reviewer (Codex GPT-5.6)
**Verdict before revision:** P0=0, P1=4, P2=2

## Findings

- P1: resolved paths did not close input/output TOCTOU.
- P1: a generic stdlib YAML subset and secret-key matching were underspecified.
- P1: `finally` alone did not safely restore overlapping page-global monkeypatches.
- P1: digests and a forward patch were insufficient rollback evidence for a non-Git project.
- P2: check content length before materializing where possible; page-owned XHR cannot be
  prevented from buffering its own response.
- P2: `authenticated_web` could overclaim authorization provenance.

## Disposition

Integrated. The handoff now pins descriptor/no-follow I/O, a closed input grammar/key set,
single active capture with ownership-aware settle, immutable pre-image and reverse patch,
early content-length handling where available, and `rendered_page_export` provenance.

