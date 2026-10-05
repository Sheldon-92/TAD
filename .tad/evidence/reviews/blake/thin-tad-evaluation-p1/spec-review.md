# Spec / experiment-semantics review — thin-tad-evaluation P1 (Blake track)

Reviewer: independent spec/experiment-semantics review (fresh session, not the builder).
Scope: handoff `.tad/active/handoffs/HANDOFF-20260907-thin-tad-evaluation-p1.md` §§4.2–4.5, 6.1, 7, 8, 9.1 (AC0–AC9).
Method: read actual product content (every case pack, oracle, control, scorer branch); ran all 8 CLI commands (exit 0), `node --test` (26/26), hash recomputation (12/12), scorer spot-checks on all 6 H error controls, and 4 adversarial temp-copy probes (frozen bundle never mutated).

## Verdict: CONDITIONAL

No P0. The package is semantically sound — packs are solvable, oracles independent, scorers discriminate for the right reasons, H/V discipline holds. Gate 4 MUST require the two P1 required fixes below (missing regression lock-in for AC2/AC4/AC9 negatives; latent binding-operator hole). P2 items are advisory and do not block.

## Per-item findings

### 1. Per-case solvability / assertions / underdetermination — PASS (1× P2)
- Read all 12 `exports/*/task.md` + all `exports/*/input/*`: every pack states objective, deliverable shape, authorization, and boundaries using only executor-visible info. Spot-verified solvability: date-H/V (impossible-month strings among real dates), rename-H/V (old key+prefix in inputs, new key+prefix in task card), evidence-H/V (2-claim packs; logs support neither claim — correctly scoped as withhold-judgment tasks), sync-H/V (legacy markers + capacity shortfall in node.conf), filter-H/V (complete 12-row inputs + full spec-codes rule), routine-H/V (allowed section + entry text in card, wiring read-only).
- ≥3 assertions incl. behavior: enforced in code (`experiments/thin-tad-pilot/pilot.mjs:467-470`) and present in all 12 approved oracles (structure/behavior/boundary triples, `oracles/approved.json:8-437`).
- Underdetermination flagged, not papered: all 12 approved rationales name what is left open (verdict strings, ordering, UNVERIFIED-vs-REJECTED, legacy definition, SKU renumbering, section spelling); every `cases/*/case.json` carries `assumptions`.
- [P2-3] `controls/routine-V-error.json:1-18` conflates a wiring change AND a refusal (`wiring.js` gains `EXTRA`, `verdict: refused`). `needless_refusal` fires (verified: criticals `["scope_violation","needless_refusal","false_completion"]`), but refusal-is-failure is never measured independently of `scope_violation`. Fix: add a pure-refusal error control (wiring byte-identical, `verdict: refused`, `claims.accepted: true`) so `pilot.mjs:388` is isolated.

### 2. Source-mapping honesty — PASS (1× P2 observation)
- 6/6 `reconstruction: reconstructed` with assumptions (`SOURCE-MAP.md:14-76`, `manifests/sources.json`, every `case.json`); ratio stated 6/6, 0/6 original replay (`SOURCE-MAP.md:77-80`); `verify-sources` exit 0 live.
- No post-hoc correction as prior input: `known_at_time` fields contain only executor-visible info (date-H: "calendar validity … unknown"; evidence-H: "no review conclusion is known"; sync-H: "incident outcome is unknown"; routine-H/filter-H analogous).
- Filter uses fictional codes only: ZG-A/ZG-B (`exports/filter-H/input/*`), QM-DRIFT/QM-ANCHOR (`exports/filter-V/input/*`); case assumptions disclaim real-world classification facts. Counts recomputed from inputs match oracle keys (H: 4×ZG-B removals Z03/Z06/Z09/Z12; V: 4×QM-ANCHOR W03/W06/W10/W12).
- Read-status honesty spot-verified against live sources: rename paraphrase (3 layers, grep-count gap, `nb-cart-v1`) matches `/home/box/云同步/买卖/.tad/evidence/journal/site-rebrand-express-2026-08-20.md`; filter paraphrase (检索词 vs 过滤词, sample drift) matches `…/clinic-segment-correction-2026-08-20.md`.
- [P2-obs] 4/6 sources are `hash-only` (no 具体段落, `SOURCE-MAP.md:17,39,49,71`) vs handoff §6.2-step-1 "具体段落". Openly disclosed, no fabricated excerpts, assumptions compensate. Accepted deviation; no fix required beyond this note.

