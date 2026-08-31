# DR-20260831 — YOLO2 Phase-2 Scope-Proof Amendment R2

**Date:** 2026-08-31
**Decider:** Sheldon (human, Value Guardian)
**Decision provenance:** Human replied “同意 scope-proof amendment R2” after Alex Gate 4
Round 2 demonstrated that the prior verifier accepted unrelated commits and hard-coded an
incorrect Git-provenance hash.
**Applies to:** `TASK-20260827-YOLO2-P2-COMPLETION` AC-B and AC-J.
**Supersedes only:** DR-20260830 §2.2's single-exclusion table and its
`first_parent_binary_diff_sha256` value. All other DR-20260830 requirements remain binding.

## 1. Decision

The Phase-2 candidate replay must contain only commits classified as Phase-2 work plus the three
signed Alex amendment carriers. Legitimate non-YOLO work in the shared main history is excluded by
the four exact Git-object entries below. No generic path allowance is authorized.

### Fixed exclusions

| Reason | Source SHA | First parent | Binary diff SHA-256 | Sorted paths SHA-256 | Stable patch-id |
|---|---|---|---|---|---|
| parallel-local-wiki-implementation | `f967276fc3b8e1fbc5acce5bc1fe7cfbfa121e5f` | `e7ec30b48f445a997b11408ea3aa5b699e55da06` | `3abdcc69c8c271673b323793e27f49dceaea4806dc5ff34f61ea60ddaba63bd2` | `35413b708507ecf4e79ac4ce602496386910fe00d10a314a4e120e62b848b65f` | `b4bc5ca3e298d2d73e0a927ad2ca54de553135b0` |
| parallel-local-wiki-gate4-archive | `c5f0114bce0fce19bf0db919cb1cf88462700c2f` | `4dff4519e46bdf3244dcf859b8bf75925e63a4b0` | `7ec134d2d99d93592eac26084d491ea7c69759c59ba936f76b5138cb6f537551` | `ec760b3326911d0215e554af8a51540af9da51da7f42cddd731e841ffb4b0ab3` | `ca0adf6c2ce07950285cb1af42b8e40b8ee9c621` |
| parallel-next-cleanup | `896f63dfb164242c1963fdf8d34414cca4e987f6` | `c5f0114bce0fce19bf0db919cb1cf88462700c2f` | `931d118495551822dc156f3c7dad873c39d0e0899655a980fc1a72693f8e00a6` | `b295aee5c13b614df889d54f8a8ffc34133434f3aa2cf07a824d6f4d34bf9e40` | `0636d789f3960fbf1b25a85c8602c22078aff1e5` |
| parallel-framework-health-cancellation | `5dac5ed088aefe13d1914e74d24eb841535ad6bf` | `7b3c38f8d1594245d75521a5e2e1457a1aae9bef` | `86a5577b65e7cd0260c9458b80584fd8a84a67b71d49a88870a20e680cc7541b` | `6fab6e495fc9a279d1a9d9e2dba34f0a62f72e24449c00ba322ee46132b52cb1` | `0889d4f1c4df2404dcf7f8c35617b11de3900a79` |

### Exact shared-control-plane exemptions

The exclusions are whole-commit exclusions; none of their files is replayed into the candidate.
The following paths overlap a Phase-2 control-plane allowlist and are explicitly acknowledged so
the overlap itself does not make classification ambiguous:

| Source SHA | Shared exemption paths |
|---|---|
| `f967276f...` | `.tad/active/handoffs/COMPLETION-20260825-yolo2-phase2-bounded-quality-loop.md` |
| `c5f0114b...` | `NEXT.md` |
| `896f63df...` | `NEXT.md` |
| `5dac5ed0...` | `NEXT.md` |

These exemptions authorize exclusion of the exact commits; they do not authorize arbitrary future
commits to modify these paths and do not import the excluded versions into the candidate.

## 2. Canonical recomputation

For every inventory entry, including all four fixed exclusions, the verifier must independently
run Git-object recomputation. It must not return a signed constant in place of computation.

The canonical binary-diff digest is the SHA-256 of stdout from:

```text
git diff --binary <full-first-parent-sha> <full-source-sha>
```

The corrected `f967276f...` value is `3abdcc69...`. DR-20260830's prior `70de6e15...`
value is invalid because the specified command does not produce it. Human approval of this R2
corrects the provenance record; it does not waive recomputation.

The sorted-path digest is SHA-256 over `LC_ALL=C` byte-sorted `git diff --name-only` output with a
single trailing newline. Parent array, source tree, binary diff, stable patch-id, complete changed
path list, classification, reason, and shared-exemption set must all be recomputed and compared.

Unknown exclusions, missing entries, duplicate classification, any field drift, or any future
non-YOLO commit in `BASE..MAIN` must return `RESULT=ERROR`/exit 2 and require a new human-signed
entry. Commit author and message are never classification evidence.

## 3. Allowed candidate boundary

Delete all generic allowances for:

- `.tad/archive/handoffs/**` or cancelled handoffs;
- `.tad/brain-index.md`;
- `.tad/eval/judge/bundles/**`;
- `PROJECT_CONTEXT.md`;
- `.tad/active/epics/EPIC-20260816-framework-health-repair.md`;
- any other non-YOLO path not named by the original Phase-2 handoff or a signed amendment carrier.

The isolated candidate must replay only included Phase-2 commits. Its final diff may contain the
original Handoff §3 allowlists and these exact Alex-authored amendment carriers:

- `.tad/decisions/DR-20260827-yolo2-phase2-amended-acceptance.md`;
- `.tad/decisions/DR-20260830-yolo2-phase2-scope-proof-amendment.md`;
- `.tad/decisions/DR-20260831-yolo2-phase2-budget-amendment.md`;
- this R2 amendment.

## 4. Required fixtures

The same production verifier must exercise real temporary Git repositories and prove:

1. each exact exclusion independently passes when all recomputed fields match;
2. changing source SHA, parent, binary diff, path set, patch-id, reason, or exemption set returns
   ERROR;
3. replacing recomputation with a constant is caught by a negative control;
4. an excluded commit that touches an undeclared shared Phase-2 path returns ERROR;
5. a candidate containing any excluded commit or generic unrelated path fails;
6. an unknown fifth exclusion returns ERROR.

Fixtures that compare one in-memory constant with another are invalid.

## 5. Gate consequences

- The Round-2 tuple `a199030b... / 28c0f9af...` is rejected and cannot be repaired in place.
- Blake must construct a new Phase-2-only candidate from the new pinned main, make the five
  scope-proof carriers immutable, and address the remaining Gate-4 findings for exact Gate-3
  authority binding and complete DR-20260831 dogfood-reuse identity.
- Completion and Gate-3 authority documents must be corrected before the new tuple and reviews are
  generated.
- Group-0 and Layer 2 must bind the new tuple. Blake stops at Gate 3 PASS; Gate 4 and archive remain
  Alex-owned.

This amendment does not pre-approve Gate 3, Gate 4, archive, Phase 3, or default-on.
