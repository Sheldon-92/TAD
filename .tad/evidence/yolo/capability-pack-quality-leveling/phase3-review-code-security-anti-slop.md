# Phase 3 Adversarial Review — code-security pack — ANTI-SLOP lens

> Reviewer: subagent (Opus 4.8) | Date: 2026-06-13
> Lens: anti-slop (Layer B depth — are "specifics" research-grounded numbers an LLM
> could NOT emit from training, or generic rules dressed up?)
> Files read: SKILL.md + 5 references + 2 scripts + 1 fixture + QUALITY-BAR.md
> Verification: live WebSearch/WebFetch against FIRST.org, CISA, ProjectDiscovery, TruffleHog, Google OSV docs

## lens
anti-slop / Layer B domain depth

## meets_bar
TRUE — clears the bar, with one factual defect to fix (does not sink the pack).

## Verdict rationale
specN ≈ 48 unique specific-threshold matches (Layer B bucket 4 = "40-59 → 4", before reading
adjustment). More importantly, the headline specifics are NOT generic-rules-dressed-up: the
load-bearing numbers (FIRST.org efficiency table, EPSS 88th-percentile anchor, CISA BOD 26-04
3-day/14-day tiers, TruffleHog exit 183, Nuclei v3 throttle defaults+precedence, osv-scanner
v2.3.5 transitive-Python) are all verifiable against live sources, and several are
POST-TRAINING-CUTOFF (BOD 26-04 issued 2026-06-10) — by definition an LLM cannot emit them from
training. This is the strongest possible anti-slop signal. Negative-control contrast holds: the
fixture's discriminative_pattern keys on these exact pack-named markers, not on "scan for vulns".

## findings

1. **GENUINELY research-grounded (clears anti-slop) — the FIRST.org triage table is the
   strongest evidence.** V1 cites CVSS≥7 = 57.4% effort / 82.2% coverage / 3.96% efficiency vs
   EPSS≥0.1 = 2.7% effort / 63.2% coverage / 65.2% efficiency. I fetched first.org/epss/model:
   ALL SIX numbers match EXACTLY (Oct-2023 dataset). These are not numbers an LLM reliably emits
   from training — they are a specific published measurement. This single table moves the rule
   from "use risk-based prioritization" (restatable) to "here is the quantified tradeoff"
   (pack-unique). 5/5 depth.

2. **POST-CUTOFF specificity (the deepest anti-slop signal) — CISA BOD 26-04.** V7 + fixture +
   triage-prioritize.sh build the deadline contract on BOD 26-04's risk-based 3-day/14-day tiers
   and explicitly flag the flat 14/60-day BOD 22-01 model as revoked. Verified: BOD 26-04 was
   issued 2026-06-10 (3 days before this review), supersedes BOD 22-01, and uses the four inputs
   (exposure × KEV × automatable × impact) the pack encodes. This is information that did NOT
   exist at training time — the pack could only have it via fresh research. Unambiguously
   not-slop. This is exactly the "LLM could NOT emit from training" criterion.

3. **EPSS 0.10 ≈ 88th percentile anchor (V1) — research-grounded, not invented.** Verified
   against FIRST.org + Empirical Security: 0.10 sits at ~88th percentile, EPSS v4 released
   2025-03-17, ~5% of CVEs ever exploited. The pack correctly refuses to invent a "critical/high"
   EPSS bin and tells the agent to present `prob% (Nth pct)` — this is faithful to FIRST's own
   guidance, not a dressed-up heuristic.

