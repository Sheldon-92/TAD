# Gate 2 Re-Review R2-Round2 — Code & Security / Interface-Contract Lens (Independent)

- Reviewer: R2-Round2 independent — Muse Spark, working INDEPENDENTLY (no coordination with R1)
- Date: 2026-09-08 (UTC)
- Artifact: `.tad/active/handoffs/HANDOFF-20260908-thin-tad-harness-adapter.md` (v1.1, Status Ready-for-Gate2-rereview)
- Prior findings source: `.tad/evidence/reviews/alex/thin-tad-harness-adapter/code-review.md` (R2 Round1 CONDITIONAL PASS, F01–F04 P0, F05–F11 P1, F12–F14 P2)
- Method: full read of handoff v1.1 (477 lines); full read of Round1 code-review.md (89 lines); live `rg` evidence checks in `/home/box/云同步/TAD` (quoted below). Judged the HANDOFF TEXT (design completeness), not implementation.
- Verdict: **CONDITIONAL PASS** — all four P0 findings (F01–F04) are textually closed; P1 containment (F07 prefix/symlink rule) remains PARTIAL and is the condition for Gate 3. No P0 blocks Gate 2 passage once the condition is recorded as a Gate 3 enforcement obligation (or a one-line handoff patch, preferred).

---

## Per-finding re-verification table

