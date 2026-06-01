# Security Review: CI/CD Security Pipeline (Semgrep + Nuclei + CVSS triage + new secret scanning)

> Reviewed against the `code-security` capability pack: cross-cutting rules (Four-Gate Pipeline, Detection ≠ Remediation), SAST (S1-S8), DAST (D1-D7), Secret Detection (SE1-SE7), Vulnerability Triage (V1-V7).

**What you told me you do:**
1. Run Semgrep and Nuclei in the pipeline.
2. Dump all CRITICAL CVSS findings to the dev channel.
3. Fix top-down by severity.
4. Want to add secret scanning.

There are **four serious problems** with this setup, two of which directly violate the pack's cross-cutting rules. Below is the violation-by-violation breakdown with the exact fix for each, followed by the secret-scanning design you asked for.

---

## P0 — Blocking (fix before you trust this pipeline at all)

### [P0] Rule V1 + V7 (triage): "Fix top-down by CVSS severity" is the single biggest flaw

You are sorting by CVSS score and fixing from the top. The pack treats this as the canonical anti-pattern (V1): **CVSS measures theoretical severity, not actual risk.** A CVSS 9.8 in an unused/dead dependency is *less* urgent than a CVSS 7.5 in a directly-called function exposed to user input.

What "top-down by CVSS" misses:
- **Reachability** — is the vulnerable code path actually reachable from user input? (V6)
- **EPSS** — probability of exploitation in the next 30 days (V1).
- **KEV** — is it *actively being exploited in the wild right now*? (V7)

The killer case the pack calls out (V7): a **CVSS 5.0 that is on CISA's KEV list is P0**, but your current sort buries it below every theoretical CVSS 9.x. You are provably fixing the wrong things first.

**Fix — replace "sort by CVSS" with the pack's priority formula (V1):**
```
P0 = KEV OR (CVSS >= 9.0 AND reachable AND EPSS > 0.5)
P1 = (CVSS >= 7.0 AND reachable) OR (CVSS >= 9.0 AND NOT reachable)
P2 = CVSS >= 4.0 AND NOT reachable
P3 = CVSS < 4.0 OR explicitly accepted risk
```

Wire in the missing signals:
```bash
# KEV check — any match here is automatic P0, regardless of CVSS (V7)
curl -s https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json \
  | jq '.vulnerabilities[] | select(.cveID == "CVE-XXXX-YYYY")'

# Reachability sanity check when you have no SCA reachability tool (V6)
grep -r "vulnerable_function\|require.*vuln_pkg" src/   # no matches -> downgrade to P2
```
Add an EPSS lookup (FIRST.org) and a KEV lookup as enrichment steps before you assign priority. KEV overrides everything.

### [P0] Cross-Cutting Rule: Detection ≠ Remediation — "dump to dev channel" is security theater

> "Scanning without a fix workflow is security theater... Raw scanner dumps sent to developers without prioritization are a violation."

Dumping findings into a Slack/dev channel is the exact failure mode the pack names: 72% of orgs use >10 AppSec tools but still fail to remediate because **scanners produce alerts, not actions**. A channel message has no owner, no deadline, no status, and scrolls away. "We have N findings" is a backlog, not a security posture.

**Fix — every P0/P1 finding gets an owner + deadline + status + verification (V5):**

| Field | Required | Example |
|-------|----------|---------|
| Owner | Yes | @backend-team |
| Deadline | Yes (P0: 24h, P1: 1 sprint) | 2026-06-01 |
| Status | Yes | open / in-progress / fixed / accepted-risk |
| Verification | Yes (re-scan confirms resolved) | re-scan clean |

Stop dumping to the channel. Route findings into your issue tracker (one issue per deduped finding) with these fields populated. The channel can post a *summary link*, not the raw firehose.

### [P0] Rule D2 (dast): Confirm Nuclei is NOT pointed at production

Nuclei is an **active** DAST scanner — it sends exploit payloads. The pack's hard rule (D2): **NEVER active-scan production.** It causes service disruption (fuzzing crashes endpoints), data corruption (write-path injection tests), and WAF/monitoring alert fatigue. You didn't say which target Nuclei hits — if it's production, this is a release-blocking misconfiguration.

**Fix:**
```bash
# CORRECT — active scan against staging only
nuclei -u https://staging.example.com -severity critical,high -rl 50

# If you genuinely have no staging, the ONLY production-safe option is passive:
docker run zaproxy/zap-stable zap-baseline.py -t https://production.example.com
```
The pack rejects the "we scan production carefully" excuse outright: there is no safe way to run active DAST against production. Get a staging environment.

