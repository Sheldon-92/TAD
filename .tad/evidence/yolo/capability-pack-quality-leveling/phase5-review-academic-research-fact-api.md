# Phase 5 Adversarial Review — academic-research — fact-api lens

- **lens**: fact-api (factual / API correctness; replaces cross-model review)
- **pack**: academic-research v0.1.0
- **reviewer model**: Claude Opus 4.8 (1M)
- **date**: 2026-06-13
- **meets_bar**: true

## Verdict

The pack **clears the fact-api bar**. The version-sensitive claims the upgrade
introduced were checked against current primary documentation and are
overwhelmingly correct and well-sourced (each carries a "retrieved 2026-06-13"
URL). No wrong class names, no deprecated/renamed API methods, no wrong metric
types, no wrong bibliometric formulas were found. Two real but non-blocking
defects remain (one overspecified credit-cost upper bound; one stale
self-contradicting rate-limit row). Neither breaks an actual API call.

## Findings

### Confirmed correct (high-value, version-sensitive — the upgrade got these RIGHT)
- **OpenAlex: free API key now REQUIRED + credit budget + $1/day** — CONFIRMED.
  OpenAlex blog (usage-based-pricing) states verbatim "you'll need an API key for
  all requests" and "Every API key gets $1 of free usage per day"; the
  openalex-users announcement set the cutover at Feb 13, 2026. Singleton=1 credit,
  list=10 credits, 100 req/s cap all match primary docs. This is a strong,
  correctly-executed currency update (database-apis-general.md L53-61,
  literature-search.md L40).
- **Semantic Scholar: individual key = 1 req/s across ALL endpoints, NO 10/s burst
  tier** — CONFIRMED by S2 API tutorial / docs ("introductory rate limit for an
  API key is 1 RPS on all endpoints"). The pack's explicit correction of the old
  "10/s burst" myth is accurate (database-apis-general.md L50).
- **PRISMA 2020 = 27-item checklist, Page et al. BMJ 2021;372:n71** — CONFIRMED
  (literature-search.md L14, L110, L155).
- **PRISMA-ScR = 20 essential + 2 optional items, Tricco et al. Ann Intern Med
  2018** — CONFIRMED (literature-search.md L13, L111). The scoping-vs-systematic
  instrument-selection rule is factually sound.
- **ClinicalTrials.gov API v2 pageSize max 1000** — CONFIRMED
  (database-apis-life-sciences.md L148).
- **PubChem PUG-REST 5 req/s** — CONFIRMED (life-sciences L17).
- **CiteScore = citations over 4 years / documents over 4 years** — CONFIRMED
  vs Scopus methodology (literature-search.md L35, L191). Impact Factor formula
  (year N citations to N-1+N-2 papers) is textbook-correct.

### Defect 1 (minor — overspecification, unverified upper bound)
- database-apis-general.md L58 claims OpenAlex "content/vector endpoints =
  **100-1000 credits**." Primary docs (ourresearch/openalex-docs rate-limits;
  OpenAlex blog) document **content/PDF = 100 credits** only — no "vector"
  endpoint and no "1000" tier are documented. The "100-1000" range and the
  "vector" label appear fabricated/over-specified. Recommend narrowing to
  "content/PDF = 100 credits" or flagging the 1000 figure as unverified.

