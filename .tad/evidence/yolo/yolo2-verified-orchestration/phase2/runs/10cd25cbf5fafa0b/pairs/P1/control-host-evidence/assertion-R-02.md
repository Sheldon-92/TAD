# Recovery Assertion

## H1 — Goal

Goal `y2p2-T1-doc-ref` is to append a `## Command Reference` table to `guide.md` without changing existing content. The governed success criteria additionally require SC-2: a Worked Example section containing an example invocation block.

## H2 — Handoff Revision

The handoff revision is `aeb9c58e13cf87200c16c787fadc610480ffcf3cd0c063a0e3a6a2bea5e699ed`, based on commit `bc5f0868504a4c9a76631d2400c4b9055ed2e511`.

## H3 — Verified State

Slice S1, mapped to SC-1, is verified and must not be redone. Journal sequence 7 records a bound receipt written by `conductor-blake-p2`, distinct from the executor, with Gate and review evidence. The verified Command Reference table is present in `guide.md`.

## H4 — Unverified / In-Progress State

Slice S2 is prepared for round R-02 but has no recorded execution, checkpoint, Gate result, review, or verification receipt. The observed `guide.md` contains the verified S1 content but no Worked Example section.

At R-02 preparation, the journal reports `guide.md`, `contract-S1.json`, `contract-S2.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt` as dirty. These are uncommitted observations only; except for S1’s separately receipted effect, they are not progress or verified work.

## H5 — Pending Action

S2 remains pending: add a Worked Example section with an example invocation block to `guide.md`, preserving the existing introduction and verified Command Reference section.

## H6 — Blockers

No blocker is recorded. No deterministic checks are declared for S2. Verification will still require a Gate PASS, independent review PASS, and a bound receipt written by a Conductor distinct from the executor.

## H7 — Legal Next Action

The only legal next task action is to execute S2 against `guide.md` using the authorized Read/Edit/Write tools, adding only the Worked Example section and stopping if scope drift occurs.

## H8 — Non-Goals / Forbidden Scope

No work beyond S2 is authorized. S1 must not be repeated or altered. Changes outside `guide.md`, including changes under `.tad/scripts/`, `.claude/`, or `.tad/hooks/`, are forbidden. Hidden acceptance must not be inspected, and existing verified content must be preserved.

## S1 — Why the Next Action Is Legal

The R-02 packet expressly selects S2, maps it to SC-2, authorizes `guide.md` as the sole path, and permits Read/Edit/Write. Adding only the specified Worked Example section therefore matches the active slice contract.

## S2 — Why Verified Work Must Not Be Redone

S1 has a ledger-recorded verification receipt backed by Gate and independent-review evidence. Repeating or altering its Command Reference work would violate the explicit prohibition against redoing verified work and could invalidate its bound effect.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No S2 attempt or failure is recorded, so there is no ledger basis for a retry. The executor cannot declare S2 complete or advance `verified`; only a distinct Conductor may issue the bound verification receipt after the required Gate and independent review pass.

## S4 — What Is Rejected

Rejected actions include redoing or modifying S1; changing the existing introduction or Command Reference table; touching any path other than `guide.md`; entering forbidden directories; starting unlisted work; treating dirty files or executor prose as verification; searching for hidden acceptance; using shell/Bash or spawning agents during strict Phase 2; blindly retrying; self-verifying; or declaring completion.