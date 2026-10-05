# Gate 2 Round 2 Re-Review — HANDOFF-20260908-thin-tad-evaluation-p3.md v1.1

**Reviewer role:** Code Reviewer / System Lead (Reviewer 2: boundary safety + zero-intrusion + reopening-protocol rigor; eval methodology out of scope, covered by Reviewer 1)
**Date:** 2026-09-08
**Session:** OpenCode independent session (per Charter §3.7 — not Cursor)
**Scope:** boundary safety / zero-intrusion / reopening rigor ONLY.
**Grounding read:** handoff v1.1 (358 lines); EPIC-20260907-thin-tad-evaluation.md; `runs/isolation-probe-report.json` (live read); `arms/baseline.json` (13-file scope); principles.md incl. 2026-08-06 allowlist amendment; patterns `gate-design.md` + `ac-verification.md`; Round 1 carriers `round1-ai-evaluation.md` + `round1-code-review.md`; live `git status` / path-existence spot checks.

## Verdict: PASS (all Round 1 P0s confirmed cleared; no new P0; one accepted residual blind spot documented below)

This is a **re-review**. Each Round 1 boundary P0/P1 is dispositioned with the exact v1.1 carrier lines that close it, plus a satisfiability check of the revised commands.

## Round 1 P0 closure verification (boundary scope)

### R1-P0-1 (AC7 absolute-empty fence unsatisfiable on dirty tree) — CLEARED
- **Round 1 defect:** `git status --porcelain .agents/ .claude/ .tad/hooks/ .tad/config.yaml` with "output must be empty" false-FAILs at baseline (Round 1 live runs: 20–100+ pre-existing `M`/`D` entries). Blake could never satisfy it without cleaning other terminals' dirt (itself a violation).
- **v1.1 closure:** AC7 rewritten to Snapshot-Diff (line 286); §6 step 0 records baseline (`git status --porcelain ... > /tmp/p3-baseline-status.txt`, line 297); §6 step 4 records post-state and asserts delta-emptiness via `comm -13` with fail-closed `test -z ... || { echo; exit 1; }` (lines 320–322); fix-mapping row P0-1 (line 342).
- **Re-verification:** command sequence is syntactically fail-closed and no longer asserts absolute emptiness. `comm -13` on two sorted `git status` snapshots is the sanctioned `ac-verification.md` 2026-08-05 pattern. Paths in the fence (`.agents/ .claude/ .tad/hooks/ .tad/config.yaml`) all exist and `.tad/config.yaml` is tracked (Round 1 confirmed; unchanged in v1.1).
- **Accepted residual (NOT a P0):** status-line-set diff cannot detect *content modification inside an already-`M` file* (line present before and after → invisible in `comm -13` delta). This is inherent to the pattern. Accepted because: (a) protected set ∩ allowlist = ∅ by construction, so any compliant Blake never touches the protected set at all; (b) Gate 3 Layer 2 review + completion-report per-AC evidence provide a second detection layer; (c) the alternative (absolute-empty) was proven unsatisfiable. Blake MAY add an optional sha256 spot-check at impl time, but the design does not require it. Documented here as the named blind spot so Gate 3 knows what the fence does not cover.

### R1-P0-2 (AC4 currency grep self-defeating) — CLEARED
- **Round 1 defects:** (1) `\$` matches every literal `$` (template literals `${...}`, shell `$VAR`), making the mandated `verify-p3.mjs` unsatisfiable; (2) scope covered "相关脚本" while §6 grepped only md files; (3) ban-description prose ("不含 USD/$") self-matches under `-i`.
- **v1.1 closure:** normative regex is now `\b(usd|dollars?|cents)\b` case-insensitive everywhere it matters (lines 168, 283, 316, 344); scope is the two md deliverables ONLY with the verifier script explicitly exempt ("验证脚本自身 exempt", lines 168, 283); the `\$` alternative is gone from every normative line (remaining `$` occurrences audited: shell `$md`/`$marker`, prose `$N \ge 3`, LaTeX `$\delta$`/`$n$` — none inside the AC4 pattern); §6 step 3 uses `test -s "$md" && ! grep -qiE ...` (line 316) so a missing file fails-closed instead of passing vacuously.
- **Re-verification:** the deliverables' REQUIRED future content (shell `which oc-run`, `git status` snippets with `$` prompts; LaTeX `$\delta \le 5\%$`, `$n \ge 50$`; prose `500,000 tokens`, `sha256 100%`) contains zero `usd|dollar|cents` word-tokens, so no self-trap. The script-exempt + md-only scoping resolves the §3.1/§6 disagreement. **Satisfiable.**