---

## P1 — Required (fix this sprint)

### [P1] Rule SE1 + SE2 (secrets): Set up secret scanning as TWO layers, not one

You asked to "set up secret scanning." The pack mandates a **two-layer architecture** (SE1) — a single layer is explicitly insufficient:

| Layer | Tool | Command | Why |
|-------|------|---------|-----|
| Pre-commit (<5s) | Gitleaks | `gitleaks protect --staged -v` | Catches secret BEFORE it's committed |
| CI pipeline | Gitleaks + TruffleHog | see below | Safety net for `git commit --no-verify` bypass |

- **CI-only is wrong (SE2):** by the time CI runs, the secret is already pushed to the remote and in git history.
- **Pre-commit-only is wrong (SE1):** any developer can run `git commit --no-verify` and skip every hook. CI is the backstop.

**Fix — pre-commit hook:**
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0        # pin the version (SE1)
    hooks:
      - id: gitleaks
```
```bash
pip install pre-commit && pre-commit install
```

**Fix — CI safety net with TruffleHog verification (SE4):**
```bash
# Exit 183 = TruffleHog confirmed the credential is ACTIVE (not a false positive) -> fail the pipeline
trufflehog git file://. --only-verified --fail --json > trufflehog.json
```
Use **Gitleaks for broad coverage** and **TruffleHog `--only-verified` for active-credential verification** — they are complementary, not redundant (SE4/SE7). Do not run TruffleHog without `--only-verified` (high false-positive rate).

### [P1] Rule SE6 (secrets): Pre-commit the remediation ORDER before you turn scanning on

The moment you enable scanning you *will* find a live secret. When you do, the order is non-negotiable (SE6) — and it is the opposite of most people's instinct:

```
1. ROTATE the credential FIRST (assume compromised from the second it was committed)
2. Update running apps to the new credential (vault/env/CI secrets)
3. Remove the secret from code + add to .gitleaks.toml allowlist
4. Purge from git history (git filter-repo / BFG, force-push, contributors re-clone)
5. Prevent recurrence (pre-commit + CI hooks)
```
**Do NOT** delete the secret from code first and call it done — it's still in git history, GitHub indexes commit content, and scrapers may already have it. Rotate first, always.

### [P1] Rule S3 (sast): Make Semgrep diff-aware on PRs

You didn't mention baseline/diff mode. Without it, Semgrep re-scans the entire repo on every PR and surfaces hundreds of pre-existing findings. This is the pack's **#1 named cause of developers ignoring SAST** (S3) — 30-50% of triage time wasted on old tech debt.

**Fix:**
```bash
# In CI on PRs — report only NEW findings introduced by the PR (S3)
export SEMGREP_BASELINE_REF=main
semgrep ci

# Non-Semgrep-App equivalent
semgrep scan --config auto --baseline-commit=$(git merge-base HEAD main) .
```
For your existing codebase, establish a baseline once so day-one rollout doesn't drown the team (S8).

### [P1] Rule D3 + D5 (dast): Severity-filter and refresh Nuclei templates

- **D3** — in the PR/CI gate, restrict to `-severity critical,high`; run the full spectrum only in a nightly scan. All-severity in a PR gate floods output and delays deploys with no security benefit.
- **D5** — run `nuclei -update-templates` as a step *before* every scan. Cached templates >1 week old miss recently disclosed CVEs (new templates land daily).

```yaml
- name: Update Nuclei templates
  run: nuclei -update-templates
- name: DAST scan (staging)
  run: nuclei -u $STAGING_URL -severity critical,high -rl 50 -json -o dast.json
```

---

## P2 — Advisory (improves posture)

### [P2] Rule D7 + V4 (correlation): Cross-reference Semgrep and Nuclei — you already have both

You run SAST *and* DAST but (per your description) treat outputs independently. The pack says correlate them (D7/V4). A finding flagged by **both Semgrep and Nuclei is DUAL-VERIFIED → high-confidence P0**, and should jump the queue:
```
[P0] SQL Injection — /api/users?id= (CWE-89)
  Verified by: Semgrep (sast.sarif) + Nuclei (CVE template)
  Confidence: DUAL-VERIFIED
