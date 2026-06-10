# Platform Selection Rules
<!-- capability: platform_selection -->

## Quick Rule Index

| # | Rule | Applies When |
|---|------|-------------|
| PS1 | Vercel for Next.js-first projects — tightest integration, 12ms edge | SSR/ISR project with Next.js |
| PS2 | Netlify for static/Jamstack + commercial hobby projects — free tier allows commercial | Static sites, Hugo, Gatsby, Astro |
| PS3 | Fly.io for Docker-native apps needing global distribution — <500ms KVM boot | Docker containers, custom runtimes |
| PS4 | Railway for backend services needing one-click DB provisioning | API servers, background workers |
| PS5 | Self-hosted (Coolify) for full control + unlimited deploys on VPS | Budget-constrained, compliance needs |
| PS6 | Never select platform without weighted decision matrix | All platform decisions |
| PS7 | "Dashboard-Only" features usually have a CLI/API path — search for it | Any vendor-specific config task |

---

## Rules

### PS1: Vercel — Next.js-First Platform

When the project uses Next.js and needs edge performance:

| Attribute | Value |
|-----------|-------|
| Free Tier | Hobby (no commercial use) |
| Cold Start | ~1s serverless, ~12ms edge functions |
| Edge Runtime | V8 Edge Runtime |
| Databases | KV, Postgres, Blob Storage |
| Build Minutes | 6,000/month (free) |
| Deploy Command | `vercel --prod` |
| Preview Deploys | Automatic on every PR |
| Rollback | `vercel rollback` (instant, immutable snapshots) |

**When to choose**: Next.js projects, ISR/SSR workloads, teams wanting zero-config deploys. Vercel's integration with Next.js is first-party — edge middleware, image optimization, and incremental builds work without configuration.

**When NOT to choose**: Commercial hobby projects on free tier (ToS violation). Long-running processes (serverless 10s/30s timeout). Docker workloads (no Docker support).

**CLI workflow**:
```bash
npm i -g vercel
vercel login
vercel link                    # connect to existing project
vercel env pull .env.local     # pull env vars locally
vercel --prod                  # deploy to production
vercel rollback                # instant rollback to previous
```

### PS2: Netlify — Static/Jamstack with Commercial Hobby

When the project is static or Jamstack and needs a commercial-friendly free tier:

| Attribute | Value |
|-----------|-------|
| Free Tier | Starter (commercial OK) |
| Cold Start | ~3s serverless, 10-50ms edge |
| Edge Runtime | Deno-based Edge Functions |
| Databases | Netlify DB, Blobs |
| Build Minutes | 300/month (free) |
| Deploy Command | `netlify deploy --prod` |
| Rollback | Immutable deploy snapshots, rollback in <10s |

**When to choose**: Static sites (Hugo, Gatsby, Astro, Eleventy), Jamstack apps, hobby commercial projects. Free tier explicitly allows commercial use.

**When NOT to choose**: Heavy SSR workloads (edge functions are Deno-based, not Node-native). Build-heavy monorepos (300 min/month is tight). Complex server-side logic.

**CLI workflow**:
```bash
npm i -g netlify-cli
netlify login
netlify init                    # connect to repo
netlify deploy --prod           # deploy to production
netlify deploy --alias=staging  # deploy to staging URL
# Rollback: Dashboard > Published deploys > click "Publish deploy" on previous
```

**Config-as-code** (`netlify.toml`):
```toml
[build]
  command = "npm run build"
  publish = "dist"

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
```

### PS3: Fly.io — Docker-Native Global Distribution

When the project needs Docker containers deployed close to users:

| Attribute | Value |
|-----------|-------|
| Free Tier | 3 shared VMs (256MB) |
| Cold Start | <500ms (KVM microVM boot) |
| Edge | Docker containers in 32+ regions |
| Databases | Managed Postgres, Redis (LiteFS for SQLite) |
| Pricing | Usage-based ($0.0000022/s per shared CPU) |
| Deploy Command | `flyctl deploy` |

