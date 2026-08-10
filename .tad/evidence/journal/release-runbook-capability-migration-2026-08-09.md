# Release-runbook capability migration — implementation journal

## Sealed-window evidence is a generator/replay split

Forward behavior sessions must be generated between a complete managed-surface pre-capture and post-capture. The AC verifier should replay the persisted outputs, rubric, and sealed pre/post equality; regenerating sessions during every replay would mutate evidence after the post-capture and invalidate the window.

## Concurrent target activity must remain visible

Strict zero-side-effect evidence can detect unrelated concurrent changes in registered targets. Four windows correctly failed while a Sober Creator LITE handoff was edited and archived. The safe response was to preserve the failure, coordinate the external writer, and create a wholly fresh window. Filtering that zero-touch file or attributing the change without evidence would have weakened AC6.

## Approval consumption needs an atomic claim primitive

“Consume before launch” prose is insufficient under concurrent consumers. The runbook now makes one durable `mkdir` claim authoritative: exactly one contender succeeds, a failed claim is DENY, and a crash after the claim remains consumed/ambiguous. A two-consumer fixture proves one winner and replay denial.

## Failure injection must inspect downstream invariants

Migration exit-code tests became meaningful only after using disposable two-target fixtures that injected partial writes and verified backup presence, later-target immutability, and unchanged registry/success/commit/push state.

## Evidence-harness lesson

Capture what the acceptance text promises: source worktree status, stdout/stderr/exit for every derivation interface, and the dynamically parsed sole TOP_DENY. Comparing two incomplete manifests can otherwise produce a false PASS.
