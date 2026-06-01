---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
gate3_verdict: pass
gate4_delta:
  - field: "AC2 dogfood — compensation case (anti-theater core)"
    alex_said: "per-owner gate resists the compensation attack"
    actual: "Alex Gate-4 re-ran it: deleted express forbidden_implementations + added 2 surplus elsewhere (global 12→14). Gate STILL exit 1 ('1 owner below source count'). A count-floor gate would PASS at 14. Verified, not trusted."
    caught_by: "Alex Gate 4 independent dogfood re-run"
  - field: "AC6 constraint fidelity (P1 #1 residual risk)"
    alex_said: "P2 regen preserves all must-cover SAFETY constraints"
    actual: "per-owner trace 12/12 forbidden_implementations + 6/6 anti_rat, source-body==codex-body per owner. P1's condensation risk RESOLVED."
    caught_by: "Alex Gate 4 (read p2-constraint-trace.md per-owner table)"
  - field: "Layer 2 audit reviewer-name drift (recurring, known 2026-05-27)"
    alex_said: "Blake ran 2 distinct reviewers"
    actual: "TRUE in substance (spec-compliance.md + code-reviewer.md exist) but layer2-audit.sh doesn't recognize 'spec-compliance' → false WARN_REVIEWER_COUNT=1. Not a blocker; recurring naming-canonicalization issue — fix: canonical review filenames OR extend KNOWN_REVIEWERS."
    caught_by: "Alex Gate 4 step4c layer2-audit.sh"
  - field: "headless regen tool (P3 input)"
    alex_said: "headless regen via claude -p or codex exec"
    actual: "codex exec --full-auto = PASS 175s (<5min). claude -p = FAIL on 326KB (model produced analysis, not raw file). P3 release-time regen should use codex exec, OR a claude -p with strict raw-output instruction."
    caught_by: "Alex Gate 4 (p2-constraint-trace.md Headless Probe table) + Blake honest report"
git_tracked_dirs:
  - .tad/codex/
  - .tad/evidence/spikes/codex-parity/
---

# HANDOFF: Codex-Edition Parity — Phase 2 (Catch-up)

**Epic:** EPIC-20260601-codex-edition-parity.md (Phase 2/3)
**Decision Record:** DR-20260601-codex-edition-parity-architecture.md (Architecture B)
**Priority:** P2
**From:** Alex (Terminal 1)
**Status:** Expert Review Complete — Ready for Implementation
**Builds on:** P1 spike (commit 1b74dec) — regen-procedure.md, parity-criterion.md, parity-check.sh, portable-rules allowlist

---

## 1. Task Overview

Bring the **live** Codex editions (`.tad/codex/codex-alex-skill.md` + `codex-blake-skill.md`) to full
parity with the current v2.20.0 Claude source — replacing the drifted `Generated: 2026-05-04`
snapshots. Two P1-Gate-4 decisions expand this beyond a plain regen:
- **(a) Harden the gate first**: upgrade `parity-check.sh` Layer 2 from a global constraint floor to
  **per-SAFETY-category presence within the must-cover scope**, so P2's "parity PASS" actually
  guarantees no must-cover SAFETY constraint was condensed away (the P1 floor passed a 59-vs-150 regen).
- **(b) Prove headless**: run at least one regen **headlessly** (`claude -p`/`codex exec`) and measure
  the recurring per-release human-touch time vs the ≤5min standing guarantee (closes P1 AC8).

This delivers the user's "拉到完全当前 v2.20.0" with trustworthy verification.

---

## 2. Background Context

P1 proved the regen mechanism works and built a discriminating `parity-check.sh`, BUT Gate-4
raw-recompute surfaced two residual risks now owned by P2:
1. **Regen condensation.** P1's codex-alex regen = 49KB, constraint count 59 vs source 150. Tracing
   showed honest_partial 4→0 is LEGIT (all in stripped yolo) and the cross_model AR-001 anchor
   survived — but `forbidden_implementations` 12→6 / `anti_rationalization_registry` 6→3 MIX
   legit-stripped losses with **possible must-cover losses** (express/experiment/cancel/step1c are
   must-cover, not on the allowlist). Unverified per-item. The regen LLM condensed despite the
   procedure saying "strip-not-summarize."
2. **The gate can't catch #1.** `parity-check.sh` Layer 2 (grounded 2026-06-01) uses
   `floor = source_count/10` (≥10) + bare presence checks (`anti_rationalization_registry >0`,
   `forbidden_implementations >0`). A regen that keeps ONE anti_rat mention in a kept section but
   drops a must-cover `forbidden_implementations` block still passes. So P2 must FIX the gate before
   trusting it to verify the catch-up.

