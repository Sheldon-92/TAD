# Phase 1 Design Review (Gate 2) — nondev verdict_shape (categorical + checklist)

**Reviewer:** Architecture (Alex-side expert sub-agent)
**Date:** 2026-06-06
**Handoff under review:** `.tad/active/handoffs/HANDOFF-20260606-nondev-verdict-shapes-p1.md`
**Verdict shape under scrutiny:** `categorical` (BUILD/PIVOT/KILL, judged on rigor) + `checklist` (export-spec pass/fail)
**Scope of review:** design soundness only — no files edited.

---

## Summary table

| Focus | Result |
|---|---|
| 1. Rigor-band decoupling enforced? | Mostly — one residual leak path (P1-1) |
| 2. Checklist semantics sound? | Two edge-case ambiguities (P1-2, P2-1) |
| 3. Gate 4 shape-agnostic? | Holds for the grep; but a stale weighted-only Critical-Check line in Gate **3** (P1-3) |
| 4. judge≠producer + file-paths-only preserved? | Yes — preserved and re-stated per shape (PASS) |
| 5. Contract §B.4/§B.5/§C consistency? | Consistent; this work is the contract's own anticipated BA P1-3 follow-up (PASS) |
| 6. Scope coherence (checklist w/o dogfood)? | Real risk — unverified gate logic ships (P1-4) |

No P0. The design is sound in architecture and faithfully additive. The findings below are hardening, not blockers — except that P1-4 (scope) needs an explicit human decision.

---

## P0 (blocking)

None.

The core architecture is correct: additive sub-blocks under `Verdict_Mapping`, weighted path byte-preserved (AC2), guard widened to a 3-element allow-set, Gate-4 token left untouched. AC7 verified independently: `.tad/codex/` contains only `manual-gates.md`, no gate mirror → no parity regen needed (handoff §6 claim is true).

---

## P1

### P1-1 — Residual leak path: the band is judged by ONE agent that also SEES the BUILD/PIVOT/KILL conclusion; the decoupling rests entirely on prose instruction, with no structural firewall

**The decoupling mechanism in Edit B/C is purely admonitory.** Edit B `rigor_independence` and Edit C `judge_prompt_by_shape.categorical` both *tell* the judge "do not raise/lower the band based on the BUILD/PIVOT/KILL conclusion." But the same judge sub-agent reads the artifact, observes that it concluded (say) KILL, AND assigns the band — in one pass, with the conclusion fully in context. There is no structural separation between "perceive the conclusion" and "score the rigor."

This is the same failure class the lane was built to defend against: the contract's foundational rule (§C.2, guide §3) is that **self-enhancement / anchoring bias is defeated structurally (a separate agent), not by asking nicely.** Here the conclusion-anchoring risk is defended *only* by asking nicely. Known LLM-judge biases (the very self-enhancement literature the Phase-3 dogfood cited) include outcome/conclusion bias: a judge that already knows the verdict tends to retrofit its rigor assessment to feel consistent with a "strong" or "weak" conclusion.

Cite: Edit C says "do NOT reward/punish the BUILD/PIVOT/KILL conclusion" — an instruction, not an enforcement. Compare guide §3: "Independent judging is the only defense; [an instruction] is validation theater."

**Concrete hardening (pick at least one, none requires new infra):**

1. **Order-of-emission firewall (cheapest, recommended).** Require the judge to emit and justify `band:` *with per-criterion rigor evidence* BEFORE it is permitted to read/state `content_verdict:`. I.e. the rubric-eval file's required structure is: (a) rigor scoring section citing specific evidence per rigor criterion → (b) `band:` derived from (a) → (c) ONLY THEN `content_verdict:` recorded as a trailing fact. The handoff's `extra_output` currently lists `band:` and `content_verdict:` as peer lines with no ordering or justification requirement — that permits the judge to decide both simultaneously. Add to Edit B `extra_output`: "band: MUST be justified by per-rigor-criterion evidence BEFORE content_verdict is stated; content_verdict is recorded last, as a non-scoring fact."

