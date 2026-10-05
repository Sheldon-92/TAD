# Gate 2 Re-Review R2-Round3 — Code & Security / Interface-Contract Lens (Independent)

- Reviewer: R2-Round3 independent — Muse Spark, working INDEPENDENTLY (no coordination with R1)
- Date: 2026-09-08 (UTC)
- Artifact: `.tad/active/handoffs/HANDOFF-20260908-thin-tad-harness-adapter.md` (v1.2, Status Ready-for-Gate2-rereview, 531 lines)
- Prior findings source: `.tad/evidence/reviews/alex/thin-tad-harness-adapter/code-review-round2.md` (R2-Round2 CONDITIONAL PASS, sole open item F07 containment P1; P0 F01–F04 closed)
- Method: full read of handoff v1.2 (all 531 lines); full read of Round2 code review (94 lines); live exact-string checks in `/home/box/云同步/TAD` (quoted below). Judged the HANDOFF TEXT (design completeness), not implementation.
- Verdict: **PASS** (unconditional, code lens) — the F07 containment condition is textually closed in §4.1/§4.2/§7/§9.2 with exact-string evidence, and its Gate 3 enforcement rationale is recorded as a blocking checkpoint. No P0/P1 open items remain at design stage.
- Carrier path: `.tad/evidence/reviews/alex/thin-tad-harness-adapter/code-review-round3.md` (new file; `code-review.md` and `code-review-round2.md` untouched)

---

## Round2 blocker re-verification (the only open item)

Round2's condition (code-review-round2.md §"Blocking-fix checklist status", F07): implementation MUST add (a) `WORK_DIR` prefix enforcement after `realpath -m`, (b) symlinked-workdir rejection or resolve-then-compare, (c) `PROMPT_FILE` containment; probe MUST exercise the real adapter binary for at least the negative control; Gate 3 must show failing-before/passing-after tests. "A one-line handoff patch adding this rule pre-Gate-2-signoff is preferred."

v1.2 delivers the preferred patch plus enforcement machinery. Row-by-row:

| Sub-item | v1.2 location | Closed? + evidence (quote / line) |
|---|---|---|
| (a) Workdir prefix containment | §4.1 table L221; §4.2 L305–L311; §4.3 step 5 L359; AC1 L450; §9.2 L490 | **YES.** §4.2: `ALLOWED_WORK_ROOT="${TAD_ALLOWED_WORK_ROOT:-/tmp}"` (L306) → `ALLOWED_WORK_ROOT="$(realpath -m "$ALLOWED_WORK_ROOT")"` (L307) → `if [[ "$WORK_DIR" != "$ALLOWED_WORK_ROOT"/* && "$WORK_DIR" != "$ALLOWED_WORK_ROOT" ]]; then … exit 2; fi` (L308–L311). Normalization precedes comparison (TOCTOU-reduced at script layer); equality with the root itself is allowed (no falseFAIL on `--dir /tmp`); default root `/tmp` with explicit `TAD_ALLOWED_WORK_ROOT` override. §4.1 row L221 restates the identical rule ("`/tmp/` 前缀沙箱包含性校验"), so table == code. |
| (b) Symlink rejection (workdir + prompt) | §4.2 L293–L297, L313–L317; §4.1 L221/L223; AC1 L450; AC4 L453 case 8 | **YES.** Pre-normalization hard reject on the RAW inputs: `if [ -L "$WORK_DIR" ]; then … exit 2; fi` (L294–L297) and `if [ -L "$PROMPT_FILE" ]; then … exit 2; fi` (L314–L317). Round2 accepted "rejection or resolve-then-compare"; v1.2 implements rejection-then-normalize, which is the stricter branch (a symlinked workdir fails even if its target would resolve inside the root — fail-closed, correct for a `--auto`-armed adapter). |
| (c) Prompt-file binding | §4.2 L319–L329; §4.1 L223; AC1 L450; AC4 L453 case 10 | **YES.** After `realpath -m` + `[ ! -f ] \|\| [ ! -r ]` (L319–L323): `if [[ "$PROMPT_FILE" != "$WORK_DIR"/* && "$PROMPT_FILE" != "$ALLOWED_WORK_ROOT"/* ]]; then … exit 2; fi` (L326–L329). A directly-invoked adapter can no longer `exec -f` an arbitrary readable path — the exact hole Round2 named is closed in text. Ordering is correct: symlink-reject → normalize → existence/readable → bind. |
| Gate 3 enforcement rationale | §9.2 L484–L494 (new subsection "Gate 3 强制执行与 F07 阻断验收法则") | **YES.** (1) Security & containment rationale L487–L490 names the `--auto` blast radius (unattended file read/write/execute in the workdir) as the reason prefix/symlink/binding are non-optional. (2) Mechanical acceptance L491–L494 mandates AC4 cases 8/9/10 as failing-before/passing-after Gate 3 blockers, exit-2 interception proof, and Tier-2 negative-control execution. The condition's "must be proven at Gate 3" half now has a named carrier (AC4 cases + probe Tier-2) and a named verdict point (Gate 3 reviewer). |
| AC1/AC4 test-matrix binding | AC1 L450; AC4 L453 | **YES.** AC1 expectation enumerates the full exit-2 matrix: missing/bad/unknown args; nonexistent workdir/prompt; symlinked WORK_DIR or PROMPT_FILE; WORK_DIR outside `/tmp/`; PROMPT_FILE unbound — each mapped to exit 2 under `set -u`/`set -e`. AC4 raises the bar to ≥33 tests (+8 over the 25 baseline) with 10 mandatory named mocks; cases 8/9/10 are exactly the F07 trio: `adapter fails closed exit 2 on symlinked workdir or prompt file` / `…on workdir outside allowed root` / `…on prompt-file outside workdir and root`. Names are mechanically greppable at Gate 3. |
| Revision-summary traceability | L77–L82 | **YES.** L77–L82 names R2-Round2 F07, the three defenses (a)/(b)/(c), their §4.1/§4.2/§7 landing lines, and the §9.2 enforcement rule — summary == normative text (verified by the line citations above, not taken on trust). |

