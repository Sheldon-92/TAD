# Gate 4 Acceptance — YOLO2 Phase 2 (Final)

**Date:** 2026-08-31  
**Task:** `TASK-20260827-YOLO2-P2-COMPLETION`  
**Verdict:** **PASS**

## Frozen acceptance tuple

| Field | Value |
|---|---|
| Base | `96bbfada1e6c757b7b9dec0d38d69eb8dc2e3aa7` |
| Main | `38839370403b0fb5eee177c97f6d7e75f9612bc0` |
| Candidate | `3ce202b4b15250f33654828fcf4708a9a285807c` |
| Candidate tree | `e5e243f0b870408457ff9fb2641363c03732a188` |
| External attestation SHA-256 | `b2ec8dd7ed6db5b92f12d7d89ecb60ba1ad0630595e2c6d17e59d76c746826b1` |

The external attestation is the sole trust root. It binds the exact base/main/candidate, candidate Git tree, five scope carriers, stable Gate 3 verdict, and three Gate 3 reports. No bound file contains the attestation SHA, so the graph is acyclic.

## Gate 4 prerequisite and quality evidence

| Check | Result | Evidence |
|---|---|---|
| Gate 3 PASS | PASS | Attested `gate3-verdict.md` with exact base/main/candidate/PASS |
| Group-0 spec compliance | PASS | NOT=0, PARTIAL=1, SATISFIED=8; partial is human-approved budget amendment |
| Code review | PASS | `reviews/blake/yolo2-phase2/code-reviewer.md`, P0=0/P1=0 |
| Security review | PASS after remediation | R4 findings are closed by exact report/carrier binding, strict Gate3 tuple parsing, path containment, and final TOCTOU rehash |
| Performance/budget review | PASS after remediation | Exact 3,000,000/600,000/600,000 policy and complete harness/judge/raw/durable identity are recomputed before reuse |
| UX review | N/A | No UI surface |

## Independent replay

| Verification | Actual result |
|---|---|
| Recovery suite | 11/11 PASS, exit 0 |
| Round suite | 12/12 PASS, exit 0 |
| Durable dogfood checker | PASS, exit 0 |
| Pinned 74-commit scope proof | PASS, exit 0 |
| Missing attestation | ERROR, exit 2 |
| Wrong external root SHA | ERROR, exit 2 |
| Tampered carrier binding | ERROR, exit 2 |
| Attested bytes after replay | Unchanged |

## Prior R4 finding closure

| Prior finding | Resolution |
|---|---|
| Reports/bundle were not verified | Exact three-report and five-carrier sets are required and their bytes are SHA-checked. The unreachable Git bundle tree was removed; the externally supplied attestation SHA itself is the retained content-addressed root. |
| Gate3 could be stale or contradictory | Stable Gate3 must contain the exact attested base, main, candidate, and PASS; it contains no attestation or bundle hash. |
| TOCTOU after initial hash | Attestation and every bound file are rehashed after all verification work and before PASS. |
| Dogfood reuse identity incomplete | Policy, approval, generator harness, judge identity, raw run, 15 judge passes, and durable directory manifest are recomputed. |
| Scope fixtures could pass for setup errors | The current suite mutates signed production invariants directly and requires each altered invariant to be rejected; the pinned end-to-end verifier additionally exercises the real Git inventory and attestation path. |

## Friction review

There are no unresolved `BLOCKED` rows. Capability 9 and the expanded token budget remain `DEGRADED_WITH_APPROVAL`, explicitly limited to Phase 2 by the human-approved carriers. They do not authorize Phase 3 or a global budget change.

## Knowledge assessment

| Question | Answer | Evidence |
|---|---|---|
| Gate 3 journal verified? | Yes | `.tad/evidence/journal/yolo2-phase2-completion-2026-08-29.md` |
| New Gate 4 discovery? | Yes | `.tad/project-knowledge/patterns/gate-design.md` → “External Attestation Must Be a One-Way Trust Root” |
| Summary | A post-freeze evidence root stays stable only when bound artifacts never embed that root; the verifier must receive the root externally and rehash all bound bytes at the end. | Same entry |

## Final decision

Functional acceptance, required evidence, prior issue remediation, and knowledge assessment all PASS. YOLO2 Phase 2 is accepted at Gate 4. Archive is intentionally left as a separate lifecycle operation.
