# Round 1 — what-is-the-current-recommended-way-to-run-semgrep

- Questions researched: 5
- New findings: 34 (cumulative 34)
- Dry counter: 0/1

## New findings
[
  {
    "claim": "Semgrep's official sample CI configuration page (docs.semgrep.dev/semgrep-ci/sample-ci-configs) documents 'semgrep ci' as the canonical CI entrypoint. The exact 'Default' GitHub Actions YAML uses container image 'semgrep/semgrep' (with inline comment 'Do not change this') and the run command 'semgrep ci', with SEMGREP_APP_TOKEN as the required environment variable to connect to Semgrep AppSec Platform.",
    "source_url": "https://docs.semgrep.dev/semgrep-ci/sample-ci-configs",
    "source_title": "Sample CI configurations - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "What does Semgrep's official documentation currently recommend as the canonical CI invocation?",
    "confidence": "high"
  },
  {
    "claim": "The verbatim 'Default' GitHub Actions YAML from docs.semgrep.dev/semgrep-ci/sample-ci-configs: name: Semgrep; triggers: pull_request, workflow_dispatch, push to main/master (only when semgrep.yml changes), and cron schedule; jobs.semgrep container image is 'semgrep/semgrep'; steps are 'actions/checkout@v6' then 'run: semgrep ci' with 'env: SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}'.",
    "source_url": "https://docs.semgrep.dev/semgrep-ci/sample-ci-configs",
    "source_title": "Sample CI configurations - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "What exact GitHub Actions YAML does Semgrep ship in their sample CI config?",
    "confidence": "high"
  },
  {
    "claim": "The 'Semgrep CE' tab on the same sample-ci-configs page shows an alternative variant that uses 'semgrep scan --config auto .' instead of 'semgrep ci', for teams that want OSS-only scanning without a cloud token. Both variants use the 'semgrep/semgrep' Docker image.",
    "source_url": "https://docs.semgrep.dev/semgrep-ci/sample-ci-configs",
    "source_title": "Sample CI configurations - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "What is the officially documented zero-token / CE GitHub Actions path?",
    "confidence": "high"
  },
  {
    "claim": "The same pattern (image: semgrep/semgrep, script: semgrep ci, env SEMGREP_APP_TOKEN) is used across ALL CI providers in Semgrep's official docs — GitLab CI, CircleCI, Bitbucket Pipelines, Jenkins, Azure Pipelines, and Buildkite all use 'semgrep ci' in their 'Default' tabs. The CE variants for all providers use 'semgrep scan --config auto' instead.",
    "source_url": "https://docs.semgrep.dev/semgrep-ci/sample-ci-configs",
    "source_title": "Sample CI configurations - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Is 'semgrep ci' genuinely the universal cross-platform recommendation or GitHub-specific?",
    "confidence": "high"
  },
  {
    "claim": "The semgrep/semgrep-action GitHub repository is officially deprecated and was archived by the owner on April 9, 2024. It is now read-only. The README contains a deprecation banner: 'This project is deprecated. It is recommended to stop using this wrapper script and migrate to native Semgrep support instead.' It directs users to https://github.com/returntocorp/semgrep and https://semgrep.dev/docs/semgrep-ci/ for native CI setup.",
    "source_url": "https://github.com/semgrep/semgrep-action",
    "source_title": "GitHub - semgrep/semgrep-action (archived)",
    "retrieved_at": "2026-06-13",
    "sub_question": "Is the semgrep/semgrep-action GitHub Action actually deprecated/archived?",
    "confidence": "high"
  },
  {
    "claim": "The returntocorp/semgrep-action repository (original org name before rebrand) also shows a deprecation message: 'This project is deprecated. Use https://github.com/semgrep/semgrep instead.' This confirms the deprecation is bilateral across both org namespaces. Note: the two banners cross-reference opposite org URLs — semgrep/ repo points to returntocorp/semgrep, and returntocorp/ repo points to semgrep/semgrep — a cosmetic inconsistency but both land at the same repo.",
    "source_url": "https://github.com/returntocorp/semgrep-action",
    "source_title": "GitHub - returntocorp/semgrep-action (deprecated)",
    "retrieved_at": "2026-06-13",
    "sub_question": "Is the deprecation confirmed in both org namespaces?",
    "confidence": "high"
  },
  {
    "claim": "The semgrep-action's action.yml uses Docker image 'docker://returntocorp/semgrep-agent:v1' (the old agent image, not 'semgrep/semgrep'). It accepts 'config' and 'publishToken' inputs and does not call 'semgrep ci' directly but runs via the container entrypoint. This is the concrete technical delta between the old Action and the current recommended approach.",
    "source_url": "https://github.com/semgrep/semgrep-action/blob/develop/action.yml",
    "source_title": "semgrep-action/action.yml at develop",
    "retrieved_at": "2026-06-13",
    "sub_question": "What was the old Action actually doing vs. the current semgrep ci approach?",
    "confidence": "high"
  },
  {
    "claim": "The deprecation migration note for semgrep-action does NOT explicitly say 'use semgrep ci in a container job instead' — it says 'migrate to native Semgrep support' and links to the docs. The phrase 'semgrep ci' is not used in the deprecation banner itself, though the linked documentation (semgrep-ci/ section) shows semgrep ci as the recommended command.",
    "source_url": "https://github.com/semgrep/semgrep-action",
    "source_title": "GitHub - semgrep/semgrep-action (archived)",
    "retrieved_at": "2026-06-13",
    "sub_question": "Does the deprecation banner explicitly name semgrep ci as the replacement?",
    "confidence": "high"
  },
  {
    "claim": "Behavioral delta — diff-aware scanning: semgrep ci auto-detects PR context on GitHub Actions (pull_request trigger) and GitLab CI ($CI_MERGE_REQUEST_IID). For all other platforms (Jenkins, CircleCI, Bitbucket, Azure, Buildkite), you must set SEMGREP_BASELINE_REF (branch name) or SEMGREP_BASELINE_COMMIT (commit hash) to enable diff-aware scanning. semgrep scan has no native diff-aware mode; baseline comparison is not a documented feature.",
    "source_url": "https://docs.semgrep.dev/semgrep-ci/ci-environment-variables",
    "source_title": "CI environment variables - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Functional/behavioral difference between semgrep ci and semgrep scan — diff-aware scanning",
    "confidence": "high"
  },
  {
    "claim": "Behavioral delta — rule sourcing: semgrep ci does NOT support the --config flag (CLI explicitly states '--config is Not supported in ci mode'). Rules come from SEMGREP_APP_TOKEN (platform policies) or SEMGREP_RULES env var (local paths or registry IDs). semgrep scan uses --config flag for rule selection. These two env vars are mutually exclusive in semgrep ci.",
    "source_url": "https://docs.semgrep.dev/cli-reference",
    "source_title": "CLI reference - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Functional/behavioral difference between semgrep ci and semgrep scan — rule sourcing",
    "confidence": "high"
  },
  {
    "claim": "Behavioral delta — exit codes: semgrep ci exits 1 on any blocking finding (by default, all findings are blocking without a token; with token, only 'Block'-mode policy rules trigger exit 1). semgrep scan exits 0 regardless of findings unless --error flag is explicitly passed. This is the key CI gating difference.",
    "source_url": "https://docs.semgrep.dev/semgrep-ci/configuring-blocking-and-errors-in-ci",
    "source_title": "Handling blocking findings and errors - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Functional/behavioral difference between semgrep ci and semgrep scan — exit codes and blocking",
    "confidence": "high"
  },
  {
    "claim": "Behavioral delta — platform integration: SEMGREP_APP_TOKEN with semgrep ci enables PR/MR comments, finding lifecycle tracking, SCA (Supply Chain), Secrets scanning, Pro rules (20,000+), cross-file/cross-function taint analysis, and the Semgrep AppSec Platform dashboard. None of these are available with semgrep scan (zero-token CE mode).",
    "source_url": "https://docs.semgrep.dev/semgrep-pro-vs-oss",
    "source_title": "Semgrep AppSec Platform versus Semgrep Community Edition - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "What platform features require SEMGREP_APP_TOKEN?",
    "confidence": "high"
  },
  {
    "claim": "Behavioral delta — timeout/resource defaults differ: semgrep ci defaults to a 3-hour interfile analysis timeout and 5000 MiB Pro Engine memory limit for CI scans. semgrep scan defaults to 0 (unlimited) for both. These are auto-applied based on subcommand, not flags.",
    "source_url": "https://docs.semgrep.dev/cli-reference",
    "source_title": "CLI reference - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Functional/behavioral difference between semgrep ci and semgrep scan — resource defaults",
    "confidence": "high"
  },
  {
    "claim": "SARIF output: both semgrep ci and semgrep scan support --sarif flag. semgrep ci --sarif can be combined with SEMGREP_APP_TOKEN for simultaneous platform integration + GHAS upload via github/codeql-action/upload-sarif@v2 (requires security-events: write permission). Whether semgrep ci --sarif works in fully tokenless mode (SEMGREP_RULES only) and produces a GHAS-uploadable SARIF is not explicitly documented as a distinct flow — docs show the two vars together.",
    "source_url": "https://docs.semgrep.dev/kb/semgrep-ci/github-upload-findings-in-security-dashboard",
    "source_title": "Why aren't findings populating in the GitHub Advanced Security Dashboard? - Semgrep KB",
    "retrieved_at": "2026-06-13",
    "sub_question": "SARIF output and GHAS upload path",
    "confidence": "high"
  },
  {
    "claim": "Non-GitHub CI — GitLab CI: official config uses 'semgrep ci' with SEMGREP_APP_TOKEN as a GitLab CI/CD variable. Triggered by $CI_MERGE_REQUEST_IID (diff scan, auto-detected) and $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH (full scan). CE/OSS alternative: 'semgrep scan --config auto .' with no token required.",
    "source_url": "https://docs.semgrep.dev/semgrep-ci/sample-ci-configs/",
    "source_title": "Sample CI configurations - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Non-GitHub CI platforms — GitLab CI setup",
    "confidence": "high"
  },
  {
    "claim": "Non-GitHub CI — CircleCI: two-job pattern: semgrep-full-scan (main branch only) and semgrep-diff-scan (all other branches, sets SEMGREP_BASELINE_REF: << parameters.default_branch >> defaulting to 'main'). Both use semgrep/semgrep Docker image and run 'semgrep ci'. SEMGREP_APP_TOKEN stored in a CircleCI context named 'semgrep'. CE alternative: semgrep scan --config auto without token.",
    "source_url": "https://docs.semgrep.dev/semgrep-ci/sample-ci-configs/",
    "source_title": "Sample CI configurations - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Non-GitHub CI platforms — CircleCI setup",
    "confidence": "high"
  },
  {
    "claim": "Non-GitHub CI — Jenkins: uses Docker directly ('docker pull semgrep/semgrep && docker run -e SEMGREP_APP_TOKEN=$SEMGREP_APP_TOKEN ... semgrep/semgrep semgrep ci'). Token stored via Jenkins credentials() function. Diff-aware scanning is opt-in: uncomment SEMGREP_BASELINE_REF = 'main'. A separate KB article notes SEMGREP_BASELINE_REF should be set to the computed merge base (not a static branch name) to avoid spurious results.",
    "source_url": "https://docs.semgrep.dev/semgrep-ci/sample-ci-configs/",
    "source_title": "Sample CI configurations - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Non-GitHub CI platforms — Jenkins setup",
    "confidence": "high"
  },
  {
    "claim": "Non-GitHub CI — Bitbucket Pipelines: two-section pattern: branches.main (full scan, 'semgrep ci') and pull-requests.'**' (diff scan: sets SEMGREP_BASELINE_REF=origin/main and runs 'git fetch origin +refs/heads/*:refs/remotes/origin/*' before 'semgrep ci'). Memory constraints noted — use 'size: 2x' or '-j' flag to limit subprocesses.",
    "source_url": "https://docs.semgrep.dev/semgrep-ci/sample-ci-configs/",
    "source_title": "Sample CI configurations - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Non-GitHub CI platforms — Bitbucket Pipelines setup",
    "confidence": "high"
  },
  {
    "claim": "Non-GitHub CI — Azure Pipelines: inline conditional logic — if branch is master run 'semgrep ci' (full scan); if pull request detected set SEMGREP_PR_ID=$(System.PullRequest.PullRequestId), SEMGREP_BASELINE_REF=origin/master, run 'git fetch origin master:origin/master', then 'semgrep ci'. SEMGREP_APP_TOKEN stored in a variable group. Azure is the only platform where SEMGREP_PR_ID is explicitly required for diff scanning.",
    "source_url": "https://docs.semgrep.dev/semgrep-ci/sample-ci-configs/",
    "source_title": "Sample CI configurations - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Non-GitHub CI platforms — Azure Pipelines setup",
    "confidence": "high"
  },
  {
    "claim": "For unsupported CI platforms (Bamboo, TeamCity, Travis, etc.): use semgrep/semgrep Docker image (preferred) or install via 'pipx install semgrep' / 'uv tool install semgrep', then run 'semgrep ci' with appropriate env vars. Metadata vars (SEMGREP_REPO_NAME, SEMGREP_REPO_URL, SEMGREP_BRANCH, SEMGREP_COMMIT, SEMGREP_PR_ID) populate platform dashboard hyperlinks.",
    "source_url": "https://docs.semgrep.dev/deployment/add-semgrep-to-other-ci-providers",
    "source_title": "Add Semgrep manually to CI providers - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Non-GitHub CI platforms — generic setup",
    "confidence": "high"
  },
  {
    "claim": "Phone-home behavior: source code never leaves the CI build environment when running semgrep ci. Only scan metadata (project name, CI environment) and findings hashes are transmitted to Semgrep servers. The only exceptions are Managed Scans and Semgrep Multimodal features (require explicit code access grants). Metrics can be controlled with SEMGREP_SEND_METRICS. For single-tenant enterprise, SEMGREP_APP_URL can point to a custom URL.",
    "source_url": "https://docs.semgrep.dev/faq/overview",
    "source_title": "Frequently asked questions - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Does semgrep ci phone home or require a token to run?",
    "confidence": "high"
  },
  {
    "claim": "Offline / air-gapped operation: semgrep ci without SEMGREP_APP_TOKEN still makes network calls when rules reference registry IDs (like p/ci) — those are fetched from semgrep.dev at runtime. Registry rulesets are NOT cached locally (GitHub issue #3147 requesting caching remains open with medium priority). To run fully offline, pre-download rule YAML files and reference them via local paths only (e.g., 'semgrep scan --config /path/to/rules.yaml --metrics=off'). Version check calls can be suppressed with SEMGREP_ENABLE_VERSION_CHECK=0.",
    "source_url": "https://github.com/semgrep/semgrep/issues/3147",
    "source_title": "Cache rulesets for offline use - semgrep/semgrep issue #3147",
    "retrieved_at": "2026-06-13",
    "sub_question": "Running offline / air-gapped — does semgrep ci still phone home?",
    "confidence": "high"
  },
  {
    "claim": "OSS-vs-paid boundary summary: semgrep ci is the platform-connected command requiring SEMGREP_APP_TOKEN (or SEMGREP_RULES for a tokenless-but-still-ci-mode path); semgrep scan is the Community Edition (zero-token) command. The official CE deployment docs state: 'The preferred Semgrep CE command is semgrep scan.' Semgrep consistently shows this split across all six documented CI providers.",
    "source_url": "https://docs.semgrep.dev/deployment/oss-deployment",
    "source_title": "Semgrep Community Edition in CI - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "OSS-vs-paid boundary in the recommended CI path",
    "confidence": "high"
  },
  {
    "claim": "SEMGREP_RULES env var is a supported zero-token path for semgrep ci: it is explicitly mutually exclusive with SEMGREP_APP_TOKEN and documented as 'Set SEMGREP_RULES to define rules and rulesets for your scan. Findings are logged within your CI environment.' This means semgrep ci CAN run without a Semgrep account when SEMGREP_RULES is set (e.g., SEMGREP_RULES='p/default'). In this mode, PR comments, finding tracking, SCA, and Secrets are unavailable.",
    "source_url": "https://docs.semgrep.dev/semgrep-ci/configuration-reference/",
    "source_title": "CI configuration reference - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "What works with zero token?",
    "confidence": "high"
  },
  {
    "claim": "What works with zero token (Community Edition / no account): full codebase scanning with 3,000+ community rules via 'semgrep scan --config auto' or 'semgrep scan --config p/<ruleset>', JSON and SARIF output, custom rules, 30+ language support, integration into any CI system, SEMGREP_RULES env var with semgrep ci (findings logged locally). No dashboard, no cloud upload, no PR comments, no dedup fingerprinting, no SCA/Secrets.",
    "source_url": "https://docs.semgrep.dev/deployment/oss-deployment",
    "source_title": "Semgrep Community Edition in CI - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "What works with zero token?",
    "confidence": "high"
  },
  {
    "claim": "Pro rules (20,000+ proprietary Semgrep-maintained rules) require a logged-in Semgrep account — SEMGREP_APP_TOKEN in CI. Community rules (~3,000 rules, LGPL-2.1/Semgrep Rules License) are accessible without any token via --config auto, --config p/<ruleset>, or SEMGREP_RULES=p/<ruleset>.",
    "source_url": "https://docs.semgrep.dev/semgrep-code/pro-rules",
    "source_title": "Semgrep Pro rules - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Do Pro rules require a token?",
    "confidence": "high"
  },
  {
    "claim": "Findings deduplication (fingerprinting) was explicitly moved from CE to the paid Pro Engine in the December 2024 Semgrep OSS update. Semgrep's own statement: 'the fingerprinting field — unnecessary for an engine but useful for competitor triage platforms — was among these [moved features].' Zero-token semgrep scan runs do NOT produce fingerprints for cross-run dedup; that requires AppSec Platform (token).",
    "source_url": "https://semgrep.dev/blog/2024/important-updates-to-semgrep-oss/",
    "source_title": "Important updates to Semgrep OSS - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Does findings dedup require a token?",
    "confidence": "high"
  },
  {
    "claim": "Semgrep Code and Semgrep Supply Chain are free for teams up to 10 contributors — a freemium tier that unlocks some Platform features (Pro rules, cross-file analysis, PR comments) without payment, but still requires account signup and SEMGREP_APP_TOKEN.",
    "source_url": "https://docs.semgrep.dev/semgrep-pro-vs-oss",
    "source_title": "Semgrep AppSec Platform versus Semgrep Community Edition - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "OSS-vs-paid boundary — is there a free tier?",
    "confidence": "high"
  },
  {
    "claim": "DISSENT — OpenGrep fork (January 2025): a coalition of 10+ AppSec companies (Aikido, Endor Labs, Jit, Orca Security, et al.) forked Semgrep CE specifically because Semgrep Inc. moved cross-function taint analysis, fingerprinting, tracking ignores, and Visual Basic support behind its commercial AppSec Platform. OpenGrep restores these under LGPL-2.1, is compatible with all Semgrep community rules and JSON/SARIF output, and represents the primary OSS dissent channel for teams wanting full-featured CI without platform coupling.",
    "source_url": "https://appsecsanta.com/sast-tools/opengrep-vs-semgrep",
    "source_title": "OpenGrep vs Semgrep (2026): Fork vs Upstream Comparison",
    "retrieved_at": "2026-06-13",
    "sub_question": "DISSENT: credible cases for avoiding semgrep ci / platform coupling",
    "confidence": "medium"
  },
  {
    "claim": "DISSENT — credential exposure risk: a GitHub issue (#11016) on semgrep/semgrep reports that when SEMGREP_APP_TOKEN is set and 'semgrep ci' downloads rules from a remote URL, the token is sent in the Authorization header to ANY domain, not just semgrep.dev. This is flagged as a medium-priority enhancement (not a critical vuln) but represents a real concern for teams using semgrep ci with custom remote rule sources.",
    "source_url": "https://github.com/semgrep/semgrep/issues/11016",
    "source_title": "Token leaks to non-Semgrep domains when using remote rule URLs - semgrep/semgrep #11016",
    "retrieved_at": "2026-06-13",
    "sub_question": "DISSENT: security concern with semgrep ci + token",
    "confidence": "medium"
  },
  {
    "claim": "DISSENT — telemetry warning from Trail of Bits (January 2024): Trail of Bits warns that '--config auto' submits metrics to Semgrep and recommends disabling metrics by default via environment variables or aliases, even for zero-token CE scanning. This is a concrete third-party security vendor's dissent against Semgrep's default telemetry behavior.",
    "source_url": "https://blog.trailofbits.com/2024/01/12/how-to-introduce-semgrep-to-your-organization/",
    "source_title": "How to introduce Semgrep to your organization - Trail of Bits Blog",
    "retrieved_at": "2026-06-13",
    "sub_question": "DISSENT: telemetry / privacy concerns with semgrep ci and semgrep scan",
    "confidence": "medium"
  },
  {
    "claim": "DISSENT — AppSec Testing Handbook (appsec.guide) recommends 'semgrep ci' as the primary CI command but uses the outdated 'returntocorp/semgrep' Docker image (not 'semgrep/semgrep') in its example YAML, and uses SEMGREP_RULES env var (not SEMGREP_APP_TOKEN) for a tokenless two-job setup: one monthly scheduled scan with 'p/default' and one PR scan with 'p/cwe-top-25 p/owasp-top-ten p/r2c-security-audit p/javascript p/trailofbits'. This third-party guide lags behind Semgrep's current recommended image name.",
    "source_url": "https://appsec.guide/docs/static-analysis/semgrep/continuous-integration/",
    "source_title": "Semgrep in CI - AppSec Testing Handbook",
    "retrieved_at": "2026-06-13",
    "sub_question": "DISSENT: third-party guides that diverge from official recommendation",
    "confidence": "medium"
  },
  {
    "claim": "Semgrep Fall 2025 CE release added multicore support (up to 3x performance improvement) and native Windows support to Community Edition. These are engine-level improvements applying to zero-token 'semgrep scan' usage. No changes to token requirements or CI command structure were announced.",
    "source_url": "https://semgrep.dev/blog/2025/semgrep-community-edition-fall-release-2025/",
    "source_title": "Semgrep Community Edition Fall Release 2025 - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Recent CE improvements affecting CI usage (2025-2026)",
    "confidence": "high"
  },
  {
    "claim": "SEMGREP_BASELINE_REF and SEMGREP_BASELINE_COMMIT are token-independent env vars enabling diff-aware scanning. They work with both 'semgrep ci' (when using SEMGREP_RULES) and 'semgrep scan'. The docs state SEMGREP_BASELINE_COMMIT supersedes SEMGREP_BASELINE_REF for precision but both are listed as supported. The official CE deployment docs show diff-aware scanning commented out, indicating Semgrep does not officially support it as a first-class CE feature.",
    "source_url": "https://docs.semgrep.dev/semgrep-ci/configuration-reference/",
    "source_title": "CI configuration reference - Semgrep",
    "retrieved_at": "2026-06-13",
    "sub_question": "Does diff-aware scanning require a token?",
    "confidence": "high"
  }
]

