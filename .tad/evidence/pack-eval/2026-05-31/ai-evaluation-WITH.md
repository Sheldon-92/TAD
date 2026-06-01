# Evaluation Review: Chatbot Prompt A/B Test

> Reviewed with the **ai-evaluation** capability pack (v0.1.0).
> References applied: `ab-testing-rules.md` (AB1–AB7), `human-eval-protocol.md` (HE1–HE5), plus the pack's cross-cutting **Judge ≠ Optimizer** rule.

## Your setup as described

- Two prompt variants (A and B) for a production chatbot.
- **n=20** test cases per variant.
- **claude-sonnet** as LLM-as-Judge, picking "which output is better."
- Decision rule: whoever wins, ship.

This has three blocking problems (sample size, judge model, decision rigor) and several required fixes. The short version: **as designed, this eval cannot tell a real improvement from random noise, and the judge is structurally biased toward one of the two arms.** Do not ship a winner off this setup.

---

## P0 — Blocking (must fix before running eval)

### [P0] AB1 — n=20 is statistically meaningless for declaring a winner
At n=20 the Wilson 95% confidence interval half-width is **±15–20 percentage points**. A "win" of 12/20 vs 9/20 (60% vs 45%) is entirely inside the noise band — you literally cannot distinguish a 60% system from a 45% system at this sample size. The pack rule is explicit: **never declare a winner from n<100.**

- **n=20** → ±15–20pp → *nothing; differences are noise*
- **n=100** → ±7–9.5pp → rough signal, detects differences >10%
- **n=550** → ±4–5pp → tight bounds for production deployment decisions

→ **Fix:** Raise to **n≥100 minimum** to get any signal. Because you're shipping to production ("whoever wins, we ship" = a production deployment decision), the correct target is **n≥550 per arm**. If you can only afford one expansion, go to 100 now and treat the result as directional, not final.

### [P0] AB3 + Cross-Cutting Rule — claude-sonnet judging claude-sonnet outputs is self-enhancement bias
The pack's single most-emphasized rule, surfaced at the top of the SKILL and again in AB3: **the judge MUST be a different model family from the generator.** Self-enhancement bias inflates scores by a documented **10–15%** — an LLM systematically prefers outputs that match its own style and phrasing.

This is doubly dangerous in *your* case. You didn't state which model generates the chatbot responses, and that creates two failure modes:

1. If your chatbot is **powered by Claude** (likely, given the stack), then claude-sonnet is judging its own family's output — the "winner" may just be the prompt that produces more Claude-flavored text, not the better prompt.
2. Even if A and B are both Claude prompts, a Claude judge has no *neutral* baseline; both arms are flattered, but not necessarily equally — phrasing closer to the judge's defaults wins.

→ **Fix:** Use a **different-family judge** — e.g., **gpt-4o** (or Gemini) judging Claude-generated outputs. If you are forced to keep claude-sonnet as judge, you MUST document the bias explicitly and label results **"internally consistent only — needs cross-family validation before production."** That label means you have NOT earned a ship decision.

### [P0] No statistical test — "whoever wins, we ship" is a raw-count decision
"Whichever wins, we ship" treats a count comparison as a decision rule. With no significance test, you have no idea whether the difference is real or sampling luck. The pack mandates a **paired** statistical test because both arms run on the same cases (AB2 + AB7):

- **Binary better/worse or pass/fail** → **paired McNemar test**
- **Continuous 0–1 rubric scores** → **paired t-test**
- Report a **Wilson 95% CI** on each arm's success rate.

→ **Fix:** Define the win condition as "Config B beats A with **p < 0.05** on the paired test AND the CI on the difference excludes 0." A bare win count is not a decision criterion.

---

## P1 — Required (fix before trusting results)

### [P1] AB3 (VERIMAP) — judge has no deterministic backstop
A pure LLM-as-Judge "which is better" verdict is non-deterministic and unverifiable. The pack's VERIMAP mitigation: embed **deterministic Python verification functions** alongside the LLM judge (e.g., did the answer contain the required disclaimer? stay under length budget? avoid forbidden phrases? produce valid JSON?). **When the deterministic check and the LLM judge disagree, the deterministic check wins.**

→ **Fix:** Add 2–5 mechanical assertions per case for whatever is objectively checkable for your chatbot domain, and let the LLM judge only adjudicate the genuinely subjective remainder.

### [P1] AB6 — single-dimension "better" hides cost and latency regressions
"Which output is better" collapses everything to one axis. The pack requires **multi-dimensional comparison**: a prompt that's 5% better on quality but 3x more expensive (longer prompt = more input tokens every call) or noticeably slower is usually **not** a win.

| Dimension | Suggested weight | Metric to capture |
|-----------|------------------|-------------------|
| Quality   | 0.5–0.6 | judge win-rate / mean rubric score |
| Cost      | 0.2–0.3 | total tokens × price, per-eval cost |
| Latency   | 0.1–0.2 | P50 and P95 response time |

→ **Fix:** Log tokens and latency for every call. Report all three dimensions and let the decision-maker apply weights — don't bake "better" into a single judge verdict.

### [P1] HE3 — no human-to-automated bridge; you never validated the judge
You're trusting claude-sonnet's "better" verdict with zero evidence that it agrees with human judgment. The pack requires a **Spearman bridge ≥0.80** (SOTA pipelines hit 0.86) between the LLM judge and human consensus before the judge is trusted to make decisions alone.

→ **Fix:** Before the full run, have **2–3 people** independently rate ~50 of the paired outputs, compute Spearman correlation between human consensus and the judge. If correlation < 0.80, the judge isn't measuring what you think — refine the judge prompt with anchored examples or escalate those cases to humans.

