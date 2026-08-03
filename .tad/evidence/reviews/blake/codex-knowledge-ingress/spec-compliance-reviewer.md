# Independent Layer 2 SPEC compliance review

Date: 2026-08-03
Scope: `HANDOFF-20260803-codex-knowledge-ingress.md`, current worktree diff, baseline, and AC-00..AC-10b.

Verdict: **PASS** (with the explicitly recorded no-delivery limitations below).

## 执行证据

- Read the active handoff and `.tad/evidence/acceptance-tests/codex-knowledge-ingress/baseline.md`. Baseline is pinned to commit `e73a3c88bd4152e53204fb2991623aae34903b84`; `git cat-file -e` succeeds. Baseline commit date and review date are both 2026-08-03.
- Ran the AC suite: `AC-00-spikes.sh`, `AC-01-knowledge-ingress.sh`, `AC-02-spike-envelope.sh`, `AC-03-envelope-fixtures.sh`, `AC-04-claude-zeroregression.sh`, `AC-04b-manual-gates.sh`, `AC-05-spike-d-ledger.sh`, `AC-06-detect-platform.sh`, `AC-07-skill-line-set.sh`, `AC-08-brain-index-fallback.sh`, `AC-09-regression.sh`, `AC-10a-startup-compact.sh`, and `AC-10b-notebook-fail-open.sh`: all exited 0 and reported PASS. AC-09 observed runtime freshness `21 PASS / 0 WARN / 0 BLOCK` and parity PASS.
- C/D/E evidence is honest: Spike C and D record Codex authentication HTTP 401/no hook delivery; D explicitly leaves PreCompact fire unmeasured, adds no wiring, and records `context_compaction` as `verified_partial`. Spike E records an empty measured harness-signal set and does not promote candidate variables or fixtures to runtime evidence.
- AC4 has exactly three registered `sed -e` normalizations: `ts`, `Hook Last Touched`, and snapshot filename. It separately enforces same-day completion, frozen same-basename fixtures, and second-run trace delta `0` on both baseline and after trees. No additional filter was found.
- AC4b proves missing Completion gives exit 2 with human-readable BLOCK text; valid Completion gives exit 0; bare and invalid gate/accept calls give nonzero exit with `Usage:` output. This closes the prior `{}`/exit-0 false-green path.
- Two-tree checks pass: `old Source: .claude` headers = 0, platform-tree Source headers = 38, and `release-verify.sh parity .` passes. Targeted role-skill diff contains only the registered platform-path/reference changes; Alex/Blake separation remains explicit and unchanged in the governing rules.
- No verifier/date cheating found: the baseline is an immutable Git commit, AC4 aborts on a date boundary, the runtime freshness verifier itself is unchanged, and `ask_user_question_hook` remains `accepted_limitation` rather than `verified`.

Limit: authenticated Codex hook payloads and an actual PreCompact fire were not observed because the bounded probes hit HTTP 401; the artifacts correctly preserve that as an honest partial/no-delivery result, so it is not a SPEC failure.
