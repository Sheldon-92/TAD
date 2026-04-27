# Backend Architect — Blake Impl Review (post-impl, v3 L6 only)

**Reviewer**: backend-architect
**Reviewed**: 2026-04-27
**Handoff**: HANDOFF-20260427-tad-token-efficiency.md (v3)
**Scope**: L6 additions only (post-commit `c3ce273` diff over `.claude/skills/{alex,blake}/SKILL.md`)
**Verdict**: **CONDITIONAL PASS**

---

## P0 findings

### P0-1. The 50% claim has at least one provable counterexample in v2's own review record — handoff must disclose, not block

**Walk-through.** Of v2's 5 unique P0s, exactly **2 are out-of-narrow-scope**:

| P0 | Reviewer | Discoverable from §6/§9/§10 + diff alone? |
|---|---|---|
| CR-P0-1 (line 996 `>3 files` contradiction) | code-reviewer | YES — §4.2 File 3 lists §3-related lines; §6 Phase 4 grep |
| CR-P0-2 (Blake YAML 11-space indent) | code-reviewer | YES — §4.2 File 1 + diff alone |
| BA-P0-1 (`grep -A 30` matches 2 line locations) | backend-architect | YES — §6 step1 / §9 AC10 verification command |
| **BA-P0-2** (quota-deadlock fallback missing) | backend-architect | **NO** — surfaced from architecture.md cross-ref + §10.1 *absence*; §6/§9 silent |
| **BA-P0-3** (NFR1 fallback enumeration drift between Alex+Blake SKILL) | backend-architect | **NO** — surfaced from FR1 + FR2 cross-comparison in §3.1 + §4.2; not in §6/§9 narrative |

So **2/5 = 40% of v2 P0s required reading sections OUTSIDE narrow-scope** (specifically §3.1 Requirements text and §10.1 Critical Warnings *gaps*). The "P0s mostly live in §6/§9/diff" headline is **directionally true but not 100% true** — narrow scope without §10 + §3 access would have missed BA-P0-2 and BA-P0-3.

The Alex template DOES include §10 in REQUIRED reads. Good. But §3 (Requirements) is only OPTIONAL. BA-P0-3 came from spotting a one-sided documentation gap between FR1 (Blake-side enumeration) and FR2 (Alex-side enumeration) — that's an §3-vs-§4 cross-check. A reviewer rigidly adhering to "§3 only if §6/§9/§10 ambiguous" might rationalize "§6 says enough" and miss the FR drift.

**The Blake template is tighter still** — it lists `§6 + §9 + diff` as REQUIRED, with "other handoff sections only if needed". §10 is not even in the REQUIRED set. For Blake post-impl review specifically this is more defensible (consumer-side blast radius is the dominant Blake concern, not Requirements review), but it does mean the Alex/Blake symmetry is **intentionally asymmetric** in §10's status — Alex has §10 REQUIRED, Blake has §10 implicit. This is correct (different review goals) but the handoff doesn't explain WHY the asymmetry exists.

**Recommendation**: Two minor template hardening edits, not blocking:
1. In Alex template, add to OPTIONAL READS: "§3 (Requirements) — read if reviewing FR-vs-FR cross-consistency or NFR fallback chains spanning multiple FRs."
2. In Blake template, elevate §10 from implicit ("other sections only if needed") to a third REQUIRED read alongside diff + §6 + §9. §10 is where blast-radius warnings and known-constraints live, which Blake's post-impl reviewer most needs.

Acceptable to defer to v2.8.5 — L6 v3 PASS as-is with disclosure.

### P0-2. (none beyond P0-1)

---

## P1 findings

### P1-1 [handles spec Q2]. Symmetric alignment between Alex and Blake templates is correct, but with one inconsistency

Alex template uses placeholders `{handoff_path}`, `{list_of_files}`, `{blast_radius_grep_patterns}`, `{expert_specific_focus}` — these are documented Alex SKILL invocation-time substitutions (Alex SKILL `step2_review_invocation` performs `printf` substitution; standard precedent for the existing template).

Blake template uses `{handoff_path}` literally **but does NOT define {git diff <range>}** — instead writes the raw text `git diff <range>` as a placeholder for Blake to fill. This is a contract divergence: Alex's placeholders are mechanical-substitution, Blake's "<range>" is human-fill. Either is fine in isolation, but **not labeling the difference** is a maintainability hazard. Future automation that tries to mechanically substitute Blake's template will see `{handoff_path}` and `<range>` and not know which is which.

**Fix**: In Blake's template, change `git diff <range>` to `{diff_range}` and document at SKILL-section top: "Blake fills `{diff_range}` manually before invoking Agent tool, e.g., `c3ce273..HEAD`". Or alternatively, document inline in the rationale block that `<range>` is intentional human-fill.

Did Blake correctly omit `FILE: {handoff_path}` syntax that Alex used? **YES** — the Alex template's `FILE: {handoff_path}` was for handoff-text-only review; Blake's template correctly substitutes it with diff + targeted handoff sections. Alignment correct on this dimension.

