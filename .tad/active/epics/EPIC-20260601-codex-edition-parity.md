# Epic: Codex-Edition Parity Mechanism

**Epic ID**: EPIC-20260601-codex-edition-parity
**Created**: 2026-06-01
**Owner**: Alex
**Decision Record**: DR-20260601-codex-edition-parity-architecture.md (Architecture B)

---

## Objective
Make TAD's Codex-CLI edition (Codex Alex+Blake) reach and **permanently maintain** full
feature parity with the Claude Code source, via **automated regeneration** (architecture B)
plus a **release-time hard-block drift gate**. Solves both the current drift (Codex edition
is missing the deliverable track, pack-collision, research-engine, etc.) and the standing
"every future release keeps Codex in sync" guarantee — at ≤5 min near-zero per-release human cost.

## Success Criteria
- [ ] Codex Alex+Blake editions **semantically cover 100%** of Claude source protocol sections + constraint rules (deliverable track, pack-collision step4_5/5b, research-engine all present)
- [ ] Per-release human cost to keep Codex in sync is **≤5 min**
- [ ] Release is **hard-blocked** (minor+) when the Codex edition drifts from source; advisory on patch
- [ ] **Zero constraint loss**: all Preserve-NEVER-Delete items intact (grep guards pass; `AskUserQuestion`=0; MUST/MANDATORY/VIOLATION ≥10)
- [ ] Codex editions stay within size targets (Alex ≤100KB, Blake ≤40KB) and within proven injection ceiling
- [ ] The drift gate is **release-time only** (in `*publish`/release-runbook) — NOT a settings.json auto-hook (single-user-CLI lesson)

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Spike: prove regen + define parity criterion | ✅ Done | HANDOFF-20260601-codex-parity-phase1-spike.md | Validated regen procedure + mechanizable semantic-coverage criterion + B-viability verdict |
| 2 | Catch-up: regenerate Codex editions to v2.20.0 | ✅ Done | HANDOFF-20260601-codex-parity-phase2-catchup.md | codex-alex + codex-blake at full parity (SAFETY-preservation-verified) with current source |
| 3 | Hard-block gate: wire drift detection into release | 🔄 Active | HANDOFF-20260601-codex-parity-phase3-releasegate.md | Release-time parity gate (minor+ blocks) in release-runbook + `*publish` |

### Phase Dependencies
All sequential. P1 resolves the regen mechanism + parity criterion → P2 applies it to catch up
→ P3 wires the criterion as a release gate. P1 has an explicit pivot threshold (if regen can't
hit parity at ≤5min, pivot before P2).

### Derived Status
- **Status**: In Progress (P1 ✅, P2 ✅; P3 ⬚)
- **Progress**: 2 / 3

---

## Phase Details

### Phase 1: Spike — Prove Regeneration + Define Parity Criterion

**Status:** ✅ Done
**Execution:** Blake commit 1b74dec; Gate 4 ACCEPT 2026-06-01 (Alex raw-recompute verified AC4 exit 1/0, AC1-AC8 met)
**Completed:** 2026-06-01. Verdict: B mechanism viable — proceed to P2 with the 2 Gate-4 residual risks below.

#### Scope
Prove that an **LLM-driven regeneration** of `codex-alex-skill.md` (one SKILL, as the spike
target) from the current Claude `alex/SKILL.md`, applying `portable-rules.md`'s Strip→Replace
transform table + Preserve-NEVER-Delete list, produces a **faithful, guard-passing, size-compliant**
Codex edition at near-zero human cost. AND design the **mechanizable semantic-coverage parity
criterion** that Phase 3's gate will enforce. NOT in scope: regenerating Blake (P2), wiring any
release gate (P3), production-replacing the live Codex editions (spike output goes to a scratch
path).

#### Input
- `.claude/skills/alex/SKILL.md` (current source, 319KB)
- `.tad/portable-rules.md` (transform table + preserve list + size targets)
- `.tad/codex/codex-alex-skill.md` (current drifted edition, 35KB — the negative baseline)

#### Output
- A documented + once-executed **regeneration procedure/prompt** (reusable in P2/P3)
- A **parity-criterion spec**: defines "semantic coverage" concretely enough for a release gate
  (e.g., enumerate Claude top-level protocol sections + constraint-rule inventory → each must map
  to the Codex edition) + a prototype check
- A **prototype parity-check** (script or documented procedure) that FLAGS the old drifted edition and PASSES the regen
- **Spike report** with B-viability verdict + measured per-step human-time + explicit pivot decision; DR finalized

