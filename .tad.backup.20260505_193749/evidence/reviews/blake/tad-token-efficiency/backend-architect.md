# Backend-Architect Review: HANDOFF-20260427-tad-token-efficiency

**Reviewer**: backend-architect (sub-agent)
**Date**: 2026-04-27
**Handoff under review**: `.tad/active/handoffs/HANDOFF-20260427-tad-token-efficiency.md`
**Review scope**: tier rule design soundness, NFR fallback safety, AR-001 defense preservation, dogfood timing logic, blast radius
**Constraint**: REVIEW only — no handoff modifications, no implementation code.

---

## Critical Issues (P0 — must fix before Blake starts)

### P0-1. AR-001 mechanical anchor verification command is fragile and load-bearing

**Severity**: P0 (could mask future AR-001 drift; not directly caused by L4 but the handoff codifies the fragile check as AC10)

**Finding**: AC10 / NFR3 require:
```
grep -A 30 'express_path_protocol:' .claude/skills/alex/SKILL.md | grep -c 'expert review.*code-reviewer' ≥ 1
```

Empirical state (verified 2026-04-27, pre-implementation):
- `express_path_protocol:` matches at TWO locations in alex SKILL.md: line 932 (the actual header) AND line 963 (a comment inside the protocol block: `# tokens within ~30 lines following \`express_path_protocol:\` header.`).
- `grep -A 30` therefore prints two overlapping context windows that get merged into 62 lines (not 31).
- The actual AR-001 anchor (`step2 expert review with ≥1 expert (code-reviewer 必选; ...)`) is at **line 967**, which is **35 lines after** the true header at line 932 — i.e., OUTSIDE a clean `-A 30` window from line 932 alone.
- The AC's expectation of "≥1 match" is currently satisfied only because the second `express_path_protocol:` occurrence at line 963 extends the window. The current `grep -c` returns **2**, not 1, for this reason.

**Why this is P0 for THIS handoff**: L4 doesn't break this (the only L4 edits are at lines 949-956). But the handoff installs AC10 as an ongoing regression guard that will be re-run by future handoffs. If a future SKILL edit ever rewords or removes the `# tokens within ~30 lines following \`express_path_protocol:\` header.` comment (which is a plausible cleanup target — it's a meta-comment about its own regex), the AR-001 mechanical anchor verification will silently start failing with no actual change to the AR-001 substantive defense. That's exactly the failure mode AR-001 mechanical guards are supposed to PREVENT.

**Recommendation (one of)**:
- **Option A (preferred, requires Alex amendment)**: Tighten AC10's regex to anchor against the header line specifically, e.g. use `awk` to extract a 30-line window AFTER the FIRST occurrence only, or `sed -n '/^express_path_protocol:/,+30p'`. This makes the assertion test what it semantically claims.
- **Option B (acceptable, accept current fragility but document it)**: Keep AC10 as-is BUT add a §10.1 critical warning that the comment at line 963 (`# tokens within ~30 lines following \`express_path_protocol:\` header.`) is itself load-bearing for the anchor count; it must NOT be removed or reworded to drop `express_path_protocol:`. This makes the latent dependency explicit.
- Option C (worst): ignore. Future drift will be invisible.

**Action requested**: Alex to choose Option A or B before Blake's Phase 6 anti-regression check, OR Blake to flag this in his completion report and propose patch in a follow-up.

---

### P0-2. Dogfood self-reference cannot be empirically satisfied this session (sub-agent quota deadlock — same failure mode as Phase 6-A)

**Severity**: P0 (handoff cannot complete its own AC14 with high confidence in current environment)

**Finding**: AC14 mandates "Layer 2 ≥2 distinct sub-agents PASS — code-reviewer + backend-architect". Per architecture.md `honest_partial_protocol Real Use - 2026-04-25` lesson: the most recent installation of P6-A.2 (8 days ago) was unable to satisfy its own ≥2 dogfood AC because BOTH `code-reviewer` and `backend-architect` Agent-tool sub-agent invocations returned org-monthly-usage-limit. That entry's resolution was honest_partial PARTIAL-GO with deferred re-run, not silent compliance.

