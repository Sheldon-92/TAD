# Platform Selection: Todo App (Next.js 15 + Prisma)

## ADR-001: Deployment Platform Selection

**Status**: Accepted
**Date**: 2026-04-01
**Decision Makers**: DevOps Team

---

## Context

We need to select a deployment platform for a Todo App built with:
- Next.js 15 (App Router, SSR + API Routes)
- Prisma ORM + SQLite (dev) / PostgreSQL (prod)
- JWT authentication
- Expected traffic: ~10,000 MAU initially, growing to ~50,000 MAU in 6 months

## Requirements Analysis

| Requirement | Weight | Notes |
|---|---|---|
| SSR/App Router support | 25% | Next.js 15 App Router with Server Components |
| Edge middleware | 10% | JWT validation at edge |
| Database connectivity | 20% | Prisma + PostgreSQL (serverless-compatible) |
| Build speed | 10% | Monorepo not required, moderate build |
| Cost efficiency | 20% | Early-stage, budget-conscious |
| DX (Preview deploys, CLI) | 15% | Team velocity matters |

## Weighted Decision Matrix

| Dimension (Weight) | Vercel | Netlify | Cloudflare Pages | Score Basis |
|---|---|---|---|---|
| **Next.js Support (25%)** | 5 | 3 | 3.5 | Vercel: native creator. Netlify: adapter, PPR not supported. CF: @opennextjs adapter, improving but edge cases remain. [Sources: devtoolreviews.com, makerkit.dev] |
| **Cost (20%)** | 3 | 3 | 5 | Vercel Hobby: 100GB BW, 100K fn invocations free. Netlify: 100 build min (reduced from 300 in 2025). CF: unlimited BW, $5/mo Pro. [Sources: vercel.com/docs/limits, codebrand.us] |
| **Developer Experience (20%)** | 5 | 4 | 3.5 | Vercel: zero-config Next.js, best preview deploys. Netlify: good but declining. CF: Wrangler CLI improved, steeper learning curve. [Sources: devtoolreviews.com] |
| **Performance (15%)** | 4 | 3.5 | 5 | CF: <50ms globally, V8 isolates, 300+ edge locations. Vercel: good but higher cold starts. [Sources: dev.to edge performance 2026] |
| **Security (10%)** | 4 | 3.5 | 4.5 | CF: built-in WAF, DDoS. Vercel: basic DDoS, firewall on Enterprise. Netlify: basic. [ASSUMPTION: based on documented features] |
| **Lock-in Risk (10%)** | 3 | 4 | 3.5 | Vercel: next.config.js mostly portable, but optimizations tied to platform. CF: Workers API is proprietary. Netlify: most standard. [ASSUMPTION] |

### Weighted Scores

| Platform | Calculation | Total |
|---|---|---|
| **Vercel** | 5×0.25 + 3×0.20 + 5×0.20 + 4×0.15 + 4×0.10 + 3×0.10 | **4.15** |
| **Cloudflare Pages** | 3.5×0.25 + 5×0.20 + 3.5×0.20 + 5×0.15 + 4.5×0.10 + 3.5×0.10 | **4.03** |
| **Netlify** | 3×0.25 + 3×0.20 + 4×0.20 + 3.5×0.15 + 3.5×0.10 + 4×0.10 | **3.43** |

## Decision

**Selected: Vercel**

### Why Vercel (Top 3 Advantages)

1. **Native Next.js 15 support**: Zero-config deployment with full App Router, Server Components, PPR, and ISR support -- no adapters needed
2. **Best-in-class DX**: Preview deployments per PR, integrated analytics, instant rollbacks, Vercel CLI
3. **Fastest builds**: Aggressive caching of node_modules and .next between builds reduces CI time

### Why Not Cloudflare Pages (Runner-up, Top 2 Disadvantages)

1. **Next.js support is adapter-dependent**: @opennextjs/cloudflare still has edge cases with App Router features; risk of compatibility issues
2. **Steeper learning curve**: Workers/Pages/D1/KV ecosystem requires more configuration knowledge

### Migration Path (If We Need to Switch)

1. Next.js app is largely portable (standard React + API routes)
2. Replace `vercel.json` with `wrangler.toml` or `netlify.toml`
3. Replace Vercel-specific env vars (`VERCEL_URL`, etc.) with platform equivalents
4. Update CI/CD workflows (change deploy commands)
5. Estimated effort: 1-2 days for a small app like this

## 6-Month Cost Projection

| Month | MAU | Bandwidth (est.) | Serverless Invocations | Vercel Plan | Monthly Cost |
|---|---|---|---|---|---|
| 1-3 | 10K | ~20 GB | ~50K | Hobby (Free) | $0 |
| 4 | 25K | ~50 GB | ~150K | Pro ($20/user) | $20 |
| 5 | 40K | ~80 GB | ~300K | Pro | $20 |
| 6 | 50K | ~100 GB | ~400K | Pro | $20 |
| **Total** | | | | | **$60** |

**Assumptions**:
- [ASSUMPTION] ~2KB avg page weight per visit, 5 pages/visit average
- [ASSUMPTION] ~5 serverless invocations per page load (API routes)
- Pro plan includes 1TB bandwidth and 1M invocations -- sufficient for projected traffic
- No overage charges expected within 6 months

## Consequences

**Positive:**
- Fastest path to production for Next.js
- Team can focus on product, not infrastructure
- Preview deploys improve code review quality

**Negative:**
- Vendor lock-in risk for Vercel-specific optimizations (Image Optimization, ISR)
- Pro plan required once commercial use begins ($20/user/month)
- Less control over edge runtime compared to Cloudflare Workers

**Mitigation:**
- Keep Next.js code standard (avoid `@vercel/*` packages where possible)
- Use Prisma (not Vercel Postgres) for DB abstraction
- Document migration path (see above)

---

Sources:
- [Vercel Limits](https://vercel.com/docs/limits)
- [Vercel vs Netlify vs Cloudflare Pages 2026](https://www.devtoolreviews.com/reviews/vercel-vs-netlify-vs-cloudflare-pages-2026)
- [Edge Performance 2026](https://dev.to/dataformathub/cloudflare-vs-vercel-vs-netlify-the-truth-about-edge-performance-2026-50h0)
- [10 Best Next.js Hosting Providers 2026](https://makerkit.dev/blog/tutorials/best-hosting-nextjs)
- [Vercel Pricing Explained 2026](https://schematichq.com/blog/vercel-pricing)
