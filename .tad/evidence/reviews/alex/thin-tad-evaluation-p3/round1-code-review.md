# Gate 2 Design Review — HANDOFF-20260908-thin-tad-evaluation-p3.md v1.0

**Reviewer role:** Code Reviewer / System Lead (Reviewer 2: boundary safety + zero-intrusion + reopening-protocol rigor)
**Date:** 2026-09-08 (OpenCode independent session, per Charter §3.7 — not Cursor)
**Scope:** boundary safety / zero-intrusion / reopening rigor ONLY — eval methodology out of scope (Reviewer 1).
**Grounding read:** handoff v1.0; EPIC-20260907-thin-tad-evaluation.md; `runs/isolation-probe-report.json`; `scope.json`; `arms/baseline.json`; `arms/candidate.md`; principles.md; gate-design.md; ac-verification.md; live `git status` / path existence checks.

## Verdict: CONDITIONAL (3 × P0 must be fixed before Blake starts; no redesign needed)

## P0 Findings (gate-blocking)

### P0-1 — AC7 absolute-empty `git status` fence is unsatisfiable at baseline
- **Location:** §6 command 3 + AC7 (`git status --porcelain .agents/ .claude/ .tad/hooks/ .tad/config.yaml` / "输出必须为空").
- **Evidence:** Ran the literal command on the live tree: it returns **100+ pre-existing M/D entries** across all four scoped paths (e.g. `M .agents/skills/...`, `D .agents/skills/...cost-token-economics.md`, `M .tad/hooks/lib/...` ×27, `.tad/config.yaml` tracked+present). Output is non-empty *before Blake writes anything*.
- **Why it blocks:** Per `ac-verification.md` snapshot-diff pattern, an absolute-list fence on a dirty repo false-FAILs by construction. Blake can never produce "empty output" without cleaning other terminals' dirt (itself a violation).
- **Fix:** Replace with a snapshot-diff fence: capture before/after tracked+untracked sets, `comm -13`, assert delta ⊆ allowlist; or scope the check to `git diff` of files touched after a recorded baseline instant. State the residual (modification of already-dirty files invisible to add-only diff → add content-hash guard or record as named blind spot).

### P0-2 — AC4/§6 currency grep is self-defeating as written
- **Location:** AC4 ("`analysis.md`、`decision.md` 及相关脚本中…严禁出现…`grep -riE 'usd|\$|dollar|cents'` 验证必须为 0 命中") + §6 commands 2.
- **Two defects:**
  1. `\$` matches **every literal `$`** — any normal `verify-p3.mjs` using `${...}` template literals or any shell `$VAR` fails the "0 命中" bar. Extending AC4 to "相关脚本" makes it unsatisfiable for the very script §3.1/§6 mandate.
  2. Self-leak (`ac-verification.md`): a report that writes "本报告不含 USD/$" to describe the ban **fails its own grep** (`-i` matches `USD`). Correct deliverables are forced into awkward circumlocution with no sanctioned phrasing.
- **Fix:** Scope AC4 to the two `.md` deliverables only; exempt the verifier script (or give it a machine-checkable convention, e.g. `grep -v` an explicit `CURRENCY-ALLOWLIST:` marker line); prescribe the sanctioned ban-description wording and dry-run the exact grep against a fixture containing it (GOOD must pass / BAD must fail) before Blake starts.

### P0-3 — Allowed-write set stated three different ways
- **Location:** §Gate-2 table ("仅限写 evidence 目录") vs AC7 ("局限于 `.tad/evidence/` 及 `experiments/thin-tad-pilot/`") vs §3.1 item 3 + §6 (`experiments/thin-tad-pilot/verify-p3.mjs`) vs §4.1 tree (omits the verify script entirely).
- **Why it blocks:** The executable contract (Blake) follows §3.1/§6 and writes outside the Gate-2-table fence; Gate 3 then cannot tell violation from authorized write. (Direction note: per principles.md 2026-08-06 amendment, a write-scope is an *unbounded* set → the small allowlist form used by AC7 is the correct choice; it just must be stated **once**.)
- **Fix:** One canonical allowlist (recommend: `.tad/evidence/experiments/thin-tad-pilot/**` + `experiments/thin-tad-pilot/verify-p3.mjs` + §7.2 completion carrier, see P1-1); make §4.1 tree include `verify-p3.mjs`; correct the Gate-2-table row to match.

## P1 Findings (must fix, not blocking redesign)

### P1-1 — §7.2 completion-report carrier path is outside every allowlist
- **Location:** §7.2 (requires `COMPLETION-20260908-thin-tad-evaluation-p3.md` with per-AC command evidence) vs §3.2/AC7.
- **Fix:** Add the explicit carrier (conventionally `.tad/active/handoffs/COMPLETION-20260908-thin-tad-evaluation-p3.md`) to the canonical allowlist from P0-3. Per Claims-Need-Carriers, a Gate 3 without a named carrier is unverifiable.

