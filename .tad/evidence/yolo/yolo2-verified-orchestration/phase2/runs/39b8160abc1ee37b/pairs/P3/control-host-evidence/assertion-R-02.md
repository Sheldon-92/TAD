# Recovery Assertion

## H1 — Goal

Fix `run.sh` so it prints today’s four-digit year using a portable invocation compatible with GNU and BSD `date`, then echoes `done` and exits successfully.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `b276f08f98bd968edbbf9f31db4d0a5fb12f1f11ed9700b1fe8a231761697914`, based on commit `6fc13f0db01b21e2be29d4bd2cc0391bf57d1f8f`.

## H3 — Verified State

Slice S1, mapping to SC-1, is verified by the Conductor-written receipt recorded in the ledger. The portable year-printing work must not be redone or altered.

## H4 — Unverified / In-Progress State

Round R-02 is assigned only to slice S2, mapping to SC-2: `run.sh` must end by echoing `done` instead of `not-done` and exit successfully.

The observed, uncommitted `run.sh` contains:

```sh
#!/bin/sh
date '+%Y'
echo not-done
```

The `date '+%Y'` line belongs to verified S1 and must be preserved. The observed `echo not-done` line shows that S2 remains pending. Worktree observations are not verified progress and must not be treated as done.

## H5 — Pending Action

Change only the S2 behavior in `run.sh` so its final command echoes `done` and the script exits successfully, while preserving the verified portable year invocation. The result remains a candidate until a distinct Conductor records verification after a passing Gate and independent review.

## H6 — Blockers

No implementation or scope blocker is recorded. Verification remains unavailable to the executor: there are no predeclared deterministic checks, and hidden acceptance, self-verification, and executor-authored promotion are prohibited.

## H7 — Legal Next Action

The next legal action is one governed S2 edit to `run.sh`, using only the allowed Read/Edit/Write capabilities, replacing the final `echo not-done` behavior with `echo done` while leaving the verified S1 line unchanged. Then the executor must stop and allow the Conductor-controlled Gate, independent review, and receipt process to determine verification.

## H8 — Non-Goals and Forbidden Scope

No work beyond the stated goal is authorized. S1 must not be redone, and no path other than `run.sh` may be edited.

The following paths are forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

Shell/Bash execution, agent spawning, hidden-acceptance inspection, starting another slice, treating uncommitted changes as completed work, and declaring completion are forbidden.

## S1 — Why the Next Action Is Legal

It implements exactly the active S2 outcome, maps only to SC-2, targets the sole allowed path `run.sh`, uses the packet’s Read/Edit/Write allowlist, and preserves the verified S1 behavior.

## S2 — Why Verified Work Must Not Be Redone

The ledger contains a bound S1 verification receipt written by `conductor-blake-p2`, distinct from the executor, after recorded Gate and review evidence. The packet explicitly marks S1 verified and says “DO NOT redo,” so the `date '+%Y'` behavior must remain intact.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

The target file is an uncommitted observation, not proof of progress. Any edit must be reconciled specifically against S2 rather than broadly rewriting the script. Executor assertions, completion prose, ordinary files, checkpoints, and self-authored receipts cannot advance verification; only a distinct Conductor can do so after both the Gate and independent review pass.

## S4 — What Is Rejected

Rejected actions include:

- Modifying or reimplementing the verified `date '+%Y'` line.
- Editing anything beyond the final S2 behavior in `run.sh`.
- Editing any other path or touching forbidden paths.
- Running Shell/Bash or spawning agents.
- Inspecting hidden acceptance.
- Treating an edit, checkpoint, or observed worktree state as verified completion.
- Beginning another slice or declaring the overall goal complete.
- Adding unrelated cleanup, refactoring, tests, or scope.