**When to choose**: Docker workloads, custom runtimes (Go, Rust, Python), apps needing global distribution with persistent connections (WebSocket). Fly.io runs real VMs, not serverless — no cold start timeout limits.

**When NOT to choose**: Teams wanting zero-config (Fly requires Dockerfile). Pure static sites (overkill). Budget-sensitive projects past free tier.

**CLI workflow**:
```bash
curl -L https://fly.io/install.sh | sh
flyctl auth login
flyctl launch                  # create app + Dockerfile
flyctl deploy                  # deploy
flyctl scale count 2           # scale to 2 instances
flyctl postgres create         # create managed Postgres
flyctl ssh console             # SSH into running VM
```

### PS4: Railway — One-Click Backend Services

When the project needs backend services with instant database provisioning:

| Attribute | Value |
|-----------|-------|
| Free Tier | 30 days trial |
| Cold Start | Zero (Pro plan, always-on) |
| Databases | PostgreSQL, MySQL, Redis, MongoDB (one-click) |
| Deploy | Git push or Docker |

**When to choose**: Backend APIs, background workers, projects needing PostgreSQL+Redis together. Railway's one-click database provisioning is the fastest path to a working backend.

**When NOT to choose**: Frontend-heavy projects (no edge/CDN). Long-term free usage (trial expires). Projects needing edge functions.

### PS5: Self-Hosted (Coolify) — Full Control on VPS

When the project needs unlimited deploys with full infrastructure control:

| Attribute | Value |
|-----------|-------|
| Cost | VPS only ($5-20/month for Hetzner/DigitalOcean) |
| Cold Start | Full control (always-on) |
| Databases | Any via Docker Compose |
| Build Minutes | Unlimited |
| Rollback | Docker image tags |

**When to choose**: Budget-constrained projects, compliance requirements (data residency), teams comfortable with Docker. Coolify gives a Vercel-like UI on your own VPS.

**Setup**:
```bash
# On a fresh VPS (Ubuntu 22.04+):
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
# Access dashboard at http://<VPS-IP>:8000
# Connect GitHub repo, configure build, deploy
```

### PS6: Weighted Decision Matrix (Mandatory)

When selecting a platform, NEVER choose based on familiarity or "everyone uses X." Build a weighted matrix:

| Dimension (Weight) | What to Measure |
|--------------------|-----------------|
| Performance (25%) | TTFB, cold start, CDN coverage |
| Cost (20%) | Free tier limits, 6-month growth projection |
| DX (20%) | CLI quality, preview deploys, log access |
| Scalability (15%) | Concurrent limits, bandwidth, auto-scale |
| Security (10%) | WAF, DDoS protection, OIDC support |
| Lock-in Risk (10%) | Platform-specific API dependencies |

Score each 1-5 with evidence (URL or `[ASSUMPTION]`). Calculate weighted totals. Document as ADR.

### PS7: "Dashboard-Only" Is Usually CLI-Resolvable

When a vendor's documented happy path is "click in the dashboard," do NOT accept that as the only path. Search vendor API docs / CLI docs / Terraform provider docs for the programmatic interface. Empirically ~80% of "dashboard-only" tasks have a CLI/API path. Document the CLI command in the deployment runbook so on-call does not depend on web UI availability.

---

## Anti-Patterns

- **"Everyone uses Vercel so we use Vercel"**: No requirements analysis. Vercel's free tier prohibits commercial use — this alone disqualifies many projects.
- **Assuming serverless = cheaper**: At stable traffic (>100K req/month), a $5/month VPS can outperform $50/month serverless bills.
- **Ignoring lock-in**: Vercel Edge Middleware, Netlify Edge Functions — platform-specific APIs that cost weeks to migrate away from.
- **Free tier selection without growth projection**: 300 build minutes works until your monorepo grows. Project the 6-month cost curve.
- **Skipping cold start testing**: Serverless cold starts range from 12ms (edge) to 3s (full Lambda). Measure, don't assume.
