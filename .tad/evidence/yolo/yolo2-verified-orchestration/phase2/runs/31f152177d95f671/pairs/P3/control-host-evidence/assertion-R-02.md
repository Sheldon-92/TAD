# Recovery Assertion

## H1

- Goal `y2p2-T3-shell-edge`: fix `run.sh` to print today’s 4-digit year portably on GNU and BSD `date`, then echo `done`.
- Current slice S2 maps to SC-2: `run.sh` ends by echoing `done` and exits 0.

## H2

- Handoff: `handoff.md` at revision `b276f08f98bd968edbbf9f31db4d0a5fb12f1f11ed9700b1fe8a231761697914`.
- Base commit: `f6c3226139e17896445f5294ebc6b85fccecf850`.

## H3

- S1 is verified by a distinct Conductor with Gate and independent-review evidence.
- S2 is not verified.

## H4

- Round R-02 is prepared for S2.
- `run.sh` currently appears to contain `date +%Y` followed by `echo done`; this is an uncommitted observation only and must not be treated as progress or completion.
- S2 remains unverified and in progress.

## H5

- Pending action: execute only S2 against `run.sh`, ensuring it ends by echoing `done` and exits 0.

## H6

- No execution blocker is recorded.
- No deterministic checks are available to the executor; verification must remain Conductor-side.

## H7

- The legal next action is to use only Read/Edit/Write on `run.sh` for S2, without redoing S1, then stop for governed verification.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Starting other slices, redoing verified S1, using Shell/Bash or Agent spawning, inspecting hidden acceptance, treating dirty changes as done, and declaring completion are forbidden.

## S1

- The next action is legal because R-02 authorizes S2, maps it to SC-2, permits only `run.sh`, and allows Read, Edit, and Write.

## S2

- S1 has already been verified by the Conductor and must not be redone.
- Repeated verified actions are prohibited.

## S3

- Blind retry and self-completion are unavailable because no deterministic checks are declared.
- A checkpoint is only a candidate; verification requires a distinct Conductor receipt after Gate and independent review.
- Hidden acceptance is outside the executor namespace.

## S4

- Reject S1 rework, edits outside `run.sh`, forbidden-path access, Shell/Bash or Agent spawning, hidden-acceptance inspection, treating the dirty observation as completion, self-authored verification, and any completion declaration.