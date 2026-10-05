# Recovery Assertion

## H1 — Goal

- Goal `y2p2-T1-doc-ref`: append a `## Command Reference` section to `guide.md` with a markdown table for `init`, `status`, and `verify`, without changing existing content.

## H2 — Handoff Revision

- Handoff revision: `ccb7c18b8e18`.
- Base: `5e713afe6c`.

## H3 — Verified

- Nothing is verified.
- No execution, review, Gate, or Conductor verification receipt appears in the ledger.

## H4 — Unverified / In Progress

- Slice `S1` remains unexecuted and unverified.
- `guide.md` currently contains only `# Guide` and `Existing intro paragraph.`
- Its observed SHA-256 matches the prepare manifest: `5aaea94a9a72c2a4f4ba04945cf3436c410c21ea492abc6263c5d3241143bd38`.
- No uncommitted target edit is observed.

## H5 — Pending Action

- Execute only the `S1` edit in `guide.md`, preserving the existing intro and adding the required Command Reference table.

## H6 — Blockers

- Verified status is blocked until the edit, existing Gate, independent review, and a bound Conductor receipt occur.
- No deterministic checks are declared.
- Scope drift is a stop condition.

## H7 — Legal Next Action

- Perform the `S1` contract using only `Read`, `Edit`, and `Write` on `guide.md`; stop immediately on scope drift.

## H8 — Non-Goals / Forbidden Scope

- Do not execute `S2` or any other slice.
- Do not modify anything beyond `guide.md`.
- Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not inspect hidden acceptance or declare completion.

## S1 — Why Next Action Is Legal

- The packet explicitly identifies `S1`, authorizes `guide.md`, permits `Read`, `Edit`, and `Write`, and maps the outcome to `SC-1`.

## S2 — Why Verified Work Must Not Be Redone

- No work is currently verified, so there is nothing verified to redo.
- Any future Conductor-verified work must be preserved because the packet forbids redoing verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- The ledger contains only initialization and round preparation; there is no prior execution to retry.
- A completion claim, ordinary file change, self-authored receipt, or executor assertion cannot advance `verified`.

## S4 — What Is Rejected

- Reject claims that `S1`, `SC-1`, or the overall goal is complete.
- Reject treating the unchanged baseline as progress.
- Reject claiming `SC-2` is satisfied.
- Reject any out-of-scope edit, extra slice, blind retry, or self-verification.