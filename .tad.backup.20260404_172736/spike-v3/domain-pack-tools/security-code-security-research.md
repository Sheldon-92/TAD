# Code Security — Security Domain Pack Research

**Date**: 2026-04-03
**Scope**: "Does my code have vulnerabilities?" — SAST (static) + DAST (dynamic) + secrets detection + IaC linting.
**Out of scope**: Policy compliance proof (compliance pack), runtime WAF, cloud posture management (CSPM).

---

## 1. Tool Landscape

| Tool | Stars | Last Commit | Install | Free | CI/CD | Ecosystems | Category |
|------|-------|-------------|---------|------|-------|------------|----------|
| Semgrep | 14.3k | 2026-04 (active) | `brew install semgrep` / `pip install semgrep` | CE free, Platform paid | GitHub Actions, GitLab, any CI | 30+ languages | SAST |
| Bandit | 7.8k | 2026-01 (v1.9.3) | `pip install bandit` | Yes | GitHub Actions, pre-commit | Python only | SAST |
| CodeQL | 8.2k (queries repo) | 2026-04 (v2.24.0) | `gh extension install github/gh-codeql` | Free on public repos | GitHub Actions native | C/C++, C#, Go, Java, JS/TS, Python, Ruby, Swift, Kotlin | SAST |
| Bearer CLI | unverified | 2026 (active) | `brew install bearer/tap/bearer` | Yes (OSS) | GitHub Actions, Docker | Ruby, JS/TS, Java, Go, PHP, Python | SAST |
| OWASP ZAP | 14.9k | 2026 (active, Checkmarx-backed) | `brew install zaproxy` / Docker | Yes | GitHub Actions, Docker scripts | Language-agnostic (HTTP) | DAST |
| Nikto | 10.2k | unverified | `apt install nikto` / Docker | Yes | Script-based | Language-agnostic (HTTP) | DAST |
| Nuclei | 26.9k | 2026-04 (active) | `go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest` | Yes (MIT) | GitHub Actions | Language-agnostic (multi-protocol) | DAST |
| Gitleaks | 25.8k | 2026-04 (active) | `brew install gitleaks` | Yes | GitHub Actions, pre-commit | Language-agnostic (regex) | Secrets |
| TruffleHog | 24.5k | 2026-04 (v3.94.x) | `brew install trufflehog` | OSS (AGPL-3) | GitHub Actions | 800+ secret types, multi-source | Secrets |
| detect-secrets | 4.3k | 2026-02 | `pip install detect-secrets` | Yes (Apache-2.0) | pre-commit, CI | Language-agnostic (baseline) | Secrets |
| Hadolint | 11.9k | 2026-01 | `brew install hadolint` | Yes | GitHub Actions, pre-commit | Dockerfile + inline bash | IaC |
| Checkov | 8.6k | 2026 (active) | `pip install checkov` | Yes (Apache-2.0) | GitHub Actions, GitLab | Terraform, K8s, Docker, CloudFormation, ARM, Bicep | IaC |

### CLI Usage Examples

#### Semgrep (SAST — multi-language)
```bash
# Install
brew install semgrep

# Basic scan with auto rules
semgrep scan --config auto .

# Scan with specific ruleset + SARIF output
semgrep scan --config p/owasp-top-ten --sarif --output=results.sarif .

# Multiple output streams
semgrep scan --text --output=report.txt --json-output=report.json --sarif-output=report.sarif .
```

#### Bandit (SAST — Python)
```bash
# Install
pip install bandit

# Scan directory recursively
bandit -r ./src -f json -o bandit-report.json

# Scan with severity filter
bandit -r ./src -ll  # only medium and above

# SARIF output for GitHub code scanning
bandit -r ./src -f sarif -o bandit.sarif
```

#### CodeQL (SAST — deep analysis)
```bash
# Install via gh extension
gh extension install github/gh-codeql

# Create database
codeql database create my-db --language=python --source-root=./src

# Analyze with default security queries
codeql database analyze my-db --format=sarif-latest --output=results.sarif

# Analyze with specific query suite
codeql database analyze my-db codeql/python-queries:codeql-suites/python-security-extended.qls --format=sarif-latest --output=results.sarif
```

