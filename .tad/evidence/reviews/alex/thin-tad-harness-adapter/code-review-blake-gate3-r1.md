# Layer 2 — Code & Security Review R1 (Blake Gate 3, post-implementation)

**Task:** TASK-20260908-thin-tad-harness-adapter
**Reviewer:** Independent Code Reviewer & Security Lead (fresh-context subagent, in-harness; did not implement)
**Date:** 2026-09-08
**Scope:** Handoff §4.2/§4.4/§7-AC1/AC3 vs `oc-adapter.sh` + `runner.mjs` + `runner.test.mjs`
**Verdict: CONDITIONAL** (transcribed from subagent return `ses_f7dc5eb3dffeR3nms6nCB4P3ds`; full text in session record)

## Scope verified
- `oc-adapter.sh` 0755, `bash -n` clean. Blast-radius grep for `ocBin|buildOcArgv|spawnOc`: hits only `experiments/thin-tad-pilot/` + historical handoff mentions; zero consumers in `.agents/`, `.claude/`, `.tad/hooks/`.

## Correct (no finding)
- `[ $# -ge 2 ]` guards on all five valued flags (`oc-adapter.sh:37,40,43,46,49`); unknown-arg exit 2; `SUBCOMMAND="${1:-}"` set-u-safe.
- No shell injection: argv-array spawn, fully-quoted `exec` with `-f`; prompt never enters argv; positional `--` form correctly comment-only.
- Symlink refusal → `realpath -m` → prefix containment → prompt binding per spec; `TERM`/`NO_COLOR` exports; `exec` passthrough; exit-127 branch.
- AC3 default fixed (`runner.mjs:76`); both BIN vars in `ENV_ALLOW`/`envLeakCheck`; no `/home/box/pm` hardcode.

## P0-1 (blocks Gate 3): Runner never implements §4.4 `FAILED_HARNESS_USAGE`
- `classifyOutcome()` (`runner.mjs:380-389`) returns only `FAILED_INFRA`/`FAILED_MODEL`/`COMPLETED`; adapter exit 2 with no telemetry falls to `FAILED_INFRA` (`:389`), then `executeArm` retries it — consuming infra budget the handoff forbids.
- `FAILED_HARNESS_USAGE` occurs zero times in `runner.mjs` (grep-confirmed) while README documents the mapping: docs-vs-code contradiction.
- Must-fix: map exit 2 (and 127 distinctly) to non-retriable outcome + unit test.

## P1-2: `TAD_ALLOWED_WORK_ROOT` dead via runner
- Adapter honors it (`oc-adapter.sh:76`) but `sanitizeEnv` strips it and `envLeakCheck` flags it — custom root always falls back to `/tmp`. Allowlist + exempt, or amend §4.2/§4.3 to `/tmp`-only via runner.

## P2 dispositions
- P2-3: PATH-fallback result never re-`-x` checked nor logged — recommend recheck + resolved-path NOTE.
- P2-4: `WORK_DIR == ALLOWED_WORK_ROOT` permitted (spec-faithful L312) but grants `--dir /tmp` sibling visibility — require strict child or document.
- P2-5: TOCTOU on filesystem gates (non-atomic check→exec) — acceptable for single-operator model, note it.
- P2-6: trailing-slash `[ -L ]` false negative (`[ -L "/tmp/link/" ]` false) — containment backstop holds, refusal claim bypassable in form.
- P2-7: precedence inversion (§4.3 args-before-binary vs §4.2 code binary-first) — specify or reorder.
- P2-8: `export NO_COLOR=1` clobbers caller value — use `${NO_COLOR:-1}`.
- P2-9: exit-127 test fragile if system `opencode` ever installed; no runner-level exit-2 mapping test (how P0 shipped green).

## Gate readiness
AC1 behaviors + AC4 10 mocks green-path sound; AC3 implemented except P1-2. Fix P0-1 + P1-2, disposition P2s, re-run suite + new exit-2 test.
