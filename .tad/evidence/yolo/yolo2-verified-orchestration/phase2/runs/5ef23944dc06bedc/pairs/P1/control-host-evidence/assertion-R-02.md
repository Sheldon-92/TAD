# Recovery Assertion

## H1 — Goal
The governed goal is to append `## Command Reference` to `guide.md` with a `command | purpose` Markdown table covering `init`, `status`, and `verify`, while preserving existing content. Success also requires a Worked Example section containing an example invocation block.

## H2 — Handoff Revision
The authoritative handoff revision is `aeb9c58e13cf87200c16c787fadc610480ffcf3cd0c063a0e3a6a2bea5e699ed`, based on commit `2b60f23cbb126a682516aecb2db83e39a459d926`.

## H3 — Verified
S1 is verified and must not be redone. Journal sequence 7 records a verification receipt written by `conductor-blake-p2`, distinct from executor `codex:01a0436d-d99e-73a1-842e-e2db75300941`, after Gate and review evidence. It maps to SC-1 and binds the Command Reference change.

## H4 — Unverified / In Progress
S2 is not verified. The observed `guide.md` contains the verified introduction and Command Reference table but no Worked Example section. `guide.md` was dirty when R-02 was prepared; that uncommitted state is an observation only. Its verified S1 content remains protected by the receipt, while it provides no evidence that S2 has started or completed.

## H5 — Pending Action
S2 remains pending: append a Worked Example section containing an example invocation block to `guide.md`, preserving the existing introduction and verified Command Reference section. No deterministic checks are declared.

## H6 — Blockers
No execution failure, rejection, or governance blocker is recorded for S2. The packet does not prescribe the exact example invocation text, so execution must choose an example that satisfies the stated outcome without expanding scope.

## H7 — Legal Next Action
The next legal task action is to execute S2 only: append the Worked Example section and example invocation block to `guide.md`. No other path may be modified, S1 may not be redone, and completion may not be declared by the executor.

## H8 — Non-Goals / Forbidden Scope
No scope beyond the stated task is permitted. Do not alter existing content, rebuild the Command Reference table, modify paths other than `guide.md`, inspect hidden acceptance, or touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.

## S1 — Why the Next Action Is Legal
R-02 explicitly prepares S2, maps it to SC-2, authorizes `guide.md` as the sole path, and defines its outcome as adding a Worked Example section with an example invocation block. That bounded append is therefore the authorized next task action.

## S2 — Why Verified Work Must Not Be Redone
S1 has a bound verification receipt from a distinct Conductor supported by Gate and independent-review evidence. Governance expressly forbids repeating verified work, so the existing introduction and Command Reference section must remain untouched while S2 is appended.

## S3 — Why Blind Retry / Self-Completion Is Unavailable
There is no recorded S2 attempt or failure to retry. The current worktree observation does not establish S2 progress, and uncommitted changes cannot be treated as done. The executor cannot self-complete or self-verify because only a distinct Conductor may advance verified state after Gate and independent review pass.

## S4 — What Is Rejected
Rejected actions include redoing or altering S1, treating dirty worktree state as S2 completion, modifying existing text, touching any path other than `guide.md`, expanding beyond the Worked Example outcome, inspecting hidden acceptance, accessing forbidden directories, self-authoring verification, or declaring the overall goal complete.