# Recovery Assertion

## H1 — Goal

Append a `## Command Reference` table and a `## Worked Example` section to `guide.md` as specified by the goal.

## H2 — Handoff Revision

`handoff.md` revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`; base commit: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3 — Verified

Slice S1 / SC-1 is verified by the Conductor receipt. It must not be redone.

## H4 — Unverified / In Progress

Slice S2 / SC-2 is unverified and has no recorded R-02 action. The observed `guide.md` contains the verified Command Reference table but no Worked Example section. The journal records `guide.md` as dirty; this observation is not evidence of S2 progress or completion.

## H5 — Pending Action

Append a Worked Example section containing an example invocation block to `guide.md`.

## H6 — Blockers

No execution blocker is recorded. Verification remains pending because it requires Conductor-side Gate and independent review evidence.

## H7 — Legal Next Action

Perform only the R-02 S2 edit on `guide.md`, using an allowed Edit or Write operation, then stop for Conductor verification.

## H8 — Non-Goals / Forbidden Scope

No scope beyond the stated task. Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not start other slices, redo S1, run shell or agents, inspect hidden acceptance, or declare completion.

## S1 — Why the Next Action Is Legal

The R-02 packet explicitly assigns slice S2, maps it to SC-2, permits only `guide.md`, and allows Read, Edit, and Write tools.

## S2 — Why Verified Work Must Not Be Redone

S1 has a bound verification receipt written by a distinct Conductor identity, and the packet explicitly says `S1` is verified and “DO NOT redo.”

## S3 — Why Blind Retry / Self-Completion Is Unavailable

The journal records no failed or completed R-02 action. The verification model requires a distinct Conductor receipt after Gate and independent review; an executor assertion, self-authored receipt, or completion prose cannot advance verification.

## S4 — What Is Rejected

Reject any retry of S1, any action outside S2 or `guide.md`, any forbidden-path or shell/agent action, treating dirty observations as completion, hidden-acceptance inspection, and self-declaration of completion.