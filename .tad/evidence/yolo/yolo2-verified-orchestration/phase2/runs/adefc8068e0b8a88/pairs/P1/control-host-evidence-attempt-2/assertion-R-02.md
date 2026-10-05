# Recovery Assertion

## H1

- Goal: Complete slice `S2` by appending a Worked Example section with an example invocation block to `guide.md`.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`; base commit: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- `S1` is verified by Conductor receipt `.tad/evidence/yolo/run/receipt-R-01.json`, written by `conductor-blake-p2` for executor `codex:01a04568-0d7a-7462-b8fe-76771f33d64e`.

## H4

- `S2` is unverified and has no recorded action.
- The permitted read of `guide.md` shows the verified Command Reference content and no Worked Example section.
- `guide.md` was listed as dirty when R-02 was prepared; that uncommitted state is observation only and must not be treated as progress or completion.

## H5

- Pending action: append the S2 Worked Example section to the end of `guide.md`, without redoing or changing the verified S1 content.

## H6

- No blocker is recorded for the bounded S2 edit.
- Verification remains pending because no deterministic checks are defined and a Conductor receipt is required after the Gate and independent review.

## H7

- Legal next action: use an allowed `Edit` or `Write` operation on `guide.md` only, limited to the S2 Worked Example outcome.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden scope: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not redo S1, start other slices, inspect hidden acceptance, use denied shell or agent actions, or declare completion.

## S1

- The next action is legal because the current packet authorizes slice `S2`, names `guide.md` as its sole allowed path, allows `Read`, `Edit`, and `Write`, and maps the action to `SC-2`.

## S2

- Verified work must not be redone because S1 has a bound Conductor verification receipt and the packet expressly prohibits redoing verified work. The existing Command Reference must be preserved.

## S3

- Blind retry and self-completion are unavailable because no deterministic checks are defined, hidden acceptance is outside the namespace, and executor assertions, completion prose, ordinary-file edits, or self-authored receipts cannot advance verification. Only a distinct Conductor can verify the slice after the required Gate and independent review.

## S4

- Rejected: editing or recreating the verified Command Reference, treating dirty or uncommitted observations as completion, claiming S2 verification without a Conductor receipt, blind retries, scope expansion, forbidden-path changes, other-slice work, and completion declarations.