### P1-2 — Reopening 5 prerequisites are individually named but not individually measurable
- **Location:** §3.1 item 2 §3 checklist (harness cert / probe neg-pos / param lock / 13-file fidelity 100% / budget+breaker / pre-registered non-inferiority margin).
- **Gaps:** no harness-acceptance criteria (which binary, which provenance); no budget-cap number, no breaker trip rule; no margin value; no fidelity-100% measurement method (hash comparison? loader trace?). As written, a future reader cannot compute PASS/FAIL — the "new human mandate" becomes the only real gate and the 5 items are advisory prose.
- **Fix:** Pre-register: (1) harness identity + acceptance probe; (2) token budget cap + consecutive-failure breaker N; (3) margin numeric value + decision rule; (4) fidelity method (e.g. sha256 of 13 blobs vs `arms/baseline.json`); (5) exact param set (`temperature:0, seed:42, 300s`, per Epic §Phase-2 Scope). No exit-0-vs-honest-BLOCK tension exists in *this* ticket (verify-p3.mjs has no BLOCK states), so no two-branch form needed here — but the future-ticket ACs will need it.

### P1-3 — §6 command 3 is not fail-closed
- **Location:** §6 `# 3.` bare `git status --porcelain …` with comment "# 输出必须为空".
- **Fix:** `test -z "$(git status --porcelain .agents/ .claude/ .tad/hooks/ .tad/config.yaml)"` (after P0-1 rework, the snapshot-diff equivalent with explicit non-empty-set guard per Verification-Commands-Vacuous-Before-Staging).

## P2 Findings (advisory)

### P2-1 — Probe-value citation nits (§4.2 vs JSON ground truth)
- Values match the live JSON (`probe_passed:false, adapter_eligible:false, violation:"adapter-ineligible: subject binary missing: oc-run", action:"ABORT"`, tier1 flags `true/true`, `baseline_file_count:13, candidate_present:true, harness_available:false, negative_blocked:null, positive_ok:null` — verified by direct read). Nits: (a) §4.2 flattens `checks.*` fields to top level without noting the nesting — cite as `checks.harness_available` etc.; (b) omits `model_id`/`harness_id` (`opencode-go/muse-spark-1.3-contributor`, `OpenCode/oc-run`) which are the load-bearing identity claims; (c) baseline pin `edce7606` (§4.2) vs `scope.json` head `7c1eb5a8` — clarify which commit pins the 13-file content (add `git cat-file -t` / blob-hash cross-ref; `edce7606` does resolve to a commit).

### P2-2 — Fail-closed audit coverage is adequate
- Both refusals are required with reasons: external `/home/box/pm/bin/oc-run.sh` (nonstandard path / cross-project / no mandate) and bare `opencode run` (missing `--temperature/--seed/--prompt-file`, breaking controls) — §3.1 item 1 §3 + AC3. Correctly, neither is claimed as a probe output (the probe JSON records only `harness_available:false` + pre-run nulls). No fix; carry to Reviewer 1 only for whether Tier-1 design-value discussion belongs in analysis vs decision doc.

## AC-by-AC (boundary-scope ACs)

| AC | Verdict | Reason |
|----|---------|--------|
| AC3 探针审计与边界防护 | **SOUND** (P2-1 nits) | Requires fail-closed chain + both refusals with rationale + JSON citation; values verified against live probe JSON. |
| AC4 零货币记账 | **NEEDS-FIX** (P0-2) | `\$` alternative + script-inclusive scope unsatisfiable; self-leak on ban-description prose. |
| AC6 重开准入协议规范 | **NEEDS-FIX** (P1-2) | 5 gates + new-mandate structure sound; thresholds/methods missing → not falsifiable. |
| AC7 生产零侵入 | **NEEDS-FIX** (P0-1+P0-3+P1-1) | Fence direction correct (protected-path check disjoint from `.tad/evidence/` writes — good); absolute-empty form false-FAILs on dirty tree; allowlist stated inconsistently; completion carrier missing. |

## Command / path consistency notes

- All four §6 git-status paths exist; `.tad/config.yaml` exists and is **tracked** (`git ls-files --error-unmatch` OK). Fence direction (checked set ∩ allowed-write set = ∅ for `.tad/evidence/`) is correctly non-vacuous in design — only the baseline-dirt (P0-1) defeats it.
- `node experiments/thin-tad-pilot/verify-p3.mjs` — dir `experiments/thin-tad-pilot/` exists; script does **not** yet exist (correct: Blake creates it). Consistent across §3.1/§6/Epic; only the Gate-2-table row and §4.1 tree disagree (P0-3).
- `.tad/evidence/reviews/alex/thin-tad-evaluation-p3/` does not yet exist (correct: created at review/implementation time); §7.1 carrier path is inside `.tad/evidence/` so no fence conflict.
- Execution Mandate clarity: §1.3 Blake confirmation questions + "Human 确认后才能开始" adequate (DECISION-type human gate, feasible); out-of-scope prohibitions explicit (no fabricated runs, no prod edits, no currency, no live model calls, no harness repair in-ticket, no Cursor-side Gate 2 PASS) — SOUND.
- Lifecycle: Gate2-must-run-in-OpenCode respected — this review **is** the OpenCode session; handoff correctly withholds Gate 2 PASS from the Cursor session. §7.1 dual-review (eval-methodology + boundary-safety reviewers, evidence path named) + §7.2 Gate 3 expectation (Layer 2 + per-AC command evidence) complete modulo P1-1 carrier allowlisting.

## One-line rationale

Fence architecture and fail-closed audit are well-designed, but three P0s (dirty-tree-false-FAIL AC7, self-defeating AC4 grep, triple-stated write scope) make the contract unexecutable-as-written — fix the verifiers, then PASS.
