# Code Review — research-gate-phase6 (Layer 2, POST-IMPL)

**Reviewer:** code-reviewer (blue-team) | **Date:** 2026-05-31
**Commit:** 7d41768 (worktree agent-a1f27b5a3c27bcf16)
**Artifact:** `.claude/skills/alex/SKILL.md` (+53 lines, gate region L2730–2773)
**Scope:** research-gate (AC6.1/6.2/6.4/6.5). AC6.3 *sync correctly DEFERRED (not implemented, not run).
**Note:** pre-impl spec review preserved at `code-reviewer-preimpl.md` (its P1-1/P1-2 are resolved by this impl — see below).

## Overall: PASS — no P0/P1. 2× P2 advisory (non-blocking). All FOCUS items confirmed.

---

## P0 (must fix)
None.

## P1 (should fix)
None. (Pre-impl P1-1 region-grep and P1-2 dedup-mechanizability are both resolved — see FOCUS 1 and 2.)

## P2 (consider)

**P2-1 — `declined_research_domains` "domain" key has no normalization rule.**
The set is declared at `SKILL.md:2737`; reads at `:2753`; writes at `:2765`, `:2766`, `:922`, `:213`. Membership match at `:2753` relies on the agent computing a stable "domain" string for both the *discuss-side topic and the *analyze-side decision. No normalization is specified, so a *discuss decline keyed "TTS vendor选型" and an *analyze decision domain "voice cloning library" may fail to match → one redundant prompt. This is an LLM-semantic-match design consistent with STEP 3.8 §4b ("LLM semantic judgment"), acceptable for a suggestion-only gate. Suggest a one-line "match by LLM semantic judgment over domain, mirroring STEP 3.8 §4b". Worst case = one dismissable prompt, never a block.

**P2-2 — Session-set lifetime asserted but no reset/teardown semantics.**
`:2735` says the set "lives for this *discuss→*analyze session" but no rule states when it clears. On a single-user CLI conversation reset clears it naturally, so this is fine per "Mechanical Enforcement Rejected on Single-User CLI." Flagging only: in one very long session spanning unrelated *analyze runs, a stale decline could silently suppress a legitimate later nudge.

---

## FOCUS findings (all CONFIRMED)

**1. Non-blocking / suggestion-only — CONFIRMED.** Gate region (`:2730–2773`) uses only neutral verbs ("stay silent", "skip", "proceed", "suggestion only"). `:2771–2772` explicit: "Declining proceeds straight to design / step2_research; the gate stays silent and never stops the flow." All three options (`:2764–2766`) proceed; none halt. Region `grep -cE 'BLOCK|deny|return.*fail'` = 0; case-insensitive block/deny scan also 0. Resolves pre-impl P1-1: the anchor comments now bound a real region so the negative grep is reproducible (was 30 file-wide, now 0 in-region).

**2. declined_research_domains real read+write (not prose) — CONFIRMED.**
- WRITE on decline: BOTH non-create options write — `:2765` ("WebSearch 够了" → append), `:2766` ("我已了解，直接设计" → append), reinforced `:2768–2770`. Satisfies backend-architect N2.
- READ for dedup: `:2753` membership check before firing.
- Cross-site appends are REAL mechanism, not prose: STEP 3.8 `:211–213` and research_notebook_awareness sub-step 4c `:920–923` both append the declined domain, both reference the gate as honoring consumer. Resolves pre-impl P1-2 (the shared session set IS the mechanism the pre-impl review asked for). Spot-verified each region match (`:2737` declare / `:2753` read / `:2765`,`:2766`,`:2769` write) is a mechanism site, NOT a rationale comment. Region count = 5 (≥2 required); file-wide = 7.

**3. Default-safe decidability test + ambiguous→no-gate — CONFIRMED.** `:2741–2750`: discriminating Q "Is this decision decidable from the repo + requirements alone?"; YES→silent; **AMBIGUOUS→silent** (`:2744`, "Ambiguity always defaults to NO-gate", `:2746–2747`); NO→eligible only on provable external-info dependence (`:2748–2750`). Contract is the test, not an example list (examples are illustrative under the NO branch). Literal grep: "decidable from"=1; ambiguous/ambiguity=2.

**4. REUSES step2_5_notebook_check REGISTRY result (no second scan) — CONFIRMED.** `:2756–2758`: "REUSE step2_5_notebook_check's REGISTRY lookup result (do NOT run a second independent REGISTRY scan)". `step2_5_notebook_check` exists at `:2798`. No duplicate scan introduced. Resolves pre-impl P2-2.

**5. AC6.4 safety guards intact — CONFIRMED.** DR-20260531=9, NOT_via_alex_auto: true=1, codex exec --full-auto=3, gemini -p=3 (all unchanged). Diff touches only SKILL.md + COMPLETION + traces — no SAFETY/carve-out edit, no new hook. No *sync in gate region (`grep -c '\*sync'`=0); AC6.3 left Planned/deferred. Anchors BEGIN=1/END=1.

**6. AC passing on a technicality — NONE FOUND.** Every AC is met by substantive mechanism:
- AC6.1: AskUserQuestion + "依赖外部信息" present as a real prompt (`:2762–2763`), not a stub.
- AC6.5: region count 5 is genuine declare+read+2×write, not padded prose.
- AC6.4 self-leak avoidance (neutral verbs) is the *intended* NEW-2 design, not a dodge — the gate genuinely contains no blocking logic, so the scoped grep correctly reads 0.
- AC6.2: literal greps pass against real contract text, not marker-gaming.

---

## Evidence completeness
- COMPLETION `gate3_verdict: pass` present (`COMPLETION-20260531-research-gate-phase6.md:7`).
- Sibling `backend-architect.md` present in this dir → Tier-1 distinct-reviewer ≥2 satisfied. Canonical sub-agent filenames used (per "Layer 2 Audit Canonical Reviewer Name Drift" lesson) — audit script will recognize them.
- Pre-impl spec review preserved as `code-reviewer-preimpl.md` (per "Expert Review Blind Spots" — keep pre-handoff and post-impl reviews separately suffixed).