### R1-P0-3 (allowed-write set stated three ways) — CLEARED
- **Round 1 defect:** Gate-2 table ("仅限写 evidence 目录") vs AC7 (evidence + experiments) vs §3.1/§6 (verify script) vs §4.1 tree (script omitted) disagreed; Gate 3 could not distinguish violation from authorized write.
- **v1.1 closure:** single Canonical Write Allowlist defined once (§"全局唯一定义", lines 53–59) with exactly 5 categories: (1) analysis.md, (2) decision.md, (3) `experiments/thin-tad-pilot/verify-p3.mjs`, (4) `COMPLETION-20260908-thin-tad-evaluation-p3.md`, (5) `.tad/evidence/reviews/alex/thin-tad-evaluation-p3/**`. §3 scope header (line 128), §3.2 prohibition (line 180: "严禁写入 Canonical Write Allowlist 之外的任何文件"), §4.1 tree (lines 188–199, script + completion carrier both `[CREATE]`), MQ5 (line 272), AC7 (line 286), and fix-mapping row (line 345) all reference the same canonical set.
- **Re-verification:** `grep -n "Canonical Write Allowlist\|COMPLETION-20260908-thin-tad-evaluation-p3"` shows the allowlist term used consistently across scope/design/MQ/AC/fix-map sections; no competing "仅限写 evidence 目录" phrasing remains as a normative fence. Direction is correct per principles.md 2026-08-06 amendment (write-scope is unbounded → small allowlist form). **Consistent.**

## Round 1 P1 closure verification (boundary scope)

### R1-P1-1 (completion carrier outside every allowlist) — CLEARED
- **v1.1 closure:** completion carrier `.tad/active/handoffs/COMPLETION-20260908-thin-tad-evaluation-p3.md` is allowlist item 4 (line 58) and §4.1 tree entry (line 199); §7.2 requires per-AC command evidence in it (line 358). Claims-Need-Carriers satisfied for Gate 3.

### R1-P1-2 (5 prerequisites named but not measurable) — CLEARED
- **v1.1 closure (§3.1 item 2, lines 156–162; AC6, line 285):**
  1. `PREREQ-1: HARNESS_CERTIFICATION` — `which oc-run` exit 0 on standard PATH + isolation-probe neg/pos controls. Measurable (exit code + probe JSON).
  2. `PREREQ-2: HYPERPARAMETER_LOCK` — `--temperature 0`, `--seed 42`, `300s` timeout, workspace isolation. Measurable (flag presence).
  3. `PREREQ-3: BASELINE_13_FIDELITY` — per-file sha256 vs `baseline.json` (commit `edce7606`) at 100% byte-identity, no truncation. Measurable (hash equality).
  4. `PREREQ-4: BUDGET_AND_BREAKER` — per-arm cap 500,000 tokens + breaker on N ≥ 3 consecutive harness exceptions → abort. Measurable (counter + cap).
  5. `PREREQ-5: NON_INFERIORITY_MARGIN` — pre-registered $\delta \le 5\%$ + $n \ge 50$ (B2 floor), pooled-winner claims rejected. Measurable (threshold + n).
  Plus `PREREQ-AUTH: HUMAN_MANDATE` (fresh human authorization — DECISION-type human gate, feasible; Execution Mandate questions in §1.3 + "Human 确认后才能开始" preserved).
- **Assessment:** each item now has a quantitative indicator and a decision rule. A future ticket can compute PASS/FAIL per item. No exit-0-vs-honest-BLOCK tension exists in this ticket (verify-p3.mjs has no BLOCK states — correctly noted as N/A in Round 1, still true in v1.1).

### R1-P1-3 (§6 command 3 not fail-closed) — CLEARED
- **v1.1 closure:** bare `git status` with "# 输出必须为空" comment replaced by the `comm -13` + `test -z ... || { echo; exit 1; }` sequence (lines 320–322). Fail-closed. (Vacuous-before-staging concern from Reviewer 1 P1-1c is separately closed by `test -s` gating on the md checks.)

