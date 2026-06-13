# Phase 5 Review — web-deployment — CORRECTNESS lens

- **lens**: correctness
- **meets_bar**: true (with P1 defect to fix — does not fall below the dual-layer bar)
- **date**: 2026-06-13
- **reviewer**: adversarial subagent (correctness lens)

## Verdict summary

The upgraded SKILL.md + 7 references + 2 scripts clear the dual-layer bar on the
correctness lens. Layer A structure is sound (frontmatter load-bearing, body 141 lines,
progressive disclosure via Step 0 routing table, CONSUMES/PRODUCES, anti-skip table,
Quick Rule Index per reference, fixture with `discriminative_pattern`+`min_discriminative`,
two executable scripts). Layer B depth is high: specN = **70** (≥60 → bucket 5), carrying
research-grounded specifics an LLM cannot restate (CVE-2025-30066 tj-actions v1–v45.0.7
chain, 23,000+ repos, v46.0.1 fix; upload-artifact@v3 dead 2025-01-30; 14.4x/6x/1x
burn-rate windows; DORA 2025 CFR<15%/MTTR<1h; Sigstore/Rekor ~10-min certs).
Guidance is overwhelmingly accurate and actionable. **However**, I found one genuine
cross-reference CONTRADICTION (P1) and two lesser consistency defects that a fix pass
should clean up. None is fatal to the bar.

## findings

1. [P1 — CONTRADICTION, actionability] **RB6 prescribes the exact flat-threshold MO3 condemns by name.** `references/monitoring-rules.md` MO3 anti-pattern (lines 84, 214) explicitly names `">5% errors for 2 minutes"` / `">5% for 2 min"` as the WRONG approach ("fires on harmless blips and misses slow budget burns — use multi-window multi-burn-rate"). Yet `references/rollback-rules.md` RB6 (lines 13, 150) prescribes auto-rollback trigger = `error rate >5% of requests return 5xx, grace 2 minutes`. An agent loading "all references" (Step 0 "full deployment" row) gets directly contradictory guidance for the same metric with ZERO reconciling note. The defensible reconciliation (auto-rollback is a coarse fast-acting safety net within a deploy window, distinct from SLO burn-rate paging) is NOT stated anywhere — `grep` for "burn.rate|MO3|safety net|coarse" in rollback-rules.md returns nothing. Fix: add a one-line cross-ref in RB6 distinguishing the deploy-window safety-net threshold from MO3's SLO alerting, or align the numbers.

2. [P2 — unacknowledged tension] **Cross-cutting "MUST use OIDC, not stored secrets" vs stored-token examples.** SKILL.md L31 states absolutely: "Authentication to cloud providers MUST use OIDC identity tokens, not stored secrets." But rollback-rules.md L158/L166 and ci-cd-pipeline-rules.md L102 use `${{ secrets.VERCEL_TOKEN }}`. This is defensible (Vercel/Netlify have no GA OIDC deploy path; a platform deploy token is the only option), and CI3 does soften to "OIDC is preferred". But the cross-cutting rule's wording is an unqualified MUST, so the stored-token examples read as self-violations. Fix: qualify the MUST ("for IaaS/cloud-provider auth — AWS/GCP/Azure; platform deploy tokens scoped per-environment where OIDC is unavailable") to remove the apparent contradiction.

3. [P2 — index/body mismatch] **RB3 canary stages disagree between index and body.** rollback-rules.md Quick Rule Index L10 says canary "1% > 10% > 100%"; the RB3 body L71-74 says four stages "1% > 10% > 50% > 100%". The 50% stage is dropped from the index. Cosmetic but it is the kind of inconsistency the correctness lens flags. Fix: make the index read "1% > 10% > 50% > 100%".

