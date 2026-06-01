---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
gate3_verdict: pass
gate4_delta:
  - field: "regen constraint fidelity (AC1 floor passed, but condensation)"
    alex_said: "regen preserves NEVER-Delete constraints (floor ≥10)"
    actual: "regen=49KB, MUST|MANDATORY|VIOLATION 59 vs source 150. honest_partial 4→0 is LEGIT (all in stripped yolo); cross_model_awareness AR-001 anchor SURVIVED; but forbidden_implementations 12→6 / anti_rat 6→3 mix legit-stripped with possible must-cover loss (express/experiment/cancel/step1c NOT on allowlist) — unverified per-item."
    caught_by: "Alex Gate 4 raw recompute (constraint-count diff regen vs source)"
  - field: "parity criterion constraint layer (AC3 deliverable)"
    alex_said: "3-layer criterion detects drift"
    actual: "Layer-2 constraint check uses a GLOBAL floor (passed at 59) — it does NOT detect loss of a must-cover SAFETY item (it would pass a regen that dropped a must-cover forbidden_implementations). Real gap in the P1 criterion; P3 gate must add per-SAFETY-category preservation check, not just a count floor."
    caught_by: "Alex Gate 4 (traced honest_partial/forbidden_impl losses vs the floor-only layer)"
git_tracked_dirs:
  - .tad/codex/
  - .tad/evidence/spikes/codex-parity/
  - .tad/decisions/
---

# HANDOFF: Codex-Edition Parity — Phase 1 (Spike)

**Epic:** EPIC-20260601-codex-edition-parity.md (Phase 1/3)
**Decision Record:** DR-20260601-codex-edition-parity-architecture.md (Architecture B)
**Priority:** P2
**Type:** Spike (Light TAD — mechanism de-risk, time-boxed, produces a decision + reusable procedure)
**From:** Alex (Terminal 1)
**Status:** Expert Review Complete — Ready for Implementation

---

## 1. Task Overview

Prove that the **automated regeneration** approach (architecture B) actually works: regenerate
`codex-alex-skill.md` from the current Claude `alex/SKILL.md` by applying `portable-rules.md`'s
transform table + Preserve-NEVER-Delete list, to a **scratch path** (do NOT touch the live
edition), and prove the result (a) passes all guards, (b) is size-compliant, (c) **closes the
current drift** (contains the protocol content the live edition is missing). In the same spike,
**design the mechanizable semantic-coverage parity criterion** that Phase 3's release gate will
enforce, and build a **prototype parity-check** that correctly flags the drifted edition and
passes the regen. Output a spike report with the B-viability verdict.

**This is the de-risk gate for the whole Epic.** If regen can't hit parity at ≤5 min human cost,
we STOP and reconvene architecture (explicit pivot threshold) — do NOT proceed to P2.

---

## 2. Background Context

The Codex-CLI edition (`.tad/codex/codex-alex-skill.md` / `codex-blake-skill.md`) lets Codex
users run the full Alex+Blake TAD methodology. **It has drifted.** Hard evidence (grounded
2026-06-01):

- `codex-alex-skill.md` header literally says `Generated: 2026-05-04` — the content was last
  regenerated **a month ago**; the release process only bumps the `TAD vX.Y.Z` version string
  (release-runbook items 15-18) + runs a presence/dry-run smoke test. Content is frozen.
- Drift probe: in `codex-alex-skill.md`, `grep -c 'deliverable'` = **0**, `grep -c 'research_complexity'`
  = **0**, `grep -ci 'step4_5|Pack Awareness'` = **0**. The entire non-dev `deliverable` track,
  pack-collision `step4_5` wiring, and research-engine effort-scaling are **absent**.

