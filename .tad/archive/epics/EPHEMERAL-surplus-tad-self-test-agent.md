# EPHEMERAL Epic: tad-self-test-agent

> Ephemeral surplus Epic — single phase, auto-executed, archive on completion.
> Source: next (IDEA-20260401). Surplus task ID: tad-self-test-agent.

## Goal

Validate that TAD agents actually follow the protocol (Socratic questioning, expert
review, gate compliance) via automated behavioral tests instead of manual spot-checks.
The trajectory eval harness proves gates catch real P0s; a self-test agent catches
protocol DRIFT before it ships — high leverage for framework quality.

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | self-test-workflow | Active |

## Phase 1 Scope

- Build `.claude/workflows/tad-self-test.workflow.js`: runs a synthetic TAD task
  end-to-end (design → handoff → implement → accept) against a fixture.
- Verify from the produced artifacts/trace that: Gate 1-4 were each invoked,
  Layer 2 expert review ran (min 2 experts), and a completion report was filed.
- Emit PASS/FAIL output plus a diff of the observed protocol trace against an
  expected-trace fixture (missing steps = FAIL with named step).

## Out of Scope

- Changing any gate protocol, SKILL file, or hook code.
- Judging output QUALITY of the synthetic task — only protocol-step compliance.
- Multi-model (Codex) runs; Claude Workflow only.

## Handoff

`.tad/active/handoffs/HANDOFF-surplus-tad-self-test-agent.md`