2. **Rigor rubric must enumerate conclusion-neutral criteria.** The decoupling is only real if the rubric the judge applies contains rigor dimensions that are literally evaluable on a KILL and a BUILD identically (e.g. "assumptions made explicit", "disconfirming evidence sought", "alternatives considered", "failure modes named"). If the Phase-4 rubric (out of scope here, but this gate text is what governs it) leaves "rigor" undefined, the prose decoupling has nothing to stand on. Recommend Edit B's `rigor_independence` add: "the rubric MUST define rigor as criteria evaluable identically regardless of which conclusion was reached."

3. **Symmetry probe in the band definition.** State the invariant as a testable claim the judge must self-check: "Swap test: if the same evidence/argument quality had concluded the opposite verdict, the band MUST be identical." This converts the abstract rule into a concrete check the judge can apply.

Without at least #1, the human's locked decision ("a rigorously-argued KILL must PASS") is asserted but not architecturally guaranteed — exactly the "count ≠ signal / instruction ≠ enforcement" pattern in this project's principles.

### P1-2 — checklist semantics: "all-optional rubric" and "zero required items" collapse the ladder, and the rule as written silently PASSes a content-empty artifact

The checklist rule (Edit B) is:
```
ALL required pass                     → PASS
ALL required pass, ≥1 optional fail   → PARTIAL
ANY required fail                     → FAIL
```

Edge cases the rule does not resolve:

- **Zero required items (all-optional rubric).** "ALL required pass" is vacuously true when there are no required items, so the artifact lands PASS or (if any optional fails) PARTIAL — and can NEVER be FAIL no matter how many optional items fail. A checklist rubric that is entirely optional becomes a gate that cannot fail. That is a degenerate, footgun configuration. Add a guard: "A checklist rubric MUST declare ≥1 required item; a rubric with zero required items → BLOCK Gate 3 (mis-authored rubric, same spirit as the no-silent-default Rubric_Resolution)."

- **Zero items at all / empty rubric.** Same vacuous-truth path → PASS on an empty rubric. Covered by the same ≥1-required guard.

- **"pass/fail" of an individual item is undefined here.** For export specs (dB / format / duration) the item-level predicate is a band/equality test, but the rule never says the judge derives pass/fail from *measured evidence in the artifact* vs *the spec threshold*. Without that, the judge could mark items pass on the artifact's self-claim — re-opening the artifact-channel VIOLATION (Judge_Not_Producer #4). Recommend Edit B checklist `extra_output` add: "each item's pass/fail is derived from evidence the judge independently extracts (measured value vs spec), NOT from the artifact's own claim of compliance."

### P1-3 — Gate 3 Critical Check line L473 is weighted-only and is NOT in the edit set → a categorical/checklist PASS will fail this hard-coded check item

Gate 3's `Critical Check (4 items)` at **L473** reads:
```
- [ ] Rubric weighted score ≥ pass_threshold (scored by independent judge)
```
This is weighted-specific ("weighted score ≥ pass_threshold"). A categorical artifact has a **band**, not a weighted score; a checklist artifact has **all-required-pass**, not a score-vs-threshold. The handoff's five edits (A–E) do NOT touch this line. After the edits, a categorical/checklist deliverable reaches a Gate-3 checklist item it cannot literally satisfy as phrased — the executing agent must either improvise (defeating "do not improvise structure", §3) or mark a weighted criterion N/A with no guidance.

Same issue, lower severity, at **L397** (judge_prompt_constraint blue-team framing): "Report dimension scores + weighted average + verdict." This weighted-only sentence stays, and Edit C *appends* a shape-aware paragraph after it — so for categorical/checklist the judge gets contradictory framing (the original line still says "weighted average"). Edit C says "do NOT delete the existing blue-team text", which is right for the weighted case, but the combined prompt for a categorical judge now contains a stale "report weighted average" instruction.

