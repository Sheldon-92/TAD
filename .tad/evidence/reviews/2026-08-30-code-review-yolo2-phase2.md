# Independent code review — YOLO2 Phase 2

**Reviewer:** independent Gate-4 code reviewer  
**Reviewed object:** candidate `e78f0360dbcb2a71a0161ac9adc08480488c73fe` against frozen base `96bbfada1e6c757b7b9dec0d38d69eb8dc2e3aa7`, with pinned main `06a535320b98f6469b4afbb87914fd9092d36872`  
**Design/acceptance authority read:** both active YOLO handoffs, `DR-20260827-yolo2-phase2-amended-acceptance.md`, `DR-20260830-yolo2-phase2-scope-proof-amendment.md`, the active completion report, and `phase2/gate3-verdict.md`.

## Verdict

**FAIL — P0: 0, P1: 3, P2: 0, LOW: 0.**

The five Phase-2 product scripts have identical Git blobs in candidate and pinned
main. That product equivalence does not compensate for the three P1 acceptance-
integrity failures below. In particular, the scope verifier can return PASS while
its required dogfood-input proof is sourced from mutable, uncommitted filesystem
state and while the claimed final Gate-3 carrier is stale.

## Findings

### P1-1 — Scope proof accepts mutable dogfood inputs instead of an immutable candidate-bound input

`verifyDogfoodInputManifest` first tries the candidate Git blob for
`pairs/dataset-index.json`, but on failure silently falls back to the current
worktree at `.tad/scripts/yolo-recovery.test.mjs:1690-1697`. It also prefers the
current filesystem for every per-task input at `:1706-1716`. Both candidate and
pinned main lack the dataset-index Git blob:

```text
git cat-file -e e78f0360:.../pairs/dataset-index.json
# fatal: path exists on disk, but not in e78f0360
git cat-file -e 06a535320:.../pairs/dataset-index.json
# fatal: path exists on disk, but not in 06a535320
```

Nevertheless, the DR-pinned verifier returned `RESULT=PASS` when the ignored
worktree evidence was present. It additionally skips validation altogether when
`dogfood-input-manifest.json` is absent (`:2001-2008`). This is contrary to
DR-20260830 §2.6/§3: reuse must be recomputed from candidate Git blobs and
content-addressed immutable raw inputs; a mutable filesystem-only source is not
reconstructible evidence.

**Impact:** a changed, replaced, or locally selected dataset can be made to match a
rewritten manifest without a candidate-bound source, so the verifier may authorize
reuse of dogfood that did not run against the accepted mechanism/input tuple.

**Required correction:** make the manifest mandatory; remove the mutable-worktree
fallback; bind every dataset/task input to a candidate Git blob or an independently
immutable content-addressed carrier; and add a real negative fixture for a missing
Git/blob carrier and for a changed live filesystem copy.

### P1-2 — Main-equivalence proof never verifies the required exact Gate-3 HEAD/PASS carrier

The DR requires `gate3-verdict.md` to bind the candidate HEAD and PASS using an
exact selector/value/canonical-subdocument hash. The implementation instead checks
only that the file contains the title `Gate 3 Verdict`
(`.tad/scripts/yolo-recovery.test.mjs:1625-1629,1645-1657`). The emitted
`main-equivalence.json` records only the handoff amendment and completion frontmatter
markers, with `immutable_evidence: []` (`:2066-2077`).

The defect is observable in the pinned candidate: its
`phase2/gate3-verdict.md` names `3226670097c54efe354c258aa351c5fadb328541`, not
candidate `e78f0360...`; its body still says Phase-1 is `10/11`, scope proof is
blocked, and Group-0/Layer 2 were not started. The verifier still returns PASS,
because the stale document retains the title.

**Impact:** the candidate/main equivalence tuple can attest to a Gate-3 result that
was not produced for the reviewed candidate. This defeats the DR's exact-value
control-plane binding and makes the reported verifier-output hash non-probative.

**Required correction:** parse and compare the exact candidate SHA and PASS verdict
in candidate and pinned main, include their canonical subdocument hashes in
`main-equivalence.json`, enumerate and compare the required immutable Phase-2
evidence roots, and add wrong-HEAD/wrong-verdict/missing-root negative fixtures.

### P1-3 — The claimed final suites cannot be replayed in the required candidate validation worktree

From `.worktrees/tad-yolo2-candidate` at the reviewed candidate, independent
re-execution produced:

```text
node .tad/scripts/yolo-recovery.test.mjs
# dogfood-evidence FAIL: Phase-1 recovery-scores.json missing
# required-evidence FAIL: Phase-1 base-commit.txt missing
# RESULT=FAIL (9/11)

node .tad/scripts/yolo-round.test.mjs
# dogfood-evidence FAIL: phase2 pair-results.json missing
# required-evidence FAIL: Group-0 report and capability JSON missing
# RESULT=FAIL (10/12)
```

Those raw carriers are ignored/untracked in the validation worktree; only the
scope-proof files are in candidate's Git tree. This conflicts with DR-20260830
§2.3/§2.7, which requires the decisive verifier to run in the candidate validation
worktree, and with AC-J's final 11/11 plus 12/12 claim. The test-runner report's
PASS summary is therefore not independently replayable against the pinned candidate
without borrowing mutable shared-worktree evidence.

**Impact:** Gate 4 cannot establish that the tested code, dogfood evidence, and
scope proof refer to one reproducible object.

**Required correction:** provide a candidate-addressable immutable evidence bundle
or an explicit, hash-bound bootstrap mechanism available to the validation worktree;
then rerun both complete suites and the pinned scope verifier from that worktree.

## Independent checks performed

- Recomputed the five product-path Git blobs for candidate and pinned main: all
  equal.
- Ran syntax checks and the two full suites in the candidate worktree; both suites
  failed only on unavailable evidence carriers as shown above.
- Ran the exact pinned scope-verifier command using the candidate worktree and
  pinned main/candidate/manifest values; it returned PASS despite the P1-1 and
  P1-2 conditions.
- Read the Group-0, code-reviewer, and test-runner tuple reports. Their tuple strings
  agree with each other, but the tuple's `immutable_evidence_tree_sha256` is
  `no-tree`; it does not repair the missing candidate-bound evidence or stale
  control-plane carrier.

No material product-code correctness or security defect beyond the acceptance and
evidence-integrity findings above is supported by this review.
