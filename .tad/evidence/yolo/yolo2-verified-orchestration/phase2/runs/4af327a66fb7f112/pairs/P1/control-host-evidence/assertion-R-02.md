# Recovery Assertion

## H1 — Goal

The governed goal is to preserve the existing `guide.md` content while adding the required command documentation. `SC-1` requires a Command Reference table for `init`, `status`, and `verify`; `SC-2` requires a Worked Example section containing an example invocation block.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at SHA-256 `aeb9c58e13cf87200c16c787fadc610480ffcf3cd0c063a0e3a6a2bea5e699ed`, based on commit `8a89fa40e5e7aac0b845cb49d8a8c0741a886547`.

## H3 — Verified State

Slice `S1`, mapped to `SC-1`, is verified and must not be redone. Journal sequence 7 records a bound receipt written by `conductor-blake-p2`, distinct from executor `codex:01a04028-b347-7a21-bff6-3cfeba9c2035`, with Gate and review evidence.

The verified content visible in `guide.md` includes the unchanged introduction and the Command Reference table with rows for `init`, `status`, and `verify`.

## H4 — Unverified / In-Progress State

Round `R-02` has prepared slice `S2`, mapped only to `SC-2`. No execution attempt, action, checkpoint, Gate result, review, or verification receipt for `S2` is recorded.

At round preparation, the journal observed uncommitted paths `guide.md`, `contract-S1.json`, `contract-S2.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. These are observations only. The dirty status of `guide.md` does not invalidate its separately verified `S1` content, and none of the dirty paths constitutes progress on `S2`.

## H5 — Pending Action

Execute only slice `S2`: append a Worked Example section containing an example invocation block to `guide.md`, while preserving the existing introduction and verified Command Reference section exactly.

## H6 — Blockers

The packet provides no deterministic checks and does not specify the exact example invocation text or code-block language. Those omissions do not authorize scope expansion, alteration of verified content, or invention of additional requirements. This recovery turn has no write or task-execution authority.

## H7 — Legal Next Action

After recovery, the next governed executor action is to edit only `guide.md` using an allowed `Read`, `Edit`, or `Write` capability and append the `S2` Worked Example section with an example invocation block. The executor must stop if satisfying that outcome would require scope drift or modification of the verified `S1` content.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated task is authorized. Changes under `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Hidden acceptance is outside the executor namespace. Redoing `S1`, modifying existing text, starting any slice other than `S2`, declaring completion, using shell/Bash, or spawning agents is prohibited.

## S1 — Why the Next Action Is Legal

The ledger prepared round `R-02` specifically for slice `S2`; the slice maps to `SC-2`, permits changes only to `guide.md`, and allows `Read`, `Edit`, and `Write`. Appending the Worked Example section while preserving all existing content is therefore the sole legal execution action.

## S2 — Why Verified Work Must Not Be Redone

`S1` has a ledger-recorded verification receipt backed by Gate and independent review evidence and authored by a Conductor distinct from the executor. The packet explicitly marks `S1` as verified and says “DO NOT redo.” Its introduction and Command Reference table must be treated as protected prior work even though `guide.md` remains uncommitted.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no recorded `S2` attempt or failure to retry, so a blind retry has no governed basis. The executor also cannot self-complete: checkpoints record only intent, and executor prose, file contents, uncommitted changes, or self-authored receipts cannot advance `verified`. Verification requires a distinct Conductor’s bound receipt after Gate and independent review both pass.

## S4 — What Is Rejected

Rejected actions include redoing or rewriting `S1`; 