#### Bearer CLI (SAST — data-flow aware)
```bash
# Install
brew install bearer/tap/bearer

# Basic scan
bearer scan .

# SARIF output with severity filter
bearer scan . --format sarif --output bearer-report.sarif --severity critical,high

# HTML report
bearer scan . --format html --output security-report.html
```

#### ZAP (DAST — web app scanner)
```bash
# Baseline scan (passive, ~1 min spider)
docker run -v $(pwd):/zap/wrk/:rw zaproxy/zap-stable \
  zap-baseline.py -t https://target.example.com -r baseline-report.html

# Full scan (spider + active scan)
docker run -v $(pwd):/zap/wrk/:rw zaproxy/zap-stable \
  zap-full-scan.py -t https://target.example.com -r full-report.html -J full-report.json

# API scan (OpenAPI/SOAP)
docker run -v $(pwd):/zap/wrk/:rw zaproxy/zap-stable \
  zap-api-scan.py -t openapi.yaml -f openapi -r api-report.html
```

#### Nuclei (DAST — template-based)
```bash
# Install
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

# Scan with all templates
nuclei -u https://target.example.com

# Scan with specific severity + JSON output
nuclei -u https://target.example.com -severity critical,high -json -o nuclei-results.json

# Scan with CVE templates only
nuclei -u https://target.example.com -tags cve -o cve-results.txt
```

#### Gitleaks (Secrets)
```bash
# Install
brew install gitleaks

# Scan git history
gitleaks git -v --source=. --report-format=json --report-path=gitleaks-report.json

# Pre-commit (staged files only)
gitleaks protect --staged -v

# Scan specific commit range
gitleaks git -v --log-opts="--all commitA..commitB" .
```

#### TruffleHog (Secrets — with verification)
```bash
# Install
brew install trufflehog

# Scan git repo with verification
trufflehog git file://. --only-verified --json

# Scan remote repo
trufflehog git https://github.com/org/repo --only-verified

# Scan filesystem
trufflehog filesystem /path/to/project --json
```

#### Hadolint (IaC — Dockerfile)
```bash
# Install
brew install hadolint

# Lint Dockerfile
hadolint Dockerfile

# With specific ignored rules
hadolint --ignore DL3008 --ignore DL3009 Dockerfile

# JSON output
hadolint -f json Dockerfile > hadolint-report.json
```

### SAST vs DAST Coverage Matrix

| Vulnerability Type | SAST Tools | DAST Tools | Gap |
|-------------------|-----------|-----------|-----|
| SQL Injection | semgrep, bandit, codeql, bearer | ZAP, nuclei | Stored procedures hard for SAST |
| XSS (Reflected) | semgrep, codeql, bearer | ZAP, nuclei | DAST better at DOM-based XSS |
| XSS (Stored) | semgrep, codeql | ZAP | Requires multi-step DAST flows |
| Command Injection | semgrep, bandit, codeql | ZAP | SAST stronger — pattern matching |
| Path Traversal | semgrep, codeql, bearer | ZAP, nuclei | Both effective |
| SSRF | semgrep, codeql | ZAP, nuclei | DAST needs reachable endpoints |
| Insecure Deserialization | semgrep, codeql | nuclei (known CVEs) | SAST stronger — code pattern |
| Hardcoded Secrets | semgrep (secrets rules) | none | Dedicated secret scanners preferred |
| Broken Auth | limited (codeql patterns) | ZAP (auth scripts) | Mostly manual/DAST |
| Broken Access Control | limited | ZAP (with auth context) | Mostly manual review |
| Security Misconfiguration | hadolint, checkov | ZAP, nikto, nuclei | DAST for runtime, IaC for build-time |
| Cryptographic Failures | semgrep, bandit, codeql | limited | SAST dominant |
| Vulnerable Dependencies | none (SCA tools) | nuclei (known CVEs) | SCA gap — needs Dependabot/Trivy |

---

## Search Log

