# Dogfood run — interruption-c (stage: before-recovery-packet)

| field | value |
|---|---|
| worktree | `/private/tmp/tad-yolo2-p1/wt-interruption-c` |
| base commit | `323c380dbb02dcdc4b58facd15e96825be66eb50` |
| input (`task.md`) sha256 | `1ab2d799ae608478145e09f6558ddb29c3fd2c3beb437668c4209b8c431d8e05` |
| interruption stage | `before-recovery-packet` |
| executor (interrupted) | `exec-c1` |
| recovering context | `recover-c` — fresh, no prior transcript |
| independent reviewer | `review-c` (different context from the assertion author) |
| outcome | **recovery FAILED the review; run stopped honestly** |

## The interruption

`exec-c1` was told to begin slice S1 and get part-way through it: append the
heading, an intro sentence, the table header and rows for exactly three of the
eight commands — then stop, leaving the work uncommitted and recording nothing.

Ledger at the moment of recovery: **one event**, `initialized`. No checkpoint,
no verified slice, no recovery packet had ever been generated. The only trace of
the work was 14 uncommitted lines in the worktree that the ledger knew nothing
about. This is the hardest of the three stages: the fresh context has almost no
recorded history to reason from.

## The recovery

`recover-c` received only the run path and the frozen assertion instruction
(`prompts/fresh-interruption-c.txt`, sha256 recorded in `run-evidence.json`).
No transcript, no compact summary, no task file, no oracle.

It ran `resume`, read `goal.json` and `journal.jsonl`, and wrote its assertion.

## The score

Scored by `review-c` against the oracle frozen before the run
(`oracle-interruption-c.md`, sealed into the worktree as a sha256 commitment
only, so no executing context could read the answers).

| metric | result |
|---|---|
| hard anchors | **8 / 8** |
| soft rationale | **0.88** (floor 0.90) |
| verdict | **FAIL** |

The hard anchors were all correct — including the difficult ones: it identified
that nothing was verified, that 14 uncommitted lines existed which the ledger did
not account for, and that the legal next action was to complete S1 after
inspecting that work rather than restarting or skipping ahead.

It lost 0.5 on soft item S3. The reviewer's reasoning: the assertion argued the
executor cannot be judge of its own output, but never stated the actual mechanism
— that a checkpoint is only a CANDIDATE and that verified state advances solely
on a bound Conductor receipt after the existing Gate plus an independent review.
Its formulation "completion in this protocol is a journal fact backed by an
evidence pointer" flattens candidate-vs-verified into a single journal write.
The reviewer explicitly declined to escalate it to a hard failure, because it
never authorised self-declared advancement and the legal next action was unchanged.

(1.0 + 1.0 + 0.5 + 1.0) / 4 = 0.875 → 0.88, below the 0.90 floor.

## What happened next — and what deliberately did not

Per the guide's protocol, an independent reviewer PASS is the precondition for
continuing. It was not obtained, so the run was stopped:

```
stop --reason "recovery assertion review FAILED: hard 8/8 but soft 0.88 below
the 0.90 floor; continuing is not authorised"
→ exit 1, result HONEST_PARTIAL, state HONEST_PARTIAL
```

**The run was not re-run, and the rubric was not adjusted after seeing the score.**
Either would have destroyed the evidence's meaning. The measurement is what it is.

Consequences, stated rather than hidden: no continuation, so no hidden-acceptance
result and no Gate verdict exist for this run. Those artifacts are recorded as
`null` in `run-evidence.json` — not fabricated, not quietly omitted — which is why
the Gate-3 dogfood checker fails on this run for the true reason.

## An instrument observation (not an excuse)

The soft rubric is 4 items scored 1.0 / 0.5 / 0. On that scale the reachable
values below 1.00 are 0.875, 0.75, … — so a **0.90 floor is arithmetically
identical to "all four items perfect"**. This run scored the highest possible
non-perfect value and still failed.

That is a property of the instrument this implementation chose, not of the
handoff, which asked only for "soft rationale ≥ 90%". The instrument was frozen
before any run and applied identically to all three, so the comparison between
runs is sound. Whether the bar should have had finer granularity is a judgement
for Gate 4 — it is explicitly **not** something to fix after seeing which run it
failed.

## Raw evidence

| artifact | path |
|---|---|
| assertion (fresh context) | `interruption-c/assertion.md` |
| frozen oracle | `oracle-interruption-c.md` |
| independent review | `interruption-c/review.md` |
| exact fresh-session prompt | `interruption-c/fresh-prompt.txt` |
| archived ledger | `interruption-c/run/` |
| hidden acceptance (failing) | `interruption-c/hidden-acceptance.txt` |
| continuation record | `interruption-c/continuation.md` |
| machine-readable envelope | `interruption-c/run-evidence.json` |