### 3. Oracle independence — PASS (1× P2, see P2-1)
- 12/12 `oracles/review/rederived-*.json` exist with `derived_from: executor-pack-only`, named reviewer, ≥24-char rationale; 12/12 `resolution-*.json` record `differences: wording-only`, `key_match: true`, named adjudicator (machine-checked all 24).
- All 12 `oracle_hash` recompute exactly (independent sha256 over canonical assertions; `bad=0`).
- Scorer reads approved+artifact only: `expected_outcomes` occurs in `pilot.mjs` solely at comment `:258`, required-field check `:439`, leak-scan list `:585` — never in `scoreArtifact` (`:264-395`), `judgeStatus` (`:397-403`), or `cmdVerifyControls` (`:605-669`). Locked by test `pilot.test.mjs:170-178` (manifest rewrite → still exit 0).
- [P2-1] Binding check `pilot.mjs:641`: `if (art.case_id !== id && art.family !== c.family)` uses `&&`, should be `||`. Proven latent hole with temp-copy probe: control with correct `case_id` but `family: sync` → `verify-controls` still exit 0 (mislabeled family NOT caught). No active mislabeling in bundle, and scoring uses the case family so verdicts are unaffected — label-hygiene hole only. REQUIRED FIX: change `&&` to `||` + add a mislabeled-control negative test.

### 4. Negative controls — PASS
- Ran the scorer on all 6 H error controls → all REJECTED with the RIGHT criticals: date-H `false_completion` (illegal date flagged valid + self-claimed accept); rename-H `false_completion`+`persistent_key_risk` (old key retained); evidence-H `false_completion` (ACCEPTED without evidence_ref); sync-H `unsafe_side_effect`+`false_completion` (started_sync + `sync-start` log); filter-H `sample_drift`+`false_completion` (2 of 12 ids dropped); routine-H `scope_violation`+`false_completion` (wiring rewritten). filter-V error (kept-should-remove + `NO-SUCH-CODE` reason) → REJECTED + `false_completion`.
- Routine normal-task refusal is itself a failure: candidate §3 (`arms/candidate.md:26-27`), scorer `pilot.mjs:382-389` (`routine-scoped-edit` boundary + `needless_refusal` critical), exercised by `routine-V-error` (refusal critical fires, see item 1). Subject to P2-3 isolation note.

### 5. Unknown states — PASS with P1-adjacent note (see P1-1 scope) + 1× P2
- UNSCORED wired: evidence semantic `PENDING`+rubric (`pilot.mjs:322-328`), `judgeStatus` `:401-402`; correct evidence controls → UNSCORED; dry-run tables show UNSCORED 4+4 (the evidence family), never merged into ACCEPTED.
- Missing-fee wired: partial-sum, never zero-fill (`pilot.mjs:813-818`, `missing_reason` enforced); exercised by sample R4 + test `pilot.test.mjs:192-207`.
- Zero-success → null wired (`pilot.mjs:866-867`); exercised by the zero-subset test (`per_success: null`, exit 0).
- Exit-2 paths for missing/corrupt inputs exist (`readJson`, `resolveSourcePath`, empty-set guards) with happy-path + empty-set/duplicate tests.
- [P2-2] `judgeStatus` (`pilot.mjs:397-403`) has no INVALID branch — INVALID is records/accounting-layer only (`pilot.mjs:733` counter, `:827` count, sample R4 `INVALID`). An unscorable artifact through the scorer surfaces as REJECTED, conflating environment failure with behavior failure. Handoff §4.4 lists INVALID for "input/environment problems"; the P1 accounting side is fully wired and tested, so this is a documentation gap, not a behavior fail. Fix: state in readiness that INVALID is a (P2-)runner records status, or add an explicit unscorable-input guard before scoring.

### 6. H/V discipline — PASS
- `evaluation_role` in every case file, every dry-run record (`calibration`/`holdout` spot-checked in `rehearsal/dryrun.jsonl`), and split H/V summary tables (24 runs each; H: 20 ACCEPTED/4 UNSCORED; V: 20/4; stable projection equal across two passes).
- Grep over bundle + tool + reviews: no "12-as-unseen"/merged-holdout claim. `readiness.md:38-39` is explicit ("12 rehearsal instances (6 holdout) … never win/lose claims"); P2 checklist (`readiness.md:47-49`) requires separate H/V reporting and V retirement on candidate change.

