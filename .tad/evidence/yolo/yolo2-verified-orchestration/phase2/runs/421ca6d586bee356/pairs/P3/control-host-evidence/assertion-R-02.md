# Recovery Assertion

## H1

- Goal: Fix `run.sh` to print today’s year portably on GNU and BSD `date`, then echo `done`.
- Current slice: S2, requiring `run.sh` to end by echoing `done` and exit 0.

## H2

- Handoff revision: `b276f08f98bd968edbbf9f31db4d0a5fb12f1f11ed9700b1fe8a231761697914`.
- Base: `0869a6fd1b98e16b193414201c5bdb0e59820a07`.

## H3

- S1 is verified by the R-01 receipt, written by distinct Conductor `conductor-blake-p2`, mapping to SC-1.
- S2 is not verified; no S2 verification receipt is recorded.

## H4

- S2 remains unverified.
- The worktree observation is that `run.sh` already contains a portable year command and ends with `echo done`.
- The ledger marks `run.sh` dirty at R-02 preparation; this is observation only and must not be treated as progress or completion.
- No S2 edit or verification action is recorded.

## H5

- Pending action: preserve the already-observed `run.sh` state and route S2 through the required Gate, independent review, and distinct-Conductor verification receipt.

## H6

- S2 has no bound verification receipt.
- No deterministic checks are declared.
- No explicit environment blocker is recorded; verification evidence remains pending.

## H7

- The legal next action is read-only reconciliation of the existing S2 state followed by the mandated verification path, with no edit when the requested end state already exists.
- No task work is performed in this assertion turn.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- S1 redo, unnecessary S2 edits, hidden-acceptance inspection, and unsupported completion claims are forbidden.

## S1

- The next action is legal because R-02 authorizes only slice S2, maps it to SC-2, and limits the target to `run.sh`; the existing end state means no edit is needed.

## S2

- S1 is verified and must not be redone because its distinct-Conductor receipt is recorded.
- The observed S2 content is not verified work, but it also must not be rewritten merely to fabricate an edit.

## S3

- Blind retry and self-completion are unavailable because no deterministic checks are declared, hidden acceptance is outside the namespace, uncommitted observations cannot count as done, and only a distinct Conductor receipt advances verification after Gate and review PASS.

## S4

- Rejected: redoing S1, fabricating an S2 edit, starting other slices, editing forbidden paths, treating the dirty observation as verified, inspecting hidden acceptance, or declaring completion without the required receipt.