# Security Tool Evaluation Matrix — Cross-Domain Comparison

**Date**: 2026-04-03
**Purpose**: Consolidated view of all security tools across 5 domain packs for tool selection and overlap analysis.

---

## 1. Master Tool Inventory

| # | Tool | Domain | Stars | Install | Free | CI/CD | Ecosystems / Targets | Category |
|---|------|--------|-------|---------|------|-------|---------------------|----------|
| 1 | osv-scanner | Supply Chain | ~8.6k | `go install` / brew | Yes | GitHub Action | multi (11+ langs: npm, pip, cargo, go, maven, nuget, gem) | CVE Scanner |
| 2 | pip-audit | Supply Chain | ~1.2k | `pip install pip-audit` | Yes | GitHub Action | pip (Python) | CVE Scanner |
| 3 | cargo-audit | Supply Chain | ~1.9k | `cargo install cargo-audit` | Yes | GitHub Action | cargo (Rust) | CVE Scanner |
| 4 | socket CLI | Supply Chain | unverified | `npm install -g @socketsecurity/cli` | Free OSS | GitHub App | multi (npm, PyPI, Go, Maven, Ruby, Cargo, NuGet) | Behavioral Analysis |
| 5 | OSSF Scorecard | Supply Chain | ~5.3k | `go install` | Yes | GitHub Action | any GitHub repo | Trust Scoring |
| 6 | syft | Supply Chain + Monitoring | ~8.4k | `brew install syft` | Yes | GitHub Action | multi (Alpine, Debian, Go, Python, Java, JS, Ruby, Rust) | SBOM Generation |
| 7 | npm audit | Supply Chain | built-in | Ships with npm | Yes | native | npm (Node.js) | CVE Scanner |
| 8 | lockfile-lint | Supply Chain | unverified | `npm install -g lockfile-lint` | Yes | pre-commit | npm, yarn | Lockfile Integrity |
| 9 | cargo-vet | Supply Chain | unverified | `cargo install cargo-vet` | Yes | CI | cargo (Rust) | Audit Trail |
| 10 | cosign (sigstore) | Supply Chain | unverified | `go install` | Yes | GitHub Action | multi (OCI images, npm provenance) | Provenance Verification |
| 11 | typosquatting CLI | Supply Chain | unverified | `gem install typosquatting` | Yes | CLI | multi (PyPI, npm, RubyGems, Cargo, Go, Maven) | Typosquat Detection |
| 12 | dep-scan (OWASP) | Supply Chain | unverified | `pip install owasp-depscan` | Yes | CI | multi (Python, JS, Java, Go, Rust, PHP, .NET) | SCA + Deep Risk |
| 13 | semgrep | Code Security | 14.3k | `brew install semgrep` | CE free | GitHub Actions | 30+ languages | SAST |
| 14 | bandit | Code Security | 7.8k | `pip install bandit` | Yes | GitHub Actions | Python only | SAST |
| 15 | codeql | Code Security | 8.2k | `gh extension install` | Free public | GitHub Actions | C/C++, C#, Go, Java, JS/TS, Python, Ruby, Swift, Kotlin | SAST (Deep) |
| 16 | bearer CLI | Code Security | unverified | `brew install bearer/tap/bearer` | Yes | GitHub Actions | Ruby, JS/TS, Java, Go, PHP, Python | SAST (Data-flow) |
| 17 | ZAP (OWASP) | Code Security | 14.9k | `brew install zaproxy` / Docker | Yes | GitHub Actions | HTTP (language-agnostic) | DAST |
| 18 | nikto | Code Security | 10.2k | `apt install nikto` / Docker | Yes | Script-based | HTTP (language-agnostic) | DAST |
| 19 | nuclei | Code Security + Monitoring | 26.9k | `brew install nuclei` | Yes (MIT) | GitHub Actions | multi-protocol (HTTP, DNS, network) | DAST (Template) |
| 20 | gitleaks | Code Security | 25.8k | `brew install gitleaks` | Yes | GitHub Actions, pre-commit | language-agnostic (regex) | Secrets |
| 21 | trufflehog | Code Security | 24.5k | `brew install trufflehog` | Yes (AGPL) | GitHub Actions | 800+ secret types | Secrets (Verified) |
| 22 | detect-secrets | Code Security | 4.3k | `pip install detect-secrets` | Yes | pre-commit, CI | language-agnostic (baseline) | Secrets (Baseline) |
| 23 | hadolint | Code Security | 11.9k | `brew install hadolint` | Yes | GitHub Actions | Dockerfile + inline bash | IaC Linting |
| 24 | checkov | Code Security + Compliance | 8.6k | `pip install checkov` | Yes | GitHub Actions | Terraform, K8s, Docker, CloudFormation, ARM, Bicep | IaC Compliance |
| 25 | garak | AI Security | 7.3k | `pip install garak` | Yes (Apache) | JSON report | LLM APIs, local models | LLM Red-Teaming |
| 26 | promptfoo | AI Security | 17.6k | `npx promptfoo@latest` | Yes (MIT) | `--ci` flag, GitHub Action | LLM APIs | Red-Team + Eval |
| 27 | PyRIT | AI Security | 3.4k | `pip install pyrit` | Yes (MIT) | Framework/script | LLM APIs | Multi-turn Red-Team |
| 28 | NeMo Guardrails | AI Security | 5.9k | `pip install nemoguardrails` | Yes (Apache) | Server mode | LLM APIs | Runtime Guardrails |
| 29 | LLM Guard | AI Security | 2.5k | `pip install llm-guard` | Yes (MIT) | HTTP API | LLM I/O | Input/Output Scanning |
| 30 | OPA (Rego) | Compliance | 11.5k | `brew install opa` | Yes | GitHub Action | K8s, Terraform, any JSON/YAML | Policy Engine |
| 31 | conftest | Compliance | 3.2k | `brew install conftest` | Yes | GitHub Action | K8s, Terraform, Dockerfile, HCL, TOML | Policy Testing |
| 32 | prowler | Compliance | 13.5k | `pip install prowler` | Yes | Yes | AWS, Azure, GCP, K8s, GitHub, M365 | Cloud Compliance |
| 33 | InSpec | Compliance | 3.1k | `gem install inspec` | Yes | Yes | SSH-reachable hosts, Docker, AWS, Azure, GCP | Compliance-as-Code |
| 34 | kube-bench | Compliance | 8.0k | `go install` / K8s Job | Yes | K8s Job | Kubernetes (12+ distros) | CIS K8s Benchmark |
| 35 | docker-bench | Compliance | 222 | `go install` / Docker | Yes | Yes | Docker | CIS Docker Benchmark |
| 36 | fides | Compliance | 450 | `pip install ethyca-fides` | Yes | Partial | DB/API data flows | Privacy Engineering |
| 37 | trivy | Monitoring | 32.2k | `brew install trivy` | Yes (Apache) | GitHub Action, Jenkins | containers, filesystem, IaC, SBOM, secrets, K8s | Swiss-Army Scanner |
| 38 | grype | Monitoring | 11.5k | `brew install grype` | Yes (Apache) | GitHub Action | containers, filesystem, SBOM | CVE Scanner (Fast) |
| 39 | renovate | Monitoring | 20.7k | GitHub App / `npx renovate` | Yes (AGPL) | Native App | 90+ package managers | Update Automation |
| 40 | cdxgen | Monitoring | 839 | `npm i -g @cyclonedx/cdxgen` | Yes (Apache) | CLI | multi-language, containers | SBOM Generation |

