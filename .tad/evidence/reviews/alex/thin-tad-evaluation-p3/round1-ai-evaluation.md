# TAD Gate 2 Design Review — HANDOFF-20260908-thin-tad-evaluation-p3.md v1.0

**Reviewer role:** Independent AI Evaluation Architect (methodology + honesty + AC quality; system security out of scope, covered by Reviewer 2)
**Date:** 2026-09-08
**Session:** OpenCode independent session (per Charter §3.7 — not Cursor)
**Target:** `.tad/active/handoffs/HANDOFF-20260908-thin-tad-evaluation-p3.md` v1.0 (Ready for Gate 2 Review)
**Grounded in (all read):** handoff; EPIC-20260907-thin-tad-evaluation.md; `runs/isolation-probe-report.json`; `arms/baseline.json` + `arms/candidate.md`; principles.md (Measure Before Optimizing, honesty); patterns `gate-design.md` (Claims Need Carriers) + `ac-verification.md` (dry-run discipline); ai-evaluation SKILL.

## Verdict: CONDITIONAL (2 × P0 must-fix; no redesign needed)

## P0 findings (blocking Gate 2 PASS)

**P0-1 — AC7 / §6 step 3 unsatisfiable: scoped `git status` is non-empty at baseline.**
Location: handoff §5 AC7 + §6 step 3 (`git status --porcelain .agents/ .claude/ .tad/hooks/ .tad/config.yaml`, "output must be empty").
Dry-run (live host, verified): the command returns 20+ pre-existing `M` entries under `.agents/` (plus a `D` line) at baseline — exit 0 but non-empty output. Blake can never produce "empty" regardless of P3 discipline; this is the snapshot-fence anti-pattern (absolute-list fence false-FAILs on dirty tree; cf. ac-verification.md 2026-08-05 entry).
Fix: replace with a snapshot-diff fence (capture before/after sets, `comm -13`, single shared allowlist covering `.tad/evidence/experiments/thin-tad-pilot/{analysis,decision}.md` + `experiments/thin-tad-pilot/verify-p3.mjs` + review carriers), or assert "no NEW entries vs recorded baseline hash" instead of absolute emptiness.

**P0-2 — AC0/AC5/AC6 have no positive-presence verification; only AC4 has a (broken) negative check.**
Location: §5 AC0/AC5/AC6 vs §6 (steps 1–4 contain no `grep -q` for `ADAPTER_INELIGIBLE`, `LIVE_EFFECT_UNDETERMINED`, architecture-retention sentence, or the 5-item prerequisites list).
Per Claims Need Carriers + AC-Driven Gate pattern, honesty claims without carrier-anchored presence ACs are unenforceable prose. An implementation delivering two non-empty md files about anything would pass §6 steps 1–3.
Fix: add `grep -qF 'LIVE_EFFECT_UNDETERMINED' analysis.md`, `grep -qF 'ADAPTER_INELIGIBLE' analysis.md`, presence checks for the retention verdict in decision.md and each of the 5 prerequisites keywords; or pin exact literal tokens that `verify-p3.mjs` must assert (currently §3.1-3.3 says "key metrics" with no literals).

## P1 findings (required before Blake starts)

