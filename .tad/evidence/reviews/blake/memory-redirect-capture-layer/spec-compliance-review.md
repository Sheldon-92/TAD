# Spec Compliance Review — HANDOFF-20260712-memory-redirect-capture-layer

**Reviewer:** spec-compliance-reviewer (independent sub-agent)
**Date:** 2026-07-12
**Scope:** Handoff §6 / §7 / §9.1 vs actual working-tree implementation. All AC scripts in
`.tad/evidence/acceptance-tests/TASK-20260712-001/` were RE-RUN live by this reviewer (not
trusted from Blake's claims), plus supplementary independent checks.

VERDICT: PASS

(NOT_SATISFIED = 0; PARTIALLY_SATISFIED = 2 ≤ 3; AC8 = N/A-Gate4)

---

## Per-AC Classification

| AC | Description | Classification | Evidence (re-run by reviewer) |
|----|-------------|----------------|-------------------------------|
| AC1 | settings.local.json +1 key only; permissions deep-equal | **SATISFIED** | Re-ran AC-01: PASS. `jq -S .permissions` diff vs before-snapshot empty; `autoMemoryDirectory=/Users/sheldonzhao/01-on progress programs/TAD/.tad/memory` (absolute, ends `.tad/memory`). Before-snapshot exists at `.tad/evidence/ralph-loops/TASK-20260712-001-ac1-permissions-before.json`. |
| AC2 | Content-level complete migration; old dir untouched (36) | **SATISFIED** | Re-ran AC-02: PASS. `diff -rq` old→target: 0 "Only in <old>" lines; old dir count = 36. Correct direction-scoped diff (not a count floor), per SEC P1-1 resolution. |
| AC3 | SAFETY end-to-end: memory in BOTH deny-lists + drift gate + sync-set exclusion | **SATISFIED** | Re-ran AC-03: PASS (lib=1, tadsh=1, `tad.sh --verify-denylist` exit 0, `--dirs | grep -cx memory`=0). Verified diffs directly: `derive-sync-set.sh` ZERO_TOUCH +memory with count comments updated 10→11 / 15→16; `tad.sh` TAD_ZERO_TOUCH +memory (no separate count comment exists near it — "如有" satisfied). All four assertions hold, including the load-bearing exclusion assertion. |
| AC4 | Distillation protocol purely additive | **SATISFIED** | Re-ran AC-04: PASS (comm deletions=0, `^## Step`=7, `^## Second Capture Source`=1). Diff confirms the new section is inserted immediately before `## Anti-Theater`, content matches handoff T4 text verbatim incl. the explicit `[ -f cursor ]` first-run branch (CR P1-1). alex/SKILL.md body untouched (not in diff). |
| AC5 | CLAUDE.md §7.5 + runbook gotcha both additive | **SATISFIED** | Re-ran AC-05: PASS (claude=1, runbook=1, comm deletion-side 0/0). CLAUDE.md gains only §7.5 block; runbook SKILL.md gains only gotcha #12 (covers double-list + pre-publish re-scan + downstream opt-in, matching T5b). |
| AC6 | .agents parity PASS | **PARTIALLY_SATISFIED** | Both handoff-scope mirrors verified byte-identical by `cmp` (distillation-loop-protocol.md + release-runbook/SKILL.md — the latter sanctioned by T6 "若 runbook 也有镜像一并同步"). Global `release-verify.sh parity` exits 1, but the drift is `mobile-testing/SKILL.md` etc. — a CONCURRENT terminal's mobile-*/hw-* pack build, outside this handoff. Honest call: the AC as WRITTEN ("parity PASS/0 drift") does not pass globally, so this cannot be marked fully SATISFIED; the handoff's intent (this change introduced zero drift) IS met. **Required follow-up: global parity must be re-run and PASS before *publish, after the concurrent workstream lands.** |
| AC7 | Script robust + idempotent + revert round-trip | **SATISFIED** | Re-ran AC-07 live: PASS. `bash -n` clean; `--status` exit 0; 2nd `--enable` idempotent (AC1+AC2 re-pass after); `--revert` removes key with permissions unchanged; re-enabled after test. Script matches T1 pseudocode incl. SLUG preflight (SEC P1-3), quoted expansions for the space-containing path, no hooks registered. |
| AC8 | Live redirect + negative detection (old dir stays 36) | **N/A-Gate4** | Declared Gate-4 human-verified in the handoff (requires a NEW session + trust dialog — cannot be machine-verified by this reviewer). T8 rollback path exists (`--revert`, tested via AC7) if falsified. Old-dir count currently 36 (consistent). |
| AC9 | Change scope maps 1:1 to §7 table | **PARTIALLY_SATISFIED** | All handoff-produced changes map to §7 (see mapping below); no unmapped handoff-produced file found. BUT the commit (T7) has not yet been made, so the discriminative check is prospective, and two hazards must be handled at commit time: (1) **the git index ALREADY contains two staged out-of-scope entries from another workstream** (`M .tad/hooks/post-write-sync.sh`, `A .tad/tests/detect-state-fixture.sh`) — a plain `git commit` after `git add <scope>` would sweep them in and violate AC9; Blake must unstage them or commit with an explicit pathspec. (2) `.gitignore` contains one addition beyond the T3b sensitive-isolation section: `.agents/skills/local/` mirror-protection rule — additive, defensible as a T6 `parity --fix` wholesale-rsync safeguard, but it is scope-plus vs §6/§7 and should be named in the COMPLETION report. Pre-existing dirty files (brain-index, OBJECTIVES, NEXT, SURPLUS-*, hw-*/mobile-*) are other workstreams and correctly excluded from Blake's staging plan. |
| AC10 | Sensitive isolation (SEC P0-1) | **SATISFIED** | Re-ran AC-10: PASS (36 report rows; all 7 SENSITIVE files `git check-ignore` = 0; 0 `user_*` tracked). Note: the script's tracked-file credential grep is currently VACUOUS (`git ls-files .tad/memory` = 0 — nothing staged yet). Reviewer ran a NON-vacuous direct scan of all 29 non-ignored files: 0 credential/email-pattern hits. Report quality is high: per-file frontmatter type + class + reason, mechanical-scan hits individually adjudicated as false positives, email-specific sweep documented, MEMORY.md itself conservatively classed SENSITIVE (index embeds user-profile/seed/leaked-source hooks) — beyond the minimum, consistent with 宁多勿漏. **AC-10 should be re-run after `git add` so the tracked-file assertion is exercised non-vacuously.** |

---

## §6 Execution-Order & Completeness Audit

- **T2 BEFORE T3 (SAFETY ordering)**: HONORED. Artifact mtimes: `derive-sync-set.sh` (…748) < `tad.sh` (…749) < `memory-redirect.sh` (…788) < `.tad/memory/` (…813) < sensitivity report (…968). Deny-lists were in place before any memory data entered the repo — no exposure window. Task ledger agrees (T2 completed first).
- **T2d**: other flag consumers (release-verify.sh / migration-engine.sh / migration-draft.sh) correctly NOT modified (absent from diff) — single source of truth via `--zero-touch` flag.
- **T1**: script matches pseudocode; SLUG derivation empirically correct (old dir found with 36 files).
- **T3a report quality**: GOOD (see AC10 row). 36/36 rows, reasons specific, false positives inspected rather than rubber-stamped.
- **T3b/T3c**: gitignore per-file SENSITIVE entries + `user_*` pattern present; check-ignore verified.
- **T3d**: commit-not-push respected — nothing committed yet (T7 in progress).
- **T4 additive guardrail**: verified by line-set comm (0 deletions) + anchors (7 Steps, Anti-Theater intact).
- **T5a/T5b**: both done, additive.
- **T6**: both mirrors byte-identical; `.agents` diff contains ONLY the two handoff mirrors.
- **T7**: pending (this review is a pre-commit input to it). See AC9 staged-rider hazard.
- **T8**: rollback path implemented and live-tested (AC7 revert round-trip).
- **Nothing in §6 found skipped.**

## AC9 Mapping Detail (handoff-produced changes → §7)

| Change | §7 row |
|---|---|
| `.tad/hooks/lib/derive-sync-set.sh` (M) | T2a |
| `tad.sh` (M) | T2b |
| `.tad/hooks/lib/memory-redirect.sh` (??) | T1 |
| `.claude/settings.local.json` (gitignored, +1 key) | T3 |
| `.tad/memory/` 36 files (??, 29 trackable / 7 ignored) | T3 |
| `.gitignore` (M) | T3b (+1 scope-plus line, see AC9 note) |
| `.tad/evidence/memory-migration-sensitivity-report.md` (??) | T3a |
| `.claude/skills/alex/references/distillation-loop-protocol.md` (M) | T4 |
| `CLAUDE.md` (M) | T5a |
| `.claude/skills/release-runbook/SKILL.md` (M) | T5b |
| `.agents/skills/alex/references/distillation-loop-protocol.md` (M) | T6 |
| `.agents/skills/release-runbook/SKILL.md` (M) | T6 (sanctioned in §6 text) |
| AC scripts + ralph-loop snapshots + handoff-review files (??) | Required Evidence Manifest |

## Action Items for Blake (before/at T7 commit)

1. **P1**: Unstage or pathspec-exclude the pre-staged `post-write-sync.sh` + `detect-state-fixture.sh` before committing (AC9 rider hazard).
2. **P2**: Re-run AC-10 after `git add` so the tracked-file credential grep is non-vacuous.
3. **P2**: Record in COMPLETION: (a) global parity FAIL is external (mobile-* concurrent build) — re-run before *publish; (b) the `.agents/skills/local/` gitignore addition and its rationale.
