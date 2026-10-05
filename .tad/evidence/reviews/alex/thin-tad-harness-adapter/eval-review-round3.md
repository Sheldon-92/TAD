# Gate 2 Re-Review R1-Round3 — AI Evaluation Methodology (Independent)

- Reviewer: R1-Round3 independent — Muse Spark (muse-spark-1.3-contributor), eval lens ONLY (no coordination with R2)
- Date: 2026-09-08 (UTC)
- Artifact: `.tad/active/handoffs/HANDOFF-20260908-thin-tad-harness-adapter.md` (v1.2, Status Ready-for-Gate2-rereview, 531 lines)
- Prior: `.tad/evidence/reviews/alex/thin-tad-harness-adapter/eval-review-round2.md` (R1-Round2, CONDITIONAL PASS, single open blocker F-07/AC5)
- Method: full read of v1.2 + full read of Round2 eval review; live `python3`/`grep` checks on handoff text (exact-string evidence below). No files modified except this new carrier. Judged the HANDOFF TEXT (design completeness), not implementation.
- Carrier path: `.tad/evidence/reviews/alex/thin-tad-harness-adapter/eval-review-round3.md` (new file; `eval-review.md` and `eval-review-round2.md` untouched)

## Verdict: **PASS** (unconditional, eval lens)

The single Round2 CONDITIONAL blocker (F-07 / AC5 verification-cell executable assertion) is textually closed in v1.2 with exact-string evidence. All Round2 PASS findings remain PASS on re-check (no regression). No new eval-lens findings. R1 clears the handoff on the evaluation-methodology axis; Gate 2 passage on this axis requires only the independent R2-Round3 verdict (recorded separately).

## Round2 blocker re-verification (the only CONDITIONAL item)

| Round2 ID | Requirement | v1.2 location | Closed? + evidence quote |
|---|---|---|---|
| F-07 (P1) / AC5 | Promote AC5 behavioral assertion from expectation prose to an executable verification-cell command | AC5 row L454; revision summary L73–L76; §3.2 L209; §4.3 L355–L363 | **YES.** Verification cell is now a two-stage runnable command: `` `node --check experiments/thin-tad-pilot/runner.mjs && node -e 'import("./experiments/thin-tad-pilot/runner.mjs").then(async m => { const argv = m.buildOcArgv({ workDir: "/tmp/w", extraPrompt: "/tmp/p" }); if (!argv.includes("--prompt-file") \|\| !argv.includes("--dir") \|\| !argv.includes("--temperature") \|\| !argv.includes("--seed")) process.exit(1); const { report } = await m.probeIsolation(); if (typeof report.probe_passed !== "boolean") process.exit(1); console.log("AC5 probe & buildOcArgv assertions passed"); })'` `` (L454). Revision summary L75 quotes the identical string, so summary == normative cell. Expectation cell (L454) demands Leg-1 contract shape + `probe_passed` boolean + fail-closed `ADAPTER_INELIGIBLE`, which the command mechanically asserts. A syntactically valid but contract-fictional runner can no longer pass the stated command. |

### Direction-of-assertion adjudication (why INCLUDES is correct)

Round2's suggested fix offered two alternative example shapes: "asserting `buildOcArgv` output contains no `--temperature/--seed/--prompt-file`, or probe emits `probe_passed`/`adapter_eligible`". The first alternative, read literally, contradicts the handoff's settled two-leg protocol and must NOT be applied to Leg 1:

- §3.2 L209 (unchanged, authoritative): "Leg 1 (Runner → Adapter): `buildOcArgv` 输出 `run --model <id> --dir <workDir> --prompt-file <path> --temperature 0 --seed 42`。保留超参数是为了在适配器层透明捕获并打印审计注记".
- §4.3 steps 2/8 (L355, L362–L363) mirror the same split: Leg 1 keeps `--temperature/--seed/--prompt-file` for honest capture; Leg 2 emits native-only argv.
- R2-Round2 code review (blocking-adjacent paragraph) explicitly closed this scoping: "消除假想旗标" cannot be misread as deleting Leg-1 flags.
- The "contains no" shape applies to **Leg 2** (adapter → OpenCode exec line, §4.2 L347: `exec "$OPENCODE_BIN" run --dir "$WORK_DIR" -m "$MODEL" --auto --format default -f "$PROMPT_FILE"` — no temperature/seed), never to Leg 1.

v1.2 asserts `argv.includes(...)` for all four Leg-1 flags, which is the correct direction for the `buildOcArgv` unit under test. The command additionally asserts `typeof report.probe_passed === "boolean"`, satisfying the second alternative (probe-key assertion). Both halves of the Round2 intent are therefore met; the literal first-alternative wording is superseded by the two-leg spec, not violated. Recorded here so a future reader does not "fix" the assertion backwards.

### Design-stage executability caveat (not a reopen)

