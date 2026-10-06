# Phase 2 scripted full-chain session — fixed task text (verbatim, all three runtimes)

Run in the skeleton repo root, one non-interactive command per runtime
(codex exec / opencode run / agent -p), stdin closed. The text between the
markers is the exact prompt given to every runtime.

---TASK-TEXT-BEGIN---
You are in a TAD-managed repository. Do these four steps in order:
(a) Activation: read the file AGENTS.md in the current directory, then print one line that begins with "ACTIVATION:" followed by the TAD version string you found in it and the role surface you are running as.
(b) Bounded write task: create a file named p2-write-target.txt containing the single line "alpha"; then edit that file to change "alpha" to "beta"; then create a file at .tad/evidence/p2-writenote.md containing one line that describes this change.
(c) Gate evidence: write a file named p2-review-record.md that reviews the diff produced by step (b): state what changed, whether it matches the instruction, and end with a line "VERDICT: PASS" or "VERDICT: FAIL".
(d) Closeout skeleton: write a file named p2-closeout.md with three sections titled "Done", "Evidence", and "Open items", each filled in briefly based on what you actually did.
When all four steps are complete, print the single word FINISHED.
---TASK-TEXT-END---

Per-runtime trigger checkpoints (verified from disk after each run, never from
the model's own claims): session/trace side effects in .tad/evidence/traces/,
session-state metadata in .tad/active/session-state.md, adapter/hook logs
where the runtime emits them, and the four produced files.
