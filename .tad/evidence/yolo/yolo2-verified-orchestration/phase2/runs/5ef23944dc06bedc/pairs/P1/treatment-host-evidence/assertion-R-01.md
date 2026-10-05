# Recovery Assertion

## H1 — Goal

Append `## Command Reference` to `guide.md` with a Markdown table whose columns are `command | purpose` and whose rows cover `init`, `status`, and `verify`, without changing the existing introduction. The overall goal also contains SC-2, but that is not part of the current slice.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `ccb7c18b8e182b508393fbfc4cb509e77c5f3a8a262d6bb35823437840d516b2`, based on commit `d488e5bfa1b61708ca4a2bf19200dbb0e1d1ab7c`.

## H3 — Verified

Nothing is verified. No bound verification receipt, Gate PASS, or independent-review PASS is recorded.

## H4 — Unverified / In Progress

Slice S1 is prepared but unverified. The permitted observation of `guide.md` shows only:

```markdown
# Guide

Existing intro paragraph.
```

No Command Reference section is present. This observation is not progress or completion. The journal also records pre-existing dirty paths at round preparation—`contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`—which are observations only and must not be attributed to S1.

## H5 — Pending Action

S1 remains pending: append only the required Command Reference table to `guide.md`, preserving all existing content. After execution, Conductor-side Gate and independent review must pass before a distinct Conductor may issue a bound verification receipt.

## H6 — Blockers

This recovery session has no write authority and explicitly forbids task execution, so S1 cannot be performed in this turn. The exact purpose text is not established by the permitted observations and must not be invented during recovery.

## H7 — Legal Next Action

The next execution action, when performed by an authorized write-capable executor, is to execute S1 only by editing `guide.md` within its slice contract. No S2 work or completion declaration is authorized.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated task is authorized. The paths `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Starting S2, searching hidden acceptance, changing existing guide content, touching other paths, redoing verified work, or treating uncommitted changes as completed progress is outside scope.

## S1 — Why the Next Action Is Legal

S1 is the current prepared slice, maps only to SC-1, and authorizes `guide.md` as its sole writable path with Read/Edit/Write tools. Appending the specified table while preserving the introduction directly implements the slice outcome.

## S2 — Why Verified Work Must Not Be Redone

The packet expressly prohibits redoing verified work, and verified state can advance only through a bound receipt written by a Conductor distinct from the executor after both Gate and independent review pass. No such verified work currently exists, so there is nothing legal to redo.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No failed execution or retryable checkpoint is recorded, and a checkpoint would be only a candidate in any event. There are no declared deterministic checks. Executor prose, file contents, self-authored receipts, and uncommitted observations cannot establish verification or completion; only the required distinct-Conductor process can do so.

## S4 — What Is Rejected

Rejected: performing task work during this recovery assertion; writing any file; beginning SC-2/S2; declaring the goal or S1 complete; inventing command purposes; modifying the existing introduction; touching any path other than `guide.md` during S1; accessing hidden acceptance; entering forbidden scope; treating dirty or observed state as progress; blind retrying; self-verifying; or bypassing Gate, independent review, and the distinct-Conductor receipt requirement.