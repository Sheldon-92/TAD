# Dogfood Judgment — agent-orchestration capability pack

**Task**: Review of a 300-step autonomous research agent built as a fully-connected 10-agent swarm with no shared context, wrapped in a whole-run try/except retry loop. Producing incoherent reports + stopping early. User wants to "upgrade to a bigger model."

**Date**: 2026-06-13
**Judge**: independent technical judge (skill-blind)

---

## Verification log (WebSearch against primary sources)

| Claim (which answer) | Verified value | Verdict |
|---|---|---|
| A2: MAST distribution 42% / 37% / 21% | Canonical MAST (arXiv 2503.13657): Specification/System-Design **41.8%**, Inter-Agent Misalignment **36.9%**, Verification **21.3%** | CORRECT (rounding) |
| A2: 42%+37% ≈ 79% spec+coordination | 41.8+36.9 = 78.7% ≈ 79% | CORRECT |
| A2: premature termination is a verification failure | MAST verification family = premature termination 6.2% + incomplete verification 8.2% + incorrect verification 9.1% = 21.3% | CORRECT |
| A2: κ=0.88, 1600+ traces, 7 frameworks | Confirmed (6 expert annotators, κ=0.88; MAST-Data 1600+ traces across 7 frameworks). NB: original taxonomy built from 150 traces; 1600+ is the extension dataset — A2 doesn't misstate this. | CORRECT |
| A2: P(fail)=1-(0.99)^300=95.1% | 1-0.99^300 = 1-0.0490 = 0.951 | CORRECT |
| A2: P(fail)=99.8% at p=0.02 | 1-0.98^300 = 1-0.00225 = 0.9977 ≈ 99.8% | CORRECT |
| A2: 10-agent fully-connected = n(n-1) = 90 directed pathways | 10×9 = 90 | CORRECT |
| A2: Cognition single-writer / Flappy-Bird / single-threaded-linear | Confirmed: Super-Mario-style background + mismatched bird; "single-threaded linear agent, continuous context" is Cognition's headline recommendation | CORRECT |
| A2: Temporal event-sourcing replay, resumes from event log, no re-run of completed activities/side-effects | Confirmed by Temporal docs + multiple 2026 guides | CORRECT |
| A2: LangGraph `durability='sync'/'async'/'exit'`, AsyncPostgresSaver checkpointer | Confirmed real, current API names | CORRECT |
| A2: max_retries=0 to avoid double-retry under Temporal | Consistent with Temporal+client retry guidance | CORRECT (sound) |
| A1: "coordination cost grows ~quadratically with agents" | Matches n(n-1) handoff-surface; correct but unquantified | CORRECT |
| A1: shared-state / supervisor / checkpoint-resume / idempotency / context-mgmt / termination | All directionally correct, no false specifics | CORRECT |

**No wrong specifics found in either answer.** Both are factually clean.

### Minor caveat (not an error)
A2's rule IDs (FM3, FM4, FM5, SUP1-4, OW1-3, DUR1-9, OW3) are the **skill pack's internal rule labels**, not MAST's official failure-mode codes (MAST uses its own FC-x.x numbering). A2 cites them as "(failure-modes)" / "(orchestration-patterns)" so it's transparent about provenance, but a reader unfamiliar with the pack could misread "FM3" as a canonical MAST code. Substance is correct; only the label namespace is internal.

---

## Scores

### Answer 1 (general)
- Correctness: **5** — every claim directionally correct, zero false specifics.
- Actionability: **4** — clear prioritized 6-step redesign; "do these in order, stop when metric fixed" is good guidance. Loses one point: no named tools/frameworks, so the reader still has to choose the implementation substrate.
- Specificity: **2** — no numbers, no named frameworks, no sourced thresholds. "Quadratic" is the only quantitative gesture and it's unquantified.
- Completeness: **4** — covers all five failure modes + the model rebuttal + a prioritized plan. Misses: durability mechanism (event sourcing vs bare checkpoint), explicit P(fail) framing, verifier-gate concept named, framework options.

### Answer 2 (skill-backed)
- Correctness: **5** — all load-bearing specifics WebSearch-verified correct (MAST split, P(fail) math, n(n-1), Cognition, Temporal, LangGraph API). Internal rule-ID labeling is the only nit and it's transparent, not wrong.
- Actionability: **5** — P0/P1/P2 triage, named topology (Supervisor/orchestrator-worker), two concrete framework paths (Temporal event-sourcing OR LangGraph StateGraph+AsyncPostgresSaver+durability='sync'), max_retries=0, verifier gate, re-grounding step. A builder can act immediately.
- Specificity: **5** — verified numbers and named, current tools throughout; specificity is earned, not padding.
- Completeness: **5** — maps all three symptoms to failure classes, quantifies the cliff, rebuts the model upgrade with the 79% figure, gives durability + verification + spec-quality + drift mitigations, plus topology recommendation.

---

## Winner: Answer 2 — margin: clear

**Both answers reach the same correct core diagnosis** (no-shared-context is the root cause of incoherence; mesh topology is wrong; whole-run retry re-runs side effects and causes the early stop; bigger model fixes none of it). Answer 1 is genuinely good — well-structured, correctly reasoned, no errors. In a vacuum it's a strong B+ review.

Answer 2 wins on **correct, verified specificity**, not verbosity:
1. It **quantifies** the user's situation (P(fail) ≈ 95% at their exact 300 steps) — turning "your retry loop is risky" into "your run has a 95% chance of hitting an infra failure, and a bare loop re-runs every side effect on restart." That is decision-changing.
2. It **names the diagnosis against research** (MAST 79% spec+coordination) so the "bigger model" rejection is evidenced, not asserted.
3. It gives **named, current, verified implementation paths** (Temporal event sourcing vs LangGraph durability modes) and concrete settings (max_retries=0, durability='sync' for side-effecting steps) — Answer 1 stops at "make tool calls idempotent / checkpoint-resume" without telling the user what to build on.
4. It adds the **spec-quality lever (FM2/42%)** — explicit subagent input/output contracts and stop conditions — which Answer 1 omits entirely, even though it's the single largest MAST failure category and directly relevant to a swarm with vague handoffs.

Critically, I verified the added specificity is **accurate**. A confident-but-wrong specific would have tanked A2; instead every checked number and API name holds up. So the win is on correctness-of-specifics, not length.

The one cost of A2: heavier rule-ID jargon (FM3/SUP3/DUR1) that reads as internal-citation noise to an outside reader, and the internal labels could be mistaken for canonical MAST codes. This is a presentation nit, not a correctness problem, and doesn't offset the substantive advantages.

**Margin is "clear" rather than "decisive"** because Answer 1 is correct and complete enough to lead the user to a working redesign on its own — A2 doesn't fix a wrong answer, it sharpens a right one into something immediately buildable.