### [P1] HE1/HE5 — customer-facing chatbot is not "low stakes"; pure automation is wrong
A shipped chatbot is **medium-risk (customer-facing / brand)** at minimum. The pack's risk-adjusted oversight table says medium-risk requires **human validation on a 10–20% sample**, with automated eval as the primary signal — *not* full automation. "Whoever wins, we ship" with zero human-in-the-loop violates this.

→ **Fix:** Keep a human spot-check on ~10–20% of the deciding cases before shipping. If any part of the chatbot touches financial/safety/legal content, that subset is high-stakes and needs dense (100%) human review.

---

## P2 — Advisory (improves eval quality)

### [P2] AB7 — confirm identical cases + randomize order
You implied the same 20 cases run on both arms (good — that's required for paired tests). Make it explicit: **identical vars, identical assertions** for both arms, and **randomize the A/B presentation order** to the judge to kill position/sequence bias (LLM judges have a known first-position preference).

### [P2] HE1 — define an anchored rubric instead of bare "which is better"
"Which is better" is an **unanchored rubric** — the judge invents its own scale per case, so verdicts aren't comparable. Define 2–4 behaviorally anchored dimensions (e.g., *helpfulness*, *correctness*, *tone/safety*, *instruction-following*) with concrete descriptions of what each score level looks like. This also makes the HE3 bridge measurable.

### [P2] AB4 — reserve multi-judge debate for the high-stakes call only
If this prompt change is a major rewrite or model migration, CollabEval-style multi-agent debate (distinct judge personas → debate to consensus) cancels individual-model bias better than a single judge. Overkill for a routine tweak; worth it for a big swing.

### [P2] Per-scenario reporting — don't ship on the aggregate alone
A 2% aggregate win can hide a 20% regression on a critical scenario (e.g., refunds, safety-sensitive queries). When you build the ≥100-case set, **stratify by scenario type and report per-scenario**, not just the overall win-rate.

### Note on AB5 (multiplicity) — not yet triggered, but watch it
You're comparing exactly 2 prompts, so Benjamini-Hochberg correction isn't required *yet*. The moment you test a 3rd+ variant (or re-run the same comparison many times and cherry-pick), you're data-dredging and MUST apply multiplicity correction.

---

## determinismLevel Audit

The pack tags each rule with how many judge samples the eval runner should draw. Your current design ignores this entirely (single judge pass = 1 sample on a non-deterministic operation).

| Rule item | determinismLevel | Sampling requirement | Your setup |
|-----------|------------------|----------------------|------------|
| AB1 sample size | deterministic | design choice — 1 decision | ❌ chose n=20 (too small) |
| AB2 statistical test | deterministic | mechanical, 1 computation | ❌ no test run |
| AB3 LLM-as-Judge verdict | **non-deterministic** | **run ≥10× and report distribution** | ❌ single judge pass |
| AB6 cost/latency dims | deterministic | mechanical, 1 computation | ❌ not measured |
| AB7 experimental design | deterministic | structural, 1 decision | ⚠️ same cases assumed, order not randomized |
| HE2 inter-rater reliability | non-deterministic | needs ≥2 raters | ❌ zero human raters |
| HE3 Spearman bridge | non-deterministic | 50–100 dual-scored outputs | ❌ no bridge built |

**Key takeaway from the audit:** the LLM judge verdict (AB3) is **non-deterministic** — per the SKILL's Step 1.5 rule, a non-deterministic operation must be **run ≥10× with the distribution reported**, not trusted from a single pass. A judge that flips its verdict across reruns on the same pair is telling you the difference is noise.

---

## Tool Recommendation

For a YAML-driven, two-arm prompt A/B with a different-family judge and built-in stats, use **promptfoo**:

```yaml
# promptfoo config sketch — applies AB7 (identical cases), AB3 (cross-family judge)
providers:
  - id: anthropic:claude-...        # your chatbot's actual generator
    label: "Prompt A"
    config: { systemPrompt: file://prompt_A.txt }
  - id: anthropic:claude-...
    label: "Prompt B"
    config: { systemPrompt: file://prompt_B.txt }

defaultTest:
  assert:
    # AB3 VERIMAP — deterministic backstops first
    - { type: javascript, value: "output.length < 1200" }
    - { type: contains, value: "<required-disclaimer>" }
    # then the cross-family LLM judge (NOT claude-sonnet)
    - type: llm-rubric
      provider: openai:gpt-4o        # ← different family than generator
      value: |
        Score helpfulness, correctness, tone (anchored 1-5 each).

tests: file://cases.csv              # ≥100 rows (≥550 for the ship decision), identical for both arms
```

- `npx promptfoo@latest init` to scaffold.
- Run the comparison, then export results and apply the **paired McNemar / paired t-test + Wilson CI** (AB2) — promptfoo gives you the per-case matched outcomes you need for the paired test.
- For OWASP-style safety/jailbreak testing of the chatbot (separate concern), `deepteam` (`pip install deepteam`).

---

## Bottom line

Your current plan would let you ship a prompt change on a **±18pp noise band**, judged by a **same-family judge with 10–15% self-enhancement bias**, with **no significance test and no human validation**. Minimum bar to make this a real decision:

1. **n≥100** (n≥550 for the production ship). — *AB1*
2. **Different-family judge** (gpt-4o or Gemini judging your Claude outputs). — *AB3 / cross-cutting*
3. **Paired McNemar/t-test + Wilson CI**, win = p<0.05 with CI excluding 0. — *AB2*
4. Add **deterministic assertions** (VERIMAP) and **measure cost + latency**. — *AB3 / AB6*
5. **Validate the judge** against 2–3 humans on ~50 cases (Spearman ≥0.80) and keep a **10–20% human spot-check** before shipping. — *HE3 / HE5*
