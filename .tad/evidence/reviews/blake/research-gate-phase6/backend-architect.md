# Backend-Architect Review — research-gate-phase6 (PART A)

Reviewer: backend-architect (blue-team architecture review)
Date: 2026-05-31
Artifact: HANDOFF-20260531-research-gate-phase6.md
Grounded against: alex/SKILL.md research_decision_protocol (L2700), step1_identify_decisions (L2712), step2_5_notebook_check (L2745), STEP 3.8 (L178), research_notebook_awareness (L885)

---

## FOCUS 1 — Gate placement & the three-nudge overlap

There are now **four** research-surfacing sites, not three, and the handoff only names three:

1. **STEP 3.8** (L178) — activation-time, OBJECTIVES-vs-REGISTRY gap scan. Output: "💡 建议: 运行 *research-plan". Non-blocking, session-start.
2. **research_notebook_awareness** (L885) — *discuss entry, per-topic. Sub-step 4 ALREADY does the exact thing this handoff proposes: "no matching notebook AND topic needs deep research → AskUserQuestion: 这个话题可能需要深度研究。要创建一个 research notebook 吗？" with create/WebSearch options.
3. **step2_5_notebook_check** (L2745) — INSIDE research_decision_protocol, the same protocol Part A targets. Already checks REGISTRY for a matching notebook before Landscape Search.
4. **NEW research-gate** (this handoff) — *analyze decision-identification, AskUserQuestion: "决策依赖外部信息，没有相关 notebook。要先研究吗？"

The placement is coherent in the sense that *analyze is the right moment for a per-decision nudge. But the de-dup story in the handoff (§10: "if STEP 3.8 already surfaced the same notebook gap this session, the gate should not re-nag") is **incomplete and architecturally insufficient as written** — see P0/P1.

## FOCUS 2 — Classification reproducibility (external-info vs internal/preference)

The distinction is sharper than the Phase 4 effort-scaling signals because it has a **concrete decidability test** baked in: "decidable from the repo/requirements itself" = internal; "turns on facts the agent can't derive from codebase" = external. That is closer to mutually-exclusive than effort-scaling's size buckets. But it is NOT default-safe (see P1) — the failure mode the handoff fears ("every decision feels like it could benefit from research") is real because "best approach for Y" subsumes almost any design decision. Phase 4's lesson (signals must be mutually exclusive + default-safe) is only half-satisfied.

## FOCUS 3 — Right-moment vs usage-count

Per-decision firing inside *analyze IS the right mechanism for "prompt the projects that should." The negative guard is the correct lever — but a guard that only lists positive/negative examples in prose is a soft classifier, and the audit's own root cause (3/14 adoption) was a *missing* prompt, not a mis-targeted one. There is no evidence in the handoff that over-prompting was ever the problem, so the negative guard is defending against a hypothesized future failure. That's fine, but it means AC6.2's weight should be on **default-to-silent** semantics, not example lists (see P1).

## FOCUS 4 — AC6.3 (sync) separability

Cleanly separable. The research-gate is a SKILL.md edit to one file (alex/SKILL.md) and is fully functional in THIS project the moment it ships. *sync only propagates the edit to 14 other projects — it adds reach, not function. The gate has zero runtime dependency on sync. Deferral is architecturally clean. AC6.3 documentation-only check (Epic map row stays "deferred") is the right closure.

---

## P0 — De-dup across the FOUR sites is under-specified and will double-prompt in the most common path

The handoff treats this as "don't duplicate STEP 3.8." But the real collision is with **research_notebook_awareness sub-step 4** (L908-917), which fires in *discuss and already asks the identical create-notebook question. The standard TAD flow is *discuss → *analyze in the SAME session. So:

- User raises a topic in *discuss → research_notebook_awareness fires "要创建 notebook 吗?" → user says "WebSearch 够了" (declines).
- Same session, Alex enters *analyze on the same external-info decision → NEW research-gate fires the SAME question again.

