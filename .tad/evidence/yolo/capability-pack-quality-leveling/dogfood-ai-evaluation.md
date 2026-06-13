# Dogfood Judgment: ai-evaluation pack — A/B eval setup review

## Task
User A/B tests two chatbot prompts: 20 cases, claude-sonnet both generates AND judges,
ship whichever prompt has more wins. "Review my eval setup."

## Verification of key specific claims (WebSearch + math)

| Claim | Answer | Verdict |
|-------|--------|---------|
| Self-enhancement / position / verbosity = 3 documented judge bias modes, MT-Bench Zheng et al. arXiv:2306.05685 | A2 | CORRECT — paper title, arXiv id, and the exact three bias names all verified |
| LLM judges achieve ~80% agreement = inter-human rate (ceiling) | A2 | CORRECT — paper states ">80% agreement, same level as humans" |
| Self-enhancement bias "10-15% more favorably" | A2 | PLAUSIBLE but imprecise — paper documents the bias directionally (GPT-4 prefers own outputs) but the original paper does not pin a 10-15% number; matches the SKILL's own figure. Soft — not a hard wrong specific. |
| McNemar paired test = standard for paired binary win/loss, continuity correction | A2 | CORRECT — McNemar is the recognized matched-pair binary test; continuity-corrected variant is standard (conservative) |
| n=20 Wilson CI half-width ±15-20pp; n=100 ±7-9.5pp; n=550 ±4-5pp | A2 | CORRECT — verified by computation. p=0.5 worst case: n=100→±9.8pp, n=550→±4.2pp. n=20→±22pp at p=0.5, ±15-20pp at off-center p. Internally consistent. |
| A1 "n=20 needs ~15-5 (75%) before marginally significant; 13-7 not" | A1 | CORRECT — binomial: 15/20 two-sided p≈0.04; 13/20 p≈0.26. Accurate. |
| promptfoo `npx promptfoo@latest init`, multi-provider, llm-rubric judge override, --repeat | A2 | CORRECT — init is interactive scaffold; supports multiple providers, llm-rubric with grader override, repeat option |
| gpt-4o as cross-family judge | A2 | CORRECT — valid different-family judge |
| Position bias on current judges negligible ≤0.04, sensitivity (swap reversal) is the operative concern | A2 (via SKILL); A1 uses classic framing | Both defensible. A2's "≤0.04" is from SKILL; A1's "judge favors first option" is the older but still broadly true framing. Neither is wrong. |

No hard-wrong specific found in EITHER answer. A1 stays correct by being slightly more
conservative on numbers; A2 reaches further with specifics that all hold up, with the lone
soft spot being the "10-15%" figure which is not in the primary paper (carried from SKILL).

## Scoring

### Answer 1 (no specialized framing — strong generalist)
- Correctness 5 — every claim checks out; binomial significance reasoning correct; no overreach
- Actionability 5 — "minimum viable fixed version" is a runnable 6-step recipe; highest-payoff change called out
- Specificity 4 — concrete (sign test, 70-75% threshold, swap-and-keep-consistent) but no named tools, no named statistical test for paired binary (uses generic sign/binomial), no arXiv anchor
- Completeness 5 — covers self-preference, power, position, ties, representativeness, rubric, variance; arguably the most well-rounded coverage

### Answer 2 (skill-backed)
- Correctness 5 — all hard specifics verified; only soft spot is the 10-15% figure (directionally right, not pinned in primary source)
- Actionability 5 — P0/P1/P2 triage, exact tests (McNemar + bootstrap + effect size), exact tool command, dual-pass procedure, n thresholds
- Specificity 5 — arXiv id, named test (McNemar continuity-corrected), Wilson CI half-widths per n, promptfoo command, gpt-4o, per-scenario breakdown
- Completeness 5 — everything A1 has PLUS: effect size, McNemar specifically, multiplicity note (correctly scoped as not-needed for 2 variants), per-scenario regression hiding, tool recommendation, determinism audit

## Winner: 2, margin: slight

Both answers are excellent and both are CORRECT — this is the rare case where the
skill-backed answer wins on *verified* specifics rather than on verbosity. A2's extra content
is load-bearing and accurate: the named paired test (McNemar) is genuinely the right tool
where A1 falls back to a generic sign/binomial test; the per-n Wilson half-widths are
computed correctly; the promptfoo command and gpt-4o judge are real and correct; the
arXiv anchor is real. A2 also correctly *scopes down* multiplicity correction as unneeded
for a 2-prompt test — a sign of judgment, not rule-dumping.

Why only SLIGHT, not clear/decisive:
- A1 nails the single most important insight just as well (same model gen+judge is the
  headline defect) and arguably communicates the "why" more crisply for a non-expert.
- A1's "highest-payoff single change" framing is excellent product judgment A2 lacks.
- A2 carries some pack-flavored framing ("violates three load-bearing rules", "the linter
  doesn't apply", determinism audit) that is slightly performative for this user's question
  and the one soft-imprecise number (10-15%) comes from that machinery.
- A2's n≥550 "production ship" threshold and McNemar are more rigorous than the user likely
  needs for a 2-prompt chatbot test, where A1's "ship on clear margin else pick on
  cost/latency" is more pragmatic.

Net: A2 wins because its additional specificity is correct and genuinely useful (McNemar,
bootstrap+effect size, real tool command, per-scenario breakdown), not because it is longer.
But A1 is a near-peer that would fully serve the user. Slight margin.