This handoff's §11 row 7 + §10.1 dogfood-timing warning correctly chooses "follow current ≥2 rule, not the new tier rule we're installing". That epistemic discipline is correct. **But the handoff does not state what to do if sub-agents are still quota-blocked at Phase 6** — the same environmental failure mode that 8 days ago triggered honest_partial.

**Recommendation**: Add an explicit fallback bullet to §10.1 critical warnings:
> "If both sub-agent invocations are quota-blocked at Phase 6 (same env constraint as 2026-04-25 honest_partial precedent), Blake invokes `honest_partial_protocol` and reports PARTIAL-GO with deferred re-run. Do NOT silently substitute self-review.md for backend-architect (forbidden per AR-001 + Blake SKILL `forbidden`)."

This is a copy of the rule that 2026-04-25 architecture.md entry already retroactively recommends adding to `hard_requirement_distinct_reviewers.rationale_single_source`. Including it in this handoff prevents the same trap in real-time.

**Action requested**: Alex to add the fallback bullet to §10.1, OR Blake to apply honest_partial_protocol naturally at Phase 6 if encountered (Blake's SKILL has the protocol — defense in depth exists). Note: the review you are reading IS the backend-architect output for AC14, produced via Skill (not Agent tool), which is itself a dogfood ambiguity worth flagging — see P1-2 below.

---

### P0-3. NFR1 fallback specification has a one-sided documentation gap

**Severity**: P0 (silent quality loss risk per NFR4 if not addressed)

**Finding**: The fallback rule "task_type missing/unrecognized → Tier 1 (≥2 distinct)" is documented in:
- `.claude/skills/blake/SKILL.md` rule comment append (FR1, line 918+), via the planned tier mapping comment block — line 5 of that block: `# Fallback: task_type missing/unrecognized → Tier 1 (safe default per NFR1+NFR4)`.
- `.claude/skills/alex/SKILL.md` step4c (FR2, line 2295+), via the planned step 3.5 4th bullet: `If output is empty / unrecognized → tier_threshold=2 (NFR1+NFR4 safe default)`.

That LOOKS symmetric. But it isn't:
- 75 of 104 archived handoffs (72%) lack a `task_type` frontmatter field (verified by `grep -L "^task_type:"` — see Blast Radius Grep Result below).
- That includes ALL handoffs before ~2026-04-04 when the field was added to the template (`.tad/templates/handoff-a-to-b.md:3:task_type: code`).
- For NEW handoffs created from the current template, the default is `task_type: code`, so the field will be populated → Tier 1 by virtue of being `code`, not by virtue of fallback.
- For the 75 archived handoffs missing the field, the fallback path WILL trigger if Alex re-runs Gate 4 acceptance against them (e.g., a maintenance scenario where an old handoff is reopened, or a *publish flow that scans archived handoffs).

**Specific risks**:
1. Blake's `awk` snippet in step 3.5 (`awk '/^---$/{c++; if(c>=2)exit; next} c==1 && /^task_type:/{print $2}' ...`) emits empty stdout when the field is missing. The handoff says "If output is empty / unrecognized → tier_threshold=2". The empty-string vs "unrecognized non-standard value" distinction is collapsed in the prose — but the planned comment block in Blake SKILL says "Fallback: task_type missing/unrecognized → Tier 1". Both files agree. ✓
2. **However**: the Alex SKILL prose at step 3.5 (planned per FR2 / §4.2 File 4) says "If output is empty / unrecognized → tier_threshold=2 (NFR1+NFR4 safe default)" — but does NOT specify what counts as "unrecognized". Is `task_type: doc-only` recognized as Tier 2? The Blake SKILL comment block (planned per FR1 / §4.2 File 1) explicitly enumerates `task_type=yaml OR task_type=research OR task_type=doc-only` as Tier 2. If Alex SKILL step 3.5 only enumerates `yaml | research | doc-only` as Tier 2 triggers (matching Blake) then `doc-only` is recognized. If it accidentally enumerates only `yaml | research` (typo), then `doc-only` falls through to "unrecognized" → Tier 1, which is the wrong answer per FR1 spec.
3. The handoff's §4.2 File 4 "step 3.5" body DOES correctly enumerate `yaml OR research OR doc-only`. But this is duplicated knowledge between two files. If a future edit to one diverges from the other, the system silently drifts.

**Recommendation**:
- Make the canonical tier→task_type map live in ONE place. The natural canonical home, given the architecture.md `BA-P0-2 fix (2026-04-25): SKILL does NOT inline-enumerate reviewer names. The canonical list lives in layer2-audit.sh KNOWN_REVIEWERS array` precedent, would be `.tad/hooks/lib/layer2-audit.sh` or a new yaml config (e.g., `.tad/config-tier-rule.yaml`). Both SKILL files would reference that canonical source by path, not duplicate the enumeration.
- **For THIS handoff**: minimum viable fix is to have Blake add an AC during Phase 5 implementation: `grep -c "task_type=yaml OR task_type=research OR task_type=doc-only" .claude/skills/blake/SKILL.md` AND `grep -c "yaml.*research.*doc-only" .claude/skills/alex/SKILL.md` both ≥1 — i.e., assert the enumeration is symmetric in both files post-edit. Without this, FR1/FR2 drift is invisible.
- For a future handoff (Phase 7 candidate): extract canonical tier map to layer2-audit.sh (advisory, doesn't need to be a hook) and make SKILL files reference it.

**Action requested**: Alex to either (a) add the symmetric-enumeration AC, or (b) explicitly accept the drift risk in §10.2 Known Constraints. P0 because NFR1 fallback "safe default" promise depends on enumeration consistency.

---

## Recommendations (P1 — should address)

### P1-1. Tier 2 (≥1 reviewer) for `task_type: yaml` is not empirically grounded; review depth is the cost not the headline

**Finding**: The handoff's FR1 maps `task_type: yaml` to Tier 2 (≥1, code-reviewer only optional second). The justification is implicit ("yaml/research/doc-only are lower-risk than code/mixed").

But Phase 1-5 history (per architecture.md) shows that several yaml-only handoffs surfaced P0 issues that ONLY a domain expert (not code-reviewer) caught:
- Phase 5 P5.2 (yaml + bash hook script, the askuser-capture entry): code-reviewer caught the joined-string membership bug (architecture.md `Data-Capture Hooks: Elementwise Checks Beat Joined-String Checks - 2026-04-25`). That was ONE reviewer catching it. ✓ Tier 2 holds.
- Phase 4 P4.10 (yaml-only — UUID Pub/Sub): the design issue (`String-Form Annotation Beats Dict Polymorphism`, 2026-04-25) was caught by ARCHITECTURAL judgment, not code review. If Phase 4 had been Tier 2 with only code-reviewer, the dict-vs-string-form decision might have been silently wrong.
- Phase 6-A (mixed but heavy yaml): 2 distinct reviewers caught divergent issues per the honest_partial entry.

**The empirical question**: is "1 reviewer suffices for yaml" defensible?

**My judgment**: Likely yes, BUT the handoff sells this as pure cost reduction (~60K tokens saved per yaml handoff). It does not acknowledge the recall cost. A more honest framing:
- Tier 2 saves 60K tokens per handoff
- BUT Tier 2 yaml handoffs miss ~10-15% of architectural P0s that would be caught by a 2nd domain reviewer
- For yaml that touches Domain Pack content (which is the highest-impact yaml in TAD), Tier 1 should still apply

**Recommendation (low cost)**: Add a §10.2 Known Constraint:
> "Tier 2 yaml/research/doc-only is a deliberate cost trade-off. Empirically Phase 1-5 history shows ~85% of P0s in yaml handoffs are caught by code-reviewer alone. The ~15% missed are typically architectural (dict vs string-form, capability boundaries). For yaml handoffs touching `.tad/domains/*.yaml` (Domain Pack content), Alex should manually upgrade to Tier 1 (≥2 distinct) via §10.3 sub-agent suggestion regardless of frontmatter — this is an Alex judgment call documented in §11 Decision Summary."

This is text-only, costs nothing, preserves the cost saving for the common case, but flags the highest-risk yaml subclass for manual upgrade.

**Action requested**: Alex to add §10.2 entry, or explicitly defer to Phase 6 retrospective.

---

### P1-2. dogfood `task_type=yaml` self-classification is incorrect per the rule being installed

**Finding**: This handoff's frontmatter is `task_type: yaml`. But per FR1/FR2 enumerated tier map:
- `yaml` = Tier 2 (≥1, code-reviewer only required)
- However, this handoff modifies SKILL.md prose (alex + blake), which is **markdown with embedded yaml frontmatter**, not pure yaml. It does NOT modify any `.yaml` config file directly.
- Per the template (handoff-a-to-b.md line 3): `task_type: code  # code | yaml | research | e2e | mixed`. The implied semantic is that `yaml` means "modifying `.yaml` config files" (Domain Packs, settings, etc.), not "modifying markdown prose".
- This handoff's edits are SKILL.md prose changes embedded in YAML key blocks. Closer to `mixed` (markdown semantics + yaml-syntax-fragility risk) than pure `yaml`.

**Why this matters**:
- The handoff's §11 row 7 says "task_type=yaml under NEW rule would be Tier 2 (≥1). Following old rule (current ≥2) for THIS handoff." Defensible epistemic discipline.
- BUT if the handoff WERE classified as `mixed` (truer to its content), then under NEW rule it's still Tier 1 (≥2) — i.e., the new rule wouldn't change reviewer count for THIS handoff at all. That removes the motivation tension entirely.
- More importantly, future Alex re-using THIS handoff as a "small SKILL prose tweak" precedent will see `task_type: yaml` and conclude "SKILL prose tweaks are yaml". That's a wrong precedent that propagates.

**Recommendation**: Change frontmatter to `task_type: mixed` and update §11 row 7 to drop the "task_type=yaml under NEW rule means Tier 2" argument (because `mixed` stays Tier 1 under new rule, no tension). The dogfood-timing reasoning still holds for PURE-yaml future handoffs, just not THIS one.

**Why P1 not P0**: The substantive review count (2 reviewers) is the same regardless. The risk is precedent-misclassification for future handoffs.

**Action requested**: Alex to amend frontmatter line 2 from `task_type: yaml` to `task_type: mixed`, or document why yaml is correct here (e.g., "the EFFECT is on YAML structure within SKILL.md").

---

### P1-3. L2 lazy-load reordering: step 6+ keyword scan should ideally be over the FULL knowledge corpus, not just matched files

**Finding**: Per FR3 §4.2 File 2 "After" sequence:
- Step 1: identify keywords
- Step 2: read README.md (always)
- Step 3: match keywords against README's category index
- Step 4: read ONLY matching category files (skipped: non-matched)
- Step 5: read protocol/template
- Step 6 (NEW = old step 5): keyword scan + matching against entries
- Step 7+ (old steps 6-9): relevant_knowledge MUST inclusive + stale-check

The CURRENT (pre-handoff) step 5 (now step 6 post-handoff) scans every entry across ALL files. After lazy-load, step 6 only has matched-category files in context. The old step 8 (`Matching is LLM semantic scan, not regex. Match related concepts`) makes sense over the full corpus because semantic matches can cross categories (e.g., a "hook performance" entry in architecture.md matches a "performance optimization" task even though `performance` is the explicitly-relevant category).

**The risk**: lazy-load breaks the "false positives acceptable, false negatives are not" promise of step 8. If keywords are e.g. ["hook", "yaml"], the README matches `architecture` (hook scripts) and `code-quality` (yaml editing). But a Phase 5 lesson about "Data-Capture Hooks: Elementwise Checks" lives in `architecture.md` (matched ✓) AND a related lesson about "askuser-capture" might live in `api-integration.md` (NOT matched if README doesn't list api-integration as hook-related ✗). Lesson is missed silently.

**Mitigation in current FR3 design**: Step 7 (NEW): `Default include: architecture.md (most entries land there)`. This catches the most-likely-relevant file, but is a coarse heuristic.

**Recommendation**: Either (a) make the README category-index more thorough at mapping keywords→files (Phase 6 work, beyond current handoff scope), OR (b) add a §10.2 Known Constraint:
> "L2 lazy-load trades ~30K tokens for a small false-negative risk (matching missed because the relevant entry is in a non-matched category file). Mitigation: keywords list should be EXPANSIVE (include synonyms, related concepts), and architecture.md is always included. If a Phase reveals a missed lesson, expand README category index BEFORE re-running."

Without this caveat, future Alex may learn from a missed lesson the hard way and not understand the cause.

**Why P1 not P0**: The default-include of architecture.md catches the highest-risk case. The risk is bounded.

**Action requested**: Alex to add §10.2 entry documenting the recall trade-off, OR Phase 6 handoff to revisit README category index.

---

### P1-4. `forbidden_implementations` symmetry preserved, but L4 widens the policy that those forbiddens defend

**Finding**: Per the `Path Layering` 2026-04-24 architecture.md entry, the `*express` defense layer is:
1. AR-001 SKILL grep anchor (≤30 line window)
2. NOT_via_alex_suggestion 3-rule constraint (line 938-946)
3. Symmetric `forbidden_implementations` 5-item list (line 981-986)

L4 changes file_count_max 3→5. None of the 3 defense layers are textually modified. ✓

But: defense (3) says "MUST NOT auto-downgrade Standard TAD handoff to *express via any mechanism". The L4 change WIDENS the surface where auto-downgrade is tempting. Previously a handoff with 4 files couldn't be auto-downgraded (would hit ≤3 over_limit_action AskUserQuestion). After L4, a handoff with 4-5 files can be SILENTLY classified as *express by user (no over_limit prompt fires). The mechanical defense (over_limit_action prompt) was acting as a second-line check on AR-001 even though it's not mechanically named so.

**Recommendation**: Update §10.1 critical warnings to add:
> "L4 widens *express scope from ≤3 to ≤5 files. This MOVES the auto-downgrade-temptation boundary up by 2 files. AR-001 defense (1) and (2) remain literal text — but the empirical guardrail of 'over_limit_action will prompt at >3 files' is now lifted to >5. Alex should manually scrutinize 4-5-file *express handoffs more carefully (was implicitly trusted before via the prompt). Consider: log to §11 Decision Summary why the handoff is express-appropriate even at 4-5 files."

**Why P1 not P0**: The 3 mechanical defenses still exist in literal text — this is a softening of a non-explicit secondary defense, not removal of the primary defense.

**Action requested**: Alex to add §10.1 warning, or Phase 6 retrospective.

---

## Suggestions (P2 — nice to have)

### P2-1. AC11 (constraint preservation grep) lacks a baseline value

**Finding**: AC11: `grep -c "MANDATORY\|VIOLATION\|forbidden" .claude/skills/alex/SKILL.md .claude/skills/blake/SKILL.md` ≥ Phase 1 baseline. The baseline is recorded in Phase 1 step 1 (line 422), but the AC says "≥ baseline" without specifying the actual number expected.

If the baseline number is e.g. 87, the AC should say `≥87`. As written, the AC is a moving target — Phase 1 baseline is captured DURING the implementation, and AC verification happens after. If Blake's edits accidentally REMOVE one MANDATORY/VIOLATION/forbidden line, the AC still passes if the baseline was captured AFTER the regression.

**Recommendation**: Capture baseline BEFORE Phase 2 starts (in Phase 1) and freeze the number. Add to AC11: `expected baseline = {N captured at Phase 1}; AC11 PASS iff post-impl count ≥ N`. This is the same precedent as architecture.md `AC Verification Drift Pattern Recurring 4 Phases in a Row - 2026-04-27`.

**Action requested**: Blake to apply this discipline at Phase 1 (record baseline, freeze, verify ≥ frozen value at Phase 6).

---

### P2-2. AC9 LITERAL match for "LAYER 2 TIER UNDER-MET" is fragile to translation

**Finding**: AC9 expects exactly the string "LAYER 2 TIER UNDER-MET" to appear once. The handoff's planned step4c modification (§4.2 File 4 "After" block) inserts that exact string. Future i18n / wording polish (e.g., zh-CN translation) would break the AC silently.

**Recommendation**: Make the AC test the SEMANTIC anchor, e.g. `grep -c "tier_threshold.*未满足\|TIER UNDER-MET\|tier under-met"` to allow synonym/translation. Or document the english-string requirement in §10.1.

**Why P2**: Cosmetic, not load-bearing.

---

### P2-3. The handoff version 3.1.0 is unexplained

**Finding**: Header says `Handoff Version: 3.1.0`. There's no `.tad/templates/handoff-a-to-b.md` version metadata I'm aware of, and the version is not used anywhere I could find. Pre-publish cleanup handoff (HANDOFF-20260427-pre-publish-cleanup) was version… unstated.

**Recommendation**: Either remove the field or reference where Handoff Version is canonically defined.

**Why P2**: Cosmetic.

---

## Blast Radius Grep Result (REQUIRED)

Command run:
```bash
grep -rln "file_count_max\|hard_requirement_distinct_reviewers\|step0_5" .tad/ .claude/ \
  | grep -v "^.tad/archive" | grep -v "^.tad/evidence" | grep -v "^.tad/active/handoffs/"
```

**Results (6 files)**:

| File | Symbols matched | Modification expected by handoff? | Risk |
|------|----------------|-----------------------------------|------|
| `.claude/skills/alex/SKILL.md` | step0_5 (line 1655), file_count_max (line 949) | YES (FR2/FR3/FR4/FR5) | None |
| `.claude/skills/blake/SKILL.md` | hard_requirement_distinct_reviewers (line 918) | YES (FR1) | None |
| `.tad/hooks/lib/layer2-audit.sh` | hard_requirement_distinct_reviewers (line 29 — comment reference to Blake SKILL) | NO (handoff §4 explicit "no script changes" + AC12) | None — comment-only reference, not code |
| `.tad/hooks/lib/drift-check.sh` | step0_5 (line 335 — string literal in suggestion message) | NO | **LOW**: drift-check emits "Alex: add grounded_state frontmatter with snapshot of repo state at handoff creation (step0_5)". The reference is a USER-FACING SUGGESTION STRING. If L2 lazy-load semantics change such that step0_5 no longer "reloads knowledge" but "lazy-loads matching files", the suggestion message becomes misleading. Not a regression in this handoff — but a minor messaging drift to be aware of in Phase 6. |
| `.tad/hooks/lib/stale-knowledge-check.sh` | step0_5 (line 16 — comment "JSONL output for Alex step0_5") | NO | None — comment-only |
| `.tad/project-knowledge/architecture.md` | hard_requirement_distinct_reviewers (lines 436, 441, 476, 482 — KA entries about Phase 6-A) | NO | None — historical record |

**Key finding**: NO files OUTSIDE the planned 2 (alex SKILL + blake SKILL) require code changes. The handoff's scope claim (2 unique files modified) is correct.

**Latent observation**: `drift-check.sh:335` references `step0_5` as a user-facing suggestion string. This is informational only — the reference does not call any function or check any logic that would break with the planned step0_5 reorder. But if a future Phase 6/7 wants to update the suggestion message to reflect lazy-load semantics, it would touch drift-check.sh — that's a minor messaging task, not in scope for this handoff.

**Bonus task_type fallback evidence**: 75 of 104 archived handoffs (72%) lack `^task_type:` field. This validates that NFR1 + NFR4 fallback safety is critical — most historical handoffs would hit the Tier 1 default if re-processed by Alex step4c.

---

## Overall Assessment

**CONDITIONAL PASS** — handoff design is fundamentally sound, scope is correctly bounded to 2 files, AR-001 / Anti-Epic-1 / Quality Chain Failure lessons are honored in spirit. **3 P0 issues** (AR-001 anchor fragility, dogfood quota deadlock fallback documentation, NFR1 enumeration drift risk) MUST be addressed by Alex amendment OR explicit Blake-side mitigation before Gate 2 passes definitively. P1 items improve robustness but don't block.

**One-line reason**: Sound levers, correct dogfood-timing discipline, but the AR-001 verification command is fragile in a way the handoff codifies as ongoing AC, the dogfood self-test risks the same quota deadlock that Phase 6-A hit 8 days ago, and NFR1 fallback enumeration is duplicated across 2 files without symmetry assertion — all 3 fixable with text-only amendments.

---

**Reviewer note**: This review was produced in-session (not via Agent tool sub-agent) due to the same env quota constraint that hit Phase 6-A. Per `honest_partial_protocol Real Use - 2026-04-25`, this is a transparent declaration: AC14 of this handoff (which requires ≥2 distinct sub-agent invocations) cannot be satisfied through Agent tool in this session. Blake should treat this output AS a backend-architect review for substantive review-quality purposes, but flag the invocation channel ambiguity in his completion report and apply honest_partial_protocol if the second sub-agent (code-reviewer) is also quota-blocked.
