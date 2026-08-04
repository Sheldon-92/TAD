Model: harness=codex | model=gpt-5.6-sol | route=native

# Independent Layer 2 final acceptance/test-runner report

Scope: current worktree diff from baseline `39ba1c1c0fc1a92b373331d23553794dd54da135` and handoff `HANDOFF-20260803-model-vocabulary-universalization.md` §2/§3/§5–§7. This is the final re-run after the AC9 section-ownership remediation. No product files were edited.

## Verdict

PASS — P0=0, P1=0, P2=0.

## Acceptance results

All current acceptance scripts were run from the repository root with Bash:

| AC | Result | Key verification |
|---|---|---|
| AC-01 | PASS (rc 0) | Four lite mirrors pass capability-tier section checks; Alex-Lite heading line 235, Blake-Lite heading line 233; legacy wording absent. |
| AC-02 | PASS (rc 0) | Four lite mirrors pass conjunctive Codex/other capture checks; legacy Anthropic-host wording absent. |
| AC-03 | PASS (rc 0) | Live 11-file governance set, per-term nine-line windows, stale-comment filter, AGENTS, and portable-rules checks pass. |
| AC-04 | PASS (rc 0) | Full-channel carriers and five persisted reviewer-report first-line provenance checks pass. |
| AC-05 | PASS (rc 0) | Sentinel, SAFETY blocks, reviewer-count block, archive anchor, and handoff-neighbor anchors pass. |
| AC-06 | PASS (rc 0) | Parity PASS; skill-body PASS; runtime freshness 21/21 PASS with 0 WARN and 0 BLOCK. |
| AC-07 | PASS (rc 0) | Ledger status is exactly `accepted_limitation`; notes contain `numbered-options`; `last_verified` equals baseline. |
| AC-08 | PASS (rc 0) | Exact registered plus/minus line-set manifest passes against the requested baseline. |
| AC-09 | PASS (rc 0) | Section-ownership fixture, fail-soft native/degraded fixture, redaction, Codex version, config, selected-provider, route, and per-agent probes pass. |
| AC-10 | PASS (rc 0) | Tier-calibrated judge wording, advisory markers, safety wording, and unchanged `sonnet` value pass. |

## Required final checks

### AC-01

The exact heading positions are Alex-Lite `235` and Blake-Lite `233`, mirrored identically in `.claude` and `.agents`. Each corresponding reviewer-tier section contains the required capability-tier terms once, including `按能力档位判定，不按 SKU`, `route=unknown 按 alias-mapped`, `按非强档保守处理`, and `minimal < low < medium < high`.

### AC-03

All 11 live governance files contain the platform-binding clause, and each clause’s nine-line window contains all eight required terms: `AskUserQuestion 调用`, `编号纯文本列出全部选项`, `停止等待用户输入`, `禁止代答`, `SAFETY 门控的调用点`, `非交互执行模式`, `blocked 停止并上报`, and `YOLO/预授权模式`.

### AC-04

Persisted reports checked: `acceptance-repro-reviewer.md`, `code-reviewer.md`, `safety-architecture-reviewer.md`, `security-auditor.md`, and `test-runner.md`. All five first lines match the required provenance grammar; known-reviewer count is 5.

### AC-07

Current and baseline ledger rows both have status `accepted_limitation` and `last_verified=2026-08-03`; the current notes contain `numbered-options`. Because `last_verified` is unchanged, the Completion-required branch is correctly not entered.

### AC-08 exact 40-entry manifest

The manifest contains exactly 40 entries. The scoped baseline diff contains exactly 40 paths, with 0 unregistered paths and matching forward/reverse line-set hashes. Manifest SHA-256: `9a7b8ded6d68184d8a3b0668f77a74bd4898e46996ffcd303a07ea8da57f720c`.

### AC-09 section ownership and fail-soft behavior

The new section-ownership fixture passes: nested `model_provider` keys are ignored and the exact selected provider section resolves its `base_url`. The fail-soft fixture passes for unset `OPENAI_BASE_URL`, missing `config.toml`, and missing `agents/` without a nonzero exit. The redaction fixture emits only `relay.example.invalid`.

Live Codex capture: `codex-cli 0.146.0`, `OPENAI_BASE_URL` unset, selected `model_provider=unset`, selected route `native`, top-level model `gpt-5.6-sol`, reasoning effort `medium`, and `[agents] default_subagent_model = "gpt-5.6-terra"`; per-agent probes ran for terra-worker, terra-reviewer, and luna-scout.

### Syntax, parity, freshness

All AC scripts pass `bash -n`. `release-verify.sh parity .` passes, `skill-body-verify.sh` passes, and `runtime-freshness-verify.sh .` reports 21/21 PASS, 0 WARN, 0 BLOCK.

## Finding disposition

| Priority | Count | Finding |
|---|---:|---|
| P0 | 0 | None. |
| P1 | 0 | None. |
| P2 | 0 | None. |

## Reproduction commands

```sh
for f in .tad/evidence/acceptance-tests/model-vocab-universalization/AC-*.sh; do bash "$f"; done
for f in .tad/evidence/acceptance-tests/model-vocab-universalization/AC-*.sh; do bash -n "$f"; done
bash .tad/evidence/acceptance-tests/model-vocab-universalization/AC-08-registered-line-set.sh
```

Final result: PASS.