**Total**: 40 unique tools across 5 security domains.

---

## 2. Cross-Domain Tool Overlap

Some tools appear in multiple domains. This is intentional — they serve different purposes in each context.

| Tool | Primary Domain | Also Used In | Role Difference |
|------|---------------|-------------|-----------------|
| nuclei | Code Security (DAST) | Monitoring (network vuln scan) | Code: find web app vulns. Monitoring: scan network services for known CVEs. |
| checkov | Compliance (IaC compliance) | Code Security (IaC linting) | Compliance: prove policy adherence. Code Security: find misconfigurations. |
| syft | Supply Chain (SBOM gen) | Monitoring (SBOM inventory) | Supply Chain: pre-install inventory. Monitoring: post-install inventory. |
| trivy | Monitoring (primary) | Code Security (IaC), Supply Chain (SBOM) | Monitoring: continuous CVE scanning. Others: secondary use. |

---

## 3. Ecosystem Coverage Matrix

| Ecosystem | Supply Chain | Code Security | AI Security | Compliance | Monitoring |
|-----------|-------------|---------------|-------------|------------|------------|
| **npm/JS** | osv-scanner, socket CLI, npm audit, lockfile-lint | semgrep, codeql, bearer, gitleaks, trufflehog | promptfoo | conftest, checkov | trivy, grype, renovate, cdxgen |
| **Python/pip** | osv-scanner, pip-audit, socket CLI, dep-scan | semgrep, bandit, codeql, bearer, gitleaks, trufflehog | garak, PyRIT, NeMo, LLM Guard | checkov, prowler, fides | trivy, grype, renovate, cdxgen |
| **Rust/cargo** | osv-scanner, cargo-audit, cargo-vet, socket CLI | semgrep, gitleaks, trufflehog | — | — | trivy, grype, renovate |
| **Go** | osv-scanner, socket CLI | semgrep, codeql, bearer, gitleaks, trufflehog | — | OPA, conftest, kube-bench | trivy, grype, renovate |
| **Java/Maven** | osv-scanner, socket CLI, dep-scan | semgrep, codeql, gitleaks, trufflehog | — | checkov | trivy, grype, renovate, cdxgen |
| **Ruby** | osv-scanner, socket CLI | semgrep, codeql, bearer, gitleaks, trufflehog | — | InSpec | trivy, grype, renovate |
| **Docker** | — | hadolint, ZAP, nuclei | — | checkov, docker-bench, kube-bench | trivy, grype |
| **Terraform** | — | checkov | — | checkov, conftest, OPA | trivy (config) |
| **K8s** | — | checkov | — | kube-bench, conftest, OPA, prowler | trivy (K8s cluster) |
| **Cloud (AWS/Azure/GCP)** | — | — | — | prowler, InSpec, checkov | — |

