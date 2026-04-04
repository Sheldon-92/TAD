# Compliance — Security Domain Pack Research

> Domain scope: "Can I prove I meet the policy?" — Policy-as-code, audit evidence generation,
> privacy engineering. Does NOT own finding vulnerabilities (that belongs to code-security).

## 1. Tool Landscape

| Tool | Stars | Last Commit | Install | Free | CI/CD | Ecosystems | Compliance Frameworks |
|------|-------|-------------|---------|------|-------|------------|-----------------------|
| OPA (Rego) | 11.5k | Active (2026-04) | `brew install opa` / binary | Yes | Yes (GitHub Action, GitLab) | K8s, Terraform, Envoy, any JSON/YAML | Custom policies (general-purpose engine) |
| conftest | 3.2k | 2026-04-02 (v0.68.0) | `brew install conftest` / binary | Yes | Yes (GitHub Action) | K8s, Terraform, Dockerfile, HCL, TOML, any structured data | Custom OPA/Rego policies |
| Checkov | 8.6k | Active (2026-Q1) | `pip install checkov` | Yes (OSS core) | Yes (native GitHub Action) | Terraform, CloudFormation, K8s, Helm, Dockerfile, ARM, Bicep, Serverless | CIS, SOC2, HIPAA, PCI-DSS, NIST 800-53 |
| Prowler | 13.5k | Active (2026-Q1) | `pip install prowler` / Docker | Yes (OSS core) | Yes | AWS, Azure, GCP, K8s, GitHub, M365, OCI, Alibaba, CloudFlare | CIS, SOC2, HIPAA, PCI-DSS, GDPR, NIST 800/CSF, FedRAMP, ISO 27001, MITRE ATT&CK, ENS (41+ standards) |
| InSpec | 3.1k | Active (2026-03) | `gem install inspec` / Chef pkg | Yes (OSS) | Yes | Any SSH-reachable host, Docker, AWS, Azure, GCP | CIS, custom profiles |
| kube-bench | 8.0k | Active (2026) | `go install` / K8s Job / binary | Yes | Yes (K8s Job/DaemonSet) | Kubernetes (12+ distros: EKS, GKE, AKS, OpenShift, k3s, RKE) | CIS Kubernetes Benchmark (v1.5.1–1.12) |
| docker-bench | 222 | 2025-01 | `go install` / Docker | Yes | Yes | Docker | CIS Docker Benchmark |
| Fides | 450 | 2026-03-31 (v2.82.1) | `pip install ethyca-fides` / Docker Compose | Yes (OSS core) | Partial (CI scanning) | Any application with DB/API data flows | GDPR, CCPA, LGPD (privacy-focused) |

### CLI Usage Examples

**OPA — Policy evaluation**
```bash
# Install
brew install opa

# Evaluate a policy against input data
opa eval -d policy.rego -i input.json "data.authz.allow"

# Test policies
opa test ./policies/ -v

# Format Rego files
opa fmt --write ./policies/
```

**conftest — Structured config policy testing**
```bash
# Install
brew install conftest

# Test Terraform plan against Rego policies
terraform plan -out=plan.tfplan
terraform show -json plan.tfplan > plan.json
conftest test plan.json --policy ./policy/

# Test Kubernetes manifests
conftest test deployment.yaml --policy ./policy/ --output json

# Pull policies from OCI registry
conftest pull oci://registry.example.com/policies:latest
conftest test --update oci://registry.example.com/policies deployment.yaml
```

**Checkov — IaC compliance scanning**
```bash
# Install
pip install checkov

# Scan Terraform directory against CIS AWS
checkov -d . --framework terraform --compliance-framework cis_aws

# Scan with specific framework
checkov -d . --compliance-framework hipaa --output json --output-file-path report.json

# Scan Kubernetes manifests
checkov -d ./k8s/ --framework kubernetes

# Available compliance frameworks: cis_aws, cis_azure, cis_gcp, cis_kubernetes,
# hipaa, pci_dss, soc2, nist_800_53
```