### P1-2 [handles spec Q3]. NFR2 +2 is expected and correct

**Verified**: alex=64 (unchanged from c3ce273), blake=34 (was 32). Δ=+2 from the new `forbidden_implementations` block at lines 1005-1008:
- "MUST NOT register hook to enforce narrow-scope via tool blocking"
- "MUST NOT add to .claude/settings.json"
- "Anti-AR-001: 'narrow scope = skip review' ..."

That block contains exactly 2 occurrences of `MUST NOT` (lines 1006-1007), 0 of `VIOLATION`, 0 net change of `forbidden` (the parent key `forbidden_implementations:` is itself counted, but it was already counted at lines 962+1321 — two existing instances unchanged). Net +2 = 2 new `MUST NOT`. Math checks.

No accidental duplication: I grep-cross-checked the lines 962-968 block (Phase 6-A's existing forbidden_implementations under `hard_requirement_distinct_reviewers`) against the new lines 1005-1008 block. Both blocks live under `layer2_expert_review`, which is correct nesting — they document different rules (≥2 reviewer count vs narrow-scope prompts). Content is non-overlapping; bullets are not duplicated. **Pass.**

### P1-3 [handles spec Q4]. AR-001 three-defense pattern is partially applied — acceptable for L6 scope

The three defenses per architecture.md "Path Layering - 2026-04-24" are:
1. Mechanical SKILL grep — **L6 has this**: AC17 `grep -c "NARROW-SCOPE INSTRUCTION (L6"` = 1, AC18 `grep -c "L6 (2026-04-27 v3)"` = 1, AC19 cross-symmetry. Mechanical detectability ✓.
2. NOT-via-Alex-suggestion — **L6 does NOT have this**, and shouldn't. L6 is template-guidance, not a path/mode/frontmatter-field. There's no AskUserQuestion menu where Alex would offer "narrow-scope-shallow-review" as an option. Defense 2 is N/A.
3. Symmetric forbidden_implementations across sibling features — **L6 has this**: 3-bullet block (no hook, no settings.json, Anti-AR-001) is **shape-symmetric** to the 5-bullet `hard_requirement_distinct_reviewers.forbidden_implementations` (lines 962-968) and the 5-bullet `completion_knowledge_override.forbidden_implementations` (lines 1321-1326). Cardinality differs (3 vs 5) because L6 has fewer attack surfaces (it's prompt-text only, not a runtime mechanism), but the structural pattern (no-hook + no-settings + Anti-AR-001 framing) is preserved.

**Verdict on Q4**: Defense 1 and 3 applied; Defense 2 correctly N/A for template scope. Acceptable.

### P1-4 [handles spec Q5]. Placeholder substitution is real, not literal

Confirmed by reading Alex SKILL `expert_prompt_template` parent context: the existing `{phase}` and `{expert_specific_focus}` placeholders in the SAME template have always been runtime-substituted by Alex's invocation step. The new `{list_of_files}` and `{blast_radius_grep_patterns}` follow the same convention. Risk is they currently have **no documented producer** — i.e., Alex SKILL doesn't yet have a step that explicitly populates them.

Looking at the diff: the placeholders are introduced but no Alex SKILL step is updated to populate them. So at first L6-using invocation, Alex will need to either (a) substitute manually before passing the prompt to Agent tool, or (b) leave the literal `{list_of_files}` token in the prompt for the sub-agent to interpret as "list not provided". Either is workable but **(b) is fragile** — the sub-agent might rationalize "{list_of_files} is empty therefore no files" and skip blast-radius checks.

**Fix recommendation**: Add a one-liner to Alex SKILL `step2_review_invocation` (or wherever the template is consumed): `Before invoking Agent tool: substitute {list_of_files} from §7 Files-to-Modify list, {blast_radius_grep_patterns} from §10 critical-warning grep targets. If §10 has no blast-radius patterns, replace with literal "(none required)".` Defer to v2.8.5; not blocking for v3 PASS.

### P1-5 [handles spec Q6]. L2/L6 lever stack is additive, not compounding

L2 (Alex lazy knowledge load) = "Alex reads fewer knowledge files when drafting handoff". L6 (sub-agent narrow scope) = "sub-agents read fewer handoff sections when reviewing". These operate on different artifacts (project-knowledge files vs. handoff sections) and at different times (Alex drafting vs sub-agent review).

**Compounding-loss concern**: Could L2 → leaner handoff → L6 → reviewers see even less? Walked through:
- L2's leanness affects what Alex CITES into the handoff — specifically what shows up in §📚 Project Knowledge and what shapes §10 Critical Warnings.
- L6 narrows what reviewers READ from the produced handoff. Reviewers always have access to the full §6/§9/§10/diff regardless of L2.
- The risk is: if L2 misses a project-knowledge file that would have warned about blast-radius pattern X, then §10 won't list X, then L6 reviewers won't grep for X.

This is theoretically real but **bounded**: the L2 lazy-load uses keyword + README-driven inclusion with "false positives acceptable, false negatives are not" (per FR3 / handoff §3.1). So under-inclusion in L2 is the explicit guard. The compounding loss is at most equal to L2's own miss rate, not multiplicative.

**Verdict**: levers are additive. No P0/P1 compounding loss.

---

## P2 findings

### P2-1 [handles spec Q8]. Token-savings claim is unaudited; offer two cheap options

The "~50% per review" claim cannot be verified from the diff. To make it auditable post-deploy:

1. **Cheap option**: After 3-5 future Layer 2 sub-agent invocations under L6, Blake records the prompt token count (visible in Agent tool result envelope) and compares to the pre-L6 baseline (any commit before c3ce273 has `expert_prompt_template` without REQUIRED/OPTIONAL/NOT ALLOWED — count the tokens of that vs the new). One row in `.tad/evidence/measurements/` is sufficient. ~10 min effort.

2. **Right option (for Phase 7)**: Add a measurement field to the planned trace-digest hook (Phase 5 P5.4 mentioned in architecture.md) that records sub-agent prompt token cost per invocation. Aggregate 30 days, surface in `*evolve`. Multi-handoff effort.

Defer to v2.8.5+. Not blocking.

---

## Dogfood feedback (P1.7 specifically)

**Did narrow scope hurt this review?**

Mostly no. Concrete observations:

1. **REQUIRED reads were sufficient for P1-2/P1-3/P1-4/P1-5** (NFR2 math, three-defense pattern, placeholder check, lever stack). I had everything I needed in diff + §6 + §9 + §10.

2. **The blast-radius escape valve was load-bearing for P0-1.** The spec explicitly allowed me to read v2 reviewer files as a one-time blast-radius check. Without that exception, I would have had to either (a) trust the handoff's "P0s mostly live in §6/§9/diff" claim without evidence, or (b) refuse to evaluate the claim. Having the explicit allowed-exception worked well — narrow scope held except where evaluating the narrow-scope claim itself required wider reads. **This is a healthy template design**: scope rules with documented exception channels for rules that are themselves under review.

3. **§3 Requirements was not in REQUIRED.** I read §3.1 anyway (FR6/FR7 lookup, mentioned as "OPTIONAL" but in practice mandatory for understanding what L6 promises). The OPTIONAL classification of §3 in Alex template is a minor sub-finding behind P0-1 — for architectural review specifically, §3 should be REQUIRED, not OPTIONAL. UI-flow / usability reviews may not need §3, so blanket-promoting it across all reviewer types is wrong; instead the `expert_specific_focus` per reviewer-type should specify whether §3 is required for that reviewer (similar to how `prompt_focus` already specializes per reviewer in Alex SKILL `experts_to_invoke`).

4. **Would I have caught more P0s with full handoff access?** Honestly — probably not many. The v2 review at c3ce273 already caught the deep architectural issues (NFR1 fallback drift, AR-001 anchor regex fragility). L6 itself is a small surface. Narrow scope here was right-sized.

**Net**: L6 narrow scope is appropriate for **post-impl review of small additive changes** (this case). For post-impl review of **major structural changes** (e.g., a future Phase 7 changing Layer 2 protocol), the OPTIONAL classification of §3/§4/§11 may bite. The template should grow a "review depth level" parameter (`shallow` for additive prose / `deep` for structural change) selected by Alex at invocation time.

---

## Verdict rationale

**CONDITIONAL PASS**.

L6 implementation is correct on the four criteria the spec asked me to evaluate:
- Token-savings claim (P0-1): directionally correct, with documented gap (~40% of v2 P0s were outside narrow scope) — disclose, don't block.
- Symmetric alignment (P1-1, Q2): correct; minor placeholder-convention inconsistency.
- NFR2 preservation (P1-2, Q3): math verified; +2 is expected, no duplication.
- AR-001 defense pattern (P1-3, Q4): defenses 1+3 applied, defense 2 correctly N/A for template scope.

The only non-trivial concern is P0-1's classification gap: §10 is REQUIRED in Alex template but not in Blake template, and §3 is OPTIONAL on both — yet 40% of v2 P0s came from §3 + §10 cross-checking. This is a template-hardening concern, not an L6-implementation defect.

**Pre-merge fixes**: none required.

**Defer to v2.8.5 / Phase 7**:
1. Elevate §10 to REQUIRED in Blake template (P0-1).
2. Document Blake's `<range>` vs Alex's `{placeholder}` substitution convention divergence (P1-1).
3. Add Alex SKILL `step2_review_invocation` substitution-step for `{list_of_files}` and `{blast_radius_grep_patterns}` (P1-4).
4. Add cheap token-savings audit row after 3-5 invocations (P2-1).

L6 v3 PASS for ship.

---

**Word count**: ~1180.