**Hardening:** add a sixth edit (Edit F) that makes L473 shape-aware, e.g.:
```
- [ ] Rubric verdict ≥ pass bar per verdict_shape (weighted: score ≥ pass_threshold · categorical: band=rigorous · checklist: all required pass) — scored by independent judge
```
And in Edit C, prefix the appended paragraph with one clause neutralizing L397 for non-weighted shapes: "(For categorical/checklist the 'weighted average' clause above is N/A — use the per-shape framing below.)" These two are load-bearing for the design to actually function end-to-end; AC6's "additive lines only" still holds if L473/L397 are edited *in place* minimally, but the handoff currently asserts the weighted bullets are untouched (Edit D: "do NOT edit the existing weighted bullets"). The Critical Check line is a separate artifact from the output_format bullets, so editing it does not violate Edit D — but the handoff should call it out explicitly so Blake does not skip it under the "purely additive" framing.

### P1-4 — Scope: implementing `checklist` gate-side WITHOUT any dogfood ships unverified gate logic; this is the exact "Validation Theater" finding from the YOLO audit

Handoff scope = "implement both shapes gate-side, dogfood only product-thinking (categorical)." That means `checklist` gate logic (the required/optional → verdict ladder, Edit B) ships **with zero end-to-end exercise** — no artifact, no rubric, no judge run. The packs that would use it (ai-voice, video) are `rubric-tbd` and hardware-blocked (guide §6/§7), so there is no near-term forcing function to discover a defect.

This is precisely the project's recorded **"Validation Theater"** principle (2026-05-15 YOLO audit) and the structural-vs-paper-verification lesson: structural checks (the AC5 grep that `verdict:` is mandated; AC4 grep that the branch exists) prove the *text is present*, not that the *logic discriminates*. The Phase-3 dogfood proof for `weighted` was load-bearing precisely because round-1 landed an honest 0.737 PARTIAL — a real discrimination, not a rubber stamp. `checklist` gets no equivalent.

**This is the one finding that needs a human decision, not just a Blake edit.** Three coherent options:

- **(a) Defer checklist to Phase 2** — implement only `categorical` now (which IS dogfooded), keep the guard BLOCKing `checklist`. Cleanest: nothing ships unverified.
- **(b) Add a paper/fixture dogfood for checklist** — a tiny synthetic rubric (3 required + 1 optional export-spec) + a synthetic artifact + one judge run, proving the ladder produces PASS / PARTIAL / FAIL on three crafted inputs. Cheap, no hardware, gives the discrimination proof. Recommended if checklist must ship now.
- **(c) Ship both, accept the risk** — only acceptable if logged as an explicit decision (DR) citing the Validation-Theater principle, so it is not a silent gap.

As written, the handoff implicitly chooses (c) without logging it. Recommend (a) or (b).

---

## P2

### P2-1 — checklist "required vs optional" needs a single declared source of truth

The rule keys entirely on which items are `required` vs `optional`, but nothing in the edits says WHERE that classification lives (the rubric file? a registry field?). If the judge infers required/optional from artifact context, that is producer-channel leakage again. Minor because Phase-4 rubric authoring will settle it — but the gate text should state "required/optional is declared by the rubric, not inferred by the judge."

### P2-2 — `content_verdict:` line will be grepped by nothing, but sits adjacent to the Gate-4 token — confirm no accidental anchor collision

Gate 4 greps `^verdict: PASS`. The new categorical output adds `content_verdict: BUILD|PIVOT|KILL` and `band: ...` as own-lines. `^verdict:` will NOT match `^content_verdict:` (different prefix) or `^band:`, so no collision — the claim in Edit E (shape-agnostic) holds. Flagging only to confirm the design intentionally chose `content_verdict:` (prefixed) rather than `verdict: BUILD` (which WOULD collide with the Gate-4 grep and corrupt acceptance). The design got this right; AC should assert it: add a verification grep that `^verdict:` in a categorical rubric-eval matches only PASS/PARTIAL/FAIL, never BUILD/PIVOT/KILL.

