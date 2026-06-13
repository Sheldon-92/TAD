# Dogfood Judgment: /pressure-test (product-thinking skill)

Task: pressure-test an AI Slack-thread + meeting-transcript summarizer (Chrome extension MVP).
One answer used the product-thinking skill, one did not. Judged purely on merit.

## WebSearch verification of load-bearing specifics

### Answer 2 (the heavily-specific one)
| Claim | Verdict | Source |
|-------|---------|--------|
| Slack shipped native AI thread/channel summaries (2024) | TRUE | slack.com/features/ai |
| As of June 2025, thread summaries + huddle notes bundled FREE into all paid plans (Pro $7.25+); Slack AI add-on no longer sold separately | TRUE | slack.com/blog/news/june-2025-pricing... ; slack.com/help/articles/39264531104275 |
| May 29 2025 API change: non-Marketplace ("unlisted") apps throttled to 1 req/min, max 15 objects, on conversations.history + conversations.replies; enforced on existing installs from Sept 2 2025 | TRUE (exact) | docs.slack.dev/changelog/2025/05/29/rate-limit-changes-for-non-marketplace-apps/ |
| API ToS update bans using API data to train an LLM + bans cross-org data use + bans persistent copies/archives (storing messages) | TRUE | docs.slack.dev/changelog/2025/05/29/tos-updates/ ; Computerworld; NatLawReview |
| Spoke.ai, TheGist real shipping Slack-summary competitors | TRUE | spoke.ai/slack-summarization ; alternativeto.net/thegist-ai |
| Sean Ellis PMF test: >=40% "very disappointed" = PMF; 10-30% = take-it-or-leave-it | TRUE | learningloop.io ; multiple |
| Mom Test commitment-currency (time/reputation/money) | TRUE framing | The Mom Test (Fitzpatrick) |
| "no-market-need cited in 43% of failures, CB Insights" | MINOR WRONG: canonical figure is **42%** (CB Insights, 101 post-mortems), not 43% | cbinsights.com/research/report/startup-failure-reasons-top |
| Opt-in no-card trial conversion 8-18% | Plausible/in-range industry figure; not authoritatively pinned but not wrong | — |

Net: Answer 2 is almost entirely correct on verifiable specifics. The ONLY wrong specific is 43% vs 42% (off by 1 pt, immaterial to the argument). Every Slack-platform fact — the ones that actually carry the KILL verdict — is exactly right, including precise API method names, the 1-req/min figure, the dates, and the ToS LLM-training ban.

### Answer 1 (general analysis, no hard specifics)
- Makes NO falsifiable numeric/version/API claims. Says "Slack already ships AI thread/channel summaries (Slack AI) and recap features" — TRUE but vague (does not know it's now FREE-bundled to exactly this user, which is the decisive fact).
- "huge share of heavy Slack users live in the desktop app, not the web client" — directionally true, unquantified, reasonable.
- "Otter/Fireflies/Granola own transcripts" — TRUE, correct competitor names.
- No wrong specifics because it avoids specifics. This is the "honest general" posture — safe but lower-resolution.

## Where the two diverge in substance

Both correctly identify the core Mom-Test failure (interest != demand, founder-as-sample, leading questions, idea-pitch feedback worth ~zero), both flag "AI improving = risk not moat," both catch the two-products-in-one (Slack vs transcripts) conflation, both prescribe behavioral validation before code.

**The decisive difference:** Answer 1 names "platform risk" abstractly ("Slack already ships summaries... can deprecate your access"). Answer 2 goes and gets the actual facts that convert that abstract risk into a *proven, present-tense kill*:
1. Slack now gives the EXACT MVP feature FREE to EXACTLY this target user (Series B eng on paid plan) — the value prop is already commoditized at zero marginal cost.
2. The API path the extension would need is, as of May 2025, throttled to 1 req/min AND the ToS now explicitly forbids feeding API data to an LLM — i.e., the data pipe and the legal basis are *already shut* against this exact product category.

That moves the analysis from "this is risky and tolerated" (Answer 1) to "the world already closed this door, here are the dated primary sources" (Answer 2). Answer 1's verdict (WEAK GO, fix evidence) is arguably *wrong* given the verified facts — the honest conclusion once you know Slack bundled the feature free + locked the API is closer to KILL/pivot, which is exactly where Answer 2 lands.

Answer 2 also exhibits clear skill scaffolding (6 named forcing rounds, FACT/ASSUMPTION tagging, fatal-flaw F2/F3/F4/F7 taxonomy with a "2+ = KILL, structural = KILL alone" rule, a verdict block with confidence, a concrete 2-week validation plan with a measurable success signal, and a salvage seam — pivot to transcripts because that half does NOT auto-fail F7). This is structured AND correct, not structured-but-padded.

## Verbosity check
Answer 2 is longer, but the length is load-bearing: it is carrying verified primary-source facts (dated API changes, pricing bundling, named competitors) that each independently change the verdict. It is NOT winning on padding. Answer 1 is tight and well-written but its central distribution argument is the very thing Answer 2 proves with citations. Answer 2 also adds the most actionable single instruction in either answer: run the Sean Ellis question *after showing users Slack's own free summary* — directly neutralizing the confound that would otherwise inflate the founder's signal.

## Scores (1-5)
Answer 1: correctness 4 (no wrong specifics, but its WEAK-GO verdict under-weights facts it didn't gather; the conclusion is softer than reality warrants), actionability 4 (concierge MVP + Mom Test interviews + pick-one-wedge are excellent), specificity 2 (deliberately avoids hard specifics; "Slack AI exists" is as far as it goes), completeness 4 (covers evidence, distribution, focus, MVP-as-feature, kill criteria).

Answer 2: correctness 5 (every decision-carrying specific verified true; lone error 43% vs 42% is trivial and non-load-bearing), actionability 5 (dated kill rationale + measurable 2-week plan + the show-them-Slack's-free-summary-first design + named pivot), specificity 5 (exact API methods, rate-limit number, dates, pricing, real competitor names, PMF threshold — and they're RIGHT), completeness 5 (demand, status-quo, persona, wedge+unit-economics, observation, future-fit, fatal flaws, validation plan, salvage seam).

## Verdict
Winner: Answer 2. Margin: clear. It wins on CORRECT, verified, decision-changing specifics — not verbosity. It turned the one abstract risk Answer 1 hand-waved at ("platform could compete / deprecate you") into a dated, primary-source-backed structural kill, and produced a more honest verdict because of it. Answer 1 is a strong generalist pressure-test and would be a creditable answer in isolation, but it leaves the single most important fact (Slack already ships this free to this exact user + locked the API) un-found, which softens its verdict below what the evidence supports.

Wrong claims found:
- Answer 2: "no-market-need is cited in 43% of failures, CB Insights" — correct value is 42% (CB Insights, 101 startup post-mortems). Off by 1 point; does not affect the argument.
- Answer 1: none (avoids hard specifics; no falsifiable error).
