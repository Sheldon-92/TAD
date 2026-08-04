Model: harness=codex | model=gpt-5.6-sol | route=native

# Final Security Re-review — Model Vocabulary Universalization

Date: 2026-08-03
Baseline: `39ba1c1c0fc1a92b373331d23553794dd54da135`
Scope: handoff §2/§3/§5 AC5/AC7/AC8/AC9/§6/§7 only
Verdict: **PASS**

## Severity summary

| Severity | Open findings |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 0 |

The prior AC9 section-ownership finding is resolved. No release-blocking, required, or advisory security finding remains in the reviewed scope.

## Evidence

### Current worktree and registered scope

- Re-read the current tracked product diff from the exact baseline: 40 files, 415 additions, 51 deletions.
- Product-diff SHA-256: `aa1e6fd6499df6fd81a524adfd6a979b1b8872ea51cc70a7b84b206bd316e212`.
- `git diff --check` returned clean.
- AC8 independently validated the immutable baseline and every registered plus/minus line set. Manifest: 40 entries; SHA-256 `9a7b8ded6d68184d8a3b0668f77a74bd4898e46996ffcd303a07ea8da57f720c`; unregistered tracked or untracked product paths: 0.
- `.claude/skills` and `.agents/skills` are byte-identical. Skill-body checks passed; runtime freshness passed 21/21 with 0 WARN and 0 BLOCK.

### AC9 section ownership and exact route resolution

- Current AC9 passed its section-aware fixture and live reprobe under `codex-cli 0.146.0`.
- Independent nested-only fixture: `model_provider` keys under `[agents]` and `[projects.*]` were ignored; no top-level provider was selected, so absent env/config route handling remained native/fail-soft.
- Independent mixed fixture: top-level `model_provider = "chosen"` won over nested decoys.
- Exact provider-table fixture placed `[model_providers.chosen-decoy]` and another decoy before `[model_providers.chosen]`. Resolution selected only `[model_providers.chosen]` and emitted host `selected.invalid`; `wrong.invalid` and `nested.invalid` were not selected.
- This verifies exact selected `[model_providers.<id>]` ownership, not substring or first-`base_url` matching.

### Missing-input fail-soft and URL redaction

- Re-ran the literal Codex capture commands under both Bash and Zsh with `OPENAI_BASE_URL` unset and config/agents paths absent. Both shells returned exit 0 and explicitly reported native/degraded state for missing `config.toml`, `base_url`, and agents overrides.
- Synthetic environment URL with userinfo, password, query token, and fragment emitted only `env-selected.invalid`.
- Synthetic selected-provider `base_url` with userinfo, password, query token, and fragment emitted only `cfg-selected.invalid`.
- Assertions confirmed that synthetic usernames, credential markers, and query markers were absent from captured output.
- No real credential was used or persisted.

### Live Codex model and route capture

- Live config: top-level `model = "gpt-5.6-sol"`, `model_reasoning_effort = "medium"`.
- Top-level `model_provider` and `OPENAI_BASE_URL` were unset; resolved route: `native`.
- `[agents] default_subagent_model = "gpt-5.6-terra"` was captured with section ownership.
- Per-agent override capture found `terra-reviewer.toml` using `model = "gpt-5.6-terra"` and `model_reasoning_effort = "high"`, proving the documented reviewer override path is observable.

### Per-block SAFETY invariants

- AC5 passed sentinel preservation, per-block `forbidden_implementations` / `anti_rationalization` equality, `hard_requirement_distinct_reviewers`, Criterion C/D no-auto-archive, `minimum_experts: 2`, and both adjacent Gate 2 violation anchors.
- Independent baseline/current extraction was byte-equivalent after block tagging.
- A synthetic cross-block relocation of an unchanged SAFETY line was detected, confirming the check preserves block ownership rather than only a global sorted line set.

### Provenance-incomplete binding

- Blake Layer 2 requires the Model self-report as the first report line. Missing provenance is marked `provenance-incomplete`, the reason is bound into Completion, and the marker is explicitly non-blocking and cannot override the existing review verdict.
- Gate 2 handoff review binds the same missing-provenance condition and reason into the handoff Audit Trail without overriding the verdict.
- The workflow semantic port persists the Model line in `review-<expert>.md`; missing provenance is bound into the Gate 2 Audit Trail. Its review schema remains intentionally unchanged per handoff non-goal.
- AC4 passed all carrier and first-line provenance checks for persisted reviewer reports.

### Remaining acceptance checks

- AC1–AC10 all passed in one fresh run.
- AC7 preserved `ask_user_question_hook` status exactly as `accepted_limitation` and retained the numbered-options runtime binding without an unsupported `last_verified` change.
- Interaction fallback remains fail-closed at human decision points: numbered options plus STOP; no automatic default selection for SAFETY gates.

## Security coverage classification

- SAST/logic review: applicable and completed for shell/TOML parsing, route selection, output redaction, and fail-soft behavior.
- Secret handling: applicable and completed with synthetic credential-bearing URLs and output non-disclosure assertions.
- DAST, IaC scanning, and dependency-vulnerability scanning: not applicable to this documentation/workflow/shell-contract diff; there is no deployed endpoint, IaC change, or dependency change in scope.

## Final verdict

**PASS — P0=0, P1=0, P2=0.** The AC9 ownership remediation is effective, the exact selected provider route is resolved safely, missing inputs degrade without failure, credential-bearing URLs are host-only, SAFETY blocks retain ownership, and provenance-incomplete evidence is bound to the correct completion/audit carriers.
