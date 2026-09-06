# Implementation Review — Security / Architecture (Round 1)

**Commit:** `77715d830e512bd6f95936b325e09dbe8da8122e`
**Reviewer:** independent security/architecture reviewer (Codex GPT-5.6)
**Verdict:** P0=0, P1=4, P2=2 — fix required

1. P1: the importer rejects the extension's real non-null `keywords:` block-list format.
2. P1: lifecycle proof is source matching; trusted fetch rejection waits for timeout instead
   of settling immediately. Execute the real shipped function and fix immediate cleanup.
3. P1: a single `os.write` can truncate publication.
4. P1: rollback evidence omits changed `tests/run.js` and the new external test file.
5. P2: check Content-Length before materialization; XHR buffering remains page-owned.
6. P2: fsync the destination directory after publication for crash durability.

Positive: descriptor/no-follow containment, no-replace link publication, closed metadata
allowlist, ownership-aware restoration, and neutral provenance wording are sound.

## Round 2 and final rollback replay

Commit `9c075be0` closed the parser, lifecycle, immediate rejection, short-write, concurrency,
and durability findings. Commit `768869c6` regenerated exact external pre/post images and
patches. The reviewer independently replayed reverse then forward recovery: popup and runner
returned to exact pre hashes, the new test became absent, and all three then returned to exact
post hashes. Final verdict: **P0=0, P1=0 — PASS**. Advisory only: an unknown-length fetch is
bounded after materialization because the page response lacks a trustworthy early length.