**Prowler — Cloud compliance scanning**
```bash
# Install
pip install prowler

# Scan AWS account against CIS
prowler aws --compliance cis_3.0_aws

# Scan with multiple frameworks
prowler aws --compliance soc2_aws hipaa_aws

# Scan Azure
prowler azure --compliance cis_2.1_azure

# Scan GCP
prowler gcp --compliance cis_2.0_gcp

# JSON output for evidence
prowler aws --compliance soc2_aws --output-formats json-ocsf --output-directory ./evidence/

# 572 AWS checks across 41 compliance standards
```

**InSpec — Infrastructure compliance profiles**
```bash
# Install
gem install inspec

# Run a CIS benchmark profile
inspec exec https://github.com/dev-sec/linux-baseline

# Run against remote host
inspec exec my-profile -t ssh://user@host

# Run against AWS
inspec exec my-aws-profile -t aws://region/profile

# Generate JSON report
inspec exec my-profile --reporter json:report.json
```

**kube-bench — Kubernetes CIS Benchmark**
```bash
# Run as Kubernetes Job (recommended)
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml

# Run as binary on node
kube-bench run --targets master,node,etcd,policies

# JSON output for CI/CD
kube-bench run --json > kube-bench-report.json

# Specific benchmark version
kube-bench run --benchmark cis-1.9
```

**Fides — Privacy engineering**
```bash
# Install (Docker Compose recommended)
pip install ethyca-fides

# Scan codebase for data flows
fides scan resource_type=system

# Evaluate privacy declarations against taxonomy
fides evaluate

# Generate privacy report
fides scan --output-file privacy-report.json
```

### SaaS vs CLI Comparison

| Capability | CLI Tools (OSS) | SaaS-Only (Drata/Vanta) | Gap |
|-----------|-----------------|------------------------|-----|
| IaC policy scanning | Checkov, conftest, OPA | Integrated but same engines | No gap |
| Cloud posture checks | Prowler (572+ checks) | Continuous monitoring + alerts | CLI needs cron/CI for continuous |
| Evidence collection | Manual export (JSON/CSV) | Auto-collected, timestamped, auditor-ready | Significant — CLI lacks audit trail UI |
| Auditor portal | None | Built-in auditor workspace | Total gap — CLI cannot replace |
| Vendor risk management | None | Questionnaire automation | Total gap |
| Employee onboarding compliance | None | HR integration, training tracking | Total gap |
| Policy document management | comply (StrongDM) | Template library + versioning + approval | Partial — comply generates docs, no workflow |
| Integration count | Tool-specific (cloud APIs) | 170–400+ SaaS integrations | Significant for SaaS-heavy orgs |
| Cost | Free | $5,000–$15,000+/yr per framework | CLI wins on cost |
| Customization | Full (write any Rego/InSpec) | Limited to platform capabilities | CLI wins on flexibility |
| Multi-framework pricing | Free (all frameworks) | Drata ~$1,500/framework, Vanta ~$5,000/framework | CLI wins significantly |

> **Key insight**: CLI tools excel at the TECHNICAL PROOF layer (scan, check, report). SaaS platforms
> excel at the ORGANIZATIONAL PROCESS layer (evidence management, auditor workflow, vendor risk).
> A compliance Domain Pack should focus on what CLI can do well — policy scanning, evidence generation,
> and report formatting — and explicitly note where SaaS is required.

## Search Log

| # | Query | Results Used | Date |
|---|-------|-------------|------|
| 1 | OPA rego policy examples CLI 2026 GitHub stars | OPA GitHub (11.5k stars), OPA docs, Gatekeeper info | 2026-04-03 |
| 2 | checkov compliance scanning CLI usage 2026 | Checkov GitHub (8.6k), oneuptime blog, AWS docs | 2026-04-03 |
| 3 | prowler cloud security compliance 2026 multi-framework | Prowler GitHub (13.5k), prowler.com, CIS partnership | 2026-04-03 |
| 4 | conftest policy testing tool GitHub 2026 | Conftest GitHub (3.2k, v0.68.0), conftest.dev | 2026-04-03 |
| 5 | fides privacy engineering tool GitHub stars 2026 | Fides GitHub (450, v2.82.1), ethyca docs | 2026-04-03 |
| 6 | InSpec compliance automation chef GitHub 2026 | InSpec GitHub (3.1k), Chef docs | 2026-04-03 |
| 7 | kube-bench docker-bench-security CIS benchmark CLI 2026 | kube-bench GitHub (8k), CNCF blog, devopscube guide | 2026-04-03 |
| 8 | OWASP SAMM compliance framework 2026 | owaspsamm.org, codific SAMM guidance, CRA context | 2026-04-03 |
| 9 | compliance as code best practices github 2026 | ComplianceAsCode org, awesome-compliance repos, spacelift PaC tools | 2026-04-03 |
| 10 | SOC2 automation CLI tools open source 2026 | comply (StrongDM), CompliSight, Probo | 2026-04-03 |
| 11 | GDPR compliance tools open source CLI 2026 | Privado, GDPR Analyzer, Bearer, Klaro, awesome-gdpr | 2026-04-03 |
| 12 | Drata Vanta compliance SaaS vs open source CLI comparison 2026 | compliancerated.com, Sprinto comparison, G2 comparison | 2026-04-03 |

