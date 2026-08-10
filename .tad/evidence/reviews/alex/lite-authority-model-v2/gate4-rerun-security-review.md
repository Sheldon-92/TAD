# Gate 4 Rerun — Security / Authority Review

**Date:** 2026-08-10  
**Task:** `FULL-RETIRE-P3B-LITE-AUTHORITY-V2`  
**Repair commit:** `c851046dc41b65f89dbe0acfbb51cc198d016c81`  
**Verdict:** **FAIL — P0=0, P1=1, P2=0**

## Closed findings

The original AC7 fail-open outcome mapping and AC10 evidence overclaim are closed. The repaired
verifier has an independent 30-case outcome oracle, strict JSON parsing, and fail-closed probes for the
previously demonstrated consequence, lifecycle, prompt, replay, and malformed-JSON mutations. The
repair did not touch live Lite carriers, did not write registered targets, and did not perform push,
tag, publish, sync, or live dogfood.

## P1 — the repair commit exceeds mandate revision 1's recorded commit bound

The accepted Execution Mandate revision 1 binds `local_commit` to **one** non-amending local commit and
states a maximum blast radius of **one TAD source-workspace commit**. Commit
`77479a0a4ada086f65930a2b1502c5713c49aad3` consumed that bound. The Gate 4 repair transaction then
created `c851046dc41b65f89dbe0acfbb51cc198d016c81` while still citing mandate revision 1.

The design contract says that a material blast-radius change supersedes the mandate and returns to
Alex-Lite for a reviewed amendment. No such revised carrier exists. The second commit was local-only,
exact-path, non-amending, and caused no external mutation, so this is P1 rather than P0.

This defect originated in Alex's prior Gate 4 repair contract, which instructed Blake to create a
separate repair commit while also claiming that mandate revision 1 remained sufficient. It is not a
missing user Git authorization and must not be converted into a technical approval question.

## Required authority correction

1. Preserve the historical deviation in evidence; do not amend, reset, squash, or otherwise rewrite
   history to conceal it.
2. Revise the prospective Authority Model contract and mandate template so human-visible blast radius
   is expressed as affected workspace/target/consequence/external reach, not raw local commit count.
3. Define Gate-directed local repair commits as agent-owned technical recovery when they stay inside
   the already accepted outcome, exact workspace/path/consequence classes, and no-external-mutation
   boundary.
4. Continue to require a human-domain amendment for an actual outcome, target, consequence class,
   external reach, or user-visible recovery expansion.
5. Establish a valid reviewed contract carrier before the next Blake repair. Do not ask the human to
   judge whether another local Git commit is technically appropriate.
6. Add a verification assertion that the executed transaction remains within the revised blast-radius
   semantics.

No external action or implementation mutation was performed by this review.