| # | Query | Results Used | Date |
|---|-------|-------------|------|
| 1 | semgrep GitHub stars 2026 CLI install | Stars (14.3k), install methods | 2026-04-03 |
| 2 | bandit python SAST GitHub stars 2026 | Stars (7.8k), version 1.9.3, 47 checks | 2026-04-03 |
| 3 | codeql GitHub stars CLI usage 2026 | v2.24.0, 491 security queries, SARIF | 2026-04-03 |
| 4 | bearer CLI SAST GitHub stars 2026 | OSS SAST, data-flow analysis | 2026-04-03 |
| 5 | OWASP ZAP GitHub stars CLI usage 2026 | Stars (14.9k), Checkmarx backing | 2026-04-03 |
| 6 | nikto web scanner GitHub stars 2026 | Stars (10.2k), 7000+ checks | 2026-04-03 |
| 7 | gitleaks GitHub stars install CLI 2026 | Stars (25.8k), multi-platform install | 2026-04-03 |
| 8 | trufflehog GitHub stars CLI usage 2026 | Stars (24.5k), 800+ secret types, verification | 2026-04-03 |
| 9 | detect-secrets Yelp GitHub stars 2026 | Stars (4.3k), baseline approach | 2026-04-03 |
| 10 | hadolint Dockerfile linter GitHub stars 2026 | Stars (11.9k), ShellCheck integration | 2026-04-03 |
| 11 | SAST tools comparison 2026 open source | Semgrep as primary, language-specific secondary, 60-70% commercial parity | 2026-04-03 |
| 12 | DAST tools open source 2026 comparison | ZAP + Nuclei as top pair, 80-90% coverage | 2026-04-03 |
| 13 | OWASP ASVS chapters code security V1 through V14 | V1-V14 chapter list, ASVS 5.0 update to 17 chapters | 2026-04-03 |
| 14 | code security best practices GitHub repository 2026 | GitHub built-in features, secret management, dependency management | 2026-04-03 |
| 15 | secret detection best practices pre-commit CI/CD 2026 | Layered approach, shift-left, defense in depth | 2026-04-03 |
| 16 | nuclei projectdiscovery GitHub stars CLI 2026 | Stars (26.9k), 9000+ community templates (nuclei-templates repo), multi-protocol | 2026-04-03 |
| 17 | checkov IaC security scanner GitHub stars 2026 | 1000+ built-in checks, graph-based policies | 2026-04-03 |
| 18 | OWASP Top 10 2021 A01 A10 tool coverage SAST DAST | DAST better for A01/A04/A06/A08, SAST better for A02/A07/A10 | 2026-04-03 |
| 19 | semgrep CLI scan command examples output format SARIF JSON | Multi-stream output, --sarif, --json-output flags | 2026-04-03 |
| 20 | bearer CLI scan command install usage example | bearer scan ., SARIF/HTML output, severity filter | 2026-04-03 |
| 21 | codeql CLI database create analyze command example | database create + analyze two-step, SARIF output | 2026-04-03 |
| 22 | ZAP CLI docker scan command baseline full scan example | zap-baseline.py, zap-full-scan.py, zap-api-scan.py | 2026-04-03 |
| 23 | gitleaks detect protect CLI command examples pre-commit | detect/protect commands, v8.19 deprecation note | 2026-04-03 |
| 24 | trufflehog CLI scan git filesystem command examples | git file://, filesystem, --only-verified | 2026-04-03 |
| 25 | "awesome-security" OR "awesome-appsec" GitHub repository | paragonie/awesome-appsec, sbilly/awesome-security | 2026-04-03 |

---

## 2. Framework Alignment

