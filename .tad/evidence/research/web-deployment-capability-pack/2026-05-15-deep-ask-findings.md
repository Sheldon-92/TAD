# web-deployment Capability Pack — Deep Ask Research Findings

> Notebook: Web Deployment — CI/CD, Platform Selection, Monitoring, Rollback
> Notebook ID: 2b6c8428-1ae9-476e-85d0-7be4a7243523
> Sources: 10 GitHub + deep research
> Date: 2026-05-15
> Rounds: 3

---

## Round 1: Platform Selection, CI/CD, Env Config

### Platform Decision Matrix
| Platform | Free Tier | Cold Start | Edge | DB | Build Mins | CLI |
|----------|-----------|-----------|------|-----|-----------|-----|
| Vercel | No commercial use | ~1s serverless, ~12ms edge | V8 Edge Runtime | KV, Postgres, Blob | 6000/mo | `vercel --prod` |
| Netlify | Commercial OK | ~3s serverless, 10-50ms edge | Deno-based | Netlify DB, Blobs | 300/mo | `netlify deploy --prod` |
| Fly.io | 3 shared VMs | <500ms (KVM boot) | Docker containers, 32+ regions | Managed Postgres, Redis | Usage-based | `flyctl` |
| Railway | 30 days free | Zero (Pro plan) | — | PostgreSQL, MySQL, Redis, MongoDB | — | — |
| AWS Amplify | 6 months free | Lambda-based | CloudFront | DynamoDB, Aurora | Pay-as-you-go | — |
| Self-hosted (Coolify) | Free (VPS cost only) | Full control | No native edge | Docker Compose DBs | Unlimited | Docker CLI |

### CI/CD (GitHub Actions)
- Stages: Source → Build → Test → Security → Deploy
- Caching: actions/cache@v4 for node_modules + build artifacts
- Matrix builds: multiple OS × Node versions in parallel
- Secrets: scoped secrets (2026) — bind to branches/environments, not repo-wide
- Deployment gates: GitHub Environments with manual reviewers + wait timers
- Lock actions to immutable commit SHAs (supply chain defense)

### Environment Config
- Immutable Docker images: build once, inject env vars at runtime
- Platform config-as-code: netlify.toml, vercel.json
- OIDC: eliminate stored secrets, use short-lived identity tokens
- External secret managers: Vault, AWS Secrets Manager, Azure Key Vault
- No long-lived .env secrets in repos

---

## Round 2: Monitoring, Rollback, DNS

### Monitoring
- Uptime Kuma: `docker run -d -p 3001:3001 louislam/uptime-kuma:1`
- Prometheus + Grafana: PromQL queries, dynamic dashboards
- Baseline/behavior-based alerting > static thresholds (reduces alert fatigue)
- SLA targets: 99.95% (standard) to 99.99% (enterprise)

### Rollback Strategies
- Blue-green: two identical envs, load balancer switches
- Canary: 1%→10%→100%, halt on error spike
- Atomic: symlink swap, instant revert
- Progressive rollouts: Vercel Flags for gradual traffic shift
- Netlify: immutable snapshots, rollback in <10s
- Docker: `docker run <image>:<commit-SHA>` for deterministic revert

### Domain/DNS
- Custom domain setup: 10-20 minutes, add to platform + update DNS
- SSL: automatic Let's Encrypt provisioning (Netlify, Coolify, Render, DigitalOcean)
- HTTPS redirects: built-in on all major platforms

---

## Round 3: Security, IaC, Cost

### Security Hardening
- Custom headers via netlify.toml / vercel.json
- Checkov for IaC scanning, Snyk/Grype for container images
- (Gap: specific CSP directives not in sources — supplement with web knowledge)

### IaC Selection
- Terraform: declarative HCL, predictable version-controlled infra
- Pulumi: standard programming languages (TS/Python/Go), more flexible
- SST: OpenNext for Next.js on AWS Lambda
- (Gap: CDK not covered in sources)

### Cost Anti-Patterns
- Over-provisioned servers without auto-scaling → Kubernetes/containers
- Unmanaged preview deployments → accumulate silently
- Silent credit drainers: image optimization, AI agents, bandwidth overages
- Monitoring: New Relic Cloud Cost Intelligence, Harness native cost visibility, Coroot for K8s

---

## Key Judgment Rules Extracted

### platform_selection
1. Vercel for Next.js-first projects (tightest integration, 12ms edge)
2. Netlify for static/Jamstack + commercial hobby projects (free tier allows commercial)
3. Fly.io for Docker-native apps needing global distribution (<500ms boot)
4. Railway for backend services needing one-click DB provisioning
5. Self-hosted (Coolify) for full control + unlimited deploys on VPS

### ci_cd_pipeline
1. GitHub Actions: stages Source→Build→Test→Security→Deploy
2. Lock actions to commit SHAs (not tags) — supply chain defense
3. Scoped secrets per environment (not repo-wide)
4. Matrix builds for OS × Node version coverage
5. Deployment gates: GitHub Environments with manual reviewers for prod

### environment_config
1. Build once, inject env vars at runtime (immutable images)
2. OIDC for cloud auth (eliminate stored secrets)
3. External secret managers for multi-service architectures
4. Platform config-as-code (netlify.toml / vercel.json)

### monitoring
1. Uptime Kuma for self-hosted uptime monitoring
2. Prometheus + Grafana for metrics + dashboards
3. Baseline-based alerting > static thresholds
4. SLA target: 99.95% minimum

### rollback_strategy
1. Immutable deploys: every deploy is a snapshot, rollback = point to previous
2. Canary for high-risk changes (1%→10%→100%)
3. Docker tag with commit SHA for deterministic rollback
4. Auto-rollback on error rate spike

### security_hardening
1. Custom security headers via platform config files
2. Checkov for IaC, Snyk/Grype for container images
3. SSL auto-provisioned via Let's Encrypt on all major platforms

### domain_dns
1. Custom domain: add to platform dashboard + update DNS records
2. SSL: automatic, no manual cert management needed