| ID | Sev | v1.1 location | Closed? | Evidence (quote / grep) |
|----|-----|---------------|---------|-------------------------|
| F01 | P0 | §4.2 lines 247–264 | **YES** | All five value-taking branches now guarded. `rg '\[\s*\$#\s*-ge\s*2\s*\]'` hits lines 251, 254, 257, 260, 263 — one per `--model\|-m`, `--dir`, `--prompt-file`, `--temperature`, `--seed`. Each of the form `[ $# -ge 2 ] \|\| { echo "ERROR: [oc-adapter] Missing value for $1" >&2; exit 2; }`. Line 247 documents the rule. `set -u`/`set -e` uncontrolled-crash path is closed; contracted exit 2 holds. |
| F02 | P0 | §4.2 line 304–305; §4.1 row line 207 | **YES** | Primary exec (line 305) `exec "$OPENCODE_BIN" run --dir "$WORK_DIR" -m "$MODEL" --auto --format default -f "$PROMPT_FILE"` carries **no prompt positional at all** — the injection surface is removed, not merely mitigated (exactly R1's preferred resolution). Fallback message path retains the mandatory `--`: line 304 comment `exec … --format default -- "$PROMPT_CONTENT"`, and §4.1 row (line 207) mandates "若使用位置参数回退，必须在参数前附加 `--` 阻断旗标注入". Table + code + comment are aligned. |
| F03 | P0 | §4.1 line 207; §4.2 lines 283–285, 305; §4.3 lines 317, 321; §3.2 line 194 | **YES** | `-f "$PROMPT_FILE"` is primary in all three places: §4.1 "优先采用 `-f "$PROMPT_FILE"` 原生文件透传" with explicit ARG_MAX (~2MB) / trailing-newline / NUL rationale; §4.2 exec uses `-f "$PROMPT_FILE"` with no `$(cat…)` anywhere in the script (only remaining `PROMPT_CONTENT` mention is the line-304 fallback comment); §4.3 step 8 emits the identical `-f` argv; §3.2 Leg 2 spells the same string. §4.1/§4.2/§4.3 aligned. |
| F04 | P0 | §3.2 lines 182–194; §4.1 line 204; §4.2 line 222; AC3 line 410 | **YES** | Dual-var design spelled out in one place (§3.2): Runner `TAD_OPENCODE_BIN` → adapter path; adapter `TAD_OPENCODE_RAW_BIN` → real binary with default `/home/box/.opencode/bin/opencode` + PATH fallback (line 222). `ENV_ALLOW` + `envLeakCheck` dual-allowlist mandated in §3.2 lines 190–191, §4.1 line 204, §4.3 line 312, AC3 line 410. `ocBin()` default-change mandate is explicit with exact string: "必须从 `'oc-run'` 强制更新为仓内相对路径 `'experiments/thin-tad-pilot/oc-adapter.sh'`" (lines 184, 204, 410). `/home/box/pm/**` hardcode forbidden (lines 185, 410). Two-leg argv shape spelled out (lines 192–194: Leg 1 keeps `--temperature/--seed/--prompt-file` for honest capture; Leg 2 emits only native flags). The `/home/box/.opencode/bin/opencode` default is the real-subject-binary path, not an external shim — acceptable per R1 F14 tolerance. |
| F05 | P1 | §4.2 lines 265–267; §1.1 line 113 | **YES** | Catch-all is now fail-closed: `*) echo "ERROR: [oc-adapter] Unknown argument: $1" >&2; exit 2 ;;` (lines 265–267). WARN-and-continue is gone. |
| F06 | P1 | §4.2 lines 272–284 | **YES** | `--prompt-file` required: lines 272–275 `if [ -z "$MODEL" ] \|\| [ -z "$WORK_DIR" ] \|\| [ -z "$PROMPT_FILE" ] … exit 2`. `WORK_DIR` gets `realpath -m` (line 277) + `[ ! -d ]` → exit 2 (lines 278–281). `PROMPT_FILE` gets `realpath -m` (line 283) + `[ ! -f ] \|\| [ ! -r ]` → exit 2 (lines 284–287). |
| F07 | P1 | §4.2 lines 277–287 (only) | **PARTIAL** | Delivered: `realpath -m` normalization + existence/readable checks (same lines as F06). **Missing, with no explicit deferral rationale:** (a) no workdir-prefix containment (`/tmp/` or allowlisted root — `rg 'prefix|containment|symlink|\[ -L \]|TOCTOU'` returns no §4.2 hits; only hit is MQ5 prose line 355 about runner-side dirs); (b) no symlink rejection on `WORK_DIR`; (c) no `PROMPT_FILE`-must-reside-in-run-dir constraint, so the adapter still `exec -f`s any readable path when invoked directly. The §4.1 "强化目录沙箱校验" claim overstates what the script enforces. Downgraded to PARTIAL rather than NO because the realpath+readable half is genuine progress and the runner-side Tier-2 negative control is still specified (MQ5). **Condition for Gate 3** (see blocking checklist). |
| F08 | P1 | §4.4 lines 335–343; MQ4 line 354 | **YES (text-level; Gate 3 tests required)** | Composition table exists with all demanded rows: adapter exit 127 → `FAILED_INFRA` no-retry (line 339); adapter exit 2 → `FAILED_HARNESS_USAGE`, "严禁消耗 2 次 infra 重试预算" (line 340); timeout `TIMEOUT_MS = 300s` → `ETIMEDOUT`, ≤1 retry/arm (line 341); base exit 0 → `COMPLETED` (line 342); base nonzero → `FAILED_MODEL` or `FAILED_INFRA` keyed on `INFRA_PATTERNS` (line 343). Residual imprecision (noted, non-blocking): the `FAILED_MODEL` telemetry-shape precondition (`--format json` vs `default`, cf. R1 F10/F08 linkage) and the mechanical `canRetryInfra` exemption are implied ("严禁消耗…重试预算") rather than spelled out as a code directive — acceptable at design stage, must be proven by per-row unit tests at Gate 3. |
| F09 (=R1 F-02) | P1 | §6 PREREQ-1 lines 368–374 | **YES** | Process substitution abolished: no `<(` remains in the handoff (`rg 'dev/fd'` hits only the line-74 revision note describing the old defect). Step 2 uses a real temp file: `P=$(mktemp /tmp/prereq-prompt.XXXXXX); echo ping >"$P"; … run --model … --dir /tmp --prompt-file "$P"; rc=$?; rm -f "$P"; test $rc -eq 0` (line 374). Offline version assertion split out (`>= 1.18.0`, lines 370/373) and PREREQ-AUTH gating explicit (lines 366, 371). |
| F10 | P1 | §4.1 line 210; §4.2 lines 302, 305; §3.2 line 194; §4.3 line 321; AC2 line 409 | **YES (minor residual: `--pure` undecided)** | `--format default` pinned in the exec (line 305) and identically in §3.2 Leg 2 (line 194) and §4.3 (line 321); table (line 210) says "显式在 `exec` 命令行中锁定 `--format default`" — table == code. Residual (P2-grade, non-blocking): the `--pure` decision R1 requested (determinism/isolation vs plugin need) is never stated — `rg pure` hits only the §1-background line 41 quoting `--help`. Carry to implementation as a documented choice. |
| F11 | P1 | AC8 line 415 | **YES (minor residual: `**` expansion)** | Now executable: who/when fixed ("Blake 实现前捕获基线快照…实现后对比"), both captures `git status --porcelain=v1 --untracked-files=all \| sort` (sorted inputs — fixes the `comm` bug), concrete paths `/tmp/thin-tad-baseline.status` → `/tmp/thin-tad-current.status`, `comm -13` diff. Residual: §3.1 item 7 (`…/**` directory glob) expansion-to-files normalization is still unspecified — Gate 3 verifier must define it. |
| F12 | P2 | §4.2 lines 295–299 | **YES** | Boundary honestly restated: "正常运行时由 runner.mjs spawnOc 负责环境净化 (sanitizeEnv)" (line 295); direct invocation must use `env -i … timeout 300` with a copy-pasteable safe form (lines 296–297). The old misleading "保持环境净化" comment is gone. `TERM` clobber fixed to `export TERM="${TERM:-dumb}"` (line 298, also closes R1 F14b). |
| F13 | P2 | §4.2 lines 296–297; §4.3 line 329; §4.4 line 341 | **YES** | Documented by design: no in-adapter timeout; runner `TIMEOUT_MS = 300,000 ms` process-group kill is the enforcement point (§4.3 line 329, §4.4 line 341); direct invocations MUST wrap with `timeout 300` (lines 296–297). Matches R1's recommended resolution exactly. |
| F14 (info) | P2 | PREREQ-1 lines 370/373; §4.2 line 298 | **YES / carried** | (a) version assertion `>= 1.18.0` present as PREREQ-1 offline step (no in-adapter `--check` subcommand — acceptable, probe/PREREQ covers it); (b) `TERM` fixed (line 298), `NO_COLOR=1` retained (line 299, `--format default` stream so no JSON interaction); (c) flag-absent (exit 2, line 274) vs file-empty (proceeds) now distinguished by construction. |

---

## Interface-contract verdict (row by row, vs R1 table)

| # | §4.1 row (v1.1) | Re-verdict | Rationale |
|---|----------------|------------|-----------|
| 1 | Subcommand `run` (§4.2 lines 234–239) | **Agree** | `run`-only pin with exit 2 otherwise, unchanged and correct. |
| 2 | 二进制路径 (line 204) | **Agree (was: Correct intent, BROKEN wiring)** | F04 closure verified above: both tiers named, both allowlisted, exact default mandated, pm-path forbidden. Wiring is now satisfiable. |
| 3 | 工作目录 `--dir` (line 205) | **Agree (passthrough), containment still missing** | Native `--dir` passthrough correct; `realpath -m` added; prefix/symlink containment deferred to the F07 Gate 3 condition. |
| 4 | 模型指定 `--model → -m` (line 206) | **Agree** | Normalization to `-m "$MODEL_ID"` correct, quoting safe. |
| 5 | 提示词输入 `--prompt-file → -f` (line 207) | **Agree (was: DISAGREE)** | `-f "$PROMPT_FILE"` primary everywhere; `--` mandated on any positional fallback. F02/F03 both closed. |
| 6 | 解码温度 `--temperature` (line 208) | **Agree** | Absorb + `NOTE: [oc-adapter]` to stderr, never forwarded. AC2 greps the prefix. |
| 7 | 随机种子 `--seed` (line 209) | **Agree** | Same as row 6. |
| 8 | 输出格式 (line 210) | **Agree (was: DISAGREE)** | Table == code (`--format default` in all four argv spellings). `--pure` choice outstanding, non-blocking. |
| 9 | 权限自动批准 `--auto` (line 211) | **Agree with containment caveat** | `--auto` required for batch use (correct); blast radius bounded only once the F07 prefix rule lands at implementation. |

Runner-rewrite scoping (R1's blocking-adjacent paragraph): **closed**. §3.2 item 4 now contains the demanded one-paragraph two-leg statement — Leg 1 `buildOcArgv` output `run --model <id> --dir <workDir> --prompt-file <path> --temperature 0 --seed 42` (retained for honest capture) vs Leg 2 native-only argv (line 193–194), mirrored in §4.3 steps 2/8. "消除假想旗标" can no longer be misread as deleting Leg-1 flags.

---

## Security verdict

- **Injection — PASS.** Primary path uses `-f` file passthrough (no prompt bytes in argv); fallback positional path mandates `--`. No `eval`/`system`/unquoted expansion; adapter quoting (`"$OPENCODE_BIN"`, `"$WORK_DIR"`, `"$MODEL"`, `"$PROMPT_FILE"`) intact. R1's "argv-array safety ≠ option-parser safety" trap is addressed at the parser layer.
- **Env hygiene — PASS (text-level).** Dual-tier allowlist mandated (`ENV_ALLOW` + `envLeakCheck` both vars); adapter honest about performing NO sanitization itself; safe direct-invocation form given. Mechanical confirmation (runner.mjs diff) is a Gate 3 check.
- **Traversal / symlink / containment — CONDITIONAL (F07).** `realpath -m` + existence/readable checks are real but prefix containment, symlink rejection, and prompt-dir binding are absent. Combined with forced `--auto`, this remains the highest-blast-radius residual. Must be implemented + tested at Gate 3 (see condition).
- **Exit-code integrity — PASS (text-level).** 127/2/passthrough taxonomy preserved; composition table routes deterministic usage errors to non-retriable `FAILED_HARNESS_USAGE`. Per-row unit tests required at Gate 3.
- **Timeout / DoS — PASS.** Runner group-kill authoritative; direct-invocation `timeout 300` documented. `-f` passthrough removes the prompt-size memory/ARG_MAX vector (no size cap needed on the primary path).
- **Overall:** no new attack surface introduced; all R1 security findings are either closed in text or converted to a single bounded Gate 3 implementation condition. No architectural change needed.

---

## Blocking-fix checklist status

P0 (required before Gate 2 PASS — **all closed**):

1. **F01** — ✅ `$2`/`shift 2` guards with exit 2 on all five branches (§4.2 lines 251–264).
2. **F02** — ✅ injection surface removed via `-f` primary; `--` mandated on fallback (§4.2 lines 304–305, §4.1 line 207).
3. **F03** — ✅ `-f` passthrough primary; §4.1/§4.2/§4.3 aligned; no `cat`-into-argv path remains.
4. **F04** — ✅ dual-var allowlist + exact `ocBin()` default mandate + two-leg argv paragraph (§3.2, §4.1 line 204, AC3).

P1/P2 (Gate 3 enforcement obligations):

- [x] F05 unknown-args fail-closed — closed in text; AC4 test #4 must prove it.
- [x] F06 required-args + realpath + existence/readable — closed in text; AC1/AC4 tests must prove it.
- [ ] **F07 containment — CONDITION (only open item):** implementation MUST add (a) `WORK_DIR` prefix enforcement (allowlisted root, e.g. `/tmp/` or runner-passed root) after `realpath -m`, (b) symlinked-workdir rejection or resolve-then-compare, (c) `PROMPT_FILE` containment (resolve inside run workdir or runner prompt dir); probe MUST exercise the real adapter binary for at least the negative control. Gate 3 must show failing-before/passing-after tests. A one-line handoff patch adding this rule pre-Gate-2-signoff is preferred but not required to withhold Gate 2 given all P0s are closed.
- [x] F08 composition table — closed in text; per-row unit tests required at Gate 3.
- [x] F09 mktemp + version assertion + AUTH gating — closed.
- [x] F10 `--format` pin — closed; record the `--pure` choice at implementation.
- [x] F11 fence procedure — closed; Gate 3 verifier defines `**` expansion.
- [x] F12/F13 env/timeout boundary — closed.

---

## Knowledge Assessment

No new project-knowledge candidate beyond R1's note (already captured in Round1: allowlist-stripping of `*_RAW_BIN`-tier vars, `<(…)` vs `[ -f ]` trap, argv-safety ≠ option-parser-safety). Round2 adds one empirical corollary worth appending to that pattern note when it is written: **`-f` file-passthrough simultaneously closes three defect classes (ARG_MAX/fidelity/injection) — prefer native file-mount flags over prompt-as-positional in any future harness adapter.** No new pattern file needed; no existing knowledge contradicted.

---

## Provenance

- Independent reviewer R2-Round2, fresh session; no coordination with R1 per instructions.
- Live evidence: full reads of handoff v1.1 (477 lines) and Round1 `code-review.md` (89 lines); `rg` checks executed in `/home/box/云同步/TAD` for: `[ $# -ge 2 ]` guards (5 hits, lines 251/254/257/260/263), `--` separator (line 304 comment), `-f "$PROMPT_FILE"` (lines 194/207/305/321), dual-var + `ocBin()` + pm-path (lines 182–194/204/410), `Unknown argument` + `exit 2` (lines 265–267 et al.), `realpath` + required-arg checks (lines 272–287), §4.4 mapping rows (lines 339–343), `mktemp` (line 374, no `<(` remains), `--format` (5 consistent spellings), AC8 fence (line 415), `env -i`/`timeout 300`/`sanitizeEnv` (lines 295–297/312/329).
- Existing files NOT modified. This carrier is NEW: `.tad/evidence/reviews/alex/thin-tad-harness-adapter/code-review-round2.md` (Round1 `code-review.md` untouched).