## Round 1 P2 nits (boundary scope)
- **P2-1 (probe citation nits):** FIXED. §4.2 now cites `checks.*` with nesting prefix (lines 239–247), includes `model_id`/`harness_id` load-bearing identities (lines 237–238), and disambiguates the baseline pin (`baseline.json` commit `edce7606` vs repo HEAD `7c1eb5a8`, line 205). Live JSON re-read in this review matches every cited value.
- **P2-2 (fail-closed audit coverage):** still adequate, no change needed. Both refusals (`/home/box/pm/bin/oc-run.sh` with nonstandard-path/cross-project/no-mandate reasons; bare `opencode run` with missing-flag/control-break reasons) required in §3.1 + AC3, correctly NOT claimed as probe outputs.

## Command / path consistency (re-checked on v1.1 text)
- Fence paths exist; `.tad/config.yaml` tracked (Round 1 `git ls-files --error-unmatch` OK, v1.1 paths unchanged).
- `node experiments/thin-tad-pilot/verify-p3.mjs` path consistent across §3.1/§6/§4.1/Epic; dir `experiments/thin-tad-pilot/` exists, script correctly absent pre-impl (Blake creates it); `node --version` prerequisite present (line 296, node v20.19.2 on this host).
- Review carrier dir `.tad/evidence/reviews/alex/thin-tad-evaluation-p3/` exists with Round 1 carriers; Round 2 carriers land in the same dir, inside `.tad/evidence/` so no fence conflict (allowlist item 5 covers `**`).
- Execution Mandate clarity: §1.3 Blake confirmation questions + out-of-scope prohibitions (no fabricated runs, no prod edits, no currency, no live model calls, no harness repair in-ticket, no Cursor-side PASS) intact — SOUND.
- Lifecycle: Charter §3.7 respected — this re-review runs in the OpenCode session; v1.1 withholds self-signed PASS (status line + §7.1 re-review mandate intact until this review lands).

## AC-by-AC (boundary-scope ACs)

| AC | Verdict | Reason |
|----|---------|--------|
| AC3 probe audit + boundary defense | PASS | Fail-closed chain + both refusals with rationale + JSON values verified live |
| AC4 zero currency | PASS | Narrowed word-regex, md-only scope, script exempt, `test -s` gated, no self-trap |
| AC6 reopening protocol | PASS | 5 gates + fresh-mandate structure with per-item quantitative PASS/FAIL rules |
| AC7 zero intrusion | PASS | Snapshot-diff satisfiable + single allowlist + completion carrier; blind spot named above |

## Gate 2 checklist (Reviewer 2 lens)

| Item | Status | Note |
|------|--------|------|
| Expert review complete (min 2) | ✅ Pass | Round 1 dual + this Round 2 dual, all OpenCode sessions per Charter §3.7 |
| All P0 resolved | ✅ Pass | 3 boundary P0s verified closed with line-anchored carriers (P0-1 fence, P0-2 grep, P0-3 allowlist) |
| Architecture complete | ✅ Pass | Deliverable tree (§4.1) matches allowlist and §3.1 scope 1:1 |
| Components specified | ✅ Pass | Snapshot fence, currency gate, presence gate, 5-prereq protocol each specified |
| Functions verified | ✅ Pass | §6 commands assessed satisfiable + fail-closed (baseline/post/test -z/test -s/exit codes) |
| Data flow mapped | ✅ Pass | MQ2/MQ5: read-only evidence in, bounded allowlist out, no prod writes |

## Residual advisories (P2 only, do not block Blake)
- **ADV-1 (accepted blind spot):** status-line-set diff misses in-place edits to already-dirty protected files. Accepted for the reasons in P0-1 above; optional Blake hardening: record `git hash-object` spot-hashes of the 13 baseline files + hook lib at baseline and re-assert post-impl.
- **ADV-2:** No new issues found. Currency, allowlist, probe-citation, and fail-closed handling are all sound as written.

## One-line rationale
Fence architecture is now satisfiable, the currency gate no longer self-traps, and the write scope is stated exactly once — the contract is executable as written. Gate 2 PASS recommended from the boundary-safety lens.

## Knowledge Assessment
No new reusable boundary-safety knowledge beyond applied snapshot-diff/allowlist/fail-closed patterns already in project-knowledge; no distillation proposed.