## Regression re-check (Round2 PASS findings, v1.2 text)

| ID | v1.2 spot-check | Still PASS? |
|---|---|---|
| F01 (P0 `$# -ge 2` guards) | §4.2 L263–L285: all five value-taking branches (`--model\|-m`, `--dir`, `--prompt-file`, `--temperature`, `--seed`) retain `[ $# -ge 2 ] \|\| { … exit 2; }`; rule documented L263. | YES |
| F02 (P0 `--` injection) | Primary exec L347 is `-f` file-passthrough (no positional prompt at all); fallback comment L346 retains mandatory `--` (`… --format default -- "$PROMPT_CONTENT"`); §4.1 L223 mandates `--` on any positional fallback. | YES |
| F03 (P0 `-f` primary) | `-f "$PROMPT_FILE"` primary in §4.1 L223, §4.2 L347, §3.2 Leg-2 L210, §4.3 step 8 L363; no `$(cat…)` into argv anywhere (only `PROMPT_CONTENT` is the L346 fallback comment); ARG_MAX/newline/NUL rationale retained. | YES |
| F04 (P0 dual-var) | §3.2 L198–L210: `TAD_OPENCODE_BIN` → adapter, `TAD_OPENCODE_RAW_BIN` → real binary (default `/home/box/.opencode/bin/opencode` + PATH fallback L238–L246); both in `ENV_ALLOW`/`envLeakCheck` (L205–L207, AC3 L452); exact `ocBin()` default-mandate string retained; `/home/box/pm/**` hardcode forbidden. | YES |
| F05 (unknown-args exit 2) | Catch-all L281–L283 `*) … exit 2 ;;` retained. | YES |
| F06 (required + realpath) | L288–L291 required-args exit 2; `realpath -m` + existence/readable retained (now L299/L303/L319–L323, shifted by the inserted containment block — content-identical, line numbers moved). | YES |
| F08 (composition table) | §4.4 L377–L385: 127→`FAILED_INFRA` no-retry; 2→`FAILED_HARNESS_USAGE` "严禁消耗 2 次 infra 重试预算"; 300s→`ETIMEDOUT` ≤1/arm; 0→`COMPLETED`; nonzero→`FAILED_MODEL`/`FAILED_INFRA` keyed on `INFRA_PATTERNS`. Residual (telemetry-shape precondition, `canRetryInfra` spelling) unchanged, still Gate-3-testable, still non-blocking. | YES |
| F09 (mktemp/version/AUTH) | PREREQ-1 L414–L416 mktemp + `>= 1.18.0` + AUTH gating; no `<(` outside L89 historical note. | YES |
| F10 (`--format` pin) | `--format default` pinned in exec L347 + Leg-2 L210 + §4.3 L363 + table L226 ("显式在 `exec` 命令行中锁定"). `--pure` decision still unrecorded (only hit: L41 `--help` background quote) — carried P2-grade residual, non-blocking, must be recorded at implementation. | YES |
| F11 (fence procedure) | AC8 L457: pre-impl baseline capture + post-impl `comm -13`, both `git status --porcelain=v1 --untracked-files=all \| sort`, concrete `/tmp/*.status` paths. `**`-expansion normalization still unspecified — Gate 3 verifier defines it (carried, non-blocking). | YES |
| F12/F13 (env/timeout boundary) | L337–L341: runner `sanitizeEnv` authoritative; direct-invocation `env -i … timeout 300` copy-pasteable form; no in-adapter timeout; `export TERM="${TERM:-dumb}"` retained. | YES |

## Interface-contract verdict (row by row, vs Round2 table)

