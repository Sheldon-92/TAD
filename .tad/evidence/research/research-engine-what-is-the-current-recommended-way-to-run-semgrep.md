# Running Semgrep in CI (2026): `semgrep ci` vs the deprecated GitHub Action

**Question:** What is the current recommended way to run Semgrep in CI in 2026 — native `semgrep ci` run in the official container, versus the deprecated `semgrep/semgrep-action` GitHub Action?

---

## Summary

- Semgrep's official 2026 recommendation is to run the `semgrep ci` command inside the official `semgrep/semgrep` Docker container (or pip/pipx-installed), NOT the GitHub Action. The "Default" GitHub Actions sample ships `image: semgrep/semgrep` (with the inline comment "Do not change this"), `run: semgrep ci`, and `SEMGREP_APP_TOKEN` as the env var to connect to Semgrep AppSec Platform [https://docs.semgrep.dev/semgrep-ci/sample-ci-configs].
- The `semgrep/semgrep-action` GitHub Action is officially deprecated and archived (read-only); the repo was last pushed / archived on 2024-04-09 and the README banner says "This project is deprecated. It is recommended to stop using this wrapper script and migrate to native Semgrep support instead." [https://github.com/semgrep/semgrep-action].
- `semgrep ci` is preferred over a bare `semgrep scan` because it adds diff-aware PR/MR scanning, CI-tuned exit/blocking semantics, platform integration via `SEMGREP_APP_TOKEN`, and CI-appropriate resource defaults — none of which `semgrep scan` provides natively [https://docs.semgrep.dev/semgrep-ci/ci-environment-variables] [https://docs.semgrep.dev/semgrep-ci/configuring-blocking-and-errors-in-ci].
- The recommendation is cross-platform, not GitHub-specific: GitLab CI, CircleCI, Jenkins, Bitbucket, and Azure Pipelines all use `semgrep ci` in their official "Default" tabs (with provider-specific deviations in how Semgrep is installed) [https://docs.semgrep.dev/semgrep-ci/sample-ci-configs].
- A zero-token / OSS-only path exists: `semgrep scan --config auto` (Community Edition, "preferred CE command") or `semgrep ci` with `SEMGREP_RULES` set instead of a token; both run without a Semgrep account but lose PR comments, dedup, SCA, and Secrets [https://docs.semgrep.dev/deployment/oss-deployment] [https://docs.semgrep.dev/semgrep-ci/configuration-reference/].
- Credible dissent exists: the OpenGrep fork (Jan 2025, 10+ AppSec vendors), a token-leak-to-arbitrary-domains issue, and Trail of Bits' telemetry warning argue for avoiding platform coupling and/or disabling metrics [https://appsecsanta.com/sast-tools/opengrep-vs-semgrep] [https://github.com/semgrep/semgrep/issues/11016] [https://blog.trailofbits.com/2024/01/12/how-to-introduce-semgrep-to-your-organization/].

---

## Findings by sub-question

### 1. What does Semgrep's official documentation recommend as the canonical CI invocation?

Semgrep's official sample CI configuration page documents `semgrep ci` as the canonical CI entrypoint. The "Default" GitHub Actions YAML uses container image `semgrep/semgrep` (with the inline comment "Do not change this") and the run command `semgrep ci`, with `SEMGREP_APP_TOKEN` as the environment variable used to connect to Semgrep AppSec Platform [https://docs.semgrep.dev/semgrep-ci/sample-ci-configs]. *(Adversarially confirmed.)*

The verbatim "Default" GitHub Actions YAML structure is:
- `name: Semgrep`
- Triggers: `pull_request`, `workflow_dispatch`, `push` to `main`/`master` (only when `semgrep.yml` changes), and a `cron` schedule
- `jobs.semgrep` runs in `container: image: semgrep/semgrep`
- Steps: `actions/checkout@v6`, then `run: semgrep ci`
- `env: SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}`

[https://docs.semgrep.dev/semgrep-ci/sample-ci-configs] *(Adversarially confirmed.)*

A reproduced minimal form of the recommended workflow:

```yaml
name: Semgrep
on:
  pull_request: {}
  workflow_dispatch: {}
  push:
    branches: [main, master]
    paths: [.github/workflows/semgrep.yml]
  schedule:
    - cron: '...'   # periodic full scan
jobs:
  semgrep:
    name: semgrep/ci
    runs-on: ubuntu-latest
    container:
      image: semgrep/semgrep   # Do not change this
    if: (github.actor != 'dependabot[bot]')
    steps:
      - uses: actions/checkout@v6
      - run: semgrep ci
        env:
          SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}
```

(Structure per [https://docs.semgrep.dev/semgrep-ci/sample-ci-configs].)

### 2. Is `semgrep/semgrep-action` actually deprecated/archived?

The `semgrep/semgrep-action` GitHub repository is officially deprecated and was archived on 2024-04-09; it is now read-only. The README deprecation banner reads: "This project is deprecated. It is recommended to stop using this wrapper script and migrate to native Semgrep support instead." [https://github.com/semgrep/semgrep-action]. *(Adversarially confirmed; minor URL caveats below.)*

The `returntocorp/semgrep-action` repository (the original org namespace before the rebrand) also shows a deprecation message: "This project is deprecated. Use https://github.com/semgrep/semgrep instead." This confirms the deprecation is bilateral across both org namespaces [https://github.com/returntocorp/semgrep-action]. *(Adversarially confirmed.)*

The old Action's `action.yml` uses Docker image `docker://returntocorp/semgrep-agent:v1` (the old agent image, not `semgrep/semgrep`), accepts `config` and `publishToken` inputs, and runs via the container entrypoint rather than calling `semgrep ci` directly — the concrete technical delta between the old Action and the current approach [https://github.com/semgrep/semgrep-action/blob/develop/action.yml]. *(Adversarially confirmed.)*

Official-wording caveat (distinguishing deprecation wording from community inference): the deprecation banner does NOT itself say "use `semgrep ci` in a container job instead." It says "migrate to native Semgrep support" and links to the docs; the phrase `semgrep ci` appears only in the linked documentation, not in the banner [https://github.com/semgrep/semgrep-action]. *(Adversarially confirmed.)* Adversarial verification also noted two minor URL inaccuracies in the banner links (the archived repo links to `semgrep/semgrep` after the org rename, and the CI docs link points to the more specific `sample-ci-configs` anchor), neither of which materially changes the deprecation finding [https://github.com/semgrep/semgrep-action].

### 3. Behavioral delta: `semgrep ci` vs `semgrep scan`

**Diff-aware scanning.** `semgrep ci` auto-detects PR context on GitHub Actions (`pull_request` trigger) and GitLab CI (`$CI_MERGE_REQUEST_IID`). On all other platforms (Jenkins, CircleCI, Bitbucket, Azure, Buildkite) you must set `SEMGREP_BASELINE_REF` (branch) or `SEMGREP_BASELINE_COMMIT` (commit hash) to enable diff-aware scanning. `semgrep scan` has no native diff-aware mode [https://docs.semgrep.dev/semgrep-ci/ci-environment-variables].

**Rule sourcing.** `semgrep ci` does NOT support the `--config` flag ("--config is Not supported in ci mode"). Rules come from `SEMGREP_APP_TOKEN` (platform policies) or the `SEMGREP_RULES` env var (local paths or registry IDs), which are mutually exclusive. `semgrep scan` uses `--config` for rule selection [https://docs.semgrep.dev/cli-reference].

**Exit codes / blocking.** `semgrep ci` exits 1 on any blocking finding (without a token, all findings block; with a token, only policy rules in "Block" mode trigger exit 1). `semgrep scan` exits 0 regardless of findings unless `--error` is explicitly passed — the key CI gating difference [https://docs.semgrep.dev/semgrep-ci/configuring-blocking-and-errors-in-ci].

**Platform integration.** `SEMGREP_APP_TOKEN` with `semgrep ci` enables PR/MR comments, finding lifecycle tracking, Supply Chain (SCA), Secrets scanning, Pro rules (20,000+), cross-file/cross-function taint analysis, and the AppSec Platform dashboard — none available with tokenless `semgrep scan` [https://docs.semgrep.dev/semgrep-pro-vs-oss].

**Resource defaults.** `semgrep ci` defaults to a 3-hour interfile-analysis timeout and a 5000 MiB Pro Engine memory limit; `semgrep scan` defaults to 0 (unlimited) for both. These are applied per-subcommand, not via flags [https://docs.semgrep.dev/cli-reference].

**SARIF output.** Both subcommands support `--sarif`. `semgrep ci --sarif` can be combined with `SEMGREP_APP_TOKEN` for simultaneous platform integration plus GHAS upload via `github/codeql-action/upload-sarif@v2` (requires `security-events: write`). Whether `semgrep ci --sarif` produces a GHAS-uploadable SARIF in fully tokenless mode is not explicitly documented as a distinct flow [https://docs.semgrep.dev/kb/semgrep-ci/github-upload-findings-in-security-dashboard].

### 4. Non-GitHub CI platforms and offline/air-gapped operation

**Cross-platform consistency.** `semgrep ci` is used in the "Default" tabs across GitLab CI, CircleCI, Jenkins, Bitbucket Pipelines, Azure Pipelines, and Buildkite [https://docs.semgrep.dev/semgrep-ci/sample-ci-configs]. *(Adversarial caveat: the `image: semgrep/semgrep` Docker pattern is NOT universal — Azure Pipelines installs Semgrep via `pipx install semgrep` with no container image, and Jenkins uses `docker run` with the image rather than a `container:` directive. The CE variants are also not uniform: GitLab's CE command is `semgrep scan --config auto .` with a trailing dot, while other providers omit it, and the Jenkins/Azure CE paths use `pipx install semgrep` instead of the Docker image.)* [https://docs.semgrep.dev/semgrep-ci/sample-ci-configs]

- **GitLab CI:** `semgrep ci` with `SEMGREP_APP_TOKEN` as a CI/CD variable; diff scan auto-detected via `$CI_MERGE_REQUEST_IID`, full scan when `$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH`. CE alternative: `semgrep scan --config auto .` with no token [https://docs.semgrep.dev/semgrep-ci/sample-ci-configs/].
- **CircleCI:** two-job pattern — `semgrep-full-scan` (main only) and `semgrep-diff-scan` (other branches, sets `SEMGREP_BASELINE_REF`). Both use the `semgrep/semgrep` image and run `semgrep ci`; token stored in a CircleCI context named `semgrep` [https://docs.semgrep.dev/semgrep-ci/sample-ci-configs/].
- **Jenkins:** `docker pull semgrep/semgrep && docker run -e SEMGREP_APP_TOKEN=... semgrep/semgrep semgrep ci`; token via `credentials()`. Diff-aware is opt-in by uncommenting `SEMGREP_BASELINE_REF = 'main'`; a KB note recommends setting it to the computed merge base rather than a static branch name [https://docs.semgrep.dev/semgrep-ci/sample-ci-configs/].
- **Bitbucket Pipelines:** `branches.main` full scan (`semgrep ci`) and `pull-requests.'**'` diff scan (sets `SEMGREP_BASELINE_REF=origin/main`, runs `git fetch` first). Memory note: use `size: 2x` or `-j` to limit subprocesses [https://docs.semgrep.dev/semgrep-ci/sample-ci-configs/].
- **Azure Pipelines:** inline conditional — full `semgrep ci` on master; on PRs set `SEMGREP_PR_ID`, `SEMGREP_BASELINE_REF=origin/master`, `git fetch`, then `semgrep ci`. Token in a variable group; Azure is the only platform explicitly requiring `SEMGREP_PR_ID` for diff scanning [https://docs.semgrep.dev/semgrep-ci/sample-ci-configs/].
- **Unsupported platforms (Bamboo, TeamCity, Travis, etc.):** use the `semgrep/semgrep` Docker image (preferred) or `pipx install semgrep` / `uv tool install semgrep`, then run `semgrep ci` with metadata env vars (`SEMGREP_REPO_NAME`, `SEMGREP_REPO_URL`, `SEMGREP_BRANCH`, `SEMGREP_COMMIT`, `SEMGREP_PR_ID`) for dashboard hyperlinks [https://docs.semgrep.dev/deployment/add-semgrep-to-other-ci-providers].

**Phone-home / offline behavior.** Source code never leaves the CI build environment with `semgrep ci`; only scan metadata and finding hashes are transmitted (exceptions: Managed Scans and Multimodal features require explicit code-access grants). Metrics are controllable via `SEMGREP_SEND_METRICS`, and enterprise single-tenant can point `SEMGREP_APP_URL` at a custom URL [https://docs.semgrep.dev/faq/overview]. Even tokenless, `semgrep ci` still makes network calls when rules reference registry IDs (e.g., `p/ci`), which are fetched at runtime; registry rulesets are NOT cached locally (issue #3147 requesting caching remains open). To run fully offline, pre-download rule YAML and reference local paths only (e.g., `semgrep scan --config /path/to/rules.yaml --metrics=off`), and suppress version checks with `SEMGREP_ENABLE_VERSION_CHECK=0` [https://github.com/semgrep/semgrep/issues/3147].

### 5. OSS-vs-paid boundary in the recommended CI path

The split: `semgrep ci` is the platform-connected command requiring `SEMGREP_APP_TOKEN` (or `SEMGREP_RULES` for a tokenless-but-still-`ci`-mode path); `semgrep scan` is the Community Edition (zero-token) command. The official CE deployment docs state "The preferred Semgrep CE command is `semgrep scan`" [https://docs.semgrep.dev/deployment/oss-deployment].

`SEMGREP_RULES` is a supported zero-token path for `semgrep ci`, explicitly mutually exclusive with `SEMGREP_APP_TOKEN`: "Set SEMGREP_RULES to define rules and rulesets for your scan. Findings are logged within your CI environment." So `semgrep ci` CAN run without an account when `SEMGREP_RULES` is set (e.g., `p/default`); in this mode PR comments, finding tracking, SCA, and Secrets are unavailable [https://docs.semgrep.dev/semgrep-ci/configuration-reference/].

What works with zero token (CE / no account): full scanning with 3,000+ community rules via `semgrep scan --config auto` or `--config p/<ruleset>`, JSON and SARIF output, custom rules, 30+ languages, integration into any CI, and `SEMGREP_RULES` with `semgrep ci` (findings logged locally). No dashboard, no cloud upload, no PR comments, no dedup fingerprinting, no SCA/Secrets [https://docs.semgrep.dev/deployment/oss-deployment].

Pro rules (20,000+) require a logged-in account (`SEMGREP_APP_TOKEN`); community rules (~3,000, LGPL-2.1 / Semgrep Rules License) need no token [https://docs.semgrep.dev/semgrep-code/pro-rules]. Findings deduplication (fingerprinting) was explicitly moved from CE to paid Pro Engine in the December 2024 OSS update — Semgrep's statement: "the fingerprinting field — unnecessary for an engine but useful for competitor triage platforms — was among these [moved features]." Zero-token runs do not produce cross-run dedup fingerprints [https://semgrep.dev/blog/2024/important-updates-to-semgrep-oss/]. There is a freemium tier: Semgrep Code and Supply Chain are free for teams up to 10 contributors, unlocking some Platform features but still requiring signup and a token [https://docs.semgrep.dev/semgrep-pro-vs-oss].

`SEMGREP_BASELINE_REF` / `SEMGREP_BASELINE_COMMIT` are token-independent and enable diff-aware scanning with both `semgrep ci` (using `SEMGREP_RULES`) and `semgrep scan`; the CE deployment docs show diff-aware commented out, indicating it is not treated as a first-class CE feature [https://docs.semgrep.dev/semgrep-ci/configuration-reference/].

**Recent CE improvements (2025):** the Fall 2025 CE release added multicore support (up to 3x faster) and native Windows support — engine-level gains for zero-token `semgrep scan`, with no change to token requirements or CI command structure [https://semgrep.dev/blog/2025/semgrep-community-edition-fall-release-2025/].

### Dissent angle (case for keeping the old Action / avoiding `semgrep ci`)

- **OpenGrep fork (Jan 2025):** a coalition of 10+ AppSec vendors (Aikido, Endor Labs, Jit, Orca Security, et al.) forked Semgrep CE specifically because Semgrep Inc. moved cross-function taint analysis, fingerprinting, ignore-tracking, and Visual Basic support behind the commercial Platform. OpenGrep restores these under LGPL-2.1, is compatible with community rules and JSON/SARIF, and is the primary OSS dissent channel for teams avoiding platform coupling [https://appsecsanta.com/sast-tools/opengrep-vs-semgrep].
- **Token-exposure risk:** issue #11016 reports that when `SEMGREP_APP_TOKEN` is set and `semgrep ci` downloads rules from a remote URL, the token is sent in the `Authorization` header to ANY domain, not just `semgrep.dev` — a real concern for teams using custom remote rule sources (filed as a medium-priority enhancement, not a critical vuln) [https://github.com/semgrep/semgrep/issues/11016].
- **Telemetry warning (Trail of Bits, Jan 2024):** Trail of Bits warns that `--config auto` submits metrics to Semgrep and recommends disabling metrics by default via env vars/aliases, even for zero-token CE scanning [https://blog.trailofbits.com/2024/01/12/how-to-introduce-semgrep-to-your-organization/].
- **Third-party guides lag the official image name:** the AppSec Testing Handbook recommends `semgrep ci` but uses the outdated `returntocorp/semgrep` Docker image (not `semgrep/semgrep`) and a tokenless two-job `SEMGREP_RULES` setup — illustrating that current ecosystem guidance has not all caught up to the org rebrand [https://appsec.guide/docs/static-analysis/semgrep/continuous-integration/].

---

## Contradictions / open debates

- **Image name drift:** Official docs mandate `image: semgrep/semgrep` ("Do not change this"), but the AppSec Testing Handbook still uses the older `returntocorp/semgrep` — the handbook lags the org rebrand [https://docs.semgrep.dev/semgrep-ci/sample-ci-configs] [https://appsec.guide/docs/static-analysis/semgrep/continuous-integration/].
- **Cross-referenced deprecation URLs:** the `semgrep/` banner points to `returntocorp/semgrep` while the `returntocorp/` banner points to `semgrep/semgrep` — opposite directions, both resolving to the same repo. Cosmetic but potentially confusing during migration [https://github.com/semgrep/semgrep-action] [https://github.com/returntocorp/semgrep-action].
- **"Preferred" zero-token path:** oss-deployment says "preferred CE command is `semgrep scan`," yet `semgrep ci` + `SEMGREP_RULES` is also a documented tokenless path. Both are correct; the ambiguity is purely in the word "preferred" [https://docs.semgrep.dev/deployment/oss-deployment] [https://docs.semgrep.dev/semgrep-ci/configuration-reference/].
- **Token "required" vs "optional":** a Jenkins KB calls `SEMGREP_APP_TOKEN` "required" for a Cloud-connected scan, while the env-var reference lists it as optional. Resolution: required only for platform connectivity; diff scanning works tokenlessly via `SEMGREP_BASELINE_REF` + `SEMGREP_RULES` [https://docs.semgrep.dev/semgrep-ci/ci-environment-variables].
- **`--config` "not supported in ci mode":** initially implies `semgrep ci` cannot run tokenless, but the constraint is on the `--config` flag, not the `SEMGREP_RULES` env var, which IS supported [https://docs.semgrep.dev/cli-reference] [https://docs.semgrep.dev/semgrep-ci/configuration-reference/].
- **Tokenless SARIF + GHAS:** docs show `semgrep ci --sarif` with a token, but do not clearly distinguish the tokenless `--sarif` + `SEMGREP_RULES` flow producing a GHAS-uploadable SARIF [https://docs.semgrep.dev/kb/semgrep-ci/github-upload-findings-in-security-dashboard].
- **Baseline ref vs commit:** `SEMGREP_BASELINE_REF` is documented as "superseded by `SEMGREP_BASELINE_COMMIT`" yet both remain listed as supported — unclear whether REF is maintained or kept for backward compatibility [https://docs.semgrep.dev/semgrep-ci/configuration-reference/].

---

## Open questions / saturation reason

Research stopped after **1 round** with `saturation_reason = max_rounds` (the configured round cap was reached, not because findings were exhausted — only 1 dry round was observed, dry_counter=0). Remaining open questions:

1. Does `semgrep ci --sarif` in fully tokenless mode (`SEMGREP_RULES` only) produce a GHAS-uploadable SARIF, or does GHAS upload require a token? Docs show the two together but do not isolate the tokenless flow.
2. Is `SEMGREP_BASELINE_REF` still actively maintained, or kept only for backward compatibility now that `SEMGREP_BASELINE_COMMIT` "supersedes" it?
3. Exact current contents of the deprecation banner's links after the org rename (the archived repo's link target may differ from what the finding recorded).
4. Whether the OpenGrep fork's feature parity claims (cross-function taint, fingerprinting) hold in practice as of mid-2026 — sourced from a comparison site, not primary OpenGrep release notes.
5. The precise default `cron` value and any `if:` guards in the official GitHub Actions sample were not captured verbatim.

---

## Confidence note

**Overall confidence: HIGH.** The core recommendation (`semgrep ci` in the `semgrep/semgrep` container; `semgrep/semgrep-action` deprecated/archived 2024-04-09) is grounded in primary Semgrep documentation and the GitHub repo state, and the load-bearing claims were adversarially re-verified and **confirmed**.

Two claims were **refuted** by adversarial verification and have been corrected/caveated in this report:
1. The claim that "both [Default and CE] variants use the `semgrep/semgrep` Docker image" is false — Jenkins and Azure CE paths use `pipx install semgrep` (no Docker image), and the trailing-dot `semgrep scan --config auto .` appears only on some providers (e.g., GitLab).
2. The claim that the `image: semgrep/semgrep` pattern is universal across ALL providers is false — Azure uses `pipx`, Jenkins uses `docker run`. The `semgrep ci` command and `SEMGREP_APP_TOKEN` env var ARE consistent; the install mechanism varies.

The dissent claims (OpenGrep, token leak, telemetry, handbook drift) are **medium** confidence — sourced from a comparison site, GitHub issues, and third-party blogs rather than Semgrep primary docs. What would raise confidence: directly fetching the live `sample-ci-configs` page to capture the exact `cron`/`if:` lines verbatim, confirming the current deprecation-banner link targets, and citing primary OpenGrep release notes for its parity claims.

---

## Sources

1. https://docs.semgrep.dev/semgrep-ci/sample-ci-configs
2. https://docs.semgrep.dev/semgrep-ci/sample-ci-configs/
3. https://github.com/semgrep/semgrep-action
4. https://github.com/returntocorp/semgrep-action
5. https://github.com/semgrep/semgrep-action/blob/develop/action.yml
6. https://docs.semgrep.dev/semgrep-ci/ci-environment-variables
7. https://docs.semgrep.dev/cli-reference
8. https://docs.semgrep.dev/semgrep-ci/configuring-blocking-and-errors-in-ci
9. https://docs.semgrep.dev/semgrep-pro-vs-oss
10. https://docs.semgrep.dev/kb/semgrep-ci/github-upload-findings-in-security-dashboard
11. https://docs.semgrep.dev/deployment/add-semgrep-to-other-ci-providers
12. https://docs.semgrep.dev/faq/overview
13. https://github.com/semgrep/semgrep/issues/3147
14. https://docs.semgrep.dev/deployment/oss-deployment
15. https://docs.semgrep.dev/semgrep-ci/configuration-reference/
16. https://docs.semgrep.dev/semgrep-code/pro-rules
17. https://semgrep.dev/blog/2024/important-updates-to-semgrep-oss/
18. https://appsecsanta.com/sast-tools/opengrep-vs-semgrep
19. https://github.com/semgrep/semgrep/issues/11016
20. https://blog.trailofbits.com/2024/01/12/how-to-introduce-semgrep-to-your-organization/
21. https://appsec.guide/docs/static-analysis/semgrep/continuous-integration/
22. https://semgrep.dev/blog/2025/semgrep-community-edition-fall-release-2025/