## 2. Framework Alignment

| Framework | Key Items | Tool Coverage | Gap |
|-----------|----------|--------------|-----|
| OWASP SAMM | Policy & Compliance practice, Governance function | OPA/conftest (policy enforcement), InSpec (verification) | No automated maturity level assessment tool; manual scoring needed |
| CIS Benchmarks | AWS, Azure, GCP, K8s, Docker benchmarks | Prowler (41+ standards), kube-bench (K8s), docker-bench, Checkov (IaC) | Strong coverage — this is the best-covered area |
| SOC2 | Trust Service Criteria (Security, Availability, Processing Integrity, Confidentiality, Privacy) | Prowler (soc2_aws mapping), Checkov (soc2 framework), comply (doc generation) | Evidence collection gap — CLI generates point-in-time reports, not continuous evidence |
| HIPAA | Security Rule, Privacy Rule, Breach Notification | Prowler (hipaa_aws), Checkov (hipaa framework), Fides (data flow mapping) | Privacy Rule requires organizational processes — no CLI tool covers admin safeguards |
| GDPR | Data mapping, consent, DSAR, DPIAs | Fides (data flow scanning, DSAR orchestration), Privado (code-level data flow), Bearer (code scanning) | Consent management (Klaro/TarteAuCitron) is frontend, not CLI. DPIA is manual. |
| PCI-DSS | 12 requirement categories, network segmentation, encryption | Prowler (pci_dss mapping), Checkov (pci_dss framework) | Requirement 9 (physical access) and Requirement 12 (policies) have zero CLI coverage |
| ASVS 4.0.3 | V1 Architecture (policy enforcement) | OPA (runtime policy), conftest (build-time policy) | ASVS is app-security focused; compliance overlap is only V1 policy controls |
| NIST 800-53 | 20 control families, 1000+ controls | Prowler (nist_800_53), Checkov (nist_800_53), InSpec (STIG profiles) | Best automated coverage after CIS. Some control families (PE, PS) require manual processes |
| ISO 27001 | Annex A controls (93 controls in 2022 revision) | Prowler (iso27001), InSpec (custom profiles) | ISO requires management system evidence (policies, reviews) beyond technical scans |
| FedRAMP | Based on NIST 800-53 + additional requirements | Prowler (fedramp_low/moderate/high) | 3PAO assessment and continuous monitoring portal (OMB MAX) not covered |

### Cloud Provider Variants

> **Important**: Compliance requirements differ by cloud provider. The following tools have provider-specific frameworks:

| Provider | Prowler | Checkov | kube-bench | InSpec |
|----------|---------|---------|------------|--------|
| AWS | cis_3.0_aws, soc2_aws, hipaa_aws, pci_dss_aws, nist_800_53_aws | cis_aws | EKS-specific benchmarks | inspec-aws resource pack |
| Azure | cis_2.1_azure, nist_800_53_azure | cis_azure | AKS-specific benchmarks | inspec-azure resource pack |
| GCP | cis_2.0_gcp | cis_gcp | GKE-specific benchmarks | inspec-gcp resource pack |
| Kubernetes | cis_kubernetes | cis_kubernetes | All K8s distros (12+) | N/A (SSH-based) |

## 3. Best Practices (from GitHub repos)

