# Gate 2 Re-Review R1-Round2 — AI Evaluation Methodology (Independent)

- Reviewer: R1-Round2 independent — Muse Spark (muse-spark-1.3-contributor), eval lens ONLY (no coordination with R2)
- Date: 2026-09-08 (UTC)
- Artifact: `.tad/active/handoffs/HANDOFF-20260908-thin-tad-harness-adapter.md` (v1.1, Status Ready-for-Gate2-rereview)
- Prior: `.tad/evidence/reviews/alex/thin-tad-harness-adapter/eval-review.md` (R1 Round1, CONDITIONAL PASS, F-01 P0, F-02 P0, F-03–F-07 P1, F-08 P2)
- Method: full read of v1.1 (477 lines) + full read of Round1 review; live `grep`/`sed` checks on handoff text (evidence quotes below). No files modified.

## Verdict: **CONDITIONAL PASS**

Both P0s (F-01, F-02) are textually closed with exact-string evidence. Six of seven remaining findings are closed. One P1 (F-07) is only prose-closed: AC5's verification column is still syntax-only (`node --check`), with behavioral assertions confined to the expectation prose and no runnable command. v1.1 must promote the AC5 behavioral assertion to an executable command (one-line fix, suggested below) before Gate 2 PASS. Blake must not start implementation until that AC5 command lands and is re-confirmed (by R1 spot-check or Gate 2 chair).

## Per-finding re-verification table