---

## 4. Framework Coverage Summary

| Framework | Supply Chain | Code Security | AI Security | Compliance | Monitoring |
|-----------|-------------|---------------|-------------|------------|------------|
| OWASP Top 10 (2021/2025) | A03/A06 | A01-A10 (partial) | — | — | A05, A06 |
| OWASP LLM Top 10 (2025) | — | — | LLM01-LLM10 (7/10 partial+) | — | — |
| ASVS 4.0.3 | V14.2 | V1-V14 (partial) | — | V1 | V14.1, V14.2 |
| NIST SSDF | PO.1, PS.1, PW.4, RV.1 | — | — | — | — |
| NIST AI RMF | — | — | Map, Measure, Manage | — | — |
| NIST 800-53 | — | — | — | 20 control families | — |
| NIST CSF 2.0 | — | — | — | — | DE.CM, ID.AM, RS.MI |
| SLSA | Level 1-3 | — | — | — | — |
| MITRE ATT&CK | — | — | — | — | T1595, T1190 |
| MITRE ATLAS | — | — | 6 tactic categories | — | — |
| CIS Benchmarks | — | — | — | AWS, Azure, GCP, K8s, Docker | — |
| SOC2 | — | — | — | Trust Service Criteria | — |
| HIPAA | — | — | — | Security Rule (partial) | — |
| PCI-DSS | — | — | — | 12 requirements (partial) | — |
| GDPR | — | — | — | Data flow mapping | — |
| CWE Top 25 | CWE-1395, 1104, 1357 | ~18/25 via SAST | — | — | CWE-1104, 937 |

---

## 5. Install Method Distribution