Enabling fact: `.tad/portable-rules.md` already **codifies the strip** — a Strip→Replace transform
table (`AskUserQuestion`→numbered text, `Agent`→sequential `codex exec`, hooks→manual bash, …) +
a Preserve-NEVER-Delete inventory (all MUST/VIOLATION, `anti_rationalization_registry` byte-exact,
`forbidden_implementations`, all protocol logic) + size targets (Alex ≤100KB, Blake ≤40KB). So
regeneration is rule-driven, not blind deletion. Architecture B + spike-first chosen in DR-20260601
(A rejected: violates ≤5min; C rejected: full Alex SKILL is 319KB / 82 AskUserQuestion sites — 4×
the proven 76KB injection ceiling).

---

## 3. Requirements

1. Regenerate `codex-alex-skill.md` from current source to a **scratch path** using a documented,
   reusable procedure (the procedure is itself a deliverable — it will run at release time in P3).
2. The regen must pass all existing guards AND demonstrably close the drift (contain the missing tracks).
3. Define a **mechanizable semantic-coverage parity criterion** (input: Claude SKILL + Codex edition
   → output: covered/missing protocol-section + constraint list) and build a **prototype check** for it.
4. The prototype check must correctly **flag the live drifted edition** and **pass the regen** —
   proving it discriminates (anti-validation-theater).
5. Produce a spike report: B-viability verdict + measured human-time on the ≤5min path + explicit
   pivot decision (proceed to P2 / pivot).

**NOT in scope:** regenerating Blake (P2), replacing the live editions (P2), wiring any release
gate (P3). The live `.tad/codex/codex-alex-skill.md` MUST remain untouched — spike output goes to
`.regen.md` scratch.

---

## 4. Technical Design

**Regen mechanism (architecture B):** an LLM agent reads the full `alex/SKILL.md` + `portable-rules.md`,
applies the Strip→Replace table and the Preserve-NEVER-Delete list, and emits the Codex edition.
This is inherently LLM-driven (a pure sed/script can't do semantic stripping — that is why the
edition was manual). The spike validates this for codex-alex and **captures the exact procedure/prompt**
so that in P3 it can be invoked headlessly (`claude -p` / `codex exec`) as the ≤5min release step.

**Parity criterion (the gate's judgment, to be designed here):** pragmatic, mechanizable layers —
1. **Section coverage**: enumerate Claude source's top-level protocol units (the `*_protocol:` YAML
   keys + named `##`/`###` protocol sections). ⚠️ (CR P0-2) Source has **30** `*_protocol:` keys, live
   edition has **14** — the gap includes Conductor/automation protocols (dream/evolve/optimize/yolo/
   sync/publish) that are *legitimately* stripped on Codex. So the section layer MUST split the source
   sections into two sets, both authored in `portable-rules.md` (see Step 2b): a **must-cover** set
   (every section a Codex user actually runs) and an **expected-absent allowlist** (Conductor/automation
   protocols + CC-only). Parity requires: every must-cover section present, AND every "missing" section
   is on the allowlist (an off-allowlist missing section = drift). Renamed/merged sections use an
   explicit, minimized mapping table (ARCH P1-2 — keep it tiny; owner = whoever edits portable-rules).
