# Process Tax Cut (Layer 2)

> Route, don't duplicate. **SSOT** for the three paste blocks: `docs/process-tax-cut.md`.
> If this file and the guide drift, **docs win**.

**When**: writing §9 ACs; Layer 2 raising P0 on a dirty tree; Gate 2 / dispatch to Blake.

**Teeth**: min 2 independent Gate 2 reviews stay; Alex ≠ Blake stays. This pattern does not skip review.

## Pointers

- Guide (copy-paste blocks): `docs/process-tax-cut.md`
- AC depth: `patterns/ac-verification.md`
- Gate SSOT: `.tad/gates/gate-canonical-checklist.md`

## 1) AC realism — paste into handoff §9 / before Gate 2

```
### AC realism (copy)

- Every landing AC has exactly one legal Verification Method:
  command | path-check | fixture | rubric-spawn | light-tier N/A+one-line reason.
  Prose-only Method = illegal (verify-delta).
- Dry-run each Method on the **live baseline** before locking Gate 2.
  Post-impl rows must fail **for the right reason** on unmodified tree
  (missing file), not hang / ModuleNotFound / empty-set green.
- Known-GOOD must PASS; known-BAD must FAIL. A check that never fails is theater.
- Vacuous tests (any one → rewrite before review spawn):
  - Would this PASS on the unmodified repo?
  - Would this PASS if the enumerated set is empty (`git ls-files` before add)?
  - Would whole-file grep PASS if the sentence sits in the wrong section?
  - Does “tool exits 0” conflict with a mandated BLOCK/honest_partial state?
- Prefer: pathspec-bounded commands, section-scoped awk (not `/start/,/end/` that
  matches the start heading), non-empty set assertion before grepping the set.
- Ban as sole AC: “looks complete”, “files exist”, “reviewer is happy”,
  “no issues found” with no replayable command.
```

## 2) Layer 2 dirty-tree adjudicate — paste into reviewer prompt

Independent review is **required**. This only stops **false P0** from pre-existing dirt.

```
### Layer 2 dirty-tree adjudicate (copy)

Before raising P0 on a dirty worktree:
1. Diff **this task’s pathspec** (handoff §7 / allowed files) vs the finding path.
   Finding outside pathspec → not this knife’s defect unless the contract claimed
   a clean whole-tree fence (then the fence, not the dirt, is in scope).
2. Cross-check **prior knives’ known dirty patterns** in this repo (completion notes,
   Gate 4 “do not absorb dirty NEXT/PROJECT_CONTEXT”, leftover twins, judge bundles,
   gitignored fixtures). If the same path/class was already recorded as out-of-scope
   dirt, mark **FALSE POSITIVE (pre-existing)** with that pointer — do not mint a new P0.
3. Still write the finding. Adjudication is a **label + pointer**, not a skip of
   the second reviewer.
4. Raise P0 only when the defect is in **this delta** or the contract required
   cleanliness of that path.
5. Record: `{path} | P0 vs FALSE_POSITIVE | pointer to prior knife or “in-delta”`.
```

## 3) Gate 2 = disk dual review — paste into handoff Gate 2

Alex running the Gate 2 **protocol** (spawn two reviewers, write evidence) is required. Waiting for a **human chat string** `/gate 2` is forbidden. Human still says `当 Blake` for role switch.

```
### Gate 2 disk-only (copy)

- Process Gate 2 PASS ⇔ two independent review artifacts exist under
  `.tad/evidence/reviews/` (or the handoff’s named evidence paths),
  distinct reviewers, P0=0 or each P0 has a sanctioned resolution row.
- Dispatch Blake when those files exist (plus any L3 the **release/pay/send**
  rules already require). Do **not** block on human typing `/gate 2`.
- Forbidden handoff / prompt wording (examples):
  - “wait for human `/gate 2`”
  - “blocked until user runs /gate 2”
  - “READY_FOR_BLAKE only after human Gate 2 command”
- Allowed: “READY_FOR_GATE2” while dual reviews are still missing;
  “READY_FOR_BLAKE” when dual PASS is **on disk** (human may still confirm
  publish L3 separately — that is not Gate 2).
- `/gate 2` as Alex’s skill invocation = execute the dual-review protocol.
  It is not a standing human lock.
```
