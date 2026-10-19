# Process Tax Cut (Layer 2)

> Route, don't duplicate. **SSOT** for the paste blocks: `docs/process-tax-cut.md`.
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

1. Preserve the original finding and severity with a stable ID, original reviewer/round,
   text, path+hunk or command. A path outside handoff §7 is not causal proof of exemption.
2. Compare this task's delta to the initial-byte baseline and prior recorded dirt.
   Prove whether the task introduced, worsened, or newly exposed the defect; merely
   existing earlier or outside the diff is insufficient. Do not absorb others' hunks.
3. Blake proposes a disposition with reason and replayable evidence. The independent
   reviewer responsible for that check must approve it against the checked input.
   If unavailable, an equivalent fresh independent reviewer gets the objective original
   finding/evidence and fix input; record the replacement. Blake self-review never closes it.
4. Final dispositions: fixed (verified fix + relevant AC/check evidence), pre-existing
   (proved prior existence, no task introduction/worsening/new exposure, no AC violation,
   no unresolved severe security/delivery risk), dismissed (locatable counterevidence
   disproves the original premise or applicability). Proposal/uncertainty/dispute stays
   decision=open, final=null. Pure out-of-scope severe risk goes to Alex/human as
   BLOCKED_RISK; Blake neither silently fixes it nor grants an exemption.
5. Ledger: id | origin reviewer+round | original text/path/hunk/command/severity |
   baseline evidence | task causality | proposed disposition | reason+proof |
   independent checker+checked input | decision | final disposition | reopen link.
   Reuse IDs for rediscovery; new evidence may reopen an item. Retain raw reports/counts
   alongside effective open blocking counts/IDs and closure evidence. Do not relabel P0 as P2.
6. Valid independent dispositions affect blocker counts, never AC truth. An AC_FAIL or
   NOT_SATISFIED cannot become satisfied by labeling. Missing counterevidence, a Blake-only
   fixed/pre-existing claim, or unresolved dispute stays open; at the budget limit return
   it to Alex. Independent review and applicable expert coverage remain required.
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

## 4) Optional Layer 2 review habits (OCR thin borrow) — paste into Layer 2 reviewer prompt

Optional paste. Not a Gate. SSOT is `docs/process-tax-cut.md` §4; if drift, docs win.

### Optional Layer 2 review habits (OCR thin borrow, copy)

```
Status: optional paste. Not a Gate. Not a substitute for Gate 2 dual disk reviews or Alex ≠ Blake.

- K1 Asymmetric-bound, falsify-only second pass is optional for the same unchanged delta/report (diff + claimed findings only). Veto only when the diff directly contradicts the claim. Do not mint new findings on this optional pass. Parse/format failure → fail-open (keep the finding). It does not advance coverage, consume a new round, or replace independent disposition approval. R2/R3 repair review is different: it must check fixes and may report new regressions at their actual severity; K1 does not suppress those findings.
- K2 Precision over recall as Layer 2 default. Prefer fewer P0/P1 with replayable evidence (path + command/hunk). Comment volume is not quality. Do not lower recall on security-auditor when that Group 2 trigger fired (see K5).
- K3 Dispatch starts at handoff §7 / task delta and §10. Follow only proven dependency edges (actual reference, configuration consumer, or call relation) for directed read-only checks, including newly identified consumers. Record origin → edge evidence → consumer path + content digest → check → result/proof/unproven. No proven chain means no free repository exploration; no search hit is not safety proof. An unproven dependency affecting AC, security, or necessary coverage stays open; an unrelated unsupported guess is not automatically P0. Read access never grants out-of-scope writes: return necessary changes to Alex. Do not add a rule.json or language-md rule engine.
- K4 Claims must be localizable or labeled unanchored. Every finding cites path + command/hunk, or is labeled unanchored / extra-file. Do not treat model line numbers as SSOT.
- K5 Recall-up is opt-in for high-risk deltas. Extra budget is the existing security-auditor Group 2 trigger — not a named Ultra Gate and not an extra Ralph round by default.

Forbidden in this paste: OCR CLI or npm; replacing Gate 2 / Gate 3 / Layer 2; AACR-Bench as a TAD KPI; Alibaba language rule packs as SSOT.
```