2. **Constraint coverage**: the Preserve-NEVER-Delete categories must each be present — guard counts
   (`AskUserQuestion`=0; `MUST|MANDATORY|VIOLATION` ≥ a **source-derived floor**, NOT a magic 10:
   floor = a fraction of the live source's own count, re-derived at gate time) + `anti_rationalization_registry`
   present + `forbidden_implementations` present.
3. **Capability-marker coverage**: ⚠️ (ARCH P1-1, load-bearing) the marker list MUST be **mechanically
   extracted from the CURRENT source at gate time**, NOT a hand-curated constant. A frozen constant
   would pass *future* drift (a new track added to Claude but not Codex) — the exact failure the
   standing guarantee exists to prevent. Define the extraction rule (e.g. derive feature tokens from
   source `task_type:` enum values + top-level `*_protocol:`/`### Phase` markers introduced since the
   last edition `Generated:` date). Each extracted marker must appear in the Codex edition.

**Exit-code contract (pinned identically for P1 prototype AND the P3 gate — ARCH P1-3):**
`0`=parity, `1`=drift (off-allowlist missing / marker absent / guard fail), `2`=usage error.
Parse errors are a DISTINCT path from `2`. ⚠️ (ARCH P1-4) In the **P1 prototype** a parse error may
fail-open with a WARN (it's a scratch tool). The **P3 release gate MUST fail-CLOSED** on parse error
(a release-time hard-block that fails-open silently ships drift) — this handoff pins the contract;
P3's AC enforces fail-closed. "Semantic" correspondence not reducible to the 3 layers is *reported*
for human spot-check, never silently passed. Phase 3 hardens; Phase 1 needs a working, discriminating
first cut.

---

## 6. Implementation Steps

### Step 1 — Set up spike workspace
- `mkdir -p .tad/evidence/spikes/codex-parity/`

### Step 2 — Author the regen procedure (reusable)
- Write `.tad/evidence/spikes/codex-parity/regen-procedure.md`: a step-by-step + the literal
  agent prompt that, given `alex/SKILL.md` + `portable-rules.md`, produces a Codex edition.
  Must explicitly instruct: apply every Strip→Replace row; preserve every NEVER-Delete category
  verbatim; keep the `<!-- Codex-edition ... Generated: {date} -->` header (update date); target ≤100KB.
- ⚠️ (CR P1-3, load-bearing) The prompt MUST state the transform is **line-local strip/replace, NOT
  summarization/paraphrase** — the failure mode is the LLM silently condensing protocol prose,
  dropping constraint lines and lowering the guard counts. Include a **post-emit self-check** in the
  procedure: re-run the guard counts on the output; a regen under **~25KB is a truncation tell**, not
  success (live edition is 35KB) → reject and re-run.

### Step 2b — Close the portable-rules gap (CR P0-2)
- `portable-rules.md` currently names neither a "strip whole protocol" row nor an expected-absent
  allowlist, so the 16 Conductor/automation protocols absent from Codex have no rule. Add to
  `portable-rules.md`:
  - a **Strip→Replace row** "whole Conductor/automation protocol → omit from Codex edition" (or keep a
    one-line stub pointer), and
  - an **Expected-Absent-in-Codex allowlist** enumerating those protocol sections (dream/evolve/optimize/
    yolo/sync/publish/… — derive the exact list by diffing source `*_protocol:` keys vs what a Codex user
    can actually run; a Conductor-only/Claude-tool-only protocol is expected-absent).
  This is what lets Step 4's section layer pick a correct threshold (must-cover present + every missing
  section on the allowlist). Record the must-cover vs allowlist split in `parity-criterion.md`.

### Step 3 — Execute the regen once (codex-alex → scratch)
- Following regen-procedure.md, regenerate to `.tad/evidence/spikes/codex-parity/codex-alex-skill.regen.md`.
- This is the LLM transform: read current `alex/SKILL.md` (~326KB) + `portable-rules.md`, emit the
  stripped+current Codex edition. Record wall-clock + human-touch time **(authoring cost — kept separate
  from Step 3b recurring cost)**.

### Step 3b — Headless reliability probe (ARCH P0-1 — proves *reliability*, not just feasibility)
- The whole Epic's standing value depends on regen being **reliable + headless + ≤5min at RELEASE time**,
  not just doable once under supervision. So after the procedure is frozen (Step 2), run it **once
  headlessly** from the frozen prompt (e.g. `claude -p "$(cat regen-procedure.md)"` or `codex exec`),
  with no interactive correction, to a second scratch file `codex-alex-skill.regen2.md`.
- Run the parity-check on regen2; record PASS/FAIL + the **recurring per-release human-touch time**
  (this — not the Step 3 authoring time — is what the ≤5min pivot threshold gates on).
- If a headless run is infeasible within the spike (tooling/quota): do NOT fake it — Step 6 verdict is
  honestly downgraded to "feasible; headless reliability UNPROVEN" and carried as an explicit **P2
  residual risk**, and the pivot decision notes it.

### Step 4 — Design + build the parity criterion check
- Write `.tad/evidence/spikes/codex-parity/parity-criterion.md` (the spec, per §4 — must-cover vs
  expected-absent split from Step 2b; mechanical marker-extraction rule; the pinned exit-code contract).
- Write `.tad/evidence/spikes/codex-parity/parity-check.sh`:
  - Args: `<claude_skill> <codex_edition>`. Exit per the §4 pinned contract (0=parity, 1=drift, 2=usage;
    parse-error is a distinct path — **P1 prototype fail-open WARN; this scoping MUST NOT carry to P3**).
  - Implements the 3 coverage layers; prints a `COVERED:`/`MISSING:` report **per layer** (so AC4 can
    assert each layer fired, not just an aggregate verdict — CR P1-1).
  - Marker list is **extracted from the source argument at run time** (ARCH P1-1), never a hardcoded list.
  - BSD/macOS-safe (no `grep -P`); `LC_ALL=C` on any sort/comm over CJK-capable text.

### Step 4b — Blake transform-surface scan (ARCH P0-2 — feed P2, don't claim generalization)
- Quick scan of `blake/SKILL.md` for its transform surface so P2 isn't blind: count `AskUserQuestion`
  (≈3), `Agent`/sub-agent spawn sites, Ralph-Loop blocks, hook references. Record in spike report under
  "P2 Blake residual risk". The spike does NOT claim the alex regen proves Blake works — Blake is
  genuinely different (Ralph-Loop + Agent-spawn dominated) and is carried as an explicit P2 risk.

### Step 5 — Prove discrimination (anti-theater)
- Run `parity-check.sh .claude/skills/alex/SKILL.md .tad/codex/codex-alex-skill.md` (the LIVE drifted
  edition) → must report MISSING incl. the deliverable track → exit 1.
- Run `parity-check.sh .claude/skills/alex/SKILL.md .tad/evidence/spikes/codex-parity/codex-alex-skill.regen.md`
  (the regen) → must report parity → exit 0.
- Paste both runs into the spike report.

### Step 6 — Spike report + verdict
- Write `.tad/evidence/spikes/codex-parity/spike-report.md`: B-viability verdict, measured human-time
  vs the ≤5min target, the two parity-check runs, and the explicit pivot decision (proceed to P2 / pivot).
- Edit `DR-20260601-...md`: append a line under Status — "Phase 1 spike finalized {date}: B viable —
  proceed to P2" (or the pivot outcome).

### Step 7 — Layer 1 self-check + completion report
- Run the guard + drift + size dry-runs (see §9.1) on the regen; paste results.
- Write COMPLETION report.

---

## 7. File Structure

**Files to Create:**
- `.tad/evidence/spikes/codex-parity/regen-procedure.md` (CREATE)
- `.tad/evidence/spikes/codex-parity/codex-alex-skill.regen.md` (CREATE — scratch regen, Step 3 supervised)
- `.tad/evidence/spikes/codex-parity/codex-alex-skill.regen2.md` (CREATE — scratch regen, Step 3b headless)
- `.tad/evidence/spikes/codex-parity/parity-criterion.md` (CREATE)
- `.tad/evidence/spikes/codex-parity/parity-check.sh` (CREATE)
- `.tad/evidence/spikes/codex-parity/spike-report.md` (CREATE)

**Files to Modify:**
- `.tad/portable-rules.md` (MODIFY — add strip-whole-protocol row + Expected-Absent-in-Codex allowlist, Step 2b / CR P0-2)
- `.tad/decisions/DR-20260601-codex-edition-parity-architecture.md` (MODIFY — append spike-finalized line)

**MUST NOT touch:** `.tad/codex/codex-alex-skill.md` (live edition — P2 replaces it, not P1).

**Grounded Against** (Alex step1c actually Read):
- `.tad/codex/codex-alex-skill.md` (head 50, read 2026-06-01 — header `Generated: 2026-05-04`, guards intact)
- `.tad/codex/codex-tad-alex.sh` (head 30, read 2026-06-01 — `--dry-run`/`--extract-only`, SKILL_FILE path)
- `.tad/portable-rules.md` (full, read 2026-06-01 — transform table + preserve list + size targets)
- `.tad/templates/handoff-a-to-b.md` (section numbering, read 2026-06-01)

---

## 8. Testing Requirements

No unit tests (spike). Verification is the §9.1 dry-runs + the discrimination proof (Step 5).
`parity-check.sh` must be tested by the two opposing inputs (drifted → fail, regen → pass).

---

## 9. Acceptance Criteria

- [ ] AC1: Regen passes ALL guards + size (run the RUNNABLE FORMS in §9.1, bare-pipe): `grep -c AskUserQuestion <regen>`=0; `grep -coE 'MUST|MANDATORY|VIOLATION' <regen>`≥ source-derived floor (≥10 absolute minimum); `wc -c < <regen>`≤102400 AND ≥25600 (sub-25KB = truncation tell, CR P1-3)
- [ ] AC2: Regen closes drift (real content, not the old snapshot): `grep -c 'deliverable' <regen>`≥5; `grep -c 'task_type: deliverable' <regen>`≥1; `grep -c 'research_complexity' <regen>`≥1; `grep -ci 'step4_5\|Pack Awareness' <regen>`≥1
- [ ] AC3: `parity-criterion.md` exists, defines the 3-layer check as a repeatable procedure, AND documents the **must-cover vs expected-absent allowlist split** (CR P0-2) + the **mechanical marker-extraction rule** (ARCH P1-1) + the **pinned exit-code contract** (ARCH P1-3)
- [ ] AC4: `parity-check.sh` discriminates **per layer**: on the LIVE drifted edition exit 1 AND the per-layer report names ≥1 missing must-cover section + the absent deliverable marker (not just an aggregate fail); on the regen exit 0 with all 3 layers reporting covered — both full runs pasted in spike report
- [ ] AC5: `spike-report.md` records B-viability verdict + **separated** Step-3 authoring time vs Step-3b recurring headless time vs the ≤5min threshold + explicit boolean pivot decision (PASS/FAIL + the measured number); DR-20260601 appended with the finalized line
- [ ] AC6: Live `.tad/codex/` dir is byte-unchanged (spike touched only scratch): `git status --porcelain .tad/codex/` empty
- [ ] AC7: `portable-rules.md` gains the strip-whole-protocol row + Expected-Absent-in-Codex allowlist (CR P0-2): `grep -ci 'expected-absent\|expected absent' .tad/portable-rules.md`≥1
- [ ] AC8: Headless reliability probe (Step 3b) ran — regen2 produced headlessly + parity-check result recorded; OR, if infeasible, spike report honestly states "headless reliability UNPROVEN — P2 residual risk" (ARCH P0-1). Faking a headless run that did not occur = VIOLATION.

### 9.1 Spec Compliance Checklist

⚠️ **PIPE-ESCAPE CONTRACT (CR P0-1 — read before running any row):** markdown table cells below
escape `|` as `\|` ONLY so the table renders. **The commands you actually RUN are in the RUNNABLE
FORMS block under the table — use those (bare `|`).** In `grep -E`/`-coE` (ERE) a `\|` is a *literal
pipe*, not alternation, and returns the wrong count. The ONE exception is AC2-step45 which uses
`grep -ci` (BRE, no `-E`) where `\|` IS the correct alternation — that row keeps `\|` in BOTH the cell
and the runnable form. Do not unify the two.

| AC | Verification Command (table-escaped — see RUNNABLE FORMS) | Expected | Verified Output (Alex step1d) |
|----|----------------------------------|----------|-------------------------------|
| AC1-guard | `grep -c AskUserQuestion <regen>` | `0` | post-impl (regen not yet created); cmd valid — same form returns 0 on live edition |
| AC1-constraint | `grep -coE 'MUST\|MANDATORY\|VIOLATION' <regen>` (ERE — RUN with bare `|`) | `≥10` | post-impl; bare-pipe form returns `54` on live edition (baseline). The `\|` shown here is table-escaping only. |
| AC1-size | `wc -c < <regen>` | `≤102400` & `≥25600` | post-impl; cmd valid — live edition = `35849` bytes |
| AC2-deliverable | `grep -c 'deliverable' <regen>` | `≥5` | post-impl; baseline live = `0` (proves drift) |
| AC2-research | `grep -c 'research_complexity' <regen>` | `≥1` | post-impl; baseline live = `0` |
| AC2-step45 | `grep -ci 'step4_5\|Pack Awareness' <regen>` (BRE — `\|` correct, RUN as-is) | `≥1` | post-impl; baseline live = `0` |
| AC4-drift | `bash parity-check.sh .claude/skills/alex/SKILL.md .tad/codex/codex-alex-skill.md; echo $?` | `1` | post-impl (script not yet built) |
| AC4-parity | `bash parity-check.sh .claude/skills/alex/SKILL.md <regen>; echo $?` | `0` | post-impl |
| AC6 | `git status --porcelain .tad/codex/` | empty | pre-impl PASS — currently empty (live untouched) |

**RUNNABLE FORMS (copy THESE — bare pipe for ERE; `<regen>` = the scratch regen path):**
```bash
grep -c AskUserQuestion <regen>                          # AC1-guard → 0
grep -coE 'MUST|MANDATORY|VIOLATION' <regen>             # AC1-constraint → ≥10 (ERE: bare pipe)
wc -c < <regen>                                          # AC1-size → ≤102400 and ≥25600
grep -c 'deliverable' <regen>                            # AC2-deliverable → ≥5
grep -c 'task_type: deliverable' <regen>                 # AC2 routing anchor → ≥1
grep -c 'research_complexity' <regen>                    # AC2-research → ≥1
grep -ci 'step4_5\|Pack Awareness' <regen>               # AC2-step45 → ≥1 (BRE: \| is correct here)
git status --porcelain .tad/codex/                       # AC6 → empty
```

**AC Dry-Run Log** (Alex step1d, 2026-06-01 — run on LIVE edition as baseline):
- AC1-guard: ✅ `grep -c AskUserQuestion` on live = `0`.
- AC1-constraint: ✅ **bare-pipe** `grep -coE 'MUST|MANDATORY|VIOLATION'` on live = `54`. (The `\|` ERE form returns `0` — that bug is the reason for the RUNNABLE FORMS block.)
- AC1-size: ✅ `wc -c` on live = `35849` (within 25600–102400).
- AC2 (deliverable/research/step45): ✅ on live = `0 / 0 / 0`, confirming the drift the regen must close.
- AC4 (2 rows): post-impl — `parity-check.sh` is a deliverable of this handoff; syntax validated by Blake at Gate 3.
- AC6: ✅ pre-impl PASS — `git status --porcelain .tad/codex/` currently empty.

### 9.2 Expert Review Status

Reviewed by **code-reviewer** + **backend-architect** (2 distinct, parallel). Both: CONDITIONAL PASS.
Raw reviews: `.tad/evidence/reviews/alex/codex-parity-phase1-spike/{code-reviewer,backend-architect}.md`.

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P0-1: `\|`-in-ERE literal-pipe → AC1-constraint false-fails | §9.1 PIPE-ESCAPE CONTRACT + RUNNABLE FORMS block | Resolved |
| code-reviewer | P0-2: portable-rules silent on 16/30 protocols → criterion threshold undefined | §6 Step 2b + §4 must-cover/allowlist split + AC7 | Resolved |
| backend-architect | P0-1: n=1 proves feasibility not reliability | §6 Step 3b headless probe + AC8 + AC5 cost separation | Resolved |
| backend-architect | P0-2: "generalizes to Blake" unsupported | §11 Decision #3 softened + §6 Step 4b Blake scan | Resolved |
| backend-architect | P1-1: markers must be mechanical-on-current-source | §4 layer 3 + Step 4 + AC3 | Resolved |
| backend-architect | P1-3/P1-4: exit-code contract pinned; fail-open P1-only, P3 fail-closed | §4 exit-code contract block + Step 4 | Resolved |
| code-reviewer | P1-3: regen=strip-not-summarize + sub-25KB truncation tell | §6 Step 2 self-check + AC1 ≥25600 | Resolved |
| code-reviewer | P1-1: AC4 assert per-layer | §9 AC4 (per-layer) | Resolved |
| backend-architect | P2-2: pivot needs boolean forcing function | §9 AC5 (PASS/FAIL + number) | Resolved |
| code-reviewer | P1-2 (grep -coE occurrence vs line) / P2 (LC_ALL=C, marker label) | §4 floor note + §6 Step 4 portability | Resolved |
| backend-architect | P2-3: presence-not-fidelity false-negative class | §4 "semantic not reducible → human spot-check"; P2/P3 spot-check | Deferred (P2/P3) |

---

## 10. Important Notes

- **10.1 Anti-theater (load-bearing):** AC4 is the heart of the spike — a parity check that only
  ever PASSes is worthless. It MUST exit 1 on the live drifted edition. If it passes the drifted
  edition, the check is broken, not the edition.
- **10.2 Single-user-CLI lesson (forward to P3):** the parity check is a plain script. It MUST NOT
  be wired into `.claude/settings.json` or any PreToolUse/SessionStart hook — even in P3 it fires
  only at release time. (architecture.md "Mechanical Enforcement Rejected on Single-User CLI".)
- **10.3 Preserve-list is the safety net:** the regen MUST carry every NEVER-Delete category. If the
  regen drops a constraint to hit the size target, that is a FAIL, not a tradeoff (the size target
  is generous — live edition is 35KB vs 100KB ceiling).
- **10.4 Shell portability:** BSD/macOS — no `grep -P`; `LC_ALL=C` on sort/comm over CJK-capable text;
  fail-open WARN on parse error (never crash). (code-quality.md shell-portability + CJK comm entries.)
- **10.5 Scratch isolation:** the regen output is `.regen.md` scratch. The live edition is replaced
  only in P2, after the procedure + criterion are validated here.

## 11. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | Codex-parity architecture | A manual+gate / B regen+gate / C full-read | **B** | A violates ≤5min; C 319KB>>76KB ceiling + 82 runtime subs. DR-20260601. |
| 2 | Execution shape | single handoff / spike-first Epic | **spike-first 3-Phase Epic** | B has mechanism unknowns (regen reliability + parity criterion) → de-risk cheap first. |
| 3 | Spike regen target | both SKILLs / alex only | **alex only** | Alex is the larger/harder (~326KB, 82 subs). ⚠️ (ARCH P0-2) This does NOT prove Blake works — Blake's surface is genuinely different (≈3 AskUserQuestion but Ralph-Loop + Agent-spawn dominated). Step 4b scans Blake's surface; Blake regen + its own residual risk = explicit P2. |

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/codex-parity-phase1-spike/code-reviewer.md
  - .tad/evidence/reviews/blake/codex-parity-phase1-spike/backend-architect.md
gate_verdicts:
  - COMPLETION frontmatter gate3_verdict marker
completion: .tad/active/handoffs/COMPLETION-20260601-codex-parity-phase1-spike.md
spike_artifacts:
  - .tad/evidence/spikes/codex-parity/regen-procedure.md
  - .tad/evidence/spikes/codex-parity/codex-alex-skill.regen.md
  - .tad/evidence/spikes/codex-parity/parity-criterion.md
  - .tad/evidence/spikes/codex-parity/parity-check.sh
  - .tad/evidence/spikes/codex-parity/spike-report.md
knowledge_updates: project-knowledge entry if regen reveals a portable-rules gap
```
