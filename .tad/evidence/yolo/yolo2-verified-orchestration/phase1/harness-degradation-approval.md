# Harness Degradation Approval — yolo2 Phase 1 (persisted)

**Date of approval:** 2026-08-25
**Approver:** Sheldon (human, Value Guardian) — explicitly selected option 1
in direct response to Alex's two-option Gate 4 degradation decision.
**Scope:** TASK-20260824-YOLO2-P1 / HANDOFF-20260824-yolo2-phase1-recovery-slice.md,
Epic EPIC-20260824-yolo2-verified-orchestration Phase 1 dogfood only.

## Approved deviation

Fresh recovery contexts were OpenCode Task sub-agents of the executing harness
rather than independent fresh Claude Code processes (`claude -p` nested
invocation fails OAuth on this machine). Isolation therefore depends on the
frozen prompt's prohibitions, not on process-level isolation.

## Human approval

The human selected option `1`, whose complete decision text was:

> 我确认接受 Phase 1 使用 OpenCode Task 子代理代替独立 Claude Code 进程；我理解其隔离依赖 prompt，而不是进程级隔离。本批准仅限 Phase 1。

The option number and its full displayed text form one decision record; this file
does not claim that the human retyped the sentence verbatim.

## Conditions recorded with the approval

- Every fresh context received ONLY the run path + the fixed assertion
  instruction; hard prohibitions (no oracle, no session-state, no handoffs, no
  task file, no guide text, no skills/agents) were part of the frozen prompt.
- The deviation is recorded per-run in each `run-evidence.json`
  (`fresh_session` block) and in gate3-verdict.md / COMPLETION friction tables.
- This approval covers Phase 1 only. Phase 3 (multi-harness adaptation) owns
  the cross-harness capability question; later phases must not inherit it
  silently.

## Verification chain (for the record)

- Prompts used: `.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/prompts/fresh-interruption-{a,b,c}.txt`
- Per-run isolation evidence: `dogfood/{id}/run-evidence.json` →
  `fresh_session.prior_transcript_provided: false` + prompt hash binding.