## Next questions (dynamically generated)
[
  "Does the 'returntocorp/semgrep' Docker image on Docker Hub still resolve as an alias or redirect to 'semgrep/semgrep', or does pulling it now fail — and is there a docker pull test or Docker Hub page confirming the current state?",
  "Does 'semgrep ci --sarif' work in fully tokenless mode (SEMGREP_RULES set, no SEMGREP_APP_TOKEN) and produce a SARIF file uploadable to GitHub Advanced Security via github/codeql-action/upload-sarif — and what is the exact YAML for that tokenless SARIF + GHAS workflow?",
  "Does SEMGREP_SEND_METRICS=0 fully disable all network calls from semgrep ci and semgrep scan (including version checks, rule fetches, and any telemetry), or only usage-metric pings — and what is the complete list of network calls each command makes in tokenless mode?",
  "Does GitLab ship its own independent Semgrep CI template (e.g., Semgrep.gitlab-ci.yml or Jobs/SAST.gitlab-ci.yml) in the gitlab-org/gitlab repo or the GitLab Secure templates, separate from Semgrep's own sample config — and if so, does it use 'semgrep ci' or the deprecated semgrep-action or a different invocation?",
  "What is the exact verbatim CE/tokenless GitHub Actions YAML tab on docs.semgrep.dev/semgrep-ci/sample-ci-configs — specifically the full YAML including triggers, flags (--error? --sarif?), and any differences from the 'Default' (token) tab beyond the run command swap?"
]