Blake's surface differs from Alex's: source `blake/SKILL.md` = 104KB/1989 lines, 79 constraints,
11 `Agent` mentions, **49 Ralph-Loop mentions** (vs Alex's 82 AskUserQuestion / 3 Ralph). The Blake
regen must preserve Ralph-Loop Layer-1/Layer-2 logic + transform `Agent`-spawn → sequential `codex exec`.

---

## 3. Requirements

1. Upgrade `parity-check.sh` Layer 2 to per-SAFETY-category must-cover presence (not a global floor),
   and prove it FAILS when a must-cover SAFETY item is deleted (anti-theater dogfood).
2. Harden `regen-procedure.md` with a post-emit per-category SAFETY verification + re-emit loop, so
   condensation that drops a must-cover constraint is caught and corrected during regen.
3. Regenerate `codex-alex-skill.md` AND `codex-blake-skill.md` to the **live** paths, verified by the
   upgraded check. Trace the P1 must-cover losses per-item and confirm P2 preserves them.
4. Run ≥1 regen headlessly; measure recurring human-touch time vs ≤5min.
5. Verify launchers still work; spot-verify the previously-missing tracks are present as real content.

**NOT in scope:** wiring the gate into `release-runbook`/`*publish` (P3). P2 runs the check manually.

---

## 4. Technical Design

**Layer 2 upgrade — PER-MUST-COVER-OWNER-BODY PRESENCE (position-aware, NOT a count — CR+ARCH P0-1).**
A whole-file count is position-blind: dropping the express-path `forbidden_implementations` block (−2)
while the LLM emits the token 2× elsewhere keeps the count ≥ floor and PASSES with the safety block gone
("count ≠ signal" applied to the gate that enforces it). Redesign:

1. **Section model (CR P0-1):** parse BOTH source and Codex edition into bodies delimited by the next
   **col-0 key of ANY kind** (not the next `_protocol:` key — that lets allowlisted `dream`/`evolve`
   swallow the trailing `anti_rationalization_registry` registry at EOF). Reuse the SAME col-0 anchor
   list as Layer 1 so they can't disagree.
2. **Must-cover owner set:** for each SAFETY category (`forbidden_implementations`, `anti_rationalization_registry`,
   `honest_partial`, `NOT_via_alex_auto`), the **must-cover owners** = the source bodies that contain it
   AND are NOT in the expected-absent allowlist. (e.g. forbidden_implementations owners = cross_model_awareness,
   express_path_protocol, experiment_path_protocol — NOT optimize/evolve/yolo which are allowlisted.)
3. **Per-owner presence check:** for each (category, must-cover-owner) pair, verify the category token
   appears **within that owner's body** in the Codex edition (count_in_codex_body ≥ count_in_source_body).
   This is position-aware: surplus in section A cannot mask loss in section B. FAIL names the specific
   (category, owner) that's missing.
4. **0-source categories SKIP, not FAIL (CR P0-2):** Blake has `anti_rationalization_registry`=0 and
   `NOT_via_alex_auto`=0 — Alex-only. A category with zero must-cover owners in the source is SKIPPED.
   Delete the legacy hardcoded `has_ar==0 → DRIFT` / bare `>0` gates (parity-check.sh L116-130).
5. **Threshold self-validation (ARCH P0-2):** the script asserts its derived owner set against a small
   hand-pinned table in `parity-criterion.md` (e.g. forbidden_implementations must-cover owners = {cross_model_awareness:2,
   express_path_protocol:2, experiment_path_protocol:2} = 6). If the derivation disagrees with the pin →
   the gate ERRORs (the derivation is broken; don't bless a live file on a broken denominator).
6. **fail-CLOSED for the SAFETY layer when gating a live replace (ARCH P0-2):** the P1 fail-open WARN is
   for the scratch prototype only; when P2 uses the check to authorize replacing the LIVE edition, a parse
   error / boundary failure → exit 1 (block), never WARN-pass.

**regen-procedure hardening (BOUNDED — CR P1-2 / ARCH P1-3):** add Step D "post-emit SAFETY self-verify":
after emitting, run the upgraded check; on any per-owner FAIL, re-emit that owner's body **verbatim from
source** (strip only CC-tool lines within it, never condense constraint lines), re-check. **Max 2 re-emit
rounds**; still failing → honest_partial + pause for human (mirror Ralph-Loop circuit breaker — the P1 LLM
condensed *despite* the instruction, so the loop must be bounded, not "until the LLM gives up").

**Atomic LIVE replace (CR P1-3):** regen to a scratch path → upgraded parity-check PASS → `mv` over the
live edition → commit. Never write the live file in place (a Step-6 headless interruption must not leave a
half-written live SKILL).

**Headless probe (ARCH P1-3):** invoke the frozen procedure via `claude -p`/`codex exec`, no interactive
correction. Measure the recurring human-touch time on BOTH the happy path AND, if the first pass FAILs the
gate, the remediation path (that's the real standing-guarantee cost). A headless FAIL is a VALID honest
result (same uncorrected path that condensed in P1) — record pass-or-fail + time, do NOT pressure a pass.

**Blake regen — Ralph/Agent precedence (ARCH P1-2):** Ralph-Loop's Layer-2 expert review IS implemented
by `Agent`-spawn, so some of Blake's 11 `Agent` mentions sit INSIDE Preserve-NEVER-Delete Ralph blocks.
Precedence: **preserve the Ralph gating LOGIC verbatim; transform only the mechanism LINE** (the actual
`Agent`-spawn call → "sequential codex exec session"). AC verifies BOTH: Ralph Layer-1/2 logic present AND
zero un-transformed `Agent`-spawn calls remaining inside Ralph blocks.

---

## 6. Implementation Steps

> ⚠️ **INTERNAL MILESTONE (ARCH P1-1/P1-4):** Steps 1–3 (build + VALIDATE the gate) must self-PASS
> BEFORE Steps 4–5 (regen LIVE editions) consume it. The gate is the load-bearing SAFETY guarantee for
> replacing live files — it must be proven trustworthy first. If Step 2 can't make the gate FAIL, STOP.

### Step 1 — Upgrade parity-check.sh Layer 2 (per-must-cover-owner-body presence)
- Modify `.tad/evidence/spikes/codex-parity/parity-check.sh` Layer 2 per §4: parse bodies by **next col-0
  key of ANY kind** (reuse Layer-1 anchor list); build the must-cover owner set per SAFETY category
  (source bodies containing it, minus allowlisted bodies); per-(category,owner) presence check
  (codex-body-count ≥ source-body-count); **0-source category → SKIP**; **remove the legacy
  `has_ar==0→DRIFT` and bare `forbidden_implementations>0` gates (L116-130)**.
- fail-CLOSED on parse/boundary error (this run gates a LIVE replace).
- BSD/macOS-safe; `|| true` not `|| echo 0`; `LC_ALL=C` on sort.

### Step 2 — VALIDATE the gate (anti-theater, 3 cases — milestone)
- **2a Plain deletion:** temp-copy a live edition; delete the express_path_protocol `forbidden_implementations`
  block. Run check → MUST exit 1 naming `(forbidden_implementations, express_path_protocol)` missing.
- **2b Compensation case (ARCH P0-1):** on another temp copy, delete that same block AND add 2 surplus
  `forbidden_implementations` mentions in a DIFFERENT (surviving) section. Run check → MUST STILL exit 1
  (surplus elsewhere must not mask the express loss). This is the case a count-based gate fails.
- **2c Threshold self-validation (ARCH P0-2):** assert the script's derived owner table equals the
  hand-pinned table in parity-criterion.md (forbidden_implementations = {cross_model_awareness:2,
  express:2, experiment:2} = 6). Mismatch → gate ERRORs.
- Paste all 3 runs in completion. **If 2a or 2b can't FAIL → STOP (gate broken, do not proceed to Step 4).**

### Step 3 — Harden regen-procedure.md (bounded)
- Add Step D (post-emit per-owner SAFETY self-verify + verbatim re-emit, **max 2 rounds → honest_partial**)
  per §4. Strip-not-summarize wording gets the per-owner teeth.
- Record the pinned owner table in `parity-criterion.md` (used by Step 2c).

### Step 4 — Regenerate codex-alex to LIVE (atomic)
- Run hardened procedure: source `alex/SKILL.md` → scratch → upgraded parity-check PASS (all 3 layers
  incl. per-owner SAFETY) → **`mv` over `.tad/codex/codex-alex-skill.md`** (atomic). Update `Generated:` date.
- Per-item trace (AC5): write `p2-constraint-trace.md` with per-(category,owner) source-vs-codex-body counts
  + the `must-cover = source_total − in_allowlisted_bodies` arithmetic. Confirm zero must-cover loss.

### Step 5 — Regenerate codex-blake to LIVE (Ralph/Agent precedence)
- Same procedure, source `blake/SKILL.md` → scratch → check PASS → `mv` over live. anti_rat/NOT_via_alex_auto
  categories SKIP (0-source). Ralph precedence (ARCH P1-2): preserve Ralph Layer-1/2 gating logic verbatim;
  transform ONLY the mechanism line of each `Agent`-spawn. Verify: Ralph Layer1/2 logic present AND zero
  un-transformed `Agent`-spawn calls inside Ralph blocks.

### Step 6 — Headless probe (closes P1 AC8)
- Run ≥1 regen headlessly (`claude -p`/`codex exec`) to scratch; record parity result + recurring
  human-touch time vs ≤5min on the happy path AND (if first pass FAILs the gate) the remediation path.
  A headless FAIL is a valid honest result — record pass-OR-fail + time. If genuinely infeasible, honest
  fallback with the attempted command + reason.

### Step 7 — Verify + commit
- `bash .tad/codex/codex-tad-alex.sh --dry-run` + `codex-tad-blake.sh --dry-run` both exit 0.
- AC7 INDEPENDENT spot-read (ARCH P1-4): open the live editions and read the actual SAFETY must-cover
  blocks (cross_model_awareness forbidden_implementations, express forbidden_implementations) + ≥3 feature
  tracks — by eye, NOT via parity-check.sh (don't let the gate be its own only witness).
- git commit live editions + parity-check.sh + regen-procedure.md + parity-criterion.md + trace.

### Step 8 — Layer 1 + completion
- Run §9.1 dry-runs; write COMPLETION with gate3_verdict marker.

---

## 7. File Structure

**Files to Modify:**
- `.tad/codex/codex-alex-skill.md` (MODIFY — regenerate to live, replaces drifted snapshot)
- `.tad/codex/codex-blake-skill.md` (MODIFY — regenerate to live)
- `.tad/evidence/spikes/codex-parity/parity-check.sh` (MODIFY — Layer 2 per-category upgrade)
- `.tad/evidence/spikes/codex-parity/regen-procedure.md` (MODIFY — Step D self-verify hardening)

**Files to Create:**
- `.tad/evidence/spikes/codex-parity/codex-alex-skill.regen-headless.md` (CREATE — Step 6 scratch)
- `.tad/evidence/spikes/codex-parity/p2-constraint-trace.md` (CREATE — AC5 per-item before/after)

**Grounded Against** (Alex step1c actually Read, 2026-06-01):
- `.tad/evidence/spikes/codex-parity/parity-check.sh` (Layer 2: floor=source/10 + bare anti_rat/forbidden_impl >0 presence — the logic being upgraded)
- `.tad/evidence/spikes/codex-parity/regen-procedure.md` (head 30 — Step B already says "line-local NOT summarization" but P1 still condensed)
- `.tad/codex/codex-blake-skill.md` (Generated 2026-05-04, 25KB, 20 constraints vs source 79)
- `.claude/skills/blake/SKILL.md` (1989 lines, 79 constraints, 11 Agent, 49 Ralph — the regen target surface)

---

## 8. Testing Requirements

No unit tests. Verification = §9.1 dry-runs + the Step 2 dogfood (gate must FAIL on a deleted must-cover
SAFETY block) + the per-item trace (Step 4).

---

## 9. Acceptance Criteria

- [ ] AC1: `parity-check.sh` Layer 2 = **per-must-cover-OWNER-body presence** (position-aware, not a count): bodies delimited by next col-0 key of ANY kind; per-(category,owner) codex-body ≥ source-body; 0-source category SKIPs; legacy `has_ar==0→DRIFT`/bare `>0` gates removed; fail-CLOSED on parse error
- [ ] AC2 (milestone — must pass before AC4/AC5): gate VALIDATED by 3 cases, all pasted — **2a** delete express forbidden_implementations → exit 1 naming `(forbidden_implementations, express_path_protocol)`; **2b compensation** delete that block + add 2 surplus elsewhere → STILL exit 1; **2c** derived owner table == hand-pinned table (forbidden_implementations=6) else gate ERRORs
- [ ] AC3: live `codex-alex-skill.md` regenerated (atomic mv); upgraded parity-check exit 0 (all 3 layers incl. per-owner SAFETY)
- [ ] AC4: live `codex-blake-skill.md` regenerated (atomic mv); parity-check exit 0; Ralph Layer-1/2 logic present AND zero un-transformed `Agent`-spawn calls inside Ralph blocks; anti_rat/NOT_via_alex_auto SKIPPED (0-source)
- [ ] AC5: guards + sizes: `grep -c AskUserQuestion`=0 each; codex-alex ≤102400 B, codex-blake ≤40960 B
- [ ] AC6: `p2-constraint-trace.md` shows per-(category,owner) source-body-vs-codex-body counts + the `must-cover = source_total − in_allowlisted_bodies` arithmetic, confirming zero must-cover loss; `regen-procedure.md` Step D (bounded ≤2 re-emit) present
- [ ] AC7: headless probe (Step 6) — pass-OR-fail + recurring human-touch time vs ≤5min recorded (happy path + remediation path if first pass FAILed); honest "infeasible + attempted command + reason" acceptable
- [ ] AC8: INDEPENDENT spot-read (by eye, NOT via parity-check.sh): live codex-alex contains the cross_model_awareness `forbidden_implementations` block + express `forbidden_implementations` block + ≥3 feature tracks (`grep -c 'task_type: deliverable'`≥1, `grep -c 'research_complexity'`≥1, `grep -ci 'step4_5\|Pack Awareness'`≥1)
- [ ] AC9: `bash .tad/codex/codex-tad-alex.sh --dry-run` and `codex-tad-blake.sh --dry-run` both exit 0

### 9.1 Spec Compliance Checklist

⚠️ **PIPE-ESCAPE CONTRACT (P1 lesson):** table cells escape `|` as `\|` for rendering; RUN the bare-pipe
forms in the RUNNABLE FORMS block. ERE (`grep -E/-coE`) needs bare `|`; the BRE row (`grep -ci 'a\|b'`,
no `-E`) keeps `\|`.

| AC | Command (table-escaped) | Expected | Verified (step1d) |
|----|--------------------------|----------|-------------------|
| AC3 | `bash parity-check.sh .claude/skills/alex/SKILL.md .tad/codex/codex-alex-skill.md; echo $?` | `0` | post-impl (live not yet regenerated) |
| AC4 | `bash parity-check.sh .claude/skills/blake/SKILL.md .tad/codex/codex-blake-skill.md; echo $?` | `0` | post-impl |
| AC5a | `grep -c AskUserQuestion <edition>` | `0` | post-impl; live codex-alex currently 0 |
| AC5b | `wc -c < .tad/codex/codex-blake-skill.md` | `≤40960` | pre-impl: live = `25116` ✅ |
| AC8 | `grep -ci 'step4_5\|Pack Awareness' .tad/codex/codex-alex-skill.md` (BRE) | `≥1` | post-impl; live drifted = `0` (the drift P2 closes) |

**RUNNABLE FORMS (copy these — bare pipe for ERE):**
```bash
bash .tad/evidence/spikes/codex-parity/parity-check.sh .claude/skills/alex/SKILL.md .tad/codex/codex-alex-skill.md; echo $?   # AC2 → 0
bash .tad/evidence/spikes/codex-parity/parity-check.sh .claude/skills/blake/SKILL.md .tad/codex/codex-blake-skill.md; echo $?  # AC3 → 0
grep -c AskUserQuestion .tad/codex/codex-alex-skill.md                # AC4a → 0
grep -coE 'MUST|MANDATORY|VIOLATION' .tad/codex/codex-alex-skill.md   # AC4b → ≥floor (ERE bare pipe)
wc -c < .tad/codex/codex-blake-skill.md                               # AC4c → ≤40960
grep -ci 'step4_5\|Pack Awareness' .tad/codex/codex-alex-skill.md     # AC7 → ≥1 (BRE \| correct)
```

**AC Dry-Run Log** (Alex step1d, 2026-06-01, on current live editions = baseline):
- AC4a: ✅ `grep -c AskUserQuestion` live codex-alex = `0`.
- AC4c: ✅ `wc -c` live codex-blake = `25116` (≤40960).
- AC7: ✅ `grep -ci 'step4_5\|Pack Awareness'` live codex-alex = `0` — confirms the drift P2 must close.
- AC2/AC3: post-impl — live editions not yet regenerated; commands syntactically validated.

### 9.2 Expert Review Status

Reviewed by **code-reviewer** + **backend-architect** (2 distinct, parallel). Both CONDITIONAL PASS → all P0s integrated.
Raw: `.tad/evidence/reviews/alex/codex-parity-phase2-catchup/{code-reviewer,backend-architect}.md`.

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P0-1: body-delimiter `_protocol:`-only lets dream swallow anti_rat registry → count ~0 | §4.1 + Step 1 (col-0 ANY key, reuse Layer-1 anchors) | Resolved |
| code-reviewer | P0-2: AC3 Blake unsatisfiable — anti_rat/NOT_via_alex_auto=0, hardcoded `==0→DRIFT` | §4.4 + Step 1 (0-source SKIP, remove L116-130 gates) + AC4 | Resolved |
| backend-architect | P0-1: whole-file count position-blind → compensation attack passes | §4.1-3 per-owner-body presence + Step 2b compensation dogfood | Resolved |
| backend-architect | P0-2: must-cover threshold derivation unvalidated + fail-open on live gate | §4.5 self-validation vs pinned table + §4.6 fail-CLOSED + Step 2c + AC2 | Resolved |
| both | P1: re-emit loop unbounded | §4 "max 2 rounds → honest_partial" + Step 3 + AC6 | Resolved |
| code-reviewer | P1-3: LIVE replace not atomic | §4 atomic + Step 4/5 (scratch→check→mv) | Resolved |
| backend-architect | P1-2: Ralph-Loop Layer-2 IS Agent-spawn → transform conflict | §4 Blake precedence + Step 5 + AC4 | Resolved |
| backend-architect | P1-1/P1-4: milestone (gate validated before regen) + independent spot-read | §6 INTERNAL MILESTONE banner + Step 7 + AC2/AC8 | Resolved |
| code-reviewer | P1-4 / arch P1-3a: headless FAIL is valid honest result | Step 6 + AC7 (pass-OR-fail + time) | Resolved |
| backend-architect | P1-3b: measure remediation path, not just happy path | Step 6 + AC7 | Resolved |

---

## 10. Important Notes

- **10.1 This phase modifies LIVE editions** (unlike P1's scratch). The regen REPLACES the drifted files —
  that's the catch-up. Commit so the change is durable.
- **10.2 Anti-theater (AC1/Step 2):** the Layer-2 upgrade is worthless unless it FAILS on a deleted
  must-cover SAFETY block. Dogfood it. A check that only PASSes is a FAIL of this handoff.
- **10.3 Per-category, not global (the whole point):** the P1 floor passed a regen with possible must-cover
  loss. Do NOT keep relying on the global floor as the SAFETY guarantee — the per-category check is the
  guarantee; the floor is a secondary signal only.
- **10.4 Blake surface ≠ Alex surface:** preserve Ralph-Loop Layer1/2 verbatim (Preserve-NEVER-Delete);
  transform Agent-spawn → sequential codex exec. Don't let condensation eat Ralph logic.
- **10.5 Forward to P3:** the per-category Layer-2 logic built here is exactly what P3 wires into the
  release gate. Keep it a clean, reusable exit-coded check.
- **10.6 P1 lesson — strip-not-summarize:** P1's procedure SAID it and the LLM still condensed. Step D's
  self-verify-and-re-emit is the enforcement, not the prose. Trust the check, not the instruction.

## 11. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | SAFETY fidelity guarantee | pull P3 per-category check into P2 / manual trace only / trace-then-decide | **pull P3 check forward** | P2 replaces LIVE editions; its parity PASS must guarantee SAFETY survival, which the global floor can't. User decision 2026-06-01. |
| 2 | Headless reliability | prove in P2 / defer to P3 | **prove in P2** | Closes P1 AC8; P2 already regenerates 2 SKILLs so the marginal cost is low. User decision 2026-06-01. |

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/codex-parity-phase2-catchup/code-reviewer.md
  - .tad/evidence/reviews/blake/codex-parity-phase2-catchup/backend-architect.md
gate_verdicts:
  - COMPLETION frontmatter gate3_verdict marker
completion: .tad/active/handoffs/COMPLETION-20260601-codex-parity-phase2-catchup.md
artifacts:
  - .tad/codex/codex-alex-skill.md (regenerated live)
  - .tad/codex/codex-blake-skill.md (regenerated live)
  - .tad/evidence/spikes/codex-parity/parity-check.sh (Layer 2 upgraded)
  - .tad/evidence/spikes/codex-parity/regen-procedure.md (Step D hardened)
  - .tad/evidence/spikes/codex-parity/p2-constraint-trace.md
  - .tad/evidence/spikes/codex-parity/codex-alex-skill.regen-headless.md
knowledge_updates: project-knowledge entry if the per-category check or Blake regen reveals a new pattern
```