The user just declined this exact prompt minutes ago. This is the textbook annoy-pattern the handoff claims to prevent, and §10 does not mention research_notebook_awareness at all — only STEP 3.8 (a different, lower-collision site because it's objective-level not decision-level).

Prose-only de-dup ("should not re-nag") is **not implementable** by an LLM across a long session — it requires the agent to recall, mid-*analyze, that a semantically-equivalent prompt was declined in *discuss. That recall is exactly the kind of cross-phase state the project's own "Two-Layer Compact Recovery" lesson says must live on-disk, not in conversation memory.

**Fix:** Add a session-level flag (e.g. a `research_prompt_state` marker — declined-domains list keyed by decision-domain slug). All FOUR sites read/write it: before firing, check "已就此 domain 提示过且被拒绝？→ skip." Without a shared flag, the de-dup requirement is unenforceable and AC6.1 will produce the regression it's meant to avoid. Minimum viable: a conversation-scoped "declined research for {domain}" note that the gate checks. The handoff's own §12 cites "use conversation memory for same-session transitions" (Storage and Lifecycle Patterns) — but that lesson is about status transitions, not about suppressing a repeated AskUserQuestion across two protocols; relying on it here is a misapplication.

## P1 — Negative guard as example-list is not default-safe; needs an explicit default-deny + a decidability test

AC6.2 specifies the guard as "documented with examples (config value, naming, refactor mechanics, download-plugin)." Example lists are open-world: any decision not matching an example is undefined, and the LLM's bias (the audit's whole premise is that research is under-triggered, suggesting the model leans toward "internal/just-build") could swing either way once a prompt is added. Phase 4's lesson is explicit: **default-safe**. Here "safe" = silent (do not fire) unless the decision *clearly* needs external facts.

**Fix:** Reframe AC6.2 from "list internal examples" to "**default is SILENT; fire ONLY when the decision provably turns on a fact absent from the repo AND requirements.** When ambiguous → do not fire." This makes the guard a default-deny rather than an example-match. Add the single decidability test as the operative rule (the handoff already has the right phrasing at §4: "decidable from the repo itself"); the examples become illustrations, not the contract.

## P1 — "no relevant notebook exists (check REGISTRY)" duplicates step2_5_notebook_check; the gate should reuse, not re-implement, the REGISTRY lookup

step2_5_notebook_check (L2745, INSIDE the same protocol) already performs the REGISTRY match for the decision's domain. The new gate at step1_identify_decisions also "check REGISTRY." That's two REGISTRY lookups in one protocol run with no shared result. Beyond redundancy, if the two lookups use different matching phrasing they can disagree (gate says "no notebook," step2_5 finds one). This is the "two REGISTRY checks can diverge" hazard.

**Fix:** Either (a) have the gate at step1 set a `notebook_present_for: {domain}` result that step2_5 consumes, or (b) explicitly state the gate's REGISTRY check uses the IDENTICAL semantic-match criterion as step2_5_notebook_check and L885. Cross-reference the two in the SKILL text so a future editor keeps them in sync. (Per the project's "peer references missed by review → broader grep" lesson — make the linkage explicit in-text.)

## P2 — Placement ambiguity: step1_identify_decisions vs step2_research entry

§4 says "step1_identify_decisions (or step2_research entry)." These are different moments: step1 is pre-research classification; step2 is research execution. The gate logically belongs at the END of step1 (after decisions are classified, before step2 research begins) — that's where "should we research at all / via notebook?" is the right question. Firing it inside step2 is too late (research already started). Blake should pick step1-tail explicitly, not leave it as an either/or, to avoid the "transition arrow audit" class of bug (the project's Step-Insertion lesson: update predecessor transition, grep for successor refs).

## P2 — AC6.4 grep `DR-20260531`=9 is a self-referential fragility

The carve-out non-edit check counts a date-slug string. If Blake's own COMPLETION/review files (written this session) mention `DR-20260531` in prose, the count inflates — this is precisely the project's documented "Parser Self-Trigger / AC Self-Leak from Removal Rationale" pattern (2026-04-27, 2026-05-30). The AC verifies the SKILL.md region only, so Blake must scope the grep to the file (`grep -c 'DR-20260531' .claude/skills/alex/SKILL.md`), not the repo. Confirm the literal `9` was dry-run on the current file (per the project's mandatory AC dry-run rule); the handoff §9.2 "Verified Output" column is empty.

---

## Overall

**Verdict: REVISE before implementation (1 P0).**

Placement is sound (FOCUS 1 partial-yes), classification is more reproducible than Phase 4's signals but not default-safe (FOCUS 2), right-moment mechanism is correct (FOCUS 3), and sync deferral is cleanly separable (FOCUS 4). The blocking issue is **FOCUS 1's de-dup**: the design under-counts the overlap (four sites, not three) and misses the highest-collision peer (research_notebook_awareness sub-step 4, which asks the identical question one phase earlier in the same session). Prose-only "don't re-nag" is not enforceable by an LLM across protocol boundaries — it needs a session-level shared flag (P0). With the P0 flag added and the negative guard reframed as default-deny (P1), this is a clean, low-risk, ~20-line cognitive-firewall-embedded enhancement consistent with the project's "insert, don't create" and "suggestion never block" principles.

Recommended order: fix P0 (shared declined-domain flag, all four sites) → P1 default-deny guard → P1 reuse step2_5 REGISTRY lookup → P2 placement at step1-tail → P2 scope/dry-run AC6.4 grep.
