# Architecture Review — YOLO2 Phase-2 Scope-Proof Amendment

**Reviewer role:** independent architecture/correctness reviewer  
**Rounds:** 2 (protocol maximum)  
**Reviewed:** DR-20260830 + HANDOFF-20260827 AC-B amendment

## Round 1

Verdict: BLOCK, P0=0, P1=3.

1. Commit manifest was self-selectable and could omit evidence/control-plane commits.
2. `current main` and control-plane markers were not pinned, leaving TOCTOU ambiguity.
3. Dogfood reuse incorrectly depended on five product files although the real mechanism uses
   recovery + reference-runner + pair-driver and additional run inputs.

Disposition: all integrated. The contract now uses a closed BASE..MAIN inventory, pinned
pre/post main SHA, exact selector/value/subdocument bindings, and a canonical dogfood-input
manifest.

## Round 2

Verdict before final line-item closure: P0=0, P1=2.

1. `excluded` classification still needed a fixed, human-approved SHA/path-set boundary so an
   unauthorized write followed by rollback could not be relabeled as parallel work.
2. Dataset binding needed per-task JSON hashes, not only dataset-index or the mixed input/output
   pairs tree.

Disposition: integrated in DR §2 and §3. The only approved exclusion is now pinned by full SHA,
parent, first-parent binary-diff SHA-256 and sorted path-set SHA-256; future exclusions require a
new human amendment. Dogfood inputs now bind ordered per-task JSON blobs plus the actual mechanism,
policy, approval, harness/model/judge inputs.

## Final Alex closure

No open P0/P1 from this review remains. AC-J reuse wording is consistent with the actual
three-file mechanism; scope/test-only changes may reuse dogfood only when the complete canonical
input manifest is byte-equivalent and reconstructable from immutable inputs.