| Framework | Item | Tool Coverage | Gap |
|-----------|------|--------------|-----|
| OWASP Top 10 (2021/2025) | A01 Broken Access Control | ZAP (auth scripts), limited SAST | Primarily manual review; DAST more effective |
| OWASP Top 10 | A02 Cryptographic Failures | semgrep, bandit, codeql | SAST dominant; DAST limited |
| OWASP Top 10 | A03 Injection | semgrep, codeql, bearer, ZAP | Well covered by both SAST + DAST |
| OWASP Top 10 | A04 Insecure Design | limited | Architecture-level; tooling gap — needs threat modeling |
| OWASP Top 10 | A05 Security Misconfiguration | hadolint, checkov, ZAP, nikto, nuclei | Well covered: IaC (build-time) + DAST (runtime) |
| OWASP Top 10 (2021/2025) | A06 Vulnerable Components (→ A03:2025 Supply Chain) | none in this pack | SCA gap — needs Dependabot, Trivy, or Snyk. Note: OWASP 2025 upgraded this to A03 "Software Supply Chain Failures" |
| OWASP Top 10 | A07 Auth Failures | codeql (patterns), ZAP | SAST better than DAST per research |
| OWASP Top 10 | A08 Software Integrity | none in this pack | Supply chain — needs SBOM tools, Sigstore |
| OWASP Top 10 | A09 Logging Failures | none | Neither SAST nor DAST effective — manual review |
| OWASP Top 10 | A10 SSRF | semgrep, codeql, nuclei | SAST stronger; DAST needs reachable endpoints |
| ASVS 4.0.3 | V1 Architecture | none | Requires manual threat modeling |
| ASVS 4.0.3 | V2 Authentication | codeql (patterns), ZAP | Partial — business logic gaps |
| ASVS 4.0.3 | V3 Session Management | ZAP (cookie/session checks) | DAST partial coverage |
| ASVS 4.0.3 | V4 Access Control | ZAP (auth context) | Primarily manual; DAST partial |
| ASVS 4.0.3 | V5 Validation/Sanitization/Encoding | semgrep, codeql, bearer, ZAP | Best covered chapter — SAST + DAST synergy |
| ASVS 4.0.3 | V6 Stored Cryptography | semgrep, bandit, codeql | SAST strong (weak algo detection) |
| ASVS 4.0.3 | V7 Error Handling/Logging | semgrep (info leak patterns) | Partial — stack trace disclosure |
| ASVS 4.0.3 | V8 Data Protection | bearer (data-flow), gitleaks, trufflehog | Bearer tracks PII flow; secret scanners cover credentials |
| ASVS 4.0.3 | V9 Communication | ZAP (TLS checks), nuclei (SSL templates) | DAST strong for transport layer |
| ASVS 4.0.3 | V10 Malicious Code | none | Requires code review process, not tooling |
| ASVS 4.0.3 | V11 Business Logic | none | Cannot be automated — manual testing only |
| ASVS 4.0.3 | V12 Files and Resources | semgrep (upload patterns), ZAP | Partial SAST + DAST coverage |
| ASVS 4.0.3 | V13 API and Web Service | ZAP (API scan), semgrep, bearer | ZAP API scan mode + SAST rules |
| ASVS 4.0.3 | V14 Configuration | hadolint, checkov, nikto, nuclei | Well covered: IaC lint + server scan |
| CWE | Top 25 (2023) | semgrep, codeql cover ~18/25 | Gaps in race conditions (CWE-362), privilege mgmt (CWE-269) |
| SANS | Top 25 | Overlaps CWE Top 25 | Same coverage and gaps as CWE above |

---

## 3. Best Practices (from GitHub repos)

### 3.1 paragonie/awesome-appsec (4.3k stars)
- Curated list of application security resources organized by language
- Covers secure coding standards per language (Java, Node.js, Python, PHP, Ruby)
- Key takeaway: Language-specific security guides complement generic SAST rules
- URL: https://github.com/paragonie/awesome-appsec

### 3.2 sbilly/awesome-security (13k+ stars)
- Comprehensive collection of security tools, libraries, and resources
- Organized by category: network, web, forensics, threat intelligence
- Key takeaway: Security toolchain should span beyond code (network, infrastructure, monitoring)
- URL: https://github.com/sbilly/awesome-security

### 3.3 OWASP DevSecOps Guideline
- Defense-in-depth approach: pre-commit + CI/CD + runtime scanning
- Recommends layered secret detection: pre-commit hooks (fast) -> CI/CD mandatory scans (safety net) -> repository audits (historical)
- Shift-left strategy: catch issues at earliest possible stage
- Key takeaway: No single tool covers everything; layered scanning with multiple tool types is mandatory

---

## 4. Capability Design Recommendations

### 4.1 `sast_scan` — Type B (Code/Tool)

**Purpose**: Run static analysis against source code to find vulnerabilities before deployment.

