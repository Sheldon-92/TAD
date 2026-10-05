# Recovery Assertion

## H1

- Goal: fix `run.sh` so it prints today’s four-digit year portably on GNU and BSD `date`, then echoes `done` and exits 0. Current slice: S1, covering SC-1 only.

## H2

- Handoff: `handoff.md` at revision `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`; base `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- Verified state: none. No Conductor verification receipt is recorded.

## H4

- Unverified/in progress: R-01 prepared slice S1, but no executor edit or verification is journaled. Current `run.sh` contains `date +%Y 2>/dev/null || date -j +%Y` followed by `echo not-done`.
- The journal’s prepare-time dirty paths do not include `run.sh`; any uncommitted worktree changes remain observation only and cannot count as progress or completion.

## H5

- Pending action: make the bounded S1 edit to `run.sh` for SC-1 only, then stop for governed verification. SC-2 remains deferred.

## H6

- No blocker prevents the bounded S1 edit. Verification is constrained because there are no deterministic checks, hidden acceptance is outside the namespace, and only a distinct Conductor may advance `verified` after Gate and independent review.

## H7

- Legal next action: use an allowed Edit/Write operation on `run.sh` only to implement S1, preserve S2 behavior for now, and hand off without declaring completion.

## H8

- Non-goals and forbidden scope: no scope beyond the task; do not start S2 or another slice; do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not inspect hidden acceptance, treat uncommitted changes as done, or declare completion.

## S1

- The next action is legal because the current slice is S1, maps to SC-1, permits only `run.sh`, and allows Read/Edit/Write.

## S2

- No verified work exists to redo. Any later Conductor-verified work must be preserved because redoing verified work is explicitly prohibited.

## S3

- Blind retry and self-completion are unavailable: deterministic checks are empty, hidden acceptance is out of scope, and executor assertions or self-authored receipts cannot advance verification.

## S4

- Rejected: treating the current file or round preparation as verified, modifying SC-2 now, touching forbidden paths, starting other slices, using hidden acceptance, relying on uncommitted changes as progress, self-authoring verification, or declaring completion.