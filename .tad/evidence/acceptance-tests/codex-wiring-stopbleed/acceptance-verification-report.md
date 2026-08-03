# Acceptance Verification Report

Task: `codex-wiring-stopbleed`
Date: 2026-08-03
Handoff: `HANDOFF-20260803-codex-wiring-stopbleed.md`
Runtime: `codex-cli 0.146.0`, `Claude Code 2.1.220`
Total: 10 criteria, 10 PASS, 0 FAIL

| # | Acceptance Criterion | Verification | Result | Evidence |
|---|---|---|---|---|
| AC0 | Spike B direct relative-reference read on both platforms | `AC-00-spike-b-reference.sh` | PASS | `spike-b-report.md`: exact Claude `Read` and Codex `exec_command` paths, no search fallback |
| AC1 | Spike A old-schema real-session transcript / accepted candidate evidence | `AC-01-spike-a-schema.sh` | PASS | `spike-a-report.md`: real `unknown field` transcript; isolated trusted scratch and initial git commit |
| AC2 | New schema parses cleanly and repository/scratch files cmp | `AC-02-hooks-schema.sh` | PASS | Trusted scratch revalidation returned `SPIKE_SCHEMA_REVALIDATED`, no hooks parse warning |
| AC3 | `tad.sh` heredoc exactly matches hooks file | `AC-03-heredoc-cmp.sh` | PASS | Extracted lines 920–949 with `cmp` |
| AC4 | Platform-coupled declarations zero; path-like references resolve in both trees | `AC-04-reference-resolution.sh` | PASS | Both trees: coupled=0, missing=0; non-path embedded protocol label explicitly ignored |
| AC5 | SKILL line-set safety boundary and sentinels | `AC-05-skill-line-set.sh` plus prior sentinel script | PASS | Added=76, removed=72: 72 reference replacements + 4 exact notes; sentinel preservation PASS |
| AC6 | Fail-closed parity mutation probe | `AC-06-parity-injection.sh` | PASS | Dual-tree double/single/bare declarations trigger specialized FAIL; single-tree triggers byte-parity FAIL; trap restores |
| AC7 | Runtime ledger two-branch delta | `AC-07-ledger-delta.sh` | PASS | Alpha 21/21 PASS; isolated beta one registered BLOCK, exit 1, count < baseline 5, product ledger unchanged |
| AC8 | Skill-body and shell regression | `AC-08-regression.sh` | PASS | `skill-body-verify.sh` and `bash -n` pass |
| AC9 | Codex-only downstream installation shape | `AC-09-codex-only.sh` | PASS | `.agents/skills` present, `.claude/skills` absent, missing=0 |

## AC7 branch-β classification

The beta result is an isolated fixture only: `ask_user_question_hook` was changed
to `unknown_current_behavior` in a temporary copied ledger. Its one BLOCK is in
the pre-registered list at `ac7-branch-escalation.md` and is classified as
`honest_partial` pending human disposition; no shipped ledger or verifier was
changed. The shipped ledger follows branch α with exit 0.

## Layer 2 review evidence

- `../../reviews/blake/codex-wiring-stopbleed/spec-compliance-reviewer.md` — PASS
- `../../reviews/blake/codex-wiring-stopbleed/code-reviewer.md` — final PASS, P0/P1/P2 = 0/0/0
- `../../reviews/blake/codex-wiring-stopbleed/test-runner.md` — final PASS
