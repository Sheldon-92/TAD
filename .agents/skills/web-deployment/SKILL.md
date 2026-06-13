---
name: web-deployment
description: Web deployment capability pack. Gives AI agents the judgment rules for platform selection (Vercel/Netlify/Fly.io/Coolify), CI/CD pipeline design (GitHub Actions, SHA pinning, matrix builds), environment configuration (OIDC, secret managers, immutable images), monitoring (Uptime Kuma, Prometheus+Grafana, SLA targets), rollback strategies (blue-green, canary, atomic, Docker SHA), security hardening (headers, Checkov, SSL), and domain/DNS management (custom domains, Let's Encrypt, Cache-Control). Research-grounded rules from platform docs, GitHub Actions best practices, and real-world deployment architectures. Use for any web application deployment, CI/CD setup, production monitoring, or infrastructure task.
keywords: ["部署", "deploy", "deployment", "CI/CD", "ci cd", "Docker", "Vercel", "Netlify", "监控", "monitoring", "rollback", "回滚", "蓝绿", "blue-green", "canary", "金丝雀", "GitHub Actions", "workflow", "域名", "DNS", "SSL", "Let's Encrypt", "环境变量", "secrets", "OIDC", "Fly.io", "Coolify", "uptime"]
type: reference-based
---

**CONSUMES**: User deployment task + target platform description + project framework + optional existing CI/CD configs
**PRODUCES**: Applied deployment judgment rules + CI/CD workflow configs + environment setup + monitoring configs + rollback SOPs + security headers + DNS records

# Web Deployment Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0

---

## What This Pack Does

AI agents deploy web apps by copying Vercel tutorial configs. They hardcode secrets in repos. They skip SHA pinning on GitHub Actions — using `@latest` tags that invite supply chain attacks. They set up monitoring dashboards nobody checks because there are no alerts. They have no rollback plan — when production breaks, they forward-fix under pressure. They configure DNS with wrong record types and leave HTTP open without redirects.

This pack embeds the judgment rules that deployment engineers apply automatically — rules from real platform documentation, CI/CD security research, and production incident patterns.

**Pack = deployment judgment. Your workflow system = process constraints. No overlap.**

---

## Cross-Cutting Rule: Immutable Deploys + OIDC Auth

> **Every deploy MUST produce an immutable artifact (Docker image with SHA tag, or platform-native immutable snapshot). Authentication to IaaS/cloud providers (AWS / GCP / Azure) MUST use OIDC identity tokens, not stored long-lived secrets.** Where a platform has no GA OIDC deploy path (e.g. Vercel / Netlify), use a platform deploy token scoped to a single GitHub Environment (`environment: production`), never a repo-wide secret. Stored long-lived credentials are the #1 deployment security incident vector. Mutable deploys ("just update the server") are the #1 rollback failure vector.

This rule applies to: CI/CD pipelines, environment configuration, rollback procedures, and platform selection criteria. It is surfaced here because burying it in one reference file causes agents to miss it.

---

## Step 0: Context Detection

When the user mentions deployment work, detect the context and load the right reference:

| User Signal | Reference to Load |
|-------------|-------------------|
| "which platform", "Vercel vs", "Netlify vs", "where to deploy", "平台选型", "hosting" | `references/platform-selection-rules.md` |
| "CI/CD", "GitHub Actions", "pipeline", "workflow", "自动部署", "构建" | `references/ci-cd-pipeline-rules.md` |
| "env vars", "secrets", "environment", "OIDC", ".env", "环境变量", "密钥" | `references/environment-config-rules.md` |
| "monitoring", "uptime", "alerting", "Prometheus", "Grafana", "监控", "告警" | `references/monitoring-rules.md` |
| "rollback", "blue-green", "canary", "revert", "回滚", "蓝绿", "金丝雀" | `references/rollback-rules.md` |
| "security headers", "CSP", "Checkov", "hardening", "SSL", "安全加固" | `references/security-hardening-rules.md` |
| "domain", "DNS", "custom domain", "Let's Encrypt", "HTTPS", "域名" | `references/domain-dns-rules.md` |
| "full deployment", "deploy everything", "production setup" | Load **all references** sequentially |

---

## Step 1: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** — do not skim
2. **Run the deterministic checker first** when GitHub Actions workflows exist — do NOT eyeball SHA-pinning, dead `@v3` artifact actions, missing `permissions:`, or `:latest` image tags by hand:
   ```bash
   scripts/verify-deploy-hardening.sh .github/workflows   # emits [P0]/[P1] lines; exit 2 = P0 present
   ```
   Fold its findings into your review. Determinism belongs in the script, judgment belongs in your prose.
3. **Apply each remaining rule as a judgment check** against the user's deployment setup, config, or request
4. **For each violated rule**: state the violation clearly, then give the specific fix with the exact CLI command
5. **Re-resolve every action SHA before recommending it** — never copy a SHA from this pack or any doc (tags get mutated, SHAs rot):
   ```bash
   scripts/find-action-sha.sh actions/checkout v4.1.7    # prints the current pinnable 40-char SHA
   ```
6. **Enforce the Immutable Deploys + OIDC cross-cutting rule** on every deployment configuration; verify release provenance before deploy (`scripts/find-action-sha.sh --attest <artifact> <owner/repo>`)
7. **Check platform-specific constraints** — free tier limits, cold start characteristics, and CLI commands differ per platform

Output format per finding:
```
[P0] Rule 3 (ci-cd): GitHub Actions uses actions/checkout@v4 tag — supply chain risk.
-> Pin to SHA: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11

[P1] Rule 2 (environment): API key stored as repo-wide secret — overly broad access.
-> Use GitHub Environment secrets scoped to production environment only.
```

---

## Step 2: Output

Produce a structured deployment review:

```
## Deployment Review: [area reviewed]

### P0 — Blocking (must fix before deploying)
- [finding + specific CLI command fix]

### P1 — Required (fix before production)
- [finding + specific fix]

### P2 — Advisory (improves deployment quality)
- [finding + specific fix]

### Platform Fit Check
[Does the chosen platform match the project requirements?]

### Immutable Deploy + OIDC Audit
[Are all deploys immutable? Is OIDC used for cloud auth?]

### Tool Recommendation
[Platform / CI tool based on user context]
```

---

## Anti-Skip Table

| Excuse | Counter |
|--------|---------|
| "We'll add CI/CD later" | Manual deploys are unreproducible. A 20-line GitHub Actions workflow takes 10 minutes to set up and prevents "works on my machine" failures forever. |
| "SHA pinning is overkill" | `actions/checkout@v4` resolves to whatever the maintainer pushes. CVE-2025-30066: the entire `tj-actions/changed-files` tag chain (`v1`–`v45.0.7`) was mutated to dump runner secrets into logs across 23,000+ repos. SHA pinning is a one-line change that is immune to tag mutation. Run `scripts/verify-deploy-hardening.sh` to find every unpinned `uses:`. |
| "actionlint already lints my workflows" | actionlint checks syntax, not supply-chain risk. Add `zizmor` (`unpinned-uses`, `impostor-commit`, `template-injection`, `excessive-permissions`) — it would have mitigated every major Actions attack of the past 18 months. |
| "upload-artifact@v3 still works" | It does not — `@v3`/`@v2` stopped working 2025-01-30; the job FAILS, it does not warn. Migrate to `@v4` (also up to 98% faster; artifact name must be unique per run). |
| "We don't need monitoring yet" | You need monitoring BEFORE the first user reports an outage. Uptime Kuma takes 1 Docker command: `docker run -d -p 3001:3001 louislam/uptime-kuma:1`. |
| "Rollback plan can wait" | Without a rollback plan, your MTTR is however long it takes to debug under pressure. With immutable deploys, rollback is one command: `vercel rollback` or `docker run <image>:<previous-SHA>`. |
| "Stored secrets are fine" | OIDC tokens expire in minutes. Stored secrets live until rotated — which is never. One leaked secret compromises every environment it touches. |
| "We'll handle DNS later" | HTTP without HTTPS redirect leaks credentials in transit. Let's Encrypt is free and automatic on every major platform. |

---

## Tool Quick Reference

| Tool | Install/Run | Primary Use |
|------|-------------|-------------|
| Vercel CLI | `npm i -g vercel` / `vercel --prod` | Deploy to Vercel platform |
| Netlify CLI | `npm i -g netlify-cli` / `netlify deploy --prod` | Deploy to Netlify platform |
| Fly.io CLI | `curl -L https://fly.io/install.sh \| sh` / `flyctl deploy` | Deploy Docker containers globally |
| Coolify | `curl -fsSL https://cdn.coollabs.io/coolify/install.sh \| bash` | Self-hosted PaaS on VPS |
| actionlint | `brew install actionlint` / `actionlint .github/workflows/*.yml` | Lint GitHub Actions workflow syntax |
| zizmor | `pip install zizmor` / `zizmor .github/workflows/` | Audit Actions for supply-chain/permission risk (40+ rules) |
| Uptime Kuma | `docker run -d -p 3001:3001 louislam/uptime-kuma:1` | Self-hosted uptime monitoring |
| Checkov | `pip install checkov` / `checkov -d .` | IaC security scanning |
| dotenvx | `npx @dotenvx/dotenvx get` | Env file validation + encryption |
| verify-deploy-hardening.sh | `scripts/verify-deploy-hardening.sh .github/workflows` | Deterministic check: unpinned `uses:`, dead `@v3` artifacts, missing `permissions:`, `:latest` |
| find-action-sha.sh | `scripts/find-action-sha.sh actions/checkout v4.1.7` | Re-resolve an action tag to a pinnable SHA; `--attest` verifies SLSA provenance |
