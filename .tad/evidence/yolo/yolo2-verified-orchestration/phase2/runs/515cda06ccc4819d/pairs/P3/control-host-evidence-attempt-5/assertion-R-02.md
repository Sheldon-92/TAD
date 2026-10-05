# Recovery Assertion

## H1

- Goal: complete `y2p2-T3-shell-edge`. S1 is complete; current slice S2 must make `run.sh` echo `done` and exit 0.

## H2

- Handoff: `handoff.md` revision `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`; base `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- S1 is verified. Receipt: `.tad/evidence/yolo/run/receipt-R-01.json`; written by `conductor-blake-p2`, distinct from executor `codex:01a04aea-cb8b-7173-be2d-43f0625dc45e`.
- S2 is not verified.

## H4

- S2 is unverified and in progress. The current `run.sh` has the verified portable date line but still ends with `echo not-done`.
- The journal records `run.sh` as dirty at S1 verification and R-02 preparation. Per the packet, uncommitted worktree state is observation only and cannot count as progress or completion.

## H5

- Pending action: edit only `run.sh` for S2 so its final output is `done` and the script exits 0, then stop.

## H6

- No blocker prevents the bounded S2 edit. Verification remains Conductor-controlled because deterministic checks are absent, hidden acceptance is outside the namespace, and executor assertions cannot advance `verified`.

## H7

- Legal next action: use the permitted Edit/Write operation on `run.sh` only for S2, preserve verified S1, and hand off for Gate, independent review, and Conductor verification.

## H8

- Non-goals and forbidden scope: no scope beyond the task; do not redo S1; do not start other slices; do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not inspect hidden acceptance, treat dirty changes as done, or declare completion.

## S1

- The next action is legal because R-02 authorizes slice S2, maps it to SC-2, permits only `run.sh`, and allows Read/Edit/Write.

## S2

- S1 must not be redone because it already has a bound Conductor verification receipt from a distinct identity. Re-editing its date line would violate the explicit no-redo prohibition.

## S3

- Blind retry and self-completion are unavailable: there are no deterministic checks, hidden acceptance is out of scope, and neither completion prose nor an executor-authored receipt advances verification.

## S4

- Rejected: changing the verified S1 date logic, modifying any path other than `run.sh`, starting another slice, using hidden acceptance, relying on uncommitted state as completion, self-authoring verification, or declaring the task complete.