**P1-1 — AC4 `$` alternative makes the currency grep a false-FAIL trap; scope mismatch with §6.**
Location: §5 AC4 (`grep -riE 'usd|\$|dollar|cents'` must be 0 hits) vs §6 step 2 (greps only the two md files, while AC4 text covers "及相关脚本").
(a) In ERE `\$` = literal `$`: any legitimate `$` in analysis.md (shell `$` prompts for the documented `which oc-run` / `git status` commands, `$HOME`, backtick code) fails the AC. The report MUST document probe commands, so the author is forced to choose between faithful evidence and a green gate. Fix: drop the `\$` alternative (keep `usd|dollar|cents` case-insensitive) or restrict to word-boundary currency use, and mandate non-`$` shell prompts in both reports.
(b) Scope: either extend §6 step 2 to the script (noting the script's own regex literal self-matches — must exclude its own pattern line) or narrow AC4 text to the two md files. As written, AC4 and §6 disagree on the governed set.
(c) Dry-run: pre-impl, both md files are absent → `grep` exits 2 on missing file, `!` inverts to 0 → step 2 PASSES VACUOUSLY pre-impl. Add `test -s` gating before the grep (step 1 already exists; chain with `&&`) so the check is non-vacuous.

**P1-2 — Gate 2 mandatory-question (MQ1–MQ6) section absent, unlike P2 §5.**
Location: whole handoff (no §5-equivalent MQ table).
P2 established the precedent (history reuse of `pilot.mjs` scorers, function-existence, data-flow closure, terminal-state taxonomy, persistence paths, harness research). P3 reuses P1 oracles/controls/cases, P2 probe JSON + `runner.mjs` helpers (e.g., token-counting approach for §4.3), and introduces a new script — all of which MQ answers would pin down. Not verdict-blocking for a read-only analysis task, but a P1 traceability gap.
Fix: add a compact MQ table (reuse list: `cases/`, `controls/`, `oracles/`, probe JSON, `runner.mjs` utilities reused vs rewritten; data-flow: read-only evidence → two md files, no model calls; terminal states reused from P2 taxonomy; persistence paths).

**P1-3 — Missing explicit B2-floor / H-vs-V non-pooling guard.**
Location: §3.1 analysis requirements + §4.2.
The handoff is honest that live effect is `UNDETERMINED` and forbids thin-vs-thick verdicts (§3.2) — good. But it never cites the ai-evaluation B2 floor (n=12 ≪ 50–100 minimum; V holdout n=6) nor restates the Epic's pre-declared exclusion ("H open-calibration, V frozen holdout, H/V分表, neither supports an overall winner") inline in the analysis contract. Per the Pre-Declared Exclusion pattern, exclusions referenced only via Epic preamble don't bind the implementer at runtime — a pooled "12-case offline summary" could read as a verdict.
Fix: one explicit clause — "n=12 below B2 confirmatory floor; H/V reported separately, never pooled into a winner claim; offline characterization only (internal validity of the frozen package, no external-validity claim about live model performance)."

## P2 findings (advisory, fix in v1.1)

**P2-1 — §4.1 file tree omits the `verify-p3.mjs` carrier.** §3.1, §6 step 4, and Epic Files-Likely-Affected all name `experiments/thin-tad-pilot/verify-p3.mjs`, but the §4.1 tree shows only `analysis.md`/`decision.md`/`runs/`. (Note: §3.1 vs §6 paths are CONSISTENT — both repo-root-relative `experiments/...`; no cross-section path contradiction found.) Fix: add the script row with `[CREATE]` + its carrier AC.
**P2-2 — §3.1-3 "checks key metrics" is unverifiable.** No literal strings, no exit-code contract, no GOOD/BAD fixture requirement for the script. Fix: specify exit 0 contract + the literal token list (feeds P0-2 fix).
**P2-3 — §6 step 4 has no failure-mode pin.** If `node` is absent or the script is missing, Blake's nearest exit is editing §6. Fix: pre-declare `node --version` prerequisite and "script missing → BLOCK, do not hand-verify around it."

## What the handoff gets right (methodology + honesty)

1. **Architecture completeness — SOUND.** Dual-doc split (analysis.md §1–§4 / decision.md §1–§3) maps 1:1 to evidence: §4.2 probe-field mapping verified byte-accurate against the live JSON (`probe_passed:false, adapter_eligible:false, violation:"adapter-ineligible: subject binary missing: oc-run", action:"ABORT"`, checks block incl. `baseline_file_count:13`, null negatives/positives); baseline 13-file list matches `baseline.json` scope; 6 task families × H/V, 24 controls, oracle rigor all required.
2. **Scope honestly bounded — SOUND.** §1.3 non-goals + §3.2 forbid fabricating the 24-run matrix, forbid "untested = equivalent," forbid production edits, forbid currency conversion, forbid new live runs without a fresh authorization. `LIVE_EFFECT_UNDETERMINED` / `EMPIRICAL_DATA_ABSENT` asserted in §1.1, §3.1-§4. Consistent with Epic Phase Map + P3 redirect authorization.
3. **Missing-data accounting — SOUND with P1-3 hardening.** Zero live runs declared as zero (not 0-cost, not neutral); offline-vs-online断层 explicitly required (§3.1-§4, §4.3 final bullet). Internal validity (frozen package characterization) vs external validity (live delivery) correctly separated.
4. **Static-token method — SOUND.** §4.3 mandates chars/line-count + chars÷3.5–4 as "静态参考，不当作实际 API 计费依据," requires the thin-prompt-may-increase-dynamic-tokens dialectic (hallucination/retry/Gate-rework raising total tokens), which §3.1-§4 also requires — the AC2 dialectic the pack demands is present in both spec and method.
5. **ADAPTER_INELIGIBLE audit — SOUND.** §3.1 requires the full causal chain: `which oc-run` absence, refusal of `/home/box/pm/bin/oc-run.sh` (non-standard path, cross-project requisition, outside authorization) with reasons, refusal of bare `opencode run` (missing `--temperature/--seed/--prompt-file`, breaks control), Tier-1 env/symlink value. Fail-closed framed as success per ac-verification.md.

## AC-by-AC table

| AC | Verdict | Reason |
|----|---------|--------|
| AC0 honesty assertion | NEEDS-FIX (P0-2) | Content requirement sound; no presence check in §6 — unenforceable |
| AC1 offline package analysis | SOUND* | Complete (6 families, 12 cases H/V分表, 24 controls, oracles); content depth left to Layer 2 (*strengthen via P0-2 literals) |
| AC2 static dual-arm comparison | SOUND* | Volumes + token estimate + mandatory dialectic all specified; *same presence-check caveat |
| AC3 probe audit + boundary defense | SOUND | Both refusals with reasons required; probe fields pinned |
| AC4 zero currency | NEEDS-FIX (P1-1) | `$` false-FAIL trap; script-scope mismatch; vacuous pre-impl pass |
| AC5 architecture-retention verdict | NEEDS-FIX (P0-2) | Correct bounded verdict; no §6 presence check |
| AC6 reopening prerequisites | NEEDS-FIX (P0-2) | 5 conditions + fresh-authorization sound; no per-item presence check |
| AC7 zero production intrusion | NEEDS-FIX (P0-1) | Unsatisfiable as written — baseline tree already dirty under scoped paths |

## Verification-command dry-run notes (executed live on current repo)

| §6 step | Pre-impl result | Assessment |
|---------|----------------|------------|
| 1. `test -s analysis.md / decision.md` | Both exit 1 (files absent) | PASS-for-right-reason pre-impl; will pass post-impl. SOUND |
| 2. `! grep -riE …` on both md | `grep` exit 2 (missing file) → `!` → exit 0 | VACUOUS PASS pre-impl (P1-1c); post-impl risks `$` false-FAIL (P1-1a) |
| 3. `git status --porcelain` scoped paths | Non-empty (20+ pre-existing `M` under `.agents/`) | FAILS at baseline AND post-impl regardless of P3 work (P0-1). `.tad/config.yaml` pathspec itself is valid (file exists) |
| 4. `node experiments/thin-tad-pilot/verify-p3.mjs` | `ls` confirms script absent → exit 1 missing-file | Fails-cleanly-for-right-reason pre-impl. Path consistent with §3.1 + Epic; only §4.1 tree omits it (P2-1) |

## One-line verdict rationale

The design is methodologically honest and evidence-mapped, but ships two unsatisfiable/unenforceable gates (a baseline-dirty `git status` emptiness AC and honesty ACs with no presence checks) plus a self-trapping currency grep — fix P0-1/P0-2 and P1-1/P1-2/P1-3, then PASS.
