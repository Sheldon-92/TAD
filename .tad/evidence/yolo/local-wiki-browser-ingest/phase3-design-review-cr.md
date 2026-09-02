# Design Review — Code

**Reviewer:** independent code reviewer (Codex GPT-5.6)
**Verdict before revision:** P0=0, P1=1, P2=1

## Findings

- P1: collision suffixing plus check-then-open was underspecified and could publish a
  partial file or race a destination. Required a same-directory exclusive temp, complete
  write/fsync, and non-replacing publication.
- P2: the new popup test would not run under `npm test` unless `tests/run.js` was in scope.

## Disposition

Integrated. Output is now restricted to fixed direct-child directories and descriptor-
anchored no-follow operations; AC4 proves complete publication. `tests/run.js` is explicitly
in scope and AC5 requires registration.

