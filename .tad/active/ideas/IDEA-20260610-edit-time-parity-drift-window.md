# Idea: Close the Edit-Time Parity Drift Window (Blake Completion Check)

**ID:** IDEA-20260610-edit-time-parity-drift-window
**Date:** 2026-06-10
**Status:** captured
**Scope:** small

---

## Summary & Problem

The step3b parity gate (landed 2026-06-10, Gate 4 PASS) guarantees the PUBLISHED artifact has
.claude/skills ↔ .agents/skills byte-parity. But both historical drifts (f428d70, f84c8f b) were
introduced at EDIT time — and `.agents/skills` is read in-repo by Codex continuously, not only at
publish. The window between "Blake edits a skill" and "next *publish" remains open: Codex runs
stale protocols during it.

Fix candidate: add a parity check to Blake's completion protocol (after any handoff that touches
`.claude/skills/`): run `release-verify.sh parity "$PWD"`; on drift run `parity --fix` (direction
guard already mechanical) and include the sync in the completion commit.

## Open Questions

- Trigger condition: any §6 file under `.claude/skills/`, or every completion (cheap, ~1s)?
- Should the hook-modified-files path (post-write-sync) also trigger it, since hooks edit
  alex/SKILL.md outside handoffs (see chore commits a5a8581, 2fe627b)?

## Notes

- Recorded as the KNOWN RESIDUAL GAP at Gate 4 of codex-parity-step3b (handoff §2 row 3 deferral).
- The `parity [--fix]` tool is already hardened (DIRECTION STOP-default + parse-failure STOP,
  e82704f); this idea is wiring-only.

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: (filled by *idea promote)
