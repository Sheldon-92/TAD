# Code Review — YOLO2 Phase 2 Gate 4, Round 2

**Reviewer:** independent code-reviewer subagent (Raman); persisted verbatim in substance by Alex  
**Date:** 2026-08-31  
**Verdict:** **FAIL — P0=0, P1=3, P2=0, LOW=0**

## Audited tuple

```text
base:              96bbfada1e6c757b7b9dec0d38d69eb8dc2e3aa7
candidate:         a199030bd44d1a62a2b8b43ce629b02af5217095
pinned main:       28c0f9af83c23945038475ec4723a7c43a8acfbf
scope manifest:    06086e32998b584af603ff70fe920299c6b800a558802044fdde77b961e65e67
main equivalence:  4ac353c83aaf68c09d7805b2fffc21c58aa9fe214f1fafdbab33a52fb6b24433
```

## Findings

### P1-1 — Gate-3 binding is self-reported rather than recomputed

Candidate and pinned main contain a Gate-3 verdict whose declared HEAD is the old
`e78f0360...`, whose Phase-1 result is 10/11 FAIL, and whose prose says Group-0 and Layer 2
remain blocked. The Completion body also retains `HONEST_PARTIAL` and unresolved blockers.

The verifier checks only the generic `Gate 3 Verdict` title in the underlying Git object, then
accepts the PASS/SHA fields self-reported by `main-equivalence.json`. It does not extract the
actual declared candidate SHA and final PASS semantics from the candidate and main Git blobs.
The exact pinned command therefore returns PASS for contradictory authority carriers.

### P1-2 — Fixed-exclusion Git provenance is not recomputed

`computeBinaryDiffSha()` special-cases `f967276f...` and returns the DR constant instead of
hashing `git diff --binary <parent> <commit>`. Independent recomputation returns
`3abdcc69c8c271673b323793e27f49dceaea4806dc5ff34f61ea60ddaba63bd2`, while the signed DR
and verifier claim `70de6e15357c...`. This violates DR-20260830's requirement that the
verifier independently recompute every inventory field. The matching fixture compares constants
and is not an end-to-end negative control.

### P1-3 — Candidate scope is broadened beyond the signed allowlist

`phase2ScopeAllowsInclusive()` generically admits archive handoffs, cancelled handoffs,
`.tad/brain-index.md`, judge bundles, `PROJECT_CONTEXT.md`, and the Framework Health Epic.
Those paths are absent from the Phase-2 Handoff §3 allowlists. The candidate contains these
unrelated Local Wiki/Framework Health changes, so the scope proof succeeds only because the
implementation expanded authorization.

## Verified positives

- Dataset/task dogfood inputs are now candidate Git blobs; the mutable dataset fallback is gone.
- Five product blobs match pinned main.
- Pinned verifier is read-only and leaves carrier hashes unchanged.
- Recovery suite reports 11/11 and round suite 12/12.

These positives do not compensate for three P1 acceptance-integrity failures.

