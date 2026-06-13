# Phase 5 Review — web-deployment (lens: fact-api)

**Lens**: fact-api (factual / API correctness — wrong class names, deprecated/renamed APIs, wrong metric types, wrong constants/versions). This lens replaces cross-model review; every version-sensitive claim WebSearched against current primary docs.
**Reviewer**: subagent, 2026-06-13
**meets_bar**: false

---

## Verdict

The pack's *headline* supply-chain and SRE claims are accurate and well-sourced — CVE-2025-30066, the upload-artifact v3 cutoff, Artifact Attestations GA, Immutable Releases GA, the SRE burn-rate table, and the zizmor audit IDs all verify against primary documentation. But the fact-api lens found **two genuine errors a deployment agent would propagate verbatim into a user's production config**, plus one stale metric. Because this lens is specifically about factual/API correctness and the pack ships at least one **deprecated-API code sample** (`request.ip`, removed in Next.js 15) and one **wrong metric/framing** (DORA 2025 MO8 CFR target + "Elite → top-15% percentile"), it does not clear the fact-api bar. Both are mechanical fixes; with them corrected the pack would pass cleanly.

---

## Findings

### P0 — Deprecated API in shipped code sample (SH5)
`references/security-hardening-rules.md` SH5 "Vercel Edge Middleware" uses `const ip = request.ip ?? '127.0.0.1';`. **`NextRequest.ip` (and `.geo`) were REMOVED in Next.js 15** (vercel/next.js PR #68379) — they were never part of the framework's stable contract and are now `undefined` / a type error. An agent copying this into a current (Next 15+) project ships dead code. Correct API: `import { ipAddress } from '@vercel/functions'; const ip = ipAddress(request)`. Fix the snippet (and note the Next 14→15 migration / codemod).

### P0 — Wrong metric + wrong framing (MO8 DORA 2025)
`references/monitoring-rules.md` MO8 makes two claims that contradict the source it cites:
1. **CFR "< 15%" as the "top-tier target"** is wrong. Per DORA 2025, the top/elite CFR band is **0–5%** (elite benchmark 0–2%; only ~8.5% of teams hit it). 15% sits in the *high/medium* range, not top-tier. Shipping "< 15%" as a deploy-health SLO sets the gate ~3–7x too loose.
2. **"the 2025 DORA report dropped the named 'Elite' bucket in favor of a top-15% percentile view"** — the actual 2025 change was retiring the four-tier classification in favor of **seven team archetypes** (delivery performance × human factors like burnout/friction). "Top-15% percentile" is not the DORA framing; it reads as fabricated. Reword to the archetype change and fix the CFR number.

### P1 — Stale platform metric (PS1 Vercel build minutes)
`references/platform-selection-rules.md` PS1 lists "Build Minutes | 6,000/month (free)". Current Vercel docs indicate the **Hobby plan does not provide build minutes** under the present model (build-minute allotments are a Pro/Enterprise concept). The 6,000 figure is stale/incorrect for the free tier. (Secondary sources; verify against vercel.com/docs/plans/hobby before edit. The commercial-use prohibition in the same row IS correct.)

### P2 — Minor staleness, defensible (PS2 Netlify 300 build min)
PS2 "300/month (free)" is correct for **legacy** Netlify plans; accounts created after 2025-09-04 are on credit-based pricing where build minutes aren't a standalone metric. Not wrong, but add a "legacy vs credit-based" note to avoid drift.

### Correct claims (verified — no action)
- CVE-2025-30066: tags v1–v45.0.7 mutated 2025-03-14/15, 23,000+ repos, patched v46.0.1, log-secret exfil. ✅ matches CISA/GHSA.
- upload-artifact/download-artifact @v2/@v3 dead since **2025-01-30**, v4 up to 98% faster, unique-name-per-run requirement. ✅
- Artifact Attestations GA **June 2024**, Sigstore + Rekor + SLSA in-toto provenance. ✅
- Immutable Releases GA **2025-10-28** (public preview 2025-08-26). ✅
- MO3 burn-rate table (14.4x/1h/5m/2%, 6x/6h/30m/5%, **1x**/3d/6h/10%) ✅ matches SRE Workbook Table 5-8 exactly (slow tier is 1x, NOT 3x — pack is right).
- zizmor audits `unpinned-uses`, `impostor-commit`, `template-injection`, `excessive-permissions`, `dependabot-cooldown` (7-day default). ✅
- Vercel apex A record `76.76.21.21`. ✅ still current general-purpose value.
- `@upstash/ratelimit` `Ratelimit.slidingWindow(60, '1 m')` + `Redis.fromEnv()`. ✅ signature correct (the surrounding `request.ip` is the bug, see SH5 P0).

---

## fact_checks

1. **CVE-2025-30066 (CI9/anti-skip/fixture)** — claims: tags v1–v45.0.7 mutated 2025-03-14/15, 23,000+ repos, patched v46.0.1, secrets dumped to logs. WebSearch CISA + GHSA-mrrh-fwg8-r2c3 + SentinelOne. VERDICT: CORRECT (advisory says "before 46" / patched v46.0.1; pack's v46.0.1 is accurate).
2. **upload-artifact @v3 cutoff (CI11)** — claim: @v2/@v3 dead since 2025-01-30, job FAILS not warns, v4 up to 98% faster, unique name per run. WebSearch github.blog changelog + actions/upload-artifact#635. VERDICT: CORRECT.
3. **Artifact Attestations GA (CI12/SH8)** — claim: GA June 2024, Sigstore, Rekor transparency log, SLSA build-provenance in-toto, ephemeral ~10-min certs. WebSearch github.blog changelog 2024-06-25 + docs.github.com. VERDICT: CORRECT.
4. **Immutable Releases GA (CI13)** — claim: GA 2025-10-28. WebSearch github.blog changelog 2025-10-28. VERDICT: CORRECT (public preview 2025-08-26).
5. **SRE multi-burn-rate table (MO3)** — claim: 14.4x/1h/5m/2%, 6x/6h/30m/5%, 1x/3d/6h/10%. WebFetch sre.google/workbook/alerting-on-slos Table 5-8. VERDICT: CORRECT (third tier is 1x, pack did NOT make the common 3x mistake).
6. **DORA 2025 MO8** — claims: dropped "Elite" for "top-15% percentile"; top-tier CFR "< 15%". WebSearch redmonk DORA2025 + RDEL benchmarks + faros. VERDICT: WRONG on both — 2025 retired four tiers for SEVEN archetypes (not a percentile); top CFR band is 0–5% (elite 0–2%), not <15%. [P0]
7. **NextRequest.ip (SH5)** — claim: `request.ip ?? '127.0.0.1'` in Vercel edge middleware. WebSearch vercel/next.js PR #68379 + Next 15 breaking changes. VERDICT: WRONG — `.ip`/`.geo` removed in Next.js 15; use `ipAddress()` from `@vercel/functions`. [P0]
8. **zizmor audits (CI10)** — claim: unpinned-uses / impostor-commit / template-injection / excessive-permissions / dependabot-cooldown (7-day default). WebSearch docs.zizmor.sh/audits + zizmor#1221. VERDICT: CORRECT (dependabot-cooldown default 7 days confirmed).
9. **Vercel build minutes (PS1)** — claim: "6,000/month (free)" Hobby. WebSearch vercel.com/docs/plans/hobby + pricing guides. VERDICT: LIKELY WRONG/STALE — Hobby plan doesn't offer build minutes in current model. [P1, secondary sources]
10. **Netlify build minutes (PS2)** — claim: "300/month (free)". WebSearch netlify docs legacy + credit-based pricing. VERDICT: CORRECT for legacy; new accounts (post 2025-09-04) credit-based. [P2 staleness]
11. **Vercel apex A record (DN1/DN2)** — claim: `76.76.21.21`. WebSearch vercel.com/docs/domains + KB. VERDICT: CORRECT (general-purpose value, still current).
12. **@upstash/ratelimit (SH5)** — claim: `Ratelimit.slidingWindow(60, '1 m')` + `Redis.fromEnv()`. WebSearch upstash docs + npm. VERDICT: CORRECT signature (limit, duration-string); only the `request.ip` line in the same block is buggy.

---

## Sources
- https://github.com/advisories/ghsa-mrrh-fwg8-r2c3 — CVE-2025-30066 advisory (patched v46, before-46 affected)
- https://www.cisa.gov/news-events/alerts/2025/03/18/supply-chain-compromise-third-party-tj-actionschanged-files-cve-2025-30066-and-reviewdogaction
- https://github.blog/changelog/2024-04-16-deprecation-notice-v3-of-the-artifact-actions/ — v3 cutoff 2025-01-30
- https://github.blog/changelog/2024-06-25-artifact-attestations-is-generally-available/ — Attestations GA June 2024
- https://github.blog/changelog/2025-10-28-immutable-releases-are-now-generally-available/ — Immutable Releases GA
- https://sre.google/workbook/alerting-on-slos/ — Table 5-8 burn-rate values
- https://redmonk.com/rstephens/2025/12/18/dora2025/ — DORA 2025 seven archetypes, CFR tightening
- https://rdel.substack.com/p/rdel-115-what-are-the-2025-benchmarks — DORA 2025 CFR 0-2% elite benchmark
- https://github.com/vercel/next.js/pull/68379 — removal of NextRequest.ip/.geo (Next 15)
- https://docs.zizmor.sh/audits/ — zizmor audit IDs + dependabot-cooldown 7-day default
- https://vercel.com/docs/plans/hobby — Hobby plan limits (no build minutes)
- https://upstash.com/docs/redis/sdks/ratelimit-ts/algorithms — slidingWindow signature