4. **Tool exit-code semantics are specific and correct.** TruffleHog exit 183 (verified leaked
   credential, only with --fail) confirmed against trufflehog docs. Semgrep 1 / Checkov 1 /
   Gitleaks 1 standard. These exit codes are the kind of concrete operational detail (per
   QUALITY-BAR's "exit code 183" example) that marks 5-band depth, not 0-2 restatable prose.

5. **osv-scanner v2 depth claims verified.** V3 claims v2 (2025-03) added container scanning +
   guided remediation for Maven; v2.3.5 added transitive Python requirements.txt via deps.dev
   API. Confirmed against Google security blog + OSV docs. This is the "don't under-sell vs
   Trivy/Grype" nuance that a generic LLM answer would miss — genuine currency.

6. **DEFECT (factual) — Nuclei v3 default concurrency is WRONG.** dast-rules.md D4 table states
   `-c / -concurrency` v3 default = **10**, and the example line 99 comment repeats "concurrency
   10". ProjectDiscovery's current Running docs state the default is **25** (rate-limit 150,
   concurrency 25, bulk-size 25). The pack's rate-limit=150 and bulk-size=25 are correct; only
   concurrency is wrong. The PRECEDENCE rule (rate-limit caps actual req/s regardless of c/bs) is
   correct and is the load-bearing teaching point — so the error is cosmetic to the rule's logic
   but is still a wrong sourced number that an anti-slop lens must flag. FIX: change "10" → "25"
   in D4 table and in the line-99 comment. (Note: TruffleHog --concurrency default IS 10, a
   plausible source of the cross-tool confusion.)

7. **MINOR (accuracy completeness) — BOD 26-04 supersession is under-stated.** Pack says BOD 26-04
   "supersedes and revokes BOD 22-01". CISA's directive supersedes BOTH BOD 22-01 AND BOD 19-02.
   Not an error (22-01 is the relevant KEV one), but for full correctness V7 could add 19-02.
   Low priority.

8. **No vague-rule-masquerading-as-depth found in the headline content.** The cross-cutting
   "Detection ≠ Remediation / 72% of orgs use >10 tools" stat and "30-50% triage time on false
   positives" are industry stats (widely reported; not uniquely traceable to one primary source
   in the pack, unlike the FIRST.org table). These are the WEAKEST specifics — borderline
   restatable and the 72% lacks an inline source URL. They still function as concrete anchors, but
   are the closest thing to "generic dressed up". Recommend adding a source citation for the 72%
   and 30-50% figures to match the rigor of the FIRST.org/BOD/EPSS citations (which DO carry
   "Source: …, retrieved 2026-06-13").

9. **Semgrep "~25-30% scan-time cut" and "~20-40% Pro interfile perf" (S1/S4) are soft.** These
   carry "(Source: semgrep.dev release notes, retrieved 2026-06-13)" but I did not independently
   confirm the exact percentages; they are plausible release-note ranges. They read as real but
   are the second-softest specifics after the 72% stat. Not blocking — flagged for the
   cross-model fact-check pass (per QUALITY-BAR §6: verify version-sensitive perf claims).

## fact_checks
- FIRST.org EPSS strategy table 57.4/82.2/3.96 and 2.7/63.2/65.2 — VERIFIED EXACT (first.org/epss/model, Oct-2023 data).
- CISA BOD 26-04 issued 2026-06-10, risk-based 3-day tier, supersedes BOD 22-01 (and 19-02) — VERIFIED (cisa.gov + Tenable/Nucleus/runZero). Post-training-cutoff content.
- EPSS 0.10 ≈ 88th percentile; EPSS v4 released 2025-03-17; ~5% CVEs ever exploited — VERIFIED (FIRST.org / Empirical Security).
- TruffleHog exit 183 = verified leaked credential, only with --fail — VERIFIED (trufflehog docs/GitHub).
- Nuclei v3 defaults: rate-limit 150 ✓, bulk-size 25 ✓, concurrency 25 ✗ (pack says 10) — DEFECT (docs.projectdiscovery.io Running).
- Nuclei rate-limit precedence over -c/-bs — VERIFIED (consistent with docs; rl is global cap).
- osv-scanner v2 container scan + Maven guided remediation (2025-03); v2.3.5 transitive Python via deps.dev — VERIFIED (security.googleblog.com + OSV docs).
- specN (specific-threshold count) ≈ 48 → Layer B bucket 4 pre-reading; reading confirms 5-band on triage/SAST, holds at 4-5.
- triage-prioritize.sh constants (9.0/7.0/4.0/0.5/0.10, BOD tiers) all rule-referenced — NO voodoo constants.