| ID | Round1 sev | v1.1 location | Closed? + evidence quote |
|---|---|---|---|
| F-01 | P0 | AC7 row L414; §1.3 L139; knowledge refs L162; revision summary L73 | **YES.** AC7 command is now `` `! grep -riE '\b(usd\|dollars?\|cents)\b' .tad/evidence/experiments/thin-tad-pilot/harness-contract-audit.md` `` — word-boundary, no `\$` alternative (grep for `\\$` in v1.1 returns zero normative hits), scoped to audit md only. Exemption is explicit in-row: "豁免 `oc-adapter.sh` 脚本内合法的 shell 变量 `$VAR` 与 `$(...)` 语法" (L414), repeated §1.3 L139 ("shell 脚本中正常的 `$VAR`、`$(...)` 语法完全豁免") and L162. The §4.2 draft's `$OPENCODE_BIN`/`$(...)` lines can no longer fail the gate. Residual (non-blocking): dispatch L473 still writes loose prose "禁止引入任何法币符号（USD, $, cents 等）" — not a verification command, so not a satisfiability defect, but recommend aligning its wording with L139 at next edit. |
| F-02 | P0 | PREREQ-1 L368–374; summary L74 | **YES.** Normative step-2 command is now "`P=$(mktemp /tmp/prereq-prompt.XXXXXX); echo ping >\"$P\"; experiments/thin-tad-pilot/oc-adapter.sh run --model opencode-go/muse-spark-1.3-contributor --dir /tmp --prompt-file \"$P\"; rc=$?; rm -f \"$P\"; test $rc -eq 0`" (L374) — real temp file, no process substitution. The only remaining `<(` occurrence in v1.1 is L74's historical description of the removed pattern, not a command. `-f` check (§4.2 L284) is now satisfiable. |
| F-03 | P1 | §3.2 L182–194; §4.1 table L204; §4.2 L221–222; §4.3 L312; AC3 L410; §1.1 L110/L116 | **YES (as superseded design).** Round1 R1 recommended single-var unify; v1.1 adopted the dual-var split per R2 F04. Eval-lens check is narrative consistency, not allowlist depth (deferred to R2): v1.1 is internally coherent everywhere — `TAD_OPENCODE_BIN` = Runner→adapter (L182–185, L204, L410), `TAD_OPENCODE_RAW_BIN` = adapter→binary with `/home/box/.opencode/bin/opencode` fallback (L186–188, L221–222), both in `ENV_ALLOW`/`envLeakCheck` (L190–191, L410). No remaining single-vs-dual contradiction in PREREQ-1/AC3 narrative. |
| F-04 | P1 | PREREQ-1 L370–373; PREREQ-AUTH L364–366 | **YES.** (a) AUTH linkage: L371 "仅在满足 `PREREQ-AUTH` 授权后执行…计入单次调用监控（包含在 24+2 预算管控内）". (b) Offline version step split out: L373 "`test -x experiments/thin-tad-pilot/oc-adapter.sh && test -x /home/box/.opencode/bin/opencode && /home/box/.opencode/bin/opencode --version`（断言输出版本 >= 1.18.0）". Live ping no longer normalizes an un-authorized call. |
| F-05 | P1 | PREREQ-4 L391; PREREQ-5 L395; PREREQ-6 L399; summary L83 | **YES (with noted weakness).** Each now has a concrete runnable command: PREREQ-4 `verifyArmsFidelity()` node one-liner (L391); PREREQ-5 constant-grep + node assert on `MAX_INVOCATIONS!==26\|\|MAX_TOTAL_INFRA_RETRIES!==2\|\|CONSECUTIVE_INFRA_ABORT!==3` (L395); PREREQ-6 `H_CASES/V_CASES length!==6` assert (L399). Limitation (not reopening): all three assert code-symbol presence/shape rather than independently recomputing hashes or budget state — sufficient to kill paper-admission, weaker than Round1's suggested hash-compare. Gate 3 reviewers should execute, not eyeball, these commands. |
| F-06 | P1 | AC4 L411; summary L84; §1.1 L120 | **YES.** Threshold raised to "测试数 >= 30，在基线 25 个通过基础上新增 >= 5 个" with 7 mandatory named Mock tests enumerated verbatim (L411): `adapter translates prompt-file to -f flag` / `…missing required args` / `…missing value for flag` / `…unknown flags` / `…absorbs temperature and seed with NOTE to stderr` / `…propagates nonzero opencode exit code and exit 127 accurately` / `…flag-injection immunity with leading dash prompt content`. Discriminative power restored (count + names). |
| F-07 | P1 | AC5 L412; summary L85 | **PARTIAL — prose closed, command open.** Expectation column now demands behavioral content ("探针能正确驱动适配器接口…诚实报 `ADAPTER_INELIGIBLE`…静态检查确认 `buildOcArgv` 契约…完全吻合"), which is stronger than v1.0's syntax-only title. BUT the verification column is unchanged: still only `node --check experiments/thin-tad-pilot/runner.mjs`. No executable behavioral command (e.g. asserting `buildOcArgv` output contains no `--temperature/--seed/--prompt-file`, or probe emits `probe_passed`/`adapter_eligible`) is given. A syntactically valid but contract-fictional runner still passes the stated command. **Required fix (one line):** append a runnable assertion to AC5's verification cell, e.g. `node -e '…' asserting probe keys` + `! grep -E 'temperature|seed|prompt-file' <buildOcArgv body>` scoped to the argv builder. |
| F-08 | P2 | AC6 L413; AC8 L415; §1.3 L139; AC3 L410 | **YES.** (a) AC6 now requires content, not existence: "完整对比表、硬阻断科学归因、§6 完整的 6 项 PREREQ 清单（全量包含可直接运行的验证命令）、v1.18.27 真实版本核对证据" (L413). (b) AC8 now has explicit baseline capture + compare: `` `git status --porcelain=v1 --untracked-files=all \| sort > /tmp/thin-tad-baseline.status` `` pre-impl and `comm -13` post-impl (L415). (c) AC3 absence-grep noted acceptable, unchanged. (d) §1.3 currency scoping note present (L139); same L473 dispatch-prose residual as noted under F-01. |

## PREREQ-by-PREREQ (re-assessed on v1.1 text)

