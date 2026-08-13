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
| CI9 | tj-actions/changed-files (CVE-2025-30066) — the dated incident behind SHA-pinning | GitHub Actions workflows |
| CI10 | Run zizmor as a CI gate (40+ audits) — actionlint is not enough | GitHub Actions security |
| CI11 | actions/upload-artifact@v3 is dead since 2025-01-30 — v4 mandatory | Artifact upload/download |
| CI12 | Artifact Attestations + SLSA provenance — sign + verify the build output | Release / supply-chain |
| CI13 | Immutable Releases + OCI immutable actions — protect the action supply chain | Tagging releases / publishing actions |

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

> ⚠️ **The SHAs above are illustrative, not authoritative.** Tags have been mutated in the wild (see CI9 / CVE-2025-30066), so a hardcoded SHA can silently rot or point at a yanked release. Always **re-resolve the current SHA for the version you actually want** with `scripts/find-action-sha.sh <owner/repo> <tag>` (or the `git ls-remote` below) before committing — never copy a SHA from a doc.

To find the SHA for a tag:
```bash
# Get the commit SHA for a specific tag
git ls-remote https://github.com/actions/checkout refs/tags/v4.1.7
# Or use the pack's verifier (also prints the dereferenced tag object):
scripts/find-action-sha.sh actions/checkout v4.1.7
```

Use `pin-github-action` to automate pinning:
```bash
npx pin-github-action .github/workflows/ci.yml
```

Verify the whole workflow tree deterministically with the pack's checker:
```bash
scripts/verify-deploy-hardening.sh .github/workflows
# Emits [P0]/[P1] lines for unpinned uses:, missing permissions:, dead @v3 artifact actions, :latest image tags
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

### CI9: The tj-actions/changed-files Compromise (CVE-2025-30066) — Why SHA-Pinning Is Not Optional

The abstract "tags are mutable" warning in CI2 became a concrete mass-compromise on **2025-03-14/15**. An attacker mutated the **entire tag chain of `tj-actions/changed-files` (every tag from `v1` through `v45.0.7`)** to point at a single malicious commit. The injected payload dumped the **CI runner's memory** (using `memdump.py` against the Runner.Worker process) and printed every credential it found **into the build logs** — where any reader of a public repo's Actions output could harvest them.

- **Blast radius**: **23,000+ repositories** referenced the action; public-repo logs leaked secrets.
- **Fix**: patched in **`v46.0.1`**; remediation window required **rotating any secret** exposed to a run between **2025-03-14 and 2025-03-15**.
- **The defense that would have stopped it**: SHA-pinning. A workflow pinned to a specific 40-char commit SHA is **immune to tag mutation** — the mutated `v35`/`v45` tags never change the SHA you already committed.

```yaml
# A SHA-pinned reference is immune to the v1..v45 tag-mutation chain:
- uses: tj-actions/changed-files@<verified-40-char-sha>  # NOT @v45
```

**Action**: SHA-pin every third-party action (CI2). After any disclosed action compromise, rotate secrets exposed to runs in the affected window, then re-resolve SHAs (`scripts/find-action-sha.sh`). Source: CISA AA, CVE-2025-30066 (retrieved 2026-06-13).

### CI10: Run zizmor as a CI Security Gate (MANDATORY)

`actionlint` only catches **syntax/expression** errors — it does NOT audit for supply-chain or permission risks. Add **`zizmor`** (static analysis for GitHub Actions, 40+ audit rules). Per the maintainers, running it "would have mitigated every major GitHub Actions attack from the past 18 months."

```bash
pip install zizmor          # or: brew install zizmor / uvx zizmor
zizmor .github/workflows/   # audit all workflows
zizmor --min-severity=high .github/workflows/   # gate on high+ in CI
```

Key audits to keep enabled (do NOT silence without written justification):

| Audit ID | What it catches | Default policy |
|----------|-----------------|----------------|
| `unpinned-uses` | actions referenced by tag/branch, not SHA | all third-party actions MUST be SHA-pinned |
| `impostor-commit` | a SHA that is NOT reachable from the named repo's branches/tags (typo-squat / fork commit) | flag |
| `known-vulnerable-actions` | actions with published CVEs (e.g. the CI9 class) | flag |
| `template-injection` | untrusted `${{ github.event.* }}` expanded into a `run:` shell | flag (RCE vector) |
| `excessive-permissions` | missing/over-broad token scope | recommends `permissions: {}` at workflow level, widen per-job |
| `dependabot-cooldown` | dependency PRs merged too fast to catch a poisoned release | default minimum **7 days** cooldown |

```yaml
- uses: zizmorcore/zizmor-action@<verified-sha>
  with:
    min-severity: high   # fail the build on high/critical findings
