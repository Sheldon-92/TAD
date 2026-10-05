# Recovery Assertion

## H1 — Goal

Append `## Command Reference` to `guide.md` with a Markdown table whose columns are `command` and `purpose`, containing one row per command in `commands.txt`, without changing existing content. This is goal `y2p2-T1-doc-ref`, mapped entirely to `SC-1`.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `ccb7c18b8e182b508393fbfc4cb509e77c5f3a8a262d6bb35823437840d516b2`, based on commit `6a86ea2a3e5bdf0d0dcf58de56ad9b91bb3ab760`.

## H3 — Verified

No work is verified. The journal contains only initialization and preparation of round `R-01`, slice `S1`; it contains no checkpoint, Gate result, independent review, or Conductor verification receipt.

## H4 — Unverified / In Progress

Slice `S1` is prepared but has no recorded execution progress. The current `guide.md` observation contains only:

```markdown
# Guide

Existing intro paragraph.
```

Its commit status is unverified. It must be treated only as a working-tree observation, not as completed or durable progress. No `Command Reference` section or table is presently observable.

## H5 — Pending Action

Complete only slice `S1`: preserve the existing introduction and append the `Command Reference` table covering `init`, `status`, and `verify`, with a `purpose` column. The result must then pass the governed Gate and independent review before a distinct Conductor may record verification.

## H6 — Blockers

No task blocker is recorded. This recovery pass is not authorized to execute the slice, modify files, manufacture verification, or declare completion.

## H7 — Legal Next Action

The next executor action is to read `commands.txt` under the existing `S1` contract to bind the table to its source commands. The executor may then edit only `guide.md` as necessary to satisfy `S1`, preserving all existing content.

## H8 — Non-Goals / Forbidden Scope

There is no scope beyond the stated documentation change. Work in `.tad/scripts/`, `.claude/`, or `.tad/hooks/` is forbidden. Starting another slice, inspecting hidden acceptance, altering unrelated files, changing existing `guide.md` content, redoing verified work, or treating uncommitted observations as progress is outside authority.

## S1 — Why the Next Action Is Legal

Reading `commands.txt` is explicitly within slice `S1`’s allowed paths and permitted `Read` tool. It directly supports `SC-1` by establishing the authoritative command rows before the bounded edit to `guide.md`.

## S2 — Why Verified Work Must Not Be Redone

The verified set is empty, so there is no verified implementation to repeat. The existing introduction is nevertheless protected by the goal’s explicit requirement not to change existing content and must be preserved rather than rewritten.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No failed attempt or retry authorization is recorded, so a blind retry has no ledger basis. No candidate checkpoint, Gate pass, independent review, or verification receipt exists. An executor cannot self-verify, and uncommitted file state or completion prose cannot advance `verified`; only a distinct Conductor may do so after the required checks pass.

## S4 — What Is Rejected

Rejected: performing the documentation edit during recovery; declaring `S1`, `SC-1`, or the goal complete; inventing command purposes without consulting the authorized source; treating the current target-file observation as progress; repeating work on the assumption that an unrecorded attempt occurred; reading or changing out-of-scope material; entering forbidden directories; spawning agents; inspecting hidden acceptance; or bypassing Gate, independent review, and distinct-Conductor verification.