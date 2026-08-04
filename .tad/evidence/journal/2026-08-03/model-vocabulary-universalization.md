# Blake execution journal — model vocabulary universalization

## Scope and baseline

- Handoff: `HANDOFF-20260803-model-vocabulary-universalization.md` v3.
- Pre-edit baseline commit: `39ba1c1c0fc1a92b373331d23553794dd54da135`.
- Live §C derivation matched the pre-registered 11-file set before edits.
- Four lite ESCALATION-LIST sentinels were recorded in `baseline.md` and AC5
  preserved the expected MD5 `4c55bcb6563f24dc78449fb19ff76067`.

## Layer 1 observations

- AC1, AC2, AC4, AC5, AC6, AC7, AC8, AC9, and AC10 passed on first substantive run.
- AC3 first failed because the portable-rules pointer was inside the existing quoted
  replacement text, so the exact handoff probe `条款） |` could not match. The pointer
  was moved after the quote and before the table-closing pipe; AC3 then passed.
- AC8 first exposed missing registration cases in the acceptance script itself: parity
  mirror paths, multi-line clause tails, and blank diff lines. The script was tightened
  with explicit mirror mapping, term patterns, and post-sign blank-line skipping; AC8
  passed without broad full-file matching.
- AC9 real local repro: codex-cli `0.146.0`, top-level model `gpt-5.6-sol`, reasoning
  `medium`, per-agent files include terra-reviewer at `high`; `OPENAI_BASE_URL` and
  config `base_url` probes were empty, so the documented native/section-lookup path is
  retained.

## Layer 2 reflexion

- Code reviewer initially found a P1: the Alex interaction clause had been inserted
  inside YAML front matter. This was a real parser regression, not an AC false positive.
- Fix: moved the clause after the closing front-matter delimiter in `.claude`, then ran
  `release-verify.sh parity --fix .` to update `.agents`.
- Fix verification: Ruby YAML `safe_load` guard added to AC6 for both trees' four role
  SKILLs; code reviewer re-reviewed and returned PASS.

## Evidence discipline

- No `.agents` source edits were made; parity was the mirror mechanism.
- No hook files, workflow schemas, sentinel blocks, or SAFETY neighbor blocks were
  rewritten. The parity `--fix` raw output and codex key repro are stored beside the ACs.

## Final validator reflexion

- A fresh security review found two P1 contract gaps and two P2 evidence weaknesses:
  missing-provenance handling was not durably bound, literal Codex capture commands
  were not independently fail-soft, AC9 erased TOML section ownership, and AC5b used
  a file-global SAFETY bag.
- Root cause: the first implementation validated the happy-path wrapper and aggregate
  invariants, while the handoff required the published command text and each named
  block to be independently discriminating.
- Remediation: added provenance-incomplete consequences to the full reviewer carriers
  and workflow, guarded every Codex capture branch against absent inputs and unmatched
  agent globs, annotated AC9 model keys/base URLs with TOML sections and selected
  provider, and prefixed AC5 blocks with ordinal ownership before comparison.
- AC1–AC10 were re-run after remediation and passed. Three independent reviewers were
  sent for a final re-review against the post-remediation worktree; their final verdicts
  are recorded in the reviewer carriers before Gate 3.