**Steps**:
1. `select_scanner` — Choose scanner based on project language (semgrep for multi-lang, bandit for Python-only, codeql for deep analysis)
2. `configure_rules` — Select ruleset: auto (default), OWASP Top 10, or custom rules
3. `execute_scan` — Run scanner with SARIF output for standardized results
4. `triage_findings` — Classify findings by severity (critical/high/medium/low), filter false positives against baseline
5. `generate_report` — Produce actionable report with file paths, line numbers, and remediation guidance

**tool_ref**: `semgrep_cli` (primary), `bandit_cli` (Python), `codeql_cli` (deep analysis), `bearer_cli` (data-flow)

**quality_criteria**:
- Must produce SARIF output for CI/CD integration
- Must support baseline comparison to avoid alert fatigue on existing code
- Must cover OWASP Top 10 A02 (Crypto), A03 (Injection), A07 (Auth), A10 (SSRF) at minimum
- False positive rate below 30% on standard benchmarks

### 4.2 `dast_scan` — Type B (Code/Tool)

**Purpose**: Test running web application for vulnerabilities via HTTP interaction.

**Steps**:
1. `select_scan_type` — Choose: baseline (passive, ~1 min), full (active, 10-60 min), or API scan
2. `configure_target` — Set target URL, authentication credentials if needed, scan policy
3. `execute_scan` — Run ZAP or Nuclei against target with appropriate rate limiting
4. `verify_findings` — Cross-reference DAST findings with SAST results to eliminate duplicates
5. `prioritize_exploitability` — Rank findings by actual exploitability, not just CVSS score

**tool_ref**: `zap_docker` (comprehensive), `nuclei_cli` (template-based CVE), `nikto_cli` (quick server sweep)

**quality_criteria**:
- Must not disrupt production systems (rate limiting, safe mode)
- Must cover OWASP Top 10 A01 (Access Control), A03 (Injection), A05 (Misconfig)
- Must support authenticated scanning for non-trivial applications
- Report must include reproduction steps for each finding

### 4.3 `secret_detection` — Type B (Code/Tool)

**Purpose**: Detect hardcoded credentials, API keys, tokens, and other secrets in code and git history.

**Steps**:
1. `select_detection_mode` — Choose: pre-commit (fast, staged files), CI scan (full repo), historical audit (git log)
2. `configure_rules` — Set custom allowlist, regex patterns, entropy thresholds
3. `execute_scan` — Run gitleaks (speed) or trufflehog (depth + verification)
4. `verify_secrets` — TruffleHog verifies found secrets are still active by testing against services
5. `remediate_and_rotate` — For verified secrets: rotate credential, add to .gitignore, update vault

**tool_ref**: `gitleaks_cli` (speed, pre-commit), `trufflehog_cli` (depth, verification), `detect_secrets_cli` (baseline)

**quality_criteria**:
- Pre-commit scan must complete in <5 seconds for developer experience
- Must detect top 20 secret types (AWS keys, GitHub tokens, private keys, DB passwords, etc.)
- Must support baseline mode to avoid flagging known/allowed patterns
- Verification of live secrets is mandatory for CI/CD mode

### 4.4 `iac_security_lint` — Type B (Code/Tool)

**Purpose**: Lint infrastructure-as-code files for security misconfigurations before deployment.

**Steps**:
1. `detect_iac_files` — Scan project for Dockerfiles, Terraform, K8s manifests, CloudFormation templates
2. `select_linter` — Choose: hadolint (Dockerfile), checkov (multi-IaC)
3. `execute_lint` — Run linter with default + custom policies
4. `map_to_compliance` — Map findings to CIS benchmarks or organizational policies
5. `fail_or_warn` — Apply severity threshold: critical/high = fail pipeline, medium/low = warn

**tool_ref**: `hadolint_cli` (Dockerfile), `checkov_cli` (Terraform, K8s, CloudFormation)

**quality_criteria**:
- Must check for running as root, exposed ports, pinned versions (Dockerfile)
- Must validate least-privilege IAM, encryption at rest, public access blocks (Terraform/CloudFormation)
- Must integrate with pre-commit hooks for shift-left
- Must produce machine-readable output (JSON/SARIF)