#### Acceptance Criteria
- [ ] AC1: Regenerate `codex-alex-skill.md` (to scratch path) via the documented procedure; output passes ALL grep guards (`grep -c AskUserQuestion`=0; `grep -coE 'MUST|MANDATORY|VIOLATION'`≥10) AND `wc -c` ≤102400 (100KB)
- [ ] AC2: Regen contains previously-missing protocol content (`grep -c 'deliverable'`≥5, `grep -c 'research_complexity'`≥1, `grep -ci 'step4_5\|Pack Awareness'`≥1) — proving the regen actually closes drift, not just re-emits the old snapshot
- [ ] AC3: Parity-criterion spec written + saved; defines the semantic-coverage check as a repeatable procedure (input: Claude SKILL + Codex edition; output: covered/missing section list)
- [ ] AC4: Prototype parity-check run twice: against the OLD drifted edition → correctly reports drift (missing sections incl. deliverable track); against the NEW regen → correctly reports parity. Both results pasted in spike report.
- [ ] AC5: Spike report records B-viability verdict + measured human-time on the ≤5min path + explicit pivot decision (proceed to P2 / pivot). DR-20260601 marked finalized.

#### Files Likely Affected
- `.tad/evidence/spikes/codex-parity/regen-procedure.md` (CREATE — the regen prompt/procedure)
- `.tad/evidence/spikes/codex-parity/parity-criterion.md` (CREATE — the semantic-coverage spec)
- `.tad/hooks/lib/codex-parity-check.sh` (CREATE — prototype, may graduate to P3)
- `.tad/evidence/spikes/codex-parity/codex-alex-skill.regen.md` (CREATE — scratch regen output)
- `.tad/evidence/spikes/codex-parity/spike-report.md` (CREATE)
- `.tad/decisions/DR-20260601-codex-edition-parity-architecture.md` (MODIFY — mark finalized)

#### Dependencies
None (entry phase). Pivot threshold: if regen cannot pass AC1+AC2 at ≤5min human input → STOP, reconvene architecture (do not auto-proceed to P2).

---

### Phase 2: Catch-up — Regenerate Codex Editions to v2.20.0

**Status:** ✅ Done
**Execution:** Blake commits 4881bc1+774ce53+fb43be2+638fd87+2d132c1; Gate 4 ACCEPT 2026-06-01 (Alex re-ran the 3 dogfood cases incl. compensation — gate exit 1 verified; per-owner trace 12/12 + 6/6; headless codex exec 175s<5min)
**Completed:** 2026-06-01. Both live editions at v2.20.0 parity; per-owner SAFETY gate proven compensation-resistant. P1 #1 constraint-fidelity risk RESOLVED.

