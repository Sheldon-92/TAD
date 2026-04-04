# Supply Chain Security — Security Domain Pack Research

> Domain Scope: "Should I trust this dependency?" — Pre-install analysis: behavioral, provenance,
> typosquat, lock file integrity. Does NOT own post-install CVE monitoring (that's security-monitoring).
>
> Research date: 2026-04-03

---

## 1. Tool Landscape

| Tool | Stars | Last Commit | Install | Free | CI/CD | Ecosystems |
|------|-------|-------------|---------|------|-------|------------|
| osv-scanner | ~8.6k | Active (2026) | `go install github.com/google/osv-scanner/v2/cmd/osv-scanner@latest` | Yes | GitHub Action | multi (11+ langs: npm, pip, cargo, go, maven, nuget, gem, composer, etc.) |
| pip-audit | ~1.2k | Active (2026) | `pip install pip-audit` | Yes | GitHub Action | pip (Python) |
| cargo-audit | ~1.9k (rustsec mono) | Active (2026) | `cargo install cargo-audit --locked` | Yes | GitHub Action | cargo (Rust) |
| socket CLI | unverified | Active (2026) | `npm install -g @socketsecurity/cli` | Free for OSS | GitHub App + CLI | multi (npm, PyPI, Go, Maven, Ruby, Cargo, NuGet — 10+ ecosystems) |
| OSSF Scorecard | ~5.3k | Active (2026) | `go install github.com/ossf/scorecard/v2@latest` | Yes | GitHub Action | multi (scores any GitHub repo) |
| syft | ~8.4k | Active (v1.42.0, Feb 2026) | `brew install syft` or curl installer | Yes | GitHub Action | multi (Alpine, Debian, RPM, Go, Python, Java, JS, Ruby, Rust, PHP, .NET) |
| npm audit | built-in | n/a | Ships with npm | Yes | native | npm (Node.js) |
| lockfile-lint | unverified | Active | `npm install -g lockfile-lint` | Yes | Pre-commit hook | npm, yarn |
| cargo-vet | unverified | Active | `cargo install cargo-vet` | Yes | CI integration | cargo (Rust) |
| cosign (sigstore) | unverified | Active (2026) | `go install github.com/sigstore/cosign/v3/cmd/cosign@latest` | Yes | GitHub Action | multi (OCI images, npm provenance, Homebrew provenance) |
| typosquatting | unverified | Active | `gem install typosquatting` (Ruby CLI) | Yes | CLI | multi (PyPI, npm, RubyGems, Cargo, Go, Maven, NuGet, Composer) |
| dep-scan (OWASP) | unverified | Active (NGI grant through 2026) | `pip install owasp-depscan` | Yes | CI native | multi (Python, JS, Java, Go, Rust, PHP, .NET) |

### CLI Usage Examples

#### osv-scanner
```bash
# Install
go install github.com/google/osv-scanner/v2/cmd/osv-scanner@latest
# Scan a project directory
osv-scanner -r /path/to/project
# Scan a lockfile directly
osv-scanner --lockfile=package-lock.json
# Scan an SBOM
osv-scanner --sbom=sbom.spdx.json
# Output: JSON with vulnerability IDs, severity, affected versions, fix versions
```

#### pip-audit
```bash
# Install
pip install pip-audit
# Scan current environment
pip-audit
# Scan requirements file
pip-audit -r requirements.txt
# JSON output for CI
pip-audit --format json -o vulnerabilities.json
# Auto-fix
pip-audit --fix
```

#### cargo-audit
```bash
# Install
cargo install cargo-audit --locked
# Run audit
cargo audit
# Auto-fix vulnerable deps
cargo audit fix
# Audit compiled binaries
cargo audit bin ./target/release/myapp
```

#### socket CLI
```bash
# Install
npm install -g @socketsecurity/cli
# Wrap npm to intercept installs
socket wrapper on
# Now regular npm install is protected
npm install some-package  # socket checks before install
# Create a scan report
socket scan create --repo .
```

#### OSSF Scorecard
```bash
# Install
go install github.com/ossf/scorecard/v2@latest
# Score a repository
scorecard --repo=github.com/owner/repo
# Output: scores 0-10 for checks like Branch-Protection, Code-Review, Vulnerabilities
```

#### syft (SBOM generation)
```bash
# Install
brew install syft
# Generate SBOM from directory
syft dir:/path/to/project -o spdx-json > sbom.spdx.json
# Generate SBOM from container image
syft alpine:latest -o cyclonedx-json > sbom.cdx.json
```

#### lockfile-lint
```bash
# Install
npm install -g lockfile-lint
# Lint package-lock.json
lockfile-lint --path package-lock.json --type npm --allowed-hosts npm --validate-https
# Validate integrity hashes exist
lockfile-lint --path package-lock.json --type npm --validate-integrity
```

#### cosign (sigstore)
```bash
# Install
go install github.com/sigstore/cosign/v3/cmd/cosign@latest
# Sign a container image (keyless)
cosign sign myregistry.io/myimage:latest
# Verify a signed image
cosign verify myregistry.io/myimage:latest \
  --certificate-identity=name@example.com \
  --certificate-oidc-issuer=https://accounts.example.com
# Verify npm provenance attestation
cosign verify-attestation --type slsaprovenance <artifact>
```

#### cargo-vet
```bash
# Install
cargo install cargo-vet
# Initialize for a project
cargo vet init
# Check all dependencies against audits
cargo vet
# Record an audit for a crate
cargo vet certify crate-name 1.0.0
```

#### dep-scan (OWASP)
```bash
# Install
pip install owasp-depscan
# Scan project
depscan --src $PWD --reports-dir $PWD/reports
# Deep risk audit (dependency confusion)
depscan --src $PWD --deep
```

#### typosquatting detection
```bash
# Install (andrew/typosquatting)
gem install typosquatting
# Check a package name for typosquat risk
typosquatting check express --ecosystem npm
# Scan an SBOM for typosquat candidates
typosquatting scan --sbom sbom.spdx.json
```

### litellm-class Attack Coverage Matrix

> Reference incident: litellm 1.82.7/1.82.8 PyPI poisoning (2026-03-24) — trusted-package-hijack
> Reference incident: axios npm supply chain compromise (2026-03-31) — compromised maintainer account

| Attack Vector | Tool Coverage | Gap |
|--------------|--------------|-----|
| Behavioral diff between versions | socket CLI (flagged axios malware in 6 min), dep-scan (deep audit) | osv-scanner/pip-audit only check known CVEs — zero-day behavioral changes are invisible |
| Publisher provenance verification | cosign (verify attestations, npm provenance), OSSF Scorecard (checks maintainer trust signals) | No tool automatically verifies "was this upload by the expected human?" for PyPI — cosign only works if publisher opted into sigstore |
| Lock file hash integrity | lockfile-lint (validates sha512 hashes, HTTPS-only hosts), npm audit (checks integrity field) | lockfile-lint is npm/yarn only — no equivalent for pip (requirements.txt has no hashes by default) or Cargo.lock |
| Typosquatting detection | typosquatting CLI (multi-ecosystem), socket CLI (built-in typosquat detection), dep-scan (dependency confusion audit) | Most tools detect name similarity but NOT semantic clones (same name, different registry) |
| Compromised maintainer account | OSSF Scorecard (checks 2FA, branch protection), socket CLI (behavioral anomaly) | No tool can detect a legitimate maintainer whose credentials are stolen — this is the hardest vector |
| Version pinning bypass | lockfile-lint (validates lockfile present), cargo-vet (audit trail per version) | pip requirements without `==` pinning are undetectable by static tools |

---

## Search Log

| # | Query | Results Used | Date |
|---|-------|-------------|------|
| 1 | osv-scanner GitHub stars 2026 CLI install supply chain security | GitHub repo, Google docs, LFX Insights | 2026-04-03 |
| 2 | socket CLI npm supply chain security behavioral analysis 2026 | Socket docs, AppSec Santa review, Axios incident reports | 2026-04-03 |
| 3 | OSSF Scorecard CLI GitHub stars install 2026 | GitHub repo, securityscorecards.dev, v6 roadmap PR | 2026-04-03 |
| 4 | sigstore cosign CLI supply chain provenance verification 2026 | Sigstore docs, GitGuardian blog, cosign verify docs | 2026-04-03 |
| 5 | pip-audit cargo-audit npm audit CLI usage supply chain 2026 | npm docs, DevSecOpsNow pip-audit guide, DZone article | 2026-04-03 |
| 6 | syft SBOM generator CLI anchore GitHub 2026 install | GitHub repo, AppSec Santa review, Anchore docs | 2026-04-03 |
| 7 | lockfile-lint npm CLI lock file integrity verification | npm page, GitHub repo, README | 2026-04-03 |
| 8 | cargo-vet Mozilla supply chain trust CLI 2026 | GitHub repo, Mozilla docs, cargo-vet book | 2026-04-03 |
| 9 | OWASP dep-scan depscan CLI supply chain security 2026 | OWASP project page, GitHub repo, ReadTheDocs | 2026-04-03 |
| 10 | typosquat detection tool CLI pypi npm 2026 | andrew/typosquatting, MUAD'DIB, pypi-scan, ecosyste-ms dataset | 2026-04-03 |
| 11 | NIST SSDF supply chain security framework practices 2026 | NIST SP 800-218 Rev 1 draft, CISA guidance, Aikido explainer | 2026-04-03 |
| 12 | SLSA framework levels supply chain security 2026 | slsa.dev, Practical DevSecOps guide, Cloudsmith 2026 guide | 2026-04-03 |
| 13 | CWE supply chain software dependency vulnerability categories | CWE-1395, CWE-1104, CWE-1357, OWASP Top 10 2025 A03 | 2026-04-03 |
| 14 | supply chain security best practices GitHub repository 2026 awesome | bureado/awesome-software-supply-chain-security, GitHub Docs, GitHub Actions 2026 roadmap | 2026-04-03 |
| 15 | osv-scanner GitHub stars count 2026 | LFX Insights (~8.6k) | 2026-04-03 |
| 16 | socket dev CLI install command "socket npm" behavioral diff | Socket docs, npm page | 2026-04-03 |
| 17 | cargo-audit GitHub stars install CLI rustsec 2026 | rustsec/rustsec GitHub, lib.rs | 2026-04-03 |
| 18 | pip-audit pypa GitHub stars 2026 | pypa/pip-audit GitHub (~1.2k) | 2026-04-03 |
| 19 | cosign install CLI command "cosign verify" sigstore 2026 | Sigstore docs, Chainguard Academy | 2026-04-03 |

---

## 2. Framework Alignment

| Framework | Item | Tool Coverage | Gap |
|-----------|------|--------------|-----|
| NIST SSDF | PO.1 Define Security Requirements | OSSF Scorecard (security posture baseline), lockfile-lint (policy enforcement) | No tool auto-generates security requirements from project type |
| NIST SSDF | PS.1 Protect Software (3rd-party intake) | osv-scanner, pip-audit, cargo-audit, npm audit (vulnerability scanning), socket CLI (behavioral analysis) | SSDF 1.2 draft adds AI-specific practices — no tool covers AI model supply chain yet |
| NIST SSDF | PW.4 Reuse Existing Well-Secured Software | cargo-vet (audit trail), OSSF Scorecard (trust signals), typosquatting CLI (name verification) | No unified "dependency approval" workflow across ecosystems |
| NIST SSDF | RV.1 Respond to Vulnerabilities | osv-scanner (continuous monitoring), pip-audit --fix, cargo audit fix (auto-remediation) | Auto-fix limited to version bumps — cannot fix design-level supply chain issues |
| SLSA | Level 1 (Provenance exists) | syft (SBOM generation), cosign (attestation) | Generating provenance != consuming/verifying it at install time |
| SLSA | Level 2 (Signed provenance) | cosign (cryptographic signing), sigstore Rekor (transparency log) | Only works for artifacts that opted into sigstore — most PyPI packages have not |
| SLSA | Level 3 (Hardened builds) | cosign verify-attestation (build provenance check) | Build hardening is a producer concern — consumer tools can only verify, not enforce |
| CWE | CWE-1395 Dependency on Vulnerable Third-Party Component | osv-scanner, pip-audit, cargo-audit, npm audit, dep-scan | All rely on known vulnerability databases — zero-day supply chain attacks are invisible |
| CWE | CWE-1104 Use of Unmaintained Third Party Components | OSSF Scorecard (maintenance signals: commit frequency, issue response) | No tool blocks install of unmaintained packages — only advisory |
| CWE | CWE-1357 Reliance on Insufficiently Trustworthy Component | OSSF Scorecard (trust metrics), cargo-vet (human audit trail), socket CLI (behavioral trust) | Trust is multi-dimensional — no single tool covers all axes (code quality, maintainer intent, build integrity) |
| OWASP Top 10 | A03:2025 Software Supply Chain Failures (upgraded from A06:2021) | All tools in this pack address some aspect | OWASP 2025 expanded scope: now includes build pipeline attacks, not just known vulns |
| ASVS 4.0.3 | V14 Configuration — V14.2 Dependency | osv-scanner, pip-audit, npm audit (vulnerability checks) | ASVS requires "all components are up to date" — no tool enforces freshness policy |

---

## 3. Best Practices (from GitHub repos)

### Source: bureado/awesome-software-supply-chain-security ([GitHub](https://github.com/bureado/awesome-software-supply-chain-security))
- Practice 1: Categorize supply chain security into phases: Source, Build, Deploy, Runtime — tools should be selected per phase, not as a monolith
- Practice 2: Use GitXray for analyzing GitHub repositories to detect threat actors, fake repositories, tampered commits, and sensitive information disclosures
- Practice 3: Maintain a curated SBOM (awesomeSBOM) as a living inventory — SBOM is the foundation that all other tools build upon

### Source: GitHub Docs — Securing your supply chain ([GitHub](https://docs.github.com/en/code-security/supply-chain-security))
- Practice 1: Pin third-party GitHub Actions to full-length commit SHAs, not tags — tags can be force-pushed to point to malicious code
- Practice 2: Enable Dependabot for automated vulnerability alerts AND automated PRs to fix vulnerable dependencies
- Practice 3: Never store secrets in source code — use GitHub encrypted secrets with environment-level scoping
- Practice 4: Use `npm audit signatures` to verify that packages were published through the npm registry's signing pipeline

### Source: GitHub Actions 2026 Security Roadmap ([GitHub Blog](https://github.blog/news-insights/product-news/whats-coming-to-our-github-actions-2026-security-roadmap/))
- Practice 1: Deterministic dependency locking — lock ALL transitive dependencies, not just direct ones
- Practice 2: Enterprise-grade egress controls — restrict what network endpoints CI jobs can reach
- Practice 3: Centralized policy enforcement — organization-level rules that individual repos cannot override

---

## 4. Capability Design Recommendations

### Capability: dependency_audit
- **Type**: B (tool execution)
- **Steps**:
  1. `detect_ecosystem`: Scan project root for package manager files (package.json, requirements.txt, Cargo.toml, go.mod, pom.xml, Gemfile, composer.json)
  2. `run_scanner`: Execute ecosystem-appropriate scanner (osv-scanner for multi, pip-audit for Python, cargo-audit for Rust, npm audit for Node)
  3. `analyze_severity`: Filter results by CRITICAL/HIGH severity, check if fix versions exist, compute upgrade risk (breaking changes)
  4. `generate_report`: Structured audit report with: vulnerability ID, affected package, severity, fix version, upgrade path, breaking change risk
- **tool_ref**: [osv_scanner, pip_audit, cargo_audit, npm_audit, dep_scan]
- **quality_criteria**:
  - All direct dependencies scanned (zero skip)
  - CRITICAL vulnerabilities have explicit remediation path or documented accept-risk decision
  - Report includes transitive dependency depth for each finding
  - JSON output available for CI pipeline consumption

### Capability: behavioral_analysis
- **Type**: B (tool execution)
- **Steps**:
  1. `select_packages`: Identify new or updated dependencies from lockfile diff (git diff on lockfiles)
  2. `run_behavioral_scan`: Execute socket CLI scan on changed packages — check for network access, filesystem writes, shell execution, obfuscated code
  3. `evaluate_risk_signals`: Compare behavioral profile against known-good baseline — flag anomalies (new network calls, new fs writes, new eval/exec usage)
  4. `generate_decision`: Produce allow/block/review recommendation with evidence for each flagged package
- **tool_ref**: [socket_cli, dep_scan]
- **quality_criteria**:
  - Every new/updated dependency scanned before merge
  - Behavioral changes between versions explicitly documented
  - Network access patterns listed (domains, ports)
  - litellm-class attack vector: would this have caught the 1.82.7 behavioral change? (must answer yes or explain gap)

### Capability: provenance_verification
- **Type**: B (tool execution)
- **Steps**:
  1. `check_signatures`: For container images, verify cosign signatures and attestations against expected identity
  2. `verify_build_provenance`: Check SLSA provenance attestations — was this artifact built by the expected CI system?
  3. `validate_publisher`: Cross-reference package publisher identity with expected maintainer (npm provenance, PyPI Trusted Publishers)
  4. `score_trust`: Run OSSF Scorecard on dependency repos — flag repos with score < 5 or missing branch protection/code review
- **tool_ref**: [cosign, ossf_scorecard, syft]
- **quality_criteria**:
  - All container images verified before deployment
  - SLSA level documented for each critical dependency
  - Publisher identity verified for top-10 most critical dependencies
  - Scorecard results cached and refreshed weekly

### Capability: lockfile_integrity
- **Type**: B (tool execution)
- **Steps**:
  1. `detect_lockfiles`: Find all lockfiles in repo (package-lock.json, yarn.lock, Cargo.lock, poetry.lock, uv.lock, go.sum)
  2. `validate_hashes`: Run lockfile-lint (npm/yarn) — verify sha512 integrity hashes present, HTTPS-only hosts, no git:// URLs
  3. `check_consistency`: Compare lockfile against manifest (package.json vs package-lock.json) — detect orphan deps or missing entries
  4. `enforce_policy`: Fail CI if lockfile missing, hashes absent, or non-HTTPS registry hosts detected
- **tool_ref**: [lockfile_lint, npm_audit]
- **quality_criteria**:
  - All lockfiles have integrity hashes (sha512 minimum)
  - No packages resolved from non-HTTPS sources
  - Lockfile-to-manifest consistency verified
  - Pre-commit hook blocks lockfile modifications without corresponding manifest change

### Capability: typosquat_detection
- **Type**: B (tool execution)
- **Steps**:
  1. `extract_dependencies`: Parse all manifest files to get dependency names
  2. `generate_variants`: For each dependency, generate typosquat variants (character swap, missing char, extra char, homoglyph)
  3. `check_registries`: Query package registries for variant names — flag any that exist and have different publishers
  4. `cross_reference_sbom`: If SBOM available, scan all transitive dependencies for typosquat risk
  5. `alert_on_matches`: Generate alert with: original package, typosquat candidate, registry, download count, publisher mismatch
- **tool_ref**: [typosquatting_cli, socket_cli, dep_scan]
- **quality_criteria**:
  - All direct dependencies checked for typosquat variants
  - Flagged packages include publisher identity comparison
  - Known-good package names maintained in allowlist to reduce false positives
  - Detection covers at least: character swap, omission, addition, homoglyph substitution

---

## 5. Anti-Patterns & Pitfalls

### Anti-Pattern 1: CVE-only scanning (false sense of security)
Running only osv-scanner/pip-audit/npm-audit and declaring "no vulnerabilities found" misses the entire class of supply chain attacks where the malicious code has no CVE. The litellm 1.82.7 poisoning had no CVE at time of publish — it was a behavioral attack. **Mitigation**: Always pair CVE scanning with behavioral analysis (socket CLI) and provenance checks (cosign).

### Anti-Pattern 2: Lockfile without hash verification
Having a lockfile (package-lock.json, Cargo.lock) provides reproducibility but NOT integrity unless hashes are validated. An attacker who modifies the lockfile to point to a malicious registry or removes integrity hashes can bypass the lockfile's protection entirely. **Mitigation**: Run lockfile-lint in pre-commit hooks, enforce sha512 hashes, block non-HTTPS sources.

### Anti-Pattern 3: Trust-by-popularity ("10k stars means safe")
GitHub stars and download counts are gameable and do not indicate security posture. The axios attack (2026-03-31) targeted one of the most popular npm packages (100M+ weekly downloads). Popularity makes a package a MORE attractive target, not a safer one. **Mitigation**: Use OSSF Scorecard for evidence-based trust metrics (branch protection, code review, 2FA, signed releases).

### Anti-Pattern 4: One-time audit without continuous monitoring
Running cargo-audit once during initial setup and never again means new vulnerabilities discovered after the audit are silently ignored. Supply chain threats are continuous — new versions, new maintainers, new transitive dependencies. **Mitigation**: Integrate scanning into CI (every PR) and use Dependabot/Renovate for automated vulnerability alerts.

### Anti-Pattern 5: Ignoring transitive dependencies
Auditing only direct dependencies (listed in package.json) while ignoring transitive dependencies (the full dependency tree in package-lock.json) leaves the majority of attack surface unchecked. The axios attack vector was through a transitive dependency (plain-crypto-js@4.2.1). **Mitigation**: Always scan the full lockfile/dependency tree, not just the manifest. Use syft to generate complete SBOMs.

### Anti-Pattern 6: Auto-merging dependency update PRs without behavioral review
Dependabot/Renovate PRs that bump versions are often auto-merged if CI passes. But CI typically only checks "does it compile and pass tests" — not "did the dependency's behavior change." A poisoned version that passes all existing tests will sail through. **Mitigation**: Add socket CLI scan to the CI pipeline for dependency update PRs. Require human review for major version bumps of critical dependencies.

---

## 6. Summary: Tool Selection Priority

For a Domain Pack focused on pre-install supply chain security, the recommended tool priority:

1. **osv-scanner** — Best multi-ecosystem CVE scanner, free, Google-backed, covers the baseline
2. **socket CLI** — Only tool that does behavioral analysis (the litellm/axios-class attack detector)
3. **cosign/sigstore** — Provenance verification for container images and npm packages
4. **lockfile-lint** — Lightweight, focused, solves the hash integrity gap for npm/yarn
5. **OSSF Scorecard** — Trust scoring for dependency repos, evidence-based maintainer trust
6. **syft** — SBOM generation foundation that other tools build upon
7. **cargo-vet** — Best-in-class for Rust ecosystem human audit trails
8. **typosquatting CLI** — Multi-ecosystem typosquat detection
9. **dep-scan** — OWASP-backed, good for dependency confusion and deep risk audit
10. **pip-audit / cargo-audit / npm audit** — Ecosystem-specific scanners, use as fallback when osv-scanner insufficient
