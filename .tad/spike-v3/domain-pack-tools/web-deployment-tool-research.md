# Web Deployment — Tool Research

> Date: 2026-04-01
> Researcher: Claude Code (automated spike)

## Summary

| # | Tool | Version | Install | Auth Required? | Verdict |
|---|------|---------|---------|----------------|---------|
| 1 | Vercel CLI | 48.1.0 | `npm i -g vercel` | Yes (token) for most ops | **PASS** (core) |
| 2 | actionlint | 1.7.12 | `brew install actionlint` | No | **PASS** (excellent) |
| 3 | Sentry CLI | 3.3.5 | `npx @sentry/cli` | Yes for all useful ops | **CONDITIONAL** |
| 4 | Lighthouse CI | 0.15.1 | `npx @lhci/cli` | No (needs Chrome) | **PASS** |
| 5 | observatory-cli | 0.7.1 | `npx observatory-cli` | No | **FAIL** (deprecated/502) |
| 6 | Docker CLI | N/A | Not installed | N/A | **SKIP** (not available) |
| 7 | dotenvx | 1.59.1 | `npx @dotenvx/dotenvx` | No | **PASS** |

---

## 1. Vercel CLI

**Install & verify:**
```bash
npm install -g vercel    # or: npx vercel
vercel --version         # → 48.1.0
```

**Capabilities tested:**
- `vercel --help` — full command list works (deploy, build, env, dev, init, inspect, link, ls, pull, etc.)
- `vercel init` — requires auth (401) even for template listing
- `vercel project ls` — requires auth token
- `vercel init --help` — help text works without auth

**Auth requirement:** Auth token required for virtually all operations except `--help` and `--version`. Must run `vercel login` first or set `VERCEL_TOKEN` env var.

**Key commands for Claude Code agent:**
- `vercel deploy` — deploy to preview
- `vercel deploy --prod` — deploy to production
- `vercel env pull` — pull env vars to local .env
- `vercel build` — local build test
- `vercel dev` — local dev server
- `vercel inspect <url>` — deployment info

**Verdict: PASS (core tool)**
Essential for Vercel-based projects. Auth is a prerequisite but standard for deployment tools. All operations are CLI-friendly and produce structured output.

---

## 2. actionlint

**Install & verify:**
```bash
brew install actionlint   # → 1.7.12, 6.0MB
actionlint --version
```

**Test results:**

Valid workflow (missing @ref):
```
test.yml:9:15: specifying action "actions/setup-node" in invalid format
because ref is missing. available formats are "{owner}/{repo}@{ref}"
```
Correctly caught `actions/setup-node` without version tag.

Bad workflow (expression error):
```
bad.yml:9:36: got unexpected character ' ' while lexing == operator,
expecting '=' [expression]
```
Correctly caught `=` vs `==` in GitHub Actions expression.

**Key features:**
- Zero config — just point at a workflow file
- Catches real errors: missing @ref, expression syntax, shell injection risks
- Exit code 1 on errors (CI-friendly)
- Works offline, no API calls

**Verdict: PASS (excellent)**
Catches real workflow errors that are common pain points. Zero setup, fast execution, no auth. Ideal for Claude Code agent to validate workflows before commit.

---

## 3. Sentry CLI

**Install & verify:**
```bash
npx @sentry/cli@latest --version   # → sentry-cli 3.3.5
```

**Capabilities tested:**
- `sentry-cli --help` — shows full command list (releases, sourcemaps, deploys, monitors, debug-files, etc.)
- `sentry-cli info` — shows config but fails: "Auth token is required"
- No config generation commands available without auth

**Key commands (require auth):**
- `sentry-cli releases new/finalize` — release management
- `sentry-cli sourcemaps upload` — upload source maps
- `sentry-cli deploys new` — register deployments
- `sentry-cli monitors` — cron monitoring

**Without auth:** Only `--help`, `--version`, and `completions` work.

**Verdict: CONDITIONAL**
Useful for projects already using Sentry, but zero functionality without auth token. Include in domain pack with clear auth prerequisite documentation. Not useful for generating configs or scaffolding.

---

## 4. Lighthouse CI (lhci)

**Install & verify:**
```bash
npx @lhci/cli --version   # → 0.15.1
```

**Prerequisites:** Chrome must be installed (verified via `lhci healthcheck`).