- **PREREQ-AUTH (L364–366): PASS.** Explicit human mandate, hard precondition for any live call including PREREQ-1 step 2. Unchanged and correct.
- **PREREQ-1 (L368–374): PASS** (was FAIL). Executable (mktemp), version-asserted offline (L373), AUTH-gated + budget-counted (L371). Intent-to-command gap closed.
- **PREREQ-2 (L376–382): PASS.** Concrete probe command + `probe_passed`/`adapter_eligible` assertions + Tier-1/Tier-2 controls. Re-pointing probe at adapter path remains a Blake task, now covered by strengthened AC4/AC5 prose.
- **PREREQ-3 (L384–387): PASS.** Disclosure demand intact ("严禁宣称已锁定 temperature: 0", "运行于默认采样策略下") with runnable doc-grep command (L387).
- **PREREQ-4 (L389–391): PASS** (was CONDITIONAL). Runnable `verifyArmsFidelity()` command present; symbol-presence weakness noted, Gate 3 must execute it.
- **PREREQ-5 (L393–395): PASS** (was CONDITIONAL). Budget constants (26/2/3) grep + node assert present.
- **PREREQ-6 (L397–399): PASS** (was CONDITIONAL). H/V 6/6 structural assert present.

## AC-by-AC (re-assessed on v1.1 text)

- **AC0 (L407): PASS.** `test -x` + `bash -n` exit-0, fail-closed pre-impl, discriminative post-impl.
- **AC1 (L408): PASS.** Exit-2 matrix (missing/bad/unknown) under `set -u`/`set -e` verifiable via AC4 mocks.
- **AC2 (L409): PASS.** `grep -F 'NOTE: [oc-adapter]'` source+log check; NOTE-to-stderr honesty mechanism preserved (§4.2 L290–292, no downstream injection L305).
- **AC3 (L410): PASS** (was CONDITIONAL). Dual-var wording consistent with §3.2/§4.1/§4.2; zero-`/home/box/pm/` negated grep retained.
- **AC4 (L411): PASS** (was CONDITIONAL). ≥30 + 7 named mocks.
- **AC5 (L412): CONDITIONAL** (was CONDITIONAL, reason narrowed). Behavioral requirement exists in prose but not in the verification command — see F-07 fix.
- **AC6 (L413): PASS** (was CONDITIONAL). Content assertions present.
- **AC7 (L414): PASS** (was FAIL P0). Satisfiable word-boundary gate scoped to audit md with shell exemption.
- **AC8 (L415): PASS** (was PASS-with-note). Baseline capture/compare now runnable; allowlist scope (§3.1) unchanged.

## Honesty & anti-forgery verdict: **PASS (conditional on AC5 fix)**

1. No forged flags: §4.1 hard-block rows + §4.2 TEMP/SEED absorb-and-NOTE (L290–292) + Leg-2 exec line carrying only native flags `-m/--dir/--auto/--format default/-f` (L305). No temp/seed downstream injection anywhere in the draft.
2. No fake shim / pm borrowing: allowlist (§3.1) + Fact C + AC3 negated grep + §3.2/L204 explicit anti-hardcode rule. Clean.
3. No live 24-run in this ticket: §1.3, §6 preamble, dispatch prohibitions, plus PREREQ-1 now AUTH-gated. The one Round1 gap is closed.
4. Currency/production-intrusion: AC7 gate satisfiable; allowlist + AC8 fence correctly scoped. Only residual is loose L473 dispatch prose (non-normative).
5. Comparability & variance severity: single identical adapter path for both arms, variance honestly disclosed (PREREQ-3/6, raw-tokens-only). Direction remains fail-safe (over-disclosure). Adequate.

## Knowledge Assessment

No new pattern. Both P0 closures confirm the durable P3-derived rule ("currency greps must be word-boundary without `\$` and scoped to prose artifacts; every PREREQ needs a runnable command") — v1.1 now exemplifies it except AC5, which repeats the old shape (prose requirement, syntax-only command). Recommend a lint-level home for "every AC verification cell must contain an executable command" so AC5-class regressions are caught mechanically.

## Provenance

- Independent reviewer R1-Round2, fresh session, eval-methodology lens only; no coordination with R2; code-allowlist depth explicitly deferred to R2.
- No live system re-verification re-run (binary/help/test-suite facts carried from Round1 evidence, which v1.1 does not dispute); all closure claims above rest on exact-string `grep`/`sed` evidence from v1.1 text quoted in the table.
- Carrier path: `.tad/evidence/reviews/alex/thin-tad-harness-adapter/eval-review-round2.md` (new file; `eval-review.md` untouched).
