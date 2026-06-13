# Phase 5 Adversarial Review — web-deployment — Anti-Slop Lens

**Reviewer**: Anti-slop lens (adversarial, default-skeptic)
**Date**: 2026-06-13
**Pack**: `.claude/skills/web-deployment/` (v0.1.0)
**Files reviewed**: SKILL.md + 7 references + 2 scripts + 1 fixture
**QUALITY-BAR**: `.tad/evidence/pack-quality/QUALITY-BAR.md`

## Lens

Layer B (深度): are the "specifics" genuinely research-grounded — numbers/thresholds/dated
incidents an LLM could NOT emit from training — or generic rules dressed up? Flag vague
restatable rules masquerading as depth. Flag unsourced numbers.

## Verdict

**meets_bar = TRUE** (Layer B clears the bar; specN=70 → bucket 5; the upgraded references
carry dated, sourced, verifiable specifics. One factual SHA-label error and a tier-split in
ref freshness are flagged but do not sink the depth verdict.)

## specN (counted sub-dimension, NFR4c)

Ran the QUALITY-BAR DISC alternation with `LC_ALL=en_US.UTF-8` over SKILL.md + references/:
**specN = 70** → `≥60 → Layer B bucket 5`. Above the gold-pack web-backend (27), so specN
alone over-credits raw-number density; the reading-based judgment below is what confirms 5.

## Findings

### Genuinely research-grounded depth (clears the bar — NOT LLM-restatable)

1. **CVE-2025-30066 / tj-actions (CI9, Anti-Skip, fixture)** — dated mass-compromise with
   specifics: entire tag chain `v1`–`v45.0.7` mutated, `memdump.py` against Runner.Worker,
   **23,000+ repos**, patched in **v46.0.1**, rotate secrets exposed **2025-03-14/15**. This
   is the strongest anti-slop signal in the pack: a frontier LLM cannot emit this CVE id +
   blast radius + patched version + remediation window without research. Sourced (CISA AA,
   retrieved 2026-06-13).

2. **upload-artifact@v3 hard cutoff (CI11)** — "stopped working **2025-01-30**, job FAILS not
   warns, v4 up to **98% faster**, artifact name must be unique per run." Dated, behavioral,
   and the v4 unique-name breaking change is a real migration gotcha. Not restatable.

3. **Multi-window multi-burn-rate alerting (MO3)** — **14.4x / 6x / 1x** with paired
   long/short windows (1h+5m, 6h+30m, 3d+6h) and budget-consumed-at-fire (2% / 5% / 10%).
   FACT-CHECKED the math independently: `14.4 * 1h/(30d) = 2.0%`, `6x*6h = 5.0%`, `1x*3d =
   10.0%`, exhaust-in-`30/14.4 = 2.08 days`. **All four numbers reproduce exactly.** These are
   the canonical Google SRE Workbook reference numbers, correctly transcribed and sourced
   (sre.google/workbook/alerting-on-slos, retrieved 2026-06-13). This is the model for "carries
   a research threshold an LLM gets wrong from memory."

4. **zizmor named audits (CI10)** — `unpinned-uses / impostor-commit / known-vulnerable-actions
   / template-injection / excessive-permissions / dependabot-cooldown (7-day default)`. Named
   tool + specific audit IDs + the "every major Actions attack in 18 months" maintainer claim.
   Tool-freshness depth (B2), not a name-drop.

5. **Artifact Attestations / SLSA (CI12, SH8)** — GA **June 2024**, Sigstore **~10-min
   ephemeral certs**, **Rekor** transparency log, `in-toto` predicate, `gh attestation verify`
   fail-closed gate. Concrete, dated, and wired into a deploy gate, not a buzzword list.

6. **GitHub Immutable Releases GA 2025-10-28 (CI13)** — dated, specific, ties the immutability
   thread upstream. Not restatable.

7. **DORA 2025 reporting change (MO8)** — "2025 report **dropped the named Elite bucket** for a
   **top-15% percentile** view; CFR **<15%**, MTTR **<1h**." The reporting-method change is the
   research-grounded part an LLM wouldn't volunteer. Sourced.

### Scripts elevate the pack above prose (deterministic-vs-judgment split is correct)

- `verify-deploy-hardening.sh` — **ran it against a dirty fixture workflow**: correctly emitted
  4×[P0] (3 unpinned uses: + dead @v3 artifact) + 1×[P1] (missing permissions), **exit 2**.
  macOS bash-3.2-portable (no mapfile; heredoc loops; 40-hex SHA test). Determinism is in code,
  judgment in prose — exactly per QUALITY-BAR's "no punt to Claude."
- `find-action-sha.sh` — correctly prefers the peeled `^{}` ref for annotated tags; `--attest`
  wraps `gh attestation verify`. Sound.

### Weaker / restatable items (do NOT masquerade as depth — honestly generic, acceptable)

