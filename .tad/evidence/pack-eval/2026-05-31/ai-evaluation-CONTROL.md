# Eval Setup Review: A/B Prompt Comparison via LLM Judge

**Reviewer:** Claude (general-knowledge review, no skill files loaded)
**Date:** 2026-05-31
**Setup under review:**
> "I'm A/B testing two prompts for our chatbot. I run each on 20 cases and use claude-sonnet to judge which output is better. Whichever wins, we ship."

---

## TL;DR

Your instinct (compare two prompts head-to-head with a judge) is reasonable. But the current setup will give you a number that *feels* decisive and *isn't*. The four biggest problems:

1. **n=20 is too small to detect anything but a huge difference** — most realistic wins won't clear statistical noise.
2. **No statistical test / no confidence interval** — "whichever wins, we ship" treats 11–9 the same as 18–2.
3. **The judge is unvalidated and biased** — you don't know if claude-sonnet agrees with humans, and pairwise judges have well-documented position/verbosity/self-preference biases.
4. **No held-out / no production ground truth** — 20 cases chosen once, judged once, with no check that "better per the judge" means "better for users."

Below is the full breakdown, then a concrete fixed protocol.

---

## What's wrong (in priority order)

### P0 — Sample size of 20 cannot support a ship decision

With 20 paired cases and a binary win/lose outcome, the margin of error is large. Some intuition:

