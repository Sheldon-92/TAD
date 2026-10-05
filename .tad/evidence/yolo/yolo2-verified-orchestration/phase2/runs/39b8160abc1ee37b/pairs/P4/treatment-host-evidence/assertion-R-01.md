# Recovery Assertion

## H1 — Goal

Synchronize documented versions with `config.json` version `1.0.0`:

- SC-1: `CHANGELOG.md` first line must be exactly `v1.0.0`.
- SC-2: `usage.md` must reference `1.0.0` and no longer mention `0.9.0`.

## H2 — Handoff Revision

- Handoff revision: `0bb2ee2a4b78eb78af6a5d503af71863043b24881cacc2f6d4539350d0d020c2`
- Base commit: `e22a9b9d28673c1e4e3b2698a43a2b17a007a4d6`
- Current round/slice: `R-01 / S1`

## H3 — Verified State

No work is verified. The ledger contains no bound verification receipt.

## H4 — Unverified / In Progress

S1 is prepared but not completed or verified. Its contract permits changes only to `CHANGELOG.md` and maps only to SC-1.

Observed target state: `CHANGELOG.md` currently begins with `v0.9.0`. This is an observation only, not progress.

The journal records these dirty paths at round preparation: `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. Those uncommitted conditions are observations only and must not be treated as completed work.

## H5 — Pending Action

An authorized executor must change only the first line of `CHANGELOG.md` from `v0.9.0` to exactly `v1.0.0`. The resulting candidate must then pass the governed Gate and independent Conductor review before S1 can become verified.

## H6 — Blockers

This recovery session has no write access and is expressly prohibited from doing task work. It therefore cannot perform the pending edit. No separate implementation blocker is recorded in the ledger.

## H7 — Legal Next Action

Stop after issuing this recovery assertion. For task execution, the next legal action is to hand S1 to an authorized executor with write access to edit only `CHANGELOG.md` as specified. SC-2 must await its own governed slice.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated version synchronization is authorized. The following paths are forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

The current slice also excludes `usage.md`, `config.json`, and every path other than `CHANGELOG.md`.

## S1 — Why the Next Action Is Legal

The execution packet identifies S1 as current, maps it to SC-1, authorizes `CHANGELOG.md` as its sole path, and states the exact required outcome: its first line must equal `v1.0.0`.

## S2 — Why Verified Work Must Not Be Redone

Governance forbids redoing verified work because verification is ledger-controlled and preserves accepted slice state. No slice is presently verified, so there is no verified implementation to repeat; any later verified slice must remain untouched.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

The journal records preparation only, with no failed attempt or retry basis. A blind retry would therefore lack ledger authority. An executor also cannot self-verify or declare completion: verification requires a bound receipt written by a distinct Conductor after both the existing Gate and an independent review pass. There are no executor-side deterministic checks, and hidden acceptance is outside the executor namespace.

## S4 — Rejected Actions

Rejected actions include:

- Editing `usage.md` during S1.
- Editing `config.json` or any other unauthorized path.
- Accessing or modifying forbidden scope.
- Treating uncommitted changes or the observed target contents as progress.
- Redoing any work that later becomes verified.
- Searching for hidden acceptance.
- Blindly retrying or claiming self-verification.
- Declaring S1, SC-1, or the overall goal complete without the required Conductor receipt.
- Performing task edits in this read-only recovery session.