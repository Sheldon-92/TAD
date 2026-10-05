# Security Audit — YOLO2 Phase 2 Gate 4, Round 2

**Date:** 2026-08-31  
**Reviewer:** independent security-auditor  
**Verdict:** **FAIL** — P0=0, P1=3

## Audited tuple

```text
base:          96bbfada1e6c757b7b9dec0d38d69eb8dc2e3aa7
candidate:     a199030bd44d1a62a2b8b43ce629b02af5217095
pinned main:   28c0f9af83c23945038475ec4723a7c43a8acfbf
scope manifest:    06086e32998b584af603ff70fe920299c6b800a558802044fdde77b961e65e67
main equivalence:  4ac353c83aaf68c09d7805b2fffc21c58aa9fe214f1fafdbab33a52fb6b24433
```

The supplied scope-manifest and main-equivalence SHA-256 values match the files
present at review time. The candidate tree also matches its manifest
(`933a86e9b17912dddc954e36bd8b32496fd02508`). This is a new assessment of the
Round-2 tuple, not a carry-forward of Round 1.

## P1 — Gate-4 blockers

### P1-1 — Candidate replay still authorizes unrelated paths

The candidate’s frozen-base diff contains 34 paths, including Framework Health
and Local Wiki artifacts outside the Phase-2 handoff scope: the Framework Health
epic, cancelled/archive handoffs, `.tad/brain-index.md`, the Local Wiki judge
bundle, and `PROJECT_CONTEXT.md`. They pass only because
`phase2ScopeAllowsInclusive` explicitly accepts those unrelated paths
([yolo-recovery.test.mjs](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/yolo-recovery.test.mjs:1343)).

DR-20260830 permits exactly one fixed Local Wiki *excluded commit*; it does not
authorize these paths as included Phase-2 work. Consequently, a candidate can
contain unrelated changes and still satisfy the scope verifier, defeating AC-B’s
authorization boundary.

Required: remove the unrelated paths from the candidate replay and delete the
ad-hoc allowlist branches. The verifier must admit only the original handoff
allowlists, the explicitly signed amendment carriers, and the one fixed exclusion.

### P1-2 — Scope-proof carriers remain mutable ignored files

All five scope-proof carriers are ignored by `.gitignore`’s `.tad/evidence/`
rule. Neither candidate nor pinned main contains the two decisive carrier blobs:
`git show <candidate-or-main>:.../scope-proof/main-equivalence.json` fails.
The verifier’s `git status --porcelain -- <carrier>` check treats ignored files as
clean ([yolo-recovery.test.mjs](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/yolo-recovery.test.mjs:2043)).
An attacker or concurrent process can therefore replace a carrier between review
steps without changing a Git object or producing a dirty-path failure.

The Round-2 code correctly removed the previous mutable fallback for
`dataset-index.json` and per-task inputs
([yolo-recovery.test.mjs](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/yolo-recovery.test.mjs:1687)); that remediation is effective. It does
not make the verifier’s own tuple carriers immutable or close their TOCTOU gap.

Required: commit the carrier set, or store it in immutable content-addressed
evidence and verify its digest before and after every dependent check. Re-running
the verifier must consume the same fixed carrier digest set, not mutable ignored
paths.

### P1-3 — Gate-3 authority carrier is stale but the verifier accepts its self-report

The Git objects for both candidate and pinned main contain a Completion body that
states `HONEST_PARTIAL`, Phase-1 `10/11`, and downstream Layer-2 `BLOCKED`.
Their `gate3-verdict.md` instead names prior candidate `e78f0360` and describes
the old scope-proof failure. Neither authority carrier supports PASS for
`a199030b`.

`verifyEquivalence` only checks that the Gate-3 file contains the heading `Gate 3
Verdict` ([yolo-recovery.test.mjs](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/yolo-recovery.test.mjs:1610)).
The later check then trusts fields in `main-equivalence.json` rather than extracting
and hashing the actual Gate-3 Git object; it also fails to reject a non-empty but
wrong `source_commit` ([same file](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/yolo-recovery.test.mjs:2088)).
This is a false-PASS evidence-integrity path: a self-reported `PASS` hash can
contradict the reviewed authority carrier.

Required: update the Completion and Gate-3 authority documents for the audited
candidate, then have the verifier extract the exact candidate HEAD and PASS verdict
from both Git objects and compare their canonical subdocument hashes with the
equivalence carrier. Reject any mismatched, absent, or non-equal `source_commit`.

## Security checklist

| Category | Check | Status | Finding |
|---|---|---|---|
| Authorization | Candidate replay scope | Fail | P1-1 |
| Evidence integrity | Tuple immutability, TOCTOU, authority binding | Fail | P1-2, P1-3 |
| Dogfood inputs | Mutable filesystem fallback | Pass | Candidate Git blobs are now mandatory for dataset/task inputs. |
| Signed budget | DR-20260831 authority | Pass | Human-signed, mechanism-scoped amendment; not treated as a security defect. |
| Secrets | `gitleaks dir .tad/scripts` | Pass | Exit 0; no leaks found. |
| Shell/path handling | Fixed runner/driver paths | Pass with accepted degraded risk | No additional exploitable injection or traversal supported by reviewed fixed invocations. |
| Dependencies / network | New external runtime surface | N/A | No package/lockfile change or network service in the audited scope. |

## Vulnerability summary

| Severity | Count | Details |
|---|---:|---|
| P0 / Critical | 0 | — |
| P1 / High | 3 | Scope authorization; mutable ignored proof carriers; stale Gate-3 authority accepted as PASS |
| P2 / Medium | 0 | — |
| Low | 0 | — |

## Gate decision

P0/P1=0 is required for PASS. With three P1 findings, Gate 4 must not accept the
Round-2 tuple. No material additional security finding is supported beyond those
listed above.

## Evidence inspected

- Both active YOLO handoffs, final completion, Gate-3 verdict, DR-20260827/30,
  and signed budget amendment DR-20260831.
- Candidate `a199030b`, pinned main `28c0f9af`, current scope-proof carriers,
  their pre/post review SHA-256 values, and the cited verifier source.