### 4.5 `vulnerability_triage` — Type A (Document/Research)

**Purpose**: Aggregate findings from SAST, DAST, and secret scans into a prioritized action plan.

**Steps**:
1. `collect_reports` — Gather SARIF/JSON outputs from all scan tools
2. `deduplicate` — Cross-reference SAST and DAST findings to eliminate duplicates (same vuln found by both)
3. `enrich_context` — Add CWE mapping, CVSS scoring, exploitability data, affected component info
4. `prioritize` — Rank by: verified exploitable > high CVSS + reachable > medium CVSS > informational
5. `generate_action_plan` — Produce triage document: fix now (P0), fix this sprint (P1), backlog (P2), accept risk (P3)

**tool_ref**: None (aggregation logic, not tool execution)

**quality_criteria**:
- Must deduplicate across tools (same SQLi found by semgrep and ZAP counts once)
- Must map every finding to CWE ID
- Must separate verified vulnerabilities from potential/unverified
- Action plan must have clear ownership and timeline per finding

---

## 5. Anti-Patterns & Pitfalls

### 5.1 "Scan Everything, Fix Nothing" (Alert Fatigue)
Running all tools with default settings on a large existing codebase produces thousands of findings. Teams become overwhelmed and ignore results entirely. **Mitigation**: Use baseline mode (detect-secrets baseline, semgrep with --baseline-commit) to only surface new findings. Gradually reduce baseline over sprints.

### 5.2 "SAST-Only False Confidence"
Relying solely on SAST gives false confidence — SAST cannot detect runtime issues like broken access control (A01), security misconfiguration in deployed environments (A05), or vulnerable component exploitation (A06). **Mitigation**: Always pair SAST with at least one DAST tool. The coverage matrix above shows complementary strengths.

### 5.3 "Pre-Commit Secret Scanning Without CI Verification"
Pre-commit hooks can be bypassed with `git commit --no-verify` or by developers not installing hooks. **Mitigation**: Pre-commit is the fast feedback layer, but CI/CD must enforce mandatory secret scanning as a safety net. Both layers are required.

### 5.4 "Running DAST Against Production"
Active DAST scanning (especially ZAP full scan) can cause service disruption, data corruption, or trigger security alerts. **Mitigation**: Always run DAST against staging/dev environments. Use rate limiting. ZAP baseline scan (passive only) is safer for production health checks.

### 5.5 "Ignoring IaC Security Until Deployment"
Dockerfile and Terraform misconfigurations (running as root, public S3 buckets, no encryption) are easier and cheaper to fix at code-write time than after deployment. **Mitigation**: Integrate hadolint/checkov in pre-commit hooks and CI pipeline, treating IaC linting as mandatory as code linting.

---

## Sources

- [Semgrep GitHub](https://github.com/semgrep/semgrep)
- [Bandit GitHub](https://github.com/PyCQA/bandit)
- [CodeQL GitHub](https://github.com/github/codeql)
- [Bearer GitHub](https://github.com/Bearer/bearer)
- [ZAP GitHub](https://github.com/zaproxy/zaproxy)
- [Nikto GitHub](https://github.com/sullo/nikto)
- [Nuclei GitHub](https://github.com/projectdiscovery/nuclei)
- [Gitleaks GitHub](https://github.com/gitleaks/gitleaks)
- [TruffleHog GitHub](https://github.com/trufflesecurity/trufflehog)
- [detect-secrets GitHub](https://github.com/Yelp/detect-secrets)
- [Hadolint GitHub](https://github.com/hadolint/hadolint)
- [Checkov GitHub](https://github.com/bridgecrewio/checkov)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)
- [awesome-appsec](https://github.com/paragonie/awesome-appsec)
- [awesome-security](https://github.com/sbilly/awesome-security)
- [Semgrep CLI Docs](https://semgrep.dev/docs/getting-started/cli)
- [ZAP Docker Guide](https://www.zaproxy.org/docs/docker/about/)
- [AppSec Santa — Open-Source SAST Tools](https://appsecsanta.com/sast-tools/open-source-sast-tools)
- [AppSec Santa — Free DAST Tools](https://appsecsanta.com/dast-tools/free-dast-tools)