- If the true win rate of prompt B over A is 50% (i.e., they're actually equal), a single run of 20 will frequently produce lopsided-looking results like 13–7 *purely by chance*. 13–7 has a two-sided p-value of ~0.26 under a fair coin — not remotely significant.
- To get a result you'd call "significant" at p<0.05 with n=20, you need roughly **15–5 or more extreme**. Anything closer is noise.
- Translation: with 20 cases you can only detect *large* quality differences. If prompt B is 5–10% better (a meaningful, ship-worthy improvement in most products), you will usually **fail to detect it OR detect it spuriously in the wrong direction.**

This is the single most important fix. A coin-flip-grade sample is being used to make an irreversible ship decision.

### P0 — No statistical test; "whoever wins ships" ignores uncertainty

"Whichever wins, we ship" means a 11–9 result ships prompt B. But 11–9 is statistically indistinguishable from a tie. You are shipping noise ~half the time when the prompts are close.

You need:
- A **test** (binomial / McNemar's test on the paired wins, excluding ties), producing a p-value.
- A **confidence interval** on the win rate, so you can see whether the plausible range even excludes 50%.
- A pre-declared **decision rule**: e.g., "ship B only if it wins AND the 95% CI lower bound > 50% AND the absolute win margin exceeds our minimum-effect threshold."

### P0 — The judge is unvalidated

You're trusting claude-sonnet's verdict but have no evidence it tracks what you actually care about. Known failure modes of LLM-as-judge:

- **Position bias:** judges favor the answer shown first (or second) regardless of content. This alone can flip a close A/B.
- **Verbosity bias:** judges prefer longer, more elaborate answers even when they're not better — a real problem if one prompt produces wordier output.
- **Self-preference bias:** a Claude judge tends to prefer Claude-style outputs. If both prompts feed the same underlying model this is muted, but it still skews toward certain phrasings.
- **Format/Markdown bias, sycophancy, leniency drift.**

Until you've measured judge–human agreement on a labeled subset, the judge's "B is better" is an opinion of unknown validity.

### P1 — No criteria / rubric given to the judge

"Which output is better" is underspecified. *Better at what* — accuracy? tone? safety? following instructions? brevity? Without a rubric, the judge silently optimizes its own implicit notion of "better," which may be the opposite of your product goal (e.g., it rewards verbosity while your users want terse answers). The judge's criteria must match the product's success definition explicitly.

### P1 — Single run, no variance accounting (non-determinism)

LLM outputs (and LLM judgments) are stochastic. A single generation per case + a single judgment per pair means you're measuring one sample from a distribution and treating it as the truth. Re-running could change individual verdicts. You have no estimate of run-to-run variance.

### P1 — 20 cases of unknown representativeness

How were the 20 cases chosen? If they're hand-picked, convenient, or skewed toward easy/typical inputs, you're not measuring real-world performance. You especially want coverage of:
- High-frequency real user intents (weighted by actual traffic).
- Edge cases, adversarial inputs, and the failure modes that matter (safety, refusals, hallucination triggers).
- The cases where the *current* prompt is known to struggle.

### P1 — Aggregate win/lose hides per-segment regressions

A global "B wins 12–8" can hide that B is much better on easy cases but **worse on your highest-stakes cases** (e.g., billing questions, safety-sensitive prompts). Net-positive in aggregate, net-negative where it counts. You need per-category breakdowns, not one scalar.

### P2 — No tie handling

Pairwise judges often should be allowed to say "tie / roughly equal." Forcing a binary winner manufactures signal out of noise. Ties should be a permitted verdict and excluded from (or explicitly modeled in) the test.

### P2 — No cost/latency/safety dimensions

"Better quality" isn't the only ship criterion. If prompt B wins on quality but is 2x longer (higher token cost, higher latency) or trips more safety refusals, that matters. Track these as guardrail metrics alongside the quality verdict.

### P2 — Irreversibility / no rollout safety net

"Whichever wins, we ship" implies a hard cutover. Even with a clean eval, prefer a staged rollout (canary / small % of traffic) with live metrics, so a wrong call from a 20-case offline eval is caught before it hits all users.

---

## Concrete recommendations (the fixed protocol)

### 1. Fix the sample size

- Target **n ≥ 100–200 cases** for a real ship decision, not 20. If 20 is all you can hand-curate, treat the result as a *directional smoke test*, not a ship gate.
- Do a quick **power calculation** up front: pick the smallest win-rate difference you'd care about (e.g., 55% vs 45%), the significance level (0.05), and power (0.8), and let that dictate n. (55/45 at 80% power needs hundreds of paired cases — which tells you 20 was never going to work for subtle differences.)

### 2. Add a statistical decision rule (pre-registered)

- Use a **paired test** (McNemar's / binomial on wins vs losses, ties dropped).
- Report **win rate + 95% confidence interval**.
- Pre-declare the rule, e.g.:
  > "Ship B only if B's win rate CI lower bound > 50% AND no high-stakes category regresses."
- Write this down **before** looking at results so you can't rationalize a close call.

### 3. Validate the judge before trusting it

- Hand-label **20–50 pairs yourself** (or have a domain expert label them) with the same rubric.
- Compute judge–human agreement (Cohen's κ or simple % agreement). Aim for κ ≥ ~0.6 before using the judge to gate decisions; below that, fix the rubric or add a second judge.
- **Mitigate position bias:** run every pair **twice with A/B order swapped**; only count it as a win if the verdict is consistent across both orders (inconsistent = tie). This is cheap and removes the single biggest judge artifact.
- Consider a **panel** of judges (e.g., two different models) and require agreement, or use majority vote, to reduce single-model self-preference.

### 4. Give the judge an explicit rubric

- Define what "better" means for *your* product, in writing: e.g., factual accuracy first, then instruction-following, then tone, with brevity as a tie-breaker.
- Tell the judge to ignore length/formatting unless the rubric says they matter.
- Ask for a short rationale per verdict — useful for spot-checking and debugging bias.

### 5. Account for variance

- Generate **k samples per case** (e.g., 3) or at minimum acknowledge single-run noise.
- If budget allows, repeat the whole eval and check the verdict is stable across runs.

### 6. Build a representative, segmented test set

- Sample cases weighted by **real production traffic**, plus a deliberate **edge/adversarial/safety** slice.
- Tag each case with a **category**; report results **per category**, and gate on "no high-stakes regression," not just net wins.
- Freeze this set as a reusable **regression suite** so the *next* prompt change is evaluated against the same bar.

### 7. Track guardrail metrics

- Alongside the quality verdict, log **token length, latency, refusal/safety-trigger rate, hallucination flags**. A quality win that doubles cost or safety incidents is not a clean win.

### 8. Stage the rollout

- Even after a clean offline win, ship B to a **canary slice** (e.g., 5–10% traffic), watch live quality/business metrics, then ramp. Keep a fast rollback.

---

## Minimal viable upgrade (if you can only do three things)

If full rigor isn't feasible right now, do at least these — they kill the worst failure modes cheaply:

1. **Swap A/B order and require consistency** (removes position bias, ~2x judge cost).
2. **Add a binomial test + CI and a pre-declared ship threshold** (stops shipping noise).
3. **Spot-check ~15 judge verdicts against your own judgment** (catches a broken/biased judge before it costs you).

Then, before calling it a real ship gate, grow the test set well past 20 and segment it by stakes.

---

## One-paragraph summary for your team

The current setup answers "did claude-sonnet prefer B's output on 20 hand-picked cases, once, with no rubric and no order control?" — which is *not* the same question as "is prompt B better for our users?" Fix it by: (a) enlarging and segmenting the test set, (b) validating the judge against humans and swapping A/B order to kill position bias, (c) giving the judge an explicit product-aligned rubric, and (d) replacing "whoever wins ships" with a pre-registered statistical threshold plus a canary rollout. Until then, treat the 20-case result as a hint, not a decision.
