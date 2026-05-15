# code-security Capability Pack — Deep Ask Research Findings

> Notebook: Code Security — SAST, DAST, Secret Detection, IaC Security, Vulnerability Triage
> Notebook ID: 32ffd85a-7887-490a-b2d9-01bcd6444e03
> Sources: 12 GitHub + deep research
> Date: 2026-05-15
> Rounds: 3

---

## Round 1: SAST, DAST, Secret Detection

### SAST (Semgrep)
- CLI: `semgrep ci` (CI mode), `semgrep -e '$X == $X' --lang=py path/` (custom pattern)
- Rule sets: p/ci, p/security-audit, p/nginx; custom YAML rules with metavariables ($X) + ellipsis (...)
- Taint mode: `mode: taint` with pattern-sources, pattern-sinks, pattern-sanitizers
- CI: SEMGREP_APP_TOKEN env var, diff-aware via SEMGREP_BASELINE_REF
- Output: SARIF format for GitHub code scanning integration
- Exit codes: 1 = blocking findings, 0 = clean

### DAST (Nuclei)
- CLI: `nuclei -u https://example.com`, `nuclei -l urls.txt`, `nuclei -u 192.168.1.0/24`
- Templates: `-tag cve/cloud/tech`, `-t path/to/template`, `-as` for auto-scan
- Severity filtering: `-severity` flag
- Rate limiting: `-rl 150` (default), adjustable per target

### Secret Detection
- Gitleaks: `gitleaks detect --source . -v`, `gitleaks git -v --log-opts="--all"`, pre-commit hook
- TruffleHog: `trufflehog git <url>`, `trufflehog s3 --bucket=X`, `trufflehog filesystem path/`
- Baseline: `--report-path findings.json` → `--baseline-path findings.json` for delta
- Inline allowlist: `# gitleaks:allow`
- TruffleHog CI: `--fail` flag → exit code 183 on leaked credentials
- Pre-commit: `.pre-commit-config.yaml` with gitleaks repo

---

## Round 2: IaC Security, Vulnerability Triage, Anti-Patterns

### IaC (Checkov)
- CLI: `checkov -d /path/`, `checkov -f file.tf`, `checkov --docker-image name:tag`
- 1000+ built-in policies mapping to CIS, SOC 2, HIPAA, PCI DSS
- 800+ graph-based cross-resource checks
- Skip: `--skip-check CKV_123`, inline `checkov:skip=CKV_123:reason`
- Baseline: `soft_fail: true` in CI, flip to false after critical fixes

### Vulnerability Triage
- ASPM platforms (Cycode, ArmorCode) consolidate findings with risk-based prioritization
- Reachability analysis (Endor Labs, Aikido): call graphs prove exploitability
- CVSS alone is insufficient — measures theoretical severity, not actual risk
- CLI tools: osv-scanner (Google, OSV.dev DB), Grype (Anchore, container/SBOM), Snyk (proprietary Intel DB)

### Anti-Patterns
- Tool sprawl: 72% orgs use >10 AppSec tools → isolated dashboards, context switching
- Alert fatigue: 30-50% time spent triaging false positives → critical vulns lost in noise
- Security theater: "Detection is not the bottleneck. Remediation is." — scanning without fixing

---

## Round 3: CI/CD Pipeline, AI-Specific Risks

### Four-Gate Pipeline Architecture (fastest-fail-first)
1. Pre-commit hooks (<10s): Gitleaks/detect-secrets, TFLint, Trivy
2. PR gates (diff-aware, ~10s): Semgrep, Checkov, KICS, Trivy, Pixee auto-remediation
3. Full CI/CD (minutes-hours): CodeQL (deep semantic), Snyk SCA, container scanners
4. Runtime: Prowler (cloud posture), Nuclei (DAST sweeps)

### Exit Codes
- Semgrep: exit 1 = blocking findings, exit 0 = clean
- TruffleHog: exit 183 = verified leaked credentials, exit 1 = scanner error, exit 0 = clean

### AI-Generated Code Risks
- Hallucinated/vulnerable dependencies (supply chain attacks via fake package names)
- Complex logic flaws (IDOR, broken access control) — beyond pattern-matching SAST
- Agentic attack surfaces: prompt injection via MCP, data exfiltration
- Semgrep Guardian: in-workflow enforcement, scans code AS AI generates it

---

## Key Judgment Rules Extracted

### sast_scan
1. Semgrep default: `semgrep ci` with SEMGREP_APP_TOKEN in CI
2. Diff-aware scanning on PRs: SEMGREP_BASELINE_REF=main
3. Custom rules: YAML with metavariables + taint mode for data flow
4. SARIF output for GitHub code scanning integration

### dast_scan
1. Nuclei for template-based scanning: `-tag cve` for CVEs, `-as` for auto-detect
2. Rate limit: `-rl` flag to avoid DoS'ing own infrastructure
3. Severity filter: focus on critical/high in CI, full spectrum in nightly

### secret_detection
1. Gitleaks pre-commit hook: `.pre-commit-config.yaml` integration
2. Baseline management: `--baseline-path` for delta scanning (only new secrets)
3. TruffleHog `--fail` flag: exit 183 blocks CI on verified leaks
4. Inline suppression: `# gitleaks:allow` with mandatory review

### iac_security_lint
1. Checkov `--skip-check` for known false positives with documented reason
2. 1000+ policies mapped to compliance frameworks (CIS/SOC2/HIPAA)
3. soft_fail→hard_fail transition as baseline clears
4. Inline suppression: `checkov:skip=CKV_ID:reason`

### vulnerability_triage
1. CVSS alone is insufficient — add reachability analysis
2. ASPM consolidation: single dashboard from 5-15 scanners
3. osv-scanner for OSS, Grype for containers, Snyk for proprietary intelligence
4. "Detection ≠ remediation" — findings without fix workflows = security theater
