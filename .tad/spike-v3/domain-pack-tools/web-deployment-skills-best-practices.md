# Web Deployment Skills Best Practices

> Research date: 2026-04-01
> Sources: 10 web searches, 9 deep-fetched pages, 6 GitHub repos analyzed

---

## Repositories Analyzed

| Repo | Stars | Key Focus |
|------|-------|-----------|
| [iuliandita/skills (ci-cd)](https://github.com/iuliandita/skills/blob/main/skills/ci-cd/SKILL.md) | - | CI/CD pipeline security, PCI-DSS 4.0 compliance, supply chain hardening |
| [ahmedasmar/devops-claude-skills](https://github.com/ahmedasmar/devops-claude-skills) | 112 | 6 specialized DevOps skills: IaC, K8s, AWS cost, CI/CD, GitOps, monitoring |
| [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | - | Vercel deployment, React best practices, web design guidelines |
| [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) | - | 220+ skills including ci-cd-pipeline-builder, observability-designer, env-secrets-manager, incident-commander |
| [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) | - | DevOps engineer subagent with phased maturity model |
| [GoogleChrome/lighthouse-ci](https://github.com/GoogleChrome/lighthouse-ci) | - | Performance monitoring CI integration, assertion presets, budgets |

---

## By Capability

---

### 1. Platform Selection (document type)

**Purpose**: Compare and choose between Vercel, Netlify, Cloudflare Pages, Docker/K8s, and traditional hosting.

#### Step Checklist

1. **Inventory application requirements**
   - SSR vs SSG vs SPA vs hybrid rendering
   - Edge function needs (middleware, geolocation routing)
   - Database/backend coupling (serverless functions vs separate API)
   - Build time constraints (monorepo size, asset pipeline)
   - Compliance requirements (data residency, SOC 2, PCI-DSS)

2. **Evaluate platform fit**
   | Criterion | Vercel | Netlify | Cloudflare Pages | Docker/K8s |
   |-----------|--------|---------|------------------|------------|
   | Best for | Next.js, React | JAMstack, static | Edge-first, Workers | Full control, microservices |
   | SSR support | Native (serverless) | Edge Functions | Workers | Full flexibility |
   | Build limits | 6000 min/mo (Pro) | 300 min/mo (Free) | 500 builds/mo (Free) | Self-managed |
   | Edge network | Global | Global | 300+ PoPs | Self-managed |
   | DB integration | Vercel Postgres, KV | Blobs | D1, KV, R2 | Any |
   | Lock-in risk | Medium (framework) | Low | Medium (Workers API) | Low |
   | Cost model | Per-seat + usage | Per-site + usage | Per-request | Infrastructure |

3. **Score using weighted decision matrix**
   - Weight categories: Performance (25%), Cost (20%), DX (20%), Scalability (15%), Security (10%), Vendor lock-in (10%)
   - Score each platform 1-5 per category
   - Document decision rationale in ADR format

4. **Validate with proof-of-concept**
   - Deploy a representative page to top 2 candidates
   - Measure: cold start latency, build time, TTFB from 3 regions
   - Test: environment variables, preview deployments, rollback

#### Analysis Frameworks

- **12-Factor App Methodology** — Assess platform compliance with all 12 factors:
  1. Codebase (one repo, many deploys)
  2. Dependencies (explicitly declared)
  3. Config (environment variables, not code)
  4. Backing services (attached resources)
  5. Build, release, run (strict separation)
  6. Processes (stateless, share-nothing)
  7. Port binding (self-contained)
  8. Concurrency (scale via process model)
  9. Disposability (fast startup, graceful shutdown)
  10. Dev/prod parity (minimize gaps)
  11. Logs (treat as event streams)
  12. Admin processes (run as one-off tasks)

#### Quality Standards

- Decision documented in ADR with trade-off analysis
- PoC deployed to at least 2 platforms with measured metrics
- Migration path documented if platform switch needed later
- Cost projection for 6-month horizon at expected traffic

#### Anti-patterns

- Choosing platform because "everyone uses it" without requirements analysis
- Assuming serverless = cheaper (spiky traffic yes, steady traffic often not)
- Ignoring vendor lock-in of platform-specific APIs (Vercel Edge Config, Netlify Blobs)
- Selecting based on free tier without projecting growth costs
- Not testing cold start latency for serverless functions

---

### 2. CI/CD Pipeline (code type)

**Purpose**: Build production-grade GitHub Actions / GitLab CI pipelines with security, caching, and quality gates.

#### Step Checklist

1. **Identify platform and gather requirements**
   - `.github/workflows/*.yml` = GitHub Actions
   - `.gitlab-ci.yml` = GitLab CI/CD
   - Triggers: push, PR, tag, schedule, manual dispatch
   - Build: language, runtime, package manager
   - Test: unit, integration, e2e, linting, typecheck
   - Deploy: target environment and strategy

2. **Design stage ordering** (fastest feedback first)
   ```
   lint -> test -> build -> scan -> deploy
   ```
   - Stage 1: Lint (fastest feedback, cheapest)
   - Stage 2: Test (unit, typecheck)
   - Stage 3: Build (compile, bundle, Docker image)
   - Stage 4: Scan (SAST, SCA, container scan, secret detection)
   - Stage 5: Deploy (staging auto, production manual gate)

3. **Apply the AI Self-Check before every pipeline config**

   | Check | Rule |
   |-------|------|
   | SHA pinning | All third-party actions pinned to full 40-char commit SHA, NOT mutable tags |
   | Permissions | Explicit `permissions:` block, read-only default |
   | No hardcoded secrets | Use CI/CD variables or vault integration |
   | No `latest` tags | Runner/tool/base images pinned to specific versions or digests |
   | Caching strategy | Dependencies cached with lockfile-based keys |
   | Fail-fast security | SAST, dependency scanning, secret detection run EARLY |
   | Manual gates | Production requires explicit approval (never auto-deploy) |
   | SBOM generation | Releases generate and attach SPDX/CycloneDX SBOMs |
   | Minimal scope | Jobs have minimum permissions, access only needed secrets |
   | No allow_failure | Without written justification |
   | Version pinning | Specific tool versions prevent silent breakage |
   | No expression injection | `${{ }}` never directly in `run:` blocks |

4. **Implement caching strategy**
   ```yaml
   # npm/bun
   key: ${{ hashFiles('**/package-lock.json') }}
   # pip
   key: ${{ hashFiles('**/requirements*.txt') }}
   # Go
   key: ${{ hashFiles('**/go.sum') }}
   ```
   **Rule**: Cache is speed optimization only. Pipelines MUST work without cache.

5. **Configure deployment gates**
   | Environment | Trigger | Approval |
   |-------------|---------|----------|
   | Dev/Preview | Every PR push | None |
   | Staging | Merge to main | None (auto-deploy) |
   | Production | Tag or manual dispatch | Required reviewer(s) |

6. **Monorepo patterns**
   - Use `paths:` filters for per-service triggering
   - Always rebuild when shared lib changes
   - Prefer per-service workflows over single workflow with matrix

#### Source List

- [GitHub Actions Secure Use Reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [GitHub Actions 2026 Security Roadmap](https://github.blog/news-insights/product-news/whats-coming-to-our-github-actions-2026-security-roadmap/)
- [iuliandita/skills CI/CD SKILL.md](https://github.com/iuliandita/skills/blob/main/skills/ci-cd/SKILL.md)
- [StepSecurity SHA Pinning Guide](https://www.stepsecurity.io/blog/pinning-github-actions-for-enhanced-security-a-complete-guide)

#### Analysis Frameworks

- **Supply Chain Security Model**: SHA pinning + SBOM generation + signed artifacts + immutable releases
- **PCI-DSS 4.0 Mapping**: Req 6.2.1 (SAST on every PR), 6.2.4 (branch protection + signed commits), 6.3.2 (SBOM per release), 6.4.2 (gated deployments), 6.5.3 (consistent scanning across environments)
- **GitHub 2026 `dependencies:` Section**: New workflow YAML feature that locks all direct and transitive action dependencies with commit SHAs (similar to go.sum)

#### Quality Standards

- Zero hardcoded secrets (automated secret scanning in pipeline)
- 100% of third-party actions SHA-pinned
- Build succeeds without cache (tested monthly)
- Production deploy requires human approval
- SBOM attached to every release artifact
- Pipeline execution time < 10 minutes for PR checks

#### Anti-patterns

- Using mutable tags (`@v4`) instead of SHA pins — tj-actions, reviewdog, Trivy compromises proved this dangerous
- `${{ github.event.pull_request.title }}` in `run:` blocks (expression injection attack vector)
- `allow_failure: true` without documented justification
- Skipping security scanning in development environments (PCI-DSS 6.5.3 requires consistency)
- Cache as artifact — cache can evict anytime; artifacts are guaranteed inter-job data
- Auto-deploying to production without manual gate
- Using `ubuntu-latest` instead of pinned runner version
- AI-generated pipelines used without running AI Self-Check (AI consistently generates insecure configs: unpinned actions, missing permissions blocks, latest tags)

---

### 3. Environment Config (code type)

**Purpose**: Manage .env files, secrets, multi-environment configuration safely.

#### Step Checklist

1. **Establish environment hierarchy**
   ```
   .env.example       # Template with keys, no values (committed)
   .env.local         # Local overrides (gitignored)
   .env.development   # Dev defaults (committed if non-sensitive)
   .env.staging       # Staging config (CI/CD variables only)
   .env.production    # Production config (CI/CD variables only)
   ```

2. **Secret classification**
   | Level | Examples | Storage |
   |-------|---------|---------|
   | Public | API_URL, NEXT_PUBLIC_* | .env committed |
   | Internal | DB_HOST, REDIS_URL | CI/CD environment variables |
   | Secret | API_KEYS, DB_PASSWORD | Vault / CI/CD secrets with branch protection |
   | Critical | Signing keys, master passwords | HSM / KMS with audit trail |

3. **Platform-specific secret management**
   | Platform | Mechanism | Scope Control |
   |----------|-----------|---------------|
   | GitHub Actions | Repository/org/environment secrets | Per-environment, per-repo, per-org; deployment branches |
   | GitLab CI | CI/CD variables | Protected branches/tags, environments, masked in logs |
   | Vercel | Environment variables UI/CLI | Per-environment (dev/preview/prod) |
   | Netlify | Environment variables + .env | Per-context (deploy previews, branch) |

4. **Validation at build time**
   - Use schema validation (e.g., `zod`, `@t3-oss/env-nextjs`) to fail builds on missing/invalid env vars
   - Never provide defaults for secrets — fail loudly
   - Separate client-safe vars (NEXT_PUBLIC_*, VITE_*) from server-only

5. **Rotation workflow**
   - Automate rotation schedule (90 days for API keys, 365 for certs)
   - Rotate immediately after any team member departure
   - Test rotation in staging before production
   - Document rotation runbook per secret type

#### Quality Standards

- `.env.example` always in sync with actual env vars used
- Zero secrets in git history (verified by secret scanning)
- All environments use the same variable names (different values)
- Build fails if required env var is missing (schema validation)
- Secret rotation documented and tested

#### Anti-patterns

- Committing `.env` files with real secrets to git
- Using environment variables as feature flags (use proper feature flag service)
- Storing secrets in Docker images or build artifacts
- Echoing secrets in CI logs or passing as CLI arguments (visible in `ps`)
- Having different variable names across environments
- Hardcoding production URLs in code instead of env vars
- Using `NEXT_PUBLIC_` prefix for server-only secrets

---

### 4. Domain & DNS (code type)

**Purpose**: Configure DNS, SSL/TLS, CDN, and domain management.

#### Step Checklist

1. **DNS configuration**
   - Set A/AAAA records for root domain
   - Set CNAME for www subdomain (or redirect)
   - Configure CAA records to restrict certificate issuers
   - Set up SPF, DKIM, DMARC for email deliverability
   - TTL strategy: 3600s for stable records, 60s before migration

2. **SSL/TLS setup**
   - Enforce HTTPS everywhere with HSTS header
   - HSTS config: `max-age=63072000; includeSubDomains; preload`
   - Submit to HSTS preload list after confirming all subdomains support HTTPS
   - Use TLS 1.3 minimum (disable TLS 1.0, 1.1, 1.2 where possible)
   - Auto-renewal via Let's Encrypt or platform-managed certificates
   - Certificate monitoring with expiry alerts (7-day and 1-day warnings)

3. **CDN configuration**
   - Cache-Control headers for static assets: `public, max-age=31536000, immutable` (hashed filenames)
   - Cache-Control for HTML: `no-cache` or `s-maxage=60, stale-while-revalidate=3600`
   - Configure CDN purge on deploy
   - Set up custom cache keys for A/B testing or localization
   - Enable Brotli compression (preferred over gzip)

4. **Multi-domain management**
   - Canonical URL strategy (www vs non-www, trailing slashes)
   - 301 redirects for deprecated domains
   - Wildcard SSL for subdomains if needed
   - Separate staging domain (never share production domain)

#### Quality Standards

- SSL Labs score: A+ (test at ssllabs.com/ssltest)
- HSTS preload list submitted and confirmed
- DNS propagation verified from multiple regions
- Zero mixed-content warnings
- CAA records configured

#### Anti-patterns

- Using self-signed certificates in production
- Not setting up HSTS preload (allows SSL stripping attacks)
- Pointing staging to production database via DNS
- TTL too low in steady state (unnecessary DNS load) or too high before migration (slow failover)
- Forgetting CAA records (any CA can issue certificates for your domain)

---

### 5. Monitoring (code type)

**Purpose**: Set up error tracking, performance monitoring, uptime checks, and alerting.

#### Step Checklist

1. **Error tracking (Sentry or equivalent)**
   - Install SDK with source maps upload in CI/CD
   - Configure environment tags (dev/staging/production)
   - Set up release tracking tied to git commits
   - Configure alert rules: new error type, error spike (2x baseline), P0 errors
   - Set up Slack/PagerDuty integration for critical alerts
   - Define error budget: < 0.1% error rate for user-facing flows

2. **Performance monitoring (Lighthouse CI)**
   - Install: `npm install -g @lhci/cli`
   - Configuration file `lighthouserc.js`:
     ```javascript
     module.exports = {
       ci: {
         collect: {
           startServerCommand: 'npm run serve',
           url: ['http://localhost:3000', 'http://localhost:3000/dashboard'],
           numberOfRuns: 5
         },
         assert: {
           preset: 'lighthouse:recommended',
           assertions: {
             'categories:performance': ['error', { minScore: 0.9 }],
             'categories:accessibility': ['error', { minScore: 0.95 }],
             'categories:best-practices': ['error', { minScore: 0.9 }],
             'categories:seo': ['error', { minScore: 0.9 }],
             'first-contentful-paint': ['warn', { maxNumericValue: 2000 }],
             'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],
             'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
             'total-blocking-time': ['error', { maxNumericValue: 300 }]
           }
         },
         upload: {
           target: 'temporary-public-storage' // or 'lhci' for self-hosted
         }
       }
     };
     ```
   - Add to CI pipeline: `lhci autorun` after build step
   - Upload results to LHCI server for trend tracking

3. **Real User Monitoring (RUM)**
   - Enable Vercel Speed Insights / Web Vitals collection
   - Track Core Web Vitals: LCP < 2.5s, FID < 100ms, CLS < 0.1, INP < 200ms
   - Segment by: device type, connection speed, geography
   - Set up dashboards for p50, p75, p95 latency

4. **Uptime monitoring**
   - External health check endpoint (`/api/health` or `/healthz`)
   - Check interval: 60s for production, 300s for staging
   - Monitor from multiple regions (minimum 3)
   - Alert escalation: 1 failure = warning, 3 consecutive = incident
   - Status page (public or internal) updated automatically

5. **SLO/SLI definition**
   - Availability SLO: 99.9% (8.76 hours downtime/year)
   - Latency SLI: p95 response time < 500ms
   - Error SLI: error rate < 0.1%
   - Error budget calculation and tracking
   - Monthly SLO review cadence

#### Source List

- [Lighthouse CI Getting Started](https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/getting-started.md)
- [Lighthouse CI Configuration](https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/configuration.md)
- [web.dev Lighthouse CI Guide](https://web.dev/articles/lighthouse-ci)
- [ahmedasmar/devops-claude-skills monitoring-observability](https://github.com/ahmedasmar/devops-claude-skills)

#### Analysis Frameworks

- **Google DORA Metrics**: Deployment frequency, lead time, change failure rate, time to restore
- **SLO/SLI/Error Budget Model**: Define measurable service objectives, track against budget
- **OpenTelemetry Standard**: Unified traces, metrics, logs collection

#### Quality Standards

- Lighthouse CI running on every PR with assertion thresholds
- Core Web Vitals meeting "Good" thresholds for 75th percentile
- Error tracking with source maps and release correlation
- Uptime monitoring from 3+ regions with < 5 min detection
- SLOs defined, measured, and reviewed monthly
- Alert fatigue < 10 non-actionable alerts per week

#### Anti-patterns

- Monitoring only in production (catch regressions in PR with Lighthouse CI)
- Alert on every error instead of error rate/spike
- No source maps in error tracking (useless stack traces)
- Monitoring without defined SLOs (no baseline = no actionable alerts)
- Uptime check only from one region
- Not tracking Core Web Vitals (Google ranking factor since 2021)
- Dashboard without alerting (nobody watches dashboards proactively)

---

### 6. Security Hardening (document -> code type)

**Purpose**: Implement OWASP security headers, CSP, CORS, rate limiting, and web application hardening.

#### Step Checklist

1. **Security headers (OWASP HTTP Headers Cheat Sheet)**

   **Headers to SET:**
   | Header | Value | Purpose |
   |--------|-------|---------|
   | `Strict-Transport-Security` | `max-age=63072000; includeSubDomains; preload` | Force HTTPS |
   | `Content-Security-Policy` | See CSP section below | Prevent XSS, injection |
   | `X-Content-Type-Options` | `nosniff` | Prevent MIME sniffing |
   | `X-Frame-Options` | `DENY` | Prevent clickjacking (legacy) |
   | `Referrer-Policy` | `strict-origin-when-cross-origin` | Control referrer leakage |
   | `Permissions-Policy` | `geolocation=(), camera=(), microphone=()` | Disable unused browser APIs |
   | `Cross-Origin-Opener-Policy` | `same-origin` | Isolate browsing context |
   | `Cross-Origin-Embedder-Policy` | `require-corp` | Enable cross-origin isolation |
   | `Cross-Origin-Resource-Policy` | `same-site` | Prevent cross-origin reads |

   **Headers to REMOVE:**
   | Header | Reason |
   |--------|--------|
   | `Server` | Reveals server software version |
   | `X-Powered-By` | Reveals framework (Express, ASP.NET) |
   | `X-AspNet-Version` | Version disclosure |
   | `X-XSS-Protection` | Deprecated, can create vulnerabilities — set to `0` or omit |
   | `Expect-CT` | Deprecated |
   | `Public-Key-Pins` | Deprecated, dangerous |

2. **Content Security Policy (CSP) implementation**

   **Phase 1 — Report-Only mode:**
   ```
   Content-Security-Policy-Report-Only: default-src 'self'; report-uri /csp-report
   ```
   - Deploy in report-only for 1-2 weeks
   - Collect and analyze violation reports
   - Identify legitimate third-party resources

   **Phase 2 — Strict CSP with nonces:**
   ```
   Content-Security-Policy:
     default-src 'none';
     script-src 'nonce-{RANDOM}' 'strict-dynamic';
     style-src 'self' 'nonce-{RANDOM}';
     img-src 'self' data: https:;
     font-src 'self';
     connect-src 'self' https://api.example.com;
     frame-ancestors 'none';
     form-action 'self';
     base-uri 'none';
     object-src 'none';
     upgrade-insecure-requests;
     report-uri /csp-report;
   ```

   **Critical rules:**
   - Never use `unsafe-inline` or `unsafe-eval` — use nonce or hash
   - Generate unique nonce per request (not reusable)
   - `frame-ancestors 'none'` supersedes X-Frame-Options
   - CSP via HTTP header preferred over `<meta>` tag (meta doesn't support frame-ancestors, report-uri)

3. **CORS configuration**
   - Whitelist specific origins (never `*` with credentials)
   - Validate Origin header server-side
   - Set `Access-Control-Max-Age` for preflight caching (86400s)
   - Restrict `Access-Control-Allow-Methods` to actually used methods
   - Restrict `Access-Control-Allow-Headers` to actually used headers

4. **Rate limiting**
   - Global rate limit: 100 requests/minute per IP
   - Auth endpoints: 5 attempts/minute per IP
   - API endpoints: Based on plan tier with clear 429 responses
   - Include `Retry-After` header in 429 responses
   - Use Vercel WAF, Cloudflare, or nginx for edge-level limiting

5. **Additional hardening**
   - Enable HTTPS everywhere with `upgrade-insecure-requests`
   - Implement CSRF tokens for state-changing operations
   - Set secure cookie attributes: `Secure; HttpOnly; SameSite=Strict; Path=/`
   - Input validation and output encoding (CSP is defense-in-depth, not primary defense)
   - Dependency vulnerability scanning in CI (npm audit, Snyk, Dependabot)

#### Source List

- [OWASP HTTP Headers Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Headers_Cheat_Sheet.html)
- [OWASP CSP Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html)
- [OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/)
- [MDN Content Security Policy Guide](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CSP)

#### Analysis Frameworks

- **OWASP Top 10 (2021)**: A01-Broken Access Control, A02-Cryptographic Failures, A03-Injection, A05-Security Misconfiguration, A07-XSS
- **OWASP Secure Headers Project**: Comprehensive header recommendations with best/good/bad ratings
- **CSP Evaluator**: Tool to assess policy strength (csp-evaluator.withgoogle.com)
- **Security Scorecard**: securityheaders.com for quick A-F grading

#### Quality Standards

- securityheaders.com grade: A+ (all recommended headers present)
- CSP in enforce mode (not just report-only) with nonce/hash based script control
- Zero `unsafe-inline` or `unsafe-eval` in CSP
- Rate limiting active on all auth and API endpoints
- Dependency vulnerability scan on every PR (zero critical/high)
- SSL Labs grade: A+
- Cookie attributes: Secure, HttpOnly, SameSite on all session cookies

#### Anti-patterns

- Copy-pasting CSP from another project without understanding each directive
- Using `unsafe-inline` "because styled-components needs it" (use nonces instead)
- Deploying CSP in enforce mode without report-only testing first
- Setting CORS to `*` for convenience during development and forgetting to restrict
- Rate limiting only at application layer (DDoS hits before app code runs — need edge-level)
- Thinking CSP replaces input validation (CSP is second layer of defense)
- Setting `X-XSS-Protection: 1; mode=block` (deprecated, can create vulnerabilities)
- Not removing `Server` and `X-Powered-By` headers (information disclosure)

---

### 7. Rollback Strategy (document type)

**Purpose**: Define rollback patterns, deployment strategies, and disaster recovery procedures.

#### Step Checklist

1. **Choose deployment strategy by context**

   | Strategy | Best For | Rollback Speed | Cost | Complexity |
   |----------|---------|---------------|------|------------|
   | **Blue-Green** | Mission-critical apps, security patches | Instant (traffic flip) | High (2x infra) | Low |
   | **Canary** | Major features, gradual confidence building | Fast (reroute traffic) | Low (shared infra) | High |
   | **Rolling** | Routine updates, backward-compatible changes | Medium (batch revert) | Low | Low |
   | **Recreate** | Breaking changes, database migrations | Slow (full redeploy) | Low | Low |

2. **Blue-Green deployment procedure**
   - Maintain two identical environments (blue = live, green = staging)
   - Deploy new version to green environment
   - Run smoke tests against green
   - Switch load balancer/DNS from blue to green
   - Monitor for 15-30 minutes
   - Rollback: switch traffic back to blue (< 1 minute)
   - Keep blue alive for 24 hours as safety net

3. **Canary deployment procedure**
   - Deploy new version to canary subset (2-5% of traffic)
   - Monitor error rates, latency, and business metrics for 15-30 minutes
   - If healthy: increase to 25%, then 50%, then 100%
   - At each stage: compare canary metrics to baseline
   - Rollback: route 100% traffic to stable version
   - **Requires**: Traffic routing capability + real-time monitoring + automated health checks

4. **Platform-specific rollback**
   | Platform | Rollback Method |
   |----------|----------------|
   | Vercel | Promote previous deployment via dashboard/CLI: `vercel promote <deployment-url>` |
   | Netlify | One-click rollback to any previous deploy in dashboard |
   | GitHub Pages | `git revert` + push |
   | Docker/K8s | `kubectl rollout undo deployment/<name>` |
   | AWS ECS | Update service to previous task definition |

5. **Database rollback strategy**
   - Always use forward-compatible migrations (additive only)
   - Never drop columns in the same deploy as code changes
   - Two-phase migration: Phase 1 = add new column + deploy code reading both, Phase 2 = drop old column after confirmation
   - Keep migration rollback scripts tested and ready
   - Database backups before every schema migration

6. **Disaster recovery**
   - RTO (Recovery Time Objective): Define per service tier
   - RPO (Recovery Point Objective): Define acceptable data loss window
   - Automated backups with tested restore procedure (test quarterly)
   - Multi-region failover for critical services
   - Runbook for each failure scenario (DNS, CDN, database, API)
   - Incident response playbook with escalation paths

#### Analysis Frameworks

- **MTTR (Mean Time To Recovery)**: Primary metric for rollback effectiveness
- **Error Budget Model**: Rollback decision based on error budget consumption rate
- **Blast Radius Analysis**: Assess how many users affected before rollback triggers
- **Forward Fix vs Rollback Decision Tree**:
  ```
  Is the fix obvious and < 5 min? -> Forward fix
  Is data being corrupted? -> Immediate rollback
  Is error rate > 5x baseline? -> Immediate rollback
  Is error rate 2-5x baseline? -> Canary rollback (route away from new version)
  Is error rate < 2x baseline? -> Monitor, prepare rollback, investigate
  ```

#### Quality Standards

- Rollback procedure tested monthly (not just documented)
- Rollback execution time < 5 minutes for any deployment
- Zero-downtime rollback for all non-database changes
- Database migrations are forward-compatible (no destructive changes in same deploy)
- Incident response runbook reviewed and updated quarterly
- RTO and RPO defined and tested for all critical services
- Post-incident review (PIR) within 48 hours of any rollback

#### Anti-patterns

- "We'll figure out rollback when we need it" (untested rollback = no rollback)
- Destructive database migrations coupled with code deployment
- Assuming platform rollback works without testing it
- Blue-green with shared database (state inconsistency risk)
- No monitoring during canary phase (flying blind)
- Rollback without understanding root cause (will redeploy same bug)
- In-flight transaction loss during traffic switch (need graceful draining)
- Not keeping previous version alive long enough (24h minimum for blue-green)

---

## Cross-Cutting Concerns

### Vercel Production Checklist (Consolidated)

From Vercel's official production checklist (updated March 2026):

**Operational Excellence:**
- Define incident response plan with escalation paths
- Familiarize with staging, promote, and rollback deployment flows
- Configure monorepo caching to prevent unnecessary builds
- Enable Log Drains for log persistence

**Security:**
- Configure Vercel Web Application Firewall (WAF)
- Enable Deployment Protection
- Implement CSP headers
- Authorize fork PRs before deploying (protects env vars and OIDC tokens)

**Reliability:**
- Enable automatic Function failover for multi-region redundancy
- Implement caching headers for static assets
- Enable Speed Insights for Core Web Vitals tracking

**Performance:**
- Review and optimize image loading (next/image optimization)
- Implement ISR or on-demand revalidation where appropriate

**Cost Optimization:**
- Opt into latest image optimization pricing
- Review function execution time and memory allocation

### GitHub Actions 2026 Security Evolution

Key 2026 developments for CI/CD security:
- **`dependencies:` section** in workflow YAML — locks all action dependencies with SHAs (like go.sum for workflows)
- **Immutable releases** — once marked immutable, assets and Git tags cannot be changed or deleted
- **Action blocking policies** — organizations can block specific actions in addition to allowlisting
- **Deterministic runs** — hash mismatches stop execution before jobs run

---

## Implementation Priority Order

For a new project adopting these practices:

| Phase | Capability | Timeline |
|-------|-----------|----------|
| 1 | CI/CD Pipeline (basic lint + test + build) | Day 1 |
| 2 | Environment Config (.env.example + schema validation) | Day 1 |
| 3 | Security Headers (HSTS + CSP report-only + basics) | Week 1 |
| 4 | Monitoring (error tracking + Lighthouse CI) | Week 1 |
| 5 | Platform Selection (if not already decided) | Week 1-2 |
| 6 | Domain & DNS (SSL, CDN, HSTS preload) | Week 2 |
| 7 | CI/CD Hardening (SHA pinning, SBOM, security scanning) | Week 2-3 |
| 8 | CSP enforcement (switch from report-only) | Week 3-4 |
| 9 | Rollback Strategy (blue-green or canary setup) | Week 3-4 |
| 10 | SLO definition and monitoring maturity | Month 2 |