| §4.1 row (v1.2) | Re-verdict |
|---|---|
| Subcommand `run` | Agree (unchanged, exit 2 otherwise). |
| 二进制路径 (L220) | Agree — dual-tier named, both allowlisted, exact default mandated, pm-path forbidden. |
| 工作目录 `--dir` (L221) | **Agree (was: passthrough, containment missing) → now Agree.** Native passthrough + `realpath -m` + symlink-reject + prefix containment; table == code. |
| 模型指定 (L222) | Agree. |
| 提示词输入 (L223) | Agree — `-f` primary everywhere, `--` on fallback, symlink-reject + readable + binding; table == code. |
| 温度/种子 (L224–L225) | Agree — absorb + `NOTE: [oc-adapter]` to stderr (L331–L334), never forwarded. |
| 输出格式 (L226) | Agree — table == code (`--format default`); `--pure` carry noted above. |
| 权限自动批准 `--auto` (L227) | **Agree (was: with containment caveat) → caveat discharged.** Forced `--auto` (L347) is now bounded by the landed prefix rule; blast radius is fenced at the adapter layer. |

## Security verdict

- **Injection — PASS.** Unchanged from Round2: `-f` primary removes the prompt-bytes-in-argv surface; `--` on fallback; quoting intact; no `eval`/unquoted expansion.
- **Env hygiene — PASS (text-level).** Dual-tier allowlist mandated; adapter performs no sanitization itself (honest boundary L337); safe direct-invocation form given. Mechanical confirmation is a Gate 3 check (unchanged).
- **Traversal / symlink / containment — PASS (text-level; was CONDITIONAL).** The three defenses are specified with correct ordering (reject → normalize → compare → bind), correct defaults (`/tmp`, overridable via `TAD_ALLOWED_WORK_ROOT`), and correct failure mode (exit 2 → `FAILED_HARNESS_USAGE`, non-retriable per §4.4 L382). Per-case unit proof + probe negative-control execution are Gate 3 obligations per §9.2, which is the right place for them — no architectural change needed.
- **Exit-code integrity — PASS (text-level).** 127/2/passthrough taxonomy preserved; deterministic usage/containment errors routed to non-retriable `FAILED_HARNESS_USAGE`. Per-row unit tests required at Gate 3 (unchanged).
- **Timeout / DoS — PASS.** Runner group-kill authoritative; `timeout 300` for direct invocation; `-f` removes the ARG_MAX vector (unchanged).
- **New-sibling check:** the inserted containment block introduces no new expansion hazard — all comparisons are quoted (`"$WORK_DIR"`, `"$PROMPT_FILE"`, `"$ALLOWED_WORK_ROOT"`), `realpath -m` handles non-existent tails without failure, and the `[[ … ]]` globs are prefix patterns, not pathname expansions. `TAD_ALLOWED_WORK_ROOT` itself is normalized (L307), so a symlinked root config cannot smuggle a prefix escape past the comparison.
- **Overall:** no new attack surface; zero open P0/P1 at design stage. The two carried P2-grade residuals (`--pure` choice, `**` expansion norm) are implementation-time records, not Gate 2 blocks.

## Blocking-fix checklist status (final, code lens)

P0 (all closed, verified above): F01 ✅ / F02 ✅ / F03 ✅ / F04 ✅.
P1/P2 Gate 3 obligations: F05 ✅ text (AC4 #4 proves) / F06 ✅ text (AC1/AC4 prove) / **F07 ✅ text (AC4 #8/#9/#10 + §9.2 prove; was the sole CONDITION, now closed)** / F08 ✅ text (per-row tests) / F09 ✅ / F10 ✅ text (`--pure` record at impl) / F11 ✅ text (verifier defines `**`) / F12 ✅ / F13 ✅.

## Knowledge Assessment

No new pattern file. One empirical corollary worth appending to the existing harness-adapter note when it is written (same corollary R2-Round2 recorded): **`-f` file-passthrough simultaneously closes ARG_MAX/fidelity/injection** — v1.2 keeps it primary in all four argv spellings. Second corollary from this round: **order the containment as reject-raw-symlink → normalize → prefix-compare → bind** (v1.2 §4.2 L293–L329 is the exemplar — checking `[ -L ]` before `realpath` keeps the fail-closed branch strict even when the target would resolve inside the root). No existing knowledge contradicted.

---

## Provenance

- Independent reviewer R2-Round3; no coordination with R1 per instructions.
- Live evidence on 2026-09-08: full reads of v1.2 (531 lines) and Round2 code review (94 lines); exact-string checks for `[ -L ]` (L79/L126/L221/L293/L314/L490), `TAD_ALLOWED_WORK_ROOT` (L80/L126/L305–L308/L326/L490), `realpath -m` (L80/L126/L221/L299/L303/L307/L319), `FAILED_HARNESS_USAGE` (§4.4 L382), AC4 named mocks (L453, 10 cases incl. trio 8/9/10), §9.2 enforcement (L484–L494), `ocBin()` default mandate + pm-prohibition (L200–L201/L220/L452), `mktemp` (L416, no live `<(`), `--format default` (L210/L226/L347/L363), `env -i`/`timeout 300` (L337–L341).
- Existing files NOT modified. This carrier is NEW: `.tad/evidence/reviews/alex/thin-tad-harness-adapter/code-review-round3.md` (Round1 `code-review.md` and Round2 `code-review-round2.md` untouched).