```

Source: docs.zizmor.sh/audits (retrieved 2026-06-13).

### CI11: actions/upload-artifact@v3 Is Dead — v4 Is Mandatory

`actions/upload-artifact@v3` and `actions/download-artifact@v3` (and `@v2`) **stopped working on 2025-01-30** — first via brownouts, then permanent failure. A workflow still on `@v3` does **not warn, it FAILS** with `This version of the action is no longer supported`.

- **Migrate to `@v4`** — which is also up to **98% faster** on upload/download (new backend).
- **Breaking change to know**: in v4 an artifact **name must be unique within a run** (you can no longer upload to the same name from multiple matrix jobs — suffix with the matrix key, e.g. `dist-${{ matrix.os }}`).
- **Pairs with CI2**: do not SHA-pin a *dead major* — `upload-artifact@<sha-of-v3>` is just as broken as `@v3`. Pin a v4 SHA.

```yaml
- uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02  # v4.6.2 — re-resolve before use
  with:
    name: dist-${{ matrix.os }}   # unique per run (v4 requirement)
    path: dist/
```

Source: github.blog v3 artifact deprecation notice (retrieved 2026-06-13).

### CI12: Artifact Attestations + SLSA Provenance (Sign and Verify the Build Output)

SHA-pinning protects the *inputs*; **artifact attestations** prove the *output* came from your pipeline. **GitHub Artifact Attestations** (GA **June 2024**, built on **Sigstore** with **ephemeral ~10-minute signing certs** and the **Rekor** transparency log) bind an artifact's **digest** to a **SLSA build-provenance predicate** (`in-toto` format). This is shifting from opt-in toward default for public repos through 2025–2026.

**Generate in CI** (needs `id-token: write` + `attestations: write`):
```yaml
permissions:
  id-token: write
  attestations: write
  contents: read
steps:
  - uses: actions/attest-build-provenance@<verified-sha>
    with:
      subject-path: dist/myapp.tar.gz   # or subject-name + subject-digest for an image
```

**Verify before deploy / on the consumer side**:
```bash
gh attestation verify dist/myapp.tar.gz --repo <owner/repo>
# Or wrap via the pack helper:
scripts/find-action-sha.sh --attest dist/myapp.tar.gz <owner/repo>
```

A deploy step that consumes an artifact with **no valid attestation for the expected repo** MUST fail closed. Source: docs.github.com Artifact Attestations concepts (retrieved 2026-06-13).

### CI13: Immutable Releases + Immutable Actions (Extend Immutability Upstream)

The cross-cutting "immutable deploy" rule protects the *deployed* artifact. Extend it **upstream to the action/release supply chain** so the thing you pin can't be moved out from under you:

- **GitHub Immutable Releases** — GA **2025-10-28**. Once published, a release's **tag and assets are protected from move/delete** and carry **signed attestations**. Enable for the repo so a `v1.2.3` release can't be silently re-pointed (the failure mode behind CI9).
- **Immutable actions as OCI packages** — publish your own actions to **`ghcr.io`** via **`actions/publish-immutable-action`**, giving the **tag + namespace** immutability (consumers resolve a fixed digest instead of a mutable git tag).

```yaml
# Publishing your action immutably (run on release):
- uses: actions/publish-immutable-action@<verified-sha>
```

Source: github.blog Immutable Releases GA + actions/publish-immutable-action (retrieved 2026-06-13).

---

## Anti-Patterns

- **`actions/checkout@latest`**: Supply chain attack vector. One compromised tag poisons every repo. SHA-pin everything.
- **No `permissions` block**: Default permissions are overly broad. Always declare minimal permissions explicitly.
- **Serial lint > typecheck > test > build**: Independent jobs should run in parallel. Serial execution wastes 40-60% of pipeline time.
- **No cache**: Full `npm install` on every run wastes 30-60 seconds per job. Cache with lockfile hash.
- **Secrets in logs**: Even GitHub's automatic masking can be bypassed with string splitting. Never `echo` secrets or pass them as command arguments visible in logs.
- **No `concurrency` group**: Two simultaneous deploys to the same environment cause race conditions and inconsistent state.
- **Pinning a mutable tag because "it's an official action"**: `tj-actions/changed-files` was popular and trusted — its full `v1..v45.0.7` tag chain was still mutated to dump runner memory into logs (CVE-2025-30066, 23,000+ repos). Trust does not exempt SHA-pinning.
- **`actionlint` as the only Actions check**: actionlint validates syntax, not supply-chain/permission risk. Add `zizmor` (`unpinned-uses`, `impostor-commit`, `template-injection`, `excessive-permissions`).
- **Still on `actions/upload-artifact@v3`**: dead since 2025-01-30 — the job FAILS, it does not warn. Migrate to `@v4` (unique artifact name per run).
- **Releasing without attestation**: an unsigned artifact can't be distinguished from a tampered one at deploy time. Generate `attest-build-provenance` and gate the deploy on `gh attestation verify`.
- **Copy-pasting a SHA from a doc/tutorial**: SHAs rot and tags get yanked. Re-resolve with `scripts/find-action-sha.sh` for the version you actually want.