4. [P3 — script edge case, NON-blocking] **verify-deploy-hardening.sh false-flags uppercase-hex SHAs.** The pin test `grep -qE '^[0-9a-f]{40}$'` rejects an all-uppercase 40-char hex SHA as "unpinned" (verified: `actions/checkout@B4FF...` flagged P0). GitHub canonicalizes commit SHAs to lowercase, so this is a near-non-issue in practice, but a hand-typed/uppercased SHA would yield a false positive. Add `[A-Fa-f]` or `-i` if desired. Not a bar issue.

## fact_checks

- **specN = 70** (re-ran the QUALITY-BAR.md DISC alternation with `LC_ALL=en_US.UTF-8` over SKILL.md + references/) → Layer B bucket **5** (≥60). Confirms domain depth.
- **Body size = 141 lines** (< 500 Anthropic threshold / < 550 A3 buffer) → PASS.
- **Frontmatter**: 1 `name:` + 1 `description:` (third-person, what+when) → A1 PASS.
- **A9 eval wired**: examples/cicd-sha-pin-oidc.md contains BOTH `discriminative_pattern:` and `min_discriminative: 4` → PASS (not a non-discriminative combined fallback).
- **verify-deploy-hardening.sh behaves per its documented contract**: synthetic workflow with `@v4` tag + `upload-artifact@v3` + missing `permissions:` + `node:latest` correctly emitted 3 P0 / 2 P1, exit code 2 (P0 present). Clean SHA-pinned workflow with `permissions:` block → 0/0, exit 0. **Correctly handles the pack's OWN recommended `uses: x@<40-hex>  # v4.1.7` comment format** (ref-stripping logic strips trailing `# tag` before the 40-hex test) → no false positive. CI11 dead-@v3 check fires independently of the unpinned check (a @v3 is both unpinned AND dead, so double-counted as 2 P0 — acceptable, both true).
- **find-action-sha.sh works against live network**: `actions/checkout v4.1.7` → `692973e3d937129bcbf40652eb9f2f61becf3332`. NOTE: this DIFFERS from the SHA hardcoded throughout the pack (`b4ffde65f46336ab88eb53be808477a3936bae11`). This is NOT a pack bug — it directly VALIDATES the pack's repeated, explicit warning (SKILL Step 1.5, CI2 L67, anti-pattern L334) that doc SHAs rot and MUST be re-resolved. The illustrative SHAs are labeled illustrative. Self-consistent.
- **CVE-2025-30066 detail** (tj-actions/changed-files v1–v45.0.7 tag-mutation, memdump payload to logs, 23,000+ repos, fixed v46.0.1, 2025-03-14/15 window) is accurately stated and matches the disclosed incident.
- **upload-artifact@v3 dead 2025-01-30** and **v4 unique-name-per-run** breaking change — accurate.
- **DN2 "CNAME cannot be used on apex"** + Cloudflare CNAME-flattening exception — accurate.
- **SH4 Cloudflare Flexible = plaintext origin** — accurate.

## Why meets_bar = true despite a P1

The P1 is a single cross-reference contradiction between two of seven references on ONE
metric (auto-rollback trigger vs SLO alert threshold), with a defensible (just unstated)
reconciliation. Every individual rule is factually correct; the scripts execute correctly
and match their prose; Layer A structure and Layer B depth both clear their thresholds with
margin. The pack does not fall below the dual-layer bar on the correctness lens. The P1 and
two P2s are fix-forward items, not bar failures.

---

## FIX applied (validated)

Fix pass date: 2026-06-13. Edits confined to `.claude/skills/web-deployment/`. Each finding validated before action (WebSearch against primary docs for fact claims; in-file cross-reference for correctness claims).

