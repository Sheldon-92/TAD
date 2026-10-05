# Recovery Assertion

## H1

- Goal: `y2p2-T1-doc-ref`.
- Overall objective: preserve existing `guide.md` content while adding the required command reference and worked example.
- Current slice: `S2`, which maps to `SC-2` and requires a Worked Example section containing an example invocation block.

## H2

- Handoff revision: `17b14aa1367710cfe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base commit: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- `S1` is verified.
- The journal records receipt `.tad/evidence/yolo/run/receipt-R-01.json`, with `written_by_id` `conductor-blake-p2` distinct from executor `codex:01a04ac5-bbb7-7773-bf41-f6e081508094`.
- `S1` maps to `SC-1` and must not be redone.

## H4

- `S2` remains unverified and has no recorded execution action.
- `guide.md` currently contains the verified Command Reference section but no Worked Example section.
- `guide.md` is listed among the uncommitted paths at R-02 preparation; this is an observation only and must not be treated as S2 progress or completion.

## H5

- Pending action: append a Worked Example section with an example invocation block to `guide.md`.
- Existing content, including the verified Command Reference section, must remain unchanged.

## H6

- No technical blocker or failed S2 attempt is recorded.
- S2 verification remains pending until the edit is performed and the required Gate, independent review, and distinct-Conductor receipt are completed.

## H7

- The next legal action is one scoped Edit/Write to `guide.md` for S2 only.
- The action must append the Worked Example section, use only the permitted tools, and stop on scope drift.

## H8

- Non-goals: redoing S1, changing the existing Command Reference, starting other slices, expanding scope, or declaring overall completion.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Hidden acceptance, shell/Bash execution, and Agent spawning are outside the authorized scope.

## S1

- The next action is legal because the S2 contract allows only `guide.md`, permits `Read`, `Edit`, and `Write`, and explicitly defines the Worked Example outcome mapped to `SC-2`.

## S2

- S1 has a bound verification receipt from a distinct Conductor, so it is verified work and must not be repeated. The packet also sets the repeated verified action limit to zero.

## S3

- Blind retry is unavailable because no S2 failure or prior S2 action is recorded.
- Self-completion is unavailable because only a distinct Conductor receipt after Gate and independent review advances verification; executor assertions, ordinary files, and self-authored receipts do not.

## S4

- Rejected: redoing S1, treating the dirty `guide.md` state as S2 completion, altering verified content, self-verifying, declaring completion, editing forbidden paths, or starting another slice.