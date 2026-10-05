# Security Audit — YOLO2 Phase 2 Gate 4

**Date:** 2026-08-30  
**Reviewer:** independent security-auditor  
**Verdict:** **FAIL** — P0=0, P1=3

## Audited tuple

```text
candidate_sha: e78f0360dbcb2a71a0161ac9adc08480488c73fe
main_sha:      06a535320b98f6469b4afbb87914fd9092d36872
scope_manifest_sha256:   2c48f936381c54859d52599aa12058b5b864bea1868d1c9ef930fea4f8378afc
main_equivalence_sha256: 5ec952669303492d127cb7e7673c26ae151be6b56917241b12a155c44af496b6
```

The stated SHA-256 values match the files currently present in the main working
tree. They do not establish a Gate-4 tuple: both scope-proof files are
ignored/untracked at pinned main, and the versions stored in candidate `e78f0360`
bind the older tuple `candidate=64b5a44d`, `main=c1ccd94f`.

## P1 — Gate-4 blockers

### P1-1 — Scope verifier expands the human-approved allowlist

`phase2ScopeAllowsInclusive` accepts every Phase-2 evidence/review path and also
all archive handoffs, cancelled handoffs, the brain index, judge bundles,
`PROJECT_CONTEXT.md`, and the Framework Health epic
([yolo-recovery.test.mjs](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/yolo-recovery.test.mjs:1342)).
Those exceptions are absent from both Phase-2 handoff allowlists. DR-20260830
authorizes only one exact Local Wiki exclusion. An unrelated commit can therefore
be classified as `included` and pass ownership/replay checks, defeating AC-B's
authorization boundary. The candidate-tree carrier itself lists unrelated Local
Wiki archive/control-plane paths.

Required: restore the exact handoff allowlist union plus the three DR amendment
carriers; reject every other path and every non-fixed exclusion. Recreate the
candidate from the frozen base and rerun the fixed verifier fixtures.

### P1-2 — Dogfood reuse accepts mutable filesystem inputs

When `dataset-index.json` is absent from the candidate Git object, the verifier
falls back to the live `repoRoot` file
([yolo-recovery.test.mjs](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/yolo-recovery.test.mjs:1687)).
The five task inputs likewise prefer a live file over the candidate blob
([same file](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/yolo-recovery.test.mjs:1703)).
Independent `git ls-tree` checks found no `pairs/dataset-index.json` blob in
either `e78f0360` or pinned main. A file can change between dogfood and Gate 4
while matching a newly-written manifest: a TOCTOU/evidence-substitution route.
This conflicts with DR-20260830 §2.6, which requires unreconstructable mutable
inputs to invalidate reuse and require a new dogfood run.

Required: missing candidate blobs/content-addressed immutable carriers must fail;
bind all dataset/task/policy/approval/harness/judge inputs to immutable artifacts
and rerun dogfood if that cannot be done.

### P1-3 — Candidate/main equivalence is stale and incomplete

Candidate `e78f0360` stores `phase2-commit-manifest.json`, `candidate-tree.json`,
`dogfood-input-manifest.json`, `main-equivalence.json`, and `scope-proof.log` for
the earlier `64b5a44d`/`c1ccd94f` tuple. Pinned main deletes these carriers;
`git show 06a53532:<scope-proof-file>` fails. The supplied on-disk hashes are thus
not evidence for the candidate/pinned pair.

Further, `main-equivalence.json` has `immutable_evidence: []` and only two shared
control-plane entries. The verifier checks merely that `gate3-verdict.md` contains
the heading `Gate 3 Verdict`
([yolo-recovery.test.mjs](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/yolo-recovery.test.mjs:1613)),
not its candidate HEAD and PASS verdict. Entries also omit DR-required
`source_commit`. A stale or substituted verdict carrier can therefore pass.

Required: produce and persist one immutable, internally consistent five-carrier set
for exactly `e78f0360`/`06a53532`, with source-to-replay mapping, Phase-2 immutable
evidence-tree hashes, and exact selectors/values/hashes/source commits for the
handoff, completion, and Gate-3 candidate HEAD + PASS assertions. Reject stale
tuple fields rather than regenerate or trust working-tree carriers.

## Security checklist

| Category | Check | Status | Finding |
|---|---|---|---|
| Evidence integrity | Candidate/main binding, TOCTOU | Fail | P1-2, P1-3 |
| Authorization | Frozen scope / allowlist | Fail | P1-1 |
| Shell/path handling | New runner/driver invocation paths | Pass with accepted degraded risk | No additional exploitable injection or traversal was supported by the reviewed fixed commands; the signed degraded assertion-shell path remains governed by DR-20260827. |
| Secrets | Candidate product diff inspection | Pass | No credential/private-key material found in reviewed product files. |
| Dependencies | New runtime dependency surface | N/A | No package/lockfile change is in approved product scope. |
| Network/transport/auth | Web application controls | N/A | Local CLI/evidence workflow, not a network service. |

## Vulnerability summary

| Severity | Count | Details |
|---|---:|---|
| P0 / Critical | 0 | — |
| P1 / High | 3 | Scope authorization, mutable dogfood evidence, stale/incomplete tuple |
| P2 / Medium | 0 | — |
| Low | 0 | — |

## Gate decision

Gate 4 must not accept this candidate. No material P0 finding is supported, but
the three P1 evidence/authorization failures mean the reported Gate-3 PASS cannot
be relied on for this tuple.

## Evidence inspected

- Both active YOLO handoffs, final completion, Gate-3 verdict, and DR-20260827/30.
- Candidate `e78f0360` and pinned main `06a53532` Git objects.
- Scope-proof raw carriers and the cited verifier/runner/driver source.
