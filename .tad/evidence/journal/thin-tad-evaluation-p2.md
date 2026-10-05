# Journal — thin-tad-evaluation-p2 (Blake raw capture, 2026-09-08)

> Doer raw journal. Distillation into project-knowledge is Alex's stranger role, not mine.

## What happened
- Implemented `experiments/thin-tad-pilot/runner.mjs` (~700 lines, stdlib only) + `runner.test.mjs` (23 tests) + README P2 section per handoff §6 Phase 2.1-2.4.
- Layer 1: `node --check` OK, 23/23 tests pass, live `probe` fail-closed exit 1 (`adapter-ineligible: binary missing: oc-run`), runs/ currency grep clean.
- Layer 2: two independent reviewers both CONDITIONAL with the SAME 2 P1s (10s backoff unwired; sibling probe leg dead code). Fixed both, re-verified 23/23, appended fix-round notes to both review files → both PASS.
- Did NOT fabricate `manifest.json` / `pair-summary.json` / `run.json` without the harness. Gate 3 recorded as CONDITIONAL-PASS-TOOL-ONLY; live matrix BLOCKED on missing `oc-run`.

## Surprises / friction
- `oc-run` absent in this terminal: the honest path is BLOCKED + fail-closed probe, not mock manifest. The handoff friction table explicitly pre-authorized this outcome.
- `assert.throws(regex)` does not match `RunnerError.code` (only message): 3 tests initially failed on assertion style, not logic. Fixed by asserting `e.code`.
- Pre-existing workspace dirt: 136 files under `.agents/` etc. show mode-only 755→644 diffs predating this task; AC8 live recompute needs a clean baseline or it will false-FAIL future work.
- Both reviewers independently converged on the identical 2 P1s — narrow-scope prompts with file:line grounding worked; no duplicate/divergent findings to reconcile.

## Open for the stranger (distillation questions)
- Is "BLOCKED-without-fabrication" worth a typed pattern (fail-closed-evidence > green-gate), or is it covered by existing honesty entries?
- The `assert.throws` vs error-code gotcha: generic JS testing knowledge, probably not TAD-specific — leave as journal only?
- Mode-only git dirt as AC8 false-FAIL source: belongs in shell-portability or handoff-design, or one-off?

## Round 2 (Blake, 2026-09-08 ~15:00 — Human said "可以开", re-executed Gate 3)

- Layer 1 re-run: `node --check` OK both files; `node --test` 23/23 (pre-fix); live `probe` still fail-closed exit 1 (`adapter-ineligible: binary missing: oc-run`, Tier 1 + 13/13 fidelity true); currency grep clean; production paths content-diff 0 (136 files mode-only, pre-existing).
- Verified raw `opencode` binary (`/home/box/.opencode/bin/opencode`) CANNOT substitute for `oc-run`: its `run` subcommand has no `--temperature/--seed/--prompt-file` flags the runner's argv contract requires, and handoff §8.4 allows no substitute. Checked `opencode models`: authorized `opencode-go/muse-spark-1.3-contributor` exists — model is available, harness wrapper is not.
- Layer 2 round 2 (2 fresh independent reviewers, OpenCode sessions): spec PASS with 2 NEW P1s (cross-arm fuse unreachable — terminal FAILED_INFRA reset the streak; classifyOutcome mapped nonzero-with-structured-output to retriable infra), code PASS (0 P0/0 P1/4 OBS). Fixed both: `Budget.noteTerminalInfra()` + terminal path calls it; `classifyOutcome` returns non-retriable `FAILED_MODEL` for structured-output nonzero exits (run.json records it, P1 scorer judges it downstream, scored+unscorable=24 invariant intact). Added 2 regression tests → 25/25. Independent delta verifier: FINAL PASS (25/0).
- Live 24-run matrix still BLOCKED (no `oc-run`); manifest/pair-summary/run.json still not fabricated. Verdict unchanged: CONDITIONAL-PASS-TOOL-ONLY.

## Closure (Blake, 2026-09-08 — Human/PM decision 你定吧: close P2 as tools-leg ACCEPT)

- **Decision carried out**: P2 closed as tools-leg ACCEPT; live 24-run matrix formally
  `ADAPTER_INELIGIBLE` (subject `oc-run` binary absent in this terminal).
- **Closure re-verification (fresh, this session)**: `which oc-run` exit 1;
  `TAD_OPENCODE_BIN` unset; `runs/` holds only `isolation-probe-report.json`
  (`probe_passed: false, adapter_eligible: false, violation: "adapter-ineligible:
  subject binary missing: oc-run"`); `manifest.json` / `pair-summary.json` / `run.json`
  all absent — nothing fabricated. `node --check runner.mjs` OK; `node --test
  runner.test.mjs` 25/25 pass.
- **Explicit non-substitution**: `/home/box/pm/bin/oc-run.sh` exists on disk but was
  deliberately NOT pointed at via `TAD_OPENCODE_BIN` per Human instruction
  (handoff §8.4: no substitutes; never commandeer a cross-directory harness).
  The closure rests on the fail-closed probe fact, not on any call to that path.
- **Not claimed**: no Gate 4 live PASS; AC0-pass/AC2/AC3/AC5/AC7-live remain unpassed
  (missing harness, not a tool defect).
- **Files updated**: `.tad/active/handoffs/COMPLETION-20260908-thin-tad-evaluation-p2.md`
  (§0.5 closure record, §4 ACCEPT-TOOLS-LEG, §7 struck-through resume path);
  `.tad/active/epics/EPIC-20260907-thin-tad-evaluation.md` (Phase 2 Closed, P3 input noted absent).
