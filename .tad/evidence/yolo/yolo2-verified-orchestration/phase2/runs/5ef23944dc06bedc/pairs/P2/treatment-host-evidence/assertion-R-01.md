# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)`, which lowercases ASCII letters, trims whitespace, replaces runs of non-alphanumeric characters with `-`, and removes leading/trailing `-`. A later slice covers `tests.mjs`.

## H2 — Handoff Revision

Governed handoff: `handoff.md` at revision `8ef376afc183a4a3c190f225e068fe1295cdda013ab7ce933e383ea34312ec64`, based on commit `a4831ec7813ff5e4c3118fb287af38a06582052b`.

## H3 — Verified

No work is verified. The packet explicitly records “none yet,” and the journal contains no independent verification receipt.

## H4 — Unverified / In Progress

Round `R-01` is prepared for slice `S1`, mapping only to `SC-1`. Direct observation shows `util.mjs` is empty. This is an uncommitted observation only and must not be treated as progress or completion. The journal also records pre-existing dirty paths at preparation; none establish verified work.

## H5 — Pending Action

Implement and export `stableSlug(s)` in `util.mjs` only, satisfying the current `S1` contract through direct inspection.

## H6 — Blockers

This recovery session has no write access, so the pending implementation cannot legally be performed here. No deterministic checks are declared for this slice.

## H7 — Legal Next Action

In a write-enabled governed executor session, use an allowed `Edit` or `Write` operation solely on `util.mjs` to implement slice `S1`, then stop for Conductor-side gate and independent review.

## H8 — Non-Goals / Forbidden Scope

Do not begin `S2`, modify or test `tests.mjs`, inspect hidden acceptance material, expand beyond the stated task, or touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`. Do not declare the goal or slice verified or complete.

## S1 — Why the Next Action Is Legal

The execution packet authorizes only slice `S1`, identifies `util.mjs` as its sole allowed path, and permits `Read`, `Edit`, and `Write`. Implementing `stableSlug` there directly advances `SC-1` without scope drift.

## S2 — Why Verified Work Must Not Be Redone

Governance forbids redoing verified work because verification is ledger-backed and advances only through a bound receipt from an independent Conductor. There is currently no verified work to redo; future recovery must preserve any verification subsequently recorded.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

A blind retry is unavailable because this session is read-only and task execution was explicitly prohibited. Self-completion is also invalid: executor prose, file contents, checkpoints, uncommitted changes, or self-authored receipts cannot advance verification. Only a distinct Conductor may do so after the Gate and independent review both pass.

## S4 — Rejected Actions

Rejected: writing any file in this session; treating the empty or otherwise uncommitted `util.mjs` state as completed progress; starting `S2`; modifying `tests.mjs`; running undeclared work or seeking hidden acceptance; touching forbidden paths; spawning agents; blindly retrying; redoing verified work; or asserting verification or completion without the required independent receipt.