```
Dedup key: `CWE + endpoint/file + vuln type` (V4). This also stops the same SQLi being counted 3x and inflating your "total findings."

### [P2] Rule S5 (sast): Emit SARIF, not just channel text

Produce SARIF so findings land in the GitHub Security tab, can be diffed across runs, and can feed an ASPM/consolidation layer later:
```bash
semgrep scan --config auto --sarif --output=sast-results.sarif .
```
Text-only output (or a channel dump) can't be uploaded to GitHub code scanning or compared over time (S5).

### [P2] Rule V2/V3 (triage): Consolidate scanners; add SCA coverage

You have SAST + DAST but no **SCA** (dependency/CVE scanning) — yet your whole triage process is CVSS-based, which is fundamentally a dependency-CVE concern. Add free coverage (V3):
```bash
osv-scanner -r .                 # OSS deps, Google OSV.dev DB, flags KEV
trivy fs .                       # all-in-one: deps + IaC + secrets
grype myapp:latest               # container images
```
Then consolidate to a single deduped triage plan (V2) instead of N separate channel dumps.

### [P2] Rule (IaC coverage gap): No infrastructure scanning at all

There's no IaC scanning in your pipeline. If you ship any Terraform / Dockerfile / K8s manifests, misconfigs (public S3, open security groups) are cheapest to catch at code-write time. Add Checkov at the PR gate (runs <30s):
```bash
checkov -d .        # exit 1 = failed checks
```

---

## Pipeline Gate Audit (Four-Gate, Fastest-Fail-First)

The pack mandates ordering scans by speed so slow scans never block fast feedback (a 5-min scan in pre-commit = violation). Here's where your current + recommended tools belong:

| Gate | Time budget | Should run | Your status |
|------|------------|-----------|-------------|
| Pre-commit (<10s) | <10s | **Gitleaks `protect --staged`**, Trivy fs | MISSING — add (SE2) |
| PR gate (diff-aware, ~10s–1min) | 10s–1min | **Semgrep `SEMGREP_BASELINE_REF=main`**, Checkov, TruffleHog `--only-verified --fail` | Semgrep present but likely NOT diff-aware (S3); secrets missing |
| Full CI (minutes) | minutes | osv-scanner / Grype SCA, deep Semgrep `p/security-audit` nightly | MISSING SCA |
| Runtime (async) | async | **Nuclei DAST** `-severity critical,high -rl 50` against **staging** | Present — VERIFY not prod (D2), add `-rl` + `-update-templates` |

**Biggest structural gap:** secret scanning belongs at the *fastest* gate (pre-commit) precisely so it catches the secret before it ever reaches the remote — don't bolt it on as a CI-only afterthought.

---

## Tool Recommendation (for your context)

| Need | Tool | Key flags / rule |
|------|------|------------------|
| SAST | Semgrep (keep it) | `SEMGREP_BASELINE_REF=main` on PRs (S3); `--sarif` output (S5) |
| DAST | Nuclei (keep it) | staging only (D2); `-severity critical,high` (D3); `-rl 50` (D4); `-update-templates` (D5) |
| Secrets — pre-commit | Gitleaks | `gitleaks protect --staged -v`, pinned `v8.18.0` (SE1/SE2) |
| Secrets — CI verify | TruffleHog | `--only-verified --fail` → exit 183 blocks (SE4) |
| SCA (add) | osv-scanner + Trivy | `osv-scanner -r .`, `trivy fs .` (V3) — free, flags KEV |
| IaC (add, if applicable) | Checkov | `checkov -d .` at PR gate (V3) |
| Triage | KEV + EPSS + reachability | replace CVSS-sort with V1 formula; KEV = always P0 (V7) |

---

## Bottom line — the 4 things that actually matter

1. **Stop sorting by CVSS.** Adopt the V1 formula; check **KEV** (always P0) and **reachability** first. You are currently fixing theoretical-worst before actively-exploited. (P0)
2. **Stop dumping to the dev channel.** Every P0/P1 finding needs owner + deadline + status in your issue tracker, or it's security theater. (P0)
3. **Verify Nuclei targets staging, not production**, with `-rl` and fresh templates. (P0/P1)
4. **Set up secret scanning as two layers** (Gitleaks pre-commit + Gitleaks/TruffleHog CI), pin versions, and rehearse the rotate-FIRST remediation order before you flip it on. (P1)

Quick wins this week: add the Gitleaks pre-commit hook (5 min, <5s/commit), add `SEMGREP_BASELINE_REF=main`, add `-rl 50 -update-templates` to Nuclei, and add a KEV-check step ahead of triage.
