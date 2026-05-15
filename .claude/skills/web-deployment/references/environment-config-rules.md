# Environment Configuration Rules
<!-- capability: environment_config -->

## Quick Rule Index

| # | Rule | Applies When |
|---|------|-------------|
| EC1 | Build once, inject env vars at runtime — immutable images | Docker / container deploys |
| EC2 | OIDC for cloud auth — eliminate stored secrets | CI/CD cloud provider auth |
| EC3 | External secret managers for multi-service architectures | Vault / AWS Secrets Manager / Azure Key Vault |
| EC4 | Platform config-as-code: netlify.toml / vercel.json | Platform-specific deploys |
| EC5 | Secret classification: L1 Critical through L4 Public | All env var management |
| EC6 | NEXT_PUBLIC_ prefix = client-visible — never put secrets there | Next.js projects |
| EC7 | Startup validation: fail fast on missing required env vars | All applications |

---

## Rules

### EC1: Immutable Images — Build Once, Inject at Runtime

When using Docker or containerized deployments, build the image ONCE and inject environment variables at runtime. Never bake secrets or env-specific config into the image.

**WRONG**:
```dockerfile
# Secrets baked into image — anyone with image access sees them
ENV DATABASE_URL=postgres://user:password@host/db
COPY .env .
RUN npm run build
```

**RIGHT**:
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --production
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
# ENV vars injected at runtime, not build time
CMD ["node", "dist/server.js"]
```

```bash
# Runtime injection
docker run -e DATABASE_URL="postgres://..." -e API_KEY="..." myapp:abc123
```

Tag images with commit SHA for deterministic rollback:
```bash
docker build -t myapp:$(git rev-parse --short HEAD) .
docker push myapp:$(git rev-parse --short HEAD)
```

### EC2: OIDC Authentication (MANDATORY for CI/CD)

When authenticating CI/CD pipelines to cloud providers, use OIDC identity tokens instead of stored secrets. OIDC tokens expire in minutes; stored secrets live until manually rotated.

**GitHub Actions OIDC to AWS**:
```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502
    with:
      role-to-assume: arn:aws:iam::123456789:role/github-deploy
      aws-region: us-east-1
```

**GitHub Actions OIDC to GCP**:
```yaml
steps:
  - uses: google-github-actions/auth@71fee32a0bb7e97b4d33d548e7d957010649d8fa
    with:
      workload_identity_provider: projects/123/locations/global/workloadIdentityPools/github/providers/github
      service_account: deploy@project.iam.gserviceaccount.com
```

**Why**: A stored `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` leaked via log exposure, fork access, or supply chain attack gives permanent access. OIDC tokens are scoped to the specific workflow run and expire automatically.

### EC3: External Secret Managers

When managing secrets across multiple services or environments:

| Tool | CLI Command | Best For |
|------|-------------|----------|
| HashiCorp Vault | `vault kv get secret/myapp/db` | Multi-cloud, self-hosted |
| AWS Secrets Manager | `aws secretsmanager get-secret-value --secret-id myapp/db` | AWS-native stacks |
| Azure Key Vault | `az keyvault secret show --name db-password --vault-name mykeyvault` | Azure-native stacks |
| 1Password CLI | `op read "op://Vault/Item/password"` | Small teams, developer-friendly |
| dotenvx | `npx @dotenvx/dotenvx get` | Encrypted .env files in git |

**Pattern**: Store secrets in the external manager. CI/CD pulls them at deploy time via OIDC-authenticated API call. Application reads them from environment variables injected by the orchestrator.

### EC4: Platform Config-as-Code

When deploying to managed platforms, use their config files instead of dashboard settings:

**Vercel** (`vercel.json`):
```json
{
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options", "value": "DENY" }
      ]
    }
  ]
}
```

**Netlify** (`netlify.toml`):
```toml
[build]
  command = "npm run build"
  publish = "dist"

[build.environment]
  NODE_VERSION = "20"

[[headers]]
  for = "/*"
  [headers.values]
    X-Content-Type-Options = "nosniff"
    X-Frame-Options = "DENY"
```

Config-as-code is version-controlled, reviewable in PRs, and reproducible. Dashboard settings are none of these.

### EC5: Secret Classification System

When managing environment variables, classify every variable:

| Level | Type | Storage | Example |
|-------|------|---------|---------|
| L1 Critical | Database passwords, encryption keys, API master keys | Secret manager only, CI/CD injection | `DATABASE_URL`, `ENCRYPTION_KEY` |
| L2 Sensitive | Third-party API keys, SMTP credentials | Platform env vars (environment-scoped) | `STRIPE_SECRET_KEY`, `SMTP_PASSWORD` |
| L3 Config | Feature flags, API base URLs, port numbers | `.env` files (gitignored) or platform env | `API_BASE_URL`, `FEATURE_FLAG_X` |
| L4 Public | App name, version, public API keys | Code or `.env.example` (committed) | `NEXT_PUBLIC_APP_NAME`, `APP_VERSION` |

**Rules**:
- L1 and L2 MUST NOT appear in `.env` files, even gitignored ones (developer machines get compromised)
- L3 goes in `.env.development` (gitignored) with safe defaults
- L4 goes in `.env.example` (committed) as documentation template
- Every variable in code MUST have a corresponding entry in `.env.example`

### EC6: NEXT_PUBLIC_ Prefix Is Client-Visible

When working with Next.js, any environment variable prefixed with `NEXT_PUBLIC_` is embedded into the client-side JavaScript bundle. It is visible to every user via browser DevTools.

**NEVER put L1 or L2 secrets in NEXT_PUBLIC_ variables.**

```bash
# SAFE — server-only
DATABASE_URL=postgres://...
STRIPE_SECRET_KEY=sk_live_...

# SAFE — intentionally public
NEXT_PUBLIC_APP_NAME=MyApp
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_...

# DANGEROUS — secret exposed to all users
NEXT_PUBLIC_DATABASE_URL=postgres://...        # NEVER
NEXT_PUBLIC_STRIPE_SECRET_KEY=sk_live_...      # NEVER
```

### EC7: Startup Validation — Fail Fast

When an application starts, validate ALL required environment variables immediately. Missing a critical variable should crash the app at startup, not at the first user request 30 minutes later.

**Node.js with Zod**:
```typescript
import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  API_KEY: z.string().min(1),
  NODE_ENV: z.enum(['development', 'staging', 'production']),
  PORT: z.coerce.number().default(3000),
});

export const env = envSchema.parse(process.env);
// Throws with clear error message if any required var is missing
```

---

## Anti-Patterns

- **`.env` committed to git**: Even "just the development one" trains the team to commit env files. Use `.env.example` as template, `.env*` in `.gitignore`.
- **Hardcoded API keys in source**: `const API_KEY = "sk_live_..."` is grep-discoverable by any contributor. Use env vars.
- **NEXT_PUBLIC_ secrets**: L1/L2 variables with `NEXT_PUBLIC_` prefix are shipped to every browser. Check every `NEXT_PUBLIC_` variable against the classification table.
- **Development env pointing to production DB**: One `DROP TABLE` in dev destroys production data. Development must use separate databases.
- **No startup validation**: Missing env vars cause cryptic runtime errors hours after deploy. Validate at startup with schema validation.
- **Repo-wide secrets**: A single leaked `VERCEL_TOKEN` at repo level gives access to all environments. Scope secrets to GitHub Environments.