8. **SH1 OWASP headers, SH7 cookie flags, EC6 NEXT_PUBLIC_** — these ARE restatable by a
   frontier LLM (HSTS max-age, httpOnly/Secure/SameSite, NEXT_PUBLIC_ visibility are training-
   data common knowledge). They sit in the 0-2 band on their own. NOT flagged as slop because
   they're presented as concrete config (exact header values, platform config files), not
   dressed up as proprietary depth — and they're a minority of the pack. They don't inflate the
   verdict.

### FLAGGED — factual errors / freshness gaps

9. **[P1 FACT ERROR] Mislabeled SHA: `actions/checkout@b4ffde6…` is commented `# v4.1.7` but
   `b4ffde65f46336ab88eb53be808477a3936bae11` is actually the SHA of `v4.1.1`.** Live
   `git ls-remote` confirms: `refs/tags/v4.1.1 → b4ffde6…`; the real v4.1.7 is
   `692973e3d937129bcbf40652eb9f2f61becf3332`. The wrong (mislabeled) SHA appears in CI2 (RIGHT
   example), CI7 (3×), and the SKILL.md output-format example. Mitigations that keep this from
   being P0: (a) the SHA is real + pinnable so security posture is intact, (b) the pack loudly
   labels every SHA "illustrative, not authoritative — re-resolve, never copy from this doc"
   and ships `find-action-sha.sh` precisely for this. Still: a user who ignores the warning and
   copies the SHA gets v4.1.1 believing it is v4.1.7. The version comment is simply wrong and
   should be corrected to `# v4.1.1` or re-resolved to the v4.1.7 SHA. (Verified SHAs that ARE
   correct: setup-node@v4.0.3, cache@v4.0.2, upload-artifact@v4.6.2 all MATCH live.)

10. **[P2 FRESHNESS TIER-SPLIT] 4 of 7 references upgraded (Jun 13), 3 still original (May 15).**
    Upgraded: ci-cd, monitoring, security-hardening, SKILL. NOT upgraded:
    `platform-selection-rules.md`, `rollback-rules.md`, `environment-config-rules.md`,
    `domain-dns-rules.md`. The un-upgraded refs are SOLID but carry NO source citations and a few
    soft/unsourced numbers (see fact_checks). Depth is uneven across the pack; the headline
    Layer-B specifics all live in the 4 upgraded files.

## fact_checks

- ✅ Burn-rate math (MO3): 14.4x→2%, 6x→5%, 1x→10%, exhaust ~2 days — all reproduce exactly.
- ✅ SLA downtime budgets (MO4): 99.95%→21.6min (~22), 99.99%→4.32min (~4.3), 99.999%→0.43min
  (~26s) — all correct.
- ✅ SHA MATCH: setup-node v4.0.3 = 1e60f62…, cache v4.0.2 = 0c45773…, upload-artifact v4.6.2 =
  ea165f8… — verified against live `git ls-remote`.
- ❌ SHA MISLABEL: checkout `b4ffde6…` commented `# v4.1.7` is really v4.1.1; v4.1.7 = 692973e…
  (Finding 9).
- ✅ verify-deploy-hardening.sh: ran on dirty workflow → 4 P0 + 1 P1, exit 2. Correct + portable.
- ⚠️ UNSOURCED NUMBERS (mostly un-upgraded refs, plausible but not citation-backed):
  - PS1 "Vercel ~12ms edge / ~1s serverless cold start", PS3 "Fly <500ms KVM boot",
    "$0.0000022/s", PS2 "Netlify 300 build min / Vercel 6,000 build min" — platform-doc numbers
    that drift; no retrieval date. Plausible, not verified live.
  - CI7 "parallel cuts pipeline 40-60%", CI11 "98% faster", PS7 "~80% of dashboard-only tasks
    have a CLI path", MO7 Sentry "$500+/month at 100K req/day" — round-number heuristics stated
    as fact without a source. Directionally fine; flagged as unsourced.
  - RB6/RB3 auto-rollback thresholds ("error rate >5% for 2 min", canary 1/10/50/100, halt on
    >0.5% / +200ms p95) — reasonable operational defaults but presented as if canonical; no
    source. NB: RB6's ">5% for 2 min" flat trigger mildly contradicts MO3's own argument
    AGAINST flat-threshold alerting — minor internal tension between an upgraded and an
    un-upgraded ref.

## Bottom line

The UPGRADED layer (ci-cd / monitoring / security-hardening + scripts + fixture) is genuine
research-grounded depth: dated CVEs, a correctly-transcribed SRE Workbook burn-rate table,
named tool audit IDs, GA dates, and a working deterministic checker — the antithesis of slop.
specN=70 and the reading-based 0/2/5 judgment both land at bucket 5. The pack CLEARS the
anti-slop bar. Two corrections owed before "accepted": fix the v4.1.7→v4.1.1 SHA mislabel
(Finding 9) and either upgrade or source-annotate the 3 May-15 references (Finding 10 +
unsourced numbers). Neither defeats the Layer B verdict.
