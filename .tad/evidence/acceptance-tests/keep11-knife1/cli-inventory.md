# CLI Inventory — KEEP11 Knife 1 (code-security + web-deployment)

**Date:** 2026-09-11 · **Host:** impl host (opencode) · **Method:** `command -v` + `--help`/`--version`
where present; official docs URL where ABSENT (no Gemini, per human lock).
Live SHA via `.claude/skills/web-deployment/scripts/find-action-sha.sh` (network OK).

## Host tool status

| Tool | Documented invocation(s) | Status | Evidence |
|------|--------------------------|--------|----------|
| gitleaks | `gitleaks git --staged -v`, `gitleaks git . --report-format json --report-path … -v` | ABSENT | http — https://github.com/gitleaks/gitleaks (latest v8.30.1, 2026-03-21, still latest on releases page) |
| trufflehog | `trufflehog git/filesystem/s3 …` (flag renamed, see below) | ABSENT | http — https://github.com/trufflesecurity/trufflehog (v3.97.4, published 2026-09-03) |
| semgrep | `semgrep ci`, `semgrep scan --config auto …` | ABSENT | http — https://semgrep.dev/docs (v1.176.0, 2026-09-01) |
| nuclei | `nuclei -u … -tags …`, `nuclei -update-templates` | ABSENT | http — https://docs.projectdiscovery.io/tools/nuclei (v3.11.1, 2026-08-08) |
| checkov | `checkov -d . --framework …`, `checkov -f …`, `checkov --docker-image …`, `--skip-check` | ABSENT | http — https://www.checkov.io (3.3.16, 2026-08-30) |
| trivy | `trivy fs .`, `trivy image …` | ABSENT | http — https://github.com/aquasecurity/trivy (v0.74.0, 2026-08-14) |
| grype | `grype alpine:latest`, `grype sbom:./sbom.json` | ABSENT | http — https://github.com/anchore/grype (v0.118.0, 2026-08-27) |
| osv-scanner | `osv-scanner scan source/image …` | ABSENT | http — https://github.com/google/osv-scanner (v2.5.1, 2026-08-17) |
| hadolint | `hadolint Dockerfile` | ABSENT | http — https://github.com/hadolint/hadolint |
| snyk | `snyk test`, `snyk container test/monitor …` | ABSENT | http — https://docs.snyk.io |
| bandit | `bandit -r ./src -ll` | ABSENT | http — https://bandit.readthedocs.io |
| bearer | `bearer scan .` | ABSENT | http — https://github.com/Bearer/bearer |
| zap | `zap-full-scan.py / zap-api-scan.py / zap-baseline.py` (via `docker run zaproxy/zap-stable`) | ABSENT (docker ABSENT) | http — https://www.zaproxy.org/docs/ |
| nikto | `nikto -h https://staging.example.com` | ABSENT | http — https://github.com/sullo/nikto |
| zizmor | `zizmor .github/workflows/` | ABSENT | http — https://docs.zizmor.sh (v1.30.0, 2026-08-30; audits `unpinned-uses`, `impostor-commit`, `template-injection`, `excessive-permissions` confirmed in usage docs) |
| actionlint | `actionlint .github/workflows/*.yml` | ABSENT | http — https://github.com/rhysd/actionlint |
| gh | `gh attestation verify … --repo <owner/repo>` | PRESENT 2.46.0 but `attestation` subcommand ABSENT (`unknown command "attestation"`) | PATH (`gh --help`) + http — https://cli.github.com/manual/gh_attestation_verify (docs-pin per handoff §10.2) |
| git | `git ls-remote`, `git rev-parse`, `git commit …` | PRESENT 2.47.3 | PATH (`git --version`) |
| docker | `docker run/build/push …` | ABSENT | http — https://docs.docker.com/reference/cli/docker/ |
| vercel | `vercel --prod`, `vercel rollback`, `vercel domains add`, `vercel login/link/env` | ABSENT | http — https://vercel.com/docs/cli (59.10.0, ~2026-09-08) |
| netlify | `netlify deploy --prod`, `netlify init/login/domains` | ABSENT | http — https://github.com/netlify/cli (latest v27.5.2, 2026-09-09, verified on releases page) |
| flyctl | `flyctl deploy`, `flyctl certs add …`, `flyctl releases` | ABSENT | http — https://fly.io/docs/flyctl (v0.4.99, 2026-09-03; `deploy`/`certs add`/`releases` confirmed) |
| vault | `vault kv get secret/myapp/db` | ABSENT | http — https://developer.hashicorp.com/vault/docs/commands |
| aws | `aws secretsmanager get-secret-value …` | ABSENT | http — https://docs.aws.amazon.com/cli/ |
| az | `az keyvault secret show …` | ABSENT | http — https://learn.microsoft.com/en-us/cli/azure/ |
| op | `op read "op://Vault/Item/password"` | ABSENT | http — https://developer.1password.com/docs/cli |
| dotenvx | `npx @dotenvx/dotenvx get` | ABSENT | http — https://dotenvx.com |
| certbot | `certbot --nginx -d …`, `certbot renew --dry-run` | ABSENT | http — https://eff-certbot.readthedocs.io |
| actions/checkout | `find-action-sha.sh actions/checkout v4.1.7` | LIVE SHA `692973e3d937129bcbf40652eb9f2f61becf3332` | PATH (script stdout, network OK) |

## Command-string patches applied this knife

1. **TruffleHog `--only-verified` → `--results=verified`** (secret-detection-rules.md, 3 trees):
   rename class. Current upstream docs (v3.92.3 → v3.97.x) only document
   `--results=verified[,unknown]`; `--only-verified` last appears in v3.67-era docs.
   All 9 occurrences (`git`/`filesystem`/`s3` examples + SE7 row + anti-pattern prose)
   updated. Subcommands (`git`, `filesystem`, `s3`) and `--fail` (exit 183) unchanged upstream.
2. **No other renames found**: `semgrep ci/scan`, `nuclei -u/-update-templates/-as`,
   `checkov -d/-f/--framework/--skip-check`, `trivy fs/image`, `grype <img>/sbom:`,
   `osv-scanner scan source|image`, `gh attestation verify --repo/--owner`,
   `fly deploy/certs/releases`, `zizmor <path>` all still documented upstream.
   `gitleaks git/dir/stdin` already correct (prior knife `58978798`).

## Explicitly NOT re-resolved (out of scope, FR4 = checkout only)

- `actions/setup-node@1e60f620` (v4.0.3) in ci-cd-pipeline-rules.md
- `aws-actions/configure-aws-credentials@e3dd6a42…`, `google-github-actions/auth@71fee32a…`
  in environment-config-rules.md
- `gitleaks` pre-commit `rev: v8.18.0` pin example in secret-detection-rules.md SE1