| Method | Tool Count | Tools |
|--------|-----------|-------|
| brew | 16 | osv-scanner, syft, semgrep, gitleaks, trufflehog, hadolint, ZAP, nuclei, OPA, conftest, trivy, grype, bearer, checkov (pip preferred), kube-bench, cdxgen |
| pip | 14 | pip-audit, bandit, detect-secrets, garak, PyRIT, NeMo Guardrails, LLM Guard, checkov, prowler, fides, dep-scan, owasp-depscan, trivy (brew preferred), semgrep |
| npm | 5 | socket CLI, lockfile-lint, promptfoo, renovate, cdxgen |
| go install | 5 | osv-scanner, OSSF Scorecard, cosign, nuclei, kube-bench |
| cargo | 2 | cargo-audit, cargo-vet |
| gem | 2 | InSpec, typosquatting |
| Docker | 6 | ZAP, nikto, docker-bench, fides, renovate, kube-bench |
| built-in | 1 | npm audit |
| gh extension | 1 | codeql |

---

## 6. Tool Priority Ranking by Domain

### Supply Chain Security (Pre-install)
1. **osv-scanner** — Multi-ecosystem CVE baseline (Google-backed)
2. **socket CLI** — Behavioral analysis (only litellm-class attack detector)
3. **cosign/sigstore** — Provenance verification
4. **lockfile-lint** — Lock file integrity (npm/yarn)
5. **OSSF Scorecard** — Evidence-based trust scoring

### Code Security (Find vulnerabilities)
1. **semgrep** — Multi-language SAST, 2000+ free rules
2. **gitleaks** — Fast secret detection, pre-commit
3. **ZAP** — Comprehensive DAST
4. **trufflehog** — Deep secret scanning with verification
5. **hadolint + checkov** — IaC security linting

### AI Security (LLM safety)
1. **promptfoo** — Most versatile (red-team + eval + CI), OWASP/NIST presets
2. **garak** — Deepest vulnerability scanning (100+ probes)
3. **LLM Guard** — Runtime input/output scanning
4. **NeMo Guardrails** — Runtime guardrails with evaluate CLI
5. **PyRIT** — Multi-turn orchestrated attacks (framework, not CLI)

### Compliance (Prove policy adherence)
1. **prowler** — Cloud compliance leader (41+ standards, 572+ checks)
2. **checkov** — IaC compliance scanning
3. **OPA/conftest** — Custom policy-as-code
4. **kube-bench** — CIS Kubernetes benchmark
5. **InSpec** — Infrastructure compliance profiles

### Security Monitoring (Post-install safety)
1. **trivy** — Swiss-army scanner (32k stars, broadest coverage)
2. **renovate** — Automated dependency updates (90+ package managers)
3. **grype** — Fast CVE scanning with EPSS prioritization
4. **cdxgen** — Multi-ecosystem SBOM generation
5. **nuclei** — Network/service vulnerability scanning (9000+ templates)

---

## 7. Capability Count by Domain

| Domain | Capabilities Designed | Type A (Doc) | Type B (Tool) | Total Steps |
|--------|----------------------|-------------|---------------|-------------|
| Supply Chain | 5 | 0 | 5 | 21 |
| Code Security | 5 | 1 | 4 | 25 |
| AI Security | 5 | 1 | 4 | 25 |
| Compliance | 5 | 2 | 3 | 25 |
| Monitoring | 5 | 1 | 4 | 26 |
| **Total** | **25** | **5** | **20** | **122** |

---

## 8. Known Gaps Across All Domains

| Gap Category | Description | Affected Domains |
|-------------|-------------|-----------------|
| Zero-day supply chain attacks | CVE scanners blind to behavioral attacks without CVE | Supply Chain, Monitoring |
| Business logic security | No tool can test application-specific business logic | Code Security |
| LLM training data poisoning | No CLI tool for training-time security | AI Security |
| Vector/embedding attacks | No mature CLI tooling for embedding security | AI Security |
| Organizational compliance | HR, vendor management, physical access controls | Compliance |
| Runtime behavioral detection | EDR/SIEM territory, not CLI scanner scope | Monitoring |
| Model theft prevention | Infrastructure-level concern, not CLI-addressable | AI Security |
| Consent management | Frontend UI concern (cookie banners, preference centers) | Compliance |
