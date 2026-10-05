# Layer 2 — AI Evaluation Review R1 (Blake Gate 3, post-implementation)

**Task:** TASK-20260908-thin-tad-harness-adapter
**Reviewer:** Independent AI Evaluation Specialist (fresh-context subagent, in-harness; did not implement)
**Date:** 2026-09-08
**Scope:** Handoff §1.3/§3.2/§6/§7 vs implementation diff + `runner.test.mjs` + `harness-contract-audit.md`
**Verdict: FAIL** (transcribed from subagent return `ses_f7dc5eb5cffe9oz3iLKBnSJj8P`; full text in session record)

## P0-1: `executeArm` never supplies `--prompt-file` — every real arm would exit 2
- `buildOcArgv` appends `--prompt-file` only when `extraPrompt` is passed (`runner.mjs:266`), but the sole live caller `executeArm` called `buildOcArgv({ workDir })` with no `extraPrompt` (`runner.mjs:587`).
- Runtime-verified: `buildOcArgv({workDir:"/tmp/w"})` → no `--prompt-file`; adapter mandates it (exit 2, empirically `rc=2`).
- Masked by tests: all 10 adapter tests hand-build argv; AC5 test passes `extraPrompt` explicitly. 24-run matrix would fail deterministically on harness-usage with zero model signal while suite stays green.

## P0-2: PREREQ-2 unsatisfiable via its documented command; Tier-2 live has zero non-mock coverage
- `defaultHarnessReader().readPath` unconditionally throws `delegated-to-run-pair-sandbox` (`runner.mjs:571`); live `probe` → `probe_passed: false`, `positive_ok: false` (verified live, `probe-rc=1`).
- Handoff §6 PREREQ-2 presents that exact command as the gate — it can never pass as written. All Tier-2 PASS evidence from injected doubles.

## P1-3: README claims `Locks: temperature 0, seed 42`
- Header verb asserts determinism the audit denies (`harness-contract-audit.md:43-46`). Skim readers may cite "locked temp 0" downstream.

## P2-4: AC8 snapshot-diff fence unverifiable as implemented
- `runner.mjs`/`runner.test.mjs` are untracked (`??`), working tree has unrelated dirt; no pre-implementation baseline captured per AC8 §460-461 at review time.

## Explicit non-findings (bounded)
- Temp/seed non-forwarding genuine and discriminating (exec line native-only; 2 tests assert downstream absence).
- Audit holds all 6 PREREQ with runnable commands; PREREQ-3 disclosure holds; AC7 clean; AC3 holds (no `oc-run.sh`, in-repo default, both BIN vars allowlisted).
- Probe fail-closed exit code correct on the real path.

## Remediation demanded
(a) wire prompt-file creation into `executeArm` (+ integration test through real adapter); (b) real canary leg or PREREQ-2 rewrite; (c) README wording; (d) AC8 before/after diff scoped to allowlist.