### Correctness lens
1. **[P1 CONTRADICTION — RB6 vs MO3] FIXED.** Validated as genuine: `rollback-rules.md` RB6 (index L13 + body table L150) prescribed `error rate >5% / 2 min`, the exact flat threshold `monitoring-rules.md` MO3 condemns by name (L84/L214). Added a blockquote note under RB6 distinguishing the **coarse fast-acting deploy-window safety net** (RB6) from MO3's **multi-window multi-burn-rate SLO paging**, stating MO3's condemnation applies to flat thresholds *as an SLO pager* and not to the deploy-time circuit-breaker; directs the agent to use BOTH. Numbers left intentionally unaligned because the two thresholds serve different purposes (now stated explicitly).
2. **[P2 OIDC MUST tension] FIXED.** Validated as genuine: SKILL.md L31 stated an unqualified "Authentication to cloud providers MUST use OIDC", yet rollback-rules.md L158/L166 and ci-cd-pipeline-rules.md L102 use `${{ secrets.VERCEL_TOKEN }}` (Vercel/Netlify have no GA OIDC deploy path — confirmed: PS1 lists deploy tokens as the only auth path). Qualified the cross-cutting MUST to "IaaS/cloud providers (AWS/GCP/Azure)" and added an explicit carve-out: where no GA OIDC deploy path exists (Vercel/Netlify), use a platform deploy token scoped to a single GitHub Environment, never repo-wide. The stored-token examples no longer read as self-violations.
3. **[P2 RB3 index/body mismatch] FIXED.** Validated as genuine: Quick Rule Index L10 said canary `1% > 10% > 100%`; body L71-74 lists four stages `1% > 10% > 50% > 100%`. Aligned the index to the four-stage body (added the dropped 50% stage).
4. **[P3 script uppercase-hex edge case] FIXED (hardening).** Validated as genuine: pin test `grep -qE '^[0-9a-f]{40}$'` false-flagged an all-uppercase 40-char hex SHA as unpinned. Changed to `^[0-9A-Fa-f]{40}$` with an explanatory comment. Re-ran the script against a synthetic workflow containing an uppercase SHA (no longer flagged), a lowercase SHA-pinned clean workflow (passes), an `@v4` tag (caught), and dead `@v3` (caught) — behavior intact, exit codes correct.

### Fact-api lens (cross-handled in this fix pass since edits land in the same files)
5. **[P0 SH5 NextRequest.ip] FIXED.** Validated genuine via WebSearch + nextjs.org/docs upgrade guide: `NextRequest.ip`/`.geo` were removed in Next.js 15 (vercel/next.js PR #68379). Rewrote the SH5 Vercel Edge Middleware sample to `import { ipAddress } from '@vercel/functions'` and `const ip = ipAddress(request) ?? '127.0.0.1'`, typed the handler as `NextRequest`, and added inline comments noting the removal + PR number.
6. **[P0 MO8 DORA] FIXED (both counts).** Validated genuine via WebSearch: (a) top-tier/elite CFR band is ≤5% (tightened from the old 0-15% in the 2024 report), NOT "<15%" — corrected index L15, body table, and anti-pattern L215 to "≤5%". (b) DORA 2025 retired the four-tier model in favor of SEVEN team archetypes (delivery performance × human factors), NOT a "top-15% percentile view" — rewrote the MO8 framing paragraph to say so and re-sourced the elite thresholds to the 2024 report (last year with named bands). Updated the source line accordingly.
7. **[P1 PS1 Vercel build minutes] FIXED.** Validated genuine via vercel.com/docs/plans/hobby (retrieved 2026-06-13): the Hobby resource table has no build-minutes line item — build is bounded by machine resources (4 vCPU / 8 GB / 23 GB disk) + 100 deploys/day; metered build minutes are a Pro/Enterprise concept. Replaced the "Build Minutes 6,000/month (free)" row with an accurate Hobby build-resources row. (Commercial-use prohibition row left unchanged — it is correct.)
8. **[P2 PS2 Netlify build minutes] FIXED.** Validated genuine: 300 min/month is correct only for legacy plans; accounts created after 2025-09-04 are on credit-based pricing where build minutes are not a standalone metric. Added a legacy-vs-credit qualifier to the Netlify Build Minutes row.

### SKIPPED — false positives
None. All eight findings validated as genuine. (Findings tagged POSITIVE / VERIFIED CORRECT / GENUINE DEPTH in the review were confirmations, not defects, and required no edit.)
