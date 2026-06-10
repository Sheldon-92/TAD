# CI/CD Pipeline Rules
<!-- capability: ci_cd_pipeline -->

## Quick Rule Index

| # | Rule | Applies When |
|---|------|-------------|
| CI1 | Five-stage pipeline: Source > Build > Test > Security > Deploy | Every CI/CD setup |
| CI2 | SHA-pin all third-party actions — never use `@latest` or `@v4` tags | GitHub Actions workflows |
| CI3 | Scoped secrets per environment, not repo-wide | Secret management |
| CI4 | Matrix builds for OS x Node version coverage | Multi-platform support |
| CI5 | Deployment gates with manual reviewers for production | Production deploys |
| CI6 | Cache node_modules + build artifacts with actions/cache@v4 | Build optimization |
| CI7 | Parallel stages for independent jobs (lint, typecheck, test) | Pipeline speed |
| CI8 | Concurrency groups to prevent parallel deploy conflicts | Deploy safety |

---

## Rules

### CI1: Five-Stage Pipeline Architecture

When designing a CI/CD pipeline, implement these five stages in order:

```
Source -> Build -> Test -> Security -> Deploy
```

| Stage | Jobs | Failure Behavior |
|-------|------|-----------------|
| Source | Checkout, dependency install, cache restore | Block all downstream |
| Build | Compile, bundle, type-check | Block Test + Deploy |
| Test | Unit tests, integration tests, coverage check | Block Deploy |
| Security | `actionlint`, dependency review, Checkov IaC scan | Block Deploy |
| Deploy | Platform deploy (preview on PR, production on main) | Notify team on failure |

**Trigger strategy**:
```yaml
on:
  push:
    branches: [main]        # -> production deploy
  pull_request:
    branches: [main]        # -> preview deploy + full CI
```

### CI2: SHA-Pin All Third-Party Actions (MANDATORY)

When using GitHub Actions, NEVER reference actions by tag. Tags are mutable — a compromised maintainer can push malicious code to `@v4`.

**WRONG**:
```yaml
- uses: actions/checkout@v4          # mutable tag
- uses: actions/setup-node@latest    # even worse
```

**RIGHT**:
```yaml
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.7
- uses: actions/setup-node@1e60f620b9541d16bece96c5465dc8ee9832be0b  # v4.0.3
```

To find the SHA for a tag:
```bash
# Get the commit SHA for a specific tag
git ls-remote https://github.com/actions/checkout refs/tags/v4.1.7
```

Use `pin-github-action` to automate pinning:
```bash
npx pin-github-action .github/workflows/ci.yml
```

### CI3: Scoped Secrets Per Environment

When managing secrets in GitHub Actions, use Environment secrets (scoped to specific environments) not Repository secrets (accessible to all workflows).

**Setup**:
1. Create environments in GitHub: Settings > Environments > `production`, `staging`, `preview`
2. Add secrets per environment (e.g., `VERCEL_TOKEN` only in `production`)
3. Reference in workflow:

```yaml
jobs:
  deploy:
    environment: production    # gates access to production secrets
    steps:
      - run: vercel --prod --token=${{ secrets.VERCEL_TOKEN }}
```

**OIDC is preferred over stored secrets** (cross-cutting rule):
```yaml
permissions:
  id-token: write    # required for OIDC
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502
    with:
      role-to-assume: arn:aws:iam::123456789:role/deploy-role
      aws-region: us-east-1
      # No stored AWS keys — OIDC token auto-exchanged
```

### CI4: Matrix Builds for Coverage

When supporting multiple Node.js versions or operating systems:

```yaml
strategy:
  matrix:
    node-version: [18, 20, 22]
    os: [ubuntu-latest]
  fail-fast: false    # don't cancel other matrix jobs on first failure
```

`fail-fast: false` ensures you see ALL failures, not just the first one. This matters when debugging platform-specific issues.

### CI5: Deployment Gates for Production

When deploying to production, require human approval via GitHub Environments:

1. Settings > Environments > `production`
2. Add **Required reviewers** (1-2 team members)
3. Add **Wait timer** (optional, e.g., 5 minutes for canary observation)
4. Add **Branch protection**: only `main` can deploy to production

```yaml
jobs:
  deploy-production:
    environment:
      name: production
      url: ${{ steps.deploy.outputs.url }}
    # This job pauses until a reviewer approves in the GitHub UI
```

### CI6: Caching Strategy

When caching dependencies and build artifacts:

```yaml
- uses: actions/cache@0c45773b623bea8c8e75f6c82b208c3cf94ea4f9  # v4.0.2
  with:
    path: |
      node_modules
      .next/cache
      ~/.npm
    key: ${{ runner.os }}-deps-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-deps-
```

**Rules**:
- Cache key MUST include lockfile hash (`package-lock.json`, `pnpm-lock.yaml`)
- Include framework build cache (`.next/cache`, `.nuxt`, `dist/.cache`)
- Set `restore-keys` for partial cache hits (faster than full install)
- Cache size limit: 10 GB per repo on GitHub Actions

### CI7: Parallel Independent Stages

When lint, type-check, and tests are independent, run them in parallel:

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11
      - run: npm ci
      - run: npm run lint

  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11
      - run: npm ci
      - run: npx tsc --noEmit

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11
      - run: npm ci
      - run: npm test -- --coverage

  deploy:
    needs: [lint, typecheck, test]   # waits for all three
    runs-on: ubuntu-latest
    # ...
```

Parallel stages cut pipeline time by 40-60% compared to serial execution.

### CI8: Concurrency Groups

When deploying, prevent multiple simultaneous deploys to the same environment:

```yaml
concurrency:
  group: deploy-${{ github.ref }}
  cancel-in-progress: true    # cancel previous deploy if new commit pushed
```

For production, prefer `cancel-in-progress: false` to let the current deploy finish.

---

## Anti-Patterns

- **`actions/checkout@latest`**: Supply chain attack vector. One compromised tag poisons every repo. SHA-pin everything.
- **No `permissions` block**: Default permissions are overly broad. Always declare minimal permissions explicitly.
- **Serial lint > typecheck > test > build**: Independent jobs should run in parallel. Serial execution wastes 40-60% of pipeline time.
- **No cache**: Full `npm install` on every run wastes 30-60 seconds per job. Cache with lockfile hash.
- **Secrets in logs**: Even GitHub's automatic masking can be bypassed with string splitting. Never `echo` secrets or pass them as command arguments visible in logs.
- **No `concurrency` group**: Two simultaneous deploys to the same environment cause race conditions and inconsistent state.