### P2-3 — Edit A guard message lost the explicit "BLOCK" verb in one reading

Edit A's new `rule:` says "→ BLOCK Gate 3" (good). The `message:` is now generic ("An unrecognized shape must NOT be silently mis-scored"). Original message named the consequence concretely. Minor wording: keep "→ BLOCK Gate 3" salient in the message too, so an operator who sees only the message knows the gate halts.

### P2-4 — fence-balance sanity check in §5 is necessary but not sufficient

The verification `count('\`\`\`')%2==0` catches an odd number of fences but not a mis-nested YAML block (e.g. an inserted block that breaks the enclosing ```yaml of the Gate 3 section). Recommend adding a structural parse: confirm the Gate-3 block still reads as one contiguous ```yaml … ``` region (e.g. the next ``` after L345 still closes at L483, not earlier). Cheap insurance for an "insert between existing lines" edit.

---

## Cross-check of the six review questions

1. **Decoupling enforced?** Architecturally intended, prose-only enforced → P1-1 hardening required (order-of-emission firewall + conclusion-neutral rigor criteria + swap test).
2. **Checklist semantics sound?** Sound for the normal case; degenerate on zero-required / all-optional (P1-2) and under-specified on item-level pass/fail provenance (P1-2) and required/optional source (P2-1).
3. **Gate 4 shape-agnostic?** YES for the `^verdict: PASS` grep — nothing in the Gate-4 branch (L758-821) references weighted_score; it greps the token only. Confirmed against L782-784. The shape-leak risk is in **Gate 3** (L473 Critical Check, L397 framing), not Gate 4 → P1-3.
4. **judge≠producer + file-paths-only preserved?** YES. Edit C closes with "All shapes keep judge≠producer + file-paths-only"; Judge_Not_Producer (L420-434) is untouched; judge_inputs (L391-394, file paths only) untouched. Preserved.
5. **Contract §B.4/§B.5/§C consistency?** Consistent. The contract explicitly logged this as **BA P1-3 OPEN RISK** ("§B.5's weighted-0-1 ladder does NOT generalize … Phase 4 MUST either convert to weighted-0-1 OR admit a second verdict_shape"). This handoff takes the "admit a second verdict_shape" branch the contract sanctioned. No contradiction with §B.4 (output_format) or §C (judge≠producer). One nuance: §B.4 says "weighted_score shown explicitly with the arithmetic" as a flat requirement — Edit D correctly makes that conditional per shape, which is a *refinement* of the contract, not a contradiction; worth noting in the completion report that §B.4 is now shape-conditional.
6. **Scope coherence?** Categorical (dogfooded) is coherent. Checklist (no dogfood, hardware-blocked consumers) ships unverified logic → P1-4, needs human decision (defer / fixture-dogfood / log-the-risk).

---

## Overall: CONDITIONAL PASS

The architecture is correct and faithfully additive; the weighted path is byte-preserved; Gate 4 is genuinely shape-agnostic; judge≠producer is preserved. No P0.

Conditions to clear before implementation:
- **P1-1**: add the order-of-emission firewall (band justified before content_verdict) + conclusion-neutral rigor criteria + swap-test to Edit B/C — the locked "rigorous KILL must PASS" decision is otherwise prose-only, not enforced.
- **P1-2**: guard zero-required / all-optional checklist rubrics (BLOCK) and require item pass/fail derived from independent evidence.
- **P1-3**: add Edit F to make the Gate-3 Critical-Check line (L473) shape-aware and neutralize the stale "weighted average" clause (L397) for non-weighted shapes — otherwise the new shapes hit a check item they cannot satisfy as phrased.
- **P1-4**: HUMAN DECISION — defer checklist, add a fixture dogfood, or log the Validation-Theater risk as a DR. Do not ship checklist silently unverified.