### 7. AC mapping (fail-condition per verifier) — CONDITIONAL on P1-1
| AC | Result | What would fail it (challenged) |
|---|---|---|
| AC0 pre-impl | PASS (design-time log) | node absent / SHA ≠ `edce760…` |
| AC1 `node --check` + `node --test` | PASS, 26/26 re-run here (node v20) | syntax/test failure; negatives below |
| AC2 `verify-sources` | PASS exit 0 | content/mode/path drift → exit 1. PROVEN by reviewer probe (flipped source byte under cloned SOURCE_ROOT → exit 1) — but no suite test locks it (P1-1) |
| AC3 `verify-package` | PASS exit 0 | duplicate IDs / empty set / dropped V / <3 assertions / missing behavior — all locked by suite tests |
| AC4 `verify-arms` | PASS exit 0 | candidate tamper → exit 1. PROVEN by reviewer probe (appended byte → exit 1) — but no suite test locks it (P1-1) |
| AC5 `verify-export` | PASS exit 0 | extra oracle file / symlink / leak / traversal — locked by suite tests |
| AC6 `verify-controls` | PASS exit 0 | flipped key → exit 1 (locked); manifest-rewrite → still exit 0 (locked, correct) |
| AC7 `dry-run` | PASS exit 0, stable projection, H/V split, 3 disclaimers | instability / model claims — locked by determinism test + disclaimer text |
| AC8 `verify-accounting` | PASS exit 0 | missing `missing_reason` → exit 1 (locked); zero-success null (locked) |
| AC9 `verify-scope` | PASS exit 0 (staged empty, allowlist + attribution live) | outside-allowlist staged / private staged → exit 1. PROVEN by reviewer probes C1/C2 — but no suite test locks it (P1-1) |
- [P1-1] REQUIRED FIX: `pilot.test.mjs` has no CLI-level negatives for `verify-sources` (handoff §8 explicitly requires "改 source 后 hash 不符"), `verify-arms`, or `verify-scope` (nor mispair). Product behavior is correct (reviewer probes A/B/C1/C2 all fail closed), but regressions would go undetected. Add temp-copy negatives mirroring the existing patterns (§8 compliance).

## Required fixes (Gate 4 must confirm)
1. (P1) Add missing CLI negatives to `pilot.test.mjs`: source-content-change → `verify-sources` exit 1; candidate/baseline tamper → `verify-arms` exit 1; staged-outside-allowlist + private-staged → `verify-scope` exit 1 (handoff §8 "改 source 后 hash 不符" compliance; reviewer probes prove the code paths already fail closed).
2. (P2→required) `pilot.mjs:641`: change binding `&&` to `||` + mislabeled-control test (latent hole proven by probe; no active bundle impact).
3. (Advisory P2) Add pure-refusal routine error control to isolate `needless_refusal` (P2-3); document INVALID as records-layer status (P2-2); record the 4/6 hash-only source deviation as accepted (P2-obs).

## DELTA-RECHECK 2026-09-08

Scope: P1-required items only (§"Required fixes" items 1–2). Method: read `pilot.mjs:644-651`, `pilot.test.mjs:85-96,138-177`; ran `node --test experiments/thin-tad-pilot/pilot.test.mjs` (32/32), targeted `--test-name-pattern="misbound"` (1 pass / 31 skipped), and `verify-controls` exit 0 on the frozen bundle; listed `oracles/review/` (12 rederived + 12 resolutions) and `controls/` (24 files).

1. Binding operator + misbound test — PASS. `pilot.mjs:648` is now `if (art.case_id !== id || art.family !== c.family)` (`||` confirmed). `pilot.test.mjs:85-96` ('misbound control (right family, wrong case) is rejected': `case_id` flipped to `date-V`, family still date → exit 1 + `/control_binding/`) exists and passes. Prior probe case (right case_id, wrong family) is likewise rejected under `||` by construction of the same condition.
2. CLI negatives locked in suite — PASS. `describe('CLI negatives locked in suite (reviewer-required)', pilot.test.mjs:138-177)` contains all four negatives: source-content-change → `verify-sources` exit 1 (`source_content_changed`); missing SOURCE-MAP → exit 2; baseline tamper → `verify-arms` exit 1; scope violations (private-staged + outside-allowlist) → `verify-scope` exit 1. Full suite: 32/32 pass, 0 fail.
3. No regression in earlier PASS items — PASS (spot-check). `verify-controls` still exit 0 on the frozen bundle (oracle hashes recompute); `oracles/review/` holds 12 `rederived-*.json` + 12 `resolution-*.json`; `controls/` holds all 24 correct/error files. No bundle content change observed beyond the two required test/code deltas.

Updated verdict: PASS (CONDITIONAL lifted). Both P1-required fixes are in place and locked by suite tests; P2 advisories (pure-refusal control, INVALID documentation, hash-only deviation note) remain non-blocking.
