# Recovery Assertion

## H1 — Goal

Append `## Command Reference` to `guide.md` with a Markdown table whose columns are `command | purpose` and whose rows cover `init`, `status`, and `verify`, without changing the existing introduction.

## H2 — Handoff Revision

- Handoff revision: `ccb7c18b8e182b508393fbfc4cb509e77c5f3a8a262d6bb35823437840d516b2`
- Base commit: `7cf6dbfefd21f4e6950047ebd2609d5c8f9beafa`
- Active round/slice: `R-01` / `S1`

## H3 — Verified

Nothing is verified. The ledger contains no bound verification receipt, independent-review PASS, or Gate PASS for S1.

## H4 — Unverified / In Progress

S1 is prepared but not completed or verified. Direct observation shows `guide.md` still contains only:

```markdown
# Guide

Existing intro paragraph.
```

No Command Reference section is present. This observation is not progress and cannot be treated as done. The journal records these dirty paths at round preparation: `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; they are uncommitted observations only and are outside the S1 mutation scope.

## H5 — Pending Action

An authorized executor must append the S1 Command Reference table to `guide.md`, listing `init`, `status`, and `verify` with a purpose column while preserving the existing introduction exactly.

## H6 — Blockers

No ledger-recorded blocker exists. This recovery session has no write authority and therefore cannot execute the pending edit. No deterministic checks are declared; verification still requires the governed Gate and independent Conductor review.

## H7 — Legal Next Action

The only legal next task action is to execute S1 by editing `guide.md` alone to append the specified Command Reference section. Afterward, the result may be submitted as a candidate for Conductor-side Gate and independent review; the executor may not declare it verified or complete.

## H8 — Non-Goals / Forbidden Scope

No work beyond S1 is authorized. In particular:

- Do not start S2 or add the Worked Example section.
- Do not modify any path other than `guide.md`.
- Do not access hidden acceptance material.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not treat checkpoints, prose assertions, ordinary files, self-authored receipts, or uncommitted changes as verification.

## S1 — Why the Next Action Is Legal

The execution packet designates S1 as the current slice, maps it to SC-1, identifies `guide.md` as its sole allowed path, and defines the required outcome as the Command Reference table with the existing introduction untouched.

## S2 — Why Verified Work Must Not Be Redone

Governance forbids redoing verified work because verification advances only through a bound receipt written by a distinct Conductor after Gate and independent-review PASS. No work is presently verified, so there is nothing eligible for repetition; once such a receipt exists, that slice must not be executed again.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

The ledger records no failed S1 attempt that would justify a retry, and worktree observations cannot establish progress or completion. The executor cannot self-verify: candidate status records intent only, and completion requires a distinct Conductor’s bound verification receipt after the governed checks pass.

## S4 — Rejected Actions

Rejected actions include performing the edit during this assertion-only recovery, treating the current worktree as completed progress, inventing a verification result, declaring S1 or the overall goal complete, starting S2, modifying non-`guide.md` files, examining hidden acceptance, entering forbidden directories, or retrying work without a ledger-authorized basis.