### 1. ComplianceAsCode/content (GitHub: ComplianceAsCode org)
- SCAP Security Guide with machine-readable compliance content
- Covers RHEL, Ubuntu, Fedora, CentOS — maps to NIST, CIS, PCI-DSS
- **Pattern**: Compliance rules stored as structured data (YAML/XML), rendered into multiple output formats (SCAP, Ansible, Bash)
- **Takeaway**: Separate policy definition from enforcement mechanism

### 2. strongdm/comply (GitHub: 344 stars)
- SOC2-focused compliance framework with document pipeline
- `comply init` scaffolds policies, `comply build` generates auditor-friendly PDFs
- Integrates with Jira/GitHub Issues for procedure ticket tracking
- **Pattern**: Compliance-as-code for DOCUMENTS, not just scans — policies are markdown, built into publishable formats
- **Takeaway**: Evidence generation includes policy documentation, not just scan results

### 3. getprobo/probo (GitHub: recently launched)
- Open-source alternative to Vanta/Drata for SOC2, GDPR, ISO 27001
- Self-hosted GRC platform with control mapping and evidence collection
- **Pattern**: Bridges the gap between CLI scan tools and SaaS platforms by providing an open-source evidence management layer
- **Takeaway**: The missing middle ground — an open-source evidence aggregation layer that consumes CLI tool outputs

## 4. Capability Design Recommendations

### Capability 1: `policy_audit` (Type A — Document/Research)

**Purpose**: Evaluate organizational compliance posture against a target framework.

**Steps**:
1. `select_framework` — User specifies target framework (CIS, SOC2, HIPAA, PCI-DSS, GDPR, NIST, ISO 27001)
2. `scan_infrastructure` — Run appropriate tools (Prowler for cloud, Checkov for IaC, kube-bench for K8s)
3. `map_controls` — Map scan findings to framework control IDs
4. `identify_gaps` — Analyze which controls have no automated coverage and require manual evidence
5. `generate_report` — Produce gap analysis report with pass/fail/manual-required per control

**tool_ref**: prowler, checkov, kube-bench, inspec
**quality_criteria**:
- Every control in the target framework must be classified as pass, fail, or manual-required
- Report must include framework version and scan timestamp
- Cloud-provider-specific variant must be used (e.g., cis_3.0_aws not generic cis)

### Capability 2: `iac_compliance_scan` (Type B — Code/Tool)

**Purpose**: Scan infrastructure-as-code for compliance violations before deployment.

**Steps**:
1. `detect_iac_type` — Identify IaC framework (Terraform, CloudFormation, K8s manifests, Helm, Dockerfile)
2. `select_policies` — Choose compliance framework(s) to scan against
3. `execute_scan` — Run Checkov or conftest with appropriate framework flags
4. `classify_findings` — Separate critical (blocking) from advisory findings
5. `generate_fix_suggestions` — For each violation, provide remediation code snippet

**tool_ref**: checkov, conftest, opa
**quality_criteria**:
- Zero false-positive tolerance for blocking findings — must verify each maps to a real control
- Output must be CI/CD compatible (JSON or JUnit XML)
- Must support `.checkov.yml` or conftest policy directory for custom rules

### Capability 3: `privacy_assessment` (Type A — Document/Research)

**Purpose**: Map data flows and assess privacy regulation compliance (GDPR, CCPA, LGPD).

**Steps**:
1. `scan_data_flows` — Use Fides or Privado to scan codebase for personal data processing
2. `classify_data_categories` — Map discovered data to privacy taxonomy (PII, sensitive, special category)
3. `assess_legal_basis` — For each data flow, verify legal basis documentation exists
4. `check_cross_border` — Flag data transfers that cross jurisdictional boundaries
5. `generate_ropa` — Produce Record of Processing Activities (GDPR Art. 30 requirement)

**tool_ref**: fides, privado (CLI)
**quality_criteria**:
- Must discover data flows in code, not rely on manual declarations alone
- ROPA output must include: purpose, legal basis, data categories, recipients, retention period
- Cross-border transfers must be flagged with applicable transfer mechanism (SCCs, adequacy)

### Capability 4: `cloud_compliance_check` (Type B — Code/Tool)

**Purpose**: Continuous compliance checking of live cloud environments.

**Steps**:
1. `authenticate_cloud` — Verify cloud credentials and permissions for scanning
2. `select_standards` — Choose compliance standards (can run multiple simultaneously)
3. `execute_prowler` — Run Prowler with selected standards against target cloud account
4. `prioritize_by_threatscore` — Use Prowler's ThreatScore to rank findings by risk
5. `export_evidence` — Generate JSON-OCSF formatted evidence files with timestamps
6. `compare_baseline` — Diff against previous scan to show compliance drift

**tool_ref**: prowler
**quality_criteria**:
- Must use cloud-provider-specific compliance framework variant (not generic)
- Evidence files must include scan timestamp, account ID, and framework version
- Baseline comparison must detect both new failures and newly passing controls

### Capability 5: `evidence_generation` (Type A — Document/Research)

**Purpose**: Aggregate compliance scan results into auditor-ready evidence packages.

**Steps**:
1. `collect_scan_outputs` — Gather JSON outputs from all compliance tools (Prowler, Checkov, kube-bench, InSpec)
2. `normalize_format` — Convert all outputs to a common schema (OCSF or custom)
3. `map_to_controls` — Cross-reference each finding to specific framework control IDs
4. `generate_evidence_package` — Create timestamped evidence bundle with metadata
5. `produce_executive_summary` — Generate human-readable summary with pass rates per control family

**tool_ref**: prowler (JSON-OCSF output), checkov, comply (document generation)
**quality_criteria**:
- Evidence must be timestamped and immutable (append-only)
- Each evidence item must trace to exactly one framework control
- Executive summary must include: overall pass rate, critical failures count, manual-required count
- **Limitation note**: This produces point-in-time evidence. Continuous evidence collection requires SaaS (Drata/Vanta) or self-hosted Probo

## 5. Anti-Patterns & Pitfalls

### Anti-Pattern 1: "Scan and Ship" — Running compliance scans without mapping to controls
**Problem**: Teams run `checkov -d .` or `prowler aws` and treat raw output as compliance evidence. Auditors need findings mapped to specific control IDs (e.g., "SOC2 CC6.1"), not a list of 500 check results.
**Fix**: Always use `--compliance-framework` flag and map each finding to the control it satisfies. Evidence without control mapping is noise, not proof.

### Anti-Pattern 2: "One Cloud Fits All" — Using generic compliance checks across providers
**Problem**: Running `cis_aws` checks against an Azure environment, or using a generic Kubernetes benchmark instead of the EKS/AKS/GKE-specific variant. Each cloud provider has unique services and configurations that require provider-specific benchmarks.
**Fix**: Always select the cloud-provider-specific compliance variant. Prowler and Checkov both support provider-specific frameworks. kube-bench auto-detects K8s distribution but verify the benchmark version matches your cluster.

### Anti-Pattern 3: "Policy Without Process" — Assuming CLI scans equal compliance
**Problem**: Compliance requires both TECHNICAL controls (what CLI tools check) and ORGANIZATIONAL controls (policies, training, incident response procedures). Tools like Prowler cover ~60% of SOC2 controls; the remaining ~40% are process-based and cannot be automated by CLI.
**Fix**: The Domain Pack must clearly delineate which controls are automated vs. manual-required. Generate a "manual evidence checklist" alongside scan results so teams know what still needs human attestation.

### Anti-Pattern 4: "Stale Evidence" — Point-in-time scans treated as continuous compliance
**Problem**: A passing Prowler scan from January does not prove compliance in March. Auditors increasingly require evidence of CONTINUOUS compliance, not periodic snapshots.
**Fix**: Schedule regular scans (daily or weekly) via CI/CD, retain historical results, and implement baseline comparison to detect compliance drift. Note: for true continuous monitoring, SaaS platforms (Drata/Vanta) or self-hosted solutions (Probo) are more appropriate.

### Anti-Pattern 5: "Privacy by Checkbox" — Treating GDPR/CCPA as a scanning problem
**Problem**: Teams install Fides or Privado and assume automated data flow scanning covers privacy compliance. GDPR requires Data Protection Impact Assessments (DPIAs), consent management, and Data Subject Access Request (DSAR) processes that cannot be fully automated by CLI.
**Fix**: Use code-level scanning (Fides, Privado) as one input to privacy compliance, but explicitly document the manual requirements: DPIAs for high-risk processing, consent UX implementation, DSAR response workflows, and DPO appointment where required.