### Defect 2 (real — internal contradiction the upgrade missed)
- literature-search.md §1 "Rate Limits" table (L95) still reads
  `OpenAlex | 10 req/sec (with mailto) | Same`. This contradicts the SAME file's
  corrected Quick-Reference row (L40: "key REQUIRED; mailto polite-pool retired;
  100 req/s cap") and the general-API reference. A reader hitting the §1 table
  gets the now-wrong pre-2026 polite-pool number. The currency update was applied
  to the quick-ref + detailed sections but the §1 rate-limit table was left stale.
  Recommend updating L95 to match (key required, 100 req/s, polite pool retired).

### Source-discrepancy note (not a pack defect — pack is on the right side)
- The canonical `ourresearch/openalex-docs` rate-limits page STILL says "No API
  key is required" and "polite pool via mailto — no key needed," which on its face
  contradicts the pack. But the authoritative OpenAlex **blog + changelog +
  users-group announcement** (the sources that announce the change) confirm the
  key-required cutover and $1/day model. The docs page is the stale artifact; the
  pack correctly follows the announcement. No action needed — flagged only so a
  future reviewer who hits the stale docs page does not "correct" the pack
  backwards.

## fact_checks
(each = one version-sensitive claim verified against current primary doc)

1. OpenAlex "free API key now REQUIRED on every request (2026)" — TRUE. OpenAlex blog "API new features and usage-based pricing": "you'll need an API key for all requests"; openalex-users group: keys required from Feb 13, 2026. (Note: stale ourresearch/openalex-docs rate-limits page still says no key required — pack correctly follows the authoritative announcement.)
2. OpenAlex "free tier ≈ $1/day ≈ 100,000 credits/day" — TRUE. Blog: "Every API key gets $1 of free usage per day"; docs: free users 100,000 credits/day. Dollar figure and credit figure both correct.
3. OpenAlex per-call cost "singleton=1, list=10" — TRUE per ourresearch/openalex-docs rate-limits page.
4. OpenAlex "content/vector = 100-1000 credits" — PARTIALLY WRONG. Primary docs: content/PDF = 100 credits. No documented "vector" endpoint, no documented 1000-credit tier. Overspecified/unverified.
5. OpenAlex "max 100 requests/second cap" — TRUE per ourresearch/openalex-docs ("max 100 requests per second regardless of credit cost").
6. OpenAlex "polite pool (mailto) retired" — TRUE per the team's stated position in the pricing announcement (keys-only going forward). [Caveat: stale docs page still describes the polite pool as active.]
7. literature-search.md L95 "OpenAlex 10 req/sec (with mailto)" — STALE/WRONG and self-contradicting vs the pack's own corrected L40. Internal inconsistency.
8. Semantic Scholar "individual key = 1 req/s across ALL endpoints; no 10/s burst" — TRUE per S2 API tutorial/docs ("introductory rate limit for an API key is 1 RPS on all endpoints").
9. PRISMA 2020 = 27 items; Page et al., BMJ 2021;372:n71 (DOI 10.1136/bmj.n71) — TRUE per BMJ / PMC8005924.
10. PRISMA-ScR = 20 essential + 2 optional items; Tricco et al., Ann Intern Med 2018 (M18-0850) — TRUE per Annals of Internal Medicine / EQUATOR.
11. ClinicalTrials.gov API v2 pageSize max 1000 — TRUE per clinicaltrials.gov/data-api/api.
12. PubChem PUG-REST 5 req/s — TRUE (also 400 req/min, 300 s/min runtime caps per PubChem docs); pack's "5 req/s" is accurate.
13. CiteScore = citations over 4 years / documents over 4 years — TRUE per Scopus CiteScore methodology (Elsevier).
14. Impact Factor = citations in year N to papers published N-1 and N-2 — TRUE (standard JCR definition).
15. Effect-size metric types (Cohen's d 0.2/0.5/0.8; I² heterogeneity bands; Hedges' g for small-sample SMD; DerSimonian-Laird random-effects) — consistent with standard meta-analysis references; no wrong metric types.

## Sources
- https://blog.openalex.org/openalex-api-new-features-and-usage-based-pricing/
- https://groups.google.com/g/openalex-users/c/rI1GIAySpVQ
- https://github.com/ourresearch/openalex-docs/blob/main/how-to-use-the-api/rate-limits-and-authentication.md
- https://www.semanticscholar.org/product/api/tutorial
- https://www.bmj.com/content/372/bmj.n71 (PRISMA 2020)
- https://www.acpjournals.org/doi/10.7326/M18-0850 (PRISMA-ScR)
- https://clinicaltrials.gov/data-api/api
- https://service.elsevier.com/app/answers/detail/a_id/14880/supporthub/scopus/ (CiteScore)