The AC5 command imports `runner.mjs` and calls `buildOcArgv`/`probeIsolation` — symbols that do not exist until Blake implements. That is correct for a Gate 2 design gate: the AC verification cell must NAME an executable command (Round2's demand), and its pass/fail is adjudicated at Gate 3 by execution, not at Gate 2 by speculation. AC4's `node --test runner.test.mjs` has the identical pre/post-impl shape and was already accepted on that basis. NoExecutability defect at design stage.

## Regression re-check (Round2 PASS findings, v1.2 text)

| ID | v1.2 spot-check | Still PASS? |
|---|---|---|
| F-01 (P0 currency) | AC7 command cell L456 still `` `! grep -riE '\b(usd\|dollars?\|cents)\b' .tad/evidence/experiments/thin-tad-pilot/harness-contract-audit.md` `` — word-boundary, scoped to audit md, shell exemption in-row ("豁免 `oc-adapter.sh`…`$VAR`…`$(...)`"). §1.3 L155 and refs L178 repeat exemption. | YES |
| F-02 (P0 mktemp) | PREREQ-1 L414–L416: offline `test -x … && … --version` (≥1.18.0) + AUTH-gated live step `P=$(mktemp /tmp/prereq-prompt.XXXXXX); echo ping >"$P"; … run … --prompt-file "$P"; rc=$?; rm -f "$P"; test $rc -eq 0`. Only remaining `<(` in file is L89 historical note. | YES |
| F-03 (dual-var) | §3.2 L198–L210, §4.1 L220, AC3 L452: `TAD_OPENCODE_BIN` = Runner→adapter, `TAD_OPENCODE_RAW_BIN` = adapter→binary, both in `ENV_ALLOW`/`envLeakCheck`, exact `ocBin()` default-mandate string retained. | YES |
| F-04 (AUTH+version) | PREREQ-AUTH L406–L408 + PREREQ-1 L411/L415: AUTH hard precondition, offline version split, budget-counted live ping. | YES |
| F-05 (PREREQ-4/5/6 commands) | PREREQ-4 L433 (`verifyArmsFidelity()`), PREREQ-5 L437 (26/2/3 constants grep + node assert), PREREQ-6 L441 (H/V 6/6 assert). Symbol-presence weakness noted in Round2 persists by design; Gate 3 must execute. | YES |
| F-06 (AC4 threshold) | AC4 L453 now demands ≥33 + 10 named mocks (was ≥30 + 7) — strictly stronger than Round2's closure condition. New cases 8/9/10 are the F07 containment trio (deferred to R2 for depth; no eval objection). | YES |
| F-08 (AC6/AC8) | AC6 L455 content demands retained; AC8 L457 baseline `git status --porcelain=v1 --untracked-files=all \| sort` + `comm -13` retained. | YES |

## PREREQ / AC sweep (eval lens, v1.2 deltas only)

- PREREQ-AUTH through PREREQ-6: no normative weakening vs v1.1; all verification cells still contain runnable commands. PASS.
- AC0–AC3, AC6–AC8: unchanged in normative intent; AC1 L450 and AC4 L453 now additionally name the F07 containment trio (symlink/prefix/binding exit-2 matrix). Eval lens defers containment-implementation depth to R2; the AC text is testably phrased (exit-2 conditions enumerated). PASS.
- AC5: CONDITIONAL → PASS per table above. No other AC changes state.

## Honesty & anti-forgery (eval lens): PASS

No new forgery surface in v1.2: Leg-2 exec still carries native flags only; TEMP/SEED absorb-and-NOTE retained (§4.2 L331–L334); pm-path prohibition retained (AC3 L452, §3.2 L201); no live 24-run authorized (§1.3, §6 preamble, PREREQ-AUTH). Residual non-blocking items carried from Round2 unchanged: L436 "严禁 USD 换算" prohibition prose (not a conversion; AC7 gate scope unaffected), L41 `--pure` background quote (decision still unrecorded — code-lens residual, not eval-blocking), L527 dispatch currency-boundary restatement (consistent with §1.3).

## Knowledge Assessment

No new pattern. v1.2 is a clean instance of the P3-derived rule "every AC verification cell must contain an executable command" — the AC5 fix is the exemplar. Recommend (non-blocking) that the eventual pattern note for that rule cite this AC5 v1.1→v1.2 delta as the canonical before/after.

## Provenance

- Independent reviewer R1-Round3, fresh read of v1.2 (531 lines) + Round2 eval review (64 lines); no coordination with R2-Round3.
- Live evidence: `python3` exact-string checks on 2026-09-08 — `buildOcArgv`/`probe_passed`/`node -e 'import` present; AC5/AC4/AC1 rows printed verbatim; currency word-boundary hits enumerated (L83/L88/L155/L178/L436/L456/L527, all prohibition/boundary prose or the scoped AC7 gate, none a conversion); `<(` hits = L89 historical note only; `--pure` hits = L41 background quote only.
- No live system re-verification (binary/help/test-suite facts carried from Round1, undisputed by v1.2).
- Existing files NOT modified. This carrier is NEW: `.tad/evidence/reviews/alex/thin-tad-harness-adapter/eval-review-round3.md`.
