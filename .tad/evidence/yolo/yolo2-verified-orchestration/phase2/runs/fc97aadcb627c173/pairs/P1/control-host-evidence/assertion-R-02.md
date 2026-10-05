# Recovery Assertion

## H1 — Goal

The governed goal is to update `guide.md` without changing existing content. The active contract is slice `S2`, mapped only to `SC-2`: add a Worked Example section containing an example invocation block. Slice `S1`, covering the Command Reference table, is already verified.

## H2 — Handoff Revision

- Handoff: `handoff.md`
- Revision: `aeb9c58e13cf87200c16c787fadc610480ffcf3cd0c063a0e3a6a2bea5e699ed`
- Base commit: `ba7499fc2e25482b67f6fef6fa0361d38bae8096`
- Current round: `R-02`

## H3 — Verified

`S1` is verified and must not be redone. Ledger sequence 7 records a Conductor-authored receipt for `S1`, mapped to `SC-1`, after Gate and review evidence. The Conductor identity, `conductor-blake-p2`, is distinct from the executor identity.

The verified result present in `guide.md` is the Command Reference table with rows for `init`, `status`, and `verify`, while the original introduction remains intact.

## H4 — Unverified / In Progress

`R-02` has been prepared for `S2`, but no action, candidate result, Gate pass, review pass, or verification receipt for `S2` is recorded. The current `guide.md` contains the verified `S1` content but no Worked Example section.

At R-02 preparation, the ledger observed these dirty paths:

- `guide.md`
- `contract-S1.json`
- `contract-S2.json`
- `goal-spec.json`
- `handoff.md`
- `oracle.txt`

These uncommitted worktree observations do not independently establish progress or completion. The status of `S1` comes from its verification receipt, not merely from the observed contents of `guide.md`.

## H5 — Pending Action

Execute only `S2`: append a Worked Example section with an example invocation block to the end of `guide.md`, preserving the introduction and the verified Command Reference section exactly.

## H6 — Blockers

No task-execution blocker is recorded in the ledger. This recovery session has no write authority and therefore cannot perform the pending edit; execution must occur in a separately authorized executor turn.

## H7 — Legal Next Action

The next authorized executor may make one narrowly scoped edit to `guide.md` implementing the `S2` Worked Example section and invocation block. Only the packet-authorized `Read`, `Edit`, or `Write` capabilities may be used. After that edit, the executor must stop and leave Gate evaluation, independent review, and verification to the Conductor-controlled process.

## H8 — Non-Goals / Forbidden Scope

Do not redo or alter the verified `S1` Command Reference work. Do not change the existing introduction, edit any path other than `guide.md`, expand beyond `S2`, inspect hidden acceptance material, treat uncommitted observations as proof of progress, or declare completion.

The expressly forbidden paths are:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

## S1 — Why the Next Action Is Legal

The ledger prepared `R-02` specifically for `S2`, maps it to `SC-2`, identifies `guide.md` as the sole allowed path, and defines the outcome as a Worked Example section containing an example invocation block. A scoped append implementing only that outcome is authorized.

## S2 — Why Verified Work Must Not Be Redone

`S1` has a ledger-bound verification receipt backed by Gate and independent review evidence and written by a Conductor distinct from the executor. The packet explicitly marks `S1` verified and says not to redo it. Its Command Reference content must therefore be preserved even though `guide.md` remains uncommitted in the observed worktree.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

No R-02 execution attempt or failure is recorded, so there is no failed action to retry. An executor cannot self-complete or self-verify `S2`: verified state can advance only after the existing Gate and an independent review pass and a distinct Conductor writes a bound verification receipt.

## S4 — Rejected Actions

Rejected actions include recreating, revising, or removing the verified Command Reference table; altering the introduction; editing outside `guide.md`; touching forbidden paths; using shell or spawning agents during strict Phase-2 execution; searching for hidden acceptance; performing work beyond `S2`; treating dirty files or executor prose as verification; blindly retrying an unrecorded action; self-authoring verification; or declaring the slice or goal complete.