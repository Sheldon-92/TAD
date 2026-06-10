# Dual-Platform Regression Acceptance Summary

verdict: PASS
release_readiness: CONDITIONAL_GO
waiver: n=3 stability waiver accepted; fresh n=1 run completed on 2026-06-09 and prior n=1 evidence exists in `.tad/evidence/codex-validation/REPORT-2026-06-07.md`

## Test Matrix

| Test | Verdict | Notes |
|------|---------|-------|
| T1 Codex full-cycle regression | PASS | Full Alex -> Blake carrier flow succeeded on local `codex-cli 0.138.0`; independent rerun passed |
| T2 Claude Code compatibility | PASS | Six protocol surfaces confirmed plus two behavioral spot-checks |
| T3 Carry-forward verification | PASS | Eight items checked; two real gaps documented and classified |
| T4 Runtime freshness check | PASS | 21/21 freshness entries PASS, exit 0 |

## Gaps

| gap_classification | Area | Finding | Disposition |
|--------------------|------|---------|-------------|
| accepted_limitation | CF1 | Codex `request_user_input` is unavailable in `codex exec` batch mode (by design — no interactive user present). In interactive `codex` mode, Alex asks questions via plain text conversation normally. Only affects TAD's subagent-style `codex exec` usage, not direct interactive use. | No action needed for interactive Codex usage. For `codex exec` subagent path, text-based fallback is the documented pattern. |
| accepted_limitation | T1 carrier Gate 3 | Carrier sandbox could not complete git-backed Gate 3 bookkeeping because `.git/index.lock` creation was denied. | Accept for this regression because implementation, review artifacts, and independent rerun all passed. |
| accepted_limitation | CF6 | `model_provider` is supported only in user config, not project-local `.codex/config.toml`. | Keep provider selection out of project activation plans. |
| deferred | CF7 | No documented per-agent output-constraint field exists in custom agent TOML. | Revisit only if TAD needs schema-constrained subagent output after custom-agent activation. |
| process_blemish | T1 runtime pin | Handoff expected `0.137.0`, but the machine had `0.138.0`. | Recorded actual runtime and validated that version instead of treating the pin as silently satisfied. |

## n=3 Waiver

The handoff's Decision D1 explicitly waived a fresh `n=3` rerun. This phase therefore used:

- prior n=1 Codex validation on 2026-06-07
- one fresh n=1 full-cycle run on 2026-06-09

That combination is sufficient for this Epic because the architecture work in Phases 1-4 was design-only and the new regression confirmed the live adapter path again on a newer Codex CLI build.

## Evidence Index

- `.tad/evidence/codex-regression/T1-full-cycle-v0.137.0.md`
- `.tad/evidence/dual-platform-regression/T2-claude-code-compat.md`
- `.tad/evidence/dual-platform-regression/T3-carry-forward.md`
- `.tad/evidence/dual-platform-regression/T4-freshness-check.md`
- `.tad/evidence/codex-validation/REPORT-2026-06-07.md`
- `.tad/evidence/codex-regression/sandbox/evidence/completion-report.md`

## Recommendation

The dual-platform native runtime architecture is ready to move forward. Codex interactive mode supports normal conversational Q&A (Alex asks questions as text, user replies). The `request_user_input` tool limitation only applies to `codex exec` batch mode, which is by design (no interactive user present).