**Test results:**
```bash
lhci healthcheck
# ✅ .lighthouseci/ directory writable
# ⚠️  Configuration file not found
# ✅ Chrome installation found
# Healthcheck passed!

lhci collect --url="http://localhost:8765/index.html" --no-lighthouserc -n 1
# Running Lighthouse 1 time(s)... done.
```

Generated JSON report with scores:
```json
{"performance": 0.84, "accessibility": 0.79, "best-practices": 0.86, "seo": 0.9}
```

**Key commands:**
- `lhci collect --url=<URL>` — run Lighthouse audit
- `lhci assert` — check scores against thresholds
- `lhci autorun` — collect + assert + upload in one step
- Results in `.lighthouseci/` as JSON + HTML

**Verdict: PASS**
Works without auth, produces structured JSON scores. Requires Chrome but that's standard on dev machines. Excellent for pre-deploy performance checks. The `assert` command with threshold config is particularly useful for CI gates.

---

## 5. Mozilla Observatory CLI

**Install & verify:**
```bash
npx observatory-cli --version   # → 0.7.1
```

**Test results:**
```bash
observatory-cli example.com --format report
# ERROR 502 - Server Error
```

**Issues:**
- Package last published 2016 (10 years old)
- Uses deprecated dependencies (request, har-validator)
- Mozilla Observatory API returned 502 — service may be intermittent or deprecated
- Multiple npm deprecation warnings

**Alternative approach:** Security headers can be checked with `curl -sI <url>` (already in registry). Example:
```bash
curl -sI https://example.com | grep -iE "strict-transport|x-frame|content-security|x-content-type"
```
This is more reliable than the observatory-cli.

**Verdict: FAIL**
Deprecated, broken API backend. Use `curl -sI` + grep patterns instead for security header checks.

---

## 6. Docker CLI

**Check:**
```bash
which docker   # → not found
docker --version   # → command not found
```

**Notes:** Docker CLI not installed on this machine. Docker Desktop required for daemon. Even with CLI installed, most operations require Docker daemon running.

**Verdict: SKIP**
Not available. Would require Docker Desktop installation. Include as optional dependency with detection (`which docker`) in domain pack.

---

## 7. dotenvx

**Install & verify:**
```bash
npx @dotenvx/dotenvx --version   # → 1.59.1
```

**Note:** Package name is `@dotenvx/dotenvx`, NOT `dotenvx`.

**Test results:**
```bash
# Created .env with DB_HOST=localhost, DB_PORT=5432, API_KEY=
dotenvx ls        # → └─ .env
dotenvx get       # → {"DB_HOST":"localhost","DB_PORT":"5432","API_KEY":""}
dotenvx encrypt   # → ◈ encrypted (.env) + key (.env.keys)
```

**Key commands:**
- `dotenvx get [KEY]` — read env vars as JSON
- `dotenvx set KEY value` — set and encrypt a value
- `dotenvx encrypt` — encrypt .env file in place
- `dotenvx decrypt` — decrypt back to plain text
- `dotenvx run -- <cmd>` — inject env vars at runtime
- `dotenvx keypair` — manage encryption keys

**Verdict: PASS**
Works without auth, provides real value for env file management. Encryption/decryption is the killer feature — prevents accidental .env commits with plain secrets. JSON output from `get` is machine-parseable.

---

## Recommendations for Domain Pack

### Tier 1 — Include (no caveats)
| Tool | Use Case | npx-able? |
|------|----------|-----------|
| **actionlint** | Validate GitHub Actions workflows | No (brew) |
| **Lighthouse CI** | Pre-deploy performance audit | Yes |
| **dotenvx** | Env file management + encryption | Yes |

### Tier 2 — Include with auth prerequisite
| Tool | Use Case | npx-able? |
|------|----------|-----------|
| **Vercel CLI** | Deploy, env management, project ops | Yes |
| **Sentry CLI** | Release tracking, sourcemap upload | Yes |

### Tier 3 — Skip / Alternative
| Tool | Reason | Alternative |
|------|--------|-------------|
| observatory-cli | Deprecated, broken API | `curl -sI` + header grep |
| Docker CLI | Not installed, needs daemon | Detect with `which docker` |

### curl-based security header check (replaces observatory-cli)
```bash
# Check security headers for any URL
curl -sI https://example.com | grep -iE \
  "strict-transport-security|x-frame-options|content-security-policy|x-content-type-options|referrer-policy|permissions-policy"
```
This is reliable, zero-dependency, and already available via curl in the registry.
