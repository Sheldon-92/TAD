# Recovery Assertion

## H1

- Goal: `y2p2-T3-shell-edge`
- Fix `run.sh` to print today’s year portably on GNU and BSD `date`, then echo `done`.
- Active slice: R-02 / S2, mapped to SC-2.

## H2

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`

## H3

- S1 is verified.
- The journal records a bound Conductor receipt with distinct `written_by_id` and `executor_id`.
- S1 must not be redone.

## H4

- S2 is unverified and in progress.
- `run.sh` currently contains the verified portable year line but still ends with `echo not-done`.
- The journal records `run.sh` as dirty at S1 verification and R-02 preparation; this is an uncommitted observation, not evidence of S2 completion.
- No S2 verification receipt is recorded.

## H5

- Pending action: edit `run.sh` only to replace `echo not-done` with `echo done`, preserve the verified S1 line, and then stop for Conductor-side verification.

## H6

- No task failure is recorded.
- Verification is pending because no deterministic checks are declared and verified status requires Gate, independent review, and a distinct Conductor receipt.
- Shell/Bash and Agent spawning are denied; hidden acceptance is outside the namespace.

## H7

- The legal next action is an `Edit` or `Write` limited to `run.sh` for S2, followed by handoff for verification.
- No S1 changes or completion claim are legal.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Redoing S1, modifying other files, inspecting hidden acceptance, treating dirty observations as progress, or declaring completion is forbidden.

## S1

- The next action is legal because the active packet authorizes S2, maps it to SC-2, allows only `run.sh`, and permits `Read`, `Edit`, and `Write`.

## S2

- Verified S1 work must not be redone because the journal records its Conductor-bound verification and the packet explicitly prohibits redoing verified work.
- The S1 year-line change must be preserved while completing S2.

## S3

- Blind retry and self-completion are unavailable because checkpoints are only candidates.
- Only a distinct Conductor receipt after Gate and independent review can advance verification; executor assertions, prose, ordinary files, and self-authored receipts cannot.

## S4

- Rejected: re-editing S1, changing files outside `run.sh`, touching forbidden paths, starting other slices, using Shell/Bash or Agents, seeking hidden acceptance, treating uncommitted observations as done, and claiming completion or verification without the required receipt.