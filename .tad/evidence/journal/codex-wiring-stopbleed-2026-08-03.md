# Knowledge Assessment — codex-wiring-stopbleed

Date: 2026-08-03

## Q1 — Discoveries and decisions

- Codex CLI 0.146.0 reports the legacy top-level event-array schema during a
  real trusted session; `codex doctor` is not a substitute for session-level
  hook parsing evidence.
- Hook trust/state must be isolated in a scratch `CODEX_HOME`; the candidate
  `{description, hooks}` shape parses cleanly and preserves all four existing
  hook semantics.
- Both Claude Code and Codex direct-read a `references/<file>.md` declaration
  relative to the active skill directory. A separate parity guard is still
  required because byte-identical bad mirrors otherwise make a verifier early
  exit look healthy.
- A fail-closed declaration matcher must be quote-agnostic. The final AC6
  probe covers double-quoted, single-quoted, and bare YAML values while the
  single-tree probe continues to exercise the legacy byte-parity path.
- AC7 is safer as a two-branch delta: branch alpha validates the shipped ledger;
  branch beta proves that an unresolved safety row remains a registered,
  human-visible `honest_partial` rather than being dated or status-edited green.

## Q2 — Reusable work pattern

Yes. The reusable pattern is: isolate runtime state, run the smallest real
session probe, capture a pre-edit structural baseline, mutate the safety
invariant in both mirrors, and run independent reviewers against the same
evidence. This is multi-step and verified by this handoff.

## Q3 — Workflow pattern

Yes. The implementation used a bounded multi-reviewer loop: spec compliance,
code safety, and test execution ran independently; a reviewer-found P1 caused a
targeted fix and a fresh review round. No new project workflow defect was
introduced; the useful pattern is the explicit fix-and-re-review loop.