#### Scope
Use the P1-validated regen procedure to regenerate **both** `codex-alex-skill.md` and
`codex-blake-skill.md` to full parity with the current v2.20.0 source, replacing the live
drifted editions. Verify with the parity criterion. NOT in scope: wiring the gate into the release
process (P3 — that's `release-runbook`/`*publish` integration, distinct from running the check here).

**Scope additions from P1 Gate-4 (user decisions 2026-06-01):**
- (a) **Pull P3's per-SAFETY-category check forward**: upgrade `parity-check.sh` Layer 2 from a global
  constraint floor to **per-category presence within the must-cover scope** (anti_rationalization_registry,
  forbidden_implementations, honest_partial, NOT_via_alex_auto anchor present in the kept region) — so
  P2's "parity PASS" actually guarantees SAFETY survival (the P1 floor did not).
- (b) **Close AC8 headless**: run at least one regen **headlessly** (`claude -p`/`codex exec`) and measure
  the recurring per-release human-touch time against the ≤5min threshold.
- (c) **Trace P1 condensation per-item**: enumerate the must-cover constraints lost in the P1 regen
  (forbidden_implementations 12→6 etc.), fix `regen-procedure.md` so SAFETY items survive verbatim.

#### Input
- P1 regen procedure + parity criterion + prototype check
- Current `.claude/skills/alex/SKILL.md` + `blake/SKILL.md`

#### Output
- `.tad/codex/codex-alex-skill.md` + `codex-blake-skill.md` regenerated, at full parity, committed

#### Acceptance Criteria
- [ ] AC1: `parity-check.sh` Layer 2 upgraded to **per-SAFETY-category presence** (must-cover scope): proves anti_rationalization_registry / forbidden_implementations / honest_partial / NOT_via_alex_auto present in the kept region — NOT a global count floor. Anti-theater: it must FAIL a regen with a must-cover SAFETY item deleted (dogfood with a deliberately-stripped copy).
- [ ] AC2: `codex-alex-skill.md` regenerated to live; upgraded parity check = PASS (all 3 layers incl. per-category SAFETY)
- [ ] AC3: `codex-blake-skill.md` regenerated to live; upgraded parity check = PASS (Blake's surface — Ralph-Loop/Agent rules preserved)
- [ ] AC4: Both pass grep guards (`AskUserQuestion`=0; constraints ≥ source-derived floor) and size targets (Alex ≤100KB, Blake ≤40KB)
- [ ] AC5: Per-item constraint-survival trace: enumerate the P1-condensation must-cover losses, confirm the P2 regen preserves them (paste before/after per-category counts); `regen-procedure.md` updated with the strip-not-summarize hardening that fixed it
- [ ] AC6: **Headless probe (closes P1 AC8)**: at least one regen run headlessly (`claude -p`/`codex exec`), recurring human-touch time measured vs ≤5min — result recorded (PASS/FAIL + number)
- [ ] AC7: Spot-verify ≥3 previously-missing elements now present **as real content** (not just keyword): deliverable/`task_type: deliverable` branch, pack-collision step4_5, research-engine effort-scaling — read the actual lines
- [ ] AC8: `bash .tad/codex/codex-tad-alex.sh --dry-run` and `codex-tad-blake.sh --dry-run` both pass (adapter launches with the new editions)

#### Files Likely Affected
- `.tad/codex/codex-alex-skill.md` (MODIFY — regenerate to live)
- `.tad/codex/codex-blake-skill.md` (MODIFY — regenerate to live)
- `.tad/hooks/lib/codex-parity-check.sh` (MODIFY — Layer 2 per-category upgrade)
- `.tad/evidence/spikes/codex-parity/regen-procedure.md` (MODIFY — strip-not-summarize hardening)

#### Dependencies
Phase 1 complete (regen procedure validated, parity criterion defined, allowlist authored).

---

### Phase 3: Hard-Block Gate — Wire Drift Detection Into Release

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Add a **release-time** parity gate: run the P1 parity check during `*publish` / release-runbook;
on drift, HARD-BLOCK minor+ releases (advisory on patch), with regeneration as the remediation
path. Document in README + portable-rules. NOT in scope: any settings.json/PreToolUse auto-hook
(forbidden — single-user-CLI lesson); the gate fires only at release.

#### Input
- P1 parity-check (graduated to a stable path) + P2 current-parity editions

#### Output
- Stable parity-check script (exit 0=parity / 1=drift) at a release-runbook-referenced path
- release-runbook "Codex Adapter" section updated with the hard-block parity gate + remediation
- `*publish` protocol (alex SKILL `publish_protocol`) references the parity gate as pre-publish blocking (minor+)
- README + portable-rules updated to describe the standing regen+gate mechanism

#### Acceptance Criteria
- [ ] AC1: parity-check script at a stable path with documented exit-code contract (0=parity, 1=drift→block, 2=advisory/NA)
- [ ] AC2: release-runbook "Codex Adapter" section updated: parity gate added, **minor+ = HARD block, patch = advisory**, remediation = "run regen then re-check"
- [ ] AC3: `*publish` `publish_protocol` references the parity gate as a pre-publish blocking step (minor+)
- [ ] AC4: **Anti-theater dogfood**: artificially drift the Codex edition (delete a section) → gate exits 1 / blocks; regenerate → gate exits 0 / passes. Both pasted in completion. (Proves the gate can actually FAIL.)
- [ ] AC5: **Single-user-CLI compliance**: gate is invoked only from `*publish`/release-runbook, NOT registered in `.claude/settings.json` and NOT a PreToolUse/SessionStart hook. Verify `grep -c 'parity' .claude/settings.json` = 0.

#### Files Likely Affected
- `.tad/hooks/lib/codex-parity-check.sh` (CREATE — graduated from P1 prototype)
- `.claude/skills/release-runbook/SKILL.md` (MODIFY — add parity gate to Codex Adapter section)
- `.claude/skills/alex/SKILL.md` (MODIFY — `publish_protocol` references gate)
- `.tad/codex/README.md` + `.tad/portable-rules.md` (MODIFY — document standing mechanism)

#### Dependencies
Phase 2 complete (editions at parity, so the gate's first run passes).

---

## Context for Next Phase

### After P1 (→ P2 / P3) — 2026-06-01
**Verdict: B mechanism viable.** Regen passed all 3 parity layers; parity-check.sh discriminates
(drifted live → exit 1, regen → exit 0, Alex-verified). Reusable: `regen-procedure.md`,
`parity-criterion.md`, `parity-check.sh`, the must-cover vs expected-absent allowlist (9 Conductor
protocols) in `portable-rules.md`.

**3 residual risks the catch-up/gate phases MUST address (not optional):**
1. **(P2 #1 risk — regen constraint fidelity)** The spike regen is 49KB with constraint-word count
   59 vs source 150. honest_partial 4→0 is LEGIT (all in stripped yolo); the cross_model AR-001
   anchor SURVIVED. BUT `forbidden_implementations` 12→6 / `anti_rationalization_registry` 6→3 mix
   legit-stripped losses with **possible must-cover losses** (express/experiment/cancel/step1c are
   NOT on the allowlist) — UNVERIFIED per-item. P2 MUST trace each must-cover constraint and tune
   `regen-procedure.md` so SAFETY preserve-list items survive verbatim (the "strip-not-summarize"
   rule needs teeth — the spike LLM condensed).
2. **(P3 — parity criterion gap)** The criterion's constraint layer uses a GLOBAL floor (passed at
   59). It does NOT detect loss of a must-cover SAFETY item — it would pass a regen that dropped a
   must-cover `forbidden_implementations`. P3's gate MUST add **per-SAFETY-category preservation**
   (anti_rationalization_registry / forbidden_implementations / honest_partial present in the
   must-cover set), not just a count floor.
3. **(P2 — headless reliability UNPROVEN)** AC8 honest fallback: the headless ≤5min regen was NOT
   run in the spike. P2 must execute a headless regen (claude -p / codex exec) and measure recurring
   cost to confirm the ≤5min standing guarantee. Also: marker list is hardcoded in the P1 prototype;
   P3 must implement the mechanical-extraction rule already documented in `parity-criterion.md`.
   And: P2 regen of **Blake** is unproven (different surface — Ralph-Loop/Agent-spawn dominated;
   Step 4b scan in spike report).

### After P2 (→ P3) — 2026-06-01
**P2 ACCEPTED.** Both live editions regenerated to v2.20.0 parity (codex-alex 46KB, codex-blake 29KB).
The per-must-cover-owner-body Layer-2 gate is built + **proven compensation-resistant** (Alex Gate-4
re-ran: delete express block + add surplus → still exit 1). P1's #1 constraint-fidelity risk RESOLVED
(per-owner trace 12/12 forbidden_implementations + 6/6 anti_rat, every owner source-body==codex-body).
Headless ≤5min PROVEN via `codex exec` (175s). P1 residual risks 1 & 2 now CLOSED.

**P3 inputs / carry-forwards (the gate logic is DONE — P3 is release-wiring + 3 small items):**
1. **Wire the existing gate into release**: `parity-check.sh` (per-owner, fail-CLOSED, pin-validated) is
   ready. P3 adds it to `release-runbook` "Codex Adapter" section + `*publish` `publish_protocol` as a
   **minor+ HARD block / patch advisory** pre-publish step. Plus the mechanical marker-extraction
   (already documented in parity-criterion.md; prototype was source-conditioned in P2) and the
   regen-procedure as the remediation path.
2. **Headless tool choice**: P3's release-time regen MUST use `codex exec --full-auto` (PASS 175s);
   `claude -p` FAILed on 326KB (produced analysis, not a raw file). Document this in the runbook.
3. **(small) Layer 2 audit reviewer-name drift** (recurring, architecture.md 2026-05-27): standardize
   Blake review filenames to canonical sub-agent names OR extend KNOWN_REVIEWERS in layer2-audit.sh.
   Not part of this Epic's core but surfaced again here — fold into P3 or a separate express fix.
4. **(small, P3-deferred) P1-2 awk header self-counting** in parity-check (Blake reviewer P1; pins
   calibrated, symmetric now) — finalize when wiring the gate.
5. **single-user-CLI**: P3 gate is release-time ONLY (in `*publish`/runbook), NEVER a settings.json
   PreToolUse/SessionStart hook (`grep -c parity .claude/settings.json` must